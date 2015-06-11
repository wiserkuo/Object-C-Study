//
//  FSLoginPacket.h
//  FonestockPower
//
//  Created by Connor on 2015/4/8.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPacket.h"

@interface FSLoginPacket : FSPacket

@end

@interface FSAuthLoginIn : NSObject <DecodeProtocol> {
@public
    int statusCode;
    NSString *message;
    NSString *importantInformation;
    NSString *extraInfomation;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode;

@end

@interface FSAuthLoginOut : NSObject <EncodeProtocol> {
    NSString *_account;
    NSString *_expiredTimestamp;
    NSString *_deviceId;
    NSString *_appId;
    NSString *_accessToken;
    NSString *_clientInfo;
}

- (instancetype)initServiceServerLoginWithAccount:(NSString *)account
                                 expiredTimestamp:(NSString *)expiredTimestamp
                                         deviceId:(NSString *)deviceId
                                            appId:(NSString *)appId
                                      accessToken:(NSString *)accessToken
                                       clientInfo:(NSString *)clientInfo;

@end