//
//  ScanViewCell.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "UISignalGadget.h"
#import "UIBatteryGadget.h"

#import "ScanViewCell.h"

@interface ScanViewCell ( )

@property (weak, nonatomic) IBOutlet UISignalGadget * signalLevel;
@property (weak, nonatomic) IBOutlet UILabel * deviceName;

@end

@implementation ScanViewCell

- (void) awakeFromNib {
    
    [super awakeFromNib];

}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

}

- (void) setName:(NSString *)name withSignal:(NSInteger)signal {

    [self.signalLevel setSignal:signal];
    [self.deviceName setText:name];

}

@end
