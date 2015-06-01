//
//  FigureSearchMyProfileModel.m
//  WirtsLeg
//
//  Created by Connor on 13/10/28.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureSearchMyProfileModel.h"
#import "FMDB.h"

@implementation FigureSearchMyProfileModel

static NSString *itemIdentifier = @"FigureSearchItemIdentifier";
static int currentDataRow;

+ (FigureSearchMyProfileModel *)sharedInstance {
    static FigureSearchMyProfileModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FigureSearchMyProfileModel alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(NSMutableArray *)searchDefaultKbarWithNumber:(NSNumber *)num{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearchKBarDefault WHERE itemOrder = ?",num];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"highValue"]];
            [dataArray addObject:[message stringForColumn:@"lowValue"]];
            [dataArray addObject:[message stringForColumn:@"openValue"]];
            [dataArray addObject:[message stringForColumn:@"closeValue"]];
        }
    }];
    
    return dataArray;
}

-(NSMutableArray *)searchCustomKbarWithFigureSearchId:(NSNumber *)figureSearchId TNumber:(NSNumber *)tNum{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ? AND tNumber = ?",figureSearchId,tNum];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"highValue"]];
            [dataArray addObject:[message stringForColumn:@"lowValue"]];
            [dataArray addObject:[message stringForColumn:@"openValue"]];
            [dataArray addObject:[message stringForColumn:@"closeValue"]];
        }
    }];
    
    return dataArray;
}

-(NSMutableArray *)actionSearchFigureSearchId{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT FigureSearch_ID, title, image_binary FROM FigureSearch ORDER BY figureSearch_ID"];
        while ([message next]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[message stringForColumn:@"FigureSearch_ID"] forKey:@"FigureSearch_ID"];
            [dict setObject:[message stringForColumn:@"title"] forKey:@"title"];
            [dict setObject:[message dataForColumn:@"image_binary"] forKey:@"image_binary"];
            [dataArray addObject:dict];
        }
    }];
    
    return dataArray;
}

-(NSArray *)actionPlanBtnTitleSearchFigureSearchIdWithFigureSearchID:(NSNumber *)figureSearchID{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearch WHERE FigureSearch_ID = ?", figureSearchID];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"title"]];
        }
    }];
    if ([dataArray count] == 0) {
        return @[@""];
    }
    return dataArray;
}


-(NSMutableArray *)searchFigureSearchIdWithGategory:(NSString *)gategory ItemOrder:(NSNumber *)itemOrder{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearch WHERE Gategory = ? AND itemOrder = ?",gategory,itemOrder];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"figureSearch_ID"]];
            [dataArray addObject:[message stringForColumn:@"title"]];
            [dataArray addObject:[message stringForColumn:@"dayRange"]];
            [dataArray addObject:[message stringForColumn:@"weekRange"]];
            [dataArray addObject:[message stringForColumn:@"monthRange"]];
            [dataArray addObject:[message dataForColumn:@"image_binary"]];
            [dataArray addObject:[message stringForColumn:@"range"]];
            [dataArray addObject:[message stringForColumn:@"color"]];
            [dataArray addObject:[message stringForColumn:@"upLine"]];
            [dataArray addObject:[message stringForColumn:@"kLine"]];
            [dataArray addObject:[message stringForColumn:@"downLine"]];
            if ([message stringForColumn:@"difinition"]==nil) {
                [dataArray addObject:@""];
            }else{
               [dataArray addObject:[message stringForColumn:@"difinition"]];
            }
            [dataArray addObject:[message stringForColumn:@"flatTrendDay"]];
            [dataArray addObject:[message stringForColumn:@"flatTrendWeek"]];
            [dataArray addObject:[message stringForColumn:@"flatTrendMonth"]];
            
        }
    }];
    
    return dataArray;
}

-(void)updateRangeWithFigureSearchId:(NSNumber *)figureSearchId DayRange:(NSNumber *)day WeekRange:(NSNumber *)week MonthRange:(NSNumber *)month{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            [db executeUpdate:@"UPDATE FigureSearch SET dayRange = ? ,weekRange = ?,monthRange = ? WHERE figureSearch_ID = ? ",day,week,month,figureSearchId];
    }];
}

//檢查資料庫是否已經有符合該id的資料，如果有則修改，否則新增
-(void)editKbarValueWithFigureSearchId:(NSNumber *)figureSearchId TNumber:(NSNumber *)tNum High:(NSNumber *)high Low:(NSNumber *)low Open:(NSNumber *)open Close:(NSNumber *)close{
    NSMutableArray * totalCount = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT count(*) AS count FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ? AND tNumber = ?",figureSearchId,tNum];
        while ([message next]) {
            [totalCount addObject:[NSNumber numberWithInt:[message intForColumn:@"count"]]];
        }
    }];
    if ([(NSNumber *)[totalCount objectAtIndex:0]intValue]==0) {
        //新增
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"INSERT INTO FigureSearchKBarValue(ref_figureSearch_ID, tNumber, highValue, lowValue, openValue, closeValue) VALUES(?,?,?,?,?,?)",figureSearchId,tNum,high,low,open,close];
        }];
    }else{
        //修改
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"UPDATE FigureSearchKBarValue SET highValue = ?,lowValue = ?,openValue = ?,closeValue = ? WHERE ref_figureSearch_ID = ? AND tNumber = ?",high,low,open,close,figureSearchId,tNum];
        }];
    }
}

-(void)editTheOriginNum:(NSNumber *)figureSearchId ToMutliTen:(NSNumber *)newFigureSearchId TNumber:(NSNumber *)tNum
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        [db executeUpdate:@"UPDATE FigureSearchKBarValue SET ref_figureSearch_ID = ? WHERE ref_figureSearch_ID = ? AND tNumber = ?",newFigureSearchId,figureSearchId,tNum];
        }
    ];
}

-(void)editKbarFigureSearchId:(NSNumber *)figureSearchId NewFigureSearchId:(NSNumber *)newFigureSearchId TNumber:(NSNumber *)tNum{
    NSMutableArray * data = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ? AND tNumber = ?",figureSearchId,tNum];
        while ([message next]) {
            [data addObject:[message stringForColumn:@"highValue"]];
            [data addObject:[message stringForColumn:@"lowValue"]];
            [data addObject:[message stringForColumn:@"openValue"]];
            [data addObject:[message stringForColumn:@"closeValue"]];
            [data addObject:[message stringForColumn:@"range"]];
            [data addObject:[message stringForColumn:@"color"]];
            [data addObject:[message stringForColumn:@"upLine"]];
            [data addObject:[message stringForColumn:@"kLine"]];
            [data addObject:[message stringForColumn:@"downLine"]];
        }
    }];
    if ([data count]!=0) {
        //記錄舊資料
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"INSERT INTO FigureSearchKBarValue(ref_figureSearch_ID, tNumber, highValue, lowValue, openValue, closeValue, range, color, upLine, kLine, downLine) VALUES(?,?,?,?,?,?,?,?,?,?,?)",newFigureSearchId,tNum,[data objectAtIndex:0],[data objectAtIndex:1],[data objectAtIndex:2],[data objectAtIndex:3],[data objectAtIndex:4],[data objectAtIndex:5],[data objectAtIndex:6],[data objectAtIndex:7],[data objectAtIndex:8]];
        }];
    }
}

-(void)doneEditKBarFigureSearchID:(NSNumber *)figureSearchId NewFigureSearchId:(NSNumber *)newFigureSearchId TNumber:(NSNumber *)tNum theData:(NSArray *)dataArray type:(NSUInteger)storeType
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    //get the currentDataRow
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT figureSearchKBarValue_ID FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ?",newFigureSearchId];
        while ([message next]) {
            currentDataRow = [message intForColumn:@"figureSearchKBarValue_ID"];
            [array addObject:[NSNumber numberWithInt:currentDataRow]];
        }
        [message close];
    }];
    
    __block BOOL modify = NO;
    if(storeType == FSFigureCustomStoreTypeTempStore){
        //暫存，指在editViewController detailViewController 裡的任何動作都會跑這邊
        [dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
            BOOL success = [db executeUpdate:@"UPDATE FigureSearchKBarValue SET highValue = ?, lowValue = ?, openValue = ?, closeValue = ?, range = ?, color = ?, upLine = ?, kLine = ?, downLine = ?  WHERE ref_figureSearch_ID = ? AND tNumber = ?",[dataArray objectAtIndex:5],[dataArray objectAtIndex:6],[dataArray objectAtIndex:7],[dataArray objectAtIndex:8],[dataArray objectAtIndex:0],[dataArray objectAtIndex:1],[dataArray objectAtIndex:2],[dataArray objectAtIndex:3],[dataArray objectAtIndex:4],newFigureSearchId,tNum];
            if(!success){
                *rollback = YES;
                return;
            }
            modify = YES;
        }];
    }else if(storeType == FSFigureCustomStoreTypeSubmitStore){
        //確定儲存，在離開caseViewController 時，按下確認儲存的動作時會跑這邊
        int targetFigureSearchID = [newFigureSearchId intValue] / 10;
        [self deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:targetFigureSearchID]];
        [dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for(int i = 0; i < array.count; i++){
                BOOL success = [db executeUpdate:@"UPDATE FigureSearchKBarValue SET ref_figureSearch_ID = ? WHERE figureSearchKBarValue_ID = ?",[NSNumber numberWithInt:targetFigureSearchID],array[i]];
                if(!success){
                    *rollback = YES;
                    return;
                }
                modify = YES;
            }
        }];
    }
}

-(int)getCounts:(NSNumber *)figureSearchID
{
    //用來判斷目前資料列的列數
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    __block int counts;
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT COUNT(*) AS COUNT FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ?", figureSearchID];
        while ([message next]) {
            counts = [message intForColumn:@"COUNT"];
        }
        [message close];
    }];
    return counts;
}

-(void)changeFigureSearchTitleWithFigureSearchId:(NSNumber *)figureSearchId String:(NSString *)title{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE FigureSearch SET title = ? WHERE figureSearch_ID = ? ",title,figureSearchId];
    }];
}

-(int)checkFigureSearchTitle:(NSString *)title SearchID:(NSNumber *)figureSearchId System:(NSString *)system{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block int count;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT COUNT(title) AS COUNT FROM FigureSearch WHERE title = ? AND figureSearch_ID != ? AND gategory = ?", title, figureSearchId, system];
        while ([message next]) {
           count = [message intForColumn:@"COUNT"];
        }
        [message close];
    }];
    
    return count;
}

-(void)deleteAllKbarWithFigureSearchId:(NSNumber *)figureSearchId{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"DELETE FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ?",figureSearchId];
    }];

}

-(void)deleteKbarWithFigureSearchId:(NSNumber *)figureSearchId tNum:(NSNumber *)num{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"DELETE FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ? AND tNumber = ?",figureSearchId,num];
    }];

}

-(void)changeFigureSearchImageWithFigureSearchId:(NSNumber *)figureSearchId Image:(NSData *)image{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE FigureSearch SET image_binary = ? WHERE figureSearch_ID = ?",image,figureSearchId];
    }];
}

-(void)updateFigureSearchImageToUSStyle:(NSNumber *)figureSearchId LongOrShort:(NSString *)longOrShort Image:(NSData *)image{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE FigureSearch SET image_binary = ? WHERE figureSearch_ID = ? AND gategory = ?",image,figureSearchId,longOrShort];
    }];
}

-(void)changeFigureSearchNameWithFigureSearchId:(NSNumber *)figureSearchId Name:(NSString *)name{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE FigureSearch SET title = ? WHERE figureSearch_ID = ?",name,figureSearchId];
    }];
}

-(BOOL)CountKbarWithFigureSearchId:(NSNumber *)figureSearchId{
    BOOL custom;
    NSMutableArray * totalCount = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT count(*) AS count FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ?",figureSearchId];
        while ([message next]) {
            [totalCount addObject:[NSNumber numberWithInt:[message intForColumn:@"count"]]];
        }
    }];
    if ([(NSNumber *)[totalCount objectAtIndex:0]intValue]==0) {
        custom = NO;
    }else{
        custom = YES;
    }
    return custom;
}

-(NSData *)searchImageWithGategory:(NSString *)gategory ItemOrder:(NSNumber *)itemOrder{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearch WHERE Gategory = ? AND itemOrder = ?",gategory,itemOrder];
        while ([message next]) {
            [dataArray addObject:[message dataForColumn:@"image_binary"]];
        }
    }];
    
    return [dataArray objectAtIndex:0];
}

-(NSData *)searchImageWithFigureSearch_ID:(NSString *)figuresearch_ID{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearch WHERE figuresearch_ID = ?", figuresearch_ID];
        while ([message next]) {
            [dataArray addObject:[message dataForColumn:@"image_binary"]];
        }
    }];
    
    return [dataArray objectAtIndex:0];
}

-(NSArray *)getDWMRange:(int)target
{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearch WHERE figureSearch_ID = ?",[NSNumber numberWithInt:target]];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"dayRange"]];
            [dataArray addObject:[message stringForColumn:@"weekRange"]];
            [dataArray addObject:[message stringForColumn:@"monthRange"]];
        }
    }];
    
    return dataArray;
}

-(NSMutableArray *)searchLastResultWithFigureSearchId:(NSNumber *)figureSearchId Range:(NSString *)range SearchType:(NSString *)type{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearchResultInfo WHERE ref_figureSearch_ID = ? AND range_type = ? AND search_type = ?",figureSearchId,range,type];
        while ([message next]) {
            [dataArray addObject:[NSNumber numberWithInt:[message intForColumn:@"figureSearchResultInfo_ID"]]];
            [dataArray addObject:[message dateForColumn:@"search_date"]];
            [dataArray addObject:[message stringForColumn:@"search_range"]];
            [dataArray addObject:[NSNumber numberWithInt:[message intForColumn:@"result_total"]]];
        }
    }];
    
    return dataArray;
}

-(NSMutableArray *)searchResultInfoWithFigureSearchId:(NSNumber *)figureSearchId{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearchResultInfo WHERE ref_figureSearch_ID = ?",figureSearchId];
        while ([message next]) {
            [dataArray addObject:[NSNumber numberWithInt:[message intForColumn:@"figureSearchResultInfo_ID"]]];
        }
    }];
    
    return dataArray;
}

-(void)deleteResultInfoWithFigureSearchId:(NSNumber *)figureSearchId{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"DELETE FROM FigureSearchResultInfo WHERE ref_figureSearch_ID = ?",figureSearchId];
    }];
}

-(void)setFigureSearchToDefaultWithFigureSearchId:(NSNumber *)figureSearchId{
    NSMutableArray * totalCount = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT itemOrder FROM FigureSearch WHERE figureSearch_ID = ?",figureSearchId];
        while ([message next]) {
            [totalCount addObject:[NSNumber numberWithInt:[message intForColumn:@"itemOrder"]]];
        }
    }];
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    NSString * name;
    if ([group isEqualToString:@"us"]) {
        name = [NSString stringWithFormat:@"My %@",[totalCount objectAtIndex:0]];
    }else if ([group isEqualToString:@"cn"]){
        name = [NSString stringWithFormat:@"形态 %@",[totalCount objectAtIndex:0]];
    }else{
        name = [NSString stringWithFormat:@"型態 %@",[totalCount objectAtIndex:0]];
    }
        //修改
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"UPDATE FigureSearch SET trend = -1,title = ?,dayRange = 3.5,weekRange = 5,monthRange = 10,flatTrendDay = 3,flatTrendWeek = 5,flatTrendMonth = 10 WHERE figureSearch_ID = ?",name,figureSearchId];
        }];
}


-(void)editFigureSearchResultInfoWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type SearchDate:(NSDate *)date SearchRange:(NSString *)range Total:(NSNumber *)total SearchType:(NSString *)searchType{
    NSMutableArray * totalCount = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT count(*) AS count FROM FigureSearchResultInfo WHERE ref_figureSearch_ID = ? AND range_type = ? AND search_type = ?",figureSearchId,type,searchType];
        while ([message next]) {
            [totalCount addObject:[NSNumber numberWithInt:[message intForColumn:@"count"]]];
        }
    }];
    if ([(NSNumber *)[totalCount objectAtIndex:0]intValue]==0) {
        //新增
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"INSERT INTO FigureSearchResultInfo(ref_figureSearch_ID, range_type, search_date, search_range, result_total,search_type) VALUES(?,?,?,?,?,?)",figureSearchId,type,date,range,total,searchType];
        }];
    }else{
        //修改
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"UPDATE FigureSearchResultInfo SET search_date = ?,search_range = ?,result_total = ? WHERE ref_figureSearch_ID = ? AND range_type = ? AND search_type = ?",date,range,total,figureSearchId,type,searchType];
        }];
    }
}

-(void)editFigureSearchResultDataWithFigureSearchResultInfoId:(NSNumber *)figureSearchResultInfoId DataArray:(NSArray *)data MarkPriceArray:(NSArray *)markPriceArray{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"DELETE FROM FigureSearchResultData WHERE ref_figureSearchResultInfo_ID = ?",figureSearchResultInfoId];
    }];
    for (int i =0; i<[data count]; i++) {
        SymbolFormat1 * symbol = [data objectAtIndex:i];
        NSString * identCode = [NSString stringWithFormat:@"%c%c",symbol->IdentCode[0],symbol->IdentCode[1]];
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"INSERT INTO FigureSearchResultData(ref_figureSearchResultInfo_ID, identCode, symbol,markPrice,fullName) VALUES(?,?,?,?,?)",figureSearchResultInfoId,identCode,symbol->symbol,[markPriceArray objectAtIndex:i],symbol->fullName];
        }];
    }
}

-(NSMutableArray *)searchFigureSearchResultDataWithFigureSearchResultInfoId:(NSNumber *)figureSearchResultInfoId{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    NSMutableArray * markPriceArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearchResultData WHERE ref_figureSearchResultInfo_ID = ?",figureSearchResultInfoId];
        while ([message next]) {
            SymbolFormat1 * symbol = [[SymbolFormat1 alloc]init];
            symbol ->symbol = [message stringForColumn:@"symbol"];
            symbol ->IdentCode[0] = [[message stringForColumn:@"identCode"] characterAtIndex:0];
            symbol ->IdentCode[1] = [[message stringForColumn:@"identCode"] characterAtIndex:1];
            [dataArray addObject:symbol];
            [markPriceArray addObject:[NSNumber numberWithFloat:[message doubleForColumn:@"markPrice"]]];
            symbol->fullName = [message stringForColumn:@"fullName"];
        }
    }];
    
    NSMutableArray * array = [[NSMutableArray alloc]initWithObjects:dataArray,markPriceArray, nil];
    return array;
}

-(void)deleteFigureSearchResultDataWithFigureSearchResultInfoId:(NSNumber *)figureSearchResultInfoId{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"DELETE FROM FigureSearchResultData WHERE ref_figureSearchResultInfo_ID = ?",figureSearchResultInfoId];
    }];
}


-(NSMutableArray *)searchStockNameWithIdentCode:(NSString *)identCode Symbol:(NSString *)symbol{
    NSMutableArray * name = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT FullName FROM Cat_FullName WHERE IdentCode = ? AND Symbol = ?",identCode,symbol];
        while ([message next]) {
            [name addObject:[message stringForColumn:@"FullName"]];
        }
        
    }];
    return name;
}

-(UIViewController *)popBackTo:(NSString *)target from:(NSArray *)array
{
    UIViewController *willBackTo = nil;
    for(id controller in array){
        if([controller isKindOfClass:[NSClassFromString(target) class]]){
            willBackTo = controller;
        }
    }
    return willBackTo;
}

-(void)addTrackWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type IdentCode:(NSString *)identCode Symbol:(NSString *)symbol TrackDate:(NSDate *)date SearchType:(NSString *)searchType MarkPrice:(NSNumber *)markPrice FullName:(NSString *)fullName{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"INSERT INTO FigureSearchTrack(ref_figureSearch_ID, range_type, identCode,symbol,track_date,search_type,markPrice,fullName) VALUES(?,?,?,?,?,?,?,?)",figureSearchId,type,identCode,symbol,date,searchType,markPrice,fullName];
    }];
}

-(BOOL)searchTrackWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type IdentCode:(NSString *)identCode Symbol:(NSString *)symbol TrackDate:(NSDate *)date SearchType:(NSString *)searchType{
    BOOL trackCount;
    NSMutableArray * totalCount = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet * message = [db executeQuery:@"SELECT count(*) AS count FROM FigureSearchTrack WHERE ref_figureSearch_ID = ? AND range_type = ? AND identCode = ? AND symbol = ? AND Track_date = ? AND search_type = ?",figureSearchId,type,identCode,symbol,date,searchType];
        while ([message next]) {
            [totalCount addObject:[NSNumber numberWithInt:[message intForColumn:@"count"]]];
        }
    }];
    if ([(NSNumber *)[totalCount objectAtIndex:0]intValue]==0) {
        trackCount = NO;
    }else{
        trackCount = YES;
    }
    return trackCount;
}

-(NSMutableArray *)searchAllTrackWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type SearchType:(NSString *)searchType{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet * message = [db executeQuery:@"SELECT * FROM FigureSearchTrack WHERE ref_figureSearch_ID = ? AND range_type = ? AND search_type = ? GROUP BY identCode,symbol ",figureSearchId,type,searchType];
        while ([message next]) {
            TrackUpFormat * track = [[TrackUpFormat alloc]init];
            track -> symbol =[message stringForColumn:@"symbol"];
            track -> identCode = [message stringForColumn:@"identCode"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            track -> date = [dateFormatter stringFromDate:[message dateForColumn:@"track_date"]];
            track ->fullName = [message stringForColumn:@"fullName"];
            [dataArray addObject:track];
        }
    }];

    return dataArray;
}

-(NSMutableArray *)searchAllTrackWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet * message = [db executeQuery:@"SELECT * FROM FigureSearchTrack WHERE ref_figureSearch_ID = ? AND range_type = ? GROUP BY identCode,symbol ",figureSearchId,type];
        while ([message next]) {
            TrackUpFormat * track = [[TrackUpFormat alloc]init];
            track -> symbol =[message stringForColumn:@"symbol"];
            track -> identCode = [message stringForColumn:@"identCode"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            track -> date = [dateFormatter stringFromDate:[message dateForColumn:@"track_date"]];
            track -> session =[message stringForColumn:@"search_type"];
            track -> markPrice =[message doubleForColumn:@"markPrice"];
            track ->fullName = [message stringForColumn:@"fullName"];
            [dataArray addObject:track];
        }
    }];
    
    return dataArray;
}

-(void)deleteTrackWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type IdentCode:(NSString *)identCode Symbol:(NSString *)symbol TrackDate:(NSDate *)date{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"DELETE FROM FigureSearchTrack WHERE ref_figureSearch_ID = ? AND range_type = ? AND identCode = ? AND symbol = ? AND track_date = ?",figureSearchId,type,identCode,symbol,date];
    }];
}

-(void)deleteAllTrackWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type IdentCode:(NSString *)identCode Symbol:(NSString *)symbol SearchType:(NSString *)searchType{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"DELETE FROM FigureSearchTrack WHERE ref_figureSearch_ID = ? AND range_type = ? AND identCode = ? AND symbol = ?",figureSearchId,type,identCode,symbol];
    }];

}

-(void)deleteAllTrackWithFigureSearchId:(NSNumber *)figureSearchId{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"DELETE FROM FigureSearchTrack WHERE ref_figureSearch_ID = ?",figureSearchId];
    }];
}

-(NSString *)searchFormulaWithFigureSearchId:(NSNumber *)figureSearchId{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;

    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet * message = [db executeQuery:@"SELECT formula FROM FigureSearch WHERE figureSearch_ID = ?",figureSearchId];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"formula"]];
        }
    }];
    
    return [dataArray objectAtIndex:0];
}

-(void)editSearchFormulaWithFigureSearchId:(NSNumber *)figureSearchId Formula:(NSString *)formula{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE FigureSearch SET formula = ? WHERE figureSearch_ID = ?",formula,figureSearchId];
    }];
}

-(void)editFigureSearchConditionsWithFigureSearch_ID:(NSNumber *)figureSearchId Range:(NSString *)range Color:(NSString *)color UpLine:(NSString *)upLine KLine:(NSString *)kLine DownLine:(NSString *)downLine{
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE FigureSearch SET range = ?,color = ?,upLine = ?,kLine = ?,downLine = ? WHERE figureSearch_ID = ?",range,color,upLine,kLine,downLine,figureSearchId];
    }];
    
}


-(NSString *)searchInstructionByControllerName:(NSString *)controllerName{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet * message = [db executeQuery:@"SELECT * FROM Instructions WHERE controllerName = ?",controllerName];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"show"]];
        }
    }];
    
    if ([dataArray count] != 0) {
        return [dataArray objectAtIndex:0];
    } else {
        return @"NO";
    }
}

-(BOOL)searchInstruction{
    BOOL show = YES;
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet * message = [db executeQuery:@"SELECT show FROM Instructions"];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"show"]];
        }
    }];
    
    for (int i=0; i<[dataArray count]; i++) {
        if (![[dataArray objectAtIndex:i]boolValue]) {
            show = NO;
            break;
        }
    }
    
    return show;
}

-(void)setAllInstruction:(NSString *)status{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE Instructions SET show = ?",status];
    }];
    
}


-(void)editInstructionByControllerName:(NSString *)controllerName Show:(NSString *)show{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE Instructions SET show = ? WHERE controllerName = ?",show,controllerName];
    }];
    
}

-(int)searchTrendTypeByFigureSearch_ID:(NSNumber *)figureSearchId{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT trend FROM FigureSearch WHERE figureSearch_ID = ?",figureSearchId];
        while ([message next]) {
            [dataArray addObject:[NSNumber numberWithInt:[message intForColumn:@"trend"]]];
        }
    }];
    
    return [(NSNumber *)[dataArray objectAtIndex:0]intValue];
}

-(void)editTrendValueWithFigureSearchId:(NSNumber *)figureSearchId UpLine:(NSNumber *)upLine DownLine:(NSNumber *)downLine FlatLine:(NSNumber *)flatLine{
    NSMutableArray * totalCount = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT count(*) AS count FROM trendValue WHERE ref_figureSearch_ID = ?",figureSearchId];
        while ([message next]) {
            [totalCount addObject:[NSNumber numberWithInt:[message intForColumn:@"count"]]];
        }
    }];
    if ([(NSNumber *)[totalCount objectAtIndex:0]intValue]==0) {
        //新增
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"INSERT INTO trendValue(ref_figureSearch_ID, upLine, downLine, flatLine) VALUES(?,?,?,?)",figureSearchId,upLine,downLine,flatLine];
        }];
    }else{
        //修改
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"UPDATE trendValue SET upLine = ?,downLine = ?,flatLine = ? WHERE ref_figureSearch_ID = ?",upLine,downLine,flatLine,figureSearchId];
        }];
    }
}

-(NSMutableArray *)searchTrendValueByFigureSearch_ID:(NSNumber *)figureSearchId{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM trendValue WHERE ref_figureSearch_ID = ?",figureSearchId];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"upLine"]];
            [dataArray addObject:[message stringForColumn:@"downLine"]];
            [dataArray addObject:[message stringForColumn:@"flatLine"]];
        }
    }];
    
    return dataArray ;
}

-(void)editTrendWithFigureSearchId:(NSNumber *)figureSearchId Trend:(NSNumber *)trend{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE FigureSearch SET trend = ? WHERE figureSearch_ID = ?",trend,figureSearchId];
    }];

}

-(void)editdifinitionWithFigureSearchId:(NSNumber *)figureSearchId Difinition:(NSString *)difinition{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE FigureSearch SET difinition = ? WHERE figureSearch_ID = ?",difinition,figureSearchId];
    }];
}

-(void)updateFlatTrendWithFigureSearchId:(NSNumber *)figureSearchId DayRange:(NSNumber *)day WeekRange:(NSNumber *)week MonthRange:(NSNumber *)month{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE FigureSearch SET flatTrendDay = ? ,flatTrendWeek = ?,flatTrendMonth = ? WHERE figureSearch_ID = ? ",day,week,month,figureSearchId];
    }];
}


-(NSMutableArray *)searchkBarConditionsWithFigureSearchId:(NSNumber *)figureSearchId tNumber:(NSNumber *)tNumber{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ? AND tNumber = ?",figureSearchId,tNumber];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"range"]];
            [dataArray addObject:[message stringForColumn:@"color"]];
            [dataArray addObject:[message stringForColumn:@"upLine"]];
            [dataArray addObject:[message stringForColumn:@"kLine"]];
            [dataArray addObject:[message stringForColumn:@"downLine"]];
            
        }
    }];
    
    return dataArray;
}

-(NSMutableArray *)searchKBarDetailWithFigureSearchID:(NSNumber *)figureSearchId tNumber:(NSNumber *)tNumber{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ? AND tNumber = ?",figureSearchId,tNumber];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"range"]];
            [dataArray addObject:[message stringForColumn:@"color"]];
            [dataArray addObject:[message stringForColumn:@"upLine"]];
            [dataArray addObject:[message stringForColumn:@"kLine"]];
            [dataArray addObject:[message stringForColumn:@"downLine"]];
            [dataArray addObject:[NSString stringWithFormat:@"%f",[message doubleForColumn:@"highValue"]]];
            [dataArray addObject:[NSString stringWithFormat:@"%f",[message doubleForColumn:@"lowValue"]]];
            [dataArray addObject:[NSString stringWithFormat:@"%f",[message doubleForColumn:@"openValue"]]];
            [dataArray addObject:[NSString stringWithFormat:@"%f",[message doubleForColumn:@"closeValue"]]];
        }
    }];
    
    return dataArray;
}

-(void)changeKbarConditionsWithFigureSearchId:(NSNumber *)figureSearchId TNumber:(NSNumber *)tNum Range:(NSString *)range Color:(NSString *)color UpLine:(NSString *)upLine KLine:(NSString *)kLine DownLine:(NSString *)downLine{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE FigureSearchKBarValue SET range = ?,color = ?,upLine = ?,kLine = ?,downLine = ? WHERE ref_figureSearch_ID = ? AND tNumber = ?",range,color,upLine,kLine,downLine,figureSearchId,tNum];
    }];
}


-(NSString *)searchFullNameWithIdentCode:(NSString *)identCode Symbol:(NSString *)symbol{
    __block NSString * returenStr = @"";
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM Cat_FullName WHERE Symbol = ? and IdentCode = ? GROUP BY Symbol",symbol,identCode];
        while ([message next]) {
            returenStr = [message stringForColumn:@"FullName"];
        }
        
    }];
    
    return returenStr;
}

+(NSURLRequest *)openExplanation{
    
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString *htmlPath = @"https://www.fonestock.com/app/%@/edu/1.html";
    NSString *htmlFile = [NSString stringWithFormat:htmlPath,appid];
    
    NSURL *url = [NSURL URLWithString:htmlFile];
    NSURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    return request;
}

@end
