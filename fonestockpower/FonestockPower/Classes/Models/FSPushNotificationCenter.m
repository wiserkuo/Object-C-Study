//
//  FSPushNotificationCenter.m
//  FonestockPower
//
//  Created by Connor on 14/6/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSPushNotificationCenter.h"
#import "DDXML.h"

@interface FSPushNotificationCenter() {
    NSURL *tokenUpdateURL;
}
@end

@implementation FSPushNotificationCenter

- (instancetype)initWithUpdateTokenWithURLString:(NSString *)urlString {
    if (self = [super init]) {
        tokenUpdateURL = [NSURL URLWithString:urlString];
    }
    return self;
}

- (void)updatePushTokenWithDeviceType:(NSString *)device_type
                             deviceId:(NSString *)deviceId
                                token:(NSString *)token
                              account:(NSString *)account
                               app_id:(NSString *)app_id {
    
    NSDateFormatter *formatterUTC = [[NSDateFormatter alloc] init];
    [formatterUTC setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatterUTC setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString *localDateString = [formatterUTC stringFromDate:[NSDate date]];
    
    NSMutableString *rawData = [[NSMutableString alloc] init];
    [rawData appendString:deviceId];
    [rawData appendString:token];
    [rawData appendString:account];
    [rawData appendString:app_id];
    [rawData appendString:localDateString];
    [rawData appendString:@"8612abef"];
    
    NSString *hashData = [CodingUtil hashed_string:rawData];
    
    DDXMLElement *tag_token_data_up = [[DDXMLElement alloc] initWithName:@"token_data_up"];
    
    DDXMLElement *tag_device_type = [[DDXMLElement alloc] initWithName:@"device_type"];
    [tag_device_type setStringValue:device_type];
    
    DDXMLElement *tag_device_id = [[DDXMLElement alloc] initWithName:@"device_id"];
    [tag_device_id setStringValue:deviceId];
    
    DDXMLElement *tag_token = [[DDXMLElement alloc] initWithName:@"token"];
    [tag_token setStringValue:token];
    
    DDXMLElement *tag_account = [[DDXMLElement alloc] initWithName:@"account"];
    [tag_account setStringValue:account];
    
    DDXMLElement *tag_app_id = [[DDXMLElement alloc] initWithName:@"app_id"];
    [tag_app_id setStringValue:app_id];
    
    DDXMLElement *tag_now = [[DDXMLElement alloc] initWithName:@"now"];
    
    [tag_now setStringValue:localDateString];
    
    DDXMLElement *tag_ckCode = [[DDXMLElement alloc] initWithName:@"ck_code"];
    [tag_ckCode setStringValue:hashData];
    
    [tag_token_data_up addChild:tag_device_type];
    [tag_token_data_up addChild:tag_device_id];
    [tag_token_data_up addChild:tag_token];
    [tag_token_data_up addChild:tag_account];
    [tag_token_data_up addChild:tag_app_id];
    [tag_token_data_up addChild:tag_now];
    [tag_token_data_up addChild:tag_ckCode];
    
    
    FSURLConnectCenter *authTokenConnect = [[FSURLConnectCenter alloc]
                                            initURLRequestWithURL:tokenUpdateURL
                                            requestString:[tag_token_data_up XMLString]];
    authTokenConnect.delegate = self;
    [authTokenConnect commit];
}

- (void)urlConnectCenter:(FSURLConnectCenter *)urlConnectCenter didFinishWithData:(NSData *)callBackData {
    
}
- (void)urlConnectCenter:(FSURLConnectCenter *)urlConnectCenter didFailWithError:(NSError *)callBackError {
    
}


@end
