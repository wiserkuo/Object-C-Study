//
//  BalanceSheet.m
//  FonestockPower
//
//  Created by Neil on 14/4/25.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "BalanceSheet.h"
#import "BalanceSheetOut.h"
#import "BalanceSheetIn.h"

@interface BalanceSheet (){
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

@implementation BalanceSheet

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
//		fetchObj = nil;
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
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ BalanceSheet.plist",symbol1]];
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
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ BalanceSheet.plist",symbol2]];
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
    if (type == 'Q') {
        path= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ BalanceSheet.plist",identCodeSymbol]];
    }else{
        path= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ MergeBalanceSheet.plist",identCodeSymbol]];
    }
    
	NSDictionary *tmpDict = [[NSDictionary alloc] initWithObjectsAndKeys:mainArray,@"mainArray",mainUnitArray,@"mainUnitArray",nil];
	BOOL success = [tmpDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"wirte error!!");
	[dataLock unlock];
}


- (void)sendAndReadWithSymbol1:(NSString *)identSymbol
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
    UInt8 type = 'R';
//    if (portfolioItem->identCode[0]=='T' && portfolioItem->identCode[1] == 'W') {
//        type = 'X';
//    }else{
//        type = 'Q';
//    }
	BalanceSheetOut *bsOut = [[BalanceSheetOut alloc] initWithStartDate:[CodingUtil makeDate:year-3 month:month day:day] EndDate:[CodingUtil makeDate:year month:month day:day] CommodityNum:commodityNum1 DataType:type];
	[FSDataModelProc sendData:self WithPacket:bsOut];
	[dataLock unlock];
}

- (void)sendAndReadWithSymbol2:(NSString *)identSymbol
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
    UInt8 type = 'R';
//    if (portfolioItem->identCode[0]=='T' && portfolioItem->identCode[1] == 'W') {
//        type = 'X';
//    }else{
//        type = 'Q';
//    }
    
    if(commodityNum1 != commodityNum2){
        BalanceSheetOut *bsOut = [[BalanceSheetOut alloc] initWithStartDate:[CodingUtil makeDate:year-3 month:month day:day] EndDate:[CodingUtil makeDate:year month:month day:day] CommodityNum:commodityNum2 DataType:type];
        [FSDataModelProc sendData:self WithPacket:bsOut];
    }
	
	[dataLock unlock];
}

- (void)decodeArrive:(BalanceSheetIn*)obj
{
	NSMutableArray *bsArray = obj->sheetArray;
	[dataLock lock];
	if(commodityNum1 == obj->commodityNum || commodityNum2 == obj->commodityNum)
	{
        if (commodityNum1 == obj->commodityNum) {
//            if (obj->dataType == 'Q') {
//                [symbol1Array removeAllObjects];
//                [symbol1UnitArray removeAllObjects];
//            }else if (obj->dataType == 'R'){
                [symbol1AllArray removeAllObjects];
                [symbol1AllUnitArray removeAllObjects];
//            }
            
        }else{
//            if (obj->dataType == 'Q') {
//                [symbol2Array removeAllObjects];
//                [symbol2UnitArray removeAllObjects];
//            }else if (obj->dataType == 'R'){
                [symbol2AllArray removeAllObjects];
                [symbol2AllUnitArray removeAllObjects];
//            }
        }
		if ([bsArray count] > 0)
		{

			FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
			PortfolioItem *portfolioItem = [dataModal.portfolioData findInPortfolio:obj->commodityNum];
			NSString *is;
			if(portfolioItem)
				is = [NSString stringWithFormat:@"%c%c %@",portfolioItem->identCode[0],portfolioItem->identCode[1],portfolioItem->symbol];
			else
				is = @"NULL";
			for(SheetParam *bs in bsArray)
			{
				int i=0,j=0;
				NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
				NSMutableDictionary *tmpUnitDict = [[NSMutableDictionary alloc] init];
				[tmpDict setObject:is forKey:@"IdentSymbol"];
				[tmpDict setObject:[NSNumber numberWithUnsignedInt:[self setDateToSeasonWithDate:bs->date]] forKey:@"RecordDate"];
                
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:[self setDateToSeasonWithDate:bs->date]] forKey:@"RecordDate"];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->cash] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->cashUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->shortInvest] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->shortInvestUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->ar] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->arUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->inventory] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->inventoryUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->currentAsset] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->currentAssetUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->longInvest] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->longInvestUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->fixedAsset] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->fixedAssetUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->totalAsset] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->totalAssetUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->shortLoan] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->shortLoanUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->ap] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->apUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->currentDebt] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->currentDebtUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->longLoan] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->longLoanUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->totalDebt] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->totalDebtUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->equity] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->equityUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->retainedEarning] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->retainedEarningUnit] forKey:[_keyArray objectAtIndex:j++]];
				[tmpDict setObject:[NSNumber numberWithDouble:bs->totalEquity] forKey:[_keyArray objectAtIndex:i++]];
				[tmpUnitDict setObject:[NSNumber numberWithUnsignedInt:bs->totalEquityUnit] forKey:[_keyArray objectAtIndex:j++]];
                
                if (commodityNum1 == obj->commodityNum) {
//                    if (obj->dataType == 'Q') {
//                        [symbol1Array addObject:tmpDict];
//                        [symbol1UnitArray addObject:tmpUnitDict];
//                    }else if (obj->dataType == 'R'){
                        [symbol1AllArray addObject:tmpDict];
                        [symbol1AllUnitArray addObject:tmpUnitDict];
//                    }
                    
                }else{
//                    if (obj->dataType == 'Q') {
//                        [symbol2Array addObject:tmpDict];
//                        [symbol2UnitArray addObject:tmpUnitDict];
//                    }else if (obj->dataType == 'R'){
                        [symbol2AllArray addObject:tmpDict];
                        [symbol2AllUnitArray addObject:tmpUnitDict];
//                    }
                    
                }
			}
            if (commodityNum1 == obj->commodityNum) {
//                if (obj->dataType == 'Q') {
//                    [self sortArray:symbol1Array];
//                    [self sortArray:symbol1UnitArray];
//                }else if (obj->dataType == 'R'){
                    [self sortArray:symbol1AllArray];
                    [self sortArray:symbol1AllUnitArray];
//                }
                
            }else{
//                if (obj->dataType == 'Q') {
//                    [self sortArray:symbol2Array];
//                    [self sortArray:symbol2UnitArray];
//                }else if (obj->dataType == 'R'){
                    [self sortArray:symbol2AllArray];
                    [self sortArray:symbol2AllUnitArray];
//                }
            }
			
			if (obj->retCode == 0)
			{
				
                if (commodityNum1 == obj->commodityNum) {
                    if(notifyObj)
                        [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"BalanceSheet1" waitUntilDone:NO];
//                    [self saveToFileWithIdentCodeSymbol:is MainArray:symbol1Array MainUnitArray:symbol1UnitArray Type:'Q'];
                    [self saveToFileWithIdentCodeSymbol:is MainArray:symbol1AllArray MainUnitArray:symbol1AllUnitArray Type:'R'];
                    
                }else{
                    if(notifyObj)
                        [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"BalanceSheet2" waitUntilDone:NO];
//                    [self saveToFileWithIdentCodeSymbol:is MainArray:symbol2Array MainUnitArray:symbol2UnitArray Type:'Q'];
                    [self saveToFileWithIdentCodeSymbol:is MainArray:symbol2AllArray MainUnitArray:symbol2AllUnitArray Type:'R'];
                }
			}
		}else{
            if(notifyObj)
                [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"BalanceSheetNoData" waitUntilDone:NO];
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
		return (int)[_keyArray count];  //要扣掉RecordDate跟IdentSymbol
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
        taParam->value = [(NSNumber *)[tmpDict objectForKey:RowTitle]doubleValue];
        taParam->unit = [(NSNumber *)[tmpUnitDict objectForKey:RowTitle]intValue];
    }
    taParam.nameString = RowTitle;
    
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


-(void)addAllKey{
    [allKeyArray removeAllObjects];
    
	[allKeyArray addObject:@"Cash And Cash Equivalents"];
	[allKeyArray addObject:@"Short Term Investments"];
	[allKeyArray addObject:@"Net Receivables"];
	[allKeyArray addObject:@"Inventory"];
	[allKeyArray addObject:@"Total Current Assets"];
	[allKeyArray addObject:@"Long Term Investments"];
	[allKeyArray addObject:@"Property Plant and Equipment"];
	[allKeyArray addObject:@"Total Assets"];
	[allKeyArray addObject:@"Current Debt"];
	[allKeyArray addObject:@"Accounts Payable"];
	[allKeyArray addObject:@"Total Current Liabilities"];
	[allKeyArray addObject:@"Deferred LT Liability Charges"];
	[allKeyArray addObject:@"Total Liabilities"];
	[allKeyArray addObject:@"Common Stock"];
	[allKeyArray addObject:@"Retained Earnings"];
	[allKeyArray addObject:@"Total Stockholder Equity"];
}

-(void)addKey{
    [_keyArray removeAllObjects];
    
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]) {
        _keyArray = allKeyArray;
    }else if([group isEqualToString:@"cn"]){
        [_keyArray addObject:@"Total Current Assets"];
        [_keyArray addObject:@"Long Term Investments"];
        [_keyArray addObject:@"Property Plant and Equipment"];
        [_keyArray addObject:@"Other Assets"];//其他資產
        [_keyArray addObject:@"Total Assets"];
        [_keyArray addObject:@"Total Current Liabilities"];
        [_keyArray addObject:@"Long Term Liabilities"];//長期負債
        [_keyArray addObject:@"Other Liabilities"];//其他負債及準備
        [_keyArray addObject:@"Total Liabilities"];
        [_keyArray addObject:@"Basic Common Stock"];//普通股股本
        [_keyArray addObject:@"Special Common Stock"];//特別股股本
        [_keyArray addObject:@"Retained Earnings"];//資本公積
        //未分配盈餘
        //少數股權
        [_keyArray addObject:@"Total Stockholder Equity"];//股東權益總額
        //負債及股東權益總額
        
        [_keyArray addObject:@"Cash And Cash Equivalents"];
        [_keyArray addObject:@"Short Term Investments"];
        [_keyArray addObject:@"Net Receivables"];
        [_keyArray addObject:@"Inventory"];

    }else{
        _keyArray = allKeyArray;
    }
    
	
}

@end
