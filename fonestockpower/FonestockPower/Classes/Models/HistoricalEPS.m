//
//  HistoricalEPS.m
//  Bullseye
//
//  Created by Yehsam on 2009/2/4.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HistoricalEPS.h"
#import "HistoricalEPSOut.h"
#import "HistoricalEPSIn.h"


@implementation HistoricalEPS

@synthesize identSymbol;
@synthesize mainArray;
@synthesize autoFetingNo;
@synthesize fetchObj;
@synthesize notifyObj;
@synthesize commodityNum;

- (id)init
{
	if(self = [super init])
	{
		datalock = [[NSRecursiveLock alloc] init];
		self.notifyObj = nil;
		removeFlag = YES;
	}
	return self;
}

- (void)loadFromIdentSymbol:(NSString*)is
{
	[datalock lock];
	self.identSymbol = is;

	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ HistoricalEPS.plist",identSymbol]];
	self.mainArray = [NSMutableArray arrayWithContentsOfFile:path];
	if(!mainArray) mainArray = [[NSMutableArray alloc] init];
	[datalock unlock];
}

- (void)sendAndRead
{
	[datalock lock];
	if([mainArray count] && self.notifyObj)
		[self.notifyObj performSelectorOnMainThread:@selector(notifyData) withObject:nil waitUntilDone:NO];
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	Portfolio *portfolio = dataModal.portfolioData;
	PortfolioItem *portfolioItem = [portfolio findItemByIdentCodeSymbol:identSymbol];
	
	if(self.notifyObj)
		commodityNum = portfolioItem->commodityNo;
	else commodityNum = 0;
	
	removeFlag = YES;
    if (portfolioItem->commodityNo) {
        HistoricalEPSOut *isOut = [[HistoricalEPSOut alloc] initWithCount:12 CommodityNum:portfolioItem->commodityNo EPSType:0];
        [FSDataModelProc sendData:self WithPacket:isOut];
    
    }
	[datalock unlock];
}

//- (void)decodeArrive:(NSMutableArray*)isArray
- (void)decodeArrive:(HistoricalEPSIn*)obj
{
	NSMutableArray *isArray = obj->historicalEPSArray;
	[datalock lock];
	if(fetchObj && commodityNum != obj->commodityNum)
	{
		fetchObj.commodityNum = obj->commodityNum;
		[fetchObj decodeArrive:obj];
	}
	else if(commodityNum == obj->commodityNum)
	{
		
		if ([isArray count] > 0)
		{
//			if(removeFlag)
//			{
				[mainArray removeAllObjects];
//				removeFlag = NO;
//			}
			for(HistoricalEPSParam *epsParam in isArray)
			{
				NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
				[tmpDict setObject:[NSNumber numberWithUnsignedInt:epsParam->date] forKey:@"Date"];
				[tmpDict setObject:[NSNumber numberWithUnsignedInt:epsParam->epsType] forKey:@"Type"];
				[tmpDict setObject:[NSNumber numberWithDouble:epsParam->epsValue] forKey:@"Value"];
				[tmpDict setObject:[NSNumber numberWithUnsignedInt:epsParam->epsValueUnit] forKey:@"ValueUnit"];		
				[mainArray addObject:tmpDict];
			}
			if (obj->retCode == 0)
			{
				[self sortArray];
				[self saveToFile];
				if(self.notifyObj)
					[self.notifyObj performSelectorOnMainThread:@selector(notifyData) withObject:nil waitUntilDone:NO];
			}
		}
		if (obj->retCode == 0 && [identSymbol hash] == autoFetingNo && identSymbol) // autofetch next sector;
		{
			autoFetingNo = 0;
			//FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
            //neil
//			[dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
		}
	}
	[datalock unlock];
}

- (void)sortArray
{
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Date" ascending:NO selector:@selector(compare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	[mainArray sortUsingDescriptors:sortDescriptors];
}

- (void)setTargetNotify:(id)obj
{
	self.notifyObj = obj;
}

- (void)saveToFile
{
	[datalock lock];

	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ HistoricalEPS.plist",identSymbol]];
	BOOL success = [mainArray writeToFile:path atomically:YES];
	if(!success) NSLog(@"HistoricalEPS wirte error!!");
	[datalock unlock];
}

- (NSArray*)getAllocEPSArray
{
	[datalock lock];
	if([mainArray count]==0)
	{
		[datalock unlock];
		return nil;
	}
    
    NSNumber *maxEpsValue = 0;
    NSNumber *minEpsValue = 0;
    
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	UInt16 preDate=0;
	for(NSDictionary *tmpDict in mainArray)
	{
		NSNumber *date = [tmpDict objectForKey:@"Date"];
		if(preDate)	//確定季 有些美股季會亂掉
		{
			UInt16 currentDate = [date unsignedIntValue];
			UInt16 preYear,currentYear;
			UInt8 preMonth,currentMonth,day;
			[CodingUtil getDate:preDate year:&preYear month:&preMonth day:&day];
			[CodingUtil getDate:currentDate year:&currentYear month:&currentMonth day:&day];
			if(preYear == currentYear && fabs(preMonth - currentMonth)<6)
			{
				if(preMonth>=10 && preMonth<=12) currentMonth = 9;
				else if(preMonth>=7 && preMonth<=9) currentMonth = 6;
				else if(preMonth>=4 && preMonth<=6) currentMonth = 3;
				currentDate = [CodingUtil makeDate:currentYear month:currentMonth day:day];
			}
			date = [[NSNumber alloc]initWithUnsignedInt:currentDate];
		}
        
        UInt16 dateUInt16 = [date unsignedIntValue];
        UInt16 year;
        UInt8 month,day;
        [CodingUtil getDate:dateUInt16 year:&year month:&month day:&day];
        
        
        NSNumber *yearValue = [NSNumber numberWithInt: year - 1911];
        
        NSNumber *seasonValue;
        if (month >= 1 && month <=3 ) {
            seasonValue = [NSNumber numberWithInt: 1];
        } else if (month >= 4 && month <= 6) {
            seasonValue = [NSNumber numberWithInt: 2];
        } else if(month >= 7 && month <= 9) {
            seasonValue = [NSNumber numberWithInt: 3];
        } else {
            seasonValue = [NSNumber numberWithInt: 4];
        }
        
        NSNumber *epsValue = [tmpDict objectForKey:@"Value"];
        
        if ([maxEpsValue compare:epsValue] == NSOrderedAscending) {
            maxEpsValue = epsValue;
        }
        
        if ([minEpsValue compare:epsValue] == NSOrderedDescending) {
            minEpsValue = epsValue;
        }
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              seasonValue, @"seasonValue",
                              yearValue, @"yearValue",
                              epsValue, @"epsValue",
                              nil];
        
		[returnArray addObject:dict];
//        if (date) {
//            preDate = [date unsignedIntValue];
//        }
		

	}
	
	[datalock unlock];
	return returnArray; //UI那邊要release
}

- (NSArray*)getCompanyEPSDate
{
	[datalock lock];
	if([mainArray count]==0)
	{
		[datalock unlock];
		return nil;
	}
    
    NSNumber *maxEpsValue = 0;
    NSNumber *minEpsValue = 0;
    
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	UInt16 preDate=0;
	for(NSDictionary *tmpDict in mainArray)
	{
		NSNumber *date = [tmpDict objectForKey:@"Date"];
		if(preDate)	//確定季 有些美股季會亂掉
		{
			UInt16 currentDate = [date unsignedIntValue];
			UInt16 preYear,currentYear;
			UInt8 preMonth,currentMonth,day;
			[CodingUtil getDate:preDate year:&preYear month:&preMonth day:&day];
			[CodingUtil getDate:currentDate year:&currentYear month:&currentMonth day:&day];
			if(preYear == currentYear && fabs(preMonth - currentMonth)<6)
			{
				if(preMonth>=10 && preMonth<=12) currentMonth = 9;
				else if(preMonth>=7 && preMonth<=9) currentMonth = 6;
				else if(preMonth>=4 && preMonth<=6) currentMonth = 3;
				currentDate = [CodingUtil makeDate:currentYear month:currentMonth day:day];
			}
			date = [[NSNumber alloc]initWithUnsignedInt:currentDate];
		}
        
        UInt16 dateUInt16 = [date unsignedIntValue];
        UInt16 year;
        UInt8 month,day;
        [CodingUtil getDate:dateUInt16 year:&year month:&month day:&day];
        
        
        NSNumber *yearValue = [NSNumber numberWithInt: year - 1911];
        
        NSNumber *seasonValue;
        if (month >= 1 && month <=3 ) {
            seasonValue = [NSNumber numberWithInt: 1];
        } else if (month >= 4 && month <= 6) {
            seasonValue = [NSNumber numberWithInt: 2];
        } else if(month >= 7 && month <= 9) {
            seasonValue = [NSNumber numberWithInt: 3];
        } else {
            seasonValue = [NSNumber numberWithInt: 4];
        }
        
        NSNumber *epsValue = [tmpDict objectForKey:@"Value"];
        
        if ([maxEpsValue compare:epsValue] == NSOrderedAscending) {
            maxEpsValue = epsValue;
        }
        
        if ([minEpsValue compare:epsValue] == NSOrderedDescending) {
            minEpsValue = epsValue;
        }
        [returnArray addObject:seasonValue];
        [returnArray addObject:yearValue];
	}
	
	[datalock unlock];
	return returnArray; //UI那邊要release
}

- (void)discardData
{
	[datalock lock];
	self.identSymbol = nil;
	self.mainArray = nil;
	self.notifyObj = nil;
	removeFlag = YES;
	[datalock unlock];
}

- (void)changePage
{
	removeFlag = YES;
}

- (int) autofetch: (NSString*)identCodeSymbol
{
	if(!fetchObj)
		fetchObj = [[HistoricalEPS alloc] init];
	fetchObj.autoFetingNo = (int)[identCodeSymbol hash];
	self.autoFetingNo = (int)[identCodeSymbol hash];
	[fetchObj loadFromIdentSymbol:identCodeSymbol];	
	[fetchObj setTargetNotify:nil];
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
