//
//  HistoricDataAgent.m
//  Bullseye
//
//  Created by Ray Kuo on 2008/12/25.
//  Copyright 2008 TelePaq Inc. All rights reserved.
//

#import "HistoricDataAgent.h"
#import "EquityHistory.h"
#import "HistoricDataTypes.h"

static NSCalendar *gCalendar;
@interface HistoricDataAgent(){
    NSRecursiveLock *dataLock;
}
@end

@implementation HistoricDataAgent{
    NSMutableDictionary * seqNoDic;

}


@synthesize dataArray;


-(id)init{
    self = [super init];
    if (self) {
        dataLock = [[NSRecursiveLock alloc]init];
        seqNoDic = [[NSMutableDictionary alloc]init];
        self.dataArray = [[NSMutableArray alloc]init];
    
    }
    return self;
}


+ (void)initialize {

    if (self == [HistoricDataAgent class])
        gCalendar = [ValueUtil sharedGregorianCalendar];
}


+ (UInt8)tickTypeForAnalysisPeriod:(AnalysisPeriod)period {

    switch (period) {
        case AnalysisPeriodDay: return kTickTypeDay;
        case AnalysisPeriodWeek: return kTickTypeWeek;
        case AnalysisPeriodMonth: return kTickTypeMonth;
        case AnalysisPeriod5Minute: return kTickType5Minute;
        case AnalysisPeriod15Minute: return kTickType15Minute;
        case AnalysisPeriod30Minute: return kTickType30Minute;
        case AnalysisPeriod60Minute: return kTickType60Minute;
        default: return 0;
    }
}


+ (NSComparisonResult)compareDate:(UInt16)date1 with:(UInt16)date2 forPeriod:(AnalysisPeriod)period {

    if (date1 == date2)
        return 0;

    switch (period) {
        case AnalysisPeriodWeek: {
            NSDate *d1, *d2;
            [gCalendar rangeOfUnit:NSWeekCalendarUnit startDate:&d1 interval:NULL forDate:[ValueUtil nsDateFromStkDate:date1]];
            [gCalendar rangeOfUnit:NSWeekCalendarUnit startDate:&d2 interval:NULL forDate:[ValueUtil nsDateFromStkDate:date2]];
            if ([d1 isEqualToDate:d2])
                return 0;
            break;
        }

        case AnalysisPeriodMonth:
            if ((date1>>5) == (date2>>5))
                return 0;
            break;
        case AnalysisPeriodDay:
        case AnalysisPeriod15Minute:
        case AnalysisPeriod30Minute:
        case AnalysisPeriod5Minute:
        case AnalysisPeriod60Minute:
            break;
    }

    return date1 > date2 ? 1 : -1;
}


- (NSString *)getIdenCodeSymbol {
    return nil;
}


- (UInt32)tickCount:(UInt8)tickType {

    return (int)dataArray.count;
}

- (id)getHistoricTickWithIndex:(int)index{
	
	return [dataArray objectAtIndex:index];
}

- (UInt32)historicTickCountFromStartDate:(UInt16)startDate toEndDate:(UInt16)endDate{
	
	// 由近期開始找介於 startDate 到 endDate 之間的資料數
	int intervalDayCount = 0;
	
	
	int count = (int)dataArray.count;
	
	for(int i = count-1 ; i>=0; i--){
		
		DecompressedHistoricData *historic = [dataArray objectAtIndex:i];
		
		if(historic.date <= startDate && historic.date >= endDate)
			intervalDayCount++;
		
	}
	
	return intervalDayCount;
	
}

- (float)getTheHightestValueFromStartIndex:(NSInteger)startIndex toEndIndex:(NSInteger)endIndex
{
	//由近期開始找介於 startDate 到 endDate 取區間資料最高價
	float maxNumber = 0;
	
	
	//int count = dataArray.count;
		
	for(NSUInteger i=startIndex ; i<endIndex+1; i++)
	{
		
		DecompressedHistoricData *historic = [dataArray objectAtIndex:i];
		
		if (maxNumber < historic.high)
            maxNumber = historic.high;
	}
	
	return maxNumber;
	
	
}

- (float)getTheLowestValueFromStartIndex:(NSInteger)startIndex toEndIndex:(NSInteger)endIndex
{
	
	//由近期開始找介於 startDate 到 endDate 取區間資料最低價
	float minNumber = 0;
	//int count = dataArray.count;

	
	for(NSUInteger i=startIndex ; i<endIndex+1; i++)
	{
        DecompressedHistoricData *historic = [[DecompressedHistoricData alloc]init];
        historic = [dataArray objectAtIndex:i];
		
        if (minNumber > historic.low || minNumber == 0){
            minNumber = historic.low;
        }
		
	}
	
	return minNumber;	
	
}

- (float)getTheChangeValueFromStartDate:(UInt16)startDate toEndDate:(UInt16)endDate {
	
	// 由近期開始找介於 startDate 到 endDate 區間資料的 change
	float startPrice = 0;
	float endPrice = 0;
	
	//從陣列後面找最近的price for endDate
	int count = (int)dataArray.count;
	for(int i = 0 ; i<count; i++){
		
		DecompressedHistoricData *historic = [dataArray objectAtIndex:i];
		
		if(historic.date >= endDate){
			
			endPrice = historic.close;
			break;
			
		}
		
		
	}
	
	
	//從陣列後面找最近的price for endDate
	for(int i = count-1 ; i>=0; i--){
		
		DecompressedHistoricData *historic = [dataArray objectAtIndex:i];
		
		if(historic.date <= startDate){
			
			startPrice = historic.close;
			break;
			
		}
	}
	
	float change = startPrice - endPrice;
	
	return change;
	
}

- (id)getHistoricTickFromStartDate:(UInt16)startDate toEndDate:(UInt16)endDate withIndex:(int)index {
	
	//取得區間日期 以區間為範圍的第index筆資料
	DecompressedHistoricData *historic;
	
	int count = (int)dataArray.count;
	int tmpIndex = -1;
	for(int i = 0 ; i<count; i++){
		
		historic = [dataArray objectAtIndex:i];
		
		if(historic.date >= endDate && historic.date <= startDate)
		{
			
			tmpIndex++;
			
			if(tmpIndex == index)			
				break;
		}
		
	}
	
	return historic;
}

- (id)copyHistoricTick:(UInt8)tickType sequenceNo:(UInt32)sequenceNo 
{
	if(sequenceNo >= [dataArray count])
		return NULL;

    return [dataArray objectAtIndex:sequenceNo];
}


-(id)copyHistoricTick:(UInt8)tickType Date:(UInt16)date{
	[dataLock lock];
    UInt32 seq = [(NSNumber *)[seqNoDic objectForKey:[NSNumber numberWithUnsignedInt:date]]intValue];
    
    [dataLock unlock];
    return [self copyHistoricTick:tickType sequenceNo:seq];
}


- (void)updateHistoricItem:(DecompressedHistoricData *)item withPrevious:(DecompressedHistoricData *)prevItem {

    item.open = prevItem.open;

    if (item.high < prevItem.high)
        item.high = prevItem.high;

    if (item.low > prevItem.low)
        item.low = prevItem.low;

    if (prevItem.volume != 0) {

        if (item.volumeUnit > prevItem.volumeUnit) {
            item.volume *= valueUnitBase[item.volumeUnit - prevItem.volumeUnit];
            item.volumeUnit = prevItem.volumeUnit;
        }
        else if (prevItem.volumeUnit > item.volumeUnit) {
            prevItem.volume *= valueUnitBase[prevItem.volumeUnit - item.volumeUnit];
        }
        if(item.date != prevItem.date){
            item.volume += prevItem.volume;

        }
    }
}


- (DecompressedHistoricData *)createTodayItem:(PortfolioItem *)portfolioItem {

    if (portfolioItem == nil) return nil;

    DecompressedHistoricData *item = [[DecompressedHistoricData alloc] init];

    
#ifdef LPCB
    FSSnapshot *snapshot = [[[FSDataModelProc sharedInstance]portfolioTickBank] getSnapshotBvalue:portfolioItem->commodityNo];
    
    double close = snapshot.last_price.calcValue;
    if (close == 0) return nil;
    
    item.date = [snapshot.trading_date date16];
    item.open = snapshot.open_price.calcValue;
    item.high = snapshot.high_price.calcValue;
    item.low = snapshot.low_price.calcValue;
    item.close = close;
    item.volume = snapshot.accumulated_volume.calcValue;
    item.volumeUnit = 0;
#else
    EquitySnapshotDecompressed *snapshot = [[[FSDataModelProc sharedInstance]portfolioTickBank] getSnapshot:portfolioItem->commodityNo];
    
    double close = snapshot.currentPrice;
    if (close == 0) return nil;
    
    item.date = snapshot.date;
    item.open = snapshot.openPrice;
    item.high = snapshot.highestPrice;
    item.low = snapshot.lowestPrice;
    item.close = close;
    item.volume = snapshot.accumulatedVolume;
    item.volumeUnit = snapshot.accumulatedVolumeUnit;
#endif
    
    return item;
}


- (void)appendDailyRecentItemTo:(NSMutableArray *)itemArray portfolioItem:(PortfolioItem *)portfolioItem {

    DecompressedHistoricData *todayItem = [self createTodayItem:portfolioItem];

    if (todayItem.date > ((DecompressedHistoricData *)itemArray.lastObject).date){
        [seqNoDic setObject:[NSNumber numberWithInteger:[itemArray count]] forKey:[NSNumber numberWithUnsignedInt:todayItem.date]];
        [itemArray addObject:todayItem];
        
    }
    

}


- (void)appendWeeklyRecentItemTo:(NSMutableArray *)itemArray withSource:(id<HistoricTickDataSourceProtocol>)dataSource portfolioItem:(PortfolioItem *)portfolioItem {

    DecompressedHistoricData *recentItem = nil;
    UInt16 lastDate = ((DecompressedHistoricData *)itemArray.lastObject).date;

    DecompressedHistoricData *todayItem = [self createTodayItem:portfolioItem];

    if (todayItem.date > lastDate)
        recentItem = todayItem;

    int dailyCount = [dataSource tickCount:kTickTypeDay];

    if (dailyCount > 0) {

        int index = dailyCount - 1;
        DecompressedHistoricData *item;

        if (recentItem == nil) {

            item = [dataSource copyHistoricTick:kTickTypeDay sequenceNo:index];

            if (item.date > lastDate) {
                recentItem = item;
                index--;
            }
        }

        if (recentItem != nil) {

            NSDate *recentDate = [ValueUtil nsDateFromStkDate:recentItem.date];
            NSDate *startDate = nil;
            [gCalendar rangeOfUnit:NSWeekCalendarUnit startDate:&startDate interval:NULL forDate:recentDate];

            UInt16 weekDate = [ValueUtil stkDateFromNSDate:startDate];

            for ( ; index >= 0; index--) {

                item = [dataSource copyHistoricTick:kTickTypeDay sequenceNo:index];

                if (item.date >= weekDate && item.date > lastDate ) {

                    [self updateHistoricItem:recentItem withPrevious:item];
                }
                else {
                    break;
                }
            }
        }
    }
    
    if (recentItem != nil) {
        
        [itemArray addObject:recentItem];
    }
}


- (void)appendMonthlyRecentItemTo:(NSMutableArray *)itemArray withSource:(id<HistoricTickDataSourceProtocol>)dataSource portfolioItem:(PortfolioItem *)portfolioItem {

    DecompressedHistoricData *recentItem = nil;
    UInt16 lastMonth = ((DecompressedHistoricData *)itemArray.lastObject).date >> 5;

    DecompressedHistoricData *todayItem = [self createTodayItem:portfolioItem];

    if ((todayItem.date >> 5) > lastMonth)
        recentItem = todayItem;

    int dailyCount = [dataSource tickCount:kTickTypeDay];

    if (dailyCount > 0) {

        int index = dailyCount - 1;
        DecompressedHistoricData *item;

        if (recentItem == nil) {

            item = [dataSource copyHistoricTick:kTickTypeDay sequenceNo:index];

            if ((item.date >> 5) > lastMonth) {
                recentItem = item;
                index--;
            }
        }

        if (recentItem != nil) {

            UInt16 month = recentItem.date >> 5;

            for ( ; index >= 0; index--) {

                item = [dataSource copyHistoricTick:kTickTypeDay sequenceNo:index];

                if ((item.date >> 5) != month) {
                    break;
                }

                [self updateHistoricItem:recentItem withPrevious:item];
            }
        }
    }

    if (recentItem != nil) {

        [itemArray addObject:recentItem];
    }
}


- (BOOL)updateData:(id<HistoricTickDataSourceProtocol>)dataSource forPeriod:(AnalysisPeriod)period portfolioItem:(PortfolioItem *)portfolioItem {
    
    [dataLock lock];
    
    NSMutableArray *tmpData = [[NSMutableArray alloc] init];

    UInt8 type = [HistoricDataAgent tickTypeForAnalysisPeriod:period];
    UInt32 count = [dataSource tickCount:type];
//    id historic;
//    if ([seqNoDic count]) {
//        [seqNoDic removeAllObjects];
    seqNoDic = [[NSMutableDictionary alloc]init];
//    }


    for (int i = 0; i < count; i++) {

        DecompressedHistoricData * historic = [dataSource copyHistoricTick:type sequenceNo:i];
        if (historic == nil) continue;
//        DecompressedHistoricData * newHistoric = historic;
        [seqNoDic setObject:[NSNumber numberWithInt:i] forKey:[NSNumber numberWithUnsignedInt:historic.date]];
//        [seqNoDic setObject:@(i) forKey:@(historic.date)];;
        [tmpData addObject:historic];
    }

    switch (period) {
        case AnalysisPeriodDay: [self appendDailyRecentItemTo:tmpData portfolioItem:portfolioItem]; break;
        case AnalysisPeriodWeek: [self appendWeeklyRecentItemTo:tmpData withSource:dataSource portfolioItem:portfolioItem]; break;
        case AnalysisPeriodMonth: [self appendMonthlyRecentItemTo:tmpData withSource:dataSource portfolioItem:portfolioItem]; break;
        case AnalysisPeriod5Minute:
        case AnalysisPeriod15Minute:
        case AnalysisPeriod30Minute:
        case AnalysisPeriod60Minute:{
//            EquityHistory *tmpData = (EquityHistory *)dataSource;
//            tmpData addObjectsFromArray:tmpData.todayOtherMK_finalize
//            todayOtherM
            break;
        }
    }

    if (tmpData.count > DateNumMax)
        [tmpData removeObjectsInRange:NSMakeRange(0, tmpData.count-DateNumMax)];

    if ([dataArray isEqualToArray:tmpData]) {
        [dataLock unlock];
        return NO;
    }

    self.dataArray = tmpData;
	switch (period) {
		case AnalysisPeriod15Minute:
		case AnalysisPeriod30Minute:
		case AnalysisPeriod60Minute:{
			EquityHistory *tmpDataSource = (EquityHistory *)dataSource;
			[tmpDataSource todayOtherMK_finalize];
			break;
        }
		default:
			break;
	}
    [dataLock unlock];
    return YES;
}



@end
