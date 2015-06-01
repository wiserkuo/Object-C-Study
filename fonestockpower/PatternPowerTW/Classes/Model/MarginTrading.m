//
//  MarginTrading.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/12.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MarginTrading.h"
#import "MarginTradingOut.h"
#import "MarginTradingIn.h"
#import "CodingUtil.h"

#import "SKDateUtils.h"

@implementation MarginTrading

@synthesize identSymbol;
@synthesize mainArray;
@synthesize autoFetingNo;
@synthesize fetchObj;
@synthesize commodityNum;


- (id)init
{
	if(self = [super init])
	{
		datalock = [[NSRecursiveLock alloc] init];
		autoFetingNo = 0;
		notifyObj = nil;
	}
	return self;
}

- (void)loadFromIdentSymbol:(NSString*)is
{
	[datalock lock];
	self.identSymbol = is;
    
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ MarginTrading.plist",identSymbol]];
	self.mainArray = [NSMutableArray arrayWithContentsOfFile:path];
	if(!mainArray) mainArray = [[NSMutableArray alloc] init];
	[datalock unlock];
}

- (void)sendAndRead
{
	[datalock lock];
    
	if([mainArray count]>0 && notifyObj)
		[notifyObj performSelectorOnMainThread:@selector(notifyMarginTradingData) withObject:nil waitUntilDone:NO];
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	Portfolio *portfolio = dataModal.portfolioData;
	PortfolioItem *portfolioItem = [portfolio findItemByIdentCodeSymbol:identSymbol];
	
	if(notifyObj)
		commodityNum = portfolioItem->commodityNo;
	else commodityNum = 0;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *today = [NSDate date];
	NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
	int year = (int)[comps year];
	int month = (int)[comps month];
	int day = (int)[comps day];
	UInt16 sDate;
	if([mainArray count]>0)
	{
		NSDictionary *tmpDict = [mainArray objectAtIndex:0];
		sDate = [[tmpDict objectForKey:@"RecordDate"] unsignedIntValue];
	}
	else sDate = [CodingUtil makeDate:1960 month:1 day:1];
	UInt16 eDate = [CodingUtil makeDate:year month:month day:day];
	MarginTradingOut *MTOut = [[MarginTradingOut alloc] initWithCommodityNum:portfolioItem->commodityNo StartDate:sDate EndDate:eDate];
	[FSDataModelProc sendData:self WithPacket:MTOut];
	[datalock unlock];
//	[MTOut release];
//	[gregorian release];
	
}

//- (void)decodeArrive:(NSMutableArray*)bsArray
- (void)decodeArrive:(MarginTradingIn*)obj;
{
	NSMutableArray *bsArray = obj->marginTradingArray;
	[datalock lock];
	if(fetchObj && commodityNum != obj->commodityNum)
	{
		fetchObj.commodityNum = obj->commodityNum;
		[fetchObj decodeArrive:obj];
	}
	else if(commodityNum == obj->commodityNum)
	{
		if([bsArray count] > 0)
		{
            /*	Server may send multiple packets, these code results in data lose.
             Jo-Hai 8/13/2010
             if([mainArray count]>0)  //代表有東西
             {
             [mainArray removeObjectAtIndex:0];
             }
             */
			
			//今日的要過後, 每看一次server還會再下傳一次今日的data
			BOOL setData = NO;
			if([mainArray count]>0)
			{
				NSDictionary *tmpDict = [mainArray objectAtIndex:0];
				UInt16 theNewestDate = [[tmpDict objectForKey:@"RecordDate"] unsignedIntValue];
				
				MarginTradingParam *mtFirstParam  = [bsArray objectAtIndex:0];
				if(mtFirstParam->date == theNewestDate)
				{
					//NSLog(@"有過了");
				}
				else
				{
					setData = YES;
				}
                
				
			}
			else
			{
				setData = YES;
			}
            
			if(setData)
			{
				int i=0;
				for(MarginTradingParam *mtParam in bsArray)
				{
//					NSLog(@"date:%d",mtParam->date);
					NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:mtParam->date] forKey:@"RecordDate"];
					[tmpDict setObject:[NSNumber numberWithDouble:mtParam->usedAmount] forKey:@"usedAmount"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:mtParam->usedAmountUnit] forKey:@"usedAmountUnit"];
					[tmpDict setObject:[NSNumber numberWithDouble:mtParam->amountOffset] forKey:@"amountOffset"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:mtParam->amountOffsetUnit] forKey:@"amountOffsetUnit"];
					[tmpDict setObject:[NSNumber numberWithDouble:mtParam->amountRatio] forKey:@"amountRatio"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:mtParam->amountRatioUnit] forKey:@"amountRatioUnit"];
					[tmpDict setObject:[NSNumber numberWithDouble:mtParam->usedShare] forKey:@"usedShare"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:mtParam->usedShareUnit] forKey:@"usedShareUnit"];
					[tmpDict setObject:[NSNumber numberWithDouble:mtParam->sharedOffset] forKey:@"sharedOffset"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:mtParam->sharedOffsetUnit] forKey:@"sharedOffsetUnit"];
					[tmpDict setObject:[NSNumber numberWithDouble:mtParam->sharedRatio] forKey:@"sharedRatio"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:mtParam->sharedRatioUnit] forKey:@"sharedRatioUnit"];
					[tmpDict setObject:[NSNumber numberWithDouble:mtParam->offset] forKey:@"offset"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:mtParam->offsetUnit] forKey:@"offsetUnit"];
					[mainArray insertObject:tmpDict atIndex:i++];
//					[tmpDict release];
				}
				[self sortArray];
				
			}
            
			if(notifyObj)
				[notifyObj performSelectorOnMainThread:@selector(notifyMarginTradingData) withObject:nil waitUntilDone:NO];
			[self saveToFile];
		}
		if (obj->retCode == 0 && [identSymbol hash] == autoFetingNo && identSymbol) // autofetch next sector;
		{
			autoFetingNo = 0;
//			FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//			[dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
            
		}
	}
    
	[datalock unlock];
}

- (void)setTargetNotify:(id)obj
{
	notifyObj = obj;
}

- (void)sortArray
{
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"RecordDate" ascending:NO selector:@selector(compare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	[mainArray sortUsingDescriptors:sortDescriptors];
//	[sortDescriptors release];
//	[sortDescriptor release];
}

- (void)saveToFile
{
	[datalock lock];
	
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ MarginTrading.plist",identSymbol]];
	BOOL success = [mainArray writeToFile:path atomically:YES];
	if(!success) NSLog(@"MarginTrading wirte error!!");
	[datalock unlock];
}

- (void)discardData
{
	[datalock lock];
	self.identSymbol = nil;
	self.mainArray = nil;
	notifyObj = nil;
	[datalock unlock];
}

- (int)getRowCount
{
	return (int)[mainArray count];
}

- (NSArray *)getRowDataWithIndex:(int)index
{
	[datalock lock];
	if([mainArray count]==0)
	{
		[datalock unlock];
		return nil;
	}
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	NSDictionary *tmpDict = [mainArray objectAtIndex:index];
	MarginTradingParam *mtParam = [[MarginTradingParam alloc] init];
    
	mtParam->date = [[tmpDict objectForKey:@"RecordDate"] unsignedIntValue];
	mtParam->usedAmount = [(NSNumber *)[tmpDict objectForKey:@"usedAmount"] doubleValue];
	mtParam->usedAmountUnit = [[tmpDict objectForKey:@"usedAmountUnit"] unsignedIntValue];
	mtParam->amountOffset = [(NSNumber *)[tmpDict objectForKey:@"amountOffset"] doubleValue];
	mtParam->amountOffsetUnit = [[tmpDict objectForKey:@"amountOffsetUnit"] unsignedIntValue];
	mtParam->amountRatio = [(NSNumber *)[tmpDict objectForKey:@"amountRatio"] doubleValue];
	mtParam->amountRatioUnit = [[tmpDict objectForKey:@"amountRatioUnit"] unsignedIntValue];
	mtParam->usedShare = [(NSNumber *)[tmpDict objectForKey:@"usedShare"] doubleValue];
	mtParam->usedShareUnit = [[tmpDict objectForKey:@"usedShareUnit"] unsignedIntValue];
	mtParam->sharedOffset = [(NSNumber *)[tmpDict objectForKey:@"sharedOffset"] doubleValue];
	mtParam->sharedOffsetUnit = [[tmpDict objectForKey:@"sharedOffsetUnit"] unsignedIntValue];
	mtParam->sharedRatio = [(NSNumber *)[tmpDict objectForKey:@"sharedRatio"] doubleValue];
	mtParam->sharedRatioUnit = [[tmpDict objectForKey:@"sharedRatioUnit"] unsignedIntValue];
	mtParam->offset = [(NSNumber *)[tmpDict objectForKey:@"offset"] doubleValue];
	mtParam->offsetUnit = [[tmpDict objectForKey:@"offsetUnit"] unsignedIntValue];
	[returnArray addObject:mtParam];
//	[mtParam release];
	[datalock unlock];
	return returnArray;	 //UI那要release
}

- (NSArray *)getAllDateArray {
    
    [datalock lock];
	if([mainArray count]==0)
	{
		[datalock unlock];
		return nil;
	}
    
    NSMutableArray *dateArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    for (NSDictionary *dict in mainArray) {
        [dateArray addObject:[dict objectForKey:@"RecordDate"]];
    }

    NSArray *retArray = [dateArray sortedArrayUsingSelector:@selector(compare:)];
    
    [datalock unlock];
    return retArray;
}

- (UInt16)getLastRecordDate {
    [datalock lock];
    int recordDate = 0;
	if([mainArray count]==0)
	{
		[datalock unlock];
    }else{
        [self sortArray];
        
        NSDictionary *d = [mainArray objectAtIndex:0];
        
        recordDate = [[d objectForKey:@"RecordDate"] unsignedIntValue];
        
        [datalock unlock];
    }
    

    return recordDate;
}

/* 取得融資餘額 */
- (NSDictionary *)getIIG1StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate {
    
    [datalock lock];
	if ([mainArray count] == 0) {
		[datalock unlock];
		return nil;
	}
    
    [self sortArray];
    
    // 建立儲存用資料結構
    
    NSMutableDictionary *retDict = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    int amountOffsetTotal = 0;
    float amountOffsetRatio = 0;
    int sharedOffsetTotal = 0;
    float sharedOffsetRatio = 0;
    int offsetTotal = 0;
    
	for (NSDictionary *bsDict1 in mainArray) {
		UInt16 recordDate = [(NSNumber *)[bsDict1 objectForKey:@"RecordDate"] intValue];
        if (startDate <= recordDate && recordDate <= endDate) {
            amountOffsetTotal += [(NSNumber *)[bsDict1 objectForKey:@"amountOffset"] intValue];
            sharedOffsetTotal += [(NSNumber *)[bsDict1 objectForKey:@"sharedOffset"] intValue];
            offsetTotal += [(NSNumber *)[bsDict1 objectForKey:@"offset"] intValue];
            
            float previous_usedAmount = [(NSNumber *)[bsDict1 objectForKey:@"usedAmount"] floatValue] - [(NSNumber *)[bsDict1 objectForKey:@"amountOffset"] intValue];
            amountOffsetRatio = amountOffsetTotal / previous_usedAmount;
            
            float previous_usedShare = [(NSNumber *)[bsDict1 objectForKey:@"usedShare"] floatValue] - [(NSNumber *)[bsDict1 objectForKey:@"sharedOffset"] intValue];
            sharedOffsetRatio = sharedOffsetTotal / previous_usedShare;
        }
        
        if (startDate == recordDate) {
//            float previous_usedAmount = [[bsDict1 objectForKey:@"usedAmount"] floatValue] - [[bsDict1 objectForKey:@"amountOffset"] intValue];
//            amountOffsetRatio = amountOffsetTotal / previous_usedAmount;
//            
//            float previous_usedShare = [[bsDict1 objectForKey:@"usedShare"] floatValue] - [[bsDict1 objectForKey:@"sharedOffset"] intValue];
//            sharedOffsetRatio = sharedOffsetTotal / previous_usedShare;

        }
    }
    
    [retDict setValue:[NSNumber numberWithInt:amountOffsetTotal] forKey:@"amountOffsetTotal"];
    [retDict setValue:[NSNumber numberWithFloat:amountOffsetRatio] forKey:@"amountOffsetRatio"];
    [retDict setValue:[NSNumber numberWithInt:sharedOffsetTotal] forKey:@"sharedOffsetTotal"];
    [retDict setValue:[NSNumber numberWithFloat:sharedOffsetRatio] forKey:@"sharedOffsetRatio"];
    [retDict setValue:[NSNumber numberWithInt:offsetTotal] forKey:@"offsetTotal"];
    
	[datalock unlock];
    
	return retDict;
}


- (void)dealloc
{
//	if(identSymbol) [identSymbol release];
//	if(mainArray) [mainArray release];
//	[super dealloc];
}

- (int) autofetch: (NSString*)identCodeSymbol
{
	if(!fetchObj)
		fetchObj = [[MarginTrading alloc] init];
	fetchObj.autoFetingNo = (int)[identCodeSymbol hash];
	self.autoFetingNo = (int)[identCodeSymbol hash];
	[fetchObj loadFromIdentSymbol:identCodeSymbol];
	[fetchObj sendAndRead];
	return 1;
}

- (void) deleteFetchObj
{
	[datalock lock];
	self.fetchObj = nil;
	[datalock unlock];
}

@end
