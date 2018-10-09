//
//  UISignalGadget.h
//  Divinio Cricket
//
//  The signal gadget renders a simple four-bar signal level meter.
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import <UIKit/UIKit.h>

// Define the thresholds to be used for the graphic representation

#define kNoSignal               -127
#define kFaintSignalThreshold   -91
#define kLowSignalThreshold     -83
#define kHighSignalThreshold    -73
#define kStrongSignalThreshold  -65

@interface UISignalGadget : UIView

- (void) setSignal:(NSInteger)signal;

@end
