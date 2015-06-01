//
//  FSAccountManager.m
//  FonestockPower
//
//  Created by Connor on 14/3/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSAccountManager.h"
#import "KeychainItemWrapper.h"

@interface FSAccountManager() {
    NSString *_account;
    NSString *_password;
    NSString *_authType;
}

@end

@implementation FSAccountManager

+ (instancetype)sharedInstance {
    static FSAccountManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FSAccountManager alloc] init];
    });
    return sharedInstance;
}

- (void)setLoginAccount:(NSString *)account password:(NSString *)password {
    _account = account;
    _password = password;
    _authType = @"fonestock";
    
//    [self saveToKeyChain];
    [self saveToUserDefault];
}

- (void)setLoginFreeAccount:(NSString *)account password:(NSString *)password {
    _account = account;
    _password = password;
    _authType = @"fonestock";
    [self saveToUserDefault];
}

- (BOOL)isReadyLogin {
    if (_account == nil || _password == nil || _authType == nil) {
        return NO;
    }
    return YES;
}

-(void)saveToUserDefault
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    _password = [[CodingUtil hashed_string:_password] uppercaseString];
    [userDefault setObject:_account forKey:@"User_Information_Account"];
    [userDefault setObject:_password forKey:@"User_Information_Password"];
    [userDefault setObject:_authType forKey:@"User_Information_AuthType"];
}

- (void)saveToKeyChain {
    KeychainItemWrapper *keyChainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"USER_INFORMATION" accessGroup:nil];
    [keyChainItem setObject:_account forKey:(__bridge id)kSecAttrAccount];
    [keyChainItem setObject:_password forKey:(__bridge id)kSecValueData];
    [keyChainItem setObject:_authType forKey:(__bridge id)kSecAttrService];
}

- (BOOL)reloadAccountAndPassword {
//    KeychainItemWrapper *keyChainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"USER_INFORMATION" accessGroup:nil];
//    _account = [keyChainItem objectForKey:(__bridge id)kSecAttrAccount];
//    _password = [keyChainItem objectForKey:(__bridge id)kSecValueData];
//    _authType = [keyChainItem objectForKey:(__bridge id)kSecAttrService];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    _account = [userDefault objectForKey:@"User_Information_Account"];
    _password = [userDefault objectForKey:@"User_Information_Password"];
    _authType = [userDefault objectForKey:@"User_Information_AuthType"];
    if ([@"" isEqualToString:_account] || [@"" isEqualToString:_password] || [@"" isEqualToString:_authType]) {
        return NO;
    }
    return YES;
}

- (void)removeAllUserInformationData {
//    KeychainItemWrapper *keyChainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"USER_INFORMATION" accessGroup:nil];
//    [keyChainItem resetKeychainItem];
    [NSUserDefaults resetStandardUserDefaults];
}

@end
