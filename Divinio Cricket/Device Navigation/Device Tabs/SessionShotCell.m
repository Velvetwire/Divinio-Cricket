//
//  SessionShotCell.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "SessionShotCell.h"
#import "UIDialGadget.h"

@interface SessionShotCell ( )

@property (weak, nonatomic) IBOutlet UIDialGadget * qualityDial;
@property (weak, nonatomic) IBOutlet UILabel * qualityValue;
@property (weak, nonatomic) IBOutlet UILabel * speedValue;
@property (weak, nonatomic) IBOutlet UILabel * twistValue;
@property (weak, nonatomic) IBOutlet UILabel * shotLabel;

@end

@implementation SessionShotCell

- (void) awakeFromNib {
    
    [super awakeFromNib];

    // Set the text color of the value labels
    [self.qualityValue setTextColor:self.tintColor];
    [self.speedValue setTextColor:self.tintColor];
    [self.twistValue setTextColor:self.tintColor];
    
    // Set the text color of the shot type label
    [self.shotLabel setTextColor:self.tintColor];

}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

}

- (void) setStrike:(StrikeType)strike quality:(NSNumber *)quality power:(NSNumber *)power {
    
    [self.qualityDial setLevel:[quality floatValue]/100.0];
    [self.qualityDial setValue:[power floatValue]];
    
    [self.qualityValue setText:[NSString stringWithFormat:@"%i",[quality intValue]]];
    
    switch ( strike ) {
        case kStrikeTypeHit:    [self.shotLabel setText:@"Shot"]; break;
        case kStrikeTypeEdge:   [self.shotLabel setText:@"Edge"]; break;
        case kStrikeTypeBlock:  [self.shotLabel setText:@"Block"]; break;
        default:                break;
    }
    
}

- (void) setStroke:(StrokeType)stroke speed:(NSNumber *)speed twist:(NSNumber *)twist {

    [self.speedValue setText:[NSString stringWithFormat:@"%1.1f m/s",[speed floatValue]]];
    [self.twistValue setText:[NSString stringWithFormat:@"%1.1f \u00B0/s",[twist floatValue]]];

}

@end

@implementation SessionShotDetails

@end
