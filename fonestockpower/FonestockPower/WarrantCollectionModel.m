//
//  WarrantCollectionModel.m
//  FonestockPower
//
//  Created by Kenny on 2014/9/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantCollectionModel.h"
#import "WarrantCollectionViewCell.h"
@implementation WarrantCollectionModel
-(NSMutableDictionary *)getCatName
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSMutableArray *catIDArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM category WHERE ParentID = 650"];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"CatName"]];
            [catIDArray addObject:[NSNumber numberWithInt:[message intForColumn:@"CatID"]]];
        }
    }];
    
    [dictionary setObject:dataArray forKey:@"TargetName"];
    [dictionary setObject:catIDArray forKey:@"CatID"];
    return dictionary;
}

-(NSMutableArray *)getFullName:(int)sectorID
{
    NSString *sector = [NSString stringWithFormat:@"%d",sectorID];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM Cat_FullName WHERE SectorID = ?", sector];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"FullName"]];
        }
    }];

    return dataArray;
}

-(NSString *)getIdentCodeSymbol:(NSString*)fullName
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block NSString *identCode;
    __block NSString *symbol;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM Cat_FullName WHERE FullName = ?", fullName];
        while ([message next]) {
            identCode = [message stringForColumn:@"IdentCode"];
            symbol = [message stringForColumn:@"Symbol"];
        }
    }];
    
    return [NSString stringWithFormat:@"%@ %@", identCode, symbol];
}
@end
