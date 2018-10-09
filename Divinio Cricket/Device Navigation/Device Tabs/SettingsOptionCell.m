//
//  SettingsOptionCell.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "SettingsOptionCell.h"

@interface SettingsOptionCell ( )

@property (weak, nonatomic) IBOutlet UIImageView *titleIcon;
@property (weak, nonatomic) IBOutlet UILabel * titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch * optionSwitch;

@end

@implementation SettingsOptionCell

- (void) awakeFromNib {
    
    [super awakeFromNib];
    
    [self.optionSwitch addTarget:self
                          action:@selector(stateChanged:)
                forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Title text and image

- (NSString *) titleText { return ( _titleLabel.text ); }

- (void) setTitleText:(NSString *)text { _titleLabel.text = text; }

- (UIImage * ) titleImage { return ( self.titleIcon.image ); }

- (void) setTitleImage:(UIImage *)image { [self.titleIcon setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]]; }

#pragma mark - State setting and updates

- (bool) state { return [_optionSwitch isOn]; }

- (void) setState:(bool)state { [_optionSwitch setOn:state animated:YES]; }

- (void) stateChanged:(id)sender {

    if ( self.delegate && [self.delegate respondsToSelector:@selector(settingsOptionCell:didChangeState:)] )
        [self.delegate settingsOptionCell:self didChangeState:self.optionSwitch.on];

}

@end
