//
//  DeviceInstance.h
//  Divinio Cricket
//
//  The device instance provides a CoreBluetooth peripheral implementation to
//  use when interacting with the Velvetwire Stickershock device.
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import <CoreData/CoreData.h>
#import <CoreBluetooth/CoreBluetooth.h>

// Device notices
#define kDeviceNoticeNumber         (@"deviceNumber")
#define kDeviceNoticeSignal         (@"deviceSignal")
#define kDeviceNoticeRename         (@"deviceRename")
#define kDeviceNoticeBattery        (@"deviceBattery")
#define kDeviceNoticeTemperature    (@"deviceTemperature")
#define kDeviceNoticePressure       (@"devicePressure")
#define kDeviceNoticeMoisture       (@"deviceMoisture")
#define kDeviceNoticeStroke         (@"deviceStroke")
#define kDeviceNoticeStrike         (@"deviceStrike")

// Standard bluetooth device information service
#define UUID_DEVICE_SERVICE         (@"180A")           // Device information service
#define UUID_DEVICE_MAKE            (@"2A29")           // Manufacturer name string
#define UUID_DEVICE_MODEL           (@"2A24")           // Model string
#define UUID_DEVICE_NUMBER          (@"2A25")           // Serial number string
#define UUID_DEVICE_HARDWARE        (@"2A27")           // Hardware revision
#define UUID_DEVICE_FIRMWARE        (@"2A26")           // Firmware revision
#define UUID_DEVICE_SOFTWARE        (@"2A28")           // Software revision

// Standard bluetooth battery information service
#define UUID_BATTERY_SERVICE        (@"180F")           // Battery service
#define UUID_BATTERY_LEVEL          (@"2A19")           // Battery level (0-100)

// Primary sticker service
#define UUID_STICKER_SERVICE        (@"DF1C")           // Sticker service
#define UUID_STICKER_ALIAS          (@"DFCA")           // Sticker name proxy
#define UUID_STICKER_BLINK          (@"DFCB")           // Sticker identification blink
#define UUID_STICKER_CLOCK          (@"DFCC")           // Sticker clock (UNIX time)
#define UUID_STICKER_FORMAT         (@"DFCF")           // Sticker behavior format

typedef NS_ENUM( NSUInteger, DevicePlayFormat ) {
    kDevicePlayPractice = 0,
    kDevicePlayTournament = 1,
};

// Ball impact service
#define UUID_IMPACT_SERVICE         (@"551A")           // Ball impact service
#define UUID_IMPACT_STRIKE          (@"5511")           // Strike description
#define UUID_IMPACT_STROKE          (@"5512")           // Stroke description
#define UUID_IMPACT_REJECT          (@"551D")           // Tap rejection setting

typedef NS_ENUM( NSInteger, StrokeType ) {
    kStrokeTypeBogus = -1,
    kStrokeTypeSwing = 0,
};

typedef NS_ENUM( NSInteger, StrikeType ) {
    kStrikeTypeBogus = -1,
    kStrikeTypeHit = 0,
    kStrikeTypeTap,
    kStrikeTypeEdge,
    kStrikeTypeBlock,
};

typedef struct __attribute__ (( packed )) {
    
    unsigned                time;                       // Time code of stroke (UNIX time)
    unsigned char           code;                       // Data payload verification code
    unsigned char           type;                       // Stroke classification type (not currently used)
    
    signed short            speed;                      // Tip speed measurement
    signed short            twist;                      // Bat twist measurement
    
} impact_stroke_t;

typedef struct __attribute__ (( packed )) {

    unsigned                time;                       // Time code of strike (UNIX time)
    unsigned char           code;                       // Data payload verification code
    unsigned char           type;                       // Strike classification type (tap, hit, edge, block)

    signed short            power;                      // Power measurement (0 - 1000)
    signed short            quality;                    // Quality measurement (0 - 100)
    signed short            offset;                     // Offset position
    signed short            center;                     // Center offset
    
} impact_strike_t;

typedef struct __attribute__ (( packed )) {
    
    unsigned                number;                     // Shot index (from shot odometer)
    
    union {
        unsigned char       encode [ 16 ];              // Encoded data
        impact_stroke_t     stroke;                     // Decoded stroke summary data
        impact_strike_t     strike;                     // Decoded strike summary data
    }   data;
    
} impact_data_t;

// Environmental service
#define UUID_AIR_SERVICE            (@"55ED")           // Environmental air service
#define UUID_AIR_TEMPERATURE        (@"55E1")           // Air temperature reading
#define UUID_AIR_PRESSURE           (@"55E2")           // Air pressure reading
#define UUID_AIR_MOISTURE           (@"55E3")           // Air moisture reading

@interface DeviceInstance : NSObject <CBPeripheralDelegate>

@property (nonatomic, strong, readonly) NSUUID * identifier;

@property (nonatomic) NSString * name;
@property (nonatomic, strong, readonly) NSString * make;
@property (nonatomic, strong, readonly) NSString * model;
@property (nonatomic, strong, readonly) NSString * number;
@property (nonatomic, strong, readonly) NSString * version;

@property (nonatomic, readonly) NSUInteger shot;

@property (nonatomic, readonly) StrokeType stroke;
@property (nonatomic, readonly) NSNumber * speed;
@property (nonatomic, readonly) NSNumber * twist;

@property (nonatomic, readonly) StrikeType strike;
@property (nonatomic, readonly) NSNumber * power;
@property (nonatomic, readonly) NSNumber * quality;

@property (nonatomic, readonly) NSNumber * temperature;
@property (nonatomic, readonly) NSNumber * pressure;
@property (nonatomic, readonly) NSNumber * moisture;
@property (nonatomic, readonly) NSNumber * battery;

@property (nonatomic) DevicePlayFormat playFormat;
@property (nonatomic) bool tapRejection;

- (id) initWithPeripheral:(CBPeripheral *)peripheral signal:(NSNumber *)signal;

- (bool) signalPresent;
- (NSNumber *) signalStrength;
- (void) advertisedSignal:(NSNumber *)signal;
- (void) retrieveSignal;

- (void) connectToCentral:(CBCentralManager *)central;
- (void) disconnectFromCentral:(CBCentralManager *)central;

@end
