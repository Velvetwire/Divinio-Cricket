//
//  SessionTabController.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "SessionTabController.h"
#import "SessionShotCell.h"

@interface SessionTabController ()

@property (strong, nonatomic) CLLocationManager * location;

@property (weak, nonatomic) IBOutlet UITableView * table;
@property (weak, nonatomic) IBOutlet UITextField * locationField;
@property (weak, nonatomic) IBOutlet UITextField * descriptionField;

@property (strong, nonatomic) NSMutableArray * taps;
@property (strong, nonatomic) NSMutableArray * shots;
@property (strong, nonatomic) NSMutableArray * swings;

@end

@implementation SessionTabController

- (void) viewDidLoad {

    // Load the superview first
    [super viewDidLoad];

    // Initialize the arrays for taps, shots and swings
    _taps   = [[NSMutableArray alloc] init];
    _shots  = [[NSMutableArray alloc] init];
    _swings = [[NSMutableArray alloc] init];

    // Serve as the delegate for editable elements
    [self.locationField setDelegate:self];
    [self.descriptionField setDelegate:self];

    // Set placeholders for editable fields
    [self viewLoadDescriptionPlaceholder];
    [self viewLoadLocationPlaceholder];
    
}

- (void) viewLoadDescriptionPlaceholder {

    NSDate *            date    = [NSDate date];
    NSDateFormatter *   format  = [[NSDateFormatter alloc] init];

    // Get the current local time and format it
    [format setLocale:[NSLocale currentLocale]];
    [format setDateFormat:@"MMMM d, YYYY h:ma"];

    // Set the description placeholder
    [self.descriptionField setPlaceholder:[NSString stringWithFormat:@"Session %@", [format stringFromDate:date]]];
    
}

- (void) viewLoadLocationPlaceholder {
    
    // Construct a CoreLocation manager
    _location       = [[CLLocationManager alloc] init];
    
    // Request a one-time in-use location update
    [self.location requestWhenInUseAuthorization];
    [self.location setDistanceFilter:kCLDistanceFilterNone];
    [self.location setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.location setDelegate:self];
    [self.location requestLocation];

}

#pragma mark - Table View Data Source and Delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView { return ( kSessionsSections ); }

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch ( section ) {
        case kSessionSectionShots:          return @"Shots";
        case kSessionSectionTaps:           return @"Taps";
        default:                            return nil;
    }
    
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    switch ( section ) {
        case kSessionSectionShots:          return @"Shots captured during this session";
        case kSessionSectionTaps:           return @"Taps captured during this session";
        default:                            return nil;
    }

}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch ( section ) {
        case kSessionSectionShots:          return ( self.shots.count );
        case kSessionSectionTaps:           return ( self.taps.count );
        default:                            return ( 0 );
    }
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath { return ( 50.0 ); }

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *       cell    = nil;
    SessionShotDetails *    details = nil;
    
    switch ( indexPath.section ) {
        // Set the details for a tap cell in the tap section
        case kSessionSectionTaps:
            cell    = [tableView dequeueReusableCellWithIdentifier:@"sessionTapCell" forIndexPath:indexPath];
            details = [self.taps objectAtIndex:indexPath.row];
            if ( details ) {
            }
            break;
        // Set the details of a shot cell for the shot section
        case kSessionSectionShots:
            cell    = [tableView dequeueReusableCellWithIdentifier:@"sessionShotCell" forIndexPath:indexPath];
            details = [self.shots objectAtIndex:indexPath.row];
            if ( details ) {
                [(SessionShotCell *)cell setStrike:[details.strike integerValue] quality:details.quality power:details.power];
                [(SessionShotCell *)cell setStroke:[details.stroke integerValue] speed:details.speed twist:details.twist];
            }
            break;
    }
    
    return ( cell );
    
}

#pragma mark - Text Field Delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
 
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return ( YES );
    
}

#pragma mark - Location delegate

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    
    CLLocation *    location    = [locations objectAtIndex:0];
    CLGeocoder *    geocoder    = [[CLGeocoder alloc] init];
    
    // Reverse geo-code the location into human readable format and set the location placeholder
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray * placemarks, NSError * error) {
                       CLPlacemark *    place   = [placemarks objectAtIndex:0];
                       NSString *       name    = place.locality;
                       if ( place.administrativeArea ) { name = [name stringByAppendingString:[NSString stringWithFormat:@", %@", place.administrativeArea]]; }
                       [self.locationField setPlaceholder:name];
                   }];
    
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    NSLog ( @"Location error %@", error );

}

#pragma mark - Device notifications

- (void) didReceiveStroke:(NSInteger)stroke type:(StrokeType)type speed:(NSNumber *)speed twist:(NSNumber *)twist {

    SessionShotDetails *    details = [[SessionShotDetails alloc] init];
    
    [details setShot:[NSNumber numberWithInteger:stroke]];
    [details setStroke:[NSNumber numberWithInteger:type]];
    
    [details setSpeed:speed];
    [details setTwist:twist];

    [self didReceiveSwingDetails:details];
    
}

- (void) didReceiveStrike:(NSInteger)strike type:(StrikeType)type quality:(NSNumber *)quality power:(NSNumber *)power {
    
    for ( SessionShotDetails * details in self.swings )
        if ( [details.shot integerValue] == strike ) {

            [details setStrike:[NSNumber numberWithInteger:type]];
            [details setQuality:quality];
            [details setPower:power];
            
            switch ( type ) {
                case kStrikeTypeTap:    [self didReceiveTapDetails:details]; break;
                case kStrikeTypeHit:    [self didReceiveShotDetails:details]; break;
                case kStrikeTypeEdge:   [self didReceiveShotDetails:details]; break;
                case kStrikeTypeBlock:  [self didReceiveShotDetails:details]; break;
                default:                break;
            }
            
            break;
        
        }
    
}

- (void) didReceiveTapDetails:(SessionShotDetails *)details {

    [self.taps insertObject:details atIndex:0];
    [self.swings removeObject:details];

    dispatch_async ( dispatch_get_main_queue(), ^{ [self.table reloadData]; } );

}

- (void) didReceiveShotDetails:(SessionShotDetails *)details {

    [self.shots insertObject:details atIndex:0];
    [self.swings removeObject:details];

    dispatch_async ( dispatch_get_main_queue(), ^{ [self.table reloadData]; } );

}

- (void) didReceiveSwingDetails:(SessionShotDetails *)details {

    [self.swings addObject:details];

}

@end
