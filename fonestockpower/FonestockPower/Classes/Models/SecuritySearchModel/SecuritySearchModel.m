//
//  SecuritySearchModel.m
//  WirtsLeg
//
//  Created by Neil on 13/9/23.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "SecuritySearchModel.h"
#import "FMDB.h"
#import "FMDatabaseAdditions.h"
#import "NewSymbolKeywordOut.h"
#import "NewSymbolKeywordIn.h"
#import "FSSymbolKeywordOut.h"
#import "FSSymbolKeywordIn.h"

@implementation SecuritySearchModel

-(void)setTarget:(id)obj{
    notifyObj = obj;
}

-(void)setGroupTarget:(id)obj{
    groupNotifyObj = obj;
}

-(void)setChooseTarget:(id)obj{
    chooseObj = obj;
}

-(void)setChooseGroupTarget:(id)obj{
    chooseGroupObj = obj;
}

-(void)setEditChooseTarget:(id)obj{
    editChooseObj = obj;
}

-(void)searchData:(NSNumber *)number{
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT CatName,CatID FROM category WHERE parentID = ? AND CatName NOT LIKE '權證' ORDER BY orderType",number];
        while ([message next]) {
            [nameArray addObject:[message stringForColumn:@"CatName"]];
            [idArray addObject:[message stringForColumn:@"CatID"]];
        }
    }];
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray, nil];
    
    [notifyObj performSelectorOnMainThread:@selector(groupNotifyDataArrive:) withObject:dataArray waitUntilDone:NO];
}

-(void)searchPlateData:(NSNumber *)number
{
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT CatName,CatID FROM category WHERE parentID = ? AND CatName NOT LIKE '權證' ORDER BY orderType",number];
        while ([message next]) {
            [nameArray addObject:[message stringForColumn:@"CatName"]];
            [idArray addObject:[message stringForColumn:@"CatID"]];
        }
    }];
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray, nil];
    
    [notifyObj performSelectorOnMainThread:@selector(plateNotifyDataArrive:) withObject:dataArray waitUntilDone:NO];
}


-(NSMutableArray *)searchGroup1CatId:(int)number{
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT CatID FROM category WHERE parentID = ? ORDER BY orderType",[NSNumber numberWithInt:number]];
        while ([message next]) {
            [idArray addObject:[message stringForColumn:@"CatID"]];
        }
    }];
    
    return idArray;
}

-(NSMutableArray *)searchGroup1Array:(int)number{
    
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT CatName,CatID FROM category WHERE parentID = ? ORDER BY orderType",[NSNumber numberWithInt:number]];
        while ([message next]) {
            [nameArray addObject:[message stringForColumn:@"CatName"]];
            [idArray addObject:[message stringForColumn:@"CatID"]];
        }
    }];
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray, nil];
    
    return dataArray;
}

-(NSMutableArray *)searchGroup2Array:(int)number{
    
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT FullName,Symbol FROM Cat_FullName WHERE SectorID = ? ORDER BY Symbol",[NSNumber numberWithInt:number]];
        while ([message next]) {
            [nameArray addObject:[message stringForColumn:@"FullName"]];
            [idArray addObject:[message stringForColumn:@"Symbol"]];
        }
    }];
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray, nil];
    return dataArray;
}

-(void)searchStock:(NSNumber *)number{
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    NSMutableArray * identCodeArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT FullName,Symbol,IdentCode FROM Cat_FullName WHERE SectorID = ? ORDER BY Symbol",number];
        while ([message next]) {
            [nameArray addObject:[message stringForColumn:@"FullName"]];
            [idArray addObject:[message stringForColumn:@"Symbol"]];
            [identCodeArray addObject:[message stringForColumn:@"IdentCode"]];
        }
    }];
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray,identCodeArray, nil];
    
    [notifyObj performSelectorOnMainThread:@selector(notifySqlDataArrive:) withObject:dataArray waitUntilDone:NO];
}

-(void)searchAmericaStockWithName:(NSString *)name{
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    NSString * search = @"";
    if ([group isEqualToString:@"us"]) {
        search = @"US";
    }else if ([group isEqualToString:@"cn"]){
        search = @"SS or identcode  = SZ";
    }else{
        search = @"TW";
    }
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    NSMutableArray * identCodeArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db ) {
        FMResultSet *message;
        if ([group isEqualToString:@"cn"]){
            message = [db executeQuery:@"SELECT distinct Symbol, FullName,IdentCode FROM ( SELECT Symbol, FullName,IdentCode FROM Cat_FullName WHERE Symbol LIKE ? and (IdentCode = 'SS' or identcode  = 'SZ') UNION ALL SELECT Symbol,FullName,IdentCode FROM Cat_FullName WHERE FullName LIKE ? and (IdentCode = 'SS' or identcode  = 'SZ'))",[NSString stringWithFormat:@"%@%%",name],[NSString stringWithFormat:@"%@%%",name]];
        }else{
            message = [db executeQuery:@"SELECT distinct Symbol, FullName,IdentCode FROM ( SELECT Symbol, FullName,IdentCode FROM Cat_FullName WHERE Symbol LIKE ? and (IdentCode = ?) UNION ALL SELECT Symbol,FullName,IdentCode FROM Cat_FullName WHERE FullName LIKE ? and (IdentCode = ?))",[NSString stringWithFormat:@"%@%%",name],search,[NSString stringWithFormat:@"%@%%",name],search];
        }
        
        
        while ([message next]) {
            if ([message stringForColumn:@"FullName"]!=NULL) {
                [identCodeArray addObject:[message stringForColumn:@"IdentCode"]];
                [idArray addObject:[message stringForColumn:@"Symbol"]];
                [nameArray addObject:[message stringForColumn:@"FullName"]];
            }
        }
        
    }];
    
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray,identCodeArray, nil];
    [notifyObj performSelectorOnMainThread:@selector(notifyArrive:) withObject:dataArray waitUntilDone:NO];
}

-(void)searchAmericaStockWithSymbol:(NSString *)symbol{
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    NSString * search = @"";
    if ([group isEqualToString:@"us"]) {
        search = @"US";
    }else if ([group isEqualToString:@"cn"]){
        search = @"SS or IdentCode = SZ";
    }else{
        search = @"TW";
    }
    
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message;
        if ([group isEqualToString:@"cn"]){
            message = [db executeQueryWithFormat:@"SELECT * FROM Cat_FullName WHERE Symbol = %@ and (IdentCode = 'SS' or IdentCode = 'SZ') GROUP BY Symbol,IdentCode",symbol];
        }else{
            message = [db executeQueryWithFormat:@"SELECT * FROM Cat_FullName WHERE Symbol = %@ and (IdentCode = %@) GROUP BY Symbol",symbol,search];
        }
        
        while ([message next]) {
            if ([message stringForColumn:@"FullName"]!=NULL) {
                [idArray addObject:[message stringForColumn:@"Symbol"]];
                [nameArray addObject:[message stringForColumn:@"FullName"]];
            }
        }
        [message close];
        
    }];
    
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray, nil];
    [notifyObj performSelectorOnMainThread:@selector(notifyArrive:) withObject:dataArray waitUntilDone:NO];
}

-(void)searchSymbolAndFullNameWithSymbolFormat1:(SymbolFormat1 *)symbolformat1{
    NSString *symbol = symbolformat1 -> symbol;
    NSString *identCode = [NSString stringWithFormat:@"%c%c", symbolformat1 -> IdentCode[0], symbolformat1 -> IdentCode[1]];
    
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message;
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN){
            message = [db executeQueryWithFormat:@"SELECT * FROM Cat_FullName WHERE Symbol = %@ and IdentCode = %@ GROUP BY Symbol, IdentCode", symbol, identCode];
        }else{
            message = [db executeQueryWithFormat:@"SELECT * FROM Cat_FullName WHERE Symbol = %@ and IdentCode = %@ GROUP BY Symbol", symbol, identCode];
        }
        
        while ([message next]) {
            if ([message stringForColumn:@"FullName"]!=NULL) {
                [idArray addObject:[message stringForColumn:@"Symbol"]];
                [nameArray addObject:[message stringForColumn:@"FullName"]];
            }
        }
        [message close];
    }];
    
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray, nil];
    [notifyObj performSelectorOnMainThread:@selector(notifyArrive:) withObject:dataArray waitUntilDone:NO];
}

-(int)searchUserStockWithName:(NSString *)name Group:(int)group{
    __block int num=0;
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT count(*) as count FROM groupPortfolio WHERE IdentCodeSymbol LIKE ? and groupID = ?",[NSString stringWithFormat:@"US %@%%",name],[NSNumber numberWithInt:group]];
        while ([message next]) {
            num = [message intForColumn:@"count"];
        }
    }];

    return num;
}

-(int)searchUserStockWithName:(NSString *)name Group:(int)group Country:(NSString *)country{
    __block int num=0;
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT count(*) as count FROM groupPortfolio WHERE IdentCodeSymbol LIKE ? and groupID = ?",[NSString stringWithFormat:@"%@ %@%%",country,  name],[NSNumber numberWithInt:group]];
        while ([message next]) {
            num = [message intForColumn:@"count"];
        }
    }];
    
    return num;
}

-(int)searchUserStockWithSymbol:(NSString *)ids Group:(int)group{
    __block int num=0;
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT count(*) as count FROM groupPortfolio WHERE IdentCodeSymbol = ? and groupID = ?",[NSString stringWithFormat:@"US %@%%",ids],[NSNumber numberWithInt:group]];
        while ([message next]) {
            num = [message intForColumn:@"count"];
        }
    }];
    
    return num;
}

-(int)countUserStockNum{
    __block int num=0;
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT count(*) as count FROM groupPortfolio WHERE groupID = 0"];
        while ([message next]) {
            num = [message intForColumn:@"count"];
        }
    }];
    
    return num;
}


-(void)searchStockWithName:(NSString *)name{
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    NSMutableArray * icArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *search = @"";
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        search = @"US";
    }else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN){
        search = @"SS OR IdentCode = SZ";
    }else{
        search = @"TW";
    }
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message;
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN){
            message = [db executeQuery:@"SELECT * FROM Cat_FullName WHERE (FullName LIKE ? OR Symbol LIKE ?) and (IdentCode = 'SS' or IdentCode = 'SZ') GROUP BY Symbol,IdentCode",[NSString stringWithFormat:@"%@%%",name],[NSString stringWithFormat:@"%@%%",name]];
        }else{
            message = [db executeQuery:@"SELECT * FROM Cat_FullName WHERE (FullName LIKE ? OR Symbol LIKE ?) and IdentCode = ? GROUP BY Symbol", [NSString stringWithFormat:@"%@%%",name], [NSString stringWithFormat:@"%@%%",name], search];
        }

        while ([message next]) {
            if ([message stringForColumn:@"FullName"]!=NULL) {
                [idArray addObject:[message stringForColumn:@"Symbol"]];
                [nameArray addObject:[message stringForColumn:@"FullName"]];
                [icArray addObject:[message stringForColumn:@"IdentCode"]];
            }
        }
        [message close];
    }];

    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray, icArray, nil];
    [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:dataArray waitUntilDone:NO];
}

-(void)searchWarrantStockWithName:(NSString *)name{
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM Cat_FullName WHERE (FullName LIKE ? OR Symbol LIKE ?) and IdentCode = 'TW' GROUP BY Symbol",[NSString stringWithFormat:@"%@%%",name],[NSString stringWithFormat:@"%@%%",name]];
        while ([message next]) {
            if ([message stringForColumn:@"FullName"]!=NULL) {
                [idArray addObject:[message stringForColumn:@"Symbol"]];
                [nameArray addObject:[message stringForColumn:@"FullName"]];
            }
        }
        
    }];
    
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray, nil];
    [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:dataArray waitUntilDone:NO];
}

-(void)searchUserGroup{
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    
    
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        int limit = 5;
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            limit = 5;
        } else {
            limit = 10;
        }
        FMResultSet *message = [db executeQuery:@"SELECT GroupName,GroupID FROM groupName ORDER BY GroupIndex LIMIT ?", [NSNumber numberWithInt:limit]];
        while ([message next]) {
            [nameArray addObject:[message stringForColumn:@"GroupName"]];
            [idArray addObject:[NSNumber numberWithInt:[message intForColumn:@"GroupID"]]];
        }
    }];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray, nil];
    
    [chooseGroupObj performSelectorOnMainThread:@selector(groupNotifyDataArrive:) withObject:dataArray waitUntilDone:NO];
}

-(NSMutableArray *)searchUserStockWithGroup2:(NSNumber*)groupID{
    NSMutableArray * groupArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *  message = [db executeQuery:@"SELECT IdentCodeSymbol FROM groupPortfolio WHERE GroupID = ? ",groupID];
        while ([message next]) {
            NSString * group = [[message stringForColumn:@"IdentCodeSymbol"]substringToIndex:2];
            [groupArray addObject:group];
            NSString * stockId = [[message stringForColumn:@"IdentCodeSymbol"]substringFromIndex:3];
            [idArray addObject:stockId];
            [nameArray addObject:@""];
            //            [nameArray addObject:[self searchStockNameWithId:group Symbol:stockId]];
        }
    }];
    
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray,groupArray, nil];
    
    return dataArray;
}

-(void)searchUserStockWithGroup:(NSNumber*)groupID{
    NSMutableArray * groupArray = [[NSMutableArray alloc]init];
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *  message = [db executeQuery:@"SELECT IdentCodeSymbol FROM groupPortfolio WHERE GroupID = ? ",groupID];
        while ([message next]) {
            NSString * group = [[message stringForColumn:@"IdentCodeSymbol"]substringToIndex:2];
            [groupArray addObject:group];
            NSString * stockId = [[message stringForColumn:@"IdentCodeSymbol"]substringFromIndex:3];
            [idArray addObject:stockId];
            [nameArray addObject:@""];
//            [nameArray addObject:[self searchStockNameWithId:group Symbol:stockId]];
        }
    }];

    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:nameArray,idArray,groupArray, nil];
    
    [chooseObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:dataArray waitUntilDone:NO];
}

-(NSMutableArray *)searchUserStockArrayWithGroup:(NSNumber *)groupID{
    NSMutableArray * identCodeArray = [[NSMutableArray alloc]init];
    NSMutableArray * symbolArray = [[NSMutableArray alloc]init];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *  message = [db executeQuery:@"SELECT IdentCodeSymbol FROM groupPortfolio WHERE GroupID = ? ",groupID];
        while ([message next]) {
            NSString * identCode = [[message stringForColumn:@"IdentCodeSymbol"]substringToIndex:2];
            [identCodeArray addObject:identCode];
            NSString * symbol = [[message stringForColumn:@"IdentCodeSymbol"]substringFromIndex:3];
            [symbolArray addObject:symbol];

        }
    }];
    
    
    NSMutableArray * dataArray = [[NSMutableArray alloc]initWithObjects:identCodeArray,symbolArray, nil];
    NSMutableArray * nameArray = [self searchFullNameWithIdentCodeSymbolArray:dataArray];
    
    [dataArray addObject:nameArray];
    
    return dataArray;
}

-(NSMutableArray *)searchFullNameWithIdentCodeSymbolArray:(NSMutableArray*)IdentCodeSymbolArray{
    NSMutableArray * nameArray = [[NSMutableArray alloc]init];
    NSMutableArray * identCodeArray = [IdentCodeSymbolArray objectAtIndex:0];
    NSMutableArray * symbolArray = [IdentCodeSymbolArray objectAtIndex:1];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    for (int i=0; i<[symbolArray count]; i++) {
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            
            FMResultSet *  message = [db executeQuery:@"SELECT FullName FROM Cat_FullName WHERE IdentCode = ? AND Symbol = ? GROUP BY Symbol",[identCodeArray objectAtIndex:i],[symbolArray objectAtIndex:i]];
            while ([message next]) {
                NSString * fullName = [message stringForColumn:@"FullName"];
                [nameArray addObject:fullName];
                
            }
        }];
    }

    return nameArray;
}


-(NSString *)searchStockNameWithId:(NSString *)identCode Symbol:(NSString *)symbol{
    NSMutableArray * name = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *subMessage = [db executeQuery:@"SELECT FullName FROM Cat_FullName WHERE IdentCode = ? and Symbol = ? group by symbol",identCode,symbol];
        while ([subMessage next]) {
            [name addObject:[subMessage stringForColumn:@"FullName"]];
            
        }
    }];
    return [name objectAtIndex:0];
}




-(void)searchStockFromServerWithName:(NSString *)name{
    searchGroup = 0;
    nowPage = 1;
    searchName = name;
    _nowNumber = 0;
    _allDataFlag = NO;
    SecurityType = malloc(sizeof(UInt8)*6);
    _idArray = [[NSMutableArray alloc]init];
    _nameArray = [[NSMutableArray alloc]init];
    IdentCode = malloc(sizeof(UInt16)*1);
    SecurityType[0] = 1;
    SecurityType[1] = 3;
    SecurityType[2] = 4;
    SecurityType[3] = 5;
    SecurityType[4] = 6;
    SecurityType[5] = 7;
//    IdentCode[0] = 'T'*16 +'W';

#ifdef PatternPowerTW
    UInt16 * sectorID = malloc(sizeof(UInt16)*2);
    sectorID[0] = 2;
    sectorID[1] = 21;
    NewSymbolKeywordOut* packet = [[NewSymbolKeywordOut alloc]initWithSectorCount:2 SectorID:sectorID countPage:200 Page_No:1 FieldType:2 SearchType:0 searchBySectorId:YES];
    
    [packet setSecurityCount:6 SecurityType:SecurityType];
    [packet setKeyword:name];
#elif PatternPowerCN
    FSSymbolKeywordOut *packet = [[FSSymbolKeywordOut alloc]initWithCountPage:200 PageNo:1 FieldType:2 SearchType:0];
    [packet setKeyword:name];
#else
    NewSymbolKeywordOut* packet = [[NewSymbolKeywordOut alloc] initWithIdentCount:1 IdentCode:IdentCode countPage:200 Page_No:1 FieldType:2 SearchType:0];
    [packet setSecurityCount:2 SecurityType:SecurityType];
    [packet setKeyword:name];
    
#endif
    
    
    [FSDataModelProc sendData:self WithPacket:packet];

}

-(void)searchAmericaStockFromServerWithName:(NSString *)name{
    IdentCodeCount = 1;
    searchGroup = 1;
    nowPage = 1;
    searchName = name;
    SecurityType = malloc(sizeof(UInt8)*6);
    _idArray = [[NSMutableArray alloc]init];
    _nameArray = [[NSMutableArray alloc]init];
    _sectorIdArray =[[NSMutableArray alloc]init];
    _symbolArray =[[NSMutableArray alloc]init];
    SecurityType[0] = 1;
    SecurityType[1] = 3;
    SecurityType[2] = 4;
    SecurityType[3] = 5;
    SecurityType[4] = 6;
    SecurityType[5] = 7;
    _nowNumber = 0;
    _allDataFlag = NO;
    IdentCode = malloc(sizeof(UInt16)*1);

#ifdef PatternPowerUS
    IdentCode[0] = 'U'*16 +'S';
    searchGroup = 1;
    NewSymbolKeywordOut* packet = [[NewSymbolKeywordOut alloc]initWithSectorCount:IdentCodeCount SectorID:IdentCode countPage:200 Page_No:1 FieldType:2 SearchType:0 searchGroup:searchGroup];
    [packet setSecurityCount:6 SecurityType:SecurityType];
    [packet setKeyword:name];
    
#elif PatternPowerCN
    FSSymbolKeywordOut *packet = [[FSSymbolKeywordOut alloc]initWithCountPage:200 PageNo:1 FieldType:2 SearchType:0];
    [packet setKeyword:name];
    
#else
    IdentCode[0] = 'T'*16 +'W';
    searchGroup = 0;
    NewSymbolKeywordOut* packet = [[NewSymbolKeywordOut alloc]initWithSectorCount:IdentCodeCount SectorID:IdentCode countPage:200 Page_No:1 FieldType:2 SearchType:0 searchGroup:searchGroup];
    [packet setSecurityCount:6 SecurityType:SecurityType];
    [packet setKeyword:name];
    
#endif

    [FSDataModelProc sendData:self WithPacket:packet];
    
}

-(void)searchAgain:(NewSymbolKeywordIn *)obj{
    _nowNumber += obj -> numSymbol;
    if (obj->flag == 1) {
        _totalNumber = obj->totalNumber;
    }else{
        _totalNumber = 0;
    }
    NSMutableArray * array  = [obj dataArray];
    for( NumberOfSymbol *NOS in array) {
        SymbolFormat1 *security1 = NOS->data;
        security1->sectorID = NOS->sectorID;

        if  (![self searchAmericaStockWithIdentCode:[NSString stringWithFormat:@"%c%c",security1->IdentCode[0],security1->IdentCode[1]] Symbol:security1->symbol TypeId:[NSNumber numberWithUnsignedInt:security1->typeID] SectorID:[NSNumber numberWithUnsignedInt:security1->sectorID]]){
            
            FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
            [dataModal.securityName addOneSecurity:security1];
        }
    }
    
    if (_nowNumber<_totalNumber) {
        if  (_nowNumber % 200 ==0 && _nowNumber > 0){
            nowPage +=1;
#ifdef PatternPowerTW
            UInt16 * sectorID = malloc(sizeof(UInt16)*2);
            sectorID[0] = 2;
            sectorID[1] = 21;
            NewSymbolKeywordOut* packet = [[NewSymbolKeywordOut alloc]initWithSectorCount:2 SectorID:sectorID countPage:200 Page_No:nowPage FieldType:2 SearchType:0 searchBySectorId:YES];
            [packet setSecurityCount:6 SecurityType:SecurityType];
#else
            NewSymbolKeywordOut* packet;
            if (searchGroup ==0) {
                packet = [[NewSymbolKeywordOut alloc] initWithIdentCount:1 IdentCode:IdentCode countPage:200 Page_No:nowPage FieldType:2 SearchType:0];
                [packet setSecurityCount:1 SecurityType:SecurityType];
                [packet setKeyword:searchName];
                [FSDataModelProc sendData:self WithPacket:packet];
            }else{
                packet = [[NewSymbolKeywordOut alloc] initWithSectorCount:IdentCodeCount SectorID:IdentCode countPage:200 Page_No:nowPage FieldType:2 SearchType:0 searchGroup:searchGroup];
                [packet setSecurityCount:1 SecurityType:SecurityType];
                
                
            }
#endif
            [packet setKeyword:searchName];
            [FSDataModelProc sendData:self WithPacket:packet];
        }
        
    }
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        [self searchAmericaStockWithName:searchName];
    }else{
        if (_totalNumber==_nowNumber) {
            [self searchAmericaStockWithName:searchName];
        }else{
            [self searchStockWithName:searchName];
        }
    }

//    [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:_allDataArray waitUntilDone:NO];
    
}

-(BOOL)searchAmericaStockWithIdentCode:(NSString *)identCode Symbol:(NSString *)symbol TypeId:(NSNumber *)typeId SectorID:(NSNumber *)sectorId{
    __block BOOL returenVal = NO;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM Cat_FullName WHERE Symbol = ? and IdentCode = ? and Type_id = ? and SectorID = ? GROUP BY Symbol",symbol,identCode,typeId,sectorId];
        while ([message next]) {
            returenVal = YES;
        }
        
    }];
    
    return returenVal;
}


-(void)countUserStock{
    NSMutableArray * totalCount = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *  message = [db executeQuery:@"SELECT count(IdentCodeSymbol) as count FROM groupPortfolio"];
        while ([message next]) {
            [totalCount addObject:[NSNumber numberWithInt:[message intForColumn:@"count"]]];
        }
    }];
        [editChooseObj performSelectorOnMainThread:@selector(totalCount:) withObject:[totalCount objectAtIndex:0] waitUntilDone:NO];
    
}

-(void)editUserStock:(NSMutableArray *)array{
    NSMutableArray * totalCount = [[NSMutableArray alloc]init];
    NSNumber * add;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *  message = [db executeQuery:@"SELECT count(IdentCodeSymbol) as count FROM groupPortfolio where  IdentCodeSymbol = ? ",[array objectAtIndex:0]];
        while ([message next]) {
            [totalCount addObject:[NSNumber numberWithInt:[message intForColumn:@"count"]]];
        }
    }];
    if ([[totalCount objectAtIndex:0]intValue]==0) {
        add = [NSNumber numberWithInt:1];
    }else{
        //修改
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"DELETE FROM groupPortfolio WHERE IdentCodeSymbol = ?",[array objectAtIndex:0]];
            
        }];
        add = [NSNumber numberWithInt:0];
        
    }
    
    [editChooseObj performSelectorOnMainThread:@selector(editTotalCount:) withObject:add waitUntilDone:NO];
    
}

-(void)deleteUserStock:(NSMutableArray *)array{
    NSNumber * add;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM groupPortfolio WHERE IdentCodeSymbol = ? and groupID = ?",[array objectAtIndex:0],[array objectAtIndex:1]];
    }];
    
    add = [NSNumber numberWithInt:-1];
    
    [editChooseObj performSelectorOnMainThread:@selector(editTotalCount:) withObject:add waitUntilDone:NO];
    
}

-(void)updateUserGroupName:(NSMutableArray *)array{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    for (int i =0; i<[array count]; i++) {
        NSMutableArray * data = [[NSMutableArray alloc]init];
        data = [array objectAtIndex:i];
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE groupName SET groupName = ? WHERE groupName = ? and groupId = ?",[data objectAtIndex:0],[data objectAtIndex:1],[data objectAtIndex:2]];
        
        }];
    }
    
    [editChooseObj performSelectorOnMainThread:@selector(updateGroupName) withObject:nil waitUntilDone:NO];
    
}

-(NSString *)searchFullNameWithIdentCode:(NSString *)identCode Symbol:(NSString *)symbol{
    __block NSString * returenStr = @"";
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM Cat_FullName WHERE Symbol = ? and IdentCode = ? GROUP BY Symbol",symbol,identCode];
        while ([message next]) {
            returenStr = [message stringForColumn:@"FullName"];
        }
        
    }];
    
    return returenStr;
}

@end
