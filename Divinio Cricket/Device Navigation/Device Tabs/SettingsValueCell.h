//
//  SettingsValueCell.h
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import <UIKit/UIKit.h>

@interface SettingsValueCell : UITableViewCell

@property UIImage * titleImage;
@property NSString * titleText;
@property NSString * detailText;

- (void) setTitleImage:(UIImage *)image;

@end

