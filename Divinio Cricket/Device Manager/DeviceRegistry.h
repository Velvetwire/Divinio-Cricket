//
//  DeviceRegistry.h
//  Divinio Cricket
//
//  The device registry provides a CoreData managed list of known devices
//  and allows for supplementary information to be tracked with each
//  device, using its unique identifier (UUID).
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import <CoreData/CoreData.h>

//
// Device equipment record reference
@interface DeviceRecord : NSManagedObject

// Unique identifier used by Core Bluetooth
@property (nonatomic, retain) NSUUID * identifier;

// Unique serial number used by the device
@property (nonatomic, retain) NSString * number;

// Device make and model
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * make;

- (BOOL) matchesIdentifier:(NSUUID *)identifier;
- (BOOL) matchesNumber:(NSString *)number;

@end

//
// Known device registry
@interface DeviceRegistry : NSObject

- (id) initWithContext:(NSManagedObjectContext *)context;

- (DeviceRecord *) registerDeviceWithIdentifier:(NSUUID *)identifier;
- (DeviceRecord *) deviceWithIdentifier:(NSUUID *)identifier;
- (void) removeDeviceWithIdentifier:(NSUUID *)identifier;

- (void) setNumber:(NSString *)number forDeviceWithIdentifier:(NSUUID *)identifier;
- (NSString *) numberForDeviceWithIdentifier:(NSUUID *)identifier;

- (void) setModel:(NSString *)model forDeviceWithIdentifier:(NSUUID *)identifier;
- (NSString *) modelForDeviceWithIdentifier:(NSUUID *)identifier;

- (void) setMake:(NSString *)make forDeviceWithIdentifier:(NSUUID *)identifier;
- (NSString *) makeForDeviceWithIdentifier:(NSUUID *)identifier;

@end
