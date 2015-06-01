//
//  FSAccountManager.h
//  FonestockPower
//
//  Created by Connor on 14/3/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSAccountManager : NSObject
+ (instancetype)sharedInstance;
- (void)setLoginFreeAccount:(NSString *)account password:(NSString *)password;
- (void)setLoginAccount:(NSString *)account password:(NSString *)password;
- (BOOL)reloadAccountAndPassword;
- (BOOL)isReadyLogin;
- (void)removeAllUserInformationData;
@property (readonly) NSString *account;
@property (readonly) NSString *password;
@property (readonly) NSString *authType;


@end
