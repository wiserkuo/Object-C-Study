//
//  TrackCenter.m
//  WirtsLeg
//
//  Created by Neil on 13/11/7.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "TrackCenter.h"
#import "FSURLConnectCenter.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"

@interface TrackCenter() <FSURLConnectCenterDelegate>
@property (strong, nonatomic) NSURL * trackURL;
@end

@implementation TrackCenter

+ (id)sharedInstance {
    static TrackCenter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifdef PatternPowerCN
        sharedInstance = [[TrackCenter alloc] initWithTrackURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/query/cntrack",[FSFonestock sharedInstance].queryServerURL]]];
#else
        sharedInstance = [[TrackCenter alloc] initWithTrackURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/query/track",[FSFonestock sharedInstance].queryServerURL]]];
#endif
        
    });
    return sharedInstance;
}

- (id)initWithTrackURL:(NSURL *)url {
    if (self = [super init]) {
        self.trackURL = url;
        NSLog(@"%@",_trackURL);
    }
    return self;
}

-(void)upTrackWithTrackUpArray:(NSMutableArray *)trackUpArray{
    self.trackUpArray = [[NSMutableArray alloc]init];
    _trackUpArray = trackUpArray;
    DDXMLElement *performance_tracking_up = [[DDXMLElement alloc] initWithName:@"performance_tracking_up"];
    
    DDXMLElement *tag_track_stocks = [[DDXMLElement alloc] initWithName:@"track_stocks"];
    
    DDXMLElement *tag_track_stock_count = [[DDXMLElement alloc] initWithName:@"track_stock_count"];
    [tag_track_stock_count setStringValue:[NSString stringWithFormat:@"%d", (int)[trackUpArray count]]];
    
    [performance_tracking_up addChild:tag_track_stocks];
    [tag_track_stocks addChild:tag_track_stock_count];

    for (int i= 0; i< [trackUpArray count]; i++) {
        TrackUpFormat * trackUp = [trackUpArray objectAtIndex:i];
        
        DDXMLElement *tag_track_stock = [[DDXMLElement alloc] initWithName:@"track_stock"];
        
        DDXMLElement *tag_security = [[DDXMLElement alloc] initWithName:@"security"];
        
        DDXMLElement *tag_ident_code = [[DDXMLElement alloc] initWithName:@"ident_code"];
        [tag_ident_code setStringValue:trackUp->identCode];
        
        DDXMLElement *tag_symbol = [[DDXMLElement alloc] initWithName:@"symbol"];
        [tag_symbol setStringValue:trackUp->symbol];
        
        DDXMLElement *tag_date = [[DDXMLElement alloc] initWithName:@"date"];
        [tag_date setStringValue:trackUp->date];
        
        [tag_track_stocks addChild:tag_track_stock];
        [tag_track_stock addChild:tag_security];
        [tag_security addChild:tag_ident_code];
        [tag_security addChild:tag_symbol];
        [tag_track_stock addChild:tag_date];
    }
    
    FSURLConnectCenter *trackConnect = [[FSURLConnectCenter alloc] initURLRequestWithURL:self.trackURL requestString:[performance_tracking_up XMLString]];
    trackConnect.delegate = self;
    [trackConnect commit];
}

- (void)urlConnectCenter:(FSURLConnectCenter *)urlConnectCenter didFinishWithData:(NSData *)callBackData {
    self.trackDownArray = [[NSMutableArray alloc]init];
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:callBackData options:0 error:nil];
    NSLog(@"%@",xmlDoc);
    // 取得 connect status
    NSArray *status = [xmlDoc nodesForXPath:@"/performance_tracking_down/status" error:nil];
    for (DDXMLElement *element in status) {
        self.connectStatusCode = [[element elementForName:@"code"] stringValue];
    }
    
    // server define status 200 連線成功
    if ([self.connectStatusCode isEqualToString:@"200"]) {
        
        // 取得 result count
        NSArray *resultCount = [xmlDoc nodesForXPath:@"/performance_tracking_down/track_results" error:nil];
        for (DDXMLElement *element in resultCount) {
            self.resultCount= [(NSNumber *)[[element elementForName:@"result_count"]stringValue]intValue];
        }
        
        NSArray *result = [xmlDoc nodesForXPath:@"/performance_tracking_down/track_results/result" error:nil];
        int i=0;
        for (DDXMLElement *element in result) {
            
            TrackDownFormat * trackDown = [[TrackDownFormat alloc]init];
            
            DDXMLElement *security = [element elementForName:@"security"];
            
            trackDown->identCode = [[security elementForName:@"ident_code"]stringValue];
            trackDown->symbol = [[security elementForName:@"symbol"]stringValue];
            trackDown->type = [[security elementForName:@"type_id"]stringValue];
            
            NSString *date = [[element elementForName:@"track_date"]stringValue];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate * newDate = [formatter dateFromString:date];
            
            NSString * appid = [FSFonestock sharedInstance].appId;
            NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
            if ([group isEqualToString:@"us"]) {
                [formatter setDateFormat:@"MM/dd/yyyy"];
            }else{
                [formatter setDateFormat:@"yyyy/MM/dd"];
            }
            
            trackDown->date = [formatter stringFromDate:newDate];
            
            trackDown->todayPrice = [[[element elementForName:@"current"]stringValue]floatValue ];
            trackDown->high = [(NSNumber *)[[element elementForName:@"high"]stringValue] floatValue];
            trackDown->low = [(NSNumber *)[[element elementForName:@"low"]stringValue] floatValue];
            
            TrackUpFormat * trackUp = [_trackUpArray objectAtIndex:i];
            trackDown->session = trackUp->session;
            trackDown->trackPrice = trackUp->markPrice;
            trackDown->fullName = trackUp->fullName;
            
            [_trackDownArray addObject:trackDown];
            i+=1;
        }
        
        
        // 回傳server驗證成功訊息
        if ([self.delegate respondsToSelector:@selector(trackCenterDidFinishWithData:)]) {
            [self.delegate trackCenterDidFinishWithData:self];
        }
        
    } else {
        // 回傳server驗證錯誤訊息
        if ([self.delegate respondsToSelector:@selector(trackCenterDidFailWithData:)]) {
            [self.delegate trackCenterDidFailWithData:self];
        }
    }
}

- (void)urlConnectCenter:(FSURLConnectCenter *)urlConnectCenter didFailWithError:(NSError *)callBackError {
    // server連線錯誤訊息
    if ([self.delegate respondsToSelector:@selector(trackCenterDidFailWithError:)]) {
        [self.delegate trackCenterDidFailWithError:callBackError];
    }
}

@end
