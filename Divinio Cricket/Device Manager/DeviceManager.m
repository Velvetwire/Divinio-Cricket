//
//  DeviceManager.m
//  Divinio Cricket
//
//  The device manager provides a CoreBluetooth central implementation to
//  use when interacting with the Velvetwire Stickershock device. The manager
//  is data backed via a device registry with a record for each known device.
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import "DeviceManager.h"
#import "DeviceRegistry.h"

@interface DeviceManager ( )

// Known device registry
@property (nonatomic, strong) DeviceRegistry * registry;

// Bluetooth central managager and scan update timer
@property (nonatomic, strong) CBCentralManager * central;
@property (nonatomic, strong) NSTimer * timer;

// List of discovered devices and device connections
@property (atomic, strong) NSMutableArray * connections;
@property (atomic, strong) NSMutableArray * discovered;

@end

@implementation DeviceManager

- (id) initWithContext:(NSManagedObjectContext *)context {
    
    if ( (self = [super init]) ) {
        
        // Construct an instance of the device equipment registry.
        
        _registry       = [[DeviceRegistry alloc] initWithContext:context];
        
        // Construct the Bluetooth LE central manager with an identifier
        // option for automatic restoration and a warning if BLE is not
        // powered on
        
        _central        = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:dispatch_queue_create("com.velvetwire.divinio.central", DISPATCH_QUEUE_SERIAL)
                                                             options:@{ CBCentralManagerOptionRestoreIdentifierKey:@"divinioCentral",
                                                                        CBCentralManagerOptionShowPowerAlertKey:@YES }];
        
        // Start with an empty list of discovered devices and connections
        
        _connections    = [[NSMutableArray alloc] init];
        _discovered     = [[NSMutableArray alloc] init];

        // Construct and start the scan refresh timer
        
        _timer          = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(scanTimer:) userInfo:nil repeats:YES];
    
        // Regisister to receive device information notifications
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNumber:) name:kDeviceNoticeNumber object:nil];

    }
    
    return ( self );
    
}

#pragma mark - Bluetooth Central Manager Delegate

- (void) centralStatus:(DeviceManagerStatus)status { _status = status; }

- (void) centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dictionary {
    
    NSArray *       peripherals = dictionary[ CBCentralManagerRestoredStatePeripheralsKey ];
    NSArray *       services    = dictionary[ CBCentralManagerRestoredStateScanServicesKey ];
    NSDictionary *  options     = dictionary[ CBCentralManagerRestoredStateScanOptionsKey ];
    
    // Loop through the list of peripherals that were connected or had a pending connection
    // at the time of application termination and continue with the connection
    
    for ( CBPeripheral * peripheral in peripherals )
        [central connectPeripheral:peripheral options:nil];
    
    // Re-start the scanning process using the restored service list and options
    
    if ( services.count && self.central.state == CBManagerStatePoweredOn )
        [central scanForPeripheralsWithServices:services options:options];
    
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch ( central.state ) {
            
        case CBManagerStatePoweredOn:
            // Device manager is enabled now that bluetooth is on
            [self centralStatus:kDeviceManagerEnabled];
            [self startScanning];
            break;
            
        case CBManagerStatePoweredOff:
            // Device manager is disabled now that bluetooth is resetting
            [self centralStatus:kDeviceManagerDisabled];
            break;
            
        case CBManagerStateResetting:
            // Device manager is disabled now that bluetooth is off
            [self centralStatus:kDeviceManagerDisabled];
            [self pauseScanning];
            break;
            
        case CBManagerStateUnauthorized:
        case CBManagerStateUnsupported:
        case CBManagerStateUnknown:
            // Device manager is unavailable for technical reasons
            [self centralStatus:kDeviceManagerUnavailable];
            break;
            
    }
    
    // Forward the status change to the delegate...
    if ( self.delegate && [self.delegate respondsToSelector:@selector(deviceManager:didChangeStatus:)] ) {
        [self.delegate deviceManager:self didChangeStatus:self.status];
    }
    
}


- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisement RSSI:(NSNumber *)rssi {
    
    //if ( [advertisement objectForKey:CBAdvertisementDataIsConnectable] && ([peripheral state] == CBPeripheralStateDisconnected) ) {
    if ( [advertisement objectForKey:CBAdvertisementDataIsConnectable]  ) {
        
        // Check whether this is a previously discovered device and, if so, update the signal
        for ( DeviceInstance * device in self.discovered )
            if ( [[device identifier] isEqual:peripheral.identifier] ) {
                [device advertisedSignal:rssi];
                return;
            }
        
        // Create a new device instance from the discovered peripheral and add it to the list
        DeviceInstance *    device      = [[DeviceInstance alloc] initWithPeripheral:peripheral signal:rssi];
        [self.discovered addObject:device];
        
        // Forward the discovery to the delegate...
        if ( self.delegate && [self.delegate respondsToSelector:@selector(deviceManager:didDiscoverDeviceIdentifier:)] ) {
            [self.delegate deviceManager:self didDiscoverDeviceIdentifier:device.identifier];
        }
        
    }
    
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    // Find the peripheral within the list of discovered devices
    for ( DeviceInstance * device in self.discovered )
        if ( [[device identifier] isEqual:peripheral.identifier] ) {

            // Register the peripheral with the equipment registry
            [self.registry registerDeviceWithIdentifier:peripheral.identifier];
            
            // Initiate service discovery..
            [peripheral discoverServices:nil];
            
            // Transfer the device from the discovered list to the connection list
            [self.connections addObject:device];
            [self.discovered removeObject:device];
            
            // Forward the connection to the delegate...
            if ( self.delegate && [self.delegate respondsToSelector:@selector(deviceManager:didConnectDeviceIdentifier:)] ) {
                [self.delegate deviceManager:self didConnectDeviceIdentifier:device.identifier];
            }

            break;
            
        }

    // Disable the scanner once connected
    [self pauseScanning];
    
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    // Find the peripheral within the list of devices
    for ( DeviceInstance * device in self.connections )
        if ( [[device identifier] isEqual:peripheral.identifier] ) {

            // Transfer the device from the connection list back to the discovered list
            [self.discovered addObject:device];
            [self.connections removeObject:device];
            
            // Forward the disconnection to the delegate...
            if ( self.delegate && [self.delegate respondsToSelector:@selector(deviceManager:didDisconnectDeviceIdentifier:)] ) {
                [self.delegate deviceManager:self didDisconnectDeviceIdentifier:device.identifier];
            }
            
            break;
            
        }

    // Re-start the scanner once disconnected
    //[self startScanning];

}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    // Find the peripheral within the list of discovered devices
    for ( DeviceInstance * device in self.discovered )
        if ( [[device identifier] isEqual:peripheral.identifier] ) {
            
            // Forward the failure to the delegate...
            if ( self.delegate && [self.delegate respondsToSelector:@selector(deviceManager:didFailToConnectDeviceIdentifier:)] ) {
                [self.delegate deviceManager:self didFailToConnectDeviceIdentifier:device.identifier];
            }
            
            break;
            
        }

}

#pragma mark - Device scanning

- (void) startScanning {

    if ( self.central.state == CBManagerStatePoweredOn) {
        
        // Start scanning for peripherals which publish the sticker service
        [self.central scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:UUID_STICKER_SERVICE]]
                                             options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES } ];
    
    }
    
}

- (void) pauseScanning {

    if ( self.central.state == CBManagerStatePoweredOn) {

        // Stop scanning for peripherals
        [self.central stopScan];

    }

}

- (void) scanTimer:(NSTimer *)timer {
   
    NSMutableArray *    lost = [[NSMutableArray alloc] init];
    
    // Generate a list of lost devices
    for ( DeviceInstance * device in self.discovered ) if ( ![device signalPresent] ) [lost addObject:device];
    for ( DeviceInstance * device in self.discovered ) [device advertisedSignal:nil];

    // Forward losses to the delegate...
    for ( DeviceInstance * device in lost )
        if ( self.delegate && [self.delegate respondsToSelector:@selector(deviceManager:didLoseDeviceIdentifier:)] ) {
            [self.delegate deviceManager:self didLoseDeviceIdentifier:[device identifier]];
        }
    
    // Remove lost devices from the discovered list
    [self.discovered removeObjectsInArray:lost];

    // Forward updates to the delegate...
    for ( DeviceInstance * device in self.discovered )
        if ( self.delegate && [self.delegate respondsToSelector:@selector(deviceManager:didUpdateDeviceIdentifier:)] ) {
            [self.delegate deviceManager:self didUpdateDeviceIdentifier:[device identifier]];
        }
    
    // Read the RSSI for any connected devices
    for ( DeviceInstance * device in self.connections )
        [device retrieveSignal];
    
}

#pragma mark - Device characteristic notifications

- (void) didReceiveNumber:(NSNotification *)notification {
    
    DeviceInstance *    device = [notification.userInfo objectForKey:@"device"];
    NSString *          number = [notification.userInfo objectForKey:@"value"];
    
    [self.registry setNumber:number forDeviceWithIdentifier:device.identifier];
    
}

#pragma mark - Device connection and management

- (DeviceInstance *) deviceFromIdentifier:(NSUUID *)identifier {

    // Look through the list of connected devices first
    for ( DeviceInstance * device in self.connections )
        if ( [[device identifier] isEqual:identifier] )
            return ( device );

    // Look through the list of discovered devices next
    for ( DeviceInstance * device in self.discovered )
        if ( [[device identifier] isEqual:identifier] )
            return ( device );
    
    // Not found
    return ( nil );
    
}

- (void) connectDeviceWithIdentifier:(NSUUID *)identifier {

    DeviceInstance *    device = [self deviceFromIdentifier:identifier];
    
    if ( device ) [device connectToCentral:self.central];
    
}

- (void) disconnectDeviceWithIdentifier:(NSUUID *)identifier {
    
    DeviceInstance *    device = [self deviceFromIdentifier:identifier];
    
    if ( device ) [device disconnectFromCentral:self.central];
    
}

- (void) disconnectAllDevices {

    for ( DeviceInstance * device in self.connections )
        [device disconnectFromCentral:self.central];

}

#pragma mark - Device registry interface

- (NSString *) makeForDeviceWithIdentifier:(NSUUID *)identifier { return [self.registry makeForDeviceWithIdentifier:identifier]; }

- (void) setMake:(NSString *)make forDeviceWithIdentifier:(NSUUID *)identifier { [self.registry setMake:make forDeviceWithIdentifier:identifier]; }

- (NSString *) modelForDeviceWithIdentifier:(NSUUID *)identifier { return [self.registry modelForDeviceWithIdentifier:identifier]; }

- (void) setModel:(NSString *)model forDeviceWithIdentifier:(NSUUID *)identifier { [self.registry setModel:model forDeviceWithIdentifier:identifier]; }

@end
