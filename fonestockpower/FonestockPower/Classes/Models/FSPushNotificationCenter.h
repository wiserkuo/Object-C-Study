//
//  FSPushNotificationCenter.h
//  FonestockPower
//
//  Created by Connor on 14/6/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSURLConnectCenter.h"

@interface FSPushNotificationCenter : NSObject <FSURLConnectCenterDelegate>

- (instancetype)initWithUpdateTokenWithURLString:(NSString *)urlString;

- (void)updatePushTokenWithDeviceType:(NSString *)device_type
                             deviceId:(NSString *)deviceId
                                token:(NSString *)token
                              account:(NSString *)account
                               app_id:(NSString *)app_id;
@end
