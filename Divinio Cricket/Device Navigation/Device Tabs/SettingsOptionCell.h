//
//  SettingsOptionCell.h
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import <UIKit/UIKit.h>

@protocol SettingsOptionCellDelegate;

@interface SettingsOptionCell : UITableViewCell

@property (nonatomic, weak) id <SettingsOptionCellDelegate> delegate;
@property (nonatomic) NSInteger id;

@property UIImage * titleImage;
@property NSString * titleText;
@property bool state;

@end

@protocol SettingsOptionCellDelegate <NSObject>

@optional
- (void) settingsOptionCell:(SettingsOptionCell *)cell didChangeState:(bool)state;

@end
