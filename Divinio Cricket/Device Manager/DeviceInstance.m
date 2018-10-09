//
//  DeviceInstance.m
//  Divinio Cricket
//
//  The device instance provides a CoreBluetooth peripheral implementation to
//  use when interacting with the Velvetwire Stickershock device.
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import "DeviceInstance.h"

@interface DeviceInstance ( )

@property (nonatomic, strong) CBPeripheral * peripheral;
@property (nonatomic, strong) NSNumber * signal;
@property (nonatomic) bool present;

@property (nonatomic, strong) CBCharacteristic * characteristicAlias;
@property (nonatomic, strong) CBCharacteristic * characteristicBlink;
@property (nonatomic, strong) CBCharacteristic * characteristicFormat;
@property (nonatomic, strong) CBCharacteristic * characteristicReject;
@property (nonatomic, strong) CBCharacteristic * characteristicBattery;

@end

@implementation DeviceInstance

- (id) initWithPeripheral:(CBPeripheral *)peripheral signal:(NSNumber *)signal {
    
    if ( (self = [super init]) ) {
        
        _peripheral     = peripheral;
        _identifier     = [[NSUUID alloc] initWithUUIDString:peripheral.identifier.UUIDString];
        _signal         = signal;
        
    }
    
    [peripheral setDelegate:self];
    
    return ( self );
    
}

#pragma mark - Device name

- (NSString *) name { return ( _peripheral.name ); }

- (void) setName:(NSString *)name {

    const char *    string  = [name cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *        data    = [NSData dataWithBytes:string length:strlen(string)];

    if ( self.characteristicAlias )
        [self.peripheral writeValue:data forCharacteristic:self.characteristicAlias type:CBCharacteristicWriteWithResponse];

    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNoticeRename
                                                        object:self
                                                      userInfo:@{ @"device":self, @"value":name } ];

}

#pragma mark - Device play format (practice or tournament)

@synthesize playFormat = _playFormat;

- (DevicePlayFormat) playFormat { return ( _playFormat ); }

- (void) setPlayFormat:(DevicePlayFormat)format {

    NSData *        data    = [NSData dataWithBytes:&(format) length:sizeof(char)];
    _playFormat             = format;

    if ( self.characteristicFormat )
        [self.peripheral writeValue:data forCharacteristic:self.characteristicFormat type:CBCharacteristicWriteWithResponse];

}

#pragma mark - Tap rejection setting

@synthesize tapRejection = _tapRejection;

- (bool) tapRejection { return ( _tapRejection ); }

- (void) setTapRejection:(bool)rejection {
    
    NSData *        data    = [NSData dataWithBytes:&(rejection) length:sizeof(char)];
    _tapRejection           = rejection;
    
    if ( self.characteristicReject )
        [self.peripheral writeValue:data forCharacteristic:self.characteristicReject type:CBCharacteristicWriteWithResponse];
    
}

#pragma mark - Bluetooth peripheral delegate

- (void) peripheral:(CBPeripheral *)peripheral didReadRSSI:(nonnull NSNumber *)RSSI error:(nullable NSError *)error {
 
    if ( !error ) [self setSignal:RSSI];
    else return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNoticeSignal
                                                        object:self
                                                      userInfo:@{ @"device":self, @"value":self.signal } ];

}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {

    if ( error ) return;

    for ( CBService * service in peripheral.services ) { [peripheral discoverCharacteristics:nil forService:service]; }

}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {

    if ( error ) return;

    for ( CBCharacteristic * characteristic in service.characteristics ) {

        // Read any of the one-time read-only properties we encounter
        if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_DEVICE_MAKE]]
          || [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_DEVICE_MODEL]]
          || [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_DEVICE_NUMBER]]
          || [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_DEVICE_FIRMWARE]] ) {

            if ( characteristic.properties & CBCharacteristicPropertyRead ) [peripheral readValueForCharacteristic:characteristic];

        }

        // If this is the battery level property, read it and register for updates
        if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_BATTERY_LEVEL]] ) {

            if ( characteristic.properties & CBCharacteristicPropertyRead ) [peripheral readValueForCharacteristic:characteristic];
            if ( characteristic.properties & CBCharacteristicPropertyNotify ) [peripheral setNotifyValue:YES forCharacteristic:characteristic];

            [self setCharacteristicBattery:characteristic];

        }
        
        // If this is the name alias characteristic, keep a reference to it
        if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_STICKER_ALIAS]] )
            [self setCharacteristicAlias:characteristic];

        // If this is the blink characteristic, keep a reference to it
        if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_STICKER_BLINK]] )
            [self setCharacteristicBlink:characteristic];

        // If this is the clock characteristic, update the sticker clock to the current UTC time
        if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_STICKER_CLOCK]] ) {
            
            unsigned        seconds = (unsigned) time ( NULL );
            NSData *        data    = [NSData dataWithBytes:&(seconds) length:sizeof(unsigned)];
            
            if ( characteristic.properties & CBCharacteristicPropertyWrite )
                [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        
        }

        // If this is the sticker format characteristic, get a reference and read it
        if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_STICKER_FORMAT]] ) {
            
            if ( characteristic.properties & CBCharacteristicPropertyRead ) [peripheral readValueForCharacteristic:characteristic];
            
            [self setCharacteristicFormat:characteristic];
            
        }

        // If this is the tap rejection characteristic, get a reference and read it
        if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_IMPACT_REJECT]] ) {
            
            if ( characteristic.properties & CBCharacteristicPropertyRead ) [peripheral readValueForCharacteristic:characteristic];
            
            [self setCharacteristicReject:characteristic];
            
        }

        // If this is either the stroke or strike characteristic, register for notices
        if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_IMPACT_STROKE]]
          || [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_IMPACT_STRIKE]] ) {
            
            if ( characteristic.properties & CBCharacteristicPropertyNotify ) [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        
        // If this is one of the atmospheric properties, read it and register for updates
        if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_AIR_TEMPERATURE]]
          || [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_AIR_PRESSURE]]
          || [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_AIR_MOISTURE]] ) {
            
            if ( characteristic.properties & CBCharacteristicPropertyRead ) [peripheral readValueForCharacteristic:characteristic];
            if ( characteristic.properties & CBCharacteristicPropertyNotify ) [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
        }
    }

}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {

    if ( error ) return;

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_DEVICE_MAKE]] )
        [self peripheral:peripheral didUpdateValueForMake:characteristic];

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_DEVICE_MODEL]] )
        [self peripheral:peripheral didUpdateValueForModel:characteristic];

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_DEVICE_FIRMWARE]] )
        [self peripheral:peripheral didUpdateValueForVersion:characteristic];

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_DEVICE_NUMBER]] )
        [self peripheral:peripheral didUpdateValueForNumber:characteristic];

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_BATTERY_LEVEL]] )
        [self peripheral:peripheral didUpdateValueForBattery:characteristic];

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_STICKER_FORMAT]] )
        [self peripheral:peripheral didUpdateValueForFormat:characteristic];
    
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_IMPACT_REJECT]] )
        [self peripheral:peripheral didUpdateValueForRejection:characteristic];

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_IMPACT_STROKE]] )
        [self peripheral:peripheral didUpdateValueForStroke:characteristic];
    
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_IMPACT_STRIKE]] )
        [self peripheral:peripheral didUpdateValueForStrike:characteristic];

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_AIR_TEMPERATURE]] )
        [self peripheral:peripheral didUpdateValueForTemperature:characteristic];

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_AIR_PRESSURE]] )
        [self peripheral:peripheral didUpdateValueForPressure:characteristic];

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_AIR_MOISTURE]] )
        [self peripheral:peripheral didUpdateValueForMoisture:characteristic];

}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForMake:(nonnull CBCharacteristic *)characteristic {
    
    _make                   = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForModel:(nonnull CBCharacteristic *)characteristic {
    
    _model                  = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForNumber:(nonnull CBCharacteristic *)characteristic {

    _number                 = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];

    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNoticeNumber
                                                        object:self
                                                      userInfo:@{ @"device":self, @"value":self.number } ];
    
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForVersion:(nonnull CBCharacteristic *)characteristic {
    
    _version                = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];

}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForBattery:(nonnull CBCharacteristic *)characteristic {

    NSData *        data    = [characteristic value];
    const uint8_t * bytes   = [data bytes];
    NSInteger       value   = bytes ? (uint8_t)(bytes[0]) : 0;
    _battery                = [NSNumber numberWithFloat:(value < 100) ? ((float)value / 100) : (1.0)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNoticeBattery
                                                        object:self
                                                      userInfo:@{ @"device":self, @"value":self.battery } ];
    
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForFormat:(nonnull CBCharacteristic *)characteristic {
    
    NSData *        data    = [characteristic value];
    const uint8_t * bytes   = [data bytes];
    _playFormat             = (DevicePlayFormat) bytes[0];

}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForRejection:(nonnull CBCharacteristic *)characteristic {

    NSData *        data    = [characteristic value];
    const uint8_t * bytes   = [data bytes];
    _tapRejection           = (bool) bytes[0];

}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForStroke:(nonnull CBCharacteristic *)characteristic {
    
    NSData *        data    = [characteristic value];
    impact_data_t * impact  = (impact_data_t *)[data bytes];
    
    _shot                   = (NSUInteger) impact->number;
    _stroke                 = (StrokeType) impact->data.stroke.type;
    _speed                  = [NSNumber numberWithInt:impact->data.stroke.speed];
    _twist                  = [NSNumber numberWithInt:impact->data.stroke.twist];

    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNoticeStroke
                                                        object:self
                                                      userInfo:@{ @"device":self } ];

}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForStrike:(nonnull CBCharacteristic *)characteristic {
    
    NSData *        data    = [characteristic value];
    impact_data_t * impact  = (impact_data_t *)[data bytes];

    _shot                   = (NSUInteger) impact->number;
    _strike                 = (StrikeType) impact->data.strike.type;
    _power                  = [NSNumber numberWithInt:impact->data.strike.power];
    _quality                = [NSNumber numberWithInt:impact->data.strike.quality];

    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNoticeStrike
                                                        object:self
                                                      userInfo:@{ @"device":self } ];

}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForTemperature:(nonnull CBCharacteristic *)characteristic {
    
    NSData *        data    = [characteristic value];
    const uint8_t * bytes   = [data bytes];
    float           value   = bytes ? (*((float *)bytes)) : 0.0;
    _temperature            = [NSNumber numberWithFloat:value];

    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNoticeTemperature
                                                        object:self
                                                      userInfo:@{ @"device":self, @"value":self.temperature } ];

}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForPressure:(nonnull CBCharacteristic *)characteristic {
    
    NSData *        data    = [characteristic value];
    const uint8_t * bytes   = [data bytes];
    float           value   = bytes ? (*((float *)bytes)) : 0.0;
    _pressure               = [NSNumber numberWithFloat:value];

    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNoticePressure
                                                        object:self
                                                      userInfo:@{ @"device":self, @"value":self.pressure } ];

}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForMoisture:(nonnull CBCharacteristic *)characteristic {
    
    NSData *        data    = [characteristic value];
    const uint8_t * bytes   = [data bytes];
    float           value   = bytes ? (*((float *)bytes)) : 0.0;
    _moisture               = [NSNumber numberWithFloat:value];

    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNoticeMoisture
                                                        object:self
                                                      userInfo:@{ @"device":self, @"value":self.moisture } ];

}

#pragma mark - Signal strength during advertisement phase

- (bool) signalPresent { return ( self.present ); }

- (NSNumber *) signalStrength { return ( self.signal ); }

- (void) advertisedSignal:(NSNumber *)signal {
    
    if ( signal != nil ) {

        [self setSignal:signal];
        [self setPresent:YES];

    } else { [self setPresent:NO]; }
    
}

- (void) retrieveSignal {

    [self.peripheral readRSSI];
    
}

#pragma mark - Connection and disconnection

- (void) connectToCentral:(CBCentralManager *)central { [central connectPeripheral:self.peripheral options:nil]; }

- (void) disconnectFromCentral:(CBCentralManager *)central { [central cancelPeripheralConnection:self.peripheral]; }

@end
