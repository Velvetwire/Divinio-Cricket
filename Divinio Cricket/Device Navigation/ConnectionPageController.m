//
//  ConnectionPageController.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "AppDelegate.h"
#import "ConnectionPageController.h"

@interface ConnectionPageController ()

@property (nonatomic, strong) NSUUID * identifier;

@end

@implementation ConnectionPageController

#pragma mark - Device association

- (void) connectedToIdentifier:(NSUUID *)identifier {
    
    [self setIdentifier:identifier];
    
}

#pragma mark - Device characteristic interface

- (NSString *) deviceName {

    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];

    if ( device ) return [device name];
    else return nil;
    
}

- (void) setDeviceName:(NSString *)name {
    
    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];
    
    if ( device ) [device setName:name];

}

- (NSString *) deviceMake {
    
    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];
    
    if ( device ) return [device make];
    else return nil;
    
}

- (NSString *) deviceModel {
    
    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];
    
    if ( device ) return [device model];
    else return nil;
    
}

- (NSString *) deviceNumber {
    
    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];
    
    if ( device ) return [device number];
    else return nil;
    
}

- (NSString *) deviceVersion {
    
    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];
    
    if ( device ) return [device version];
    else return nil;
    
}

- (NSNumber *) deviceTemperature {
    
    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];
    
    if ( device ) return [device temperature];
    else return nil;
    
}

- (NSNumber *) deviceMoisture {
    
    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];
    
    if ( device ) return [device moisture];
    else return nil;
    
}

- (NSNumber *) devicePressure {
    
    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];
    
    if ( device ) return [device pressure];
    else return nil;
    
}

- (DevicePlayFormat) deviceFormat {

    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];
    
    if ( device ) return [device playFormat];
    else return kDevicePlayPractice;

}

- (void) setDeviceFormat:(DevicePlayFormat)format {

    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];
    
    if ( device ) [device setPlayFormat:format];

}

- (NSString *) equipmentMake {

    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    return [[application deviceManager] makeForDeviceWithIdentifier:self.identifier];
    
}

- (void) setEquipmentMake:(NSString *)make {

    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    [[application deviceManager] setMake:make forDeviceWithIdentifier:self.identifier];
    
}

- (NSString *) equipmentModel {

    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    return [[application deviceManager] modelForDeviceWithIdentifier:self.identifier];

}

- (void) setEquipmentModel:(NSString *)model {

    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    [[application deviceManager] setModel:model forDeviceWithIdentifier:self.identifier];

}

- (bool) tapRejection {
    
    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];
    
    if ( device ) return [device tapRejection];
    else return NO;
    
}

- (void) setTapRejection:(bool)rejection {
    
    AppDelegate *       application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    DeviceInstance *    device      = [[application deviceManager] deviceFromIdentifier:self.identifier];
    
    if ( device ) [device setTapRejection:rejection];
    
}

- (bool) deviceUpdateAvailable {

    // For now...
    return NO;
    
}

#pragma mark - Device notifications

- (void) didReceiveStroke:(NSInteger)stroke type:(StrokeType)type speed:(NSNumber *)speed twist:(NSNumber *)twist {

}

- (void) didReceiveStrike:(NSInteger)strike type:(StrikeType)type quality:(NSNumber *)quality power:(NSNumber *)power {

}

@end
