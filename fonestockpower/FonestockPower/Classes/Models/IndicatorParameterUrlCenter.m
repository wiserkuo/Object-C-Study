//
//  IndicatorParameterUrlCenter.m
//  WirtsLeg
//
//  Created by Neil on 13/11/21.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "IndicatorParameterUrlCenter.h"
#import "FSURLConnectCenter.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"

@interface IndicatorParameterUrlCenter() <FSURLConnectCenterDelegate>
@property (strong, nonatomic) NSURL * IndicatorParameterURL;
@end

@implementation IndicatorParameterUrlCenter

+ (id)sharedInstance  {
    static IndicatorParameterUrlCenter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[IndicatorParameterUrlCenter alloc] initWithIndicatorParameterURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/query/taterm.cgi?time_stamp=",[FSFonestock sharedInstance].queryServerURL]]];
        
    });
    return sharedInstance;
}

- (id)initWithIndicatorParameterURL:(NSURL *)url {
    if (self = [super init]) {
        self.IndicatorParameterURL = url;
        NSLog(@"URL:%@",_IndicatorParameterURL);
    }
    
    return self;
}


-(void)IndicatorParameterUrlUpWithTime:(NSString *)time{
    
    FSURLConnectCenter *trackConnect = [[FSURLConnectCenter alloc] initURLRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.IndicatorParameterURL,time]] requestString:@""];
    trackConnect.delegate = self;
    [trackConnect commit];
}

- (void)urlConnectCenter:(FSURLConnectCenter *)urlConnectCenter didFinishWithData:(NSData *)callBackData {
    FSDataModelProc * dataModal = [FSDataModelProc sharedInstance];
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:callBackData options:0 error:nil];
    // 取得 connect status
    NSArray *status = [xmlDoc nodesForXPath:@"/ta_terminology/status" error:nil];
    for (DDXMLElement *element in status) {
        self.connectStatusCode = [[element elementForName:@"code"] stringValue];
    }
    
    NSMutableDictionary * urlData = [[NSMutableDictionary alloc]init];
    
    // server define status 200 連線成功
    if ([self.connectStatusCode isEqualToString:@"200"]) {
        
        NSArray *time = [xmlDoc nodesForXPath:@"/ta_terminology" error:nil];
        for (DDXMLElement *element in time) {
            NSString * connectTime = [[element elementForName:@"time_stamp"] stringValue];
            [urlData setObject:connectTime forKey:@"Time"];

        }
        
        NSArray *languages = [xmlDoc nodesForXPath:@"/ta_terminology/language_list" error:nil];
        for (DDXMLElement *element in languages) {
            
            
            NSArray *lan = [element nodesForXPath:@"language" error:nil];
            for (DDXMLElement *element in lan) {
                NSString * languageTag = [[element attributeForName:@"tag"] stringValue];
                NSMutableDictionary * language = [[NSMutableDictionary alloc]init];
                if ([languageTag isEqualToString:@"en"]) {
                    languageTag = @"en";
                }else if ([languageTag isEqualToString:@"zh-TW"]){
                    languageTag = @"zh-Hant";
                }else if ([languageTag isEqualToString:@"zh-CN"]){
                    languageTag = @"zh-Hans";
                }
                
                NSArray *term = [element nodesForXPath:@"term_list/term" error:nil];
                NSMutableArray * keyArray = [[NSMutableArray alloc]init];

                for (DDXMLElement *element in term) {
                    NSString * key = [[element attributeForName:@"id"] stringValue];
                    [keyArray addObject:key];
                    NSMutableDictionary * term = [[NSMutableDictionary alloc]init];
                    NSString * abbreviation = [[element elementForName:@"abbreviation"] stringValue];
                    [term setObject:abbreviation forKey:@"name"];
                    
                    NSString * fullName = [[element elementForName:@"full_name"] stringValue];
                    [term setObject:fullName forKey:@"fullName"];
                    
                    NSString * url = [[element elementForName:@"url"] stringValue];
                    [term setObject:url forKey:@"url"];
                    
                    [language setObject:term forKey:key];
                }
                
                [urlData setObject:language forKey:languageTag];
                [urlData setObject:keyArray forKey:@"key"];
                [dataModal.indicator addKeyArrayWithArray:keyArray];
            }
       
        }

        [dataModal.indicator writeIndicatorParameterUrlTableWithDictionary:urlData];
        
        if ([self.delegate respondsToSelector:@selector(urlCenterDidFinishWithData:)]) {
            [self.delegate urlCenterDidFinishWithData:self];
        }
    }else if ([self.connectStatusCode isEqualToString:@"304"]){
        //不需更新
        [dataModal.indicator setKeyArray];
        if ([self.delegate respondsToSelector:@selector(urlCenterDidFinishWithData:)]) {
            [self.delegate urlCenterDidFinishWithData:self];
        }
    }else {
        // 回傳server驗證錯誤訊息
        if ([self.delegate respondsToSelector:@selector(urlCenterDidFailWithData:)]) {
            [self.delegate urlCenterDidFailWithData:self];
        }
    }
}

- (void)urlConnectCenter:(FSURLConnectCenter *)urlConnectCenter didFailWithError:(NSError *)callBackError {
    // server連線錯誤訊息
    if ([self.delegate respondsToSelector:@selector(urlCenterDidFailWithError:)]) {
        [self.delegate urlCenterDidFailWithError:callBackError];
    }
}
@end
