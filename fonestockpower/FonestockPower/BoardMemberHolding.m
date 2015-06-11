//
//  BoardMemberHolding.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "BoardMemberHolding.h"
#import "BoardMemberHoldingOut.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface BoardMemberHolding()
@property (nonatomic, strong) NSRecursiveLock *datalock;
@property (nonatomic, strong) NSMutableDictionary *mainDict;
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@end

@implementation BoardMemberHolding
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
                      [NSString stringWithFormat:@"%c%c %@ BoardMemberHolding.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    
    if ([[self.mainDict objectForKey:@"Date"] isEqualToString:dateStr]) {
        if ([self.delegate respondsToSelector:@selector(notifyBoardMemberHoldingData:)]) {
            [self.delegate performSelectorOnMainThread:@selector(notifyBoardMemberHoldingData:) withObject:self.mainDict waitUntilDone:NO];
        }
    } else {
        self.mainDict = [[NSMutableDictionary alloc] init];
        PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        UInt16 tmpDate;
        tmpDate = [CodingUtil makeDate:1960 month:1 day:1];
        BoardMemberHoldingOut *cpOut = [[BoardMemberHoldingOut alloc] initWithSecurityNum:portfolioItem->commodityNo RecordDate:tmpDate Counts:0];
        [FSDataModelProc sendData:self WithPacket:cpOut];
    }
    [self.datalock unlock];
}

-(void)BoardMemberHoldingDataCallBack:(BoardMemberHoldingIn *)data
{
    [self.datalock lock];
    NSMutableArray *holderNameArray = [[NSMutableArray alloc] init];
    NSMutableArray *holderTitleArray = [[NSMutableArray alloc] init];
    NSMutableArray *shareArray = [[NSMutableArray alloc] init];
    NSMutableArray *ratioArray = [[NSMutableArray alloc] init];
    int totalCount = 0;
    for(int i = 0 ; i<[data->holdDataArray count]; i++){
        BoardMemberHoldingObject *object = [data->holdDataArray objectAtIndex:i];
        if(object){
            if(object->holderShare == 0){
                break;
            }
            [holderNameArray addObject:object->holderName];
            [holderTitleArray addObject:object->holderTitle];
            [shareArray addObject:[NSNumber numberWithDouble:object->holderShare]];
            [ratioArray addObject:[NSNumber numberWithDouble:object->holderShareRatio]];
            totalCount ++;
        }
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    [self.mainDict setObject:dateStr forKey:@"Date"];
    [self.mainDict setObject:dateStr forKey:@"ModifiedDate"];
    [self.mainDict setObject:[NSNumber numberWithInt:totalCount] forKey:@"BoardMemberHolderingCount"];
    [self.mainDict setObject:holderNameArray forKey:@"HolderName"];
    [self.mainDict setObject:holderTitleArray forKey:@"HolderTitle"];
    [self.mainDict setObject:shareArray forKey:@"Share"];
    [self.mainDict setObject:ratioArray forKey:@"Ratio"];
    
    [self saveToFile];
    
    if([self.delegate respondsToSelector:@selector(notifyBoardMemberHoldingData:)]){
        [self.delegate notifyBoardMemberHoldingData:self.mainDict];
    }
    
    [self.datalock unlock];
    
}

- (void)saveToFile {
	[self.datalock lock];
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ BoardMemberHolding.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
	BOOL success = [self.mainDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"companyProfile wirte error!!");
	[self.datalock unlock];
}



@end
