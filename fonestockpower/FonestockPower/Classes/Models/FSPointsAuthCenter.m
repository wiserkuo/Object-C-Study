//
//  FSPointsAuthCenter.m
//  FonestockPower
//
//  Created by Connor on 14/3/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSPointsAuthCenter.h"
#import "FSURLConnectCenter.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"

@implementation PackageType
@end

@interface FSPointsAuthCenter() <FSURLConnectCenterDelegate> {
    NSURL *authURL;
}
@end

@implementation FSPointsAuthCenter

//- (NSString*)sha1:(NSString*)input {
//    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
//    NSData *data = [NSData dataWithBytes:cstr length:input.length];
//    
//    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
//    
//    CC_SHA256(data.bytes, data.length, digest);
//    
//    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
//    
//    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
//        [output appendFormat:@"%02x", digest[i]];
//    
//    return output;
//    
//}

- (id)initWithAuthURL:(NSURL *)url {
    if (self = [super init]) {
        authURL = url;
    }
    return self;
}

- (void)loginWithAccount:(NSString *)account
                password:(NSString *)password
             accountType:(NSString *)accountType
                deviceId:(NSString *)deviceId
                   appId:(NSString *)appId
                 factory:(NSString *)factory
                   model:(NSString *)model
                      os:(NSString *)os
                 version:(NSString *)version
                 buildNo:(NSString *)buildNo {
    
    
    _account = account;
    _accountType = accountType;
    _appId = appId;
    
    DDXMLElement *tag_auth_token_up = [[DDXMLElement alloc] initWithName:@"auth_token_v2_up"];
    
    DDXMLElement *tag_account = [[DDXMLElement alloc] initWithName:@"account"];
    [tag_account setStringValue:account];
    
    DDXMLElement *tag_account_type = [[DDXMLElement alloc] initWithName:@"account_type"];
    [tag_account_type setStringValue:accountType];
    
    DDXMLElement *tag_password = [[DDXMLElement alloc] initWithName:@"password"];
    [tag_password setStringValue:password];
    
    DDXMLElement *tag_dev_id = [[DDXMLElement alloc] initWithName:@"dev_id"];
    [tag_dev_id setStringValue:deviceId];
    
    DDXMLElement *tag_app_id = [[DDXMLElement alloc] initWithName:@"app_id"];
    [tag_app_id setStringValue:appId];
    
    // 系統命名
    // Fonestock-iPhone-usdivergence_US_V1.0_64
    // Fonestock-iPhone-uspattern_US_V1.0_64
    DDXMLElement *tag_client_version = [[DDXMLElement alloc] initWithName:@"client_version"];
    [tag_client_version setStringValue:[NSString stringWithFormat:@"Fonestock-iPhone-%@_%@_V%@_%@",appId, [[appId substringToIndex:2] uppercaseString], version ,buildNo]];
    
    DDXMLElement *tag_factory = [[DDXMLElement alloc] initWithName:@"factory"];
    [tag_factory setStringValue:factory];
    
    DDXMLElement *tag_model = [[DDXMLElement alloc] initWithName:@"model"];
    [tag_model setStringValue:model];
    
    DDXMLElement *tag_os = [[DDXMLElement alloc] initWithName:@"os"];
    [tag_os setStringValue:os];
    
    DDXMLElement *tagVersion = [[DDXMLElement alloc] initWithName:@"version"];
    [tagVersion setStringValue:version];
    
    [tag_auth_token_up addChild:tag_account];
    [tag_auth_token_up addChild:tag_account_type];
    [tag_auth_token_up addChild:tag_password];
    [tag_auth_token_up addChild:tag_dev_id];
    [tag_auth_token_up addChild:tag_app_id];
    [tag_auth_token_up addChild:tag_client_version];
    [tag_auth_token_up addChild:tag_factory];
    [tag_auth_token_up addChild:tag_model];
    [tag_auth_token_up addChild:tag_os];
    [tag_auth_token_up addChild:tagVersion];
    
    FSURLConnectCenter *authTokenConnect = [[FSURLConnectCenter alloc]
                                            initURLRequestWithURL:authURL
                                            requestString:[tag_auth_token_up XMLString]];
    authTokenConnect.delegate = self;
    [authTokenConnect commit];
    
//        DDXMLElement *tag_auth_token_up = [[DDXMLElement alloc] initWithName:@"auth_token_up"];
//        
//        DDXMLElement *tag_account = [[DDXMLElement alloc] initWithName:@"account"];
//        [tag_account setStringValue:account];
//        
//        DDXMLElement *tag_account_type = [[DDXMLElement alloc] initWithName:@"account_type"];
//        [tag_account_type setStringValue:accountType];
//        
//        DDXMLElement *tag_dev_id = [[DDXMLElement alloc] initWithName:@"dev_id"];
//        [tag_dev_id setStringValue:deviceId];
//        
//        DDXMLElement *tag_app_id = [[DDXMLElement alloc] initWithName:@"app_id"];
//        [tag_app_id setStringValue:appId];
//        
//        DDXMLElement *tag_factory = [[DDXMLElement alloc] initWithName:@"factory"];
//        [tag_factory setStringValue:factory];
//        
//        DDXMLElement *tag_model = [[DDXMLElement alloc] initWithName:@"model"];
//        [tag_model setStringValue:model];
//        
//        DDXMLElement *tag_os = [[DDXMLElement alloc] initWithName:@"os"];
//        [tag_os setStringValue:os];
//        
//        DDXMLElement *tagVersion = [[DDXMLElement alloc] initWithName:@"version"];
//        [tagVersion setStringValue:version];
//        
//        DDXMLElement *tagBuildNo = [[DDXMLElement alloc] initWithName:@"buildno"];
//        [tagBuildNo setStringValue:buildNo];
//        
//        [tag_auth_token_up addChild:tag_account];
//        [tag_auth_token_up addChild:tag_account_type];
//        [tag_auth_token_up addChild:tag_dev_id];
//        [tag_auth_token_up addChild:tag_app_id];
//        [tag_auth_token_up addChild:tag_factory];
//        [tag_auth_token_up addChild:tag_model];
//        [tag_auth_token_up addChild:tag_os];
//        [tag_auth_token_up addChild:tagVersion];
//        [tag_auth_token_up addChild:tagBuildNo];
//        
//        FSURLConnectCenter *authTokenConnect = [[FSURLConnectCenter alloc]
//                                                initURLRequestWithURL:authURL
//                                                requestString:[tag_auth_token_up XMLString]];
//        authTokenConnect.delegate = self;
//        [authTokenConnect commit];
//#endif
    
}


// 下行電文
- (void)urlConnectCenter:(FSURLConnectCenter *)urlConnectCenter didFinishWithData:(NSData *)callBackData {
    
// 美股圖是力II 新電文格式
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:callBackData options:0 error:nil];
    
    // 取得 connect status
    NSArray *status = [xmlDoc nodesForXPath:@"/auth_token_v2_down/status" error:nil];
    for (DDXMLElement *element in status) {
        _connectStatusCode = [[element elementForName:@"code"] stringValue];
        _connectStatusMessage = [[element elementForName:@"message"] stringValue];
    }
    
    // server define status 200 連線成功
    if ([_connectStatusCode isEqualToString:@"200"]) {
//        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
//        NSLog(@"dataModel.loginService.loginCounter %d",dataModel.loginService.loginCounter);
//        if(dataModel.loginService.loginCounter < 2){
//            [self _whatThe401Do:xmlDoc];
//        }else{
        // 取得 server connect address
        NSArray *serverAddress = [xmlDoc nodesForXPath:@"/auth_token_v2_down/address" error:nil];
        for (DDXMLElement *element in serverAddress) {
            
            NSString *serverType = [[element attributeForName:@"type"] stringValue];
            if ([@"service" isEqualToString:serverType]) {
                _serviceServerIP = [[element elementForName:@"IP"] stringValue];
                _serviceServerPort = [[element elementForName:@"port"] stringValue];
            } else if ([@"query" isEqualToString:serverType]) {
                _queryServerIP = [[element elementForName:@"IP"] stringValue];
                _queryServerPort = [[element elementForName:@"port"] stringValue];
            }
        }
        
        // 取得權限
        _authority = [FSFonestock sharedInstance].authorityData;
        
        // 取得 token
        NSArray *authToken = [xmlDoc nodesForXPath:@"/auth_token_v2_down" error:nil];
        for (DDXMLElement *element in authToken) {
            _accessToken = [[element elementForName:@"token"] stringValue];
            _expiredAccessTokenDateTime = [[element elementForName:@"token_expired_time"] stringValue];
            _authority.portfolio_quota = [(NSNumber *)[[element elementForName:@"quota"] stringValue] intValue];
            _serviceDueDateTime = [[element elementForName:@"service_due_date"] stringValue];
            // [[[element elementForName:@"check"] stringValue] intValue]; // check欄位目前沒用到
        }
        
        NSArray *authorityType = [xmlDoc nodesForXPath:@"/auth_token_v2_down/authority" error:nil];
        for (DDXMLElement *element in authorityType) {
            _authority.insession = [[element elementForName:@"insession"] boolValue];
            _authority.eod_new_target = [[element elementForName:@"eod_new_target"] boolValue];
            _authority.eod_check_all = [[element elementForName:@"eod_check_all"] boolValue];
            _authority.strategy_alert = [[element elementForName:@"strategy_alert"] boolValue];
            _authority.port_relate_kline = [[element elementForName:@"port_relate_kline"] boolValue];
            _authority.journal_relate_kline = [[element elementForName:@"journal_relate_kline"] boolValue];
            _authority.press_support = [[element elementForName:@"press_support"] boolValue];
            _authority.adv_on = [(NSNumber *)[element elementForName:@"adv_on"] intValue];
            
            _authority.kchart = [[element elementForName:@"kchart"] boolValue];
        }
        
        // 回傳server驗證成功訊息
        if ([self.delegate respondsToSelector:@selector(fsAuthDidFinishWithData:)]) {
            [self.delegate fsAuthDidFinishWithData:self];
        }
//        }
    } else if ([_connectStatusCode isEqualToString:@"402"]) {
        
        // 回傳server驗證成功訊息   要繳費了
        if ([self.delegate respondsToSelector:@selector(fsAuthDidFailWithData:)]) {
            [self.delegate fsAuthDidFailWithData:self];
        }
        
    } else if ([_connectStatusCode isEqualToString:@"401"]) {
        
        [self _whatThe401Do:xmlDoc];
    } else if ([_connectStatusCode isEqualToString:@"400"]) {
        if ([self.delegate respondsToSelector:@selector(fsAuthDidFailWithData:)]) {
            [self.delegate fsAuthDidFailWithData:self];
        }
    }
    else {
        // 回傳server驗證錯誤訊息
        if ([self.delegate respondsToSelector:@selector(fsAuthDidFailWithData:)]) {
            [self.delegate fsAuthDidFailWithData:self];
        }
    }
/*
#elif PatternPowerCN
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:callBackData options:0 error:nil];
    
    // 取得 connect status
    NSArray *status = [xmlDoc nodesForXPath:@"/auth_token_down/status" error:nil];
    for (DDXMLElement *element in status) {
        _connectStatusCode = [[element elementForName:@"code"] stringValue];
        _connectStatusMessage = [[element elementForName:@"message"] stringValue];
    }
    
    // server define status 200 連線成功
    if ([_connectStatusCode isEqualToString:@"200"]) {
        
        // 取得 server connect address
        NSArray *serverAddress = [xmlDoc nodesForXPath:@"/auth_token_down/address" error:nil];
        for (DDXMLElement *element in serverAddress) {
            
            NSString *serverType = [[element attributeForName:@"type"] stringValue];
            if ([@"service" isEqualToString:serverType]) {
                _serviceServerIP = [[element elementForName:@"IP"] stringValue];
                _serviceServerPort = [[element elementForName:@"port"] stringValue];
            } else if ([@"query" isEqualToString:serverType]) {
                _queryServerIP = [[element elementForName:@"IP"] stringValue];
                _queryServerPort = [[element elementForName:@"port"] stringValue];
            }
        }
        
        // 取得 token
        NSArray *authToken = [xmlDoc nodesForXPath:@"/auth_token_down" error:nil];
        for (DDXMLElement *element in authToken) {
            _accessToken = [[element elementForName:@"token"] stringValue];
            _expiredAccessTokenDateTime = [[element elementForName:@"expired"] stringValue];
            _systemDateTime = [[element elementForName:@"system_time"] stringValue];
        }
        
        // 取得 appPackageData
        PackageType *appPackageData = [[PackageType alloc] init];
        
        NSArray *packageType = [xmlDoc nodesForXPath:@"/auth_token_down/package" error:nil];
        for (DDXMLElement *element in packageType) {
            appPackageData.package_id = [[element elementForName:@"id"] stringValue];
            appPackageData.package_name = [[element elementForName:@"name"] stringValue];
            appPackageData.expired = [[element elementForName:@"expired"] stringValue];
        }
        
        NSArray *authorityType = [xmlDoc nodesForXPath:@"/auth_token_down/package/authority" error:nil];
        for (DDXMLElement *element in authorityType) {
            
            NSString *inSessionPermission = [[element elementForName:@"insession"] stringValue];
            NSString *diyPermission = [[element elementForName:@"diy"] stringValue];
            NSInteger portfolioQuota = [[[element elementForName:@"max_portfolio"] stringValue] intValue];
            
            Authority *authority = [[Authority alloc] init];
            authority.portfolioQuota = portfolioQuota;
            
            // 圖示選股 盤中搜尋權限
            if ([@"true" isEqualToString:inSessionPermission]) {
                authority.insession = YES;
            } if ([@"true" isEqualToString:inSessionPermission]) {
                authority.insession = NO;
            }
            
            // DIY Pattern 功能權限
            if ([@"true" isEqualToString:diyPermission]) {
                authority.diy = YES;
            } else if ([@"true" isEqualToString:diyPermission]) {
                authority.diy = NO;
            }
            
            authority.portfolioQuota = portfolioQuota;
            
            appPackageData.authority = authority;
        }
        
        _appPackageData = appPackageData;
        
        // 回傳server驗證成功訊息
        if ([self.delegate respondsToSelector:@selector(fsAuthDidFinishWithData:)]) {
            [self.delegate fsAuthDidFinishWithData:self];
        }
        
    } else {
        // 回傳server驗證錯誤訊息
        if ([self.delegate respondsToSelector:@selector(fsAuthDidFailWithData:)]) {
            [self.delegate fsAuthDidFailWithData:self];
        }
    }
    
#else
#endif
*/

}

-(void)_whatThe401Do:(DDXMLDocument *)xmlDoc
{
    NSArray *status = [xmlDoc nodesForXPath:@"/auth_token_v2_down" error:nil];
    //        BOOL hasAccount = NO;
    for (DDXMLElement *element in status) {
        NSString *has_account = [[element elementForName:@"has_account"] stringValue];
        DDXMLElement *ext_instr = [element elementForName:@"ext_instr"];
        BOOL goto_accPswd = [[ext_instr elementForName:@"goto_acc_pswd"] boolValue];
//        NSString *has_account = @"1";
//        BOOL goto_accPswd = YES;
        if ([@"1" isEqualToString:has_account]) {
            // TODO: 自動開權限
            //                hasAccount = YES;
            FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
            
            //                NSData *res = [NSURLConnection sendSynchronousRequest:[dataModel.signupModel openProjectWithAccount:_account] returningResponse:nil error:nil];
            //                NSString *resultStr = [[NSString alloc]initWithData:res encoding:NSUTF8StringEncoding];
            NSArray *ary;
            
            
            if (dataModel.signupModel && _account) {
                [NSURLConnection sendAsynchronousRequest:[dataModel.signupModel openProjectWithAccount:_account] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if (!connectionError) {
                        NSError *error = nil;
                        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                        
                        if (error != nil) {
                            NSLog(@"Error parsing JSON.");
                        }
                        else {
                            [ary arrayByAddingObjectsFromArray:jsonArray];
                            [dataModel.loginService disconnectReloginAuth];
                        }
                    }
                }];
            }
            
        }else if(![@"1" isEqualToString:has_account]){
//            FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
//            dataModel.isRejectReLogin = YES;
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"帳號或密碼錯誤", @"AccountSetting", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確認",@"AccountSetting",nil) otherButtonTitles:nil, nil];
//            [alert show];
        }
        if(![@"1" isEqualToString:has_account] && goto_accPswd){
            if ([self.delegate respondsToSelector:@selector(fsAuthDidFailWithData:)]) {
                [self.delegate fsAuthDidFailWithData:self];
            }
        }
    }
}

- (void)urlConnectCenter:(FSURLConnectCenter *)urlConnectCenter didFailWithError:(NSError *)callBackError {
    // server連線錯誤訊息
    if ([self.delegate respondsToSelector:@selector(fsAuthDidFailWithError:)]) {
        [self.delegate fsAuthDidFailWithError:callBackError];
    }
}

- (BOOL)testStringToBool:(NSString *)input {
    if ([@"true" isEqualToString:input]) {
        return YES;
    } else {
        return NO;
    }
}
@end
