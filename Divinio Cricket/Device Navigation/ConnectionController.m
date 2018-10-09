//
//  ConnectionController.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "UISignalGadget.h"
#import "UIBatteryGadget.h"

#import "DeviceManager.h"
#import "ConnectionController.h"
#import "ConnectionViewController.h"

@interface ConnectionController ()

@property (nonatomic, strong) NSUUID * identifier;
@property (nonatomic, strong) UISignalGadget * signalLevel;
@property (nonatomic, strong) UIBatteryGadget * batteryLevel;

@end

@implementation ConnectionController

#pragma mark - Initialization

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self setSignalLevel:[[UISignalGadget alloc] initWithFrame:CGRectMake(0, 0, 45, 33)]];
    [self setBatteryLevel:[[UIBatteryGadget alloc] initWithFrame:CGRectMake(0, 0, 45, 33)]];

    [self.navigationBar addSubview:self.batteryLevel];
    [self.navigationBar addSubview:self.signalLevel];

}

- (void) connectedToIdentifier:(NSUUID *)identifier  withName:(NSString *)name {
    
    [self setIdentifier:identifier];
    [(ConnectionViewController *)[self topViewController] connectedToIdentifier:identifier withName:name];
    
}

#pragma mark - Appearance and layout

- (void) viewWillAppear:(BOOL)animated {

    // Interested in signal level and battery level updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSignal:) name:kDeviceNoticeSignal object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBattery:) name:kDeviceNoticeBattery object:nil];

}

- (void) viewWillDisappear:(BOOL)animated {

    // No longer interested in notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void) viewWillLayoutSubviews {
    
    CGRect  frame       = self.navigationBar.frame;
    CGRect  area        = self.batteryLevel.frame;
    CGRect  rect        = CGRectMake((frame.size.width - area.size.width - 14.0),
                                     (frame.size.height - area.size.height) / 2.0,
                                     (area.size.width), (area.size.height));
    
    [self.batteryLevel setFrame:rect];
    
    frame.size.width    = frame.size.width - rect.size.width;
    area                = self.signalLevel.frame;
    rect                = CGRectMake((frame.size.width - area.size.width - 4.0),
                                     (frame.size.height - area.size.height) / 2.0,
                                     (area.size.width), (area.size.height));
    
    [self.signalLevel setFrame:rect];
    
}

#pragma mark - Characteristic value updates

- (void) didReceiveSignal:(NSNotification *)notification {

    DeviceInstance *    device = [notification.userInfo objectForKey:@"device"];
    NSNumber *          signal = [notification.userInfo objectForKey:@"value"];
    
    if ( [device.identifier isEqual:self.identifier] ) dispatch_async ( dispatch_get_main_queue(), ^{
        [self.signalLevel setSignal:[signal integerValue]];
    } );

}

- (void) didReceiveBattery:(NSNotification *)notification {
    
    DeviceInstance *    device = [notification.userInfo objectForKey:@"device"];
    NSNumber *          charge = [notification.userInfo objectForKey:@"value"];
    
    if ( [device.identifier isEqual:self.identifier] ) dispatch_async ( dispatch_get_main_queue(), ^{
        [self.batteryLevel setLevel:(int)roundf([charge floatValue] * 100.0)];
    } );
    
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog ( @"Navigation %@ segue to %@", segue.identifier, segue.destinationViewController );

}

@end
