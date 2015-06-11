//
//  FSPointsAuthCenter.h
//  FonestockPower
//
//  Created by Connor on 14/3/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSPointsAuthCenterDelegate;

@class Authority;

@interface FSPointsAuthCenter : NSObject

// 系統初始化用
- (id)initWithAuthURL:(NSURL *)url;

- (void)loginWithAccount:(NSString *)account
                password:(NSString *)password
             accountType:(NSString *)accountType
                deviceId:(NSString *)deviceId
                   appId:(NSString *)appId
                 factory:(NSString *)factory
                   model:(NSString *)model
                      os:(NSString *)os
                 version:(NSString *)version
                 buildNo:(NSString *)buildNo;

@property (weak, nonatomic) id <FSPointsAuthCenterDelegate> delegate;

@property (strong, nonatomic) NSString *connectStatusCode;
@property (strong, nonatomic) NSString *connectStatusMessage;

@property (strong, nonatomic) NSString *account;
@property (strong, nonatomic) NSString *accountType;
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *accessToken;

@property (strong, nonatomic) NSString *serviceServerIP;
@property (strong, nonatomic) NSString *serviceServerPort;

@property (strong, nonatomic) NSString *queryServerIP;
@property (strong, nonatomic) NSString *queryServerPort;

@property (strong, nonatomic) NSString *expiredAccessTokenDateTime;
@property (strong, nonatomic) NSString *systemDateTime;
@property (strong, nonatomic) NSString *serviceDueDateTime;

@property (strong, nonatomic) Authority *authority;

@end

@protocol FSPointsAuthCenterDelegate <NSObject>
@required
- (void)fsAuthDidFinishWithData:(FSPointsAuthCenter *)pointsAuthData;
- (void)fsAuthDidFailWithData:(FSPointsAuthCenter *)pointsAuthData;
- (void)fsAuthDidFailWithError:(NSError *)error;
@end

@interface PackageType : NSObject
@property (strong, nonatomic) NSString *package_id;
@property (strong, nonatomic) NSString *package_name;
@property (strong, nonatomic) NSString *expired;
@property (strong, nonatomic) Authority *authority;
@end