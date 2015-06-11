//
//  FSEmergingObject.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/10/7.
//  Copyright (c) 2014年 Michael.Hsieh. All rights reserved.
//

#import "FSEmergingObject.h"
#import "StockRankIn.h"
#import "InternationalInfoObject_v1.h"
#import "StockRankIn.h"
#import "CodingUtil.h"
//#import "SpecialStateOut.h"

@implementation FSEmergingObjectRegisterStock

@end

@implementation FSEmergingObjectApproveStock

@end

@implementation FSEmergingObjectRejectStock

@end

@implementation FSEmergingQuotes

-(NSMutableArray *)getQuotesCatNewObj:(NSString *)catID{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSMutableArray *quoteMutableArray = [[NSMutableArray alloc]init];
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM Cat_FullName WHERE SectorID = ?", catID];
        while ([rs next]) {
            NewSymbolObject * QuotesDBObj = [[NewSymbolObject alloc]init];
            QuotesDBObj.identCode = [rs stringForColumn:@"IdentCode"];
            QuotesDBObj.symbol = [rs stringForColumn:@"Symbol"];
            QuotesDBObj.fullName = [rs stringForColumn:@"FullName"];
            QuotesDBObj.typeId = [rs intForColumn:@"Type_id"];
            [quoteMutableArray addObject:QuotesDBObj];

        }
        [rs close];
    }];
    return quoteMutableArray;
}


-(NSMutableArray *)getQuotesCatName{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSMutableArray *getCatNameAndID = [[NSMutableArray alloc]init];
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM category WHERE ParentID = 599"];
        while ([rs next]) {
            FSEmergingQuotes * QuotesDBObj = [[FSEmergingQuotes alloc]init];
            QuotesDBObj.QuotesCatName = [rs stringForColumn:@"CatName"];
            QuotesDBObj.QuotesCatID = [rs stringForColumn:@"CatID"];
            [getCatNameAndID addObject:QuotesDBObj];
        }
        [rs close];
    }];
    return getCatNameAndID;
}


@end

@implementation RecObject

static RecObject __strong *generalDataObject = nil;

@synthesize changeBtnName;

+(RecObject *) sharedInstance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        generalDataObject = [[self alloc]init];
    });
    return generalDataObject;
}

-(NSMutableArray *)getTheDB:(NSArray *)componentsArray {
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSMutableArray *recMutableArray = [[NSMutableArray alloc]init];
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        for(NSString *tempBrokerID in componentsArray){
            NSString *query = [NSString stringWithFormat:@"SELECT Name FROM brokerName Where BrokerID = %@", tempBrokerID];
            FMResultSet *rs = [db executeQuery:query];
            RecObject *brokerObj = [[RecObject alloc]init];
            while ([rs next]) {
                brokerObj.brokerName = [rs stringForColumn:@"Name"];
                [recMutableArray addObject:brokerObj];
            }
            [rs close];
        }
        
    }];
    return recMutableArray;
}
-(NSMutableArray *)parserRecBrokerObj:(NSString *)brokerIDWithT :(NSString *)timeNULL{
    NSString *urlRecBrokerPath = [NSString stringWithFormat:@"http://kqstock.fonestock.com:2172/query/emg_broker.cgi?cmd=get_symbol&broker_id=%@&time_stamp=%@", brokerIDWithT, timeNULL];
    NSData *result = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRecBrokerPath]] returningResponse:nil error:nil];
    NSString *resultStr = [[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding];
    NSArray *resultArrayNoN =[resultStr componentsSeparatedByString:@"\n"];
    NSMutableArray *resultMutableArrayNoN = [[NSMutableArray alloc]initWithArray:resultArrayNoN];
    [RecObject sharedInstance].recBrokerName = [[NSMutableArray alloc]init];
    [RecObject sharedInstance].recBrokerSymbol = [[NSMutableArray alloc]init];
    [resultMutableArrayNoN removeObjectAtIndex:0];
    [resultMutableArrayNoN removeLastObject];
    NSMutableArray *newSymbolMutableArray = [[NSMutableArray alloc]init];
    for (NSString *row in resultMutableArrayNoN){
        NewSymbolObject *new = [[NewSymbolObject alloc]init];

        new.identCode = [[row componentsSeparatedByString:@","]objectAtIndex:0];
        new.symbol = [[row componentsSeparatedByString:@","]objectAtIndex:1];
        new.fullName = [[row componentsSeparatedByString:@","]objectAtIndex:2];
        new.typeId = [(NSNumber *)[[row componentsSeparatedByString:@","]objectAtIndex:3 ]intValue];
        [newSymbolMutableArray addObject:new];
        
        NSString *brokerName = [[row componentsSeparatedByString:@","]objectAtIndex:2];
//        NSString *brokerSymbol = [[row componentsSeparatedByString:@","]objectAtIndex:1];
        [[RecObject sharedInstance].recBrokerName addObject:brokerName];
//        [[RecObject sharedInstance].recBrokerSymbol addObject:brokerSymbol];
        [[RecObject sharedInstance].recBrokerSymbol addObject:new];

    }
    return newSymbolMutableArray;
}
-(NSArray *)parserRecBrokerNameList:(NSString *)timeNULL :(NSMutableArray *)comMutableArray{
    NSArray *pathCacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [pathCacheDir objectAtIndex:0];
    NSString *recBroker = [cachePath stringByAppendingPathComponent:@"recBroker"];
    NSString *urlRecBrokerListPath  = [NSString stringWithFormat:@"http://kqstock.fonestock.com:2172/query/emg_broker.cgi?cmd=broker_list&time_stamp=%@",timeNULL];
    
    NSData *resultList = [[NSData alloc]init];
    resultList = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRecBrokerListPath]] returningResponse:nil error:nil];
    NSString *resultListStr = [[NSString alloc]initWithData:resultList encoding:NSUTF8StringEncoding];
    
    [resultListStr writeToFile:recBroker atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSArray *comArray = [resultListStr componentsSeparatedByString:@"\n"];
    [comMutableArray addObjectsFromArray:comArray];
    
    [comMutableArray removeObjectAtIndex:0];
    [comMutableArray removeLastObject];
    
    NSString *comStr = [comMutableArray componentsJoinedByString:@","];
    comStr = [comStr stringByReplacingOccurrencesOfString:@"9A0T" withString:@"9910"];
    comStr = [comStr stringByReplacingOccurrencesOfString:@"T" withString:@"0"];
    
    NSArray *componentsArray = [comStr componentsSeparatedByString:@","];
    return componentsArray;
}
@end


@implementation FSEmergingObject


NSMutableArray *marketBitMaskMuArray;
NSMutableArray *marketValueMuArray;
FSDataModelProc *dataModel;
-(NSString *)stringWithOperatingMarginByValue:(CGFloat)value Sign:(BOOL)sign
{
    NSString *retVal;
    NSString *marks;
    marks = @"";
    if (sign) {
        if (value > 0) {
            marks = @"+";
        }else {
            marks = @"";
        }
    }
    if(fabs(value) >= 10000){
        retVal = [NSString stringWithFormat:@"%@%.0f%%",marks, value];
    }else if(fabs(value) >= 100){
        retVal = [NSString stringWithFormat:@"%@%.0f%%",marks, value];
    }else if(fabs(value) < 100 && (fabs(value) >= 10)){
        retVal = [NSString stringWithFormat:@"%@%.1f%%",marks, value];
    }else if(fabs(value) < 10){
        retVal = [NSString stringWithFormat:@"%@%.2f%%",marks, value];
    }else if(fabs(value) == 0) {
        retVal = [NSString stringWithFormat:@"%f0.0", value];
    }else{
        retVal = [NSString stringWithFormat:@"%@%.f%%",marks, value];
    }
    return retVal;
}

//show 小數點後兩位, 加上@"天"
-(NSString *)stringWithar_dayByValueAndDay:(CGFloat)value
{
    NSString *retVal;
    retVal = [NSString stringWithFormat:@"%.2f%@", value, @"天"];
    
    return retVal;
}
//有加號 , 小於 10 show 小數點後兩位 , 其餘 show 小數點後一位
-(NSString *)stringWithMarketMover:(double)value sign:(BOOL)sign{
    NSString *retVal;

    NSString *marks;
    marks = @"";
    if (sign) {
        if (value > 0) {
            marks = @"+";
        }else {
            marks = @"";
        }
    }
    if (fabs(value) == 0) {
        retVal = [NSString stringWithFormat:@"0.00"];
    }else if (fabs(value) < 10){
        retVal = [NSString stringWithFormat:@"%@%.2f", marks, value];
    }else{
        retVal = [NSString stringWithFormat:@"%@%.1f", marks, value];
    }
    return retVal;
    
}//有加號 , 有百分比 , 小於 10 show 小數點後兩位 , 其餘 show 小數點後一位
-(NSString *)stringWithMarketMoverPercent:(double)value sign:(BOOL)sign{
    NSString *retVal;
    
    NSString *marks;
    marks = @"";
    if (sign) {
        if (value > 0) {
            marks = @"+";
        }else {
            marks = @"";
        }
    }
    if (fabs(value) == 0) {
        retVal = [NSString stringWithFormat:@"0.00%%"];
    }else if (fabs(value) < 10){
        retVal = [NSString stringWithFormat:@"%@%.2f%%", marks, floor(value * 100) / 100];
    }else{
        retVal = [NSString stringWithFormat:@"%@%.1f%%", marks, floor(value * 10) / 10];
    }
    return retVal;
}

-(NSString *)stringWithChipPercent:(double)value sign:(BOOL)sign{
    NSString *retVal;
    NSString *marks;
    marks = @"";
    if (sign) {
        if (value > 0) {
            marks = @"+";
        }else {
            marks = @"";
        }
    }
//    飆股密碼 - 籌碼面密碼 - 法人認同度
    value = value * 100;
    
    if (value == 0) {
        retVal = [NSString stringWithFormat:@"%@0%%", marks];
    }else if (value < 10){
        retVal = [NSString stringWithFormat:@"%@%.2f%%",marks, value];
    }else if (value < 100){
        value = floor(value * 10) / 10;
        retVal = [NSString stringWithFormat:@"%@%.1f%%",marks, value];
    }else{
        retVal = [NSString stringWithFormat:@"%@%.0f%%",marks, value];
    }
    return retVal;
}
//有加號 , 數值小於 10 show小數點後三位, 小於等於 100 小數點後兩位 其餘為一位
-(NSString*)convertPriceValueToString:(double)value{
	NSString *valueString;
	if(value == 0){
		valueString = [NSString stringWithFormat:@"%.1lf",value];
	}else if(value <= 10){
		valueString = [NSString stringWithFormat:@"+%.3lf",value];
	}else if(value <= 100){
		valueString = [NSString stringWithFormat:@"+%.2lf",value];
    }else{
        valueString = [NSString stringWithFormat:@"+%.1lf",value];
    }
	
	return valueString;
    
}
//數值小於 10 show小數點後兩位 , 小於 100 show小數點後一位
-(NSString*)convertGainsValueToString:(double)value{
	NSString *valueString;
	if(value == 0){
		valueString = [NSString stringWithFormat:@"0.00%%"];
	}else if(value <= 10){
		valueString = [NSString stringWithFormat:@"+%.2lf%%",value];
	}else if(value <= 100){
		valueString = [NSString stringWithFormat:@"+%.1lf%%",value];
    }else{
        valueString = [NSString stringWithFormat:@"+%.0lf%%",value];
    }
	
	return valueString;
    
}
//數值小於 10 show 小數點後三位 , 小於 100 show 小數點後兩位 , 否則只 show 一位
-(NSString*)convertAverageValueToString:(double)value{
    NSString *valueString;
    if(value < -100){
        valueString = [NSString stringWithFormat:@"%.1f", value];
    }else if(value < -10){
        valueString = [NSString stringWithFormat:@"%.2f",value];
    }else if(value < 0){
        valueString = [NSString stringWithFormat:@"%.3f",value];
    }else if(value == 0){
        valueString = [NSString stringWithFormat:@"0.000"];
    }else if(value < 10){
        valueString = [NSString stringWithFormat:@"+%.3f",value];
    }else if(value < 100){
        valueString = [NSString stringWithFormat:@"+%.2f",value];
    }else{
        valueString = [NSString stringWithFormat:@"+%.1f",value];
    }
    
    return valueString;
    
}

-(NSString*)convertForeighnValueToString:(double)value{
    NSString *valueString;
    
    if(value < -100){
        valueString = [NSString stringWithFormat:@"%.0f%%",value];
    }else if(value < -10){
        valueString = [NSString stringWithFormat:@"%.1f%%",floor(value * 10) / 10];
    }else if(value < 0){
        valueString = [NSString stringWithFormat:@"%.2f%%",floor(value * 100) / 100];
    }else if(value == 0){
        valueString = [NSString stringWithFormat:@"0.00%%"];
    }else if(value < 10){
        valueString = [NSString stringWithFormat:@"+%.2f%%",floor(value * 100) / 100];
    }else if(value < 100){
        valueString = [NSString stringWithFormat:@"+%.1f%%",floor(value * 10) / 10];
    }else{
        valueString = [NSString stringWithFormat:@"+%.0f%%",value];
    }
    
    return valueString;
    
    
    return valueString;
}


- (NSString*) getStringDatePlusZeroForEX:(UInt16)rdate
{
    UInt16 year;
    UInt8 month,day;
    [CodingUtil getDate:rdate year:&year month:&month day:&day];
    if(month == 0 || day == 0 || rdate == 0)
        return @"--------";
    NSDateComponents *dayComps = [[NSDateComponents alloc] init];
    [dayComps setDay:day];
    [dayComps setMonth:month];
    [dayComps setYear:year];

    
    return [NSString stringWithFormat:@"%d/%02d/%02d", year - 1871, month, day];
}
-(NSString *)convertQuotesToString:(double)value{
    NSString *retVal;
    if (value == 0) {
        retVal = [NSString stringWithFormat:@"----"];
    }else{
        retVal = [NSString stringWithFormat:@"%.2f", floor(value * 100) / 100];
    }
    return retVal;
    
}
-(NSString *)convertZeroToString:(double)value{
    NSString *retVal;
    if (value == 0) {
        retVal = [NSString stringWithFormat:@"----"];
    }else{
        retVal = [NSString stringWithFormat:@"%.f", value];
    }
    return retVal;
}
-(NSString *)convertZeroToStringForAverage:(double)value{
    NSString *retVal;
    if (value == 0) {
        retVal = [NSString stringWithFormat:@"----"];
    }else{
        retVal = [NSString stringWithFormat:@"%.2f", value];
    }
    return retVal;
}
//大於 0 有加號，否則正常（整數）
-(NSString *)convertZeroPlusOrNot:(double)value{
    NSString *retVal;
    if (value > 0) {
        retVal = [NSString stringWithFormat:@"+%.f", value];
    }else {
        retVal = [NSString stringWithFormat:@"%.f", value];
    }
    return retVal;
}

//大於 0 有加號，否則正常（整數）
-(NSString *)convertZeroPlusOrNotForChip:(double)value{
    NSString *retVal;
    if (value > 0) {
        retVal = [NSString stringWithFormat:@"+%.0f", value];
    }else if(value == 0){
        retVal = [NSString stringWithFormat:@"0"];
    }else{
        retVal = [NSString stringWithFormat:@"%.0f", value];
    }
    return retVal;
}

-(NSString *)valueWithDay:(double)value{
    NSString *retVal;
    if (value > 0) {
        retVal = [NSString stringWithFormat:@"+%.0f日", value];
    }else if (value == 0){
        retVal = [NSString stringWithFormat:@"0日"];
    }else{
        retVal = [NSString stringWithFormat:@"%.0f日", value];
    }
    return retVal;
}

-(NSString *)valueWithOneDeci:(double)value{
    NSString *retVal;
    
    value = floor(value * 10) / 10;
    
    if (value > 0) {
        retVal = [NSString stringWithFormat:@"+%.1f%%", value];
    }else {
        retVal = [NSString stringWithFormat:@"%.1f%%", value];

    }
    
    return retVal;
}

-(NSString *)valueWithDirectionPercent:(double)value1 :(double)value2{
    NSString *retVal;
    
    value1 = floor(value1 * 100) / 100;
    value2 = floor(value2 * 100) / 100;

    if (value1 < 0) {
        if (value1 > value2) {
            retVal = [NSString stringWithFormat:@"%.2f%%▲ ", value1];
        }else if(value1 < value2){
            retVal = [NSString stringWithFormat:@"%.2f%%▼ ", value1];
        }else{
            retVal = [NSString stringWithFormat:@"%.2f%% ", value1];
        }
    }else{
        if (value1 > value2) {
           retVal = [NSString stringWithFormat:@"+%.2f%%▲ ", value1];
        }else if(value1 < value2){
           retVal = [NSString stringWithFormat:@"+%.2f%%▼ ", value1];
        }else{
            retVal = [NSString stringWithFormat:@"+%.2f%% ", value1];
        }
    }
    return retVal;
}

-(NSMutableAttributedString *)valueWithDirectionAndSpace:(double)value1 :(double)value2 :(double)value3 :(double)value4{
    NSString *retVal;
    NSMutableAttributedString *attrStr;
    
    if (value1 > value3 && value2 > value4) {
        retVal = [NSString stringWithFormat:@"%7.2f▲      %7.2f▲  ", floor(value1 * 100) / 100, floor(value2 * 100) / 100];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceUpColor] range:NSMakeRange(0, retVal.length)];
    }else if(value1 < value3 && value2 < value4){
        retVal = [NSString stringWithFormat:@"%7.2f▼      %7.2f▼  ", floor(value1 * 100) / 100, floor(value2 * 100) / 100];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceDownColor] range:NSMakeRange(0, retVal.length)];
    }else if(value1 > value3 && value2 < value4){
        retVal = [NSString stringWithFormat:@"%7.2f▲      %7.2f▼  ", floor(value1 * 100) / 100, floor(value2 * 100) / 100];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];

        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceUpColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceDownColor] range:NSMakeRange(retVal.length / 2, retVal.length -  retVal.length / 2)];
    }else if(value1 < value3 && value2 > value4){
        retVal = [NSString stringWithFormat:@"%7.2f▼      %7.2f▲  ", floor(value1 * 100) / 100, floor(value2 * 100) / 100];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceDownColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceUpColor] range:NSMakeRange(retVal.length / 2, retVal.length - retVal.length / 2)];
    }else if(value1 == value3 && value2 > value4){
        retVal = [NSString stringWithFormat:@"%7.2f       %7.2f▲  ", floor(value1 * 100) / 100, floor(value2 * 100) / 100];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceUpColor] range:NSMakeRange(retVal.length / 2, retVal.length - retVal.length / 2)];
    }else if(value1 == value3 && value2 < value4){
        retVal = [NSString stringWithFormat:@"%7.2f       %7.2f▼  ", floor(value1 * 100) / 100, floor(value2 * 100) / 100];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceDownColor] range:NSMakeRange(retVal.length / 2, retVal.length - retVal.length / 2)];
    }else if(value1 < value3 && value2 == value4){
        retVal = [NSString stringWithFormat:@"%7.2f▼         %7.2f  ", floor(value1 * 100) / 100, floor(value2 * 100) / 100];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceDownColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(retVal.length / 2, retVal.length - retVal.length / 2)];
    }else if(value1 > value3 && value2 == value4){
        retVal = [NSString stringWithFormat:@"%7.2f▲         %7.2f  ", floor(value1 * 100) / 100, floor(value2 * 100) / 100];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceUpColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(retVal.length / 2, retVal.length - retVal.length / 2)];
    }else{
        retVal = [NSString stringWithFormat:@"%7.2f        %7.2f  ", floor(value1 * 100) / 100, floor(value2 * 100) / 100];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(retVal.length / 2, retVal.length - retVal.length / 2)];
    }
    
    return attrStr;
}

-(NSMutableAttributedString *)valueWithDirectionAndSpacePlus:(double)value1 :(double)value2 :(double)value3 :(double)value4{
    NSString *retVal;
    NSMutableAttributedString *attrStr;
    NSString *marks;
    
    if (value1 > 0 ) {
        marks = [NSString stringWithFormat:@"+%.2f", value1];

    }else if(value2 > 0){
        marks = [NSString stringWithFormat:@"+%.2f", value2];
    }else if(value1 < 0){
        marks = [NSString stringWithFormat:@"%.2f", value1];
    }else{
        marks = [NSString stringWithFormat:@"%.2f", value2];
    }
    
    if (value1 > value3 && value2 > value4) {

//        NSString *ss = [NSString stringWithFormat:@"%"] floor(value1 * 100) / 100
        retVal = [NSString stringWithFormat:@"%@▲      %@▲  ", marks, marks];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceUpColor] range:NSMakeRange(0, retVal.length)];
    }else if(value1 < value3 && value2 < value4){
        retVal = [NSString stringWithFormat:@"%@▼      %@▼  ", marks, marks];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceDownColor] range:NSMakeRange(0, retVal.length)];
    }else if(value1 > value3 && value2 < value4){
        retVal = [NSString stringWithFormat:@"%@▲      %@▼  ", marks, marks];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceUpColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceDownColor] range:NSMakeRange(retVal.length / 2, retVal.length -  retVal.length / 2)];
    }else if(value1 < value3 && value2 > value4){
        retVal = [NSString stringWithFormat:@"%@▼      %@▲  ", marks, marks];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceDownColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceUpColor] range:NSMakeRange(retVal.length / 2, retVal.length - retVal.length / 2)];
    }else if(value1 == value3 && value2 > value4){
        retVal = [NSString stringWithFormat:@"%@       %@▲  ", marks, marks];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceUpColor] range:NSMakeRange(retVal.length / 2, retVal.length - retVal.length / 2)];
    }else if(value1 == value3 && value2 < value4){
        retVal = [NSString stringWithFormat:@"%@       %@▼  ", marks, marks];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceDownColor] range:NSMakeRange(retVal.length / 2, retVal.length - retVal.length / 2)];
    }else if(value1 < value3 && value2 == value4){
        retVal = [NSString stringWithFormat:@"%@▼         %@  ", marks, marks];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceDownColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(retVal.length / 2, retVal.length - retVal.length / 2)];
    }else if(value1 > value3 && value2 == value4){
        retVal = [NSString stringWithFormat:@"%@▲         %@  ", marks, marks];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceUpColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(retVal.length / 2, retVal.length - retVal.length / 2)];
    }else{
        retVal = [NSString stringWithFormat:@"%@        %@  ", marks, marks];
        attrStr = [[NSMutableAttributedString alloc]initWithString:retVal];
        
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, retVal.length / 2)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(retVal.length / 2, retVal.length - retVal.length / 2)];
    }
    
    return attrStr;
}

-(NSString *)valueWithDirectionForAR:(double)value1 :(double)value2{
    NSString *retVal;
    
    value1 = floor(value1 * 1000) / 1000;
    value2 = floor(value2 * 1000) / 1000;
    
    if (value1 < 0) {
        if (value1 > value2) {
            retVal = [NSString stringWithFormat:@"%.3f▲ ", value1];
        }else if(value1 < value2){
            retVal = [NSString stringWithFormat:@"%.3f▼ ", value1];
        }else{
            retVal = [NSString stringWithFormat:@"%.3f ", value1];
        }
    }else{
        if (value1 > value2) {
            retVal = [NSString stringWithFormat:@"+%.3f▲ ", value1];
        }else if(value1 < value2){
            retVal = [NSString stringWithFormat:@"+%.3f▼ ", value1];
        }else{
            retVal = [NSString stringWithFormat:@"+%.3f ", value1];
        }
    }
    return retVal;
}

-(NSString *)valueWithDirection:(double)value1 :(double)value2{
    NSString *retVal;
    
    value1 = floor(value1 * 10) / 10;
    value2 = floor(value2 * 10) / 10;
    
    if (value1 > value2) {
        retVal = [NSString stringWithFormat:@"%.1f▲", value1];
    }else if(value1 < value2){
        retVal = [NSString stringWithFormat:@"%.1f▼", value1];
    }else{
         retVal = [NSString stringWithFormat:@"%.1f", value1];
    }
    return retVal;
}



//比對兩數 , 前大於後 紅色 , 前小於後 綠色 , 相等為"藍色"
-(UIColor *)compareTwoValue:(CGFloat)value1 :(CGFloat)value2{
    if (value1 > value2) {
        return [StockConstant PriceUpColor];
    }else if (value1 < value2){
        return[StockConstant PriceDownColor];
    }else{
        return [UIColor blueColor];
    }
}
//比對兩數 , 前大於後 紅色 , 前小於後 綠色 , 相等為"黑色"
-(UIColor *)compareTwoValueBlack:(CGFloat)value1 :(CGFloat)value2{
    if (value1 > value2) {
        return [UIColor redColor];
    }else if (value1 < value2){
        return[StockConstant PriceDownColor];
    }else{
        return [UIColor blackColor];
    }
}

-(UIColor *)compareToZero:(CGFloat)value
{
    if(value > 0){
        return [StockConstant PriceUpColor];
    }else if(value == 0){
        return [UIColor blueColor];
    }else{//綠色
        return [StockConstant PriceDownColor];
    }
}
//有值藍色，否則黑色
-(UIColor *)compareToZeroForEX:(CGFloat)value
{
    if (value == 0) {
        return [UIColor blackColor];
    }else{
        return [UIColor blueColor];
    }
}
-(void)setTarget:(id)obj{
    notifyObj = obj;
}

-(void)stockRankCallBack:(NSMutableArray *)array{
    if ([notifyObj respondsToSelector:@selector(notifyDataArrive:)]) {
        [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:array waitUntilDone:NO];
    }else{
        [self emergingCallBackData:array];
    }
}
//- (id)init
//{
//	if(self = [super init])
//	{
//		datalock = [[NSRecursiveLock alloc] init];
//	}
//	return self;
//}

-(void)emergingCallBackData:(NSMutableArray *)data{
//    [datalock lock];
    InternationalInfoObject_v1 *inter = [[InternationalInfoObject_v1 alloc]init];
    _stockRankNameWithValue = [[NSMutableArray alloc]init];

    for (FSEmergingObject *fsemObj in data) {
        FSEmergingObject *obj = [[FSEmergingObject alloc]init];
        int subType = fsemObj.subType;
//        SymbolFormat1 *symbol = [[SymbolFormat1 alloc]init];
//        symbol = fsemObj.securities;
//        
        obj.securities = fsemObj.securities;
        
        obj.stockRankName = fsemObj.securities -> fullName;

        //技術面排行 - (漲勢排行 , 新高新低排行)
        if (subType == 9 || subType == 10){
            obj.column1 = [inter formatCGFloatDataRank:fsemObj.fieldId1.calcValue];
            obj.column2 = [inter formatCGFloatDataRank:fsemObj.fieldId2.calcValue];
            obj.column3 = [inter formatCGFloatDataRank:fsemObj.fieldId3.calcValue];
            obj.column4 = [inter formatCGFloatDataRank:fsemObj.fieldId4.calcValue];
            obj.column5 = [inter formatCGFloatDataRank:fsemObj.fieldId5.calcValue];
        }
        //基本面排行 - 營收排行
        else if (subType == 16 ){
            //fieldId1:月增率, 2:年增率, 3:合併營收, 4:累計年增率, 5:累計合併營收
            obj.column1 = [CodingUtil stringWithMergedRevenueByValue:fsemObj.fieldId5.calcValue Sign:YES];
            obj.column2 = [inter formatCGFloatDataRank:fsemObj.fieldId3.calcValue];
            obj.column3 = [inter formatCGFloatDataRank:fsemObj.fieldId4.calcValue];
            obj.column4 = [CodingUtil stringWithMergedRevenueByValue:fsemObj.fieldId10.calcValue Sign:YES];
            obj.column5 = [inter formatCGFloatDataRank:fsemObj.fieldId11.calcValue];
        }
        //基本面排行 - 獲利能力
        else if (subType == 17){
            obj.column1 = [inter convertDecimalPoint:fsemObj.fieldId1.calcValue];
            obj.column2 = [self stringWithOperatingMarginByValue:fsemObj.fieldId2.calcValue Sign:YES];
            obj.column3 = [self stringWithOperatingMarginByValue:fsemObj.fieldId3.calcValue Sign:YES];
            obj.column4 = [self stringWithOperatingMarginByValue:fsemObj.fieldId4.calcValue Sign:YES];
            obj.column5 = [NSString stringWithFormat:@"%.2f", fsemObj.fieldId5.calcValue];
            obj.column6 = [inter formatCGFloatDataRank:fsemObj.fieldId6.calcValue];
            obj.column7 = [inter formatCGFloatDataRank:fsemObj.fieldId7.calcValue];
        }
        //基本面排行 - 成長能力
        else if (subType == 18){
            obj.column1 = [self stringWithOperatingMarginByValue:fsemObj.fieldId1.calcValue Sign:YES];
            obj.column2 = [self stringWithOperatingMarginByValue:fsemObj.fieldId2.calcValue Sign:YES];
            obj.column3 = [inter formatCGFloatDataRank:fsemObj.fieldId3.calcValue];
            obj.column4 = [self stringWithOperatingMarginByValue:fsemObj.fieldId4.calcValue Sign:YES];
            obj.column5 = [CodingUtil ConvertDoubleAndZeroValueToString:fsemObj.fieldId5.calcValue];
            obj.column6 = [CodingUtil ConvertDoubleAndZeroValueToString:fsemObj.fieldId6.calcValue];
        }
        //基本面排行 - 償債能力
        else if (subType == 19){
            obj.column1 = [self stringWithOperatingMarginByValue:fsemObj.fieldId1.calcValue Sign:YES];
            obj.column2 = [self stringWithOperatingMarginByValue:fsemObj.fieldId2.calcValue Sign:YES];
            obj.column3 = [inter formatCGFloatDataRank:fsemObj.fieldId3.calcValue];
            obj.column4 = [self stringWithOperatingMarginByValue:fsemObj.fieldId4.calcValue Sign:YES];
            obj.column5 = [CodingUtil ConvertDoubleAndZeroValueToString:fsemObj.fieldId5.calcValue];
        }
        //基本面排行 - 經營能力
        else if (subType == 20){
            obj.column1 = [self stringWithar_dayByValueAndDay:fsemObj.fieldId1.calcValue];
            obj.column2 = [self stringWithar_dayByValueAndDay:fsemObj.fieldId2.calcValue];
            obj.column3 = [self stringWithOperatingMarginByValue:fsemObj.fieldId3.calcValue Sign:YES];
            obj.column4 = [self stringWithOperatingMarginByValue:fsemObj.fieldId4.calcValue Sign:YES];
        
        }
        //基本面排行 - 財務結構
        else if (subType == 21){
            obj.column1 = [NSString stringWithFormat:@"%.2f",fsemObj.fieldId1.calcValue];
            obj.column2 = [self convertPriceValueToString:fsemObj.fieldId2.calcValue];
            obj.column3 = [self convertPriceValueToString:fsemObj.fieldId3.calcValue];
            obj.column4 = [self stringWithOperatingMarginByValue:fsemObj.fieldId4.calcValue Sign:YES];
        }
        [_stockRankNameWithValue addObject:obj];
}


    if ([self.delegate respondsToSelector:@selector(loadDidFinishWithData:)]) {
        [self.delegate loadDidFinishWithData:self];
    }
    
//    [datalock unlock];

    
}@end
@implementation FSEmergingMarketMoverObj



@end