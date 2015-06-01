//
//  IndexQuotesObject.m
//  IndexQuotesViewController
//
//  Created by CooperLin on 2014/10/17.
//  Copyright (c) 2014年 CooperLin. All rights reserved.
//

#import "IndexQuotesObject.h"

@implementation IndexQuotesObject{
    FSDataModelProc *model;
    NSMutableArray *dataArray;
}

-(NSMutableArray *)getNameAndIDFromDB
{
    model = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = model.mainDB;
    
    dataArray = [[NSMutableArray alloc] init];
    [dbAgent inDatabase: ^ (FMDatabase * db){
        FMResultSet *message = [db executeQuery:@"SELECT * FROM category WHERE ParentID = 3000"];
        while([message next]){
            showNameAndID *snaID = [[showNameAndID alloc] init];
            snaID->name = [message stringForColumn:@"CatName"];
            snaID->catID = [message stringForColumn:@"CatID"];
            [dataArray addObject:snaID];
        }
        [message close];
    }];
    
    return dataArray;
}

-(NSMutableArray *)getStockNameFromCatFullName:(NSString *)theCatID
{
    model = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = model.mainDB;
    
    NSMutableArray *storeName = [[NSMutableArray alloc] init];
    [dbAgent inDatabase: ^ (FMDatabase * db){
        NSString *theQuery = [NSString stringWithFormat:@"SELECT FullName FROM Cat_FullName WHERE SectorID = %@",theCatID];
        FMResultSet *message = [db executeQuery:theQuery];
        while([message next]){
            NSString *aa = [message stringForColumn:@"FullName"];
            [storeName addObject:aa];
        }
        [message close];
    }];
    
    return storeName;
}

-(NSMutableArray *)fillSymbolObject:(NSInteger)fromWhat
{
    model = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = model.mainDB;
    
    dataArray = [[NSMutableArray alloc] init];
    [dbAgent inDatabase: ^ (FMDatabase *db){
        NSString *theQuery = [NSString stringWithFormat:@"SELECT * FROM Cat_FullName WHERE SectorID = %d",(int)fromWhat];
        FMResultSet *message = [db executeQuery:theQuery];
        while([message next]){
            NewSymbolObject *symUsage = [[NewSymbolObject alloc] init];
            symUsage.identCode = [message stringForColumn:@"IdentCode"];
            symUsage.symbol = [message stringForColumn:@"Symbol"];
            symUsage.fullName = [message stringForColumn:@"FullName"];
            symUsage.typeId = [message intForColumn:@"Type_id"];
            [dataArray addObject:symUsage];
        }
        [message close];
    }];
    return dataArray;
}

-(NSString *)convertDecimalPoint:(CGFloat)value
{
    NSString *retVal;
    if(value > 10000){
        retVal = [NSString stringWithFormat:@"%.0f",value];
    }else if(value > 1000){
        retVal = [NSString stringWithFormat:@"%.1f",value];
    }else if(value > 10){
        retVal = [NSString stringWithFormat:@"%.2f",value];
    }else if(value){
        retVal = [NSString stringWithFormat:@"%.3f",value];
    }else{
        retVal = @"----";
    }
    return retVal;
}
-(UIColor *)compareToZero:(CGFloat)value
{
    if(value > 0){
        return [StockConstant PriceUpColor];
    }else if(value == 0){
        return [UIColor blueColor];
    }else{
        return [StockConstant PriceDownColor];
    }
}
-(NSString *)formatCGFloatData:(CGFloat)value
{
    NSString *str;
    if(value < 0){
        str = [NSString stringWithFormat:@"%.2f",value];
    }else if(value > 0){
        str = [NSString stringWithFormat:@"+%.2f",value];
    }else{
        str = @"----";//[NSString stringWithFormat:@"%.2f",value];
    }
    return str;
}

-(NSString *)forTWUse:(NSString *)hasLetter
{
    if([hasLetter isEqualToString:@"----"] || [hasLetter isEqualToString:@"0"])return @"----";
    NSString *str = hasLetter;
    
    if([hasLetter rangeOfString:@"B"].location != NSNotFound){
        CGFloat dd = [[hasLetter stringByReplacingOccurrencesOfString:@"B" withString:@""] floatValue] * 10;
        str = [NSString stringWithFormat:@"%@億",[self specialUsage:dd]];
    }else if([hasLetter rangeOfString:@"M"].location != NSNotFound){
        CGFloat dd = [[hasLetter stringByReplacingOccurrencesOfString:@"M" withString:@""] floatValue] / 100;
        str = [NSString stringWithFormat:@"%@億",[self specialUsage:dd]];
    }else if([hasLetter rangeOfString:@"K"].location != NSNotFound){
        CGFloat dd = [[hasLetter stringByReplacingOccurrencesOfString:@"K" withString:@""] floatValue] * 100;
        str = [NSString stringWithFormat:@"%@萬",[self convertDecimalPoint:dd]];
    }
    return str;
}

-(NSString *)specialUsage:(CGFloat)value
{
    NSString *retVal;
    if(value > 1000){
        retVal = [NSString stringWithFormat:@"%.0f",value];
    }else if(value > 100){
        retVal = [NSString stringWithFormat:@"%.1f",value];
    }else if(value > 10){
        retVal = [NSString stringWithFormat:@"%.2f",value];
    }else{
        retVal = [NSString stringWithFormat:@"%.3f",value];
    }
    return retVal;
}
@end

@implementation showInfoFormat
@end

@implementation allInfoStorage
@end

@implementation getAllCatNameAndID
@end

@implementation showNameAndID
@end