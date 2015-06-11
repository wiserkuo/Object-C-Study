//
//  FSLoginPacket.m
//  FonestockPower
//
//  Created by Connor on 2015/4/8.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSLoginPacket.h"
#import "CodingUtil.h"

@implementation FSLoginPacket

@end

@implementation FSAuthLoginIn
- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
    
    statusCode = [CodingUtil getUInt16:&body needOffset:YES];
    message = [CodingUtil getLongStringFormatByBuffer:&body needOffset:YES];
    importantInformation = [CodingUtil getLongStringFormatByBuffer:&body needOffset:YES];
    extraInfomation = [CodingUtil getLongStringFormatByBuffer:&body needOffset:YES];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSLoginService *loginService = [dataModel loginService];
    
    if ([loginService respondsToSelector:@selector(serviceServerLoginCallBack:)]) {
        [loginService performSelector:@selector(serviceServerLoginCallBack:) onThread:dataModel.thread withObject:self waitUntilDone:NO];
    }
}
@end

@implementation FSAuthLoginOut

- (instancetype)initServiceServerLoginWithAccount:(NSString *)account
                                 expiredTimestamp:(NSString *)expiredTimestamp
                                         deviceId:(NSString *)deviceId
                                            appId:(NSString *)appId
                                      accessToken:(NSString *)accessToken
                                       clientInfo:(NSString *)clientInfo {
    if (self = [super init]) {
        _account = account;
        _expiredTimestamp = expiredTimestamp;
        _deviceId = deviceId;
        _appId = appId;
        _accessToken = accessToken;
        _clientInfo = clientInfo;
    }
    return self;
}

- (BOOL)encode:(NSObject*)account buffer:(char*)buffer length:(int)len {
    
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead->escape = 0x1B;
    phead->message = 12;
    phead->command = 2;
    [CodingUtil setUInt16:(char*)&(phead->size) Value:len];
    tmpPtr+=sizeof(OutPacketHeader);
    
    *tmpPtr++= [_account length];
    strncpy(tmpPtr, [_account cStringUsingEncoding:NSASCIIStringEncoding], [_account length]);
    tmpPtr += [_account length];
    
    *tmpPtr++= [_expiredTimestamp length];
    strncpy(tmpPtr, [_expiredTimestamp cStringUsingEncoding:NSASCIIStringEncoding], [_expiredTimestamp length]);
    tmpPtr += [_expiredTimestamp length];
    
    *tmpPtr++= [_deviceId length];
    strncpy(tmpPtr, [_deviceId cStringUsingEncoding:NSASCIIStringEncoding], [_deviceId length]);
    tmpPtr += [_deviceId length];
    
    *tmpPtr++= [_appId length];
    strncpy(tmpPtr, [_appId cStringUsingEncoding:NSASCIIStringEncoding], [_appId length]);
    tmpPtr += [_appId length];
    
    *tmpPtr++= [_accessToken length];
    strncpy(tmpPtr, [_accessToken cStringUsingEncoding:NSASCIIStringEncoding], [_accessToken length]);
    tmpPtr += [_accessToken length];
    
    *tmpPtr++= [_clientInfo length];
    strncpy(tmpPtr, [_clientInfo cStringUsingEncoding:NSASCIIStringEncoding], [_clientInfo length]);
    tmpPtr += [_clientInfo length];
    return YES;
}

- (int)getPacketSize {
    int sum = (int)[_account length] + 1 + (int)[_expiredTimestamp length] + 1 + (int)[_deviceId length] + 1 + (int)[_appId length] + 1 + (int)[_accessToken length] + 1 + (int)[_clientInfo length] + 1;
    return sum;
}
@end