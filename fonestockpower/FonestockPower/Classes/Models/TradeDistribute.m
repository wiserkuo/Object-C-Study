//
//  TradeDistribute.m
//  Bullseye
//
//  Created by ilien.liao on 2009/6/16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TradeDistribute.h"
#import "TradeDistributeOut.h"
#import "TradeDistributeIn.h"

#import "FSDistributeOut.h"
#import "FSDistributeIn.h"

#import "FSNewPriceByVolumeViewController.h"
#import "FSPriceVolumeChartDataSource.h"
@implementation TDParam

@synthesize arrayData;
@synthesize volumeUnit; //for hightVolume and lowVolume
@synthesize hightPrice;
@synthesize lowPrice;
@synthesize hightVolume;
@synthesize lowVolume;


- (id)init
{
	
	if(self = [super init])
	{
		NSMutableArray* tmp = [[NSMutableArray alloc] init];
		self.arrayData = tmp;
		
	}
	return self;
}


- (void)dealloc
{
	[arrayData removeAllObjects];
	
}

@end

@interface TradeDistribute (){
    NSRecursiveLock *dataLock;
    int downloadCount;//防止頁面來回點擊，造成電文接收錯頁
}
@end

@implementation TradeDistribute

@synthesize notifyTarget;
@synthesize oneDay,period;
@synthesize date,startDate,endDate;
@synthesize dayType,dayCount;

- (id)init
{
	
	if(self = [super init])
	{
		self.oneDay = [[TDParam alloc] init];
		self.period = [[TDParam alloc] init];
        dataLock = [[NSRecursiveLock alloc]init];

	}
	return self;
}


-(double)getRealValue:(double)value Unit:(NSInteger)unit
{
	int n=1;
	for(int i=0; i<unit; i++)
	{
		n*=1000;
	}
	return value*n;
}

- (void)AskOneDaySecurityNum:(UInt32)cn DayCount:(UInt8)dc BeforeDate:(UInt16)d
{
	[oneDay.arrayData removeAllObjects];
	oneDay.hightVolume = -1;
	TradeDistributeOut* tdOut = [[TradeDistributeOut alloc] initWithOneDaySecurityNum:cn DayCount:dc BeforeDate:d];
	[FSDataModelProc sendData:self WithPacket:tdOut];
	
}

- (void)AskDaysSecurityNum:(UInt32)cn DayCount:(UInt8)dc BeforeDate:(UInt16)d
{
	[period.arrayData removeAllObjects];
	period.hightVolume = -1;
	TradeDistributeOut* tdOut = [[TradeDistributeOut alloc] initWithAddDaySecurityNum:cn DayCount:dc BeforeDate:d];
	[FSDataModelProc sendData:self WithPacket:tdOut];
}

- (void)SetTarget:(NSObject <TDNotifyProtocol>*) obj
{
    notifyTarget = obj;
    downloadCount = 0;
}

-(void)setTarget:(id)obj{
    notifyObj = obj;
    downloadCount = 0;
}

-(void)fSDistributeIn:(NSObject *)data{
    downloadCount ++;
    FSDistributeIn *td = (FSDistributeIn *)data;
    if (td -> dayType == 0 && [notifyObj isKindOfClass:[FSNewPriceByVolumeViewController class]]){
        [notifyObj performSelectorOnMainThread:@selector(dataArrive:) withObject:data waitUntilDone:NO];
    }
    if ([notifyTarget isKindOfClass:[FSPriceVolumeChartDataSource class]]) {
        if (td -> dayType == 0) {
            downloadCount++;
        }
        if (downloadCount == 2 || td -> dayType == 1) {
            [self TDIn:data];
        }
    }
}

- (void)TDIn:(NSObject *)obj
{
    FSDistributeIn *td = (FSDistributeIn *)obj;
    
    [dataLock lock];
    dayCount = td->dayCount;
    dayType = td->dayType;
    if(dayType)
    {  //1:累計
        self.date = [CodingUtil getStringDateNew:td -> date];
    
        self.startDate = [CodingUtil getStringDateNew:td -> endDate];
        
        self.endDate = [CodingUtil getStringDateNew:td -> startDate ];
        
        NSUInteger count = [td -> tdArray count];
        for(int i=0; i<count; i++)
        {
            FSDistributeObj* param = [td->tdArray objectAtIndex:i];
            if(i==0 && period.hightVolume == -1)
            {
                period.hightPrice = param.price.calcValue;
                period.hightVolume = param.volume.calcValue;
            }
            else if(i==1)
            {
                if(period.hightPrice > param.price.calcValue)
                {
                    period.lowPrice = param.price.calcValue;
                }
                else
                {
                    period.lowPrice = period.hightPrice;
                    period.hightPrice = param.price.calcValue;
                }
                
                double vol = param.volume.calcValue;
                if(period.hightVolume>vol)
                {
                    period.lowVolume = vol;
                }
                else
                {
                    period.lowVolume = period.hightVolume;
                    period.hightVolume = vol;
                }
            }
            else
            {
                double vol = param.volume.calcValue;
                if(period.hightPrice < param.price.calcValue)
                {
                    period.hightPrice = param.price.calcValue;
                }
                else if(period.lowPrice > param.price.calcValue)
                {
                    period.lowPrice = param.price.calcValue;
                }
                
                if(period.hightVolume < vol)
                {
                    period.hightVolume = vol;
                }
                else if(period.lowVolume > vol)
                {
                    period.lowVolume = vol;
                }
            }
            [period.arrayData addObject:param];
        }
        if(period.hightVolume == -1)
            period.hightVolume = 0;
    }
    else
    {  //0:單日

        self.date = [CodingUtil getStringDateNew:td -> date];
        
        self.startDate = [CodingUtil getStringDateNew:td -> endDate];
        
        self.endDate = [CodingUtil getStringDateNew:td -> startDate];
        
        NSUInteger count = [td -> tdArray count];
        for(int i=0; i<count; i++)
        {
            FSDistributeObj *param = [td -> tdArray objectAtIndex:i];
            if(i == 0 && oneDay.hightVolume == -1)
            {
                oneDay.hightPrice = param.price.calcValue;
                oneDay.hightVolume = param.volume.calcValue;
            }
            else if(i==1)
            {
                if(oneDay.hightPrice > param.price.calcValue)
                {
                    oneDay.lowPrice = param.price.calcValue;
                }
                else
                {
                    oneDay.lowPrice = oneDay.hightPrice;
                    oneDay.hightPrice = param.price.calcValue;
                }
                
                double vol = param.volume.calcValue;
                if(oneDay.hightVolume > vol)
                {
                    oneDay.lowVolume = vol;
                }
                else
                {
                    oneDay.lowVolume = oneDay.hightVolume;
                    oneDay.hightVolume = vol;
                }
            }
            else
            {
                double vol = param.volume.calcValue;
                if(oneDay.hightPrice < param.price.calcValue)
                {
                    oneDay.hightPrice = param.price.calcValue;
                }
                else if(oneDay.lowPrice > param.price.calcValue)
                {
                    oneDay.lowPrice = param.price.calcValue;
                }
                
                if(oneDay.hightVolume < vol)
                {
                    oneDay.hightVolume = vol;
                }
                else if(oneDay.lowVolume > vol)
                {
                    oneDay.lowVolume = vol;
                }
            }
            [oneDay.arrayData addObject:param];
        }
        if(oneDay.hightVolume == -1)
            oneDay.hightVolume = 0;
        
    }
    if(notifyTarget && !td->returnCode)
		[notifyTarget performSelectorOnMainThread:@selector(TDNotify) withObject: nil waitUntilDone: NO];
    
    [dataLock unlock];

}

//Michael
-(void)AskDaysIdentCodeSymbol:(NSString *)ident number:(UInt8)n date:(UInt16)d
{
    [period.arrayData removeAllObjects];
    period.hightVolume = -1;
    downloadCount = 0;
    FSDistributeOut *packetOut = [[FSDistributeOut alloc]initWithAddDayIdentCodeSymbol:ident number:n date:d];

    [FSDataModelProc sendData:self WithPacket:packetOut];
}

- (void)AskOneDayIdentCodeSymbol:(NSString *)ident number:(UInt8)n date:(UInt16)d
{
    [oneDay.arrayData removeAllObjects];
    oneDay.hightVolume = -1;
    downloadCount = 0;
    FSDistributeOut *packetOut = [[FSDistributeOut alloc]initWithOneDayIdentCodeSymbol:ident number:n date:d];
    
    [FSDataModelProc sendData:self WithPacket:packetOut];
    
}

- (NSString *)signByExamingPrice:(double) price equalToOpenPrice:(double) openPrice closePrice:(double) closePrice
{
    if ((price==openPrice) && (price==closePrice) && (openPrice == closePrice)) { //開收等價
        return @"=";
    }
    else if (price == openPrice) { //價格等於開盤價，加上*
        return @"*";
    }
    else if (price == closePrice) { //價格等於收盤價，加上#
        return @"#";
    }
    return @"";
}


@end
