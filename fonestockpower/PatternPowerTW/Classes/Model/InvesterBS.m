//
//  InvesterBS.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InvesterBS.h"
#import "Portfolio.h"
#import "InvesterBSOut.h"
#import "InvesterHoldOut.h"
#import "InvesterHoldIn.h"
#import "InvesterBSIn.h"
#import "CodingUtil.h"
#import "SKDateUtils.h"

@interface InvesterBS()

- (void)sortArray:(NSMutableArray*)array;

@end


@implementation InvesterBS

@synthesize identSymbol;
@synthesize mainDict;
@synthesize autoFetingNo;
@synthesize fetchObj;
@synthesize commodityNum;

@synthesize IIG1;
@synthesize IIG2;
@synthesize IIG3;
@synthesize notifyObj;

- (id)init
{
	if(self = [super init])
	{
		datalock = [[NSRecursiveLock alloc] init];
		notifyObj = nil;
        
        IIG1 = NO;
        IIG2 = NO;
        IIG3 = NO;
	}
	return self;
}

- (void)loadFromIdentSymbol:(NSString*)is
{
	[datalock lock];
	self.identSymbol = is;
    
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ InvesterBS.plist",identSymbol]];
	self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	if(!mainDict) mainDict = [[NSMutableDictionary alloc] init];
	[datalock unlock];
}

- (void)sendAndRead {
	[datalock lock];
    
	if ([mainDict count] > 0 && notifyObj) {
        [notifyObj performSelectorOnMainThread:@selector(notifyInvesterBSData) withObject:nil waitUntilDone:NO];
    }
		
	FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
	Portfolio *portfolio = dataModel.portfolioData;
	PortfolioItem *portfolioItem = [portfolio findItemByIdentCodeSymbol:identSymbol];
	
	if(notifyObj) {
		commodityNum = portfolioItem->commodityNo;
    } else {
        commodityNum = 0;
    }
	
	NSDate *today = [NSDate date];
    
    NSDate *startDate = [today dayOffset:-364];
    
	UInt16 sDate, eDate;

	if ([mainDict count] > 0) {
        NSDictionary *tmpDict = [[mainDict objectForKey:@"IIG1Array"] objectAtIndex:0];
        sDate = [[tmpDict objectForKey:@"RecordDate"] unsignedIntValue];
//		sDate = [self getLastRecordDate];
		if (!sDate) {
            sDate = [startDate uint16Value];
        }else{
            NSDate *recordDate =  [[[NSNumber numberWithUnsignedInt:sDate] uint16ToDate] dayOffset:1];;
            sDate = [recordDate uint16Value];
        }
	} else {
        // 完全沒資料
        sDate = [startDate uint16Value];
    }
 
	eDate = [today uint16Value];
	
    
	InvesterBSOut *BSOut1 = [[InvesterBSOut alloc] initWithCommodityNum:portfolioItem->commodityNo
                                                                IIG_ID:1 StartDate:sDate EndDate:eDate];
    if ([mainDict count] > 0) {
        NSDictionary *tmpDict = [[mainDict objectForKey:@"IIG2Array"] objectAtIndex:0];
        sDate = [[tmpDict objectForKey:@"RecordDate"] unsignedIntValue];
        //		sDate = [self getLastRecordDate];
        if (!sDate) {
            sDate = [startDate uint16Value];
        }else{
            NSDate *recordDate =  [[[NSNumber numberWithUnsignedInt:sDate] uint16ToDate] dayOffset:1];;
            sDate = [recordDate uint16Value];
        }
        
    } else {
        // 完全沒資料
        sDate = [startDate uint16Value];
    }
    InvesterBSOut *BSOut2 = [[InvesterBSOut alloc] initWithCommodityNum:portfolioItem->commodityNo
                                                                IIG_ID:2 StartDate:sDate EndDate:eDate];
    if ([mainDict count] > 0) {
        NSDictionary *tmpDict = [[mainDict objectForKey:@"IIG3Array"] objectAtIndex:0];
        sDate = [[tmpDict objectForKey:@"RecordDate"] unsignedIntValue];
        //		sDate = [self getLastRecordDate];
        if (!sDate) {
            sDate = [startDate uint16Value];
        }else{
            NSDate *recordDate =  [[[NSNumber numberWithUnsignedInt:sDate] uint16ToDate] dayOffset:1];;
            sDate = [recordDate uint16Value];
        }
    } else {
        // 完全沒資料
        sDate = [startDate uint16Value];
    }
    InvesterBSOut *BSOut3 = [[InvesterBSOut alloc] initWithCommodityNum:portfolioItem->commodityNo
                                                                IIG_ID:3 StartDate:sDate EndDate:eDate];
	if ([mainDict count] > 0) {
		NSDictionary *tmpDict = [[mainDict objectForKey:@"Hold1Array"] objectAtIndex:0];
		if (tmpDict) {
			sDate = [[tmpDict objectForKey:@"RecordDate"] unsignedIntValue];
        } else {
			sDate = [startDate uint16Value];
        }
	
    } else {
        sDate = [startDate uint16Value];
    }
    
    

    IIG1 = NO;
    IIG2 = NO;
    IIG3 = NO;
    
    
	InvesterHoldOut *holdOut = [[InvesterHoldOut alloc] initWithCommodityNum:portfolioItem->commodityNo
                                                                      IIG_ID:1 StartDate:sDate EndDate:eDate];
	[FSDataModelProc sendData:self WithPacket:BSOut1];
    [FSDataModelProc sendData:self WithPacket:BSOut2];
    [FSDataModelProc sendData:self WithPacket:BSOut3];

	[FSDataModelProc sendData:self WithPacket:holdOut];
	[datalock unlock];
}

- (void)decodeInvesterBSArrive:(InvesterBSIn*)obj
{
	NSMutableArray *bsArray = obj->investerArray;
	[datalock lock];
    
	if(fetchObj && commodityNum != obj->commodityNum)
	{
		fetchObj.commodityNum = obj->commodityNum;
		[fetchObj decodeInvesterBSArrive:obj];
	}
	else if(commodityNum == obj->commodityNum)
	{
		if ([bsArray count] > 0)
		{
			InvesterBSData *is = [bsArray objectAtIndex:0];
			NSMutableDictionary *dateDict = [mainDict objectForKey:@"DateDict"];
			if(dateDict == nil)
			{
				dateDict = [[NSMutableDictionary alloc] init];
				[mainDict setObject:dateDict forKey:@"DateDict"];
			}
			
            if(is->IIG_ID == 1)   //外資買賣
			{
                IIG1 = YES;
				BOOL releaseFlag = NO;
				NSMutableArray *IIGArray = [mainDict objectForKey:@"IIG1Array"];
				if(!IIGArray)
				{
					IIGArray = [[NSMutableArray alloc] init];
					releaseFlag = YES;
				}
				else
				{
					NSDictionary *checkDict = [IIGArray objectAtIndex:0];
					for(InvesterBSData *bsData in bsArray)
					{
						if(bsData->date == [[checkDict objectForKey:@"RecordDate"] unsignedIntValue])
						{
							[IIGArray removeObjectAtIndex:0];
							break;
						}
					}
				}
				int i=0;
				for(InvesterBSData *bsData in bsArray)
				{
					NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:bsData->date] forKey:@"RecordDate"];
					[tmpDict setObject:[NSNumber numberWithDouble:bsData->buyShares] forKey:@"Today Buy"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:bsData->buySharesUnit] forKey:@"Today Buy Unit"];
					[tmpDict setObject:[NSNumber numberWithDouble:bsData->sellShares] forKey:@"Today Sell"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:bsData->sellSharesUnit] forKey:@"Today Sell Unit"];
					[tmpDict setObject:[NSNumber numberWithDouble:bsData->buySell] forKey:@"Difference"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:bsData->buySellUnit] forKey:@"Difference Unit"];
					[IIGArray insertObject:tmpDict atIndex:i++];
					[dateDict setObject:@"Date" forKey:[NSString stringWithFormat:@"%d",bsData->date]];
				}
				[self sortArray:IIGArray];
				[mainDict setObject:IIGArray forKey:@"IIG1Array"];
			}
			else if(is->IIG_ID == 2)   //投信買賣
			{
                IIG2 = YES;
				BOOL releaseFlag = NO;
				NSMutableArray *IIGArray = [mainDict objectForKey:@"IIG2Array"];
				if(!IIGArray)
				{
					IIGArray = [[NSMutableArray alloc] init];
					releaseFlag = YES;
				}
				else
				{
					NSDictionary *checkDict = [IIGArray objectAtIndex:0];
					for(InvesterBSData *bsData in bsArray)
					{
						if(bsData->date == [[checkDict objectForKey:@"RecordDate"] unsignedIntValue])
						{
							[IIGArray removeObjectAtIndex:0];
							break;
						}
					}
				}
				int i=0;
				for(InvesterBSData *bsData in bsArray)
				{
					NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:bsData->date] forKey:@"RecordDate"];
					[tmpDict setObject:[NSNumber numberWithDouble:bsData->buyShares] forKey:@"Today Buy"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:bsData->buySharesUnit] forKey:@"Today Buy Unit"];
					[tmpDict setObject:[NSNumber numberWithDouble:bsData->sellShares] forKey:@"Today Sell"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:bsData->sellSharesUnit] forKey:@"Today Sell Unit"];
					[tmpDict setObject:[NSNumber numberWithDouble:bsData->buySell] forKey:@"Difference"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:bsData->buySellUnit] forKey:@"Difference Unit"];
					[IIGArray insertObject:tmpDict atIndex:i++];
					[dateDict setObject:@"Date" forKey:[NSString stringWithFormat:@"%d",bsData->date]];
				}
				[self sortArray:IIGArray];
				[mainDict setObject:IIGArray forKey:@"IIG2Array"];
			}
			else if(is->IIG_ID == 3)   //自營商
			{
                IIG3 = YES;
				BOOL releaseFlag = NO;
				NSMutableArray *IIGArray = [mainDict objectForKey:@"IIG3Array"];
				if(!IIGArray)
				{
					IIGArray = [[NSMutableArray alloc] init];
					releaseFlag = YES;
				}
				else
				{
					NSDictionary *checkDict = [IIGArray objectAtIndex:0];
					for(InvesterBSData *bsData in bsArray)
					{
						if(bsData->date == [[checkDict objectForKey:@"RecordDate"] unsignedIntValue])
						{
							[IIGArray removeObjectAtIndex:0];
							break;
						}
					}
				}
				int i=0;
				for(InvesterBSData *bsData in bsArray)
				{
					NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:bsData->date] forKey:@"RecordDate"];
					[tmpDict setObject:[NSNumber numberWithDouble:bsData->buyShares] forKey:@"Today Buy"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:bsData->buySharesUnit] forKey:@"Today Buy Unit"];
					[tmpDict setObject:[NSNumber numberWithDouble:bsData->sellShares] forKey:@"Today Sell"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:bsData->sellSharesUnit] forKey:@"Today Sell Unit"];
					[tmpDict setObject:[NSNumber numberWithDouble:bsData->buySell] forKey:@"Difference"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:bsData->buySellUnit] forKey:@"Difference Unit"];
					[IIGArray insertObject:tmpDict atIndex:i++];
					[dateDict setObject:@"Date" forKey:[NSString stringWithFormat:@"%d",bsData->date]];
				}
				[self sortArray:IIGArray];
				[mainDict setObject:IIGArray forKey:@"IIG3Array"];
			}
		}
		if (obj->retCode == 0)
		{
			if(notifyObj) {
                if (IIG1 && IIG2 && IIG3) {
                    IIG1 = NO;
                    IIG2 = NO;
                    IIG3 = NO;
                }
                [notifyObj performSelectorOnMainThread:@selector(notifyInvesterBSData) withObject:nil waitUntilDone:NO];
            }
			[self saveToFile];
		}
	}
	[datalock unlock];
}

- (void)sortArray:(NSMutableArray*)array
{
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"RecordDate" ascending:NO selector:@selector(compare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	[array sortUsingDescriptors:sortDescriptors];
	
}

- (void)decodeInvesterHoldArrive:(InvesterHoldIn*)obj;
{
	NSMutableArray *bsArray = obj->investerArray;
	[datalock lock];
    
    NSMutableDictionary *dateDict = [mainDict objectForKey:@"DateDict"];
    if(dateDict == nil)
    {
        dateDict = [[NSMutableDictionary alloc] init];
        [mainDict setObject:dateDict forKey:@"DateDict"];
    }
	
    //	else   //法人持有
	if(fetchObj && commodityNum != obj->commodityNum)
	{
		fetchObj.commodityNum = obj->commodityNum;
		[fetchObj decodeInvesterHoldArrive:obj];
	}
	else if(commodityNum == obj->commodityNum)
	{
		if ([bsArray count] > 0)
		{
			//		checkArrive++;
			//		[bsArray removeObjectAtIndex:0];
			InvesterHoldData *is = [bsArray objectAtIndex:0];
			if(is->IIG_ID == 1)   //外資持有
			{
				BOOL releaseFlag = NO;
				NSMutableArray *IIGArray = [mainDict objectForKey:@"Hold1Array"];
				if(!IIGArray)
				{
					IIGArray = [[NSMutableArray alloc] init];
					releaseFlag = YES;
				}
				else
				{
					[IIGArray removeObjectAtIndex:0];
				}
				int i=0;
				for(InvesterHoldData *holdData in bsArray)
				{
					NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:holdData->date] forKey:@"RecordDate"];
					
					[tmpDict setObject:[NSNumber numberWithDouble:holdData->ownShares] forKey:@"Own hold"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:holdData->ownSharesUnit] forKey:@"Own hold Unit"];
					[tmpDict setObject:[NSNumber numberWithDouble:holdData->ownRatio] forKey:@"Ratio"];
					[tmpDict setObject:[NSNumber numberWithUnsignedInt:holdData->ownRatioUnit] forKey:@"Ratio Unit"];
					[IIGArray insertObject:tmpDict atIndex:i++];
                    [dateDict setObject:@"Date" forKey:[NSString stringWithFormat:@"%d",holdData->date]];
				}
				
				//[self sortArray:IIGArray];
				
				[mainDict setObject:IIGArray forKey:@"Hold1Array"];
			}
		}
		if (obj->retCode == 0)
		{
			
			NSMutableArray *Hold1Array = [mainDict objectForKey:@"Hold1Array"];
			[self sortArray:Hold1Array];
			
			if(notifyObj)
				[notifyObj performSelectorOnMainThread:@selector(notifyInvesterHoldData) withObject:nil waitUntilDone:NO];
			//		checkArrive = 0;
			[self saveToFile];
		}
		
	}
	[datalock unlock];
}

- (void)saveToFile
{
	[datalock lock];
    
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ InvesterBS.plist",identSymbol]];
	BOOL success = [mainDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"InvesterBS wirte error!!");
	[datalock unlock];
}

- (void)setTargetNotify:(id)obj
{
	notifyObj = obj;
    
    if (obj == nil) {
        IIG1 = NO;
        IIG2 = NO;
        IIG3 = NO;
    }
}

- (void)discardData
{
	[datalock lock];
	self.identSymbol = nil;
	self.mainDict = nil;
	notifyObj = nil;
    //	checkArrive = 0;
	[datalock unlock];
}

- (int)getRowCount
{
	[datalock lock];
	NSDictionary *dateDict = [mainDict objectForKey:@"DateDict"];
	[datalock unlock];
	if(dateDict)
	{
		return (int)[dateDict count];
	}
	else
		return 0;
	
}

- (NSArray *)getAllDateArray {
    NSArray *dateArray = [[mainDict objectForKey:@"DateDict"] allKeys];
	dateArray = [dateArray sortedArrayUsingSelector:@selector(compare:)];
    return dateArray;
}


- (NSArray *)getRowDataWithIndex:(int)index
{
	[datalock lock];
	if([mainDict count]==0)
	{
		[datalock unlock];
		return nil;
	}
	NSArray *IIG1Array = [mainDict objectForKey:@"IIG1Array"];
	NSArray *IIG2Array = [mainDict objectForKey:@"IIG2Array"];
	NSArray *IIG3Array = [mainDict objectForKey:@"IIG3Array"];
	NSArray *dateArray = [[mainDict objectForKey:@"DateDict"] allKeys];
	dateArray = [dateArray sortedArrayUsingSelector:@selector(compare:)];
	int recordDate = [(NSNumber *)[dateArray objectAtIndex:([dateArray count]-index-1)] intValue];
	
	NSMutableArray *Hold1Array = [mainDict objectForKey:@"Hold1Array"];
	
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	NSMutableDictionary *tmpArray1 = [[NSMutableDictionary alloc] init];	//法人買賣用
	NSMutableDictionary *tmpArray2 = [[NSMutableDictionary alloc] init];	//法人持有
	for(NSDictionary *bsDict1 in IIG1Array)  //外資法人
	{
		InvesterBSData *bsData1 = [[InvesterBSData alloc] init];
		bsData1->date = [[bsDict1 objectForKey:@"RecordDate"] unsignedIntValue];
		if(recordDate > bsData1->date) //代表下面沒這個日期了
		{
			break;
		}
		if(recordDate == bsData1->date)
		{
			bsData1->buyShares = [(NSNumber *)[bsDict1 objectForKey:@"Today Buy"] doubleValue];
			bsData1->buySharesUnit = [(NSNumber *)[bsDict1 objectForKey:@"Today Buy Unit"] unsignedIntValue];
			bsData1->sellShares = [(NSNumber *)[bsDict1 objectForKey:@"Today Sell"] doubleValue];
			bsData1->sellSharesUnit = [(NSNumber *)[bsDict1 objectForKey:@"Today Sell Unit"] unsignedIntValue];
			bsData1->buySell = [(NSNumber *)[bsDict1 objectForKey:@"Difference"] doubleValue];
			bsData1->buySellUnit = [(NSNumber *)[bsDict1 objectForKey:@"Difference Unit"] unsignedIntValue];
			[tmpArray1 setObject:bsData1 forKey:@"Data1"];
			break;
		}
	}
	for(NSDictionary *bsDict2 in IIG2Array)  //投信
	{
		InvesterBSData *bsData2 = [[InvesterBSData alloc] init];
		bsData2->date = [[bsDict2 objectForKey:@"RecordDate"] unsignedIntValue];
		if(recordDate > bsData2->date) //代表下面沒這個日期了
		{
			break;
		}
		if(recordDate == bsData2->date)
		{
			bsData2->buyShares = [(NSNumber *)[bsDict2 objectForKey:@"Today Buy"] doubleValue];
			bsData2->buySharesUnit = [(NSNumber *)[bsDict2 objectForKey:@"Today Buy Unit"] unsignedIntValue];
			bsData2->sellShares = [(NSNumber *)[bsDict2 objectForKey:@"Today Sell"] doubleValue];
			bsData2->sellSharesUnit = [(NSNumber *)[bsDict2 objectForKey:@"Today Sell Unit"] unsignedIntValue];
			bsData2->buySell = [(NSNumber *)[bsDict2 objectForKey:@"Difference"] doubleValue];
			bsData2->buySellUnit = [[bsDict2 objectForKey:@"Difference Unit"] unsignedIntValue];
			[tmpArray1 setObject:bsData2 forKey:@"Data2"];
			break;
		}
	}
	for(NSDictionary *bsDict3 in IIG3Array)  //持有
	{
		InvesterBSData *bsData3 = [[InvesterBSData alloc] init];
		bsData3->date = [[bsDict3 objectForKey:@"RecordDate"] unsignedIntValue];
		if(recordDate > bsData3->date) //代表下面沒這個日期了
		{
			break;
		}
		if(recordDate == bsData3->date)
		{
			bsData3->buyShares = [(NSNumber *)[bsDict3 objectForKey:@"Today Buy"] doubleValue];
			bsData3->buySharesUnit = [(NSNumber *)[bsDict3 objectForKey:@"Today Buy Unit"] unsignedIntValue];
			bsData3->sellShares = [(NSNumber *)[bsDict3 objectForKey:@"Today Sell"] doubleValue];
			bsData3->sellSharesUnit = [(NSNumber *)[bsDict3 objectForKey:@"Today Sell Unit"] unsignedIntValue];
			bsData3->buySell = [(NSNumber *)[bsDict3 objectForKey:@"Difference"] doubleValue];
			bsData3->buySellUnit = [(NSNumber *)[bsDict3 objectForKey:@"Difference Unit"] unsignedIntValue];
			[tmpArray1 setObject:bsData3 forKey:@"Data3"];
			break;
		}
	}
	for(NSDictionary *holdDict in Hold1Array)  //投信
	{
		InvesterHoldData *holdData = [[InvesterHoldData alloc] init];
		holdData->date = [[holdDict objectForKey:@"RecordDate"] unsignedIntValue];
		//NSLog(@"cell index %d record dae:%d, holdData->date:%d",index,recordDate,holdData->date);
		if(recordDate > holdData->date) //holdData時間由新至舊遞減 , 代表下面沒這個日期了
		{
			//NSLog(@"break");
			break;
		}
		if(recordDate == holdData->date)
		{
			//NSLog(@"got");
			holdData->ownShares = [(NSNumber *)[holdDict objectForKey:@"Own hold"] doubleValue]; //外資持有
			holdData->ownSharesUnit = [[holdDict objectForKey:@"Own hold Unit"] unsignedIntValue];
			holdData->ownRatio = [(NSNumber *)[holdDict objectForKey:@"Ratio"] doubleValue]; //比率
			holdData->ownRatioUnit = [[holdDict objectForKey:@"Ratio Unit"] unsignedIntValue];
			[tmpArray2 setObject:holdData forKey:@"holdData"];
			break;
		}
	}
	[returnArray addObject:tmpArray1]; // Data1 , Data2 , Data3
	[returnArray addObject:tmpArray2]; // holdData
    [returnArray addObject:[NSNumber numberWithInt:recordDate]]; // holdData
	[datalock unlock];
	return returnArray;	 //UI那要release
}



/* 取得外資買賣統計 */
- (NSUInteger)getIIG1StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate {
    
    [datalock lock];
	if ([mainDict count] == 0) {
		[datalock unlock];
//		return nil;
	}
    
    // 取得外資買賣
    NSArray *IIG1Array = [mainDict objectForKey:@"IIG1Array"];
    
    // 建立儲存用資料結構
    int buySellTotal = 0;
	for (NSDictionary *bsDict1 in IIG1Array) {
        
		UInt16 recordDate = [[bsDict1 objectForKey:@"RecordDate"] unsignedShortValue];
        
        
        if (startDate <= recordDate && recordDate <= endDate) {
            int a = [(NSNumber *)[bsDict1 objectForKey:@"Difference"] intValue];
            buySellTotal += a;
        }
	}
    
	[datalock unlock];
    
	return buySellTotal;
}

- (double)getIndexIIG1StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate {
    [datalock lock];
    if ([mainDict count] == 0) {
        [datalock unlock];
        //		return nil;
    }
    
    // 取得外資買賣
    NSArray *IIG1Array = [mainDict objectForKey:@"IIG1Array"];
    
    // 建立儲存用資料結構
    double buySellTotal = 0;
    for (NSDictionary *bsDict1 in IIG1Array) {
        
        UInt16 recordDate = [[bsDict1 objectForKey:@"RecordDate"] unsignedShortValue];
        
        
        if (startDate <= recordDate && recordDate <= endDate) {
            double a = [(NSNumber *)[bsDict1 objectForKey:@"Difference"] doubleValue] * pow(1000, [(NSNumber *)[bsDict1 objectForKey:@"Difference Unit"] intValue]) / pow(10, 8);
            buySellTotal += a;
        }
    }
    
    [datalock unlock];
    
    return buySellTotal;
}

/* 取得投信買賣統計 */
- (NSUInteger)getIIG2StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate {
    
    [datalock lock];
	if ([mainDict count] == 0) {
		[datalock unlock];
//		return nil;
	}
    
    // 取得投信買賣
    NSArray *IIG1Array = [mainDict objectForKey:@"IIG2Array"];
    
    // 建立儲存用資料結構
    unsigned int buySellTotal = 0;
	for (NSDictionary *bsDict1 in IIG1Array) {
        
		UInt16 recordDate = [[bsDict1 objectForKey:@"RecordDate"] unsignedIntValue];
        if (startDate <= recordDate && recordDate <= endDate) {
            int a = [[bsDict1 objectForKey:@"Difference"] unsignedIntValue];
            buySellTotal += a;
        }
	}
    
	[datalock unlock];
    
	return buySellTotal;
}

- (double)getIndexIIG2StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate {
    
    [datalock lock];
    if ([mainDict count] == 0) {
        [datalock unlock];
        //		return nil;
    }
    
    // 取得投信買賣
    NSArray *IIG1Array = [mainDict objectForKey:@"IIG2Array"];
    
    // 建立儲存用資料結構
    double buySellTotal = 0;
    for (NSDictionary *bsDict1 in IIG1Array) {
        
        UInt16 recordDate = [[bsDict1 objectForKey:@"RecordDate"] unsignedIntValue];
        if (startDate <= recordDate && recordDate <= endDate) {
            double a = [(NSNumber *)[bsDict1 objectForKey:@"Difference"] doubleValue] * pow(1000, [(NSNumber *)[bsDict1 objectForKey:@"Difference Unit"] intValue]) / pow(10, 8);
            buySellTotal += a;
        }
    }
    
    [datalock unlock];
    
    return buySellTotal;
}

/* 取得自營商統計 */
- (NSUInteger)getIIG3StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate {
    
    [datalock lock];
	if ([mainDict count] == 0) {
		[datalock unlock];
//		return nil;
	}
    
    // 取得自營商買賣
    NSArray *IIG1Array = [mainDict objectForKey:@"IIG3Array"];
    
    // 建立儲存用資料結構
    unsigned int buySellTotal = 0;
	for (NSDictionary *bsDict1 in IIG1Array) {
        
		UInt16 recordDate = [[bsDict1 objectForKey:@"RecordDate"] unsignedIntValue];
        if (startDate <= recordDate && recordDate <= endDate) {
            buySellTotal += [[bsDict1 objectForKey:@"Difference"] unsignedIntValue];
        }
	}
    
	[datalock unlock];
    
	return buySellTotal;
}

- (double)getIndexIIG3StatWithBetweenStartDate:(UInt16)startDate AndEndDate:(UInt16)endDate {
    
    [datalock lock];
    if ([mainDict count] == 0) {
        [datalock unlock];
        //		return nil;
    }
    
    // 取得自營商買賣
    NSArray *IIG1Array = [mainDict objectForKey:@"IIG3Array"];
    
    // 建立儲存用資料結構
    double buySellTotal = 0;
    for (NSDictionary *bsDict1 in IIG1Array) {
        
        UInt16 recordDate = [[bsDict1 objectForKey:@"RecordDate"] unsignedIntValue];
        if (startDate <= recordDate && recordDate <= endDate) {
            buySellTotal += [(NSNumber *)[bsDict1 objectForKey:@"Difference"] doubleValue] * pow(1000, [(NSNumber *)[bsDict1 objectForKey:@"Difference Unit"] intValue]) / pow(10, 8);
        }
    }
    
    [datalock unlock];
    
    return buySellTotal;
}

- (UInt16)getLastRecordDate {
    [datalock lock];
	if([mainDict count]==0)
	{
		[datalock unlock];
//		return nil;
	}
    
    NSArray *dateArray = [[mainDict objectForKey:@"DateDict"] allKeys];
	dateArray = [dateArray sortedArrayUsingSelector:@selector(compare:)];
	int recordDate = [(NSNumber *)[dateArray objectAtIndex:([dateArray count] - 1)] intValue];
    
    [datalock unlock];
    return recordDate;
}

- (UInt16)getLastIIGRecordDate {
    [datalock lock];
    if ([mainDict count] == 0) {
        [datalock unlock];
    }
    
    NSArray *IIG1Array = [mainDict objectForKey:@"IIG1Array"];
    NSArray *IIG2Array = [mainDict objectForKey:@"IIG2Array"];
    NSArray *IIG3Array = [mainDict objectForKey:@"IIG3Array"];
    
    NSDictionary *IIG1Dict = [IIG1Array objectAtIndex:0];
    NSDictionary *IIG2Dict = [IIG2Array objectAtIndex:0];
    NSDictionary *IIG3Dict = [IIG3Array objectAtIndex:0];
    
    int IIG1Date = [[IIG1Dict objectForKey:@"RecordDate"] unsignedIntValue];
    int IIG2Date = [[IIG2Dict objectForKey:@"RecordDate"] unsignedIntValue];
    int IIG3Date = [[IIG3Dict objectForKey:@"RecordDate"] unsignedIntValue];
    
    int max = IIG1Date;
    if (IIG2Date > max) max = IIG2Date;
    if (IIG3Date > max) max = IIG3Date;

    
    [datalock unlock];
    return max;
}

- (NSArray *)getDataForTodayUse
{
	[datalock lock];
	if([mainDict count]==0)
	{
		[datalock unlock];
		return nil;
	}
    
	NSArray *IIG1Array = [mainDict objectForKey:@"IIG1Array"];
	NSArray *IIG2Array = [mainDict objectForKey:@"IIG2Array"];
	NSArray *IIG3Array = [mainDict objectForKey:@"IIG3Array"];
    
    NSDictionary *IIG1Dict = [IIG1Array objectAtIndex:0];
    NSDictionary *IIG2Dict = [IIG2Array objectAtIndex:0];
    NSDictionary *IIG3Dict = [IIG3Array objectAtIndex:0];
    
    int IIG1Date = [[IIG1Dict objectForKey:@"RecordDate"] unsignedIntValue];
    int IIG2Date = [[IIG2Dict objectForKey:@"RecordDate"] unsignedIntValue];
    int IIG3Date = [[IIG3Dict objectForKey:@"RecordDate"] unsignedIntValue];
    
    int max = IIG1Date;
    if (IIG2Date > max) max = IIG2Date;
    if (IIG3Date > max) max = IIG3Date;
    
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    for (int i = 1; i <= 3; i++) {
		InvesterBSData *bsData = [[InvesterBSData alloc] init];
		NSDictionary *tmpDict;
		if(i == 1) {
            tmpDict = [IIG1Array objectAtIndex:0];
        } else if (i == 2) {
            tmpDict = [IIG2Array objectAtIndex:0];
        } else {
            tmpDict = [IIG3Array objectAtIndex:0];
        }
        
        if ([[tmpDict objectForKey:@"RecordDate"] unsignedIntValue] == max) {
            bsData->date = [[tmpDict objectForKey:@"RecordDate"] unsignedIntValue];
            bsData->buyShares = [(NSNumber *)[tmpDict objectForKey:@"Today Buy"] doubleValue];
            bsData->buySharesUnit = [[tmpDict objectForKey:@"Today Buy Unit"] unsignedIntValue];
            bsData->sellShares = [(NSNumber *)[tmpDict objectForKey:@"Today Sell"] doubleValue];
            bsData->sellSharesUnit = [[tmpDict objectForKey:@"Today Sell Unit"] unsignedIntValue];
            bsData->buySell = [(NSNumber *)[tmpDict objectForKey:@"Difference"] doubleValue];
            bsData->buySellUnit = [[tmpDict objectForKey:@"Difference Unit"] unsignedIntValue];
        } else {
            bsData->date = max;
            bsData->buyShares = 0;
            bsData->buySharesUnit = 0;
            bsData->sellShares = 0;
            bsData->sellSharesUnit = 0;
            bsData->buySell = 0;
            bsData->buySellUnit = 0;
        }
        
        [returnArray addObject:bsData];
	}
    
	[datalock unlock];
	return returnArray; //UI那邊要release
}

- (int) autofetch: (NSString*)identCodeSymbol
{
	if(!fetchObj)
		fetchObj = [[InvesterBS alloc] init];
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
