//
//  ConnectionPageController.h
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import <UIKit/UIKit.h>
#import "DeviceInstance.h"

@interface ConnectionPageController : UIViewController

@property (nonatomic) NSString * deviceName;
@property (nonatomic) NSString * deviceMake;
@property (nonatomic) NSString * deviceModel;
@property (nonatomic) NSString * deviceNumber;
@property (nonatomic) NSString * deviceVersion;

@property (nonatomic) NSString * equipmentMake;
@property (nonatomic) NSString * equipmentModel;

@property (readonly) NSNumber * deviceTemperature;
@property (readonly) NSNumber * deviceMoisture;
@property (readonly) NSNumber * devicePressure;

@property (nonatomic) DevicePlayFormat deviceFormat;
@property (nonatomic) bool tapRejection;

- (void) connectedToIdentifier:(NSUUID *)identifier;

- (void) didReceiveStroke:(NSInteger)stroke type:(StrokeType)type speed:(NSNumber *)speed twist:(NSNumber *)twist;
- (void) didReceiveStrike:(NSInteger)strike type:(StrikeType)type quality:(NSNumber *)quality power:(NSNumber *)power;

- (bool) deviceUpdateAvailable;

@end
