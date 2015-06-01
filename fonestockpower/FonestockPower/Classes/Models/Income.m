//
//  Income.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Income.h"
#import "IncomeDataIn.h"
#import "IncomeDataOut.h"

@interface Income (){
    NSMutableArray *allKeyArray;
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


@implementation Income

- (id)init
{
	if(self = [super init])
	{
        allKeyArray = [[NSMutableArray alloc] init];
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
		notifyObj = nil;
        self.merge = YES;
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
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ Income.plist",symbol1]];
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
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ Income.plist",symbol2]];
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
        path= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ Income.plist",identCodeSymbol]];
    }else{
        path= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ MergeIncome.plist",identCodeSymbol]];
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
	int year = (int)[comps year];
	int month = (int)[comps month];
	int day = (int)[comps day];
    //	removeFlag = YES;
    IncomeDataOut *incomeOut = [[IncomeDataOut alloc] initWithStartDate:[CodingUtil makeDate:year-3 month:month day:day] EndDate:[CodingUtil makeDate:year month:month day:day] CommodityNum:commodityNum1 DataType:type];
	[FSDataModelProc sendData:self WithPacket:incomeOut];
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
	int year = (int)[comps year];
	int month = (int)[comps month];
	int day = (int)[comps day];
    
    //	removeFlag = YES;

    if(commodityNum1 != commodityNum2){
        IncomeDataOut *incomeOut = [[IncomeDataOut alloc] initWithStartDate:[CodingUtil makeDate:year-3 month:month day:day] EndDate:[CodingUtil makeDate:year month:month day:day] CommodityNum:commodityNum2 DataType:type];
        [FSDataModelProc sendData:self WithPacket:incomeOut];
    }
	[dataLock unlock];
}

- (void)decodeArrive:(IncomeDataIn*)obj
{
	NSMutableArray *isArray = obj->incomeArray;
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
			NSString *identCodeSymbol;
			if(portfolioItem)
				identCodeSymbol = [NSString stringWithFormat:@"%c%c %@",portfolioItem->identCode[0],portfolioItem->identCode[1],portfolioItem->symbol];
			else
				identCodeSymbol = @"NULL";
			for(IncomeParam *is in isArray)
			{
				NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
				NSMutableDictionary *tmpUnitDict = [[NSMutableDictionary alloc] init];
				
				[tmpDict setObject:identCodeSymbol forKey:@"IdentSymbol"];
				[tmpDict setObject:[NSNumber numberWithUnsignedInt:[self setDateToSeasonWithDate:is->date]] forKey:@"RecordDate"];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:[self setDateToSeasonWithDate:is->date]] forKey:@"RecordDate"];
				
				int i=0,j=0;

                [tmpDict setObject:[NSNumber numberWithDouble:is->netSales] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->netSalesUnit] forKey:[_keyArray objectAtIndex:j]];
				j = ++i;

                [tmpDict setObject:[NSNumber numberWithDouble:is->costRevenue] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->costRevenueUnit] forKey:[_keyArray objectAtIndex:j]];
				j = ++i;

                [tmpDict setObject:[NSNumber numberWithDouble:is->grossProfit] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->grossProfitUnit] forKey:[_keyArray objectAtIndex:j]];
				j = ++i;
                
                if (!portfolioItem->identCode[0]=='T' && !portfolioItem->identCode[1] == 'W') {
                    [tmpDict setObject:[NSNumber numberWithDouble:is->rdExp] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->rdExpUnit] forKey:[_keyArray objectAtIndex:j]];
                    j = ++i;
                }
					
                if (!portfolioItem->identCode[0]=='T' && !portfolioItem->identCode[1] == 'W') {
					[tmpDict setObject:[NSNumber numberWithDouble:is->sga] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->sgaUnit] forKey:[_keyArray objectAtIndex:j]];
                    j = ++i;
                }

                if (!portfolioItem->identCode[0]=='T' && !portfolioItem->identCode[1] == 'W') {
                    [tmpDict setObject:[NSNumber numberWithDouble:is->depreciationAmortization] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->depreciationAmortizationUnit] forKey:[_keyArray objectAtIndex:j]];
                    j = ++i;
                }
                if (!portfolioItem->identCode[0]=='T' && !portfolioItem->identCode[1] == 'W') {
                    [tmpDict setObject:[NSNumber numberWithDouble:is->indirectExp] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->indirectExpUnit] forKey:[_keyArray objectAtIndex:j]];
                    j = ++i;
                }
                

                [tmpDict setObject:[NSNumber numberWithDouble:is->totalExpanse] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->totalExpanseUnit] forKey:[_keyArray objectAtIndex:j]];
				j = ++i;

                [tmpDict setObject:[NSNumber numberWithDouble:is->operatingIncome] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->operatingIncomeUnit] forKey:[_keyArray objectAtIndex:j]];
				j = ++i;

                if (!portfolioItem->identCode[0]=='T' && !portfolioItem->identCode[1] == 'W') {
                    [tmpDict setObject:[NSNumber numberWithDouble:is->nonOperatingGains] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->nonOperatingGainsUnit] forKey:[_keyArray objectAtIndex:j]];
                    j = ++i;
                }
                if (portfolioItem->identCode[0]=='T' && portfolioItem->identCode[1] == 'W') {
                    [tmpDict setObject:[NSNumber numberWithDouble:is->cashFlow] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->cashFlowUnit] forKey:[_keyArray objectAtIndex:j]];
                    j = ++i;
                    
                    [tmpDict setObject:[NSNumber numberWithDouble:is->interestIncome] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->interestIncomeUnit] forKey:[_keyArray objectAtIndex:j]];
                    j = ++i;
                    
                    [tmpDict setObject:[NSNumber numberWithDouble:is->interestExpanse] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->interestExpanseUnit] forKey:[_keyArray objectAtIndex:j]];
                    j = ++i;
                }
                

                [tmpDict setObject:[NSNumber numberWithDouble:is->investLose] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->investLoseUnit] forKey:[_keyArray objectAtIndex:j]];
				j = ++i;
                
                if (portfolioItem->identCode[0]=='T' && portfolioItem->identCode[1] == 'W') {
                    [tmpDict setObject:[NSNumber numberWithDouble:is->forexLose] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->forexLoseUnit] forKey:[_keyArray objectAtIndex:j]];
                    j = ++i;
                }

                [tmpDict setObject:[NSNumber numberWithDouble:is->incomeBeforeTax] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->incomeBeforeTaxUnit] forKey:[_keyArray objectAtIndex:j]];
				j = ++i;

                [tmpDict setObject:[NSNumber numberWithDouble:is->taxExpanse] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->taxExpanseUnit] forKey:[_keyArray objectAtIndex:j]];
				j = ++i;

                [tmpDict setObject:[NSNumber numberWithDouble:is->profit] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->profitUnit] forKey:[_keyArray objectAtIndex:j]];
				j = ++i;

                if (!portfolioItem->identCode[0]=='T' && !portfolioItem->identCode[1] == 'W') {
                    [tmpDict setObject:[NSNumber numberWithDouble:is->dilutedShares] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->dilutedSharesUnit] forKey:[_keyArray objectAtIndex:j]];
                    j = ++i;
                }
                

                [tmpDict setObject:[NSNumber numberWithDouble:is->dilutedEps] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->dilutedEpsUnit] forKey:[_keyArray objectAtIndex:j]];
                j = ++i;
                
                if (portfolioItem->identCode[0]=='T' && portfolioItem->identCode[1] == 'W') {
                    [tmpDict setObject:[NSNumber numberWithDouble:is->stockValue] forKey:[_keyArray objectAtIndex:i]];
					[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:is->stockValueUnit] forKey:[_keyArray objectAtIndex:j]];
                    j = ++i;
                }
				
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
                        [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"Income1" waitUntilDone:NO];
                    if (obj->dataType == 'Q' || obj->dataType == 'R'){
                        [self saveToFileWithIdentCodeSymbol:identCodeSymbol MainArray:symbol1Array MainUnitArray:symbol1UnitArray Type:'Q'];
                        [self saveToFileWithIdentCodeSymbol:identCodeSymbol MainArray:symbol1AllArray MainUnitArray:symbol1AllUnitArray Type:'R'];
                    }else{
                        [self saveToFileWithIdentCodeSymbol:identCodeSymbol MainArray:symbol1Array MainUnitArray:symbol1UnitArray Type:'C'];
                        [self saveToFileWithIdentCodeSymbol:identCodeSymbol MainArray:symbol1AllArray MainUnitArray:symbol1AllUnitArray Type:'D'];
                    }
                        
                    
                    
                }else{
                    if(notifyObj)
                        [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"Income2" waitUntilDone:NO];
                    if (obj->dataType == 'Q' || obj->dataType == 'R'){
                        [self saveToFileWithIdentCodeSymbol:identCodeSymbol MainArray:symbol2Array MainUnitArray:symbol2UnitArray Type:'Q'];
                        [self saveToFileWithIdentCodeSymbol:identCodeSymbol MainArray:symbol2AllArray MainUnitArray:symbol2AllUnitArray Type:'R'];
                    }else{
                        [self saveToFileWithIdentCodeSymbol:identCodeSymbol MainArray:symbol2Array MainUnitArray:symbol2UnitArray Type:'C'];
                        [self saveToFileWithIdentCodeSymbol:identCodeSymbol MainArray:symbol2AllArray MainUnitArray:symbol2AllUnitArray Type:'D'];
                    }
                    
                }
			}
		}else{
            if(notifyObj)
                [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"IncomeNoData" waitUntilDone:NO];
        }
        //		if (obj->retCode == 0 && [identSymbol hash] == autoFetingNo && identSymbol) // autofetch next sector;
        //		{
        //			autoFetingNo = 0;
        //			FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        //
        //            //neil
        //            //			[dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
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
    if ([RowTitle isEqualToString:@"P/E Ratio of Quarter Ending"]) {
        if ([dataArray count]==0) {
            taParam->value = -0.00 ;
            taParam->unit = 0;
        }else{
            taParam->value = [(NSNumber *)[tmpDict objectForKey:@"Last Price of Quarter Ending"]doubleValue]/[(NSNumber *)[tmpDict objectForKey:@"YTD EPS"]doubleValue];
            taParam->unit = 0;
        }
        taParam.nameString = RowTitle;
    }else{
        if ([dataArray count]==0) {
            taParam->value = -0.00 ;
            taParam->unit = 0;
        }else{
            int y = [self dateToYear:[tmpDict objectForKey:@"RecordDate"]];
            int q = [self dateToQuarter:[tmpDict objectForKey:@"RecordDate"]];
            if (_total || q==1 ||[RowTitle isEqualToString:@"Last Price of Quarter Ending"] ) {
                taParam->value = [(NSNumber *)[tmpDict objectForKey:RowTitle]doubleValue];
                taParam->unit = [(NSNumber *)[tmpUnitDict objectForKey:RowTitle]intValue];
            }else{
                if (index+1<[dataArray count]) {
                    NSDictionary *beforeTmpUnitDict = [dataUnitArray objectAtIndex:index+1];
                    NSDictionary *beforeTmpDict = [dataArray objectAtIndex:index+1];
                    
                    int beforeY = [self dateToYear:[beforeTmpDict objectForKey:@"RecordDate"]];
                    if (beforeY == y) {
                        float value = [[CodingUtil getValueString:[(NSNumber *)[tmpDict objectForKey:RowTitle]doubleValue] Unit:[(NSNumber *)[tmpUnitDict objectForKey:RowTitle]intValue]]floatValue];
                        float beforeValue = [[CodingUtil getValueString:[(NSNumber *)[beforeTmpDict objectForKey:RowTitle]doubleValue] Unit:[(NSNumber *)[beforeTmpUnitDict objectForKey:RowTitle]intValue]]floatValue];
                        taParam->value = value-beforeValue;
                        taParam->unit = 0;
                    }else{
                        taParam->value = [(NSNumber *)[tmpDict objectForKey:RowTitle]doubleValue];
                        taParam->unit = [(NSNumber *)[tmpUnitDict objectForKey:RowTitle]intValue];
                    }
                }else{
                    taParam->value = [(NSNumber *)[tmpDict objectForKey:RowTitle]doubleValue];
                    taParam->unit = [(NSNumber *)[tmpUnitDict objectForKey:RowTitle]intValue];
                }
                
            }
            
        }
        taParam.nameString = RowTitle;
    }
    
    
    
    
	[dataLock unlock];
    return taParam;
}


-(NSMutableDictionary *)getDataDictionaryWithIdentSymbol:(NSString*)is{
    NSMutableDictionary * dataDic = [[NSMutableDictionary alloc]init];
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

    [dataDic setObject:dataArray forKey:@"valueArray"];
    [dataDic setObject:dataUnitArray forKey:@"unitArray"];
    
    return dataDic;
}


- (void)addAllKey
{
	[allKeyArray removeAllObjects];
	[allKeyArray addObject:@"Total Revenue"];
	[allKeyArray addObject:@"Cost of Revenue"];
	[allKeyArray addObject:@"Gross Profit"];
	[allKeyArray addObject:@"Research Development"];
	[allKeyArray addObject:@"Selling General and Administrative"];
	[allKeyArray addObject:@"Depreciation/Amortization"];
	[allKeyArray addObject:@"Indirect Expenses"];
	[allKeyArray addObject:@"Total Operating Expenses"];
	[allKeyArray addObject:@"Operating Income"];
	[allKeyArray addObject:@"Non-Operating Gains"];
	[allKeyArray addObject:@"Cash from Operating Activities"];
	[allKeyArray addObject:@"Interest Income"];
	[allKeyArray addObject:@"Interest Expense"];
	[allKeyArray addObject:@"Investment Gains/Losses"];
	[allKeyArray addObject:@"Exchange Gains/Losses"];
	[allKeyArray addObject:@"Income Before Tax"];
	[allKeyArray addObject:@"Income Tax Expense"];
	[allKeyArray addObject:@"Net Income"];
	[allKeyArray addObject:@"Diluted Shares"];
	[allKeyArray addObject:@"YTD EPS"];
	[allKeyArray addObject:@"Last Price of Quarter Ending"];
    [allKeyArray addObject:@"P/E Ratio of Quarter Ending"];
}


- (void)addKey
{[_keyArray removeAllObjects];
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]) {
        [_keyArray addObject:@"Total Revenue"];
        [_keyArray addObject:@"Cost of Revenue"];
        [_keyArray addObject:@"Gross Profit"];
        [_keyArray addObject:@"Research Development"];
        [_keyArray addObject:@"Selling General and Administrative"];
        [_keyArray addObject:@"Depreciation/Amortization"];
        [_keyArray addObject:@"Indirect Expenses"];
        [_keyArray addObject:@"Total Operating Expenses"];
        [_keyArray addObject:@"Operating Income"];
        [_keyArray addObject:@"Non-Operating Gains"];
        [_keyArray addObject:@"Investment Gains/Losses"];
        [_keyArray addObject:@"Income Before Tax"];
        [_keyArray addObject:@"Income Tax Expense"];
        [_keyArray addObject:@"Net Income"];
        [_keyArray addObject:@"Diluted Shares"];
        [_keyArray addObject:@"YTD EPS"];
    }else if([group isEqualToString:@"cn"]){
        
    }else{
        [_keyArray addObject:@"Total Revenue"];
        [_keyArray addObject:@"Cost of Revenue"];
        [_keyArray addObject:@"Gross Profit"];
        [_keyArray addObject:@"Total Operating Expenses"];
        [_keyArray addObject:@"Operating Income"];
        [_keyArray addObject:@"Cash from Operating Activities"];
        [_keyArray addObject:@"Interest Income"];
        [_keyArray addObject:@"Interest Expense"];
        [_keyArray addObject:@"Investment Gains/Losses"];
        [_keyArray addObject:@"Exchange Gains/Losses"];
        [_keyArray addObject:@"Income Before Tax"];
        [_keyArray addObject:@"Income Tax Expense"];
        [_keyArray addObject:@"Net Income"];
        [_keyArray addObject:@"YTD EPS"];
        [_keyArray addObject:@"Last Price of Quarter Ending"];
        [_keyArray addObject:@"P/E Ratio of Quarter Ending"];
    }
	
	
}


@end
