//
//  ShotTabController.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "UIPowerGadget.h"
#import "ShotTabController.h"

@interface ShotTabController ( )

@property (weak, nonatomic) IBOutlet UIPowerGadget * powerGadget;
@property (weak, nonatomic) IBOutlet UILabel * shotLegend;
@property (weak, nonatomic) IBOutlet UILabel * shotNumber;
@property (weak, nonatomic) IBOutlet UILabel * shotSpeed;
@property (weak, nonatomic) IBOutlet UILabel * shotTwist;

@end

@implementation ShotTabController

- (void) viewDidLoad {
    
    [super viewDidLoad];

    // Set the color of the various shot numbers
    [self.shotSpeed setTextColor:self.view.tintColor];
    [self.shotTwist setTextColor:self.view.tintColor];
    
    // Start with the power gadget hidden
    [self.powerGadget setHidden:YES];

}

#pragma mark - Device notifications

- (void) didReceiveStroke:(NSInteger)stroke type:(StrokeType)type speed:(NSNumber *)speed twist:(NSNumber *)twist {

    // Update the bat stroke parameters
    dispatch_async ( dispatch_get_main_queue(), ^{
        [self.shotNumber setText:[NSString stringWithFormat:@"%i", (int)stroke]];
        [self.shotSpeed setText:[NSString stringWithFormat:@"%1.1f m/s", [speed floatValue]]];
        [self.shotTwist setText:[NSString stringWithFormat:@"%1.1f \u00B0/s", [twist floatValue]]];
    } );

}

- (void) didReceiveStrike:(NSInteger)strike type:(StrikeType)type quality:(NSNumber *)quality power:(NSNumber *)power {
    
    // Update the power guage and parameters
    dispatch_async ( dispatch_get_main_queue(), ^{
        
        switch ( type ) {
            case kStrikeTypeTap:    [self.shotLegend setText:@"TAP"]; break;
            case kStrikeTypeHit:    [self.shotLegend setText:@"SHOT"]; break;
            case kStrikeTypeEdge:   [self.shotLegend setText:@"EDGE"]; break;
            case kStrikeTypeBlock:  [self.shotLegend setText:@"BLOCK"]; break;
            default:                [self.shotLegend setText:@""]; break;
        }
        
        [self.powerGadget setPower:[power floatValue] andLevel:[quality floatValue]/100.0];
        [self.powerGadget setHidden:NO];
        
    } );

}

/*
- (void) didReceiveStroke:(NSNotification *)notification {
    
    DeviceInstance *    device  = [notification.userInfo objectForKey:@"device"];
    
    // Update the bat stroke parameters
    dispatch_async ( dispatch_get_main_queue(), ^{
        [self.shotNumber setText:[NSString stringWithFormat:@"%i", (int) device.shot]];
        [self.shotSpeed setText:[NSString stringWithFormat:@"%i m/s", [device.speed intValue]]];
        [self.shotTwist setText:[NSString stringWithFormat:@"%i deg/s", [device.twist intValue]]];
    } );

}

- (void) didReceiveStrike:(NSNotification *)notification {
    
    DeviceInstance *    device  = [notification.userInfo objectForKey:@"device"];
    float               level   = [device.quality floatValue] / 100.0;
    float               power   = [device.power floatValue];

    // Update the shot legend power gadget with the strike details
    dispatch_async ( dispatch_get_main_queue(), ^{

        switch ( device.strike ) {
            case kStrikeTypeTap:    [self.shotLegend setText:@"TAP"]; break;
            case kStrikeTypeHit:    [self.shotLegend setText:@"SHOT"]; break;
            case kStrikeTypeEdge:   [self.shotLegend setText:@"EDGE"]; break;
            case kStrikeTypeBlock:  [self.shotLegend setText:@"BLOCK"]; break;
            default:                [self.shotLegend setText:@""]; break;
        }
        
        [self.powerGadget setPower:power andLevel:level];
        [self.powerGadget setHidden:NO];
    
    } );
 
}
*/

@end
