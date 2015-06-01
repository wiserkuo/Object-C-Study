//
//  FSSignupModel.h
//  DivergenceStock
//
//  Created by Connor on 2014/12/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSSignupModel : NSObject {
    NSURL *_signupURL;
    NSURL *_resetpwURL;
    NSURL *_openProjectURL;
    NSURL *_fbSharedURL;
    NSString *_appId;
    NSString *_uuid;
    NSString *_lang;
}

- (instancetype)initWithSignupURL:(NSString *)signupURL
                       resetPWURL:(NSString *)resetpwURL
                   openProjectURL:(NSString *)openProjectURL
                      fbSharedURL:(NSString *)fbSharedURL
                            appId:(NSString *)appId
                             uuid:(NSString *)uuid
                             lang:(NSString *)lang;
- (NSURLRequest *)request;
- (NSURLRequest *)forgetPWRequest;
- (NSURLRequest *)openProjectWithAccount:(NSString *)account;
- (NSURLRequest *)fbSharedRequestWithAccount:(NSString *)account;
@end
