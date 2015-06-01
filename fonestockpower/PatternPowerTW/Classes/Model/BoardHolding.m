//
//  BoardHolding.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "BoardHolding.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "BoardHoldingOut.h"


@interface BoardHolding()
{
    UInt16 tmpDate;
    NSDateFormatter *formatter;
}
@property (nonatomic, strong) NSRecursiveLock *datalock;
@property (nonatomic, strong) NSMutableDictionary *mainDict;
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@end


@implementation BoardHolding
- (instancetype)init {
    if (self = [super init]) {
        self.datalock = [[NSRecursiveLock alloc] init];
        formatter = [[NSDateFormatter alloc]init];
        _mainDict = [[NSMutableDictionary alloc]init];
        [formatter setDateFormat:@"yyyy/MM"];
    }
    return self;
}

- (void)sendAndRead {
    [self.datalock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:30]];
    
    self.portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ BoardHolding.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter1 stringFromDate:date];
    
    if ([[self.mainDict objectForKey:@"Date"] isEqualToString:dateStr]) {
        if ([self.delegate respondsToSelector:@selector(BoardHoldingNotifyData:)]) {
            [self.delegate performSelectorOnMainThread:@selector(BoardHoldingNotifyData:) withObject:self.mainDict waitUntilDone:NO];
        }
    } else {
        self.mainDict = [[NSMutableDictionary alloc] init];
        tmpDate = [CodingUtil makeDate:1960 month:1 day:1];
        BoardHoldingOut *cpOut = [[BoardHoldingOut alloc] initWithSecurityNum:self.portfolioItem->commodityNo queryType:'H' count:3 recordDate:tmpDate];
        [FSDataModelProc sendData:self WithPacket:cpOut];
    }
    [self.datalock unlock];
}

-(void)HDataCallBack:(BoardHoldingIn *)data
{
    [self.datalock lock];
    NSMutableArray *dateArray = [[NSMutableArray alloc] init];
    NSMutableArray *holdRatioArray = [[NSMutableArray alloc]init];
    NSMutableArray *offsetRatioArray = [[NSMutableArray alloc]init];
    
    for(int i = 0 ; i<[data->dataArray count]; i++){
        BoardHoldingObject *board = [data->dataArray objectAtIndex:i];
        [dateArray addObject:[formatter stringFromDate:[[NSNumber numberWithUnsignedInt:board->recordDate]uint16ToDate]]];
        [holdRatioArray addObject:[NSNumber numberWithDouble:board->holdRatio]];
        [offsetRatioArray addObject:[NSNumber numberWithDouble:board->offsetRatio]];
    }
    [self.mainDict setObject:dateArray forKey:@"HDate"];
    [self.mainDict setObject:holdRatioArray forKey:@"HoldRatio"];
    [self.mainDict setObject:offsetRatioArray forKey:@"OffsetRatio"];
    
    [self saveToFile];
    
    if([self.delegate respondsToSelector:@selector(BoardHoldingNotifyData:)]){
        [self.delegate BoardHoldingNotifyData:self.mainDict];
    }
    
    BoardHoldingOut *cpOut2 = [[BoardHoldingOut alloc] initWithSecurityNum:self.portfolioItem->commodityNo queryType:'P' count:3 recordDate:tmpDate];
    [FSDataModelProc sendData:self WithPacket:cpOut2];
    
    [self.datalock unlock];
    
}

-(void)PDataCallBack:(BoardHoldingIn *)data
{
    [self.datalock lock];
    NSMutableArray *dateArray = [[NSMutableArray alloc] init];
    NSMutableArray *pledgeVolumeArray = [[NSMutableArray alloc]init];
    NSMutableArray *pledgeRatioArray = [[NSMutableArray alloc]init];
    
    for(int i = 0 ; i<[data->dataArray count]; i++){
        BoardHoldingObject *board = [data->dataArray objectAtIndex:i];
        [dateArray addObject:[formatter stringFromDate:[[NSNumber numberWithUnsignedInt:board->recordDate]uint16ToDate]]];
        [pledgeVolumeArray addObject:[NSString stringWithFormat:@"%.0f", board->pledgeVolume]];
        [pledgeRatioArray addObject:[NSNumber numberWithDouble:board->pledgeRatio]];
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter1 stringFromDate:date];
    [self.mainDict setObject:dateStr forKey:@"Date"];
    [self.mainDict setObject:dateArray forKey:@"PDate"];
    [self.mainDict setObject:pledgeVolumeArray forKey:@"PledgeVolume"];
    [self.mainDict setObject:pledgeRatioArray forKey:@"PledgeRatio"];

    [self saveToFile];
    
    if([self.delegate respondsToSelector:@selector(BoardHoldingNotifyData:)]){
        [self.delegate BoardHoldingNotifyData:self.mainDict];
    }
    
    [self.datalock unlock];
    
}

- (void)saveToFile {
	[self.datalock lock];
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ BoardHolding.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
	BOOL success = [self.mainDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"BoardHolding wirte error!!");
	[self.datalock unlock];
}
@end
