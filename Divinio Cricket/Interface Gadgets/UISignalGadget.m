//
//  UISignalGadget.m
//  Divinio Cricket
//
//  The signal gadget renders a simple four-bar signal level meter.
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import "UISignalGadget.h"

@interface UISignalGadget ( )

@property (nonatomic, strong) UILabel * label;
@property (nonatomic) NSInteger value;

@end

@implementation UISignalGadget

#pragma mark - Initialization

//
// Initialize the gadget using a frame size.
- (id) initWithFrame:(CGRect)frame {
    
    if ( (self = [super initWithFrame:frame]) ) {

        _value  = kNoSignal;
        _label  = [[UILabel alloc] initWithFrame:self.frame];
    
        if ( self.label ) {
            [self.label setTextAlignment:NSTextAlignmentRight];
            [self.label setFont:[UIFont systemFontOfSize:9.0]];
            [self.label setTextColor:self.tintColor];
            [self addSubview:self.label];
        }
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAutoresizesSubviews:NO];
    
    }

    return ( self );
    
}

#pragma mark - Settings and values

//
// Set the signal level and associated label text.
- (void) setSignal:(NSInteger)signal {

    [self setValue:signal];
    
    [self.label setText:[NSString stringWithFormat:@"%i dB", (int)self.value]];
    [self setNeedsDisplay];
    
}

#pragma mark - Layout and positioning

//
// Position the decibel level label in the bottom half of the view.
- (void) layoutSubviews {

    CGRect          frame  = self.frame;
    frame.origin.y         = frame.origin.y + frame.size.height/2.0 + 8.0;
    frame.size.height      = frame.size.height/2.0 - 6.0;
    
    [super layoutSubviews];
    [self.label setFrame:frame];
    
}

//
// Shift and grow the bar area to the next position.
- (void) moveBar:(CGRect *)rect {
    
    rect->origin.x      += 5.0;
    rect->origin.y      -= 2.0;
    rect->size.height   += 2.0;

}

#pragma mark - Rendering

//
// Draw a signal bar element.
- (void) drawBar:(CGRect)rect inContext:(CGContextRef)context threshold:(bool)threshold {
    
    CGPathRef       path    = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:1.0].CGPath;
    
    // Select the bar color based on the whether it is above or below the threshold.
    if ( threshold ) { CGContextSetFillColorWithColor( context, self.tintColor.CGColor ); }
    else { CGContextSetFillColorWithColor( context, [UIColor lightGrayColor].CGColor ); }
    
    // Draw the signal bar element.
    CGContextAddPath( context, path );
    CGContextClosePath ( context );
    CGContextFillPath( context );
    
}

//
// Draw the graphic signal representation in the center of the view.
- (void) drawRect:(CGRect)rect {

    CGContextRef    context = UIGraphicsGetCurrentContext( );
    CGRect          area    = CGRectMake( rect.size.width - 18.0, rect.size.height/2.0, 3.0, 6.0 );

    CGContextSaveGState( context );
    CGContextSetAllowsAntialiasing( context, YES );
    
    // Draw the first signal bar
    [self drawBar:area inContext:context threshold:(self.value >= kFaintSignalThreshold ? YES : NO)];
    [self moveBar:&area];
    
    // Draw the second signal bar
    [self drawBar:area inContext:context threshold:(self.value >= kLowSignalThreshold ? YES : NO)];
    [self moveBar:&area];

    // Draw the third signal bar
    [self drawBar:area inContext:context threshold:(self.value >= kHighSignalThreshold ? YES : NO)];
    [self moveBar:&area];

    // Draw the fourth signal bar
    [self drawBar:area inContext:context threshold:(self.value >= kStrongSignalThreshold ? YES : NO)];
    [self moveBar:&area];

    CGContextRestoreGState( context );
    
}

@end
