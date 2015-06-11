//
//  FSNotificationCenter.h
//  WirtsLeg
//
//  Created by Connor on 14/2/12.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSNotificationCenter : NSObject
+ (FSNotificationCenter *)sharedInstance;
@end

extern NSString *const kFSLoginSuccessNotification;
extern NSString *const kFSLoginFailNotification;
extern NSString *const kFSLoginInitNotification;
extern NSString *const kFSSecurityRegisterCallBackNotification;
extern NSString *const kFSTickDataCallBackNotification;