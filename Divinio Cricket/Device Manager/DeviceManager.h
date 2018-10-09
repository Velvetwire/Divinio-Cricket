//
//  DeviceManager.h
//  Divinio Cricket
//
//  The device manager provides a CoreBluetooth central implementation to
//  use when interacting with the Velvetwire Stickershock device. The manager
//  is data backed via a device registry with a record for each known device.
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import "DeviceInstance.h"

@protocol DeviceManagerDelegate;

typedef NS_ENUM( NSInteger, DeviceManagerStatus ) {
    kDeviceManagerUnavailable,
    kDeviceManagerDisabled,
    kDeviceManagerEnabled
};

@interface DeviceManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic, weak) id <DeviceManagerDelegate> delegate;
@property (nonatomic, readonly) DeviceManagerStatus status;

- (id) initWithContext:(NSManagedObjectContext *)context;

- (DeviceInstance *) deviceFromIdentifier:(NSUUID *)identifier;

- (void) startScanning;
- (void) pauseScanning;

- (void) connectDeviceWithIdentifier:(NSUUID *)identifier;
- (void) disconnectDeviceWithIdentifier:(NSUUID *)identifier;
- (void) disconnectAllDevices;

- (NSString *) makeForDeviceWithIdentifier:(NSUUID *)identifier;
- (void) setMake:(NSString *)make forDeviceWithIdentifier:(NSUUID *)identifier;

- (NSString *) modelForDeviceWithIdentifier:(NSUUID *)identifier;
- (void) setModel:(NSString *)model forDeviceWithIdentifier:(NSUUID *)identifier;

@end

@protocol DeviceManagerDelegate <NSObject>

@required
- (void) deviceManager:(DeviceManager *)manager didDiscoverDeviceIdentifier:(NSUUID *)identifier;
- (void) deviceManager:(DeviceManager *)manager didUpdateDeviceIdentifier:(NSUUID *)identifier;
- (void) deviceManager:(DeviceManager *)manager didLoseDeviceIdentifier:(NSUUID *)identifier;

@required
- (void) deviceManager:(DeviceManager *)manager didConnectDeviceIdentifier:(NSUUID *)identifier;
- (void) deviceManager:(DeviceManager *)manager didDisconnectDeviceIdentifier:(NSUUID *)identifier;
- (void) deviceManager:(DeviceManager *)manager didFailToConnectDeviceIdentifier:(NSUUID *)identifier;

@optional
- (void) deviceManager:(DeviceManager *)manager didChangeStatus:(DeviceManagerStatus)status;

@end
