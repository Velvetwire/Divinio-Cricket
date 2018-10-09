//
//  SettingsEditCell.h
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import <UIKit/UIKit.h>

@protocol SettingsEditCellDelegate;

@interface SettingsEditCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) id <SettingsEditCellDelegate> delegate;
@property (nonatomic) NSInteger id;

@property UIImage * titleImage;
@property NSString * titleText;
@property NSString * placeholderText;
@property NSString * textField;
@property NSUInteger textLimit;
@property BOOL emptyAllowed;

@end

@protocol SettingsEditCellDelegate <NSObject>

@optional
- (void) settingsEditCell:(SettingsEditCell *)cell didUpdateText:(NSString *)text;

@end
