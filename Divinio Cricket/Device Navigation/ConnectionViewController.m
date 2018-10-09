//
//  ConnectionViewController.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "DeviceManager.h"
#import "ConnectionViewController.h"
#import "ConnectionPageController.h"

@interface ConnectionViewController ( )

@end

@implementation ConnectionViewController

#pragma mark - Initialization

- (void) viewDidLoad {

    // Handle superview loading
    [super viewDidLoad];

    // Pre-load all of the sub-views since they need to listen for updates
    for ( ConnectionPageController * controller in self.viewControllers )
        [controller loadViewIfNeeded];

}

#pragma mark - Device association

- (void) connectedToIdentifier:(NSUUID *)identifier withName:(NSString *)name {
    
    // Set the navigation title to the device name
    [self.navigationItem setTitle:name];
    
    // Forward the associated peripheral identifier to each of the sub-views
    for ( ConnectionPageController * controller in self.viewControllers )
        [controller connectedToIdentifier:identifier];

}

#pragma mark - Presentation

- (void) viewWillAppear:(BOOL)animated {
    
    // Interested in device rename updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRename:) name:kDeviceNoticeRename object:nil];

    // Interested in device impact updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveStroke:) name:kDeviceNoticeStroke object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveStrike:) name:kDeviceNoticeStrike object:nil];
    
    // Let the super view handle appearance
    [super viewWillAppear:animated];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
    // No longer interested in notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Let the super view handle disappearance
    [super viewWillDisappear:animated];
    
}

#pragma mark - Device notifications

- (void) didReceiveRename:(NSNotification *)notification {
    
    // Update the name in response to the device rename
    NSString *          name    = [notification.userInfo objectForKey:@"value"];
    dispatch_async ( dispatch_get_main_queue(), ^{ [self.navigationItem setTitle:name]; } );
    
}

- (void) didReceiveStroke:(NSNotification *)notification {
    
    DeviceInstance *    device  = [notification.userInfo objectForKey:@"device"];

    // Forward the notification to all of the pages in case one is interested
    for ( ConnectionPageController * controller in self.viewControllers )
        [controller didReceiveStroke:device.shot type:device.stroke speed:device.speed twist:device.twist];

}

- (void) didReceiveStrike:(NSNotification *)notification {
    
    DeviceInstance *    device  = [notification.userInfo objectForKey:@"device"];

    // Forward the notification to all of the pages in case one is interested
    for ( ConnectionPageController * controller in self.viewControllers )
        [controller didReceiveStrike:device.shot type:device.strike quality:device.quality power:device.power];

}

#pragma mark - Interface activity

- (IBAction) didClickDisconnect:(id)sender {

    // Return to the scan view via the disconnect segue
    [self performSegueWithIdentifier:@"disconnectSegue" sender:self];

}

#pragma mark - Navigation

 - (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
 }

@end
