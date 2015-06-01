//
//  FinancialRatio.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FinancialRatio.h"
#import "FinanicalDataOut.h"
#import "FinanicalDataIn.h"

@interface FinancialRatio (){
    NSRecursiveLock * dataLock;
    NSMutableArray *symbol1Array;
    NSMutableArray *symbol1UnitArray;
    NSMutableArray *symbol2Array;
    NSMutableArray *symbol2UnitArray;
    NSMutableArray *symbol1AllArray;
	NSMutableArray *symbol1AllUnitArray;
    NSMutableArray *symbol2AllArray;
	NSMutableArray *symbol2AllUnitArray;
    NSString * symbol1;
    NSString * symbol2;
    UInt32 commodityNum1;
    UInt32 commodityNum2;
    
}

@end

@implementation FinancialRatio

- (id)init
{
	if(self = [super init])
	{
		_allKeyArray = [[NSMutableArray alloc] init];
        self.keyArray = [[NSMutableArray alloc] init];
		dataLock = [[NSRecursiveLock alloc] init];
        symbol1Array = [[NSMutableArray alloc] init];
        symbol1UnitArray = [[NSMutableArray alloc] init];
        symbol2Array = [[NSMutableArray alloc] init];
        symbol2UnitArray = [[NSMutableArray alloc] init];
        symbol1AllArray = [[NSMutableArray alloc] init];
        symbol1AllUnitArray = [[NSMutableArray alloc] init];
        symbol2AllArray = [[NSMutableArray alloc] init];
        symbol2AllUnitArray = [[NSMutableArray alloc] init];
        commodityNum1 = 0;
        commodityNum2 = 0;
        self.merge = YES;
		notifyObj = nil;
        [self addAllKey];
        [self addKey];

	}
	return self;
}

- (void)setTargetNotify:(id)obj
{
	notifyObj = obj;
}

- (void)loadSymbol1FromIdentSymbol:(NSString*)is
{
	[dataLock lock];
	symbol1 = is;
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ FinancialRatio.plist",symbol1]];
	NSDictionary *rootDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (rootDict != nil) {
        symbol1Array = [rootDict objectForKey:@"mainArray"];
        symbol1UnitArray = [rootDict objectForKey:@"mainUnitArray"];
    }
	
	[dataLock unlock];
}

- (void)loadSymbol2FromIdentSymbol:(NSString*)is
{
	[dataLock lock];
	symbol2 = is;
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ FinancialRatio.plist",symbol2]];
	NSDictionary *rootDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (rootDict != nil) {
        symbol2Array = [rootDict objectForKey:@"mainArray"];
        symbol2UnitArray = [rootDict objectForKey:@"mainUnitArray"];
	}
    [dataLock unlock];
}

- (void)saveToFileWithIdentCodeSymbol:(NSString *)identCodeSymbol MainArray:(NSMutableArray *)mainArray MainUnitArray:(NSMutableArray *)mainUnitArray Type:(UInt8)type
{
	[dataLock lock];
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *path;
    if (type == 'Q' || type == 'C') {
        path= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ FinancialRatio.plist",identCodeSymbol]];
    }else{
        path= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ MergeFinancialRatio.plist",identCodeSymbol]];
    }
    
	NSDictionary *tmpDict = [[NSDictionary alloc] initWithObjectsAndKeys:mainArray,@"mainArray",mainUnitArray,@"mainUnitArray",nil];
	BOOL success = [tmpDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"wirte error!!");
	[dataLock unlock];
}

- (void)sendAndReadWithSymbol1:(NSString *)identSymbol Type:(char)type
{
	[dataLock lock];
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:identSymbol];
	if(notifyObj)
		commodityNum1 = portfolioItem->commodityNo;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *today = [NSDate date];
	NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
	NSInteger year = [comps year];
	NSInteger month = [comps month];
	NSInteger day = [comps day];
	FinanicalDataOut *frOut = [[FinanicalDataOut alloc] initWithStartDate:[CodingUtil makeDate:year-3 month:month day:day] EndDate:[CodingUtil makeDate:year month:month day:day] CommodityNum:commodityNum1 DataType:type];
	[FSDataModelProc sendData:self WithPacket:frOut];
	[dataLock unlock];
}

- (void)sendAndReadWithSymbol2:(NSString *)identSymbol Type:(char)type
{
	[dataLock lock];
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:identSymbol];
	if(notifyObj)
		commodityNum2 = portfolioItem->commodityNo;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *today = [NSDate date];
	NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
	NSInteger year = [comps year];
	NSInteger month = [comps month];
	NSInteger day = [comps day];
    if(commodityNum1 != commodityNum2){
        FinanicalDataOut *frOut = [[FinanicalDataOut alloc] initWithStartDate:[CodingUtil makeDate:year-3 month:month day:day] EndDate:[CodingUtil makeDate:year month:month day:day] CommodityNum:commodityNum2 DataType:type];
        [FSDataModelProc sendData:self WithPacket:frOut];
    }
	[dataLock unlock];
}

- (void)decodeArrive:(FinanicalDataIn*)obj;
{
	NSMutableArray* isArray = obj->finanicalArray;
	[dataLock lock];
	if(commodityNum1 == obj->commodityNum || commodityNum2 == obj->commodityNum)
	{
		if (commodityNum1 == obj->commodityNum) {
            if (obj->dataType == 'Q' || obj->dataType == 'C') {
                [symbol1Array removeAllObjects];
                [symbol1UnitArray removeAllObjects];
            }else{
                [symbol1AllArray removeAllObjects];
                [symbol1AllUnitArray removeAllObjects];
            }
            
        }else{
            if (obj->dataType == 'Q' || obj->dataType == 'C') {
                [symbol2Array removeAllObjects];
                [symbol2UnitArray removeAllObjects];
            }else{
                [symbol2AllArray removeAllObjects];
                [symbol2AllUnitArray removeAllObjects];
            }
        }
		if ([isArray count] > 0)
		{
			FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
			PortfolioItem *portfolioItem = [dataModal.portfolioData findInPortfolio:obj->commodityNum];
			NSString *idents;
			if(portfolioItem)
				idents = [NSString stringWithFormat:@"%c%c %@",portfolioItem->identCode[0],portfolioItem->identCode[1],portfolioItem->symbol];
			else 
				idents = @"NULL";
			
			for(FinanicalParam *fParam in isArray)
			{
				
				int i=0,j=0;
				NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
				NSMutableDictionary *tmpUnitDict = [[NSMutableDictionary alloc] init];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy/MM/dd"];
                
				[tmpDict setObject:[NSNumber numberWithUnsignedInt:[self setDateToSeasonWithDate:fParam->date]] forKey:@"RecordDate"];
                [tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:[self setDateToSeasonWithDate:fParam->date]] forKey:@"RecordDate"];
				[tmpDict setObject:idents forKey:@"IdentSymbol"];
                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->priceEps] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->priceEpsUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:-0.0f] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:0] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->priceSales] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->pirceSalesUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->avgDividendYield] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->avgDividendYieldUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->payoutRatio] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->payoutRatioUnit] forKey:[_keyArray objectAtIndex:j++]];
                
                [tmpDict setObject:[NSNumber numberWithDouble:fParam->grossMargin] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->grossMarginUnit] forKey:[_keyArray objectAtIndex:j++]];
                
                [tmpDict setObject:[NSNumber numberWithDouble:fParam->operatingMargin] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->operatingMarginUnit] forKey:[_keyArray objectAtIndex:j++]];
                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->preTaxMargin] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->preTaxMarginUnit] forKey:[_keyArray objectAtIndex:j++]];
                
                [tmpDict setObject:[NSNumber numberWithDouble:fParam->netProfitMargin] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->netProfitMarginUnit] forKey:[_keyArray objectAtIndex:j++]];
                
                [tmpDict setObject:[NSNumber numberWithDouble:fParam->salesGrowthRatio] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->salesGrowthRatioUnit] forKey:[_keyArray objectAtIndex:j++]];
                
                [tmpDict setObject:[NSNumber numberWithDouble:fParam->netGrowthRatio] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->netGrowthRatioUnit] forKey:[_keyArray objectAtIndex:j++]];
                
                [tmpDict setObject:[NSNumber numberWithDouble:fParam->netValues] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->netValuesUnit] forKey:[_keyArray objectAtIndex:j++]];
                
                [tmpDict setObject:[NSNumber numberWithDouble:fParam->arDay] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->arDayUnit] forKey:[_keyArray objectAtIndex:j++]];
                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->sales5yrGrowthRate] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->sales5yrGrowthRateUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->eps5yrGrowthRate] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->eps5yrGrowthRateUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->capex5yrGrowthRate] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->capex5yrGrowthRateUnit] forKey:[_keyArray objectAtIndex:j++]];

                [tmpDict setObject:[NSNumber numberWithDouble:fParam->currentRatio] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->currentRatioUnit] forKey:[_keyArray objectAtIndex:j++]];
                
                [tmpDict setObject:[NSNumber numberWithDouble:fParam->quickRatio] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->quickRatioUnit] forKey:[_keyArray objectAtIndex:j++]];
                
                [tmpDict setObject:[NSNumber numberWithDouble:fParam->debtToEquity] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->debtToEquityUnit] forKey:[_keyArray objectAtIndex:j++]];
                
                [tmpDict setObject:[NSNumber numberWithDouble:fParam->debtToAsset] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->debtToAssetUnit] forKey:[_keyArray objectAtIndex:j++]];
                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->interestCoverage] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->interestCoverageUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->returnOnAsset] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->returnOnAssetUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->returnOnAsset5yrAvg] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->returnOnAsset5yrAvgUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->returnOnInvestment] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->returnOnInvestmentUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->returnOnInvestment5yrAvg] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->returnOnInvestment5yrAvgUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->returnOnEquity] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->returnOnEquityUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->returnOnEquity5yrAvg] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->returnOnEquity5yrAvgUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->revenueEmployee] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->revenueEmployeeUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->netIcomeEmployee] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->netIcomeEmployeeUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->receivableTurnover] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->receivableTurnoverUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->inventoryTurnover] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->inventoryTurnoverUnit] forKey:[_keyArray objectAtIndex:j++]];
//                
//                [tmpDict setObject:[NSNumber numberWithDouble:fParam->assetTurnover] forKey:[_keyArray objectAtIndex:i++]];
//				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:fParam->assetTurnoverUnit] forKey:[_keyArray objectAtIndex:j++]];
                
                if (commodityNum1 == obj->commodityNum) {
                    if (obj->dataType == 'Q' || obj->dataType == 'C') {
                        [symbol1Array addObject:tmpDict];
                        [symbol1UnitArray addObject:tmpUnitDict];
                    }else{
                        [symbol1AllArray addObject:tmpDict];
                        [symbol1AllUnitArray addObject:tmpUnitDict];
                    }
                    
                }else{
                    if (obj->dataType == 'Q' || obj->dataType == 'C') {
                        [symbol2Array addObject:tmpDict];
                        [symbol2UnitArray addObject:tmpUnitDict];
                    }else{
                        [symbol2AllArray addObject:tmpDict];
                        [symbol2AllUnitArray addObject:tmpUnitDict];
                    }
                    
                }
			}
			if (commodityNum1 == obj->commodityNum) {
                if (obj->dataType == 'Q' || obj->dataType == 'C') {
                    [self sortArray:symbol1Array];
                    [self sortArray:symbol1UnitArray];
                }else{
                    [self sortArray:symbol1AllArray];
                    [self sortArray:symbol1AllUnitArray];
                }
                
            }else{
                if (obj->dataType == 'Q' || obj->dataType == 'C') {
                    [self sortArray:symbol2Array];
                    [self sortArray:symbol2UnitArray];
                }else{
                    [self sortArray:symbol2AllArray];
                    [self sortArray:symbol2AllUnitArray];
                }
            }
			if (obj->retCode == 0)
			{
                if (commodityNum1 == obj->commodityNum) {
                    if(notifyObj)
                        [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"FinancialRatio1" waitUntilDone:NO];
                    if (obj->dataType == 'Q' || obj->dataType == 'R'){
                        [self saveToFileWithIdentCodeSymbol:idents MainArray:symbol1Array MainUnitArray:symbol1UnitArray Type:'Q'];
                        [self saveToFileWithIdentCodeSymbol:idents MainArray:symbol1AllArray MainUnitArray:symbol1AllUnitArray Type:'R'];
                    }else{
                        [self saveToFileWithIdentCodeSymbol:idents MainArray:symbol1Array MainUnitArray:symbol1UnitArray Type:'C'];
                        [self saveToFileWithIdentCodeSymbol:idents MainArray:symbol1AllArray MainUnitArray:symbol1AllUnitArray Type:'D'];
                    }
                    
                    
                    
                }else{
                    if(notifyObj)
                        [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"FinancialRatio2" waitUntilDone:NO];
                    if (obj->dataType == 'Q' || obj->dataType == 'R'){
                        [self saveToFileWithIdentCodeSymbol:idents MainArray:symbol2Array MainUnitArray:symbol2UnitArray Type:'Q'];
                        [self saveToFileWithIdentCodeSymbol:idents MainArray:symbol2AllArray MainUnitArray:symbol2AllUnitArray Type:'R'];
                    }else{
                        [self saveToFileWithIdentCodeSymbol:idents MainArray:symbol2Array MainUnitArray:symbol2UnitArray Type:'C'];
                        [self saveToFileWithIdentCodeSymbol:idents MainArray:symbol2AllArray MainUnitArray:symbol2AllUnitArray Type:'D'];
                    }
                    
                }
							}
		}else{
            if(notifyObj)
                [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"FinancialRatioNoData" waitUntilDone:NO];
        }
//		if (obj->retCode == 0 && [identSymbol hash] == autoFetingNo && identSymbol) // autofetch next sector;
//		{
//			autoFetingNo = 0;
//            //neil
////			[dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
//		}
	}
	[dataLock unlock];
}	

- (void)sortArray:(NSMutableArray *)array
{
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"RecordDate" ascending:NO selector:@selector(compare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	[array sortUsingDescriptors:sortDescriptors];
}

-(UInt16)setDateToSeasonWithDate:(UInt16)date{
    UInt16 season = 0;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM"];
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"yyyy"];
    NSDateFormatter *newDateFormat = [[NSDateFormatter alloc] init];
    [newDateFormat setDateFormat:@"yyyy/MM/dd"];
    NSString * yearStr =[dateFormat2 stringFromDate:[[NSNumber numberWithUnsignedInt:date]uint16ToDate]];
    NSString *month = [dateFormat stringFromDate:[[NSNumber numberWithUnsignedInt:date] uint16ToDate]];
    int mon = [month intValue];
    if (mon>=1 && mon<4) {
        season = [[newDateFormat dateFromString:[NSString stringWithFormat:@"%@/03/31",yearStr]]uint16Value];
    }else if (mon>3 && mon<7) {
        season = [[newDateFormat dateFromString:[NSString stringWithFormat:@"%@/06/30",yearStr]]uint16Value];
    }else if (mon>6 && mon<10) {
        season = [[newDateFormat dateFromString:[NSString stringWithFormat:@"%@/09/30",yearStr]]uint16Value];
    }else if (mon>9 && mon<13) {
        season = [[newDateFormat dateFromString:[NSString stringWithFormat:@"%@/12/31",yearStr]]uint16Value];
    }
    
    return  season;
}

-(int)dateToQuarter:(NSNumber *)date{
    NSDate * dateD = [date uint16ToDate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM"];
    NSString *month = [dateFormat stringFromDate:dateD];
    
    int  q;
    if([month intValue]>=1 && [month intValue]<4){
        q = 1;
    }else if([month intValue]>3 && [month intValue]<7){
        q = 2;
    }else if([month intValue]>6 && [month intValue]<10){
        q = 3;
    }else{
        q = 4;
    }
    return q;
}

-(int)dateToYear:(NSNumber *)date{
    NSDate * dateD = [date uint16ToDate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy"];
    NSString *year = [dateFormat stringFromDate:dateD];
    
    return [year intValue];
}


- (UInt16)findDateByIdentSymbol:(NSString*)is Postion:(int)pos
{
	[dataLock lock];
    NSMutableArray * mainArray;
    if ([is isEqualToString:symbol1]) {
        if (_merge) {
            mainArray = symbol1AllArray;
        }else{
            mainArray = symbol1Array;
        }
        
    }else{
        if (_merge) {
            mainArray = symbol2AllArray;
        }
        else{
            mainArray = symbol2Array;
        }
        
    }
	UInt16 date = 0;
	for(int i=0 ; i<[mainArray count] && pos>=0 ; i++)
	{
		NSDictionary *tmpDict = [mainArray objectAtIndex:i];
		NSString *tmpIS = [tmpDict objectForKey:@"IdentSymbol"];
		if([tmpIS isEqualToString:is])
		{
			pos--;
		}
		else
			continue;
		if(pos>=0)
			continue;
		date = [[tmpDict objectForKey:@"RecordDate"] unsignedIntValue];
	}
	[dataLock unlock];
	return date;
}

- (int)getDateCountByIdentSymbol:(NSString*)is
{
	[dataLock lock];
    int dateCount = 0;
    
    if ([is isEqualToString:symbol1]) {
        if (_merge) {
            dateCount = (int)[symbol1AllArray count];
        }else{
            dateCount = (int)[symbol1Array count];
        }
        
    }else{
        if (_merge) {
            dateCount = (int)[symbol2AllArray count];
        }else{
            dateCount = (int)[symbol2Array count];
        }
        
    }
    
	[dataLock unlock];
	return dateCount;
}

- (int)getRowCount:(int)index
{
	[dataLock lock];
	if(_keyArray != nil)
	{
		[dataLock unlock];
		return (int)[_keyArray count];
	}
	else {
		[dataLock unlock];
		return 0;
	}
}

- (TAvalueParam *)getRowDataWithIdentSymbol:(NSString*)is RowTitle:(NSString *)RowTitle Index:(int)index
{
    [dataLock lock];
    NSMutableArray * dataArray;
    NSMutableArray * dataUnitArray;
    if ([is isEqualToString:symbol1]) {
        if (_merge) {
            dataArray = symbol1AllArray;
            dataUnitArray = symbol1AllUnitArray;
        }else{
            dataArray = symbol1Array;
            dataUnitArray = symbol1UnitArray;
        }
    }else{
        if (_merge) {
            dataArray = symbol2AllArray;
            dataUnitArray = symbol2AllUnitArray;
        }else{
            dataArray = symbol2Array;
            dataUnitArray = symbol2UnitArray;
        }
        
    }
    
    NSDictionary *tmpUnitDict;
    NSDictionary *tmpDict;
    if(index<[dataArray count]){
        tmpDict = [dataArray objectAtIndex:index];
    }
    if (index<[dataUnitArray count]) {
        tmpUnitDict = [dataUnitArray objectAtIndex:index];
    }
    
    TAvalueParam *taParam = [[TAvalueParam alloc] init];
    if ([RowTitle isEqualToString:@"Profitability Ratios"] || [RowTitle isEqualToString:@"Growth Rates"] || [RowTitle isEqualToString:@"Financial Strength"] || [RowTitle isEqualToString:@"Management Effectiveness"] || [RowTitle isEqualToString:@"Efficiency"]) {
        taParam->value = -0.00 ;
        taParam->unit = 0;
        taParam.nameString = RowTitle;
    }else{
        if ([dataArray count]==0) {
            taParam->value = -0.00 ;
            taParam->unit = 0;
        }else{
            taParam->value = [(NSNumber *)[tmpDict objectForKey:RowTitle]doubleValue];
            taParam->unit = [(NSNumber *)[tmpUnitDict objectForKey:RowTitle]intValue];
        }
        taParam.nameString = RowTitle;
    }
    
	[dataLock unlock];
    return taParam;
}

-(void)calculateWithWithIdentSymbol:(NSString*)is Index:(int)index Data:(NSMutableDictionary *)data Date:(UInt16)date{
    
    NSMutableArray * dataArray;
    NSMutableArray * dataUnitArray;
    if ([is isEqualToString:symbol1]) {
        if (_merge) {
            dataArray = symbol1AllArray;
            dataUnitArray = symbol1AllUnitArray;
        }else{
            dataArray = symbol1Array;
            dataUnitArray = symbol1UnitArray;
        }
    }else{
        if (_merge) {
            dataArray = symbol2AllArray;
            dataUnitArray = symbol2AllUnitArray;
        }else{
            dataArray = symbol2Array;
            dataUnitArray = symbol2UnitArray;
        }
        
    }
    
    NSDictionary *tmpUnitDict;
    NSDictionary *tmpDict;
    if(index<[dataArray count]){
        tmpDict = [dataArray objectAtIndex:index];
    }
    if (index<[dataUnitArray count]) {
        tmpUnitDict = [dataUnitArray objectAtIndex:index];
    }
    
    
    
    NSDictionary * incomeDict = [self getDataDictionaryWithData:[data objectForKey:@"incomeValueDict"] Date:date];
    
    NSDictionary *incomeTmpUnitDict = [incomeDict objectForKey:@"unitDict"];
    NSDictionary *incomeTmpDict = [incomeDict objectForKey:@"valueDict"];
    
    NSDictionary * beforeYearIncomeDict = [self getDataDictionaryWithData:[data objectForKey:@"incomeValueDict"] Date:[[[[NSNumber numberWithUnsignedInt:date] uint16ToDate] yearOffset:-1] uint16Value]];
    
    NSDictionary *beforeYearIncomeTmpUnitDict = [beforeYearIncomeDict objectForKey:@"unitDict"];
    NSDictionary *beforeYearIncomeTmpDict = [beforeYearIncomeDict objectForKey:@"valueDict"];
    
    NSDictionary * beforeMonthIncomeDict = [self getDataWithData:[data objectForKey:@"incomeValueDict"] BeforeDate:date];
    
    NSDictionary * beforeMonthIncomeTmpUnitDict = [beforeMonthIncomeDict objectForKey:@"unitDict"];
    NSDictionary * beforeMonthIncomeTmpDict = [beforeMonthIncomeDict objectForKey:@"valueDict"];
    
    NSDictionary * beforeYearBeforeMonthIncomeDict = [self getDataWithData:[data objectForKey:@"incomeValueDict"] BeforeDate:[[[[NSNumber numberWithUnsignedInt:date] uint16ToDate] yearOffset:-1] uint16Value]];
    
    NSDictionary * beforeYearBeforeMonthIncomeTmpUnitDict = [beforeYearBeforeMonthIncomeDict objectForKey:@"unitDict"];
    NSDictionary * beforeYearBeforeMonthIncomeTmpDict = [beforeYearBeforeMonthIncomeDict objectForKey:@"valueDict"];
    
    
    NSDictionary * balanceDict = [self getDataDictionaryWithData:[data objectForKey:@"balanceValueDict"] Date:date];
    
    NSDictionary *balanceTmpUnitDict = [balanceDict objectForKey:@"unitDict"];
    NSDictionary *balanceTmpValueDict = [balanceDict objectForKey:@"valueDict"];
    
    NSDictionary * beforeYearBalanceDict = [self getDataDictionaryWithData:[data objectForKey:@"balanceValueDict"] Date:[[[[NSNumber numberWithUnsignedInt:date] uint16ToDate] yearOffset:-1] uint16Value]];
    
    NSDictionary *beforeYearBalanceTmpUnitDict = [beforeYearBalanceDict objectForKey:@"unitDict"];
    NSDictionary *beforeYearBalanceTmpDict = [beforeYearBalanceDict objectForKey:@"valueDict"];
    
    
    NSDictionary * beforeMonthBalanceDict = [self getLastDataWithData:[data objectForKey:@"balanceValueDict"] BeforeDate:date];
    
    NSDictionary * beforeMonthBalanceTmpUnitDict = [beforeMonthBalanceDict objectForKey:@"unitDict"];
    NSDictionary * beforeMonthBalanceTmpDict = [beforeMonthBalanceDict objectForKey:@"valueDict"];
    
    int Q = [self dateToQuarter:[NSNumber numberWithUnsignedInt:date]];
    
    int setQ = Q *-3;
    
    UInt16 offsetDate = [[[[NSNumber numberWithUnsignedInt:date] uint16ToDate] monthOffset:setQ] uint16Value];
    
    if (Q == 2 || Q == 3) {
        offsetDate = [[[[NSNumber numberWithUnsignedInt:offsetDate] uint16ToDate] dayOffset:1] uint16Value];
    }
    
    NSDictionary * beforeEndOfYearBalanceDict = [self getDataDictionaryWithData:[data objectForKey:@"balanceValueDict"] Date:offsetDate];
    
    NSDictionary * beforeEndOfYearBalanceTmpUnitDict = [beforeEndOfYearBalanceDict objectForKey:@"unitDict"];
    NSDictionary * beforeEndOfYearBalanceTmpDict = [beforeEndOfYearBalanceDict objectForKey:@"valueDict"];

    
    
    //營業毛利率
    float revenue = [(NSNumber *)[incomeTmpDict objectForKey:@"Total Revenue"]floatValue] * pow(1000, [(NSNumber *)[incomeTmpUnitDict objectForKey:@"Total Revenue"]intValue]);
    float beforeMonthRevenue = [(NSNumber *)[beforeMonthIncomeTmpDict objectForKey:@"Total Revenue"]floatValue] * pow(1000, [(NSNumber *)[beforeMonthIncomeTmpUnitDict objectForKey:@"Total Revenue"]intValue]);
    
    float grossProfit = [(NSNumber *)[incomeTmpDict objectForKey:@"Gross Profit"]floatValue] * pow(1000, [(NSNumber *)[incomeTmpUnitDict objectForKey:@"Gross Profit"]intValue]);
    float beforeMonthGrossProfit = [(NSNumber *)[beforeMonthIncomeTmpDict objectForKey:@"Gross Profit"]floatValue] * pow(1000, [(NSNumber *)[beforeMonthIncomeTmpUnitDict objectForKey:@"Gross Profit"]intValue]);
    
    
    if(_total){
        [tmpDict setValue:[NSNumber numberWithFloat:grossProfit/revenue] forKey:@"Gross Margin"];
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:(grossProfit - beforeMonthGrossProfit)/(revenue - beforeMonthRevenue)] forKey:@"Gross Margin"];
    }
    
    
    //營業利益率
    float operatingIncome = [(NSNumber *)[incomeTmpDict objectForKey:@"Operating Income"]floatValue] * pow(1000, [(NSNumber *)[incomeTmpUnitDict objectForKey:@"Operating Income"]intValue]);
    
    float beforeMonthOperatingIncome = [(NSNumber *)[beforeMonthIncomeTmpDict objectForKey:@"Operating Income"]floatValue] * pow(1000, [(NSNumber *)[beforeMonthIncomeTmpUnitDict objectForKey:@"Operating Income"]intValue]);
    
    if(_total){
        [tmpDict setValue:[NSNumber numberWithFloat:operatingIncome/revenue] forKey:@"Operating Margin"];
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:(operatingIncome - beforeMonthOperatingIncome)/(revenue - beforeMonthRevenue)] forKey:@"Operating Margin"];
    }
    
    
    
    //稅前淨利率
    float beforeMonthBefortTex = [(NSNumber *)[beforeMonthIncomeTmpDict objectForKey:@"Income Before Tax"]floatValue] * pow(1000, [(NSNumber *)[beforeMonthIncomeTmpUnitDict objectForKey:@"Income Before Tax"]intValue]);
    float befortTex = [(NSNumber *)[incomeTmpDict objectForKey:@"Income Before Tax"]floatValue] * pow(1000, [(NSNumber *)[incomeTmpUnitDict objectForKey:@"Income Before Tax"]intValue]);
    
    if(_total){
        [tmpDict setValue:[NSNumber numberWithFloat:befortTex/revenue] forKey:@"Pre-Tax Margin"];
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:(befortTex - beforeMonthBefortTex)/(revenue - beforeMonthRevenue)] forKey:@"Pre-Tax Margin"];
    }
    
    
    //稅後淨利率
    float netIncome = [(NSNumber *)[incomeTmpDict objectForKey:@"Net Income"]floatValue] * pow(1000, [(NSNumber *)[incomeTmpUnitDict objectForKey:@"Net Income"]intValue]);
    float beforeMonthNetIncome = [(NSNumber *)[beforeMonthIncomeTmpDict objectForKey:@"Net Income"]floatValue] * pow(1000, [(NSNumber *)[beforeMonthIncomeTmpUnitDict objectForKey:@"Net Income"]intValue]);
    
    if(_total){
        [tmpDict setValue:[NSNumber numberWithFloat:netIncome/revenue] forKey:@"Net Profit Margin"];
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:(netIncome - beforeMonthNetIncome)/(revenue - beforeMonthRevenue)] forKey:@"Net Profit Margin"];
    }

    
    //每股營業額
    float commonStock = [(NSNumber *)[balanceTmpValueDict objectForKey:@"Common Stock"]floatValue] * pow(1000, [(NSNumber *)[balanceTmpUnitDict objectForKey:@"Common Stock"]intValue]);
    
    if(_total){
        [tmpDict setValue:[NSNumber numberWithFloat:revenue/(commonStock/10)] forKey:@"Sale Value Per Share"];
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:(revenue - beforeMonthRevenue)/(commonStock/10)] forKey:@"Sale Value Per Share"];
    }
    
    //每股營業利益
    if(_total){
        [tmpDict setValue:[NSNumber numberWithFloat:operatingIncome/(commonStock/10)] forKey:@"Profit Value Per Share"];
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:(operatingIncome-beforeMonthOperatingIncome)/(commonStock/10)] forKey:@"Profit Value Per Share"];
    }
    
    //每股稅前淨利
    if(_total){
        [tmpDict setValue:[NSNumber numberWithFloat:befortTex/(commonStock/10)] forKey:@"Pre-Tax Profit Value Per Share"];
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:(befortTex-beforeMonthBefortTex)/(commonStock/10)] forKey:@"Pre-Tax Profit Value Per Share"];
    }
    
    //每股稅後淨利
    if(_total){
        [tmpDict setValue:[NSNumber numberWithFloat:netIncome/(commonStock/10)] forKey:@"Net Profit Value Per Share"];
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:(netIncome - beforeMonthNetIncome)/(commonStock/10)] forKey:@"Net Profit Value Per Share"];
    }
    
    //股東權益報酬率
    
    float totalStockholderEquity = [(NSNumber *)[balanceTmpValueDict objectForKey:@"Total Stockholder Equity"]floatValue] * pow(1000, [(NSNumber *)[balanceTmpUnitDict objectForKey:@"Total Stockholder Equity"]intValue]);
    float beforeYearTotalStockholderEquity = [(NSNumber *)[beforeYearBalanceTmpDict objectForKey:@"Total Stockholder Equity"]floatValue] * pow(1000, [(NSNumber *)[beforeYearBalanceTmpUnitDict objectForKey:@"Total Stockholder Equity"]intValue]);
    float equityRewardsRate;
    if (beforeYearBalanceTmpDict) {
        if(_total){
           equityRewardsRate = netIncome/((totalStockholderEquity + beforeYearTotalStockholderEquity)/2);
        }else{
            equityRewardsRate = (netIncome-beforeMonthNetIncome)/((totalStockholderEquity + beforeYearTotalStockholderEquity)/2);
        }
        
        [tmpDict setValue:[NSNumber numberWithFloat:equityRewardsRate] forKey:@"Equity Rewards Rate"];
    }else {
        equityRewardsRate = 0;
        [tmpDict setValue:@"-0" forKey:@"Equity Rewards Rate"];
    }
    
    //資產報酬率
    float totalAssets = [(NSNumber *)[balanceTmpValueDict objectForKey:@"Total Assets"]floatValue] * pow(1000, [(NSNumber *)[balanceTmpUnitDict objectForKey:@"Total Assets"]intValue]);
    float beforeYeartotalAssets = [(NSNumber *)[beforeYearBalanceTmpDict objectForKey:@"Total Assets"]floatValue] * pow(1000, [(NSNumber *)[beforeYearBalanceTmpUnitDict objectForKey:@"Total Assets"]intValue]);
    
    float interestExpense = [(NSNumber *)[incomeTmpDict objectForKey:@"Interest Expense"]floatValue] * pow(1000, [(NSNumber *)[incomeTmpUnitDict objectForKey:@"Interest Expense"]intValue]);//利息支出
    float beforeMonthInterestExpense = [(NSNumber *)[beforeMonthIncomeTmpDict objectForKey:@"Interest Expense"]floatValue] * pow(1000, [(NSNumber *)[beforeMonthIncomeTmpUnitDict objectForKey:@"Interest Expense"]intValue]);
    
    float incomeTaxExpense = [(NSNumber *)[incomeTmpDict objectForKey:@"Income Tax Expense"]floatValue] * pow(1000, [(NSNumber *)[incomeTmpUnitDict objectForKey:@"Income Tax Expense"]intValue]);//所得稅費用
    float beforeMonthIncomeTaxExpense = [(NSNumber *)[beforeMonthIncomeTmpDict objectForKey:@"Income Tax Expense"]floatValue] * pow(1000, [(NSNumber *)[beforeMonthIncomeTmpUnitDict objectForKey:@"Income Tax Expense"]intValue]);
    
    
    float texRate;
    float assetRewardsRate;
    if (beforeYearBalanceTmpDict) {
        if (_total) {
            texRate = incomeTaxExpense/befortTex;
            assetRewardsRate = (netIncome + interestExpense * (1-texRate))/((totalAssets + beforeYeartotalAssets)/2);
        }else{
            texRate = (incomeTaxExpense - beforeMonthIncomeTaxExpense)/(befortTex- beforeMonthBefortTex);
            assetRewardsRate = ((netIncome-beforeMonthNetIncome) + (interestExpense -beforeMonthInterestExpense) * (1-texRate))/((totalAssets + beforeYeartotalAssets)/2);
        }
        
        [tmpDict setValue:[NSNumber numberWithFloat:assetRewardsRate] forKey:@"Asset Rewards Rate"];
    }else{
        assetRewardsRate = 0;
        [tmpDict setValue:@"-0" forKey:@"Asset Rewards Rate"];
    }
    
    //財務槓桿指數
    if (equityRewardsRate ==0 || assetRewardsRate == 0) {
        [tmpDict setValue:@"-0" forKey:@"Index Of Financial Lever"];
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:equityRewardsRate/assetRewardsRate] forKey:@"Index Of Financial Lever"];
    }
    
    //營收成長率
    float beforeYearRevenue = [(NSNumber *)[beforeYearIncomeTmpDict objectForKey:@"Total Revenue"]floatValue] * pow(1000, [(NSNumber *)[beforeYearIncomeTmpUnitDict objectForKey:@"Total Revenue"]intValue]);
    
    float beforeYearBeforeMonthRevenue = [(NSNumber *)[beforeYearBeforeMonthIncomeTmpDict objectForKey:@"Total Revenue"]floatValue] * pow(1000, [(NSNumber *)[beforeYearBeforeMonthIncomeTmpUnitDict objectForKey:@"Total Revenue"]intValue]);
    
    
    if (beforeYearIncomeTmpDict) {
        if (_total) {
            [tmpDict setValue:[NSNumber numberWithFloat:(revenue - beforeYearRevenue)/beforeYearRevenue] forKey:@"Sales Growth Rate"];
        }else{
            [tmpDict setValue:[NSNumber numberWithFloat:((revenue-beforeMonthRevenue) - (beforeYearRevenue-beforeYearBeforeMonthRevenue))/(beforeYearRevenue-beforeYearBeforeMonthRevenue)] forKey:@"Sales Growth Rate"];
        }
        
    }else{
        [tmpDict setValue:@"-0" forKey:@"Sales Growth Rate"];
    }

    
    
    //營業利益成長率
    float beforeYearOperatingIncome = [(NSNumber *)[beforeYearIncomeTmpDict objectForKey:@"Operating Income"]floatValue] * pow(1000, [(NSNumber *)[beforeYearIncomeTmpUnitDict objectForKey:@"Operating Income"]intValue]);
    
    float beforeYearBeforeMonthOperatingIncome = [(NSNumber *)[beforeYearBeforeMonthIncomeTmpDict objectForKey:@"Operating Income"]floatValue] * pow(1000, [(NSNumber *)[beforeYearBeforeMonthIncomeTmpUnitDict objectForKey:@"Operating Income"]intValue]);
    
    
    if (beforeYearIncomeTmpDict) {
        if (_total) {
           [tmpDict setValue:[NSNumber numberWithFloat:(operatingIncome - beforeYearOperatingIncome)/beforeYearOperatingIncome] forKey:@"Operating Margin Growth Rate"];
        }else{
            [tmpDict setValue:[NSNumber numberWithFloat:((operatingIncome-beforeMonthOperatingIncome) - (beforeYearOperatingIncome-beforeYearBeforeMonthOperatingIncome))/(beforeYearOperatingIncome-beforeYearBeforeMonthOperatingIncome)] forKey:@"Operating Margin Growth Rate"];
        }
        
    }else{
        [tmpDict setValue:@"-0" forKey:@"Operating Margin Growth Rate"];
    }
    
    //稅前淨利成長率
    float beforeYearBefortTex = [(NSNumber *)[beforeYearIncomeTmpDict objectForKey:@"Income Before Tax"]floatValue] * pow(1000, [(NSNumber *)[beforeYearIncomeTmpUnitDict objectForKey:@"Income Before Tax"]intValue]);
    float beforeYearBeforeMonthBefortTex = [(NSNumber *)[beforeYearBeforeMonthIncomeTmpDict objectForKey:@"Income Before Tax"]floatValue] * pow(1000, [(NSNumber *)[beforeYearBeforeMonthIncomeTmpUnitDict objectForKey:@"Income Before Tax"]intValue]);
    
    if (beforeYearIncomeTmpDict) {
        if (_total) {
            [tmpDict setValue:[NSNumber numberWithFloat:(befortTex - beforeYearBefortTex)/beforeYearBefortTex] forKey:@"Pre-Tax Profit Growth Rate"];
        }else{
            [tmpDict setValue:[NSNumber numberWithFloat:((befortTex - beforeMonthBefortTex) - (beforeYearBefortTex-beforeYearBeforeMonthBefortTex))/(beforeYearBefortTex-beforeYearBeforeMonthBefortTex)] forKey:@"Pre-Tax Profit Growth Rate"];
        }
        
    }else{
        [tmpDict setValue:@"-0" forKey:@"Pre-Tax Profit Growth Rate"];
    }
    
    //稅後淨利成長率
    float beforeYearNetIncome = [(NSNumber *)[beforeYearIncomeTmpDict objectForKey:@"Net Income"]floatValue] * pow(1000, [(NSNumber *)[beforeYearIncomeTmpUnitDict objectForKey:@"Net Income"]intValue]);
    float beforeYearBeforeMonthNetIncome = [(NSNumber *)[beforeYearBeforeMonthIncomeTmpDict objectForKey:@"Net Income"]floatValue] * pow(1000, [(NSNumber *)[beforeYearBeforeMonthIncomeTmpUnitDict objectForKey:@"Net Income"]intValue]);
    
    if (beforeYearIncomeTmpDict) {
        if (_total) {
            [tmpDict setValue:[NSNumber numberWithFloat:(netIncome - beforeYearNetIncome)/beforeYearNetIncome] forKey:@"Net Profit Growth Rate"];
        }else{
            [tmpDict setValue:[NSNumber numberWithFloat:((netIncome - beforeMonthNetIncome) - (beforeYearNetIncome-beforeYearBeforeMonthNetIncome))/(beforeYearNetIncome-beforeYearBeforeMonthNetIncome)] forKey:@"Net Profit Growth Rate"];
        }
        
    }else{
        [tmpDict setValue:@"-0" forKey:@"Net Profit Growth Rate"];
    }
    
    //總資產成長率
    if (beforeYearBalanceTmpDict) {
        
        [tmpDict setValue:[NSNumber numberWithFloat:(totalAssets - beforeYeartotalAssets)/beforeYeartotalAssets] forKey:@"Total Asset Growth Rate"];
    }else{
        [tmpDict setValue:@"-0" forKey:@"Total Asset Growth Rate"];
    }
    
    //淨值成長率
    
    if (beforeYearBalanceTmpDict) {
        [tmpDict setValue:[NSNumber numberWithFloat:(totalStockholderEquity - beforeYearTotalStockholderEquity)/beforeYearTotalStockholderEquity] forKey:@"Net Asset Growth Rate"];
    }else{
        [tmpDict setValue:@"-0" forKey:@"Net Asset Growth Rate"];
    }
    
    //固定資產成長率
    float propertyPlantAndEquipment = [(NSNumber *)[balanceTmpValueDict objectForKey:@"Property Plant and Equipment"]floatValue] * pow(1000, [(NSNumber *)[balanceTmpUnitDict objectForKey:@"Property Plant and Equipment"]intValue]);
    float beforeYearPropertyPlantAndEquipment = [(NSNumber *)[beforeYearBalanceTmpDict objectForKey:@"Property Plant and Equipment"]floatValue] * pow(1000, [(NSNumber *)[beforeYearBalanceTmpUnitDict objectForKey:@"Property Plant and Equipment"]intValue]);
    if (beforeYearBalanceTmpDict) {
        [tmpDict setValue:[NSNumber numberWithFloat:(propertyPlantAndEquipment - beforeYearPropertyPlantAndEquipment)/beforeYearPropertyPlantAndEquipment] forKey:@"Fixed Asset Growth Rate"];
    }else{
        [tmpDict setValue:@"-0" forKey:@"Fixed Asset Growth Rate"];
    }
    
    
    //現金比率
    float cash = [(NSNumber *)[balanceTmpValueDict objectForKey:@"Cash And Cash Equivalents"]floatValue] * pow(1000, [(NSNumber *)[balanceTmpUnitDict objectForKey:@"Cash And Cash Equivalents"]intValue]);
    
    float currentLiabilities = [(NSNumber *)[balanceTmpValueDict objectForKey:@"Total Current Liabilities"]floatValue] * pow(1000, [(NSNumber *)[balanceTmpUnitDict objectForKey:@"Total Current Liabilities"]intValue]);
    
    [tmpDict setValue:[NSNumber numberWithFloat:cash/currentLiabilities] forKey:@"Cash Ratio"];
    
    //現金流量比率
    float cashFromOperatingActivities = [(NSNumber *)[incomeTmpDict objectForKey:@"Cash from Operating Activities"]floatValue] * pow(1000, [(NSNumber *)[incomeTmpUnitDict objectForKey:@"Cash from Operating Activities"]intValue]);
    float beforeCashFromOperatingActivities = [(NSNumber *)[beforeMonthIncomeTmpDict objectForKey:@"Cash from Operating Activities"]floatValue] * pow(1000, [(NSNumber *)[beforeMonthIncomeTmpUnitDict objectForKey:@"Cash from Operating Activities"]intValue]);
    
    if (_total) {
        [tmpDict setValue:[NSNumber numberWithFloat:cashFromOperatingActivities/currentLiabilities] forKey:@"Cash Flow Ratio"];
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:(cashFromOperatingActivities-beforeCashFromOperatingActivities)/currentLiabilities] forKey:@"Cash Flow Ratio"];
    }
    
    
    
    
    //應收帳款週轉率
    float netReceivables  = [(NSNumber *)[balanceTmpValueDict objectForKey:@"Net Receivables"]floatValue] * pow(1000, [(NSNumber *)[balanceTmpUnitDict objectForKey:@"Net Receivables"]intValue]);
    float beforeMonthNetReceivables = [(NSNumber *)[beforeMonthBalanceTmpDict objectForKey:@"Net Receivables"]floatValue] * pow(1000, [(NSNumber *)[beforeMonthBalanceTmpUnitDict objectForKey:@"Net Receivables"]intValue]);
    
    float beforeEndOfYearNetReceivables = [(NSNumber *)[beforeEndOfYearBalanceTmpDict objectForKey:@"Net Receivables"]floatValue] * pow(1000, [(NSNumber *)[beforeEndOfYearBalanceTmpUnitDict objectForKey:@"Net Receivables"]intValue]);
    
    
    float receivableTurnoverRate = 0;
    
    if (beforeEndOfYearBalanceDict) {
        if (_total) {
            receivableTurnoverRate = (revenue * 12/(3*[self dateToQuarter:[NSNumber numberWithUnsignedInt:date]]))/((netReceivables + beforeEndOfYearNetReceivables)/2);
        
        }else{
            if (beforeMonthNetReceivables == -0) {
                [tmpDict setValue:@"-0" forKey:@"Receivable Turnover Rate"];
            }else{
                receivableTurnoverRate = ((revenue-beforeMonthRevenue) * 4)/((netReceivables + beforeMonthNetReceivables)/2);
            }
            
            
        }
        [tmpDict setValue:[NSNumber numberWithFloat:receivableTurnoverRate] forKey:@"Receivable Turnover Rate"];
    }else{
        [tmpDict setValue:@"-0" forKey:@"Receivable Turnover Rate"];
    }
    
    //應收帳款收現天數
    if (receivableTurnoverRate!=0) {
        [tmpDict setValue:[NSNumber numberWithFloat:365/receivableTurnoverRate] forKey:@"Receivable Days"];
    }else{
        [tmpDict setValue:@"-0" forKey:@"Receivable Days"];
    }
    
    
    
    //存貨週轉率
    
    float costOfRevenue =fabsf([(NSNumber *)[incomeTmpDict objectForKey:@"Cost of Revenue"]floatValue] * pow(1000, [(NSNumber *)[incomeTmpUnitDict objectForKey:@"Cost of Revenue"]intValue]));//營業成本
    float beforeMonthCostOfRevenue =fabsf([(NSNumber *)[beforeMonthIncomeTmpDict objectForKey:@"Cost of Revenue"]floatValue] * pow(1000, [(NSNumber *)[beforeMonthIncomeTmpUnitDict objectForKey:@"Cost of Revenue"]intValue]));//營業成本
    
    float inventory  = [(NSNumber *)[balanceTmpValueDict objectForKey:@"Inventory"]floatValue] * pow(1000, [(NSNumber *)[balanceTmpUnitDict objectForKey:@"Inventory"]intValue]);
    float beforeInventory = [(NSNumber *)[beforeMonthBalanceTmpDict objectForKey:@"Inventory"]floatValue] * pow(1000, [(NSNumber *)[beforeMonthBalanceTmpUnitDict objectForKey:@"Inventory"]intValue]);
    float beforeEndOfYearInventory = [(NSNumber *)[beforeEndOfYearBalanceTmpDict objectForKey:@"Inventory"]floatValue] * pow(1000, [(NSNumber *)[beforeEndOfYearBalanceTmpUnitDict objectForKey:@"Inventory"]intValue]);
    
    float inventoryTurnoverRate = 0;
    if (beforeEndOfYearBalanceDict) {
        if (_total) {
            inventoryTurnoverRate = (costOfRevenue * 12/(3*[self dateToQuarter:[NSNumber numberWithUnsignedInt:date]]))/((inventory + beforeEndOfYearInventory)/2);
            [tmpDict setValue:[NSNumber numberWithFloat:inventoryTurnoverRate] forKey:@"Inventory Turnover Rate"];
            
        }else{
            inventoryTurnoverRate = ((costOfRevenue-beforeMonthCostOfRevenue) * 4)/((inventory + beforeInventory)/2);
            [tmpDict setValue:[NSNumber numberWithFloat:inventoryTurnoverRate] forKey:@"Inventory Turnover Rate"];
        }
        
    }else{
        inventoryTurnoverRate = 0;
        [tmpDict setValue:@"-0" forKey:@"Inventory Turnover Rate"];
    }
    
    //平均存貨天數
    if (inventoryTurnoverRate ==0) {
        [tmpDict setValue:@"-0" forKey:@"AVG Inventory Days"];
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:365/inventoryTurnoverRate] forKey:@"AVG Inventory Days"];
    }
    
    //固定資產週轉率
    if (_total) {
        [tmpDict setValue:[NSNumber numberWithFloat:(revenue * 12/(3*[self dateToQuarter:[NSNumber numberWithUnsignedInt:date]]))/propertyPlantAndEquipment] forKey:@"Fixed Asset Turnover Rate"];
            
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:((revenue - beforeMonthRevenue) * 4)/propertyPlantAndEquipment] forKey:@"Fixed Asset Turnover Rate"];
    }

    
    
    //總資產週轉率
    if (_total) {
        [tmpDict setValue:[NSNumber numberWithFloat:(revenue * 12/(3*[self dateToQuarter:[NSNumber numberWithUnsignedInt:date]]))/totalAssets] forKey:@"Total Asset Turnover Rate"];
            
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:((revenue - beforeMonthRevenue) * 4)/totalAssets] forKey:@"Total Asset Turnover Rate"];
    }


    //淨值週轉率
    if (_total) {
        [tmpDict setValue:[NSNumber numberWithFloat:(revenue * 12/(3*[self dateToQuarter:[NSNumber numberWithUnsignedInt:date]]))/totalStockholderEquity] forKey:@"Net Asset Turnover Rate"];
            
    }else{
        [tmpDict setValue:[NSNumber numberWithFloat:((revenue - beforeMonthRevenue) * 4)/totalStockholderEquity] forKey:@"Net Asset Turnover Rate"];
    }
    
    //長期資金適合率
    
    float deferredLTLiabilityCharges = [(NSNumber *)[balanceTmpValueDict objectForKey:@"Deferred LT Liability Charges"]floatValue] * pow(1000, [(NSNumber *)[balanceTmpUnitDict objectForKey:@"Deferred LT Liability Charges"]intValue]);
    
    [tmpDict setValue:[NSNumber numberWithFloat:(totalStockholderEquity + deferredLTLiabilityCharges)/propertyPlantAndEquipment] forKey:@"Long Capital Fit Rate"];
}

-(NSMutableDictionary *)getDataDictionaryWithData:(NSMutableDictionary *)data Date:(UInt16)date{
    NSMutableDictionary * dataDic = [[NSMutableDictionary alloc]init];
    NSMutableArray * dataArray;
    NSMutableArray * dataUnitArray;
    
    dataArray = [data objectForKey:@"valueArray"];
    dataUnitArray =  [data objectForKey:@"unitArray"];

    
    NSDictionary *tmpUnitDict;
    NSDictionary *tmpDict;
    
    int num = -1;
    
    for (int i=0; i<[dataArray count]; i++) {
        NSMutableDictionary * dic = [dataArray objectAtIndex:i];
        UInt16 objDate = [(NSNumber *)[dic objectForKey:@"RecordDate"]intValue];
        if (date == objDate) {
            num = i;
            break;
        }
        
    }
    
    if (num>=0) {
        tmpDict = [dataArray objectAtIndex:num];
        tmpUnitDict = [dataUnitArray objectAtIndex:num];
        [dataDic setObject:tmpDict forKey:@"valueDict"];
        [dataDic setObject:tmpUnitDict forKey:@"unitDict"];
    }
    
    return dataDic;
}


-(NSMutableDictionary *)getDataWithData:(NSMutableDictionary *)data BeforeDate:(UInt16)date{
    NSMutableDictionary * dataDic = [[NSMutableDictionary alloc]init];
    NSMutableArray * dataArray;
    NSMutableArray * dataUnitArray;
    
    dataArray = [data objectForKey:@"valueArray"];
    dataUnitArray =  [data objectForKey:@"unitArray"];
    
    int num = -1;
    
    for (int i=0; i<[dataArray count]; i++) {
        NSMutableDictionary * dic = [dataArray objectAtIndex:i];
        UInt16 objDate = [(NSNumber *)[dic objectForKey:@"RecordDate"]intValue];
        if (date == objDate) {
            num = i;
            break;
        }
        
    }
    
    NSDictionary *tmpUnitDict;
    NSDictionary *tmpDict;
    
    NSDictionary *beforeTmpUnitDict;
    NSDictionary *beforeTmpDict;
    
    if (num>=0) {
        tmpDict = [dataArray objectAtIndex:num];
        tmpUnitDict = [dataUnitArray objectAtIndex:num];
        
        int y = [self dateToYear:[tmpDict objectForKey:@"RecordDate"]];
        
        if (num+1<[dataArray count]) {
            beforeTmpUnitDict = [dataUnitArray objectAtIndex:num+1];
            beforeTmpDict = [dataArray objectAtIndex:num+1];
            
            int beforeY = [self dateToYear:[beforeTmpDict objectForKey:@"RecordDate"]];
            if (beforeY == y) {
                [dataDic setObject:beforeTmpDict forKey:@"valueDict"];
                [dataDic setObject:beforeTmpUnitDict forKey:@"unitDict"];
            }
        }

    }
    
    return dataDic;
}

-(NSMutableDictionary *)getLastDataWithData:(NSMutableDictionary *)data BeforeDate:(UInt16)date{
    NSMutableDictionary * dataDic = [[NSMutableDictionary alloc]init];
    NSMutableArray * dataArray;
    NSMutableArray * dataUnitArray;
    
    dataArray = [data objectForKey:@"valueArray"];
    dataUnitArray =  [data objectForKey:@"unitArray"];
    
    int num = -1;
    
    for (int i=0; i<[dataArray count]; i++) {
        NSMutableDictionary * dic = [dataArray objectAtIndex:i];
        UInt16 objDate = [(NSNumber *)[dic objectForKey:@"RecordDate"]intValue];
        if (date == objDate) {
            num = i;
            break;
        }
        
    }
    
    NSDictionary *tmpUnitDict;
    NSDictionary *tmpDict;
    
    NSDictionary *beforeTmpUnitDict;
    NSDictionary *beforeTmpDict;
    
    if (num>=0) {
        tmpDict = [dataArray objectAtIndex:num];
        tmpUnitDict = [dataUnitArray objectAtIndex:num];
        
        if (num+1<[dataArray count]) {
            beforeTmpUnitDict = [dataUnitArray objectAtIndex:num+1];
            beforeTmpDict = [dataArray objectAtIndex:num+1];
            
            [dataDic setObject:beforeTmpDict forKey:@"valueDict"];
            [dataDic setObject:beforeTmpUnitDict forKey:@"unitDict"];
        }
        
    }
    
    return dataDic;
}

- (void)addAllKey
{
    [_allKeyArray removeAllObjects];
	[_allKeyArray addObject:@"Profitability Ratios"];//標題：獲利能力
    
	[_allKeyArray addObject:@"Gross Margin"];//營業毛利率
	[_allKeyArray addObject:@"Operating Margin"];//營業利益率
    [_allKeyArray addObject:@"Pre-Tax Margin"];//稅前淨利率
	[_allKeyArray addObject:@"Net Profit Margin"];//稅後淨利率
    [_allKeyArray addObject:@"Net Asset Value Per Share"];//每股淨值
    [_allKeyArray addObject:@"Sale Value Per Share"];//每股營業額
    [_allKeyArray addObject:@"Profit Value Per Share"];//每股營業利益
    [_allKeyArray addObject:@"Pre-Tax Profit Value Per Share"];//每股稅前淨利
    [_allKeyArray addObject:@"Net Profit Value Per Share"];//每股稅後淨利
    [_allKeyArray addObject:@"Equity Rewards Rate"];//股東權益報酬率
    [_allKeyArray addObject:@"Asset Rewards Rate"];//資產報酬率
    [_allKeyArray addObject:@"Index Of Financial Lever"];//財務槓桿指數
	
	//Growth Rates
    [_allKeyArray addObject:@"Growth Rates"];//成長能力
    
	[_allKeyArray addObject:@"Sales Growth Rate"];//營收成長率
    [_allKeyArray addObject:@"Operating Margin Growth Rate"];//營業利益成長率
    [_allKeyArray addObject:@"Pre-Tax Profit Growth Rate"];//稅前淨利成長率
	[_allKeyArray addObject:@"Net Profit Growth Rate"];//稅後淨利成長率
    [_allKeyArray addObject:@"Total Asset Growth Rate"];//總資產成長率
    [_allKeyArray addObject:@"Net Asset Growth Rate"];//淨值成長率
	[_allKeyArray addObject:@"Fixed Asset Growth Rate"];//固定資產成長率
    
    //Financial Strength
	[_allKeyArray addObject:@"Financial Strength"];//償債能力
    
	[_allKeyArray addObject:@"Current Ratio"];//流動比率
	[_allKeyArray addObject:@"Quick Ratio"];//速動比率
	[_allKeyArray addObject:@"Total Debt to Assest"];//負債比率
    [_allKeyArray addObject:@"Cash Ratio"];//現金比率
	[_allKeyArray addObject:@"Cash Flow Ratio"];//現金流量比率
    
    
    //Management Effectiveness
    [_allKeyArray addObject:@"Management Effectiveness"];//經營能力
    
    [_allKeyArray addObject:@"Receivable Turnover Rate"];//應收帳款週轉率
    [_allKeyArray addObject:@"Receivable Days"];//應收帳款收現天數
	[_allKeyArray addObject:@"Inventory Turnover Rate"];//存貨週轉率
	[_allKeyArray addObject:@"AVG Inventory Days"];//平均存貨天數
    [_allKeyArray addObject:@"Fixed Asset Turnover Rate"];//固定資產週轉率
	[_allKeyArray addObject:@"Total Asset Turnover Rate"];//總資產週轉率
    [_allKeyArray addObject:@"Net Asset Turnover Rate"];//淨值週轉率
    
    
    //Efficiency
    [_allKeyArray addObject:@"Efficiency"];//財務結構
    
    [_allKeyArray addObject:@"Total Debt to Equity"];//負債對淨值比率
    [_allKeyArray addObject:@"Long Capital Fit Rate"];//長期資金適合率
	
}

- (void)addKey
{
	if(_keyArray) [_keyArray removeAllObjects];
	[_keyArray addObject:@"Gross Margin"];
	[_keyArray addObject:@"Operating Margin"];
	[_keyArray addObject:@"Net Profit Margin"];
    [_keyArray addObject:@"Sales Growth Rate"];
	[_keyArray addObject:@"Net Profit Growth Rate"];
	[_keyArray addObject:@"Net Asset Value Per Share"];
	[_keyArray addObject:@"Receivable Days"];
    [_keyArray addObject:@"Current Ratio"];
	[_keyArray addObject:@"Quick Ratio"];
	[_keyArray addObject:@"Total Debt to Equity"];
	[_keyArray addObject:@"Total Debt to Assest"];
	

}

@end
