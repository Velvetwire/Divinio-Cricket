//
//  UIPowerGadget.m
//  Divinio Cricket
//
//  The power gadget provides a simple view control which renders a dial,
//  along with a needle and bubble, as well as a value.
//
//  Copyright © 2017 Velvetwire, LLC. All rights reserved.
//  Author: Eric Bodnar
//

#import "UIPowerGadget.h"

#pragma mark - Power gadget internal properties

@interface UIPowerGadget ( )

@property (nonatomic, strong) CAPowerGauge * powerGauge;

@end

#pragma Mark - Power gadget implementation

@implementation UIPowerGadget

- (void) awakeFromNib {

    // Handler super initialization
    [super awakeFromNib];

    // Add the power gauge layer
    _powerGauge = [[CAPowerGauge alloc] init];

    if ( self.powerGauge ) {
        [self.powerGauge setContentsScale:2.0];
        [self.powerGauge setTintColor:self.tintColor.CGColor];
        [self.powerGauge setBackColor:self.backgroundColor.CGColor];
        [self.layer addSublayer:self.powerGauge];
    }
    
    // Assume a transparent background
    [self setBackgroundColor:[UIColor clearColor]];
    
}

#pragma mark - Sub-element layout

- (void) layoutSubviews { [self.powerGauge setFrame:self.bounds]; }

#pragma mark - Proxies for setting the power and level values

- (float) power { return [self.powerGauge power]; }

- (void) setPower:(float)power { [self.powerGauge setPower:power]; }

- (float) level { return [self.powerGauge level]; }

- (void) setLevel:(float)level { [self.powerGauge setLevel:level]; }

#pragma mark - Animated setting of the power and level values

- (void) setPower:(float)power andLevel:(float)level {

    [UIView animateWithDuration:1.5
                          delay:0.0
                        options:(UIViewAnimationOptions) UIViewAnimationCurveEaseOut
                     animations:^{ self.power = power; self.level = level; }
                     completion:nil];

}

@end

#pragma mark - Power gauge render layer

@implementation CAPowerGauge

@dynamic    power;
@dynamic    level;

- (id) init {
    
    // Set up the colors to use
    if ( (self = [super init]) ) {
        _backColor  = [UIColor whiteColor].CGColor;
        _tintColor  = [UIColor blackColor].CGColor;
    }
    
    return ( self );
}

#pragma mark - Animatable properties

+ (BOOL) needsDisplayForKey:(NSString *)key {
    
    // Power and level can be animated
    if ( [key isEqualToString:@"power"] ) return ( YES );
    if ( [key isEqualToString:@"level"] ) return ( YES );
    
    // Check with the superview for other animatable values
    return [super needsDisplayForKey:key];
    
}

- (id<CAAction>) actionForKey:(NSString *)key {
    
    // The power value is animatable so construct and animation if asked
    if ( [key isEqualToString:@"power"] ) {
        
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:key];
        
        if ( animation ) {
            [animation setKeyPath:key];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [animation setFromValue:@([[self presentationLayer] power])];
        }
        
        return ( animation );
        
    }
    
    // The level value is animatable so construct and animation if asked
    if ( [key isEqualToString:@"level"] ) {
        
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:key];
        
        if ( animation ) {
            [animation setKeyPath:key];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [animation setFromValue:@([[self presentationLayer] level])];
        }
        
        return ( animation );
        
    }
    
    // Check with the superview for other animatable values
    return [super actionForKey:key];
    
}

#pragma mark - Rendering

- (void) drawInContext:(CGContextRef)context {
    
    CGRect              bounds  = CGRectInset( self.bounds, 45.0, 45.0 );
    CGPoint             center  = CGPointMake( bounds.origin.x + bounds.size.width/2, bounds.origin.y + bounds.size.height/2 );
    float               radius  = MIN( bounds.size.width/2, bounds.size.height/2 );
    
    // Draw the level needle and bubble
    CGContextSetFillColorWithColor( context, self.modelLayer.backColor );
    CGContextSetStrokeColorWithColor( context, self.modelLayer.tintColor );
    
    [self drawInContext:context needleAtCenter:center withRadius:radius];
    
    radius                      = radius - 7.0;
    
    // Draw the power arc
    CGContextSetFillColorWithColor( context, self.modelLayer.tintColor );
    CGContextSetStrokeColorWithColor( context, self.modelLayer.backColor );
    
    [self drawInContext:context arcAtCenter:center withRadius:radius];
    
    // Render the power number in the center of the bounds
    NSNumber *          power   = [NSNumber numberWithInteger:roundf(self.power)];
    [self drawInContext:context inRect:CGRectOffset( bounds, 0, 0 ) text:[power stringValue] usingTypeface:@"Helvetica" ofSize:51.0];
    
}

- (void) drawInContext:(CGContextRef)context arcAtCenter:(CGPoint)center withRadius:(float)radius {
    
    float               angle   = (PI/2) + (self.level * 2 * PI);
    float               width   = 25.0;
    
    // Construct a filled arc from the level value with the given radius and thickness
    CGContextAddArc( context, center.x, center.y, radius, (PI/2), angle, 0 );
    CGContextAddLineToPoint( context, center.x + cosf(angle) * (radius - width), center.y + sinf(angle) * (radius - width) );
    CGContextAddArc( context, center.x, center.y, radius - width, angle, (PI/2), 1 );
    CGContextClosePath( context );
    
    // Draw the arc
    CGContextDrawPath( context, kCGPathFillStroke );
    
}

- (void) drawInContext:(CGContextRef)context needleAtCenter:(CGPoint)center withRadius:(float)radius {
    
    float               angle   = (PI/2) + (self.level * 2 * PI);
    float               width   = 5.0;
    
    // Draw the power level needle
    CGContextMoveToPoint( context, center.x + cosf(angle) * radius, center.y + sinf(angle) * radius );
    CGContextAddLineToPoint( context, center.x + cosf(angle) * (radius - width), center.y + sinf(angle) * (radius - width) );
    CGContextStrokePath( context );
    
    // Draw the bubble at the end of the needle
    float               space   = 20.0;
    CGRect              rect    = CGRectMake( center.x + cosf(angle) * (radius + space) - space, center.y + sinf(angle) * (radius + space) - space, space * 2, space * 2 );
    
    CGContextAddEllipseInRect( context, rect );
    CGContextDrawPath( context, kCGPathFillStroke );
    
    // Render the level number within the bubble
    NSNumber *          level = [NSNumber numberWithInteger:self.level * 100];
    [self drawInContext:context inRect:rect text:[level stringValue] usingTypeface:@"Helvetica" ofSize:21.0];
    
}

- (void) drawInContext:(CGContextRef)context inRect:(CGRect)rect text:(NSString *)text usingTypeface:(NSString *)typeface ofSize:(CGFloat)size {
    
    // Get a font reference and construct a type string from the text
    CGAffineTransform           transform   = CGAffineTransformMakeScale( 1.0, -1.0 );
    CTFontRef                   font        = CTFontCreateWithNameAndOptions( (__bridge CFStringRef)typeface, size, &(transform), kCTFontOptionsPreferSystemFont );
    NSMutableAttributedString * type        = [[NSMutableAttributedString alloc] initWithString:text];
    
    // Assign the given font and tint attributes to the type string
    CFAttributedStringSetAttribute( (__bridge CFMutableAttributedStringRef)type, CFRangeMake(0, type.length), kCTFontAttributeName, font );
    CFAttributedStringSetAttribute( (__bridge CFMutableAttributedStringRef)type, CFRangeMake(0, type.length), kCTForegroundColorAttributeName, self.modelLayer.tintColor );

    // Construct a path area within which to render the text
    CGMutablePathRef            path        = CGPathCreateMutable( );
    CGRect                      bounds      = CGRectMake( rect.origin.x, rect.origin.y, type.size.width, rect.size.height );
    
    // Shift the bounding area to the center of the original rectangular area and add it to the path
    CGPathAddRect( path, NULL, CGRectOffset( bounds, (rect.size.width - type.size.width)/2, CTFontGetAscent( font ) + (CTFontGetSize( font ) - bounds.size.height)/2 ) );
    
    // Construct a typesetter to render the text in the given font and within the area
    CTFramesetterRef            setter  = CTFramesetterCreateWithAttributedString( (__bridge CFAttributedStringRef)type );
    CTFrameRef                  frame   = CTFramesetterCreateFrame( setter, CFRangeMake(0, type.length), path, NULL );
    
    // Render the frame constructed by the typesetter
    CTFrameDraw( frame, context );

    // Release the resources
    CFRelease( setter );
    CFRelease( frame );
    CFRelease( path );
    CFRelease( font );
    
}

@end
