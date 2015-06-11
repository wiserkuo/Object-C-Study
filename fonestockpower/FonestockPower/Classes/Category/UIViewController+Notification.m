//
//  UIViewController+Notification.m
//  WirtsLeg
//
//  Created by Connor on 14/2/13.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import "UIViewController+Notification.h"
#import "FSNotificationCenter.h"

@implementation UIViewController (Notification)

// 註冊登入結束後會重新執行的function
- (void)registerLoginNotificationCallBack:(id)target seletor:(SEL)seletor {
    [[NSNotificationCenter defaultCenter] addObserver:target
                                             selector:seletor
                                                 name:kFSLoginSuccessNotification
                                               object:nil];
}

- (void)unregisterLoginNotificationCallBack:(id)target {
    [[NSNotificationCenter defaultCenter] removeObserver:target];
}

#pragma mark -
#pragma mark - 股票註冊完畢通知 (portfolio取得股票代碼通知)

- (void)registerSecurityRegisterNotificationCallBack:(id)target seletor:(SEL)seletor {
    [[NSNotificationCenter defaultCenter] addObserver:target
                                             selector:seletor
                                                 name:kFSSecurityRegisterCallBackNotification
                                               object:nil];
}

- (void)unRegisterSecurityRegisterNotificationCallBack:(id)target {
    [[NSNotificationCenter defaultCenter] removeObserver:target name:kFSSecurityRegisterCallBackNotification object:nil];
}

#pragma mark -
#pragma mark - TickData 回補
- (void)registerTickDataNotificationCallBack:(id)target seletor:(SEL)seletor {
    [[NSNotificationCenter defaultCenter] addObserver:target
                                             selector:seletor
                                                 name:kFSTickDataCallBackNotification
                                               object:nil];
    
}

- (void)unRegisterTickDataNotificationCallBack:(id)target {
    [[NSNotificationCenter defaultCenter] removeObserver:target name:kFSTickDataCallBackNotification object:nil];
}

@end
