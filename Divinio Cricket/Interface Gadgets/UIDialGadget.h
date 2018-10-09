//
//  UIDialGadget.h
//  Divinio Cricket
//
//  The dial gadget provides a simple view control which renders a dial
//  and a value.
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#ifndef PI
#define PI  3.14159265358979323846
#endif

#import <UIKit/UIKit.h>

@interface UIDialGadget : UIView

@property (nonatomic) CGFloat level;
@property (nonatomic) CGFloat value;

@end

