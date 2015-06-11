//
//  CashFlow.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CashFlow.h"
#import "CashFlowDataOut.h"
#import "CashFlowDataIn.h"

@interface CashFlow (){
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

@implementation CashFlow

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
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ CashFlow.plist",symbol1]];
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
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ CashFlow.plist",symbol2]];
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
        path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ CashFlow.plist",identCodeSymbol]];
    }else{
        path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ MergeCashFlow.plist",identCodeSymbol]];
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
	CashFlowDataOut *cfOut = [[CashFlowDataOut alloc] initWithStartDate:[CodingUtil makeDate:year-3 month:month day:day] EndDate:[CodingUtil makeDate:year month:month day:day] CommodityNum:commodityNum1 DataType:type];
	[FSDataModelProc sendData:self WithPacket:cfOut];
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
    
    if (commodityNum1 != commodityNum2) {
        CashFlowDataOut *cfOut = [[CashFlowDataOut alloc] initWithStartDate:[CodingUtil makeDate:year-3 month:month day:day] EndDate:[CodingUtil makeDate:year month:month day:day] CommodityNum:commodityNum2 DataType:type];
        [FSDataModelProc sendData:self WithPacket:cfOut];
    }
	
	[dataLock unlock];
}

- (void)decodeArrive:(CashFlowDataIn*)obj
{
	NSMutableArray* cfArray = obj->cashFlowArray;
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
		if ([cfArray count] > 0)
		{
            
            FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
			PortfolioItem *portfolioItem = [dataModal.portfolioData findInPortfolio:obj->commodityNum];
			NSString *is;
			if(portfolioItem)
				is = [NSString stringWithFormat:@"%c%c %@",portfolioItem->identCode[0],portfolioItem->identCode[1],portfolioItem->symbol];
			else 
				is = @"NULL";
			
			for(CashFlowParam *cf in cfArray)
			{
				int i=0;
				NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
				NSMutableDictionary *tmpUnitDict = [[NSMutableDictionary alloc] init];
				
				[tmpDict setObject:is forKey:@"IdentSymbol"];
				[tmpDict setObject:[NSNumber numberWithUnsignedInt:[self setDateToSeasonWithDate:cf->date]] forKey:@"RecordDate"];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:[self setDateToSeasonWithDate:cf->date]] forKey:@"RecordDate"];
				
				
				[self dictAddValue:cf->netIncome Unit:cf->netIncomeUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->depriciation Unit:cf->depriciationUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->investGainLoss Unit:cf->investGainLossUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->shortInvestGainLoss Unit:cf->shortInvestGainLossUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->fixInvestGainLoss Unit:cf->fixInvestGainLossUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->longInvestGainLoss Unit:cf->longInvestGainLossUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->arOffset Unit:cf->arOffsetUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->inventoryOffset Unit:cf->inventoryOffsetUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->apOffset Unit:cf->apOffsetUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->changesWorkingCapital Unit:cf->changesWorkingCapitalUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->incomeAdjustments Unit:cf->incomeAdjustmentsUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->otherOperatingFlow Unit:cf->otherOperatingFlowUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->operatingCashFlow Unit:cf->operatingCashFlowUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->shortInvestSold Unit:cf->shortInvestSoldUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->longInvestSold Unit:cf->longInvestSoldUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->longInvestment Unit:cf->longInvestmentUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->fixAssetAmnt Unit:cf->fixAssetAmntUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->fixedAsset Unit:cf->fixedAssetUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->capitalExpenditures Unit:cf->capitalExpendituresUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->investmentPurchases Unit:cf->investmentPurchasesUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->investmentDisposal Unit:cf->investmentDisposalUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->businessAcqstnsDisposal Unit:cf->businessAcqstnsDisposalUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->otherInvestFlow Unit:cf->otherInvestFlowUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->investCashFlow Unit:cf->investCashFlowUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->capitalFund Unit:cf->capitalFundUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->cashDiv Unit:cf->cashDivUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->loanOffset Unit:cf->loanOffsetUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->shortDebtChanges Unit:cf->shortDebtChangesUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->longDebtChanges Unit:cf->longDebtChangesUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->changeInEquity Unit:cf->changeInEquityUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->otherFinancingFlow Unit:cf->otherFinancingFlowUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->financingCashFlow Unit:cf->financingCashFlowUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->effectOfExchangeRate Unit:cf->effectOfExchangeRateUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->termCashFlow Unit:cf->termCashFlowUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->botCashFlow Unit:cf->botCashFlowUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->eotCashFlow Unit:cf->eotCashFlowUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->paidInterest Unit:cf->paidInterestUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
				[self dictAddValue:cf->paidInteresetTax Unit:cf->paidInteresetTaxUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
//				[self dictAddValue:cf->freeCashFlow Unit:cf->freeCashFlowUnit index:i++ dictValue:tmpDict dictUnit:tmpUnitDict];
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
                        [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"CashFlow1" waitUntilDone:NO];
                    if (obj->dataType == 'Q' || obj->dataType == 'R'){
                        [self saveToFileWithIdentCodeSymbol:is MainArray:symbol1Array MainUnitArray:symbol1UnitArray Type:'Q'];
                        [self saveToFileWithIdentCodeSymbol:is MainArray:symbol1AllArray MainUnitArray:symbol1AllUnitArray Type:'R'];
                    }else{
                        [self saveToFileWithIdentCodeSymbol:is MainArray:symbol1Array MainUnitArray:symbol1UnitArray Type:'C'];
                        [self saveToFileWithIdentCodeSymbol:is MainArray:symbol1AllArray MainUnitArray:symbol1AllUnitArray Type:'D'];
                    }
                    
                }else{
                    if(notifyObj)
                        [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"CashFlow2" waitUntilDone:NO];
                    if (obj->dataType == 'Q' || obj->dataType == 'R'){
                        [self saveToFileWithIdentCodeSymbol:is MainArray:symbol2Array MainUnitArray:symbol2UnitArray Type:'Q'];
                        [self saveToFileWithIdentCodeSymbol:is MainArray:symbol2AllArray MainUnitArray:symbol2AllUnitArray Type:'R'];
                    }else{
                        [self saveToFileWithIdentCodeSymbol:is MainArray:symbol2Array MainUnitArray:symbol2UnitArray Type:'C'];
                        [self saveToFileWithIdentCodeSymbol:is MainArray:symbol2AllArray MainUnitArray:symbol2AllUnitArray Type:'D'];
                    }
                }
			}
        }else{
            if(notifyObj)
                [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"CashFlowNoData" waitUntilDone:NO];
        }
    }

	[dataLock unlock];
}
    
- (void)dictAddValue:(double)value Unit:(UInt8)unit index:(int)i dictValue:(NSMutableDictionary*)tmpDict dictUnit:(NSMutableDictionary*)tmpUnitDict
    {
//        if(![[[NSNumber numberWithDouble:value] stringValue] isEqualToString:@"-0"]) {
            [tmpDict setObject:[NSNumber numberWithDouble:value] forKey:[_keyArray objectAtIndex:i]];
            [tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:unit] forKey:[_keyArray objectAtIndex:i]];
//        }
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
    if ([dataArray count]==0) {
        taParam->value = -0.00 ;
        taParam->unit = 0;
    }else{
        int y = [self dateToYear:[tmpDict objectForKey:@"RecordDate"]];
        int q = [self dateToQuarter:[tmpDict objectForKey:@"RecordDate"]];
        if (_total || q==1 || [RowTitle isEqualToString:@"Cash & Cash Equivalents at End"]) {
            taParam->value = [(NSNumber *)[tmpDict objectForKey:RowTitle]doubleValue];
            taParam->unit = [(NSNumber *)[tmpUnitDict objectForKey:RowTitle]intValue];
        }else{
            if (index+1<[dataArray count]) {
                NSDictionary *beforeTmpUnitDict = [dataUnitArray objectAtIndex:index+1];
                NSDictionary *beforeTmpDict = [dataArray objectAtIndex:index+1];
                
                int beforeY = [self dateToYear:[beforeTmpDict objectForKey:@"RecordDate"]];
                if (beforeY == y) {
                    if ([RowTitle isEqualToString:@"Cash & Cash Equivalents at Beginning"] ) {

                        float beforeValue = [[CodingUtil getValueString:[(NSNumber *)[beforeTmpDict objectForKey:@"Cash & Cash Equivalents at End"]doubleValue] Unit:[(NSNumber *)[beforeTmpUnitDict objectForKey:@"Cash & Cash Equivalents at End"]intValue]]floatValue];
                        taParam->value = beforeValue;
                        taParam->unit = 0;
                    }else{
                        float value = [[CodingUtil getValueString:[(NSNumber *)[tmpDict objectForKey:RowTitle]doubleValue] Unit:[(NSNumber *)[tmpUnitDict objectForKey:RowTitle]intValue]]floatValue];
                        float beforeValue = [[CodingUtil getValueString:[(NSNumber *)[beforeTmpDict objectForKey:RowTitle]doubleValue] Unit:[(NSNumber *)[beforeTmpUnitDict objectForKey:RowTitle]intValue]]floatValue];
                        taParam->value = value-beforeValue;
                        taParam->unit = 0;
                    }
                    
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
    
	[dataLock unlock];
    return taParam;
}


- (void)addAllKey
{
	[allKeyArray removeAllObjects];
	[allKeyArray addObject:@"Net Income"];
	[allKeyArray addObject:@"Depreciation Expense & Various Amortization"];
	[allKeyArray addObject:@"Investment Gains/Losses"];
	[allKeyArray addObject:@"S-T Investments Disposal Gains/Loses"];
	[allKeyArray addObject:@"F-A Investments Disposal Gains/Loses"];
	[allKeyArray addObject:@"L-T Investments Disposal Gains/Loses"];
	[allKeyArray addObject:@"Changes In Accounts Receivables"];
	[allKeyArray addObject:@"Changes In Inventories"];
	[allKeyArray addObject:@"Changes in Accounts Payable"];
	[allKeyArray addObject:@"Changes in Working Capital"];
	[allKeyArray addObject:@"Adjustments To Net Income"];
	[allKeyArray addObject:@"Other Cash Flows from Operating Activities"];
	[allKeyArray addObject:@"Cash flows from Operating Activities"];
	[allKeyArray addObject:@"Slaes of S-T Investments"];
	[allKeyArray addObject:@"Slaes of L-T Investments"];
	[allKeyArray addObject:@"L-T Investments"];
	[allKeyArray addObject:@"Sales of Fixed Assets"];
	[allKeyArray addObject:@"Total Fixed Assets"];
	[allKeyArray addObject:@"Capital Expenditures"];
	[allKeyArray addObject:@"Investment Purchase"];
	[allKeyArray addObject:@"Investment Disposal"];
	[allKeyArray addObject:@"Business Acqstns/Disposals"];
	[allKeyArray addObject:@"Other Cash Flows from Investing Activities"];
	[allKeyArray addObject:@"Cash Flow From Investing Activities"];
	[allKeyArray addObject:@"Proceeds from New Issues"];
	[allKeyArray addObject:@"Dividend Paid"];
	[allKeyArray addObject:@"Changes in Borrowing"];
	[allKeyArray addObject:@"Changes in Short Term Debt"];
	[allKeyArray addObject:@"Changes in Long Term Debt"];
	[allKeyArray addObject:@"Change in Equity (Cumu)"];
	[allKeyArray addObject:@"Other Cash Flows from Financing Activities"];
	[allKeyArray addObject:@"Cash Flow from Financing Activities"];
	[allKeyArray addObject:@"Effect Of Exchange Rate Changes"];
	[allKeyArray addObject:@"Changes in Cash Flow"];
	[allKeyArray addObject:@"Cash & Cash Equivalents at Beginning"];
	[allKeyArray addObject:@"Cash & Cash Equivalents at End"];
	[allKeyArray addObject:@"Interest Paid"];
	[allKeyArray addObject:@"Income Tax Paid"];
	[allKeyArray addObject:@"Free Cash Flow"];
}


- (void)addKey
{
	[_keyArray removeAllObjects];
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]) {
        [_keyArray addObject:@"Net Income"];
        [_keyArray addObject:@"Changes in Working Capital"];
        [_keyArray addObject:@"Adjustments To Net Income"];
        [_keyArray addObject:@"Other Cash Flows from Operating Activities"];
        [_keyArray addObject:@"Cash flows from Operating Activities"];
        [_keyArray addObject:@"Capital Expenditures"];
        [_keyArray addObject:@"Investment Purchase"];
        [_keyArray addObject:@"Investment Disposal"];
        [_keyArray addObject:@"Business Acqstns/Disposals"];
        [_keyArray addObject:@"Other Cash Flows from Investing Activities"];
        [_keyArray addObject:@"Cash Flow From Investing Activities"];
        [_keyArray addObject:@"Dividend Paid"];
        [_keyArray addObject:@"Changes in Short Term Debt"];
        [_keyArray addObject:@"Changes in Long Term Debt"];
        [_keyArray addObject:@"Change in Equity (Cumu)"];
        [_keyArray addObject:@"Other Cash Flows from Financing Activities"];
        [_keyArray addObject:@"Cash Flow from Financing Activities"];
        [_keyArray addObject:@"Effect Of Exchange Rate Changes"];
        [_keyArray addObject:@"Changes in Cash Flow"];
        [_keyArray addObject:@"Cash & Cash Equivalents at Beginning"];
        [_keyArray addObject:@"Cash & Cash Equivalents at End"];
        [_keyArray addObject:@"Free Cash Flow"];
    }else{
        [_keyArray addObject:@"Net Income"];
        [_keyArray addObject:@"Depreciation Expense & Various Amortization"];
        [_keyArray addObject:@"Investment Gains/Losses"];
        [_keyArray addObject:@"S-T Investments Disposal Gains/Loses"];
        [_keyArray addObject:@"F-A Investments Disposal Gains/Loses"];
        [_keyArray addObject:@"L-T Investments Disposal Gains/Loses"];
        [_keyArray addObject:@"Changes In Accounts Receivables"];
        [_keyArray addObject:@"Changes In Inventories"];
        [_keyArray addObject:@"Changes in Accounts Payable"];
        [_keyArray addObject:@"Cash flows from Operating Activities"];
        [_keyArray addObject:@"Slaes of S-T Investments"];
        [_keyArray addObject:@"Slaes of L-T Investments"];
        [_keyArray addObject:@"L-T Investments"];
        [_keyArray addObject:@"Sales of Fixed Assets"];
        [_keyArray addObject:@"Total Fixed Assets"];
        [_keyArray addObject:@"Cash Flow From Investing Activities"];
        [_keyArray addObject:@"Proceeds from New Issues"];
        [_keyArray addObject:@"Dividend Paid"];
        [_keyArray addObject:@"Changes in Borrowing"];
        [_keyArray addObject:@"Cash Flow from Financing Activities"];
        [_keyArray addObject:@"Changes in Cash Flow"];
        [_keyArray addObject:@"Cash & Cash Equivalents at Beginning"];
        [_keyArray addObject:@"Cash & Cash Equivalents at End"];
        [_keyArray addObject:@"Interest Paid"];
        [_keyArray addObject:@"Income Tax Paid"];
    }
	
}
@end
