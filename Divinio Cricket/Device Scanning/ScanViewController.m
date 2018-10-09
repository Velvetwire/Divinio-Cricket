//
//  ScanViewController.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "ConnectionController.h"
#import "ScanViewController.h"
#import "ScanViewCell.h"

@interface ScanViewController ( )

@property (nonatomic, weak) IBOutlet UITableView * scanTable;
@property (nonatomic, weak) IBOutlet UILabel * scanStatus;
@property (atomic, strong) NSMutableArray * deviceList;

@end

@implementation ScanViewController

- (void) viewDidLoad {

    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceManager *     manager     = [application deviceManager];

    [self setDeviceList:[[NSMutableArray alloc] init]];
    
    [manager setDelegate:self];
    [super viewDidLoad];

}

- (void) viewDidAppear:(BOOL)animated {

    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceManager *     manager     = [application deviceManager];

    [self viewSetStatus:manager.status];

    if ( manager.status == kDeviceManagerEnabled ) [manager startScanning];
        
}

- (void) viewDidDisappear:(BOOL)animated {

    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceManager *     manager     = [application deviceManager];

    if ( manager.status == kDeviceManagerEnabled ) [manager pauseScanning];
    
}

- (void) viewSetStatus:(DeviceManagerStatus)status {

    switch ( status ) {
            
        case kDeviceManagerUnavailable:
            [self.scanStatus setHidden:NO];
            [self.scanStatus setText:@"NO BLUETOOTH"];
            [self.scanTable setUserInteractionEnabled:NO];
            [self.scanTable setHidden:YES];
            break;
            
        case kDeviceManagerDisabled:
            [self.scanStatus setHidden:NO];
            [self.scanStatus setText:@"BLUETOOTH OFF"];
            [self.scanTable setUserInteractionEnabled:NO];
            [self.scanTable setHidden:YES];
            break;
            
        case kDeviceManagerEnabled:
            [self.scanStatus setHidden:YES];
            [self.scanTable setUserInteractionEnabled:YES];
            [self.scanTable setHidden:NO];
            break;
            
    }

}

#pragma mark - Device manager delegate

- (void) deviceManager:(DeviceManager *)manager didChangeStatus:(DeviceManagerStatus)status {

    dispatch_async ( dispatch_get_main_queue(), ^{ [self viewSetStatus:status]; } );
    
}

- (void) deviceManager:(DeviceManager *)manager didDiscoverDeviceIdentifier:(NSUUID *)identifier {
    
    dispatch_async ( dispatch_get_main_queue(), ^{
        [self.deviceList addObject:identifier];
        [self.scanTable reloadData];
    } );
    
}

- (void) deviceManager:(DeviceManager *)manager didUpdateDeviceIdentifier:(NSUUID *)identifier {

    NSUInteger  index   = [self.deviceList indexOfObject:identifier];

    if ( index == NSNotFound ) {
        [self deviceManager:manager didDiscoverDeviceIdentifier:identifier];
        return;
    }
    
    dispatch_async ( dispatch_get_main_queue(), ^{
        NSArray *   paths   = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]];
        [self.scanTable reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    } );

}

- (void) deviceManager:(DeviceManager *)manager didLoseDeviceIdentifier:(NSUUID *)identifier {
    
    dispatch_async ( dispatch_get_main_queue(), ^{
        [self.deviceList removeObject:identifier];
        [self.scanTable reloadData];
    } );

}

- (void) deviceManager:(DeviceManager *)manager didConnectDeviceIdentifier:(NSUUID *)identifier {

    dispatch_async ( dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"connectSegue" sender:identifier];
    } );
    
}

- (void) deviceManager:(DeviceManager *)manager didDisconnectDeviceIdentifier:(NSUUID *)identifier {

    dispatch_async ( dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    } );

}

- (void) deviceManager:(DeviceManager *)manager didFailToConnectDeviceIdentifier:(NSUUID *)identifier{

    NSLog( @"Failed to connect to %@", identifier );

}

#pragma mark - Table View Data Source and Delegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return ( 64.0 ); }

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return ( 96.0 ); }

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView { return ( 1 ); }

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return ( [self.deviceList count] ); }

- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section {

    UITableViewHeaderFooterView * header    = (UITableViewHeaderFooterView *)view;

    [header.backgroundView setBackgroundColor:[UIColor whiteColor]];
    [header.textLabel setTextColor:self.view.tintColor];
    
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return ( @"Nearby bats" );
    
}

- (void) tableView:(UITableView *)tableView willDisplayFooterView:(nonnull UIView *)view forSection:(NSInteger)section {
    
    UITableViewHeaderFooterView * footer    = (UITableViewHeaderFooterView *)view;
    
    [footer.backgroundView setBackgroundColor:[UIColor whiteColor]];
    [footer.textLabel setTextColor:[UIColor lightGrayColor]];

}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    NSString *  name = [[UIDevice currentDevice] name];
    NSString *  text = [NSString stringWithFormat:@"Knock your bat twice to activate it. "
                        "The light on the bat should begin flashing blue. "
                        "Make sure that %@ is near to the bat.", name];
    
    return ( text );
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath { return ( 50.0 ); }

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSUUID *            identifier  = [self.deviceList objectAtIndex:indexPath.row];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:identifier];
    ScanViewCell *      cell        = [tableView dequeueReusableCellWithIdentifier:@"scanCell" forIndexPath:indexPath];
    
    if ( cell && device ) {
        [cell setName:[device name] withSignal:[[device signalStrength] intValue]];
    }
    
    return ( cell );
    
}

- (bool) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {

    return ( YES );

}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSUUID *            identifier  = [self.deviceList objectAtIndex:indexPath.row];
    
    [[application deviceManager] connectDeviceWithIdentifier:identifier];
    
}

#pragma mark - Connect and disconnect actions

- (IBAction) unwindConnection:(UIStoryboardSegue *)segue {

    if ( [segue.identifier isEqualToString:@"disconnectSegue"] ) {

        AppDelegate *   application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [[application deviceManager] disconnectAllDevices];
    
        [self.scanTable deselectRowAtIndexPath:[self.scanTable indexPathForSelectedRow] animated:NO];
    
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ( [segue.identifier isEqualToString:@"connectSegue"] ) {
    
        AppDelegate *           application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        ConnectionController *  controller  = segue.destinationViewController;
        NSUUID *                identifier  = (NSUUID *)sender;
        DeviceInstance *        device      = [[application deviceManager] deviceFromIdentifier:identifier];

        [controller connectedToIdentifier:identifier withName:[device name]];
        
    }
    
}

@end
