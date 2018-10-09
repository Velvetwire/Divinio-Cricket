//
//  ConnectionViewController.h
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import <UIKit/UIKit.h>

@interface ConnectionViewController : UITabBarController

- (void) connectedToIdentifier:(NSUUID *)identifier withName:(NSString *)name;

@end
