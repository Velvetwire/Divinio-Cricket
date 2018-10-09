//
//  SettingsValueCell.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "SettingsValueCell.h"

@interface SettingsValueCell ( )

@property (weak, nonatomic) IBOutlet UIImageView * titleIcon;
@property (weak, nonatomic) IBOutlet UILabel * titleLabel;
@property (weak, nonatomic) IBOutlet UILabel * detailLabel;

@end

@implementation SettingsValueCell

- (void) awakeFromNib {

    [super awakeFromNib];

}

#pragma mark - Title text and image

- (NSString *) titleText { return ( _titleLabel.text ); }

- (void) setTitleText:(NSString *)text { _titleLabel.text = text; }

- (UIImage * ) titleImage { return ( self.titleIcon.image ); }

- (void) setTitleImage:(UIImage *)image { [self.titleIcon setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]]; }

#pragma mark - Detail text

- (NSString *) detailText { return ( _detailLabel.text ); }

- (void) setDetailText:(NSString *)text { _detailLabel.text = text; }

@end
