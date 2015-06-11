//
//  UIViewController+Notification.h
//  WirtsLeg
//
//  Created by Connor on 14/2/13.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Notification)

- (void)registerLoginNotificationCallBack:(id)target seletor:(SEL)seletor;
- (void)unregisterLoginNotificationCallBack:(id)target;

- (void)registerSecurityRegisterNotificationCallBack:(id)target seletor:(SEL)seletor;
- (void)unRegisterSecurityRegisterNotificationCallBack:(id)target;

- (void)registerTickDataNotificationCallBack:(id)target seletor:(SEL)seletor;
- (void)unRegisterTickDataNotificationCallBack:(id)target;
@end
