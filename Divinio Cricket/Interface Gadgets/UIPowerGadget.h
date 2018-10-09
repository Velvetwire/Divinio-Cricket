//
//  UIPowerGadget.h
//  Divinio Cricket
//
//  The power gadget provides a simple view control which renders a dial,
//  along with a needle and bubble, as well as a value.
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#ifndef PI
#define PI  3.14159265358979323846
#endif

// Define the interface for the gadget as a view

@interface UIPowerGadget : UIView

@property (nonatomic) float power;
@property (nonatomic) float level;

- (void) setPower:(float)power andLevel:(float)level;

@end

// Define a special rendering layer for the gauge component

@interface CAPowerGauge : CALayer

@property (nonatomic) CGFloat power;
@property (nonatomic) CGFloat level;
@property (nonatomic) CGColorRef backColor;
@property (nonatomic) CGColorRef tintColor;

@end
