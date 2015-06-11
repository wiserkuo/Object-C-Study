//
//  FSPriceVolumeChartDataSource.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/11.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSPriceVolumeChartDataSource.h"
#import "TradeDistribute.h"
#import "TradeDistributeIn.h"
#import "Snapshot.h"
#import "EquityTick.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSDistributeIn.h"

static float E = 0.001;//精確度

@interface FSPriceVolumeChartDataSource (){

    NSString *identCodeSymbol;
    UInt16 newDate;
    NSRecursiveLock * dataLock;

}
@property (nonatomic, strong) NSMutableArray *tickPriceVolumeData;
@property (nonatomic, strong) NSMutableArray *groupPriceVolumeData;

#if LPCB
@property (strong, nonatomic) FSSnapshot *symbolSnapshot;
#else
@property (strong, nonatomic) EquitySnapshotDecompressed * symbolSnapshot;
#endif
@property (nonatomic, assign) BOOL isWatchingData;

@end

@implementation FSPriceVolumeChartDataSource

- (FSPriceVolumeChartDataSource *)init{
    if (self = [super init]) {
        self.singleDayData = [[NSMutableArray alloc] init];
        self.periodData = [[NSMutableArray alloc] init];
        self.tickPriceVolumeData = [[NSMutableArray alloc] init];
        self.groupPriceVolumeData = [[NSMutableArray alloc]init];
        self.singleDayIndex = 0;
        self.periodIndex = 0;
        self.singleDay = YES;
        self.periodDay = YES;
        dataLock = [[NSRecursiveLock alloc] init];
        



    }
    return self;
}

#pragma mark - Send request

- (void)sendSingleDayRequest:(NSUInteger) option
{

#ifdef LPCB
    [self findIdentCodeAndDate];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    self.singleDayIndex = option;
    NSInteger dayCount = [self getDayCount:0];
    [dataModal.tradeDistribute AskOneDayIdentCodeSymbol:identCodeSymbol number:dayCount date:(UInt16)newDate];
    
#else
    UInt16 d = _symbolSnapshot.date;
    self.singleDayIndex = option;
    if(option == 0)//今天
	{
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(setSingleDayDataMaxVolume:)])
        {
            double maxVol = 0.0;
            for (NSInteger index=0; index < [_groupPriceVolumeData count]; index++) {
                TradeDistributeParam* paramtemp = _groupPriceVolumeData[index];
                double newVol = [self getRealValue:paramtemp->volume Unit:[@(paramtemp->volumeUnit) integerValue]];
                if (newVol > maxVol) {
                    maxVol = newVol;
                }
            }
            self.priceVolumeViewController.singleDayDataMaxVolume = maxVol;
        }
		//重新畫圖
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(reloadGraph)])
        {
            [self.priceVolumeViewController reloadGraph];
        }
	}
	else// 前N天
	{
		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
		PortfolioItem *item = [dataModal.portfolioData findItemByIdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]];
        NSInteger dayCount = [self getDayCount:0];
		if(dayCount > 0) {
			[dataModal.tradeDistribute AskOneDaySecurityNum:item->commodityNo DayCount:dayCount BeforeDate:(UInt16)d];
        }
	}
#endif
}
- (void)sendPeriodRequest:(NSUInteger) option
{
    
#ifdef LPCB

    [self findIdentCodeAndDate];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    self.periodIndex = option;
    NSInteger dayCount = [self getDayCount:1];
	if(dayCount > 0) {
        [dataModal.tradeDistribute AskDaysIdentCodeSymbol:identCodeSymbol number:dayCount date:(UInt16)newDate];
    }
#else
    UInt16 d = _symbolSnapshot.date;
    self.periodIndex = option;
	NSInteger dayCount = [self getDayCount:1];
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	PortfolioItem *item = [dataModal.portfolioData findItemByIdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]];
	if(dayCount > 0) {
		[dataModal.tradeDistribute AskDaysSecurityNum:item->commodityNo DayCount:dayCount BeforeDate:(UInt16)d];
    }
#endif
}

- (BOOL)startWatch
{
    if (_portfolioItem != nil && _isWatchingData == NO) {
#ifdef LPCB
        [[[FSDataModelProc sharedInstance]portfolioTickBank] setTaget:self IdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]];
        [[[FSDataModelProc sharedInstance]portfolioTickBank] updateTickDataByIdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]];
#else
        [[[FSDataModelProc sharedInstance]portfolioTickBank] watchTarget:self ForEquity:[_portfolioItem getIdentCodeSymbol] GetTick:YES];
#endif
        
//        如果不是自選股就要加入watchlist
        if ([[[FSDataModelProc sharedInstance]portfolioData] findItemByIdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]] == nil) {
            [[[FSDataModelProc sharedInstance]portfolioData] addWatchListItemByIdentSymbolArray:@[[_portfolioItem getIdentCodeSymbol]]];
        };
        _isWatchingData = YES;
        return YES;
    }

    return NO;
}

- (void)stopWatch
{
    if (_isWatchingData) {
#ifdef LPCB
        [[[FSDataModelProc sharedInstance]portfolioTickBank] removeKeyWithTaget:self IdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]];
#else
        [[[FSDataModelProc sharedInstance]portfolioTickBank] stopWatch:self ForEquity:[_portfolioItem getIdentCodeSymbol]];
#endif
        
        if ([[[FSDataModelProc sharedInstance]portfolioData] findItemByIdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]] == nil) {
            [[[FSDataModelProc sharedInstance]portfolioData] removeWatchListItemByIdentSymbolArray];
        };

        _isWatchingData = NO;
    }
}

#pragma mark notifyDataArrive

- (void)notifyDataArrive:(NSObject <TickDataSourceProtocol> *) dataSource
{
   
    
#ifdef LPCB
    
    FSSnapshot *snapshot = ((EquityTick *) dataSource).snapshot_b;
    self.symbolSnapshot = snapshot;
    
    [dataSource lock];
    [_tickPriceVolumeData removeAllObjects];
    
    NSArray *ticksData = [dataSource ticksData];
	
    double oldVolume = 0;
    for (int tickCounter = 0;tickCounter < [ticksData count]; tickCounter++) {
		double tickPrice, tickVolume;
		
        FSTickData *tick = [ticksData objectAtIndex:tickCounter];
        tickPrice = tick.last.calcValue;
        tickVolume = tick.accumulated_volume.calcValue;

        if (oldVolume == tickVolume) {
			continue;
		}
		else if (oldVolume < tickVolume) {
			double temp = oldVolume;
			oldVolume = tickVolume;
			tickVolume -= temp;
		}
		else {
            continue;
//			oldVolume += tickVolume;
		}
		
		int count = (int)[_tickPriceVolumeData count];
		
        if(count == 0) {// 空的 直接塞
			TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
			paramtemp->price = tickPrice;
			paramtemp->volume = tickVolume;
			[_tickPriceVolumeData addObject:paramtemp];
			//break;
			continue;
		}
		else
		{
			for(int index=0; index<count; index++)
			{
				TradeDistributeParam* param = [_tickPriceVolumeData objectAtIndex:index];
				
				if(fabs(tickPrice-param->price)<E)
				{
					param->volume += tickVolume;
					break;
				}
				else if(tickPrice>param->price)
				{
					TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
					paramtemp->price = tickPrice;
					paramtemp->volume = tickVolume;
					[_tickPriceVolumeData insertObject:paramtemp atIndex:index];
					break;
				}
				
				if(index == count-1)
				{
					if(tickPrice<param->price)
					{
						TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
						paramtemp->price = tickPrice;
						paramtemp->volume = tickVolume;
						[_tickPriceVolumeData addObject:paramtemp];
						break;
					}
				}
			}
		}
    }
    [dataSource unlock];
    [self setDataToGroup];
    if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(firstInLoadPeriodRequest)])
    {
        [self.priceVolumeViewController firstInLoadPeriodRequest];
    }
    if (_singleDayIndex == 0) {
        //更新單日日期為今天
        
        NSString *todayDateString;
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            
            todayDateString = [snapshot.trading_date dateFormatToString:@"MM/dd/yyyy"];
        } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
            
            todayDateString = [snapshot.trading_date dateFormatToString:@"yyyy/MM/dd"];
        }else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyy/MM/dd"];
            NSDate * date = [snapshot.trading_date date];
            todayDateString = [dateFormatter stringFromDate:[date yearOffset:-1911]];
        }
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(updateSingleDateLabelText:)])
        {
            [self.priceVolumeViewController updateSingleDateLabelText:todayDateString];
        }
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(setSingleDayDataMaxVolume:)])
        {
            double maxVol = 0.0;
            for (NSInteger index=0; index < [_groupPriceVolumeData count]; index++) {
                TradeDistributeParam* paramtemp = _groupPriceVolumeData[index];
                double newVol = [self getRealValue:paramtemp->volume Unit:[@(paramtemp->volumeUnit) integerValue]];
                if (newVol > maxVol) {
                    maxVol = newVol;
                }
            }
            self.priceVolumeViewController.singleDayDataMaxVolume = MAX(maxVol, _priceVolumeViewController.singleDayDataMaxVolume);
        }
        //重新畫圖
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(reloadGraph)])
        {
            [self.priceVolumeViewController reloadGraph];
        }
    }
    
#else

    EquitySnapshotDecompressed *snapshot = ((EquityTick *) dataSource).snapshot;
    self.symbolSnapshot = snapshot;
    [_tickPriceVolumeData removeAllObjects];
    [dataSource lock];
    NSInteger tickCount = dataSource.tickCount;
	double oldVolume = 0;
    for (int tickCounter = 1; tickCounter <= tickCount; tickCounter++) 
    {
		double tickPrice,tmpVol;
		UInt16 tmpVolUnit;
		if(![dataSource getPriceVolume:&tickPrice Volume:&tmpVol VolUnit:&tmpVolUnit Sequence:tickCounter])
			continue;
		double volume = [self getRealValue:tmpVol Unit:tmpVolUnit];
        if(oldVolume == volume)
		{
			continue;
		}
		else if(oldVolume<volume)
		{
			double temp = oldVolume;
			oldVolume = volume;
			volume -= temp;
		}
		else
		{
			oldVolume += volume;
		}
		
		int count = [_tickPriceVolumeData count];
		if(count == 0) // 空的 直接塞
		{
			TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
			paramtemp->price = tickPrice;
			paramtemp->volume = volume;
			[_tickPriceVolumeData addObject:paramtemp];
			//break;
			continue;
		}
		else
		{
			for(int index=0; index<count; index++)
			{
				TradeDistributeParam* param = [_tickPriceVolumeData objectAtIndex:index];
				
				if(fabs(tickPrice-param->price)<E)
				{
					param->volume += volume;
					break;
				}
				else if(tickPrice>param->price)
				{
					TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
					paramtemp->price = tickPrice;
					paramtemp->volume = volume;
					[_tickPriceVolumeData insertObject:paramtemp atIndex:index];
					break;
				}
				
				if(index == count-1)
				{
					if(tickPrice<param->price)
					{
						TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
						paramtemp->price = tickPrice;
						paramtemp->volume = volume;
						[_tickPriceVolumeData addObject:paramtemp];
						break;
					}
				}
			}
		}
    }
    [dataSource unlock];
    [self setDataToGroup];
    if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(firstInLoadPeriodRequest)])
    {
        [self.priceVolumeViewController firstInLoadPeriodRequest];
    }
    if (_singleDayIndex == 0) {
        //更新單日日期為今天
        NSDate *today = [[NSNumber numberWithUnsignedInt:_symbolSnapshot.date]uint16ToDate];
        NSString *todayDateString;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS ) {
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            todayDateString = [dateFormatter stringFromDate:today];
        } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            todayDateString = [dateFormatter stringFromDate:today];
        }else{
            [dateFormatter setDateFormat:@"yyy/MM/dd"];
            todayDateString = [dateFormatter stringFromDate:[today yearOffset:-1911]];
        }
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(updateSingleDateLabelText:)])
        {
            [self.priceVolumeViewController updateSingleDateLabelText:todayDateString];
        }
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(setSingleDayDataMaxVolume:)])
        {
            double maxVol = 0.0;
            for (NSInteger index=0; index < [_groupPriceVolumeData count]; index++) {
                TradeDistributeParam* paramtemp = _groupPriceVolumeData[index];
                double newVol = [self getRealValue:paramtemp->volume Unit:[@(paramtemp->volumeUnit) integerValue]];
                if (newVol > maxVol) {
                    maxVol = newVol;
                }
            }
            self.priceVolumeViewController.singleDayDataMaxVolume = maxVol;
        }
        //重新畫圖
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(reloadGraph)])
        {
            [self.priceVolumeViewController reloadGraph];
        }
    }
#endif
}

-(void)setTodayDefaultData:(NSMutableArray *)array{
    PortfolioItem * portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    FSSnapshot * snapshot = [dataModal.portfolioTickBank getSnapshotBvalue:portfolioItem->commodityNo];
    
    self.symbolSnapshot = snapshot;
    
    [_tickPriceVolumeData removeAllObjects];
    
    NSArray *ticksData = array;
    
    double oldVolume = 0;
    for (int tickCounter = 0;tickCounter < [ticksData count]; tickCounter++) {
        double tickPrice, tickVolume;
        
        FSTickData *tick = [ticksData objectAtIndex:tickCounter];
        tickPrice = tick.last.calcValue;
        tickVolume = tick.accumulated_volume.calcValue;
        
        if (oldVolume == tickVolume) {
            continue;
        }
        else if (oldVolume < tickVolume) {
            double temp = oldVolume;
            oldVolume = tickVolume;
            tickVolume -= temp;
        }
        else {
            continue;
            //			oldVolume += tickVolume;
        }
        
        int count = (int)[_tickPriceVolumeData count];
        
        if(count == 0) {// 空的 直接塞
            TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
            paramtemp->price = tickPrice;
            paramtemp->volume = tickVolume;
            [_tickPriceVolumeData addObject:paramtemp];
            //break;
            continue;
        }
        else
        {
            for(int index=0; index<count; index++)
            {
                TradeDistributeParam* param = [_tickPriceVolumeData objectAtIndex:index];
                
                if(fabs(tickPrice-param->price)<E)
                {
                    param->volume += tickVolume;
                    break;
                }
                else if(tickPrice>param->price)
                {
                    TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                    paramtemp->price = tickPrice;
                    paramtemp->volume = tickVolume;
                    [_tickPriceVolumeData insertObject:paramtemp atIndex:index];
                    break;
                }
                
                if(index == count-1)
                {
                    if(tickPrice<param->price)
                    {
                        TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                        paramtemp->price = tickPrice;
                        paramtemp->volume = tickVolume;
                        [_tickPriceVolumeData addObject:paramtemp];
                        break;
                    }
                }
            }
        }
    }
    [self setDataToGroup];
    if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(firstInLoadPeriodRequest)])
    {
        [self.priceVolumeViewController firstInLoadPeriodRequest];
    }
    if (_singleDayIndex == 0) {
        //更新單日日期為今天
        
        NSString *todayDateString;
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            todayDateString = [snapshot.trading_date dateFormatToString:@"MM/dd/yyyy"];
            
        } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
            todayDateString = [snapshot.trading_date dateFormatToString:@"yyyy/MM/dd"];
        }else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyy/MM/dd"];
            NSDate * date = [snapshot.trading_date date];
            todayDateString = [dateFormatter stringFromDate:[date yearOffset:-1911]];
        }
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(updateSingleDateLabelText:)])
        {
            [self.priceVolumeViewController updateSingleDateLabelText:todayDateString];
        }
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(setSingleDayDataMaxVolume:)])
        {
            double maxVol = 0.0;
            for (NSInteger index=0; index < [_groupPriceVolumeData count]; index++) {
                TradeDistributeParam* paramtemp = _groupPriceVolumeData[index];
                double newVol = [self getRealValue:paramtemp->volume Unit:[@(paramtemp->volumeUnit) integerValue]];
                if (newVol > maxVol) {
                    maxVol = newVol;
                }
            }
            self.priceVolumeViewController.singleDayDataMaxVolume = maxVol;
        }
        //重新畫圖
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(reloadGraph)])
        {
            [self.priceVolumeViewController reloadGraph];
        }
    }
}

-(void)setDataToGroup{
#ifdef LPCB
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    
    [_groupPriceVolumeData removeAllObjects];
    //分50組,如小於0.01則為0.01
    float priceBlock;// = (maxHigh-minLow)/6;
    
    if ([group isEqualToString:@"us"]) {
        priceBlock =  (_symbolSnapshot.high_price.calcValue-_symbolSnapshot.low_price.calcValue)/50;
        if (priceBlock<0.01) {
            priceBlock = 0.01;
        }
        
        double highPrice = _symbolSnapshot.high_price.calcValue;
        double lowPrice = _symbolSnapshot.high_price.calcValue - priceBlock;
        double totalVol = 0;
        double lowPriceVol = 0;
        //    double lowPriceTotal = 0;
        
        if ([_tickPriceVolumeData count]>0) {
            for (int i=0; i<[_tickPriceVolumeData count]; i++) {
                TradeDistributeParam* paramtemp = (TradeDistributeParam*)[_tickPriceVolumeData objectAtIndex:i];
                if(lowPrice == _symbolSnapshot.low_price.calcValue){
                    if (paramtemp->price >= lowPrice && paramtemp->price <= highPrice) {
                        
                        lowPriceVol = paramtemp->volume;
                    }
                }else{
                    if (paramtemp->price > lowPrice && paramtemp->price <= highPrice) {
                        totalVol += paramtemp->volume;
                    }else{
                        TradeDistributeParam * groupData = [[TradeDistributeParam alloc] init];
                        groupData->price = highPrice;
                        groupData->volume = totalVol;
                        [_groupPriceVolumeData addObject:groupData];
                        highPrice = lowPrice;
                        lowPrice = lowPrice-priceBlock;
                        
                        if (paramtemp->price > lowPrice && paramtemp->price <= highPrice) {
                            totalVol = paramtemp->volume;
                            
                        }else{
                            
                            for (int j=0;j<50; j++) {
                                if (paramtemp->price > lowPrice && paramtemp->price <= highPrice) {
                                    totalVol = paramtemp->volume;
                                    break;
                                }else{
                                    TradeDistributeParam * groupData = [[TradeDistributeParam alloc] init];
                                    groupData->price = highPrice;
                                    groupData->volume = 0;
                                    [_groupPriceVolumeData addObject:groupData];
                                    highPrice = lowPrice;
                                    lowPrice = lowPrice-priceBlock;
                                }
                            }
                        }
                    }
                }
            }
            TradeDistributeParam * groupData = [[TradeDistributeParam alloc] init];
            //    groupData->price = [NSString stringWithFormat:@"%.2f~%.2f",lowPrice,highPrice];
            groupData->price = highPrice;
            groupData->volume = totalVol;
            [_groupPriceVolumeData addObject:groupData];
            
            TradeDistributeParam * groupData2 = [[TradeDistributeParam alloc] init];
            //                    groupData->price = [NSString stringWithFormat:@"%.2f~%.2f",lowPrice,highPrice];
            groupData2->price = lowPrice;
            groupData2->volume = lowPriceVol;
            [_groupPriceVolumeData addObject:groupData2];
            
            //        TradeDistributeParam * lowGroupData = [[TradeDistributeParam alloc] init];
            //        //    groupData->price = [NSString stringWithFormat:@"%.2f~%.2f",lowPrice,highPrice];
            //        lowGroupData->price = _symbolSnapshot.lowestPrice;
            //        lowGroupData->volume = lowPriceTotal;
            //        [_groupPriceVolumeData addObject:lowGroupData];
        }

        
    }else{
//        if (_symbolSnapshot.reference_price.calcValue >= 1000) {
//            priceBlock = 5;
//        }else if (_symbolSnapshot.reference_price.calcValue>=100){
//            priceBlock = 0.5;
//        }else if (_symbolSnapshot.reference_price.calcValue>=50){
//            priceBlock = 0.1;
//        }else if (_symbolSnapshot.reference_price.calcValue>=10){
//            priceBlock = 0.05;
//        }else{
//            priceBlock = 0.01;
//        }
        
        
        [_groupPriceVolumeData removeAllObjects];
        if ([_tickPriceVolumeData count]>0) {
            for (int j=0; j<[_tickPriceVolumeData count]; j++) {
                TradeDistributeParam* paramtemp = (TradeDistributeParam*)[_tickPriceVolumeData objectAtIndex:j];
                [_groupPriceVolumeData addObject:paramtemp];
            }
        }
    }

    
#else
    [_groupPriceVolumeData removeAllObjects];
    PortfolioItem * p = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    if (p->identCode[0] == 'T' && p->identCode[1]=='W') {
        
        if ([_tickPriceVolumeData count]>0) {
            for (int j=0; j<[_tickPriceVolumeData count]; j++) {
                TradeDistributeParam* paramtemp = (TradeDistributeParam*)[_tickPriceVolumeData objectAtIndex:j];
                [_groupPriceVolumeData addObject:paramtemp];
            }
        }
        
    }else{
        //分50組,如小於0.01則為0.01
        
        float priceBlock;// = (maxHigh-minLow)/6;
        
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"us"]) {
            priceBlock =  (_symbolSnapshot.highestPrice-_symbolSnapshot.lowestPrice)/50;
            if (priceBlock<0.01) {
                priceBlock = 0.01;
            }
        }else{
            if (_symbolSnapshot.referencePrice >= 1000) {
                priceBlock = 5;
            }else if (_symbolSnapshot.referencePrice>=100){
                priceBlock = 0.5;
            }else if (_symbolSnapshot.referencePrice>=50){
                priceBlock = 0.1;
            }else if (_symbolSnapshot.referencePrice>=10){
                priceBlock = 0.05;
            }else{
                priceBlock = 0.01;
            }
        }

        double highPrice = _symbolSnapshot.highestPrice;
        double lowPrice = _symbolSnapshot.highestPrice - priceBlock;
        double totalVol = 0;
        
        if ([_tickPriceVolumeData count]>0) {
            for (int i=0; i<[_tickPriceVolumeData count]; i++) {
                TradeDistributeParam* paramtemp = (TradeDistributeParam*)[_tickPriceVolumeData objectAtIndex:i];
                if(lowPrice == _symbolSnapshot.lowestPrice){
                    if (paramtemp->price >= lowPrice && paramtemp->price <= highPrice) {
                        totalVol += paramtemp->volume;
                    }
                }else{
                    if (paramtemp->price > lowPrice && paramtemp->price <= highPrice) {
                        totalVol += paramtemp->volume;
                    }else{
                        TradeDistributeParam * groupData = [[TradeDistributeParam alloc] init];
                        //                    groupData->price = [NSString stringWithFormat:@"%.2f~%.2f",lowPrice,highPrice];
                        groupData->price = highPrice;
                        groupData->volume = totalVol;
                        [_groupPriceVolumeData addObject:groupData];
                        highPrice = lowPrice;
                        lowPrice = lowPrice-priceBlock;
                        
                        if (paramtemp->price > lowPrice && paramtemp->price <= highPrice) {
                            totalVol = paramtemp->volume;
                            
                        }else{
                            
                            for (int j=0;j<50; j++) {
                                if (paramtemp->price > lowPrice && paramtemp->price <= highPrice) {
                                    totalVol = paramtemp->volume;
                                    break;
                                }else{
                                    TradeDistributeParam * groupData = [[TradeDistributeParam alloc] init];
                                    groupData->price = highPrice;
                                    groupData->volume = 0;
                                    [_groupPriceVolumeData addObject:groupData];
                                    highPrice = lowPrice;
                                    lowPrice = lowPrice-priceBlock;
                                }
                            }
                        }
                    }
                }
            }
            TradeDistributeParam * groupData = [[TradeDistributeParam alloc] init];
            groupData->price = highPrice;
            groupData->volume = totalVol;
            [_groupPriceVolumeData addObject:groupData];
            
            //        TradeDistributeParam * lowGroupData = [[TradeDistributeParam alloc] init];
            //        //    groupData->price = [NSString stringWithFormat:@"%.2f~%.2f",lowPrice,highPrice];
            //        lowGroupData->price = _symbolSnapshot.lowestPrice;
            //        lowGroupData->volume = lowPriceTotal;
            //        [_groupPriceVolumeData addObject:lowGroupData];
        }
    }
#endif
}

-(double)getRealValue:(double)value Unit:(NSInteger)unit
{
	double realValue = value * pow(1000, unit);
	return realValue;
}

- (void)TDNotify
{
    [dataLock lock];
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	TradeDistribute* tradeDistribute = dataModal.tradeDistribute;

	if(tradeDistribute.dayCount != [self getDayCount:tradeDistribute.dayType]) //確認更新資料與目前設定相同
		return;
    if(!tradeDistribute.dayType)//單日
	{
        self.singleDayData = [tradeDistribute.oneDay.arrayData copy];
        //更新單日日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        NSDate * startDate = [dateFormatter dateFromString:tradeDistribute.startDate];
        NSString * sDate;
        
        
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            sDate = [dateFormatter stringForObjectValue:startDate];
        } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            sDate = [dateFormatter stringForObjectValue:startDate];
        }else{
            [dateFormatter setDateFormat:@"yyy/MM/dd"];
            sDate = [dateFormatter stringForObjectValue:[startDate yearOffset:-1911]];
        }
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(updateSingleDateLabelText:)])
        {
            [self.priceVolumeViewController updateSingleDateLabelText:sDate];
        }
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(setSingleDayDataMaxVolume:)])
        {
            [self.priceVolumeViewController setSingleDayDataMaxVolume:tradeDistribute.oneDay.hightVolume];
        }
    }
	else//1:累計
	{
        self.periodData = [tradeDistribute.period.arrayData copy];
        //更新累積日期
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(updateAccumulativeDateLabelText:)])
        {
            NSString *dateWithoutYear = [tradeDistribute.startDate substringFromIndex:5];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            NSDate * endDate = [dateFormatter dateFromString:tradeDistribute.endDate];
            NSString * sDate;
            if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
                [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                sDate = [dateFormatter stringForObjectValue:endDate];
            } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
                [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                sDate = [dateFormatter stringForObjectValue:endDate];
            }else{
                [dateFormatter setDateFormat:@"yyy/MM/dd"];
                sDate = [dateFormatter stringForObjectValue:[endDate yearOffset:-1911]];
            }
            [self.priceVolumeViewController updateAccumulativeDateLabelText:[NSString stringWithFormat:@"%@~%@", sDate, dateWithoutYear]];
        }
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(setAccumulativeDataMaxVolume:)])
        {
            self.priceVolumeViewController.accumulativeDataMaxVolume = tradeDistribute.period.hightVolume;
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"price.calcValue" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSMutableArray *sortedArray = [[NSMutableArray alloc]initWithArray:[_periodData sortedArrayUsingDescriptors:sortDescriptors]];
        float minRange = MAXFLOAT;
        for (int i = 1; i < [sortedArray count]; i++) {
            FSDistributeObj *obj = [sortedArray objectAtIndex:i];
            FSDistributeObj *objBefore = [sortedArray objectAtIndex:i - 1];
            minRange = MIN(minRange, obj.price.calcValue - objBefore.price.calcValue);
        }
        if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(configurePlotsPeriodVolumeBarWidth:)])
        {
            [self.priceVolumeViewController configurePlotsPeriodVolumeBarWidth:minRange];
        }
	}
    //重新畫圖
    if (self.priceVolumeViewController && [self.priceVolumeViewController respondsToSelector:@selector(reloadGraph)])
    {
        [self.priceVolumeViewController reloadGraph];
    }
    [dataLock unlock];
}

-(NSInteger)getDayCount:(NSInteger)dayType
{
	if(dayType) //1:累計
	{
		switch (_periodIndex)
		{
			case 0:
				return 5;
			case 1:
				return 10;
			case 2:
				return 15;
			case 3:
				return 30;
			default:
				return -1;
		}
	}
	else
	{
		switch (_singleDayIndex)
		{
			case 0://今天
				return 0;
			case 1:
				return 1;
			case 2:
				return 2;
			case 3:
				return 3;
			case 4:
				return 4;
			case 5:
				return 5;
			default:
				return -1;
		}
	}
}

#pragma mark - CPTPlotDataSource methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if ([(NSString *)plot.identifier isEqualToString:@"CPDSingleDayVolume"]) {
        return [_singleDayData count];
        
    }
    //單日量紅虛線
    else if ([(NSString *)plot.identifier isEqualToString:@"CPDSingleDayVolumeDashLine"]){
        return [_singleDayData count];

    }
    else if ([(NSString *)plot.identifier isEqualToString:@"CPDPeriodVolume"]) {
        return [_periodData count];
    }
    return 0;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSNumber *num = nil;
    //單日線
    if ([(NSString *)plot.identifier isEqualToString:@"CPDSingleDayVolume"]) {
        FSDistributeObj *tdParam = nil;
        tdParam = _singleDayData[index];
        switch (fieldEnum) {
            case CPTScatterPlotFieldX:
                return [NSNumber numberWithDouble:tdParam.volume.calcValue];
                break;
            case CPTScatterPlotFieldY:
                return [NSNumber numberWithDouble:tdParam.price.calcValue];
                break;
            default:
                return nil;
                break;
        }
    }
    //單日量虛線
    else if ([(NSString *)plot.identifier isEqualToString:@"CPDSingleDayVolumeDashLine"]){
        FSDistributeObj *tdParam = nil;
        tdParam = _singleDayData[index];
        switch (fieldEnum) {
            case CPTBarPlotFieldBarLocation:
                return [NSNumber numberWithDouble:tdParam.price.calcValue];
                break;
            case CPTBarPlotFieldBarTip:
                return [NSNumber numberWithDouble:tdParam.volume.calcValue];
                break;
            default:
                return nil;
                break;
        }
    }
    else if ([(NSString *)plot.identifier isEqualToString:@"CPDPeriodVolume"])
    {
        FSDistributeObj *tdParam = _periodData[index];
        switch (fieldEnum) {
            case CPTBarPlotFieldBarLocation:
                return [NSNumber numberWithDouble:tdParam.price.calcValue];
                break;
            case CPTBarPlotFieldBarTip:
                return [NSNumber numberWithDouble:tdParam.volume.calcValue];
                break;
                //            case CPTBarPlotFieldBarBase:
                //                return ...;
            default:
                return nil;
                break;
        }
    }
    
    return num;
}

#pragma mark - Find Data

/**
 *  在單日或累積資料中找出最接近的價格
 *
 *  @param yAxisIndex                      在圖上Y軸的座標值
 *  @param enableSingleDaySearching        是否搜尋單日資料
 *  @param enableAccumulationDataSearching 是否搜尋累積資料
 *
 *  @return 價量資訊Dictionary
 */
- (NSDictionary *)findNearestPriceVolumeByYAxisIndex:(NSNumber *) yAxisIndex inSingleDayData:(BOOL) enableSingleDaySearching inAccumulationData:(BOOL) enableAccumulationDataSearching
{
    //先找出一個最接近的價錢
    NSNumber *nearestPrice = @(-1);
    NSArray *targetSingleDayData = nil;
    targetSingleDayData = _singleDayData;
    double oldDiff = MAXFLOAT, newDiff = 0.0;
    if (enableSingleDaySearching && [targetSingleDayData count] > 0) {
        nearestPrice = @(((FSDistributeObj *)targetSingleDayData[0]).price.calcValue);
        oldDiff = fabs([yAxisIndex doubleValue] - [nearestPrice doubleValue]);
        
        for (NSInteger index = 1 ; index < [targetSingleDayData count]; index++) {
            FSDistributeObj *tdParam = targetSingleDayData[index];
            newDiff = fabs([yAxisIndex doubleValue] - tdParam.price.calcValue);
            if (newDiff < oldDiff) {
                nearestPrice = @(tdParam.price.calcValue);
                oldDiff = newDiff;
            }
        }
    }
    if (enableAccumulationDataSearching) {
        if (!enableSingleDaySearching && ([targetSingleDayData count] == 0 && [_periodData count] > 0)) {
            nearestPrice = @(((FSDistributeObj *)_periodData[0]).price.calcValue);
            oldDiff = fabs([yAxisIndex doubleValue] - [nearestPrice doubleValue]);
        }
        for (NSInteger index=0 ; index < [_periodData count]; index++) {
            FSDistributeObj *tdParam = _periodData[index];
            newDiff = fabs([yAxisIndex doubleValue] - tdParam.price.calcValue);
            if (newDiff < oldDiff) {
                nearestPrice = @(tdParam.price.calcValue);
                oldDiff = newDiff;
            }
        }
    }
    
    //用這個價錢去取量
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(FSDistributeObj *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject.price.calcValue == [nearestPrice doubleValue];
    }];
    
    //先看是不是選今天
    NSArray *filterdSingleDataArray = nil;
    filterdSingleDataArray = [targetSingleDayData filteredArrayUsingPredicate:predicate];
    FSDistributeObj *singleDayParam = nil, *periodParam = nil;
    if ([filterdSingleDataArray count] > 0) {
        singleDayParam = filterdSingleDataArray.firstObject;
    }
    
    NSArray *filterdPeriodDataArray = [_periodData filteredArrayUsingPredicate:predicate];
    if ([filterdPeriodDataArray count] > 0) {
        periodParam = filterdPeriodDataArray.firstObject;
    }
    
    NSMutableDictionary *result = [@{} mutableCopy];
    if (singleDayParam != nil) {
        [result setObject:@(singleDayParam.price.calcValue) forKey:@"SingleDayPrice"];
        [result setObject:@(singleDayParam.volume.calcValue) forKey:@"SingleDayVolume"];
    }
    else {
        [result setObject:[NSNull null] forKey:@"SingleDayPrice"];
        [result setObject:[NSNull null] forKey:@"SingleDayVolume"];
    }
    if (periodParam != nil) {
        [result setObject:@(periodParam.price.calcValue) forKey:@"PeriodPrice"];
        [result setObject:@(periodParam.volume.calcValue) forKey:@"PeriodVolume"];
    }
    else {
        [result setObject:[NSNull null] forKey:@"PeriodPrice"];
        [result setObject:[NSNull null] forKey:@"PeriodVolume"];
    }
    return result;
}



//傳入數字找尋最接近的價
- (float)findNearestPriceVolumeByPrice:(float) price inSingleDayData:(BOOL) enableSingleDaySearching inAccumulationData:(BOOL) enableAccumulationDataSearching
{
    //先找出一個最接近的價錢
    float nearestPrice = -1;
    NSArray *targetSingleDayData = nil;
    targetSingleDayData = _singleDayData;
    double oldDiff=MAXFLOAT, newDiff=0.0;
    if (enableSingleDaySearching && [targetSingleDayData count] > 0) {
        nearestPrice = ((FSDistributeObj *)targetSingleDayData[0]).price.calcValue;
        oldDiff = fabs(price - nearestPrice);
            
        for (NSInteger index = 1 ; index < [targetSingleDayData count]; index++) {
            FSDistributeObj *tdParam = targetSingleDayData[index];
            newDiff = fabs(price - tdParam.price.calcValue);
            if (newDiff < oldDiff && price - tdParam.price.calcValue < 0.0001) {
                nearestPrice = tdParam.price.calcValue;
                oldDiff = newDiff;
            }
        } 
    }
    if (enableAccumulationDataSearching) {
        if (!enableSingleDaySearching && ([targetSingleDayData count] == 0 && [_periodData count] > 0)) {
            nearestPrice = ((FSDistributeObj *)_periodData[0]).price.calcValue;
            oldDiff = fabs(price - nearestPrice);
        }
        for (NSInteger index=0 ; index < [_periodData count]; index++) {
            FSDistributeObj *tdParam = _periodData[index];
            newDiff = fabs(price - tdParam.price.calcValue);
            if (newDiff < oldDiff) {
                if (price - tdParam.price.calcValue < 0.0001) {
                    nearestPrice = tdParam.price.calcValue;
                    oldDiff = newDiff;
                }
            }
        }
    }
    return nearestPrice;
}

-(NSInteger)findBlock:(NSInteger)blockCount{
    NSInteger x;
    
    if (blockCount > 130) {
        x = 6;
    }else if (blockCount >= 90){
        x = 5;
    }else if (blockCount >= 70){
        x = 4;
    }else if (blockCount >= 50){
        x = 4;
    }else if (blockCount >= 30){
        x = 3;
    }else if (blockCount >= 20){
        x = 3;
    }else if (blockCount >= 10){
        x = 2;
    }else{
        x = 1;
    }
    return x;
}

-(void)findIdentCodeAndDate{
    PortfolioItem * item = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    FSSnapshot * snapshot = [dataModal.portfolioTickBank getSnapshotBvalue:item->commodityNo];
    identCodeSymbol = [NSString stringWithFormat:@"%c%c:%@",item->identCode[0], item->identCode[1], item->symbol ];
    if (snapshot) {
        self.symbolSnapshot = snapshot;
        UInt16 d = _symbolSnapshot.trading_date.date16;
        newDate = [CodingUtil dateConvertToNewDate:d];
    }
}
@end
