//
//  SettingsDetailCell.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "SettingsDetailCell.h"

@interface SettingsDetailCell ( )

@property (weak, nonatomic) IBOutlet UIImageView *titleIcon;
@property (weak, nonatomic) IBOutlet UILabel * titleLabel;
@property (weak, nonatomic) IBOutlet UILabel * detailLabel;
@property (weak, nonatomic) IBOutlet UIButton * actionButton;

@end

@implementation SettingsDetailCell

- (void) awakeFromNib {
    
    [super awakeFromNib];
    
    [self.actionButton setHidden:YES];

}

#pragma mark - Title text and image

- (NSString *) titleText { return ( _titleLabel.text ); }

- (void) setTitleText:(NSString *)text { _titleLabel.text = text; }

- (UIImage * ) titleImage { return ( self.titleIcon.image ); }

- (void) setTitleImage:(UIImage *)image { [self.titleIcon setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]]; }

#pragma mark - Detail text

- (NSString *) detailText { return ( _detailLabel.text ); }

- (void) setDetailText:(NSString *)text { _detailLabel.text = text; }

#pragma mark - Action button

- (NSString *) actionText { return ( _actionButton.titleLabel.text ); }

- (void) setActionText:(NSString *)text {

    [self.actionButton setTitle:text forState:UIControlStateNormal];
    
    if ( text ) [self.actionButton setHidden:NO];
    else [self.actionButton setHidden:YES];
    
}

- (void) addActionTarget:(nullable id)target action:(nonnull SEL)selector {

    [self.actionButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

}

@end
