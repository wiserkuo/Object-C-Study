//
//  InvesterHold.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "InvesterHold.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface InvesterHold()
@property (nonatomic, strong) NSRecursiveLock *datalock;
@property (nonatomic, strong) NSMutableDictionary *mainDict;
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@end


@implementation InvesterHold
- (instancetype)init {
    if (self = [super init]) {
        self.datalock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (void)sendAndRead {
    [self.datalock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:30]];
    
    self.portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ InvesterHold.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter1 stringFromDate:date];
    
    if ([[self.mainDict objectForKey:@"Date"] isEqualToString:dateStr]) {
        if ([self.delegate respondsToSelector:@selector(InvesterNotifyData:)]) {
            [self.delegate performSelectorOnMainThread:@selector(InvesterNotifyData:) withObject:self.mainDict waitUntilDone:NO];
        }
    } else {
        self.mainDict = [[NSMutableDictionary alloc] init];
        
        NSDate *endDate = [[NSDate alloc] init];
        NSDate *startDate = [[[NSDate alloc] init] dayOffset:-364];
        UInt16 sDate = [CodingUtil makeDateFromDate:startDate];
        UInt16 eDate = [CodingUtil makeDateFromDate:endDate];
        
        
        PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        if (portfolioItem->commodityNo) {
            InvesterHoldOut *cpOut = [[InvesterHoldOut alloc] initWithCommodityNum:portfolioItem->commodityNo IIG_ID:0 StartDate:sDate EndDate:eDate];
            [FSDataModelProc sendData:self WithPacket:cpOut];
        }
    }
    
    
    
    [self.datalock unlock];
}

- (void)InvesterDataCallBack1:(InvesterHoldIn *)data
{
    [self.datalock lock];
    
    [self.mainDict setObject:[NSNumber numberWithDouble:data->percent] forKey:@"Ratio1"];

    [self.datalock unlock];
        
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    [dataModel.investerBS performSelector:@selector(decodeInvesterHoldArrive:) onThread:dataModel.thread withObject:data waitUntilDone:NO];
}


- (void)InvesterDataCallBack2:(InvesterHoldIn *)data
{
    [self.datalock lock];
    
    [self.mainDict setObject:[NSNumber numberWithDouble:data->percent] forKey:@"Ratio2"];

    [self.datalock unlock];
}


- (void)InvesterDataCallBack3:(InvesterHoldIn *)data
{
    [self.datalock lock];
    
    [self.mainDict setObject:[NSNumber numberWithDouble:data->percent] forKey:@"Ratio3"];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter1 stringFromDate:date];
    [self.mainDict setObject:dateStr forKey:@"Date"];
    [self saveToFile];
    if ([self.delegate respondsToSelector:@selector(InvesterNotifyData:)]) {
        [self.delegate InvesterNotifyData:self.mainDict];
    }
    
    
    
    [self.datalock unlock];
}

- (void)saveToFile {
	[self.datalock lock];
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ InvesterHold.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
	BOOL success = [self.mainDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"InversterHold wirte error!!");
	[self.datalock unlock];
}
@end
