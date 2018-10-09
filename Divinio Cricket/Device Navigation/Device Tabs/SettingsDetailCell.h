//
//  SettingsDetailCell.h
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import <UIKit/UIKit.h>

@interface SettingsDetailCell : UITableViewCell

@property NSString * titleText;
@property NSString * detailText;
@property NSString * actionText;

- (void) addActionTarget:(nullable id)target action:(nonnull SEL)selector;

@end
