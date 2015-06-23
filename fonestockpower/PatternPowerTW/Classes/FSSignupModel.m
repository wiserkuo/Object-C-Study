//
//  FSSignupModel.m
//  DivergenceStock
//
//  Created by Connor on 2014/12/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSSignupModel.h"
#import "FSRSAEncrypt.h"
#import "PageControlViewController.h"

@implementation FSSignupModel

- (instancetype)initWithSignupURL:(NSString *)signupURL
                       resetPWURL:(NSString *)resetpwURL
                   openProjectURL:(NSString *)openProjectURL
                      fbSharedURL:(NSString *)fbSharedURL
             checkSubscriptionURL:(NSString *)checkSubscriptionURL
                            appId:(NSString *)appId
                             uuid:(NSString *)uuid
                             lang:(NSString *)lang {
    if (self = [super init]) {
        _signupURL = [NSURL URLWithString:signupURL];
        _resetpwURL = [NSURL URLWithString:resetpwURL];
        _openProjectURL = [NSURL URLWithString:openProjectURL];
        _fbSharedURL = [NSURL URLWithString:fbSharedURL];
        _checkSubscriptionURL = [NSURL URLWithString:checkSubscriptionURL];
        _appId = appId;
        _uuid = uuid;
        _lang = lang;
    }
    return self;
}

- (NSURLRequest *)request {
    NSDictionary *accountData = [[NSMutableDictionary alloc] initWithCapacity:3];
    [accountData setValue:_appId forKey:@"app_id"];
    [accountData setValue:_uuid forKey:@"mac_id"];
    [accountData setValue:_lang forKey:@"lang"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:accountData options:0 error:&error];
    NSString *accountJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FSRSAEncrypt *rsa = [[FSRSAEncrypt alloc] init];
    NSString *encryptData = [rsa encryptToString:accountJsonString];
    NSData *postData = [encryptData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_signupURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:FS_REQUEST_TIMEOUT];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    return request;
}

- (NSURLRequest *)forgetPWRequest {
    NSDictionary *accountData = [[NSMutableDictionary alloc] initWithCapacity:3];
    [accountData setValue:_appId forKey:@"app_id"];
    [accountData setValue:_uuid forKey:@"mac_id"];
    [accountData setValue:_lang forKey:@"lang"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:accountData options:0 error:&error];
    NSString *accountJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FSRSAEncrypt *rsa = [[FSRSAEncrypt alloc] init];
    NSString *encryptData = [rsa encryptToString:accountJsonString];
    NSData *postData = [encryptData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_resetpwURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:FS_REQUEST_TIMEOUT];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    return request;
}

- (NSURLRequest *)openProjectWithAccount:(NSString *)account {
    NSDictionary *accountData = [[NSMutableDictionary alloc] initWithCapacity:3];
    [accountData setValue:_appId forKey:@"app_id"];
    [accountData setValue:_uuid forKey:@"mac_id"];
    [accountData setValue:account forKey:@"id"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:accountData options:0 error:&error];
    NSString *accountJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FSRSAEncrypt *rsa = [[FSRSAEncrypt alloc] init];
    NSString *encryptData = [rsa encryptToString:accountJsonString];
    NSData *postData = [encryptData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_openProjectURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:FS_REQUEST_TIMEOUT];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    return request;
}

- (NSURLRequest *)fbSharedRequestWithAccount:(NSString *)account{
    NSDictionary *accountData = [[NSMutableDictionary alloc] initWithCapacity:3];
    [accountData setValue:account forKey:@"id"];
    [accountData setValue:@"Social_Network_Share" forKey:@"coupon"];
    [accountData setValue:_appId forKey:@"app_id"];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:accountData options:0 error:&error];
    NSString *accountJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FSRSAEncrypt *rsa = [[FSRSAEncrypt alloc] init];
    NSString *encryptData = [rsa encryptToString:accountJsonString];
    NSData *postData = [encryptData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_fbSharedURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:FS_REQUEST_TIMEOUT];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    return request;
}


- (NSURLRequest *)checkSubscriptionStatus:(NSString *)account {
    NSDictionary *accountData = [[NSMutableDictionary alloc] initWithCapacity:3];
    [accountData setValue:_appId forKey:@"app_id"];
    [accountData setValue:account forKey:@"id"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:accountData options:0 error:&error];
    NSString *accountJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FSRSAEncrypt *rsa = [[FSRSAEncrypt alloc] init];
    NSString *encryptData = [rsa encryptToString:accountJsonString];
    NSData *postData = [encryptData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_checkSubscriptionURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:FS_REQUEST_TIMEOUT];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    return request;
}

@end
