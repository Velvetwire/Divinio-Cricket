//
//  AppDelegate.h
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import <UIKit/UIKit.h>
#import "DeviceManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow * window;
@property (strong, readonly) NSPersistentContainer * persistentContainer;

- (void) saveContext;
- (DeviceManager *) deviceManager;

@end

