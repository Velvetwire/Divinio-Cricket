//
//  SessionTabController.h
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import <CoreLocation/CoreLocation.h>
#import "ConnectionPageController.h"

typedef NS_ENUM( NSInteger, SessionSection ) {
    kSessionSectionShots,
    kSessionSectionTaps,
    kSessionsSections
};

@interface SessionTabController : ConnectionPageController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

@end
