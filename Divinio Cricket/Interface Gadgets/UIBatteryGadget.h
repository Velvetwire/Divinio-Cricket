//
//  UIBatteryGadget.h
//  Divinio Cricket
//
//  The battery gadget renders a simple battery level icon.
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import <UIKit/UIKit.h>

// Define the thresholds to be used for the graphic representation

#define kLowBatteryLevel        50
#define kCriticalBatteryLevel   20

@interface UIBatteryGadget : UIView

- (void) setLevel:(NSInteger)level;

@end
