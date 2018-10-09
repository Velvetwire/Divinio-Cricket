//
//  SessionShotCell.h
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import <UIKit/UIKit.h>
#import "DeviceInstance.h"

@interface SessionShotDetails : NSObject

@property (nonatomic, strong) NSNumber * shot;
@property (nonatomic, strong) NSNumber * stroke;
@property (nonatomic, strong) NSNumber * strike;
@property (nonatomic, strong) NSNumber * quality;
@property (nonatomic, strong) NSNumber * power;
@property (nonatomic, strong) NSNumber * speed;
@property (nonatomic, strong) NSNumber * twist;

@end

@interface SessionShotCell : UITableViewCell

- (void) setStrike:(StrikeType)strike quality:(NSNumber *)quality power:(NSNumber *)power;
- (void) setStroke:(StrokeType)stroke speed:(NSNumber *)speed twist:(NSNumber *)twist;

@end

