//
//  MarketInfo.m
//  Bullseye
//
//  Created by steven on 2009/1/9.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MarketInfo.h"
#import "MarketInfoOut.h"
#import "MarketInfoIn.h"


@implementation MarketInfoItem 

- (id)init
{
	if (self = [super init])
	{
		marketName = nil;
	}
	return self;
}

@end

@interface MarketInfo ()
@property (nonatomic, strong) NSMutableArray *marketInfoArray;
@property (nonatomic, strong) NSRecursiveLock *lock;
@end

@implementation MarketInfo

@synthesize marketInfoArray;
@synthesize lock;

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        self.marketInfoArray  = [[NSMutableArray alloc] init];
        self.lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

#pragma mark - Info

- (MarketInfoItem *)getMarketInfo: (UInt8) market_id
{
	MarketInfoItem *result = nil;
	if (marketInfoArray == nil) return nil;
	[lock lock];
	for (MarketInfoItem *item in marketInfoArray)
	{
		if (item->market_id == market_id)
		{
			result = item;
			break;
		}
	}
	[lock unlock];
	return result;
}

- (BOOL)isBreakTime:(UInt16) time marketId:(UInt8) marketId
{
    MarketInfoItem *market = [self getMarketInfo:marketId];
    
    if (market == nil) return NO;
    
    //沒有第二次開始時間，就是該市場沒有休息
    if (market->startTime_2 == 0)
        return FALSE;
    else
        return time > market->endTime_1 && time < market->startTime_2;
}

/**
 *  用來比較給定的tick時間是否為收盤時間，藉此可以判斷該tick是否為收盤價
 *
 *  @param tickTime Tick時間，可以從snapshot的timeOfLastTick或是EquityTickData->tick->time取得
 *  @param marketId PorfolioItem->marketId
 *
 *  @return 若相同回傳YES，相異回傳NO
 */
- (BOOL)isTickTime:(UInt16) tickTime EqualToMarketClosedTime:(UInt8) marketId
{
    MarketInfoItem *market = [self getMarketInfo:marketId];
    if (market == nil) return NO;
    
    //沒有休息的市場，用endTime_1來比
    if (market->startTime_2 == 0)
        return tickTime+market->startTime_1 >= market->endTime_1;
    else
        return tickTime+market->startTime_1 >= market->endTime_2;
}

/**
 *  計算從start到end共多少交易時間(休息時間不算)。時間表示是用從午夜開始所過的分鐘數。
 *
 *  @param end 結束時間
 *  @param start 開始時間
 *  @param marketId PortfolioItem裡的market_id
 *
 *  @return 以UInt16表示的分鐘數
 */
- (UInt16)subtractTime:(UInt16)end by:(UInt16)start marketId:(UInt8) marketId
{
    MarketInfoItem *market = [self getMarketInfo:marketId];
    
    if (market == nil) return NO;
    
    if (market->startTime_2 == 0 && market->endTime_2 == 0) {
        return end - start;
    }
    else {
        if (end <= market->endTime_1 || start >= market->startTime_1)
            return end - start;
        else
            return (market->endTime_1 - start) + (end - market->startTime_2) + 1;
    }
}

#pragma mark - Communication

- (void) addMarketInfo:(MarketInfoIn *)obj
{
	[lock lock];
	NSMutableArray *marketRemove = [obj marketRemove];
	for (removeMarket *remove in marketRemove)
	{
		for (MarketInfoItem *item in marketInfoArray)
		{
			if (item->market_id == remove->MarketID)
			{
				[marketInfoArray removeObject:item];
				break;
			}
		}
	}

	NSMutableArray *marketAdd = [obj marketAdd];
	for (addMarket *add in marketAdd)
	{
		MarketInfoItem *item = [[MarketInfoItem alloc] init];
		item->market_id = add->MarketID;
		item->marketName = [add->MarketName copy];
		item->identCode[0] = add->CountryCode[0];
		item->identCode[1] = add->CountryCode[1];
		item->startTime_1 = add->start_time1;
		item->endTime_1 = add->end_time1;
		item->startTime_2 = add->start_time2;
		item->endTime_2 = add->end_time2;
		[marketInfoArray addObject:item];
	}
	//if (obj->retCode == 0)
	//{
	//	DB_Date *db_Date = [[DB_Date alloc] initWithTableName:MSIC_SYNCDATE_TABLE];
	//	[db_Date updateSyncDate: obj->MITdate andSectorID: SYNCDATE_MARKETINFO];
	//	[db_Date release];
	//}
	[lock unlock];
}

- (void) sendRequest
{
	UInt16 year = 1960;
	UInt8 month = 1;
	UInt8 day = 1;
	//DB_Date *db_Date = [[DB_Date alloc] initWithTableName:MSIC_SYNCDATE_TABLE];
	//UInt16 nSyncDate = [db_Date getSyncDate:SYNCDATE_MARKETINFO];
	//[db_Date release];
	//[CodingUtil getDate:nSyncDate year:&year month:&month day:&day];
	MarketInfoOut *packet = [[MarketInfoOut alloc] initWithDate:year month:month day:day];
	[FSDataModelProc sendData:self WithPacket:packet];
}

-(void)loginNotify{
    [self sendRequest];
}

@end
