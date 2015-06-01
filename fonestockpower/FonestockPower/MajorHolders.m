//
//  MajorHolders.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "MajorHolders.h"
#import "MajorHoldersOut.h"
#import "FSInstantInfoWatchedPortfolio.h"
@interface MajorHolders()
@property (nonatomic, strong) NSRecursiveLock *datalock;
@property (nonatomic, strong) NSMutableDictionary *mainDict;
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@end


@implementation MajorHolders
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
                      [NSString stringWithFormat:@"%c%c %@ MajorHolders.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    
    
    if ([[self.mainDict objectForKey:@"Date"] isEqualToString:dateStr]) {
        if ([self.delegate respondsToSelector:@selector(notifyHoldersData:)]) {
            [self.delegate performSelectorOnMainThread:@selector(notifyHoldersData:) withObject:self.mainDict waitUntilDone:NO];
        }
    } else {
        self.mainDict = [[NSMutableDictionary alloc] init];
        PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        UInt16 tmpDate;
        tmpDate = [CodingUtil makeDate:1960 month:1 day:1];
        MajorHoldersOut *cpOut = [[MajorHoldersOut alloc] initWithSecurityNum:portfolioItem->commodityNo
                                                                          count:5 recordDate:tmpDate];
        [FSDataModelProc sendData:self WithPacket:cpOut];
    }
    [self.datalock unlock];
}

-(void)MajorHoldersDataCallBack:(MajorHoldersIn *)data
{
    [self.datalock lock];
    NSMutableArray *holderNameArray = [[NSMutableArray alloc] init];
    NSMutableArray *shareRateArray = [[NSMutableArray alloc] init];
    for(int i = 0 ; i<[data->dataArray count]; i++){
        MajorHoldersObject *object = [data->dataArray objectAtIndex:i];
        if(object){
            [holderNameArray addObject:object->name];
            [shareRateArray addObject:[NSNumber numberWithDouble:object->shareRate]];
        }
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    [self.mainDict setObject:dateStr forKey:@"Date"];
    [self.mainDict setObject:[NSNumber numberWithInteger:[data->dataArray count]] forKey:@"MajorHoldersCount"];
    [self.mainDict setObject:holderNameArray forKey:@"HolderName"];
    [self.mainDict setObject:shareRateArray forKey:@"ShareRate"];
    
    [self saveToFile];
    
    if([self.delegate respondsToSelector:@selector(notifyHoldersData:)]){
        [self.delegate notifyHoldersData:self.mainDict];
    }
    
    [self.datalock unlock];
    
}

- (void)saveToFile {
	[self.datalock lock];
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ MajorHolders.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
	BOOL success = [self.mainDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"companyProfile wirte error!!");
	[self.datalock unlock];
}


@end
