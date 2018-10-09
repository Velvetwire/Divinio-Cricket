//
//  UIDialGadget.m
//  Divinio Cricket
//
//  The dial gadget provides a simple view control which renders a dial
//  and a value.
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import "UIDialGadget.h"

@interface UIDialGadget ( )

@property (nonatomic, strong) UILabel * label;

@end

@implementation UIDialGadget

#pragma mark - Initialization

- (void) awakeFromNib {
    
    // Handler super initialization
    [super awakeFromNib];
    
    // Initialize elements
    [self initElements];
    
}

//
// Initialize the gadget using a frame size.
- (id) initWithFrame:(CGRect)frame {
    
    // Initialize elements
    if ( (self = [super initWithFrame:frame]) ) [self initElements];
    
    // Return with instance
    return ( self );
    
}

- (void) initElements {
    
    // Add and initialize the level label
    _label  = [[UILabel alloc] initWithFrame:self.frame];
    if ( self.label ) {
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setFont:[UIFont systemFontOfSize:13.0]];
        [self.label setTextColor:self.tintColor];
        [self addSubview:self.label];
    }
    
    // Set the background to clear and handle layout manually
    [self setBackgroundColor:[UIColor clearColor]];
    [self setAutoresizesSubviews:NO];
    
}


#pragma mark - Settings and values

@synthesize level = _level;
@synthesize value = _value;

- (CGFloat) level { return ( _level ); }

- (void) setLevel:(CGFloat)level {

    // Set the level
    _level = level;
    
    // Update the dial
    [self setNeedsDisplay];

}

- (CGFloat) value { return ( _value ); }

- (void) setValue:(CGFloat)value {

    // Set the value
    _value = value;
    
    // Update the label
    [self.label setText:[NSString stringWithFormat:@"%i", (int)roundf(self.value)]];
    
}

#pragma mark - Layout and positioning

//
// Position the level label in the center of the view.
- (void) layoutSubviews {
    
    [super layoutSubviews];
    [self.label setFrame:self.bounds];
    
}

#pragma mark - Rendering

- (void) drawRect:(CGRect)rect {

    CGContextRef    context = UIGraphicsGetCurrentContext( );
    CGPoint         center  = CGPointMake( rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2 );
    float           radius  = MIN( rect.size.width/2, rect.size.height/2 );
    float           angle   = (PI/2) + (self.level * 2 * PI);
    float           width   = 5.0;

    CGContextSaveGState( context );
    CGContextSetAllowsAntialiasing( context, YES );

    CGContextSetFillColorWithColor( context, self.tintColor.CGColor );
    
    // Construct a filled arc from the level value with the given radius and thickness
    CGContextAddArc( context, center.x, center.y, radius, (PI/2), angle, 0 );
    CGContextAddLineToPoint( context, center.x + cosf(angle) * (radius - width), center.y + sinf(angle) * (radius - width) );
    CGContextAddArc( context, center.x, center.y, radius - width, angle, (PI/2), 1 );
    CGContextClosePath( context );
    
    // Draw the arc
    CGContextDrawPath( context, kCGPathFill );
    CGContextRestoreGState( context );

}

@end
