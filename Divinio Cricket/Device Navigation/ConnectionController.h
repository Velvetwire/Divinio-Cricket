//
//  ConnectionController.h
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import <UIKit/UIKit.h>

@interface ConnectionController : UINavigationController

- (void) connectedToIdentifier:(NSUUID *)identifier withName:(NSString *)name;

@end

