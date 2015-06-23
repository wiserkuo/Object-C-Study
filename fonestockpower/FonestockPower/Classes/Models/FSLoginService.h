//
//  FSLoginService.h
//  FonestockPower
//
//  Created by Connor on 14/4/1.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSLoginPacket.h"

@class FSPointsAuthCenter;
@class FSLauncherPageViewController;



@interface FSLoginService : NSObject

// 登入狀態
typedef NS_ENUM(NSUInteger, FSLoginResultType) {
    FSLoginResultTypeNoLogin = 0,                       // 0:
    FSLoginResultTypeAuthLoginNow,                      // 1:
    FSLoginResultTypeAuthLoginSuccess,                  // 2:
    FSLoginResultTypeServiceServerLoginNow,             // 3:
    FSLoginResultTypeServiceServerLoginSuccess,         // 4:
    FSLoginResultTypeBadRequest = 400,
    FSLoginResultTypeUnauthorized = 401,
    FSLoginResultTypePaymentRequired = 402,
    FSLoginResultTypeInternalServerError = 500,
    FSLoginResultTypeServiceUnavailable = 503,
    FSLoginResultTypeVersionNotSupported = 505,
    FSLoginResultTypeLoginFailed = 900,
    FSLoginResultTypeStopContinuousReLogin = 901,
    FSLoginResultTypeBeKickedOut = 911
};

@property (readonly, nonatomic) FSPointsAuthCenter *fsAuthCenter;

@property (readonly, nonatomic) NSString *account;
@property (readonly, nonatomic) NSString *accountType;
@property (readonly, nonatomic) NSString *appId;
@property (unsafe_unretained, nonatomic) NSInteger loginCounter;
@property (readonly, nonatomic) NSDate *serviceDueDateTimeUTC;

@property (nonatomic, strong) FSLauncherPageViewController *aTarget;


@property (readonly, nonatomic) FSLoginResultType loginResultType;


-(void)setTarget:(id)aTarget;

- (id)initWithAuthURLString:(NSString *)urlString;

- (void)loginAuth;
- (void)disconnectReloginAuth;
- (void)loginAuthUsingPromoteAccount;
- (void)loginAuthUsingSelfAccount;
- (void)disconnect;

- (void)fsAuthLoginWithAccount:(NSString *)account
                      password:(NSString *)password
                   accountType:(NSString *)accountType;

- (void)loginServiceServer;
- (void)serviceServerLoginCallBack:(FSAuthLoginIn *)data;
@end
