//
//  UIBatteryGadget.m
//  Divinio Cricket
//
//  The battery gadget renders a simple battery level icon.
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import "UIBatteryGadget.h"

@interface UIBatteryGadget ( )

@property (nonatomic, strong) UILabel * label;
@property (nonatomic) NSInteger value;

@end

@implementation UIBatteryGadget

#pragma mark - Initialization

//
// Initialize the gadget using a frame size.
- (id) initWithFrame:(CGRect)frame {
    
    if ( (self = [super initWithFrame:frame]) ) {
        
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
// Set the charge level and associated label text.
- (void) setLevel:(NSInteger)level {
    
    if ( level < 0 ) { level = 0; }
    if ( level > 100 ) { level = 100; }
    
    [self setValue:level];
    
    [self.label setText:[NSString stringWithFormat:@"%i%%", (int)self.value]];
    [self setNeedsDisplay];
    
}

#pragma mark - Layout and positioning

//
// Position the charge level label in the bottom half of the view.
- (void) layoutSubviews {
    
    CGRect          frame  = self.frame;
    frame.origin.y         = frame.origin.y + frame.size.height/2.0 + 8.0;
    frame.size.height      = frame.size.height/2.0 - 6.0;
    
    [super layoutSubviews];
    [self.label setFrame:frame];
    
}

- (void) drawBatteryTip:(CGRect)rect inContext:(CGContextRef)context {
    
    rect.origin.x           = rect.origin.x + rect.size.width - 2.0;
    rect.size.width         = 1.5;
    CGPathRef       path    = [UIBezierPath bezierPathWithRoundedRect:CGRectInset( rect, 0, 3.0 ) cornerRadius:0.75].CGPath;
    
    CGContextSetFillColorWithColor( context, [UIColor lightGrayColor].CGColor );
    
    CGContextAddPath( context, path );
    CGContextClosePath ( context );
    CGContextFillPath( context );
    
}

- (void) drawBattery:(CGRect)rect inContext:(CGContextRef)context {
    
    rect.size.width         = rect.size.width - 3.0;
    CGPathRef       path    = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:2.5].CGPath;
    
    CGContextSetFillColorWithColor( context, self.tintColor.CGColor );
    CGContextSetStrokeColorWithColor( context, [UIColor lightGrayColor].CGColor );
    
    CGContextAddPath( context, path );
    CGContextClosePath ( context );
    CGContextStrokePath( context );
    
    rect                    = CGRectInset( rect, 1.5, 1.5 );
    rect.size.width         = rect.size.width * self.value / 100.0;
    path                    = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:1.0].CGPath;

    CGContextAddPath( context, path );
    CGContextClosePath ( context );
    CGContextFillPath( context );

}

//
// Draw the graphic signal representation in the center of the view.
- (void) drawRect:(CGRect)rect {
    
    CGContextRef    context = UIGraphicsGetCurrentContext( );
    CGRect          area    = CGRectMake( rect.size.width - 25.0, (rect.size.height - 10.0)/2.0, 25.0, 10.0 );
    
    CGContextSaveGState( context );
    CGContextSetAllowsAntialiasing( context, YES );
    
    [self drawBatteryTip:area inContext:context];
    [self drawBattery:area inContext:context];
    
    CGContextRestoreGState( context );
    
}
@end
