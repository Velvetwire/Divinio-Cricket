//
//  DeviceRegistry.m
//  Divinio Cricket
//
//  The device registry provides a CoreData managed list of known devices
//  and allows for supplementary information to be tracked with each
//  device, using its unique identifier (UUID).
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import "DeviceRegistry.h"

@interface DeviceRegistry ( )

@property (nonatomic, weak) NSManagedObjectContext * context;
@property (nonatomic, strong) NSMutableArray * equipment;

@end

@implementation DeviceRegistry

- (id) initWithContext:(NSManagedObjectContext *)context {

    if ( (self = [super init]) ) {
        
        // Establish the managed object context which will be used for
        // data model access.
        
        _context        = context;
        
        // Initialize the list of registered equipment.
        
        NSFetchRequest *    fetchRequest;
        
        fetchRequest    = [[NSFetchRequest alloc] initWithEntityName:@"Equipment"];
        _equipment      = [[self.context executeFetchRequest:fetchRequest error:nil] mutableCopy];

    }
    
    return ( self );
    
}

- (DeviceRecord *) deviceWithIdentifier:(NSUUID *)identifier {
    
    DeviceRecord *  record  = nil;
    
    for ( record in self.equipment ) if ( [record matchesIdentifier:identifier] ) { return ( record ); }
    
    return ( nil );
    
}

- (DeviceRecord *) registerDeviceWithIdentifier:(NSUUID *)identifier {

    DeviceRecord *  record  = nil;
    NSError *       error   = nil;
    
    for ( record in self.equipment )
        if ( [record matchesIdentifier:identifier] ) {
            NSLog ( @"Existing device %@ serial %@", record.identifier, record.number );
            return ( record );
        }
    
    if ( (record = [NSEntityDescription insertNewObjectForEntityForName:@"Equipment" inManagedObjectContext:self.context]) ) {
        
        record.identifier   = identifier;

        [self.equipment addObject:record];
        [self.context save:&(error)];

        if ( error ) return ( nil );
        
    }

    NSLog ( @"Registered new device %@", identifier );
    
    return ( record );
    
}

- (void) removeDeviceWithIdentifier:(NSUUID *)identifier {

    DeviceRecord *  record  = [self deviceWithIdentifier:identifier];
    NSError *       error   = nil;
    
    if ( record ) {

        [self.equipment removeObject:record];
        [self.context deleteObject:record];

    }
    
    [self.context save:&(error)];

}

- (NSString *) numberForDeviceWithIdentifier:(NSUUID *)identifier {
    
    DeviceRecord *  record  = [self deviceWithIdentifier:identifier];
    
    if ( record ) { return record.number; }
    else return ( nil );
    
}

- (void) setNumber:(NSString *)number forDeviceWithIdentifier:(NSUUID *)identifier {

    DeviceRecord *  record  = [self deviceWithIdentifier:identifier];
    NSError *       error   = nil;
    
    if ( record ) { record.number = [number uppercaseString]; }

    [self.context save:&(error)];

}

- (NSString *) modelForDeviceWithIdentifier:(NSUUID *)identifier {
    
    DeviceRecord *  record  = [self deviceWithIdentifier:identifier];
    
    if ( record ) { return record.model; }
    else return ( nil );
    
}

- (void) setModel:(NSString *)model forDeviceWithIdentifier:(NSUUID *)identifier {
    
    DeviceRecord *  record  = [self deviceWithIdentifier:identifier];
    NSError *       error   = nil;
    
    if ( record ) { record.model = model; }
    
    [self.context save:&(error)];
    
}

- (NSString *) makeForDeviceWithIdentifier:(NSUUID *)identifier {
    
    DeviceRecord *  record  = [self deviceWithIdentifier:identifier];
    
    if ( record ) { return record.make; }
    else return ( nil );
    
}

- (void) setMake:(NSString *)make forDeviceWithIdentifier:(NSUUID *)identifier {
    
    DeviceRecord *  record  = [self deviceWithIdentifier:identifier];
    NSError *       error   = nil;
    
    if ( record ) { record.make = make; }
    
    [self.context save:&(error)];
    
}

@end

@implementation DeviceRecord

@dynamic identifier;
@dynamic number;
@dynamic model;
@dynamic make;

- (BOOL) matchesIdentifier:(NSUUID *)identifier {
    return [self.identifier isEqual:identifier];
}

- (BOOL) matchesNumber:(NSString *)number {
    return ([self.number compare:number options:NSCaseInsensitiveSearch] ? NO : YES);
}

@end
