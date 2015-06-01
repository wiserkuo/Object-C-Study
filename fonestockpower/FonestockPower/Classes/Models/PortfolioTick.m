//
//  PortfolioTick.m
//  FonestockPower
//
//  Created by Neil on 14/5/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "PortfolioTick.h"
#import "EquityHistory.h"
#import "TickDataOut.h"
#import "EquityNotification.h"
#import "NewHistoricalPriceOut.h"
#import "HistoricDataTypes.h"
#import "SnapshotOut.h"
#import "Commodity.h"
#import "DiscreteTickOut.h"

#import "FSTickQueryOut.h"
#import "FSTickQueryIn.h"
#import "FSTickData.h"

#import "FSSnapshotQueryOut.h"
#import "FSSnapshot.h"

@interface PortfolioTick (){
    TickType type;
	Class entityClass;
	int capacity;
    NSMutableDictionary *mapLabelToSecurityNo;
	NSMutableDictionary *equityTicks;
    NSMutableDictionary *getTicksDict;
    NSMutableDictionary *getDiscreteTicksDict;
    
    // 使用identcodeSymbol作為Key
    NSMutableDictionary *equityTicks_lpcb;
    
    
    NSMutableDictionary *mustGetHistoricDict;
    NSRecursiveLock *lockPortfolioTick;
    
    EquityNotification *notifyKeeper;
    BOOL includeWatchAll;

    UInt8 historicType;
    
    BOOL eodFlag;
    NSString *symbolSystem;
}

@end

@implementation PortfolioTick

- (id)initWithType:(TickType)tp

{
	if (self = [super init])
	{
		type = tp;
		if (type == kTickTypeEquity)
		{
			capacity = 305;
			entityClass = [EquityTick class];
			getTicksDict = [[NSMutableDictionary alloc] init];
            getDiscreteTicksDict = [[NSMutableDictionary alloc] init];
		}
		else
		{	// kTickTypeHistoricData
			capacity = 305;
			entityClass = [EquityHistory class];
			mustGetHistoricDict = [[NSMutableDictionary alloc] init];
		}
		
		lockPortfolioTick = [[NSRecursiveLock alloc] init];
        
		mapLabelToSecurityNo = [[NSMutableDictionary alloc] initWithCapacity:capacity];
		equityTicks = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        equityTicks_lpcb = [[NSMutableDictionary alloc] initWithCapacity:capacity];

        includeWatchAll = FALSE;
        notifyKeeper = [[EquityNotification alloc] init];
	}
	
	return self;
}

- (EquitySnapshotDecompressed*) getSnapshot: (UInt32)securityNo
{
	if (type != kTickTypeEquity)
		return nil;
	
	// Find the EquityTick for the coming tick.
	NSNumber *ticksKey = [[NSNumber alloc] initWithUnsignedInt:securityNo];
	[lockPortfolioTick lock];
	EquityTick *tickObj = [equityTicks objectForKey:ticksKey];
	[lockPortfolioTick unlock];
	
	return tickObj.snapshot;
}

- (FSSnapshot *)getSnapshotBvalue:(UInt32)securityNo {
	if (type != kTickTypeEquity)
		return nil;
	
	// Find the EquityTick for the coming tick.
	NSNumber *ticksKey = [[NSNumber alloc] initWithUnsignedInt:securityNo];
	[lockPortfolioTick lock];
	EquityTick *tickObj = [equityTicks objectForKey:ticksKey];
	[lockPortfolioTick unlock];
	
	return tickObj.snapshot_b;
}

- (FSSnapshot *)getSnapshotBvalueFromIdentCodeSymbol:(NSString *)identCodeSymbol {
	if (type != kTickTypeEquity)
		return nil;
	
	// Find the EquityTick for the coming tick.
    NSNumber *key = [mapLabelToSecurityNo objectForKey:identCodeSymbol];
    
	[lockPortfolioTick lock];
    EquityTick *tickObj;
    if (key) {
        tickObj = [equityTicks objectForKey:key];
    }
	[lockPortfolioTick unlock];
	
	return tickObj.snapshot_b;
}

- (EquitySnapshotDecompressed*) getSnapshotFromIdentCodeSymbol: (NSString *)identCodeSymbol
{
	if (type != kTickTypeEquity)
		return nil;
    
	[lockPortfolioTick lock];
	NSNumber *key = [mapLabelToSecurityNo objectForKey:identCodeSymbol];
	[lockPortfolioTick unlock];
	
	if (key)
	{
		return [self getSnapshot:[key unsignedIntValue]];
	}
	
	return nil;
}



- (void)goGetTickByIdentSymbolForStock :(NSString*)is {
    
    PortfolioItem *portfolioItem = [[[FSDataModelProc sharedInstance] portfolioData] findItemByIdentCodeSymbol:is];
    
    if (portfolioItem) {
        
        FSBTimeFormat *btime;
        
        NSNumber *securityKey = [mapLabelToSecurityNo objectForKey:is];
        EquityTick *tickObj = [equityTicks objectForKey:securityKey];
        if (tickObj) {
            
            
            if ([tickObj.ticksData count] > 0) {
                
                if (tickObj.maxLastTime) {
                    btime = [tickObj.maxLastTime copy];
                    [btime timeOffsetWithAddHours:0 minutes:0 seconds:0 sn:1];
                } else {
                    MarketInfoItem *market = [[[FSDataModelProc sharedInstance] marketInfo] getMarketInfo:portfolioItem->market_id];
                    if (market) {
                        btime = [[FSBTimeFormat alloc] initWithTimeFormatUInt16:market->startTime_1];
                    }
                    else {
                        btime = [[FSBTimeFormat alloc] initWithHours:8 minutes:30 seconds:0 sn:0];
                    }
                }
                
            }
            else {
                MarketInfoItem *market = [[[FSDataModelProc sharedInstance] marketInfo] getMarketInfo:portfolioItem->market_id];
                if (market) {
                    btime = [[FSBTimeFormat alloc] initWithTimeFormatUInt16:market->startTime_1];
                }
                else {
                    btime = [[FSBTimeFormat alloc] initWithHours:8 minutes:30 seconds:0 sn:0];
                }
                
            }
        }
        
        FSTickQueryOut *packout = [[FSTickQueryOut alloc] initWithIdentCodeSymbol:is lastTickBTimeFormat:btime];
        [FSDataModelProc sendData:self WithPacket:packout];
    }

}


- (void)goGetTickByIdentSymbolForStock2 :(NSString*)is {
    
#ifdef LPCB
    PortfolioItem *portfolioItem = [[[FSDataModelProc sharedInstance] portfolioData] findItemByIdentCodeSymbol:is];
    if (portfolioItem) {
        
        FSBTimeFormat *btime;
        
        NSNumber *securityKey = [mapLabelToSecurityNo objectForKey:is];
        EquityTick *tickObj = [equityTicks objectForKey:securityKey];
        if (tickObj) {

            
            if ([tickObj.ticksData count] > 0) {

//                FSTickData *tick = [tickObj.ticksData lastObject];
                
                if (tickObj.maxLastTimeIndex == -1) {
                    MarketInfoItem *market = [[[FSDataModelProc sharedInstance] marketInfo] getMarketInfo:portfolioItem->market_id];
                    if (market) {
                        btime = [[FSBTimeFormat alloc] initWithTimeFormatUInt16:market->startTime_1];
                    }
                    else {
                        btime = [[FSBTimeFormat alloc] initWithHours:8 minutes:30 seconds:0 sn:0];
                    }
                }
                else {
//                    FSTickData *tick = [tickObj.ticksData objectAtIndex:tickObj.maxLastTimeIndex];
                    btime = [tickObj.maxLastTime copy];
                    [btime timeOffsetWithAddHours:0 minutes:0 seconds:0 sn:1];
                    
                }
                
            }
            else {
                MarketInfoItem *market = [[[FSDataModelProc sharedInstance] marketInfo] getMarketInfo:portfolioItem->market_id];
                if (market) {
                    btime = [[FSBTimeFormat alloc] initWithTimeFormatUInt16:market->startTime_1];
                }
                else {
                    btime = [[FSBTimeFormat alloc] initWithHours:8 minutes:30 seconds:0 sn:0];
                }

            }
        }
        
        FSTickQueryOut *packout = [[FSTickQueryOut alloc] initWithIdentCodeSymbol:is lastTickBTimeFormat:btime];
        [FSDataModelProc sendData:self WithPacket:packout];
    }
#else
    NSNumber *securityKey = [mapLabelToSecurityNo objectForKey:is];
	
	// Add the notification target for the specified number of commodity.
	if (securityKey)
	{
		// Issue a request to the server for ticks in high priority.
		EquityTick *tickObj = [equityTicks objectForKey:securityKey];
		
		// Send request to server for the ticks from 1 till now in low priority
		EquitySnapshotDecompressed *snapshot = tickObj.snapshot;
		
		// Check if all ticks had been fetched already. Get them if not.
		if (snapshot.sequenceOfTick > tickObj.firstBreakNo)
		{
            TickDataOut *packet = [[TickDataOut alloc] initWithCommodityNum:[securityKey unsignedIntValue] BeginSN:(tickObj.firstBreakNo + 1) EndSN:snapshot.sequenceOfTick];
			[FSDataModelProc sendData:self WithPacket:packet];
		}
        
    }
    
#endif
}


- (void)addTick:(NSArray *)tickParams recv_complete:(NSNumber *)tick_rev_complete {
    
    if (type != kTickTypeEquity)
        return;
    
    [lockPortfolioTick lock];
    
    if ([tickParams count] > 0) {
        FSTickData *tick = [tickParams lastObject];
        
        NSNumber *securityKey;
        if (tick.securityNumber) {
            securityKey = [NSNumber numberWithLongLong:tick.securityNumber];
        }
        else {
            securityKey = [mapLabelToSecurityNo objectForKey:tick.identCodeSymbol];
        }
        
        EquityTick *tickObj = [equityTicks objectForKey:securityKey];
        
        if (tickObj) {
            [tickObj addEquityTicks:tickParams isLastTicksData:[tick_rev_complete boolValue]];
            
            if (tick_rev_complete) {
                [tickObj recomputeVolume];
                [notifyKeeper notifyTarget:securityKey WithEquityDictionary:equityTicks IncludeAll:includeWatchAll];
            }
        }
    }
    
    [lockPortfolioTick unlock];
}


- (void)addTick:(NSArray *)tickParams
{
	id obj;
	EquityTick *tickObj;
	UInt32 lastSecurityNo;
	
	if (type != kTickTypeEquity)
		return;
	
	[lockPortfolioTick lock];
    
	for (obj in tickParams)
	{
		if ([obj isKindOfClass:[EquityTickParam class]])
		{
			EquityTickParam *tickParam = obj;
			// Find the EquityTick for the coming tick.
			NSNumber *ticksKey = [[NSNumber alloc] initWithUnsignedInt:tickParam->securityNO];
			tickObj = [equityTicks objectForKey:ticksKey];
			if (!tickObj)  continue;
            tickParam->etick.tick.volumeType = tickParam->volumeType;
            tickParam->etick.tick.volumeDouble = [CodingUtil ConvertTAValue:tickParam->etick.tick.volume WithType:&tickParam->etick.tick.volumeUnit];
			if(tickParam->etick.tick.time & 0x8000)
			{
				tickParam->etick.tick.time &= 0x7FFF;
				PortfolioItem *portfolioItem = [[[FSDataModelProc sharedInstance]portfolioData] findItemByIdentCodeSymbol:tickObj.identCodeSymbol];
				if(portfolioItem)
				{
					MarketInfoItem *market = [[[FSDataModelProc sharedInstance]marketInfo] getMarketInfo:portfolioItem->market_id];
					if(market)
						tickParam->etick.tick.time -= market->startTime_1;
				}
			}
			[tickObj addEquityTick:tickParam WithSequenceNo:tickParam->sequence];
			lastSecurityNo = tickParam->securityNO;
		}
        
		if ([obj isKindOfClass:[IndexTickParam class]])
		{
			IndexTickParam *tickParam = obj;
			// Find the EquityTick for the coming tick.
			NSNumber *ticksKey = [[NSNumber alloc] initWithUnsignedInt:tickParam->securityNO];
			tickObj = [equityTicks objectForKey:ticksKey];
			if (!tickObj)  continue;
			if(tickParam->itick.tick.time & 0x8000)
			{
				tickParam->itick.tick.time &= 0x7FFF;
				PortfolioItem *portfolioItem = [[[FSDataModelProc sharedInstance]portfolioData] findItemByIdentCodeSymbol:tickObj.identCodeSymbol];
				if(portfolioItem)
				{
					MarketInfoItem *market = [[[FSDataModelProc sharedInstance]marketInfo] getMarketInfo:portfolioItem->market_id];
					if(market)
						tickParam->itick.tick.time -= market->startTime_1;
				}
			}
			[tickObj addIndexTick:tickParam WithSequenceNo:tickParam->sequence];
			lastSecurityNo = tickParam->securityNO;
		}
	}
	
	// Check if notification is needed.
	NSNumber *securityKey = [[NSNumber alloc] initWithUnsignedInt:lastSecurityNo];
	[notifyKeeper notifyTarget:securityKey WithEquityDictionary:equityTicks IncludeAll:includeWatchAll];
    
    if(tickObj.progress==1){
        [tickObj recomputeVolume];
    }
    
	[lockPortfolioTick unlock];
}

- (void)updateTickDataByIdentCodeSymbol:(NSString *)identSymbol
{
	if (type != kTickTypeEquity)
		return;
    
    NSNumber *securityKey = [mapLabelToSecurityNo objectForKey:identSymbol];
    
    NSObject <HistoricDataArriveProtocol> *target = [mustGetHistoricDict objectForKey:identSymbol];
    [notifyKeeper addKey:securityKey Entity:target];
    
    [self goGetTickByIdentSymbolForStock:identSymbol];
    
}

-(void)setTaget:(NSObject<DataArriveProtocol> *)target IdentCodeSymbol:(NSString *)identSymbol{
    NSNumber *securityKey = [mapLabelToSecurityNo objectForKey:identSymbol];
    [notifyKeeper addKey:securityKey Entity:target];
}

-(void)removeKeyWithTaget:(NSObject<DataArriveProtocol> *)target IdentCodeSymbol:(NSString *)identSymbol{
    NSNumber *key = [mapLabelToSecurityNo objectForKey:identSymbol];
	
	if (key)
		[notifyKeeper removeKey:key Entity:target];
	else
		[notifyKeeper removeKey:identSymbol Entity:target];
}

-(void)removeIndexQuotesAllKeyWithTaget:(NSObject<DataArriveProtocol> *)target{
    [notifyKeeper removeEntityForAll:target];
}

- (void)getEODActionForEquity:(NSString *)identCodeSymbol tickType:(UInt8)ttp SymbolType:(NSString *)symbolType
{
    
	[lockPortfolioTick lock];
    symbolSystem = symbolType;
    eodFlag = YES;
	// Get the portfolio object from data modal.
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	Portfolio *portf = dataModal.portfolioData;
	
	// Find the portfolio item that matches the IdentCode and Symbol.
	PortfolioItem *portItem = [portf findItemByIdentCodeSymbol:identCodeSymbol];
    
	if(portItem==nil){
        return;
    }
    [self addEquity:identCodeSymbol WithSecurityNo:portItem->commodityNo];
//    NSDate *today = [NSDate date];
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
//    int year = [comps year];
//    int month = [comps month];
//    int day = [comps day];
//    int newYear;
//    int newMonth;
//    
//    if(month==2){
//        newYear = year--;
//        newMonth = 12;
//    }else if(month==1){
//        newYear = year--;
//        newMonth = 11;
//    }else{
//        newYear = year;
//        newMonth = month-2;
//    }
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *today = [NSDate date];
    NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    int year = (int)[comps year];
    int month = (int)[comps month];
    int day = (int)[comps day];
    
    year -=3;
    
    
    NewHistoricalPriceOut *packet = [[NewHistoricalPriceOut alloc]initWithSecurityNumber:portItem->commodityNo dataType:'D' commodityType:portItem->type_id startDate:[CodingUtil makeDate:year month:month day:day] endDate:[CodingUtil makeDateFromDate:today]];
    
    [FSDataModelProc sendData:self WithPacket:packet];
    
	[lockPortfolioTick unlock];
}


- (void)watchTarget:(NSObject <DataArriveProtocol> *)target ForEquity:(NSString *)identCodeSymbol
{
	if (type != kTickTypeEquity || identCodeSymbol == nil)
		return;
	
	[lockPortfolioTick lock];
	
	// Notify if it matches with target's request.
	NSNumber *securityKey = [mapLabelToSecurityNo objectForKey:identCodeSymbol];
	
	// Add the notification target for the specified number of commodity.
	if (securityKey)
		[notifyKeeper addKey:securityKey Entity:target];
	else
		// This may include "PortfolioAll".
		[notifyKeeper addKey:identCodeSymbol Entity:target];
	
	// Notify the target for the data.
	[notifyKeeper notifyTarget:securityKey WithEquityDictionary:equityTicks IncludeAll:YES];
    
	[lockPortfolioTick unlock];
}

- (BOOL)watchTarget:(NSObject <HistoricDataArriveProtocol> *)target ForEquity:(NSString *)identCodeSymbol tickType:(UInt8)ttp
{
	if (type != kTickTypeHistoricData || target == nil)
		return FALSE;
	
	[lockPortfolioTick lock];
	
	if(ttp == 'F' || ttp == 'T' || ttp == 'S')		//15~60分線 算是拿5分線的
	{
		ttp = '5';
	}
	
	historicType = ttp;
	
	// Get the portfolio object from data modal.
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	Portfolio *portf = dataModal.portfolioData;
	
	// Find the portfolio item that matches the IdentCode and Symbol.
	PortfolioItem *portItem = [portf findItemByIdentCodeSymbol:identCodeSymbol];
	
	// Save the target that watches for the tick of historic data for notification when the ticks are available.
	if(portItem->commodityNo == 0)
	{
		[mustGetHistoricDict setObject:target forKey:identCodeSymbol];
		[lockPortfolioTick unlock];
		return FALSE;
	}
	NSNumber *securityKey = [[NSNumber alloc] initWithUnsignedInt:portItem->commodityNo];
	[notifyKeeper addKey:securityKey Entity:target];
	
	// Add to the cached list.
	[self addEquity:identCodeSymbol WithSecurityNo:portItem->commodityNo];
	
	// Get the corresponding object of historic data
	NSNumber *objKey = [mapLabelToSecurityNo objectForKey:identCodeSymbol];
	EquityHistory *commObj = [equityTicks objectForKey:objKey];
	
	// Ask it to load data from stored files, if any.
	//[commObj loadWithIdentCodeSymbol:identCodeSymbol commodityType:portItem->type_id];
	[commObj loadFromFile:portItem->type_id];
    
	// Load data from file if any.
	NSDate *upToDate = nil;
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *today = [NSDate date];
	// Get last date from the file.
	UInt16 lastDate = [commObj quertyDataDate:ttp];
    
    if  (ttp == 'W' || ttp == 'M'){
        if ([commObj loadWithTickType:'D']) {
            UInt16 dLastDate = [commObj quertyDataDate:'D'];
            NSDate * dUpToDate = nil;
            if (dLastDate)
            {
                // Convert returned date to NSDate.
                UInt16 year;
                UInt8 month;
                UInt8 day;
                [CodingUtil getDate:dLastDate year:&year month:&month day:&day];
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                [comps setYear:year];
                [comps setMonth:month];
                [comps setDay:day];
                dUpToDate = [calendar dateFromComponents:comps];
            }
            if (dUpToDate)
            {
                NSDate *requestDate;
                // Some data already in file. Notify the target.
                //[target performSelector:@selector(notifyDataArrive:) withObject:commObj afterDelay:0];
                //		[target performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:commObj waitUntilDone:NO];
                
                // find the next date
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                [comps setDay:1];
                requestDate = [calendar dateByAddingComponents:comps toDate:today options:0];
                
                //if (![today isEqualToDate:upToDate])
                if (!([CodingUtil makeDateFromDate:dUpToDate] == [CodingUtil makeDateFromDate:requestDate]))
                {
                    [commObj setLatestData:'D' value:NO];
                    // Request more data from server.
                    //HistoricalPriceOut *packet = [[HistoricalPriceOut alloc] initWithQueryStartDate:[CodingUtil makeDateFromDate:requestDate] EndDate:[CodingUtil makeDateFromDate:today] Commodity:[objKey unsignedIntValue] Type:ttp CommodityType:portItem->type_id];
                    
/*  ===看起來是多送了一次=====
                    NewHistoricalPriceOut *packet = [[NewHistoricalPriceOut alloc]initWithSecurityNumber:[objKey unsignedIntValue] dataType:'D' commodityType:portItem->type_id startDate:[CodingUtil makeDateFromDate:dUpToDate] endDate:[CodingUtil makeDateFromDate:requestDate]];
                    
                    [FSDataModelProc sendData:self WithPacket:packet];
======================== */
                    
                }
            }
            
        }else{
            [commObj setLatestData:ttp value:NO];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *today = [NSDate date];
            NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
            int year = (int)[comps year];
            int month = (int)[comps month];
            int day = (int)[comps day];
            
            year -=3;
            
            NewHistoricalPriceOut *packet = [[NewHistoricalPriceOut alloc]initWithSecurityNumber:[objKey unsignedIntValue] dataType:'D' commodityType:portItem->type_id startDate:[CodingUtil makeDate:year month:month day:day] endDate:[CodingUtil makeDateFromDate:today]];
            
			[FSDataModelProc sendData:self WithPacket:packet];
        }
    }
    
	
	if (lastDate)
	{
		// Convert returned date to NSDate.
		UInt16 year;
		UInt8 month;
		UInt8 day;
		[CodingUtil getDate:lastDate year:&year month:&month day:&day];
		NSDateComponents *comps = [[NSDateComponents alloc] init];
		[comps setYear:year];
		[comps setMonth:month];
		[comps setDay:day];
		upToDate = [calendar dateFromComponents:comps];
	}
	
	if (upToDate)
	{
		NSDate *requestDate;
		// Some data already in file. Notify the target.
		//[target performSelector:@selector(notifyDataArrive:) withObject:commObj afterDelay:0];
        //		[target performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:commObj waitUntilDone:NO];
		
		// find the next date
		NSDateComponents *comps = [[NSDateComponents alloc] init];
		[comps setDay:1];
		requestDate = [calendar dateByAddingComponents:comps toDate:today options:0];
		
		//if (![today isEqualToDate:upToDate])
		if (!([CodingUtil makeDateFromDate:upToDate] == [CodingUtil makeDateFromDate:requestDate]))
		{
			[commObj setLatestData:ttp value:NO];
			// Request more data from server.
			//HistoricalPriceOut *packet = [[HistoricalPriceOut alloc] initWithQueryStartDate:[CodingUtil makeDateFromDate:requestDate] EndDate:[CodingUtil makeDateFromDate:today] Commodity:[objKey unsignedIntValue] Type:ttp CommodityType:portItem->type_id];
            
            NewHistoricalPriceOut *packet = [[NewHistoricalPriceOut alloc]initWithSecurityNumber:[objKey unsignedIntValue] dataType:ttp commodityType:portItem->type_id startDate:[CodingUtil makeDateFromDate:upToDate] endDate:[CodingUtil makeDateFromDate:requestDate]];
            
            [FSDataModelProc sendData:self WithPacket:packet];
			
		}
		else
			[commObj setLatestData:ttp value:YES];
        //		[requestDate release];
	}
	else
	{
        [target performSelector:@selector(notifyDataArrive:) withObject:commObj afterDelay:0];
		[commObj setLatestData:ttp value:NO];
		// Ask whole date from the server.
		NSInteger countEqities;// = MaximumHistoricWeeks;		// Same as MaximumHistoricMonths.
		if (ttp == kTickType5Minute)
			countEqities = MaximumHistoric5Minutes;
		else if (ttp == kTickTypeDay)
			countEqities = MaximumHistoricDays;
        else if (ttp == kTickTypeWeek)
            countEqities = MaximumHistoricWeeks;
        else if (ttp == kTickTypeMonth)
            countEqities = MaximumHistoricMonths;
		//HistoricalPriceOut *packet = [[HistoricalPriceOut alloc] initWithQueryCounts:(UInt8)countEqities Commodity:[objKey unsignedIntValue] Type:ttp CommodityType:portItem->type_id];
        
        //        NewHistoricalPriceOut * packet = [[NewHistoricalPriceOut alloc]initWithSecurityNumber:[objKey unsignedIntValue] dataType:ttp commodityType:portItem->type_id count:(UInt16)countEqities];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *today = [NSDate date];
        NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
        int year = (int)[comps year];
        int month = (int)[comps month];
        int day = (int)[comps day];
        
        if (ttp == kTickType5Minute){
			if (month>1) {
                month -=1;
            }else{
                year-=1;
                month=12;
            }
        }
        //            day -=1;
        else if (ttp == kTickTypeDay)
            year -=3;
        else if (ttp == kTickTypeWeek)
            year -=5;
        else if (ttp == kTickTypeMonth)
            year -=10;
        
        
        NewHistoricalPriceOut *packet = [[NewHistoricalPriceOut alloc]initWithSecurityNumber:[objKey unsignedIntValue] dataType:ttp commodityType:portItem->type_id startDate:[CodingUtil makeDate:year month:month day:day] endDate:[CodingUtil makeDateFromDate:today]];
        
        [FSDataModelProc sendData:self WithPacket:packet];
		
	}
	
    //	[today release];
	
	[lockPortfolioTick unlock];
	
	return TRUE;
}

- (BOOL)GetCurData:(NSObject <HistoricDataArriveProtocol> *)target ForEquity:(NSString *)identCodeSymbol tickType:(UInt8)ttp
{
	if (type != kTickTypeHistoricData || target == nil)
		return FALSE;
	
	[lockPortfolioTick lock];
	
	if(ttp == 'F' || ttp == 'T' || ttp == 'S')		//15~60分線 算是拿5分線的
	{
		ttp = '5';
	}
	
	historicType = ttp;
	
	// Get the portfolio object from data modal.
	/*DataModalProc *dataModal = [DataModalProc getDataModal];
     Portfolio *portf = dataModal.portfolioData;
     PortfolioItem *portItem = [portf findItemByIdentCodeSymbol:identCodeSymbol];*/
	// Get the corresponding object of historic data
	NSNumber *objKey = [mapLabelToSecurityNo objectForKey:identCodeSymbol];
	EquityHistory *commObj = [equityTicks objectForKey:objKey];
	
	// Ask it to load data from stored files, if any.
	//[commObj loadFromFile:portItem->type_id];
	
	// Load data from file if any.
	// Get last date from the file.
	UInt16 lastDate = [commObj quertyDataDate:ttp];
	
	if (lastDate)
	{
		[target performSelector:@selector(notifyDataArrive:) withObject:commObj afterDelay:0];
		[lockPortfolioTick unlock];
		return YES;
	}
	else
	{
		[lockPortfolioTick unlock];
		return NO;
	}
	
}


- (void)watchTarget:(NSObject <DataArriveProtocol> *)target ForEquity:(NSString *)identCodeSymbol GetTick:(BOOL)getTick
{
	[self addTaget:target ForEquity:identCodeSymbol commandType:GetTickCommand getFlag:getTick];
}

- (void)watchTarget:(NSObject <DataArriveProtocol> *)target ForEquity:(NSString *)identCodeSymbol GetDiscreteTick:(BOOL)getDiscreteTick
{
	[self addTaget:target ForEquity:identCodeSymbol commandType:GetDiscreteTickCommand getFlag:getDiscreteTick];
}

- (void)stopWatch:(NSObject *)target ForEquity:(NSString *)identCodeSymbol
{
	[lockPortfolioTick lock];
	
	if(mustGetHistoricDict)
		[mustGetHistoricDict removeObjectForKey:identCodeSymbol];
	
	NSNumber *key = [mapLabelToSecurityNo objectForKey:identCodeSymbol];
	
	if (key)
		[notifyKeeper removeKey:key Entity:target];
	else
		// This may include "PortfolioAll".
		[notifyKeeper removeKey:identCodeSymbol Entity:target];
	
	[getTicksDict removeObjectForKey:identCodeSymbol];
	[lockPortfolioTick unlock];
}

- (void)addTaget:(NSObject <DataArriveProtocol> *)target ForEquity:(NSString *)identCodeSymbol commandType:(CommandType)commandType getFlag:(BOOL) getFlag
{
    if (type != kTickTypeEquity) {
		return;
    }
	
	[lockPortfolioTick lock];
	
	// Notify if it matches with target's request.
	NSNumber *securityKey = [mapLabelToSecurityNo objectForKey:identCodeSymbol];
    
    
    if (commandType == GetTickCommand) {
        if(target == nil || !getFlag)
            [getTicksDict removeObjectForKey:identCodeSymbol];
        else if(getFlag)
        {
            [getTicksDict setObject:[NSNumber numberWithBool:YES] forKey:identCodeSymbol];
        }
    }
    else {
        if(target == nil || !getFlag)
            [getDiscreteTicksDict removeObjectForKey:identCodeSymbol];
        else if(getFlag)
        {
            [getDiscreteTicksDict setObject:[NSNumber numberWithBool:YES] forKey:identCodeSymbol];
        }
    }
    
	
	
	// Add the notification target for the specified number of commodity.
	if (securityKey)
		[notifyKeeper addKey:securityKey Entity:target];
	else
		// This may include "PortfolioAll".
		[notifyKeeper addKey:identCodeSymbol Entity:target];
	
	// Notify the target for the data.
	[notifyKeeper notifyTarget:securityKey WithEquityDictionary:equityTicks IncludeAll:YES];
	
	[lockPortfolioTick unlock];
}

- (void)addClearSnapshot:(MessageType06Param *)tmParam
{
	if (type != kTickTypeEquity)
		return;
	
	// Find the EquityTick to update the snapshot.
	NSNumber *securityKey = [[NSNumber alloc] initWithUnsignedInt:tmParam->commodityNo];
	[lockPortfolioTick lock];
	EquityTick *tickObj = [equityTicks objectForKey:securityKey];
	
	if (tickObj)
	{
		[tickObj clearTicks];
		[tickObj.snapshot updateWithClear:tmParam];
		
		// Check if notify the client.
		[notifyKeeper notifyTarget:securityKey WithEquityDictionary:equityTicks IncludeAll:YES];
	}
    
	[lockPortfolioTick unlock];
}

- (BOOL)addEquity:(NSString *)identCodeSymbol WithSecurityNo:(UInt32)securityNo
{
    
    [lockPortfolioTick lock];
//#ifdef LPCB
//    NSObject *tickObj = [[entityClass alloc] init];
//    [tickObj performSelector:@selector(assignIdentCodeSymbol:) withObject:identCodeSymbol];
//    [equityTicks_lpcb setObject:tickObj forKey:identCodeSymbol];
//    [mapLabelToSecurityNo setObject:[NSNumber numberWithUnsignedInt:securityNo] forKey:identCodeSymbol];
//#endif
    
	
	NSNumber *oldSecurity = [mapLabelToSecurityNo objectForKey:identCodeSymbol];
	
	// SecurityNo is the same as stored one.
	if (oldSecurity && [oldSecurity unsignedIntValue] == securityNo)
	{
		[lockPortfolioTick unlock];
		return TRUE;
	}
	
	NSNumber *newSecurityKey = [[NSNumber alloc] initWithUnsignedInt:securityNo];
	
	if (oldSecurity)
	{
		// Replace with a new security number with the same object.
		[equityTicks setObject:[equityTicks objectForKey:oldSecurity] forKey:newSecurityKey];
		[equityTicks removeObjectForKey:oldSecurity];
		
		[mapLabelToSecurityNo setObject:newSecurityKey forKey:identCodeSymbol];
	}
	else
	{
		// Add new entries to the two dictionary.
		NSObject *tickObj = [[entityClass alloc] init];
        //		[tickObj assignIdentCodeSymbol: identCodeSymbol];
		[tickObj performSelector:@selector(assignIdentCodeSymbol:) withObject:identCodeSymbol];
		
		[equityTicks setObject:tickObj forKey:newSecurityKey];
		[mapLabelToSecurityNo setObject:newSecurityKey forKey:identCodeSymbol];
		
	}
	[lockPortfolioTick unlock];
	
	// Change the watched symbol to commodity number
	[notifyKeeper fromOldKey:identCodeSymbol ToNewKey:newSecurityKey];
	
	
	return TRUE;
}

- (void)removeEquity:(NSString *)identCodeSymbol
{
	[lockPortfolioTick lock];
	NSNumber *securityNo = [mapLabelToSecurityNo objectForKey:identCodeSymbol];
	if (securityNo)
	{
		// Remove EquityTick from responding if any.
		// To keep notifying the target if there was a disconnection happened. The notification were kept the same.
		// [notifyKeeper removeAllEntities:[securityNo unsignedIntValue]];
		[notifyKeeper removefromKey:securityNo];
        
		// Remove from dictionaries.
		[mapLabelToSecurityNo removeObjectForKey:identCodeSymbol];
		[equityTicks removeObjectForKey:securityNo];
	}
	[lockPortfolioTick unlock];
}

- (void)stopWatch:(NSObject *)target ForEquity:(NSString *)identCodeSymbol discreteTick:(BOOL) discreteTick
{
    [lockPortfolioTick lock];
	
	if(mustGetHistoricDict)
		[mustGetHistoricDict removeObjectForKey:identCodeSymbol];
	
	NSNumber *key = [mapLabelToSecurityNo objectForKey:identCodeSymbol];
	
	if (key)
		[notifyKeeper removeKey:key Entity:target];
	else
		// This may include "PortfolioAll".
		[notifyKeeper removeKey:identCodeSymbol Entity:target];
	
	[getDiscreteTicksDict removeObjectForKey:identCodeSymbol];
	[lockPortfolioTick unlock];
}

- (void)removeWatch:(NSObject *)target
{
	[lockPortfolioTick lock];
    
	[notifyKeeper removeEntityForAll:target];
	
	[lockPortfolioTick unlock];
}

- (void)addHistoricTick:(HistoricalParm *)param
{
    NSNumber *objKey = [[NSNumber alloc] initWithUnsignedInt:param->commodityNum];
	[lockPortfolioTick lock];
	EquityHistory *obj = [equityTicks objectForKey:objKey];

	if (type != kTickTypeHistoricData)
		return;
	
	if (obj /*&& param->dataCount*/)
	{
		// Add ticks to low level module.
		[obj addHistoricTicks:param];
		// Notify if necessary.
		[notifyKeeper notifyTarget:objKey WithEquityDictionary:equityTicks IncludeAll:NO];
	}
	
	[lockPortfolioTick unlock];
    //neil
//	if (param->retcode == 0 && param->type == 'M' && param->commodityNum == autoFetingCommodityNo) // autofetch next sector;
//	{
//		autoFetingCommodityNo = 0;
//		DataModalProc *dataModal = [DataModalProc getDataModal];
//		if (includeWatchAll)
//            [dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
//	}
	
}

- (EquityTick*)getEquityTick:(NSString *)identCodeSymbol
{
	EquityTick *obj;
	[lockPortfolioTick lock];
	NSNumber *securityNo = [mapLabelToSecurityNo objectForKey:identCodeSymbol];
	if (securityNo)
		obj = [equityTicks objectForKey:securityNo];
	else
		obj = nil;
	[lockPortfolioTick unlock];
	return obj;
}

- (void)updateEquitySnapshot:(NSObject *)snapshotdata
{
	if (type != kTickTypeEquity)
		return;
    
    if ([snapshotdata isKindOfClass:[SnapshotParam class]]) {
        
        [lockPortfolioTick lock];
        
        SnapshotParam *snapshot = (SnapshotParam *)snapshotdata;
        NSNumber *securityKey = [[NSNumber alloc] initWithUnsignedInt:snapshot->security];
        
        // Find the EquityTick to update the snapshot.
        EquityTick *tickObj = [equityTicks objectForKey:securityKey];
        
        if (tickObj) {
            
            // Update the snapshot
            // Check if notify the client.
            if ([tickObj updateSnapshot:snapshot->snapshot])
                [notifyKeeper notifyTarget:securityKey WithEquityDictionary:equityTicks IncludeAll:YES];
            
            if(snapshot->snapshot->subType == 1) {
                /*
                 先檢查是否需要抓商品的全部tick，再檢查是否需要抓不連續的tick(江波圖用)
                 */
                if([getTicksDict objectForKey:tickObj.identCodeSymbol]) {
                    [self goGetTickByIdentSymbol:tickObj.identCodeSymbol];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFSTickDataCallBackNotification object:nil];
                }
                else if([getDiscreteTicksDict objectForKey:tickObj.identCodeSymbol]) {
                    [self goGetDiscreteTickByIdentSymbol:tickObj.identCodeSymbol];
                } else {
                    [self goGetDiscreteTickByIdentSymbol:tickObj.identCodeSymbol];
                    //[self goGetTickByIdentSymbolForStock:tickObj.identCodeSymbol];
                    SnapshotOut * ssOut = [[SnapshotOut alloc] initWithSubType:2 CommodityNum:snapshot->security];
                    [ssOut addWithSubType:3 CommodityNum:snapshot->security];
                    [ssOut addWithSubType:4 CommodityNum:snapshot->security];
                    [FSDataModelProc sendData:self WithPacket:ssOut];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFSTickDataCallBackNotification object:nil];
                }
            }
        }
        
        [lockPortfolioTick unlock];
        
    }
    else {
        
        [lockPortfolioTick lock];
        
        FSSnapshot *snapshot = (FSSnapshot *)snapshotdata;
        NSNumber *securityKey = [[NSNumber alloc] initWithUnsignedInt:snapshot.securityNumber];
        EquityTick *tickObj = [equityTicks objectForKey:securityKey];
        if (tickObj) {
            [tickObj updateSnapshotBValue:snapshot];
            [notifyKeeper notifyTarget:securityKey WithEquityDictionary:equityTicks IncludeAll:YES];
            
            // 判斷snapshot 2 3 4 5 要了沒
//            if (snapshot.snapshotQueryFlag) {
//                FSSnapshotQueryOut *snapshotQueryPacket = [[FSSnapshotQueryOut alloc] initWithSnapshotTypes:@[@2] identCodeSymbols:@[snapshot.identCodeSymbol]];
//                [FSDataModelProc sendData:self WithPacket:snapshotQueryPacket];
//                snapshot.snapshotQueryFlag = NO;
//            }
        }
        
        [lockPortfolioTick unlock];
        
    }
    
    
	
}

- (void)goGetTickByIdentSymbol:(NSString*)is
{
	NSNumber *securityKey = [mapLabelToSecurityNo objectForKey:is];
	
	// Add the notification target for the specified number of commodity.
	if (securityKey)
	{
		// Issue a request to the server for ticks in high priority.
		EquityTick *tickObj = [equityTicks objectForKey:securityKey];
		
		// Send request to server for the ticks from 1 till now in low priority
		EquitySnapshotDecompressed *snapshot = tickObj.snapshot;
		
		// Check if all ticks had been fetched already. Get them if not.
		if (snapshot.sequenceOfTick > tickObj.firstBreakNo)
		{
			TickDataOut *packet = [[TickDataOut alloc] initWithCommodityNum:[securityKey unsignedIntValue] BeginSN:(tickObj.firstBreakNo + 1) EndSN:snapshot.sequenceOfTick];
			[FSDataModelProc sendData:self WithPacket:packet];

		}
		
		//判斷snapshot 2 3 4 5 要了沒
		SnapshotOut *ssOut = nil;
		UInt32 commodity = [securityKey unsignedIntValue];
		for(int i=2 ; i<(snapshot.commodityType == kCommodityTypeWarrant ? 6 : 5) ; i++)		//權證才有5
		{
			if(!(snapshot.snapshotTypeGet & 1<<i))
			{
				if(ssOut == nil)
					ssOut = [[SnapshotOut alloc] initWithSubType:i CommodityNum:commodity];
				else
					[ssOut addWithSubType:i CommodityNum:commodity];
			}
		}
		if(ssOut)
		{
			[FSDataModelProc sendData:self WithPacket:ssOut];
		}
	}
}

- (void)goGetDiscreteTickByIdentSymbol:(NSString*)identSymbol
{
    
	NSNumber *securityKey = [mapLabelToSecurityNo objectForKey:identSymbol];
	
	// Add the notification target for the specified number of commodity.
	if (securityKey)
	{
		// Issue a request to the server for ticks in high priority.
		EquityTick *tickObj = [equityTicks objectForKey:securityKey];
        EquitySnapshotDecompressed *snapshot = tickObj.snapshot;
        if (snapshot.sequenceOfTick > tickObj.firstBreakNo) {
            
            UInt16 lastTickMinuteCounts = 0;
            double lastTickPrice = 0;
            //如果有已存在的tick，找最後一個，取出時間
            [tickObj getTimePrice:&lastTickMinuteCounts Price:&lastTickPrice Sequence:tickObj.lastTickNo];
            
            //計算出要抓多散的tick資料
            NSUInteger marketOpenTime, marketCloseTime = 0;
            PortfolioItem *portfolioItem = [[[FSDataModelProc sharedInstance]portfolioData] findItemByIdentCodeSymbol:tickObj.identCodeSymbol];
            if(portfolioItem)
            {
                MarketInfoItem *market = [[[FSDataModelProc sharedInstance]marketInfo] getMarketInfo:portfolioItem->market_id];
                if(market)
                {
                    marketOpenTime = market->startTime_1;
                    //沒有休息的市場
                    if (market->startTime_2 == 0 && market->endTime_2 == 0) {
                        marketCloseTime = market->endTime_1;
                    }
                    //中間有休息的市場
                    else {
                        marketCloseTime = market->endTime_2;
                    }
                    /*
                     tick_sn count = latest tick_sn-上一次query 過的 tick_sn
                     total minutes count = 現在時間-上一次query時間的 minutes count
                     */
                    //NSUInteger minutesSinceMidnight = [self computeMinutesSinceMidnight];
                    NSUInteger tickSNDivideRatio;
                    if (snapshot.timeOfLastTick-marketOpenTime==0) {
                        tickSNDivideRatio =1;
                    }else{
                        tickSNDivideRatio =snapshot.sequenceOfTick/(snapshot.timeOfLastTick-marketOpenTime);// 1;
                    }
                    
                    
                    if (tickSNDivideRatio <= 1) {
//                        [[[UIAlertView alloc] initWithTitle:@"tickSNDivideRatio = 0" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//                        assert(tickSNDivideRatio > 0);
                        tickSNDivideRatio = 1;
                    }
                    
                    
                    
                    
//                    NSUInteger tickSNDivideRatio =1;

                    //                    if (marketOpenTime < minutesSinceMidnight && minutesSinceMidnight < marketCloseTime) {
                    //                        double totalTickCounts = (snapshot.sequenceOfTick - tickObj.lastExistNo);
                    //                        double totalMinuteCounts = minutesSinceMidnight-(lastTickMinuteCounts+marketOpenTime);
                    //                        if (totalMinuteCounts!=0 && totalTickCounts!=0) {
                    //                            tickSNDivideRatio = totalTickCounts/totalMinuteCounts*5;
                    //                        }
                    //                    }
                    //                    else {
                    //                        double totalTickCounts = (snapshot.sequenceOfTick - tickObj.lastExistNo);
                    //                        double totalMinuteCounts = marketCloseTime-marketOpenTime;
                    //                        if (totalMinuteCounts!=0 && totalTickCounts!=0) {
                    //                            tickSNDivideRatio = totalTickCounts/totalMinuteCounts*5;
                    //                        }
                    //                    }
                    //                    if (minutesSinceMidnight > marketOpenTime && (snapshot.sequenceOfTick > minutesSinceMidnight - marketOpenTime) ) {
                    //                        tickSNDivideRatio = snapshot.sequenceOfTick / (minutesSinceMidnight - marketOpenTime);
                    //                        tickSNDivideRatio *= 5;
                    //                    }
                    
                    //                    if (tickSNDivideRatio == 0) return;
                    
                    DiscreteTickOut *packet = [[DiscreteTickOut alloc] initWithCommodityNum:[securityKey unsignedIntValue] beginSN:(tickObj.firstBreakNo + 1) endSN:snapshot.sequenceOfTick tickSnDivideRatio:tickSNDivideRatio];
                    [FSDataModelProc sendData:self WithPacket:packet];
                }
            }
        }
    }
}

- (NSUInteger)computeMinutesSinceMidnight
{
    NSDate *today = [NSDate date];
    
    // Get the year, month, day from the date
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
    
    // Set the hour, minute, second to be zero
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    // Create today's midnight time
    NSDate *midnight = [[NSCalendar currentCalendar] dateFromComponents:components];
    NSTimeInterval interval = [today timeIntervalSinceDate:midnight];
    NSUInteger minutesSinceMidnight = interval/60;
    return minutesSinceMidnight;
}

- (void)sendGetHistoricTick		//當加入走勢比較 commodity num還沒回來 之後用的
{
	[lockPortfolioTick lock];
	NSArray *allIdentSymbol = [mustGetHistoricDict allKeys];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	for(NSString *identSymbol in allIdentSymbol)
	{
		Portfolio *portf = dataModal.portfolioData;
		PortfolioItem *portItem = [portf findItemByIdentCodeSymbol:identSymbol];
		if(portItem && portItem->commodityNo)
		{
			NSObject <HistoricDataArriveProtocol> *target = [mustGetHistoricDict objectForKey:identSymbol];
			if(target == nil)
				continue;
			NSNumber *securityKey = [[NSNumber alloc] initWithUnsignedInt:portItem->commodityNo];
			[notifyKeeper addKey:securityKey Entity:target];
			
			// Add to the cached list.
			[self addEquity:identSymbol WithSecurityNo:portItem->commodityNo];
			
			// Get the corresponding object of historic data
			NSNumber *objKey = [mapLabelToSecurityNo objectForKey:identSymbol];
			EquityHistory *commObj = [equityTicks objectForKey:objKey];
			
			// Ask it to load data from stored files, if any.
			//[commObj loadWithIdentCodeSymbol:identCodeSymbol commodityType:portItem->type_id];
			[commObj loadFromFile:portItem->type_id];
			
			// Load data from file if any.
			NSDate *upToDate = nil;
			NSCalendar *calendar = [NSCalendar currentCalendar];
			NSDate *today = [NSDate date];
			// Get last date from the file.
			UInt16 lastDate = [commObj quertyDataDate:historicType];
            
            
            if  (historicType == 'W' || historicType == 'M'){
                if ([commObj loadWithTickType:'D']) {
                    UInt16 dLastDate = [commObj quertyDataDate:'D'];
                    NSDate * dUpToDate = nil;
                    if (dLastDate)
                    {
                        // Convert returned date to NSDate.
                        UInt16 year;
                        UInt8 month;
                        UInt8 day;
                        [CodingUtil getDate:dLastDate year:&year month:&month day:&day];
                        NSDateComponents *comps = [[NSDateComponents alloc] init];
                        [comps setYear:year];
                        [comps setMonth:month];
                        [comps setDay:day];
                        dUpToDate = [calendar dateFromComponents:comps];
                    }
                    if (dUpToDate)
                    {
                        NSDate *requestDate;
                        // Some data already in file. Notify the target.
                        //[target performSelector:@selector(notifyDataArrive:) withObject:commObj afterDelay:0];
                        //		[target performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:commObj waitUntilDone:NO];
                        
                        // find the next date
                        NSDateComponents *comps = [[NSDateComponents alloc] init];
                        [comps setDay:1];
                        requestDate = [calendar dateByAddingComponents:comps toDate:today options:0];
                        
                        //if (![today isEqualToDate:upToDate])
                        if (!([CodingUtil makeDateFromDate:dUpToDate] == [CodingUtil makeDateFromDate:today]))
                        {
                            [commObj setLatestData:'D' value:NO];
                            // Request more data from server.
                            //HistoricalPriceOut *packet = [[HistoricalPriceOut alloc] initWithQueryStartDate:[CodingUtil makeDateFromDate:requestDate] EndDate:[CodingUtil makeDateFromDate:today] Commodity:[objKey unsignedIntValue] Type:ttp CommodityType:portItem->type_id];
                            
                            NewHistoricalPriceOut *packet = [[NewHistoricalPriceOut alloc]initWithSecurityNumber:[objKey unsignedIntValue] dataType:'D' commodityType:portItem->type_id startDate:[CodingUtil makeDateFromDate:dUpToDate] endDate:[CodingUtil makeDateFromDate:requestDate]];
                            
                            [FSDataModelProc sendData:self WithPacket:packet];
                            
                        }
                    }
                    
                }else{
                    [commObj setLatestData:historicType value:NO];
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDate *today = [NSDate date];
                    NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
                    int year = (int)[comps year];
                    int month = (int)[comps month];
                    int day = (int)[comps day];
                    
                    year -=3;
                    
                    NewHistoricalPriceOut *packet = [[NewHistoricalPriceOut alloc]initWithSecurityNumber:[objKey unsignedIntValue] dataType:'D' commodityType:portItem->type_id startDate:[CodingUtil makeDate:year month:month day:day] endDate:[CodingUtil makeDateFromDate:today]];
                    
                    [FSDataModelProc sendData:self WithPacket:packet];
                }
            }
			
			if (lastDate)
			{
				// Convert returned date to NSDate.
				UInt16 year;
				UInt8 month;
				UInt8 day;
				[CodingUtil getDate:lastDate year:&year month:&month day:&day];
				NSDateComponents *comps = [[NSDateComponents alloc] init];
				[comps setYear:year];
				[comps setMonth:month];
				[comps setDay:day];
				upToDate = [calendar dateFromComponents:comps];
			}
			
			if (upToDate)
			{
				NSDate *requestDate;
				// Some data already in file. Notify the target.
				[target performSelector:@selector(notifyDataArrive:) withObject:commObj afterDelay:0];
				//		[target performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:commObj waitUntilDone:NO];
				
				// find the next date
				NSDateComponents *comps = [[NSDateComponents alloc] init];
				[comps setDay:1];
				requestDate = [calendar dateByAddingComponents:comps toDate:today options:0];
				
				//if (![today isEqualToDate:upToDate])
				if (!([CodingUtil makeDateFromDate:upToDate] == [CodingUtil makeDateFromDate:requestDate]))
				{
					[commObj setLatestData:historicType value:NO];
					// Request more data from server.
                    //					HistoricalPriceOut *packet = [[HistoricalPriceOut alloc] initWithQueryStartDate:[CodingUtil makeDateFromDate:requestDate] EndDate:[CodingUtil makeDateFromDate:today] Commodity:[objKey unsignedIntValue] Type:historicType CommodityType:portItem->type_id];
                    
                    NewHistoricalPriceOut *packet = [[NewHistoricalPriceOut alloc]initWithSecurityNumber:[objKey unsignedIntValue] dataType:historicType commodityType:portItem->type_id startDate:[CodingUtil makeDateFromDate:upToDate] endDate:[CodingUtil makeDateFromDate:requestDate]];
					
					//identSymbol
                    [FSDataModelProc sendData:self WithPacket:packet];
					
				}
				else
					[commObj setLatestData:historicType value:YES];
				//		[requestDate release];
			}
			else
			{
				[commObj setLatestData:historicType value:NO];
				// Ask whole date from the server.
				NSInteger countEqities;// = MaximumHistoricWeeks;		// Same as MaximumHistoricMonths.
				if (historicType == kTickType5Minute)
                    countEqities = MaximumHistoric5Minutes;
                else if (historicType == kTickTypeDay)
                    countEqities = MaximumHistoricDays;
                else if (historicType == kTickTypeWeek)
                    countEqities = MaximumHistoricWeeks;
                else if (historicType == kTickTypeMonth)
                    countEqities = MaximumHistoricMonths;
				//HistoricalPriceOut *packet = [[HistoricalPriceOut alloc] initWithQueryCounts:(UInt8)countEqities Commodity:[objKey unsignedIntValue] Type:historicType CommodityType:portItem->type_id];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDate *today = [NSDate date];
                NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
                int year = (int)[comps year];
                int month = (int)[comps month];
                int day = (int)[comps day];
                
                if (historicType == kTickType5Minute)
                    if (month>1) {
                        month -=1;
                    }else{
                        year-=1;
                        month=12;
                    }
                //                    day -=1;
                    else if (historicType == kTickTypeDay)
                        year -=3;
                    else if (historicType == kTickTypeWeek)
                        year -=5;
                    else if (historicType == kTickTypeMonth)
                        year -=10;
                
                NewHistoricalPriceOut *packet = [[NewHistoricalPriceOut alloc]initWithSecurityNumber:[objKey unsignedIntValue] dataType:historicType commodityType:portItem->type_id startDate:[CodingUtil makeDate:year month:month day:day] endDate:[CodingUtil makeDateFromDate:today]];
                
                //                NewHistoricalPriceOut * packet = [[NewHistoricalPriceOut alloc]initWithSecurityNumber:[objKey unsignedIntValue] dataType:portItem->type_id commodityType:historicType count:(UInt16)countEqities];
				
                [FSDataModelProc sendData:self WithPacket:packet];
				
			}
			
			[mustGetHistoricDict removeObjectForKey:identSymbol];
		}
	}
	[lockPortfolioTick unlock];
}

- (void)addPromptTick:(NSArray *)tickParams
{
	[lockPortfolioTick lock];
    
	/**
     Tell the addTick to include targets watching for 'PortfolioAll" while notifying.
	 */
	includeWatchAll = TRUE;
	[self addTick:tickParams];
	includeWatchAll = FALSE;
	
	// Notify alarm data to check if a notification should be fired.
	NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:2];
	EquityTickParam *tick = [tickParams lastObject];
	NSNumber *commodityNo = [[NSNumber alloc] initWithUnsignedInt:tick->securityNO];
	
	EquityTick *obj = [equityTicks objectForKey:commodityNo];
    
	// Pass ticks to alert object only if equity ticks of the commodityNo exist.
	if (obj)
	{
		[param addObject:commodityNo];
		[param addObject:obj];
		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
		[dataModal.alert performSelector:@selector(alertNotify:) onThread:dataModal.thread withObject:param waitUntilDone:NO];
	}
    
	[lockPortfolioTick unlock];
}

- (void)addNearestBidAsk:(MessageType03 *)baParams
{
	EquityTick *tickObj;
	if (type != kTickTypeEquity)
		return;
	
	[lockPortfolioTick lock];
    
	// Find the EquityTick for the coming tick.
	NSNumber *ticksKey = [[NSNumber alloc] initWithUnsignedInt:baParams.securityNO];
	tickObj = [equityTicks objectForKey:ticksKey];
    
	if (tickObj)
	{
		[tickObj.snapshot updateWithNearestBidAsk: baParams.BAArray];
		
		// Check if notification is needed.
		[notifyKeeper notifyTarget:ticksKey WithEquityDictionary:equityTicks IncludeAll:NO];
	}
	
    
	[lockPortfolioTick unlock];
}

@end
