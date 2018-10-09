//
//  SettingsEditCell.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "SettingsEditCell.h"

@interface SettingsEditCell ( )

@property (weak, nonatomic) IBOutlet UIImageView * titleIcon;
@property (weak, nonatomic) IBOutlet UILabel * titleLabel;
@property (weak, nonatomic) IBOutlet UITextField * editField;

@end

@implementation SettingsEditCell

- (void) awakeFromNib {
    
    [super awakeFromNib];
    
    [self.editField setDelegate:self];

    [self setEmptyAllowed:YES];
    [self setTextLimit:20];

}

#pragma mark - Title text and image

- (NSString *) titleText { return ( _titleLabel.text ); }

- (void) setTitleText:(NSString *)text { _titleLabel.text = text; }

- (UIImage * ) titleImage { return ( self.titleIcon.image ); }

- (void) setTitleImage:(UIImage *)image { [self.titleIcon setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]]; }

#pragma mark - Edit field text

- (NSString *) placeholderText { return ( _editField.placeholder ); }

- (void) setPlaceholderText:(NSString *)text { _editField.placeholder = text; }

- (NSString *) textField { return ( _editField.text ); }

- (void) setTextField:(NSString *)text { _editField.text = text; }

#pragma mark - Text Field Delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    [textField setBorderStyle:UITextBorderStyleNone];

    if ( self.delegate && [self.delegate respondsToSelector:@selector(settingsEditCell:didUpdateText:)] )
        [self.delegate settingsEditCell:self didUpdateText:self.editField.text];

}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ( [string length] == 0 ) return ( YES );
    if ( [textField.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] < self.textLimit ) return ( YES );
    
    return ( NO );
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ( textField.text.length ) [textField resignFirstResponder];
    else if ( self.emptyAllowed ) [textField resignFirstResponder];
    else return ( NO );

    return ( YES );
    
}

@end
