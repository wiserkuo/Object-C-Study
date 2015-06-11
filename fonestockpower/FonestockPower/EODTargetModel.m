//
//  EDOTargetModel.m
//  FonestockPower
//
//  Created by Kenny on 2014/5/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "EODTargetModel.h"
#import "FMDB.h"
#import "EODTargetTableViewCell.h"
@implementation EODTargetModel
-(NSMutableArray *)searchFigureSearchIdWithGategory:(NSString *)gategory ItemOrder:(NSNumber *)itemOrder{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearch WHERE Gategory = ? AND itemOrder = ?",gategory,itemOrder];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"figureSearch_ID"]];
            [dataArray addObject:[message stringForColumn:@"title"]];
            [dataArray addObject:[message dataForColumn:@"image_binary"]];
        }
    }];
    
    return dataArray;
}

-(NSMutableArray *)getLongSystem{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearch WHERE Gategory = 'LongSystem'"];
        while ([message next]) {
            SystemObject *obj = [[SystemObject alloc] init];
            obj.imageID = [message intForColumn:@"figureSearch_ID"];
            obj.imageNmae = [message stringForColumn:@"title"];
            obj.imageData = [message dataForColumn:@"image_binary"];
            [dataArray addObject:obj];
        }
    }];
    
    return dataArray;
}

-(NSMutableArray *)getShortSystem{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearch WHERE Gategory = 'ShortSystem'"];
        while ([message next]) {
            SystemObject *obj = [[SystemObject alloc] init];
            obj.imageID = [message intForColumn:@"figureSearch_ID"];
            obj.imageNmae = [message stringForColumn:@"title"];
            obj.imageData = [message dataForColumn:@"image_binary"];
            [dataArray addObject:obj];
        }
    }];
    
    return dataArray;
}

+(NSData *)getTPNImage:(int)item{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *category;
    __block NSData *imgData = [[NSData alloc]init];
    if(item > 12){
        item -= 12;
        category = @"ShortSystem";
    }else{
        category = @"LongSystem";
    }
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT image_binary FROM FigureSearch WHERE Gategory = ? AND itemOrder = ?",category,[NSNumber numberWithInt:item]];
        while ([message next]) {
            imgData = [message dataForColumn:@"image_binary"];
        }
    }];
    
    return imgData;
}

+(NSString *)getTPNName:(int)item{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *category;
    __block NSString *imgName = @"";
    if(item > 12){
        item -= 12;
        category = @"ShortSystem";
    }else{
        category = @"LongSystem";
    }
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT title FROM FigureSearch WHERE Gategory = ? AND itemOrder = ?",category,[NSNumber numberWithInt:item]];
        while ([message next]) {
            imgName = [message stringForColumn:@"title"];
        }
    }];
    
    return imgName;
}

@end

@implementation SystemObject
@end