//
//  FSNewsDataModel.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/8.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSNewsDataModel.h"
#import "FSNewsSnDataOut.h"
#import "FSNewsSnDataIn.h"
#import "FSNewsTitleDataOut.h"
#import "NewsContentOut.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "mime.h"

int snDateSn = 0;
@implementation FSNewsDataModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDataBase];
    }
    return self;
}

-(void)initDataBase{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS NewsSnDate (Date INTEGER, SectorID INTEGER PRIMARY KEY NOT NULL, Sn INTEGER)"];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS NewsContentDate (Date INTEGER, Time INTEGER, NewsSN INTEGER PRIMARY KEY NOT NULL, Sn INTEGER, SectorID INTEGER, Title TEXT, Content TEXT, HadRead INTEGER, TypeFlag INTEGER, ContentFlag INTEGER )"];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS NewsUrl (TimeStamp TEXT, SectorID INTEGER, Url TEXT PRIMARY KEY NOT NULL)"];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS NewsContentUrl (Time TEXT, Title TEXT, ContentUrl TEXT PRIMARY KEY NOT NULL, Url TEXT, HadRead INTEGER, SectorID INTEGER)"];
    }];
}

- (void)updateSyncDate:(NSMutableArray *)array{
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    for (NewsSnData *snData in array) {
        __block BOOL hasData = NO;
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            FMResultSet *message = [db executeQuery:@"SELECT * FROM NewsSnDate WHERE SectorID = ?",[NSNumber numberWithUnsignedInt:snData.sectorID]];
            while ([message next]) {
                hasData = YES;
            }
            [message close];
            if (hasData) {
                [db executeUpdate:@"UPDATE NewsSnDate SET Date = ?, Sn = ? WHERE SectorID = ?",[NSNumber numberWithUnsignedInt:snData.date],[NSNumber numberWithUnsignedInt:snData.sn],[NSNumber numberWithUnsignedInt:snData.sectorID]];
            }else{
                [db executeUpdate:@"INSERT INTO NewsSnDate (Date, SectorID, Sn) VALUES (?,?,?)",[NSNumber numberWithUnsignedInt:snData.date],[NSNumber numberWithUnsignedInt:snData.sectorID],[NSNumber numberWithUnsignedInt:snData.sn]];
            }
        }];
    }
}

-(NSMutableArray *)loadDB:(int)parentID{
    
    NSMutableArray *newsNameAndCatID = [NSMutableArray new];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM category WHERE ParentID = ?", [NSNumber numberWithInt:parentID]];
        while ([message next]) {
            FinancialNews *newsObj = [FinancialNews new];
            newsObj.btnName = [message stringForColumn:@"CatName"];
            newsObj.catID = [message intForColumn:@"CatID"];
            [newsNameAndCatID addObject:newsObj];
        }
        [message close];
    }];
    
    return newsNameAndCatID;
}



-(void)setTarget:(id)obj{
    notifyObj = obj;
}

//-(void)newsModelCallBack:(NSMutableArray *)array{
//    [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:array waitUntilDone:NO];
//}

-(void)sendPacketWithRootID{
    
    //sectorID = rootID:5 (新聞)
    FSNewsSnDataOut *snDataPacket = [[FSNewsSnDataOut alloc]initWithSectorID:5];
    [FSDataModelProc sendData:self WithPacket:snDataPacket];
}

-(void)sendPacketWithSectorID:(int)sectorID{
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
//    int __block snDateSn = 0;
    int __block contentSn = 0;
    int __block snDate = 0;
    int __block contentDate = 0;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {

//        FMResultSet *message = [db executeQuery:@"SELECT NewsSnDate.Sn, MAX(NewsContentDate.Sn), NewsSnDate.Date, MAX(NewsContentDate.Date) FROM NewsSnDate JOIN NewsContentDate ON NewsSnDate.SectorID = NewsContentDate.SectorID WHERE NewsContentDate.SectorID = ?", [NSNumber numberWithInt:sectorID]];
        FMResultSet *message = [db executeQuery:@"SELECT * FROM NewsSnDate WHERE SectorID = ?", [NSNumber numberWithInt:sectorID]];
        while ([message next]) {
            snDateSn = [message intForColumn:@"Sn"];
            snDate = [message intForColumn:@"Date"];
//                        snDateSn = [message intForColumnIndex:0];
//                        snDate = [message intForColumnIndex:1];
//            contentDate = [message intForColumn:@""];
        }
        [message close];
        
        FMResultSet *message1 = [db executeQuery:@"SELECT MAX(Sn), Date FROM NewsContentDate WHERE SectorID = ? AND Date = ?", [NSNumber numberWithInt:sectorID], [NSNumber numberWithInt:snDate]];
        while ([message1 next]) {
            contentSn = [message1 intForColumnIndex:0];
            contentDate = [message1 intForColumn:@"Date"];
        }
        [message1 close];
    }];
    if (snDate != contentDate && contentDate == 0 && snDateSn != 0) {
        FSNewsTitleDataOut *titleDataPacket = [[FSNewsTitleDataOut alloc]initWithSectorID:sectorID beginSN:0];
        [FSDataModelProc sendData:self WithPacket:titleDataPacket];
    }else{
        if (snDateSn != 0 && snDateSn != contentSn) {
            FSNewsTitleDataOut *titleDataPacket = [[FSNewsTitleDataOut alloc]initWithSectorID:sectorID beginSN:contentSn endSN:snDateSn];
            [FSDataModelProc sendData:self WithPacket:titleDataPacket];
        }else{
            NSMutableArray *array = [NSMutableArray arrayWithArray:[self loadDBTitleWithSectorID:sectorID]];
            [array addObject:[NSNumber numberWithInt:snDateSn]];
//            [array addObject:[snDateSn int]]
            [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:array waitUntilDone:NO];
        }
    }
}

-(void)newsSnDataCallBack:(NSMutableArray *)array{
    
    [self updateSyncDate:array];
    [notifyObj performSelectorOnMainThread:@selector(rootSectorIDDataArrive) withObject:nil waitUntilDone: NO];
    
}

-(void)newsTitleDataCallBack:(NSMutableArray *)array{
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    NSMutableArray *titleArray = [NSMutableArray new];

    if ([array firstObject] != nil) {
        
        for (NewsTitleData *titleData in array) {
            NewNewsContentFormat1 *newsObj = titleData.newsContent;
            __block BOOL hasData = NO;
            [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
                FMResultSet *message = [db executeQuery:@"SELECT * FROM NewsContentDate WHERE NewsSn = ?",[NSNumber numberWithUnsignedInt:newsObj.newsSN]];
                while ([message next]) {
                    hasData = YES;
                }
                [message close];

                if (hasData) {
    //                [db executeUpdate:@"UPDATE NewsContentDate SET SyncDate = ?, Sn = ? WHERE SectorID = ?",[NSNumber numberWithUnsignedInt:snData.date],[NSNumber numberWithUnsignedInt:snData.sn],[NSNumber numberWithUnsignedInt:snData.sectorID]];
                }else{
                    [db executeUpdate:@"INSERT INTO NewsContentDate (Date, Time, NewsSN, Sn, SectorID, Title, Content, HadRead, TypeFlag, ContentFlag) VALUES (?,?,?,?,?,?,?,?,?,?)",[NSNumber numberWithUnsignedInteger:titleData.date], [NSNumber numberWithUnsignedInteger:newsObj.time], [NSNumber numberWithUnsignedInteger:newsObj.newsSN], [NSNumber numberWithUnsignedInteger:newsObj.sN], [NSNumber numberWithUnsignedInteger:titleData.rootSectorID] , newsObj.mimeString ,[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],[NSNumber numberWithUnsignedInteger:newsObj.type], [NSNumber numberWithBool:newsObj.contentFlag]];
                }
            }];
        }
        NewsTitleData *titleData = [array objectAtIndex:0];
        
        if (titleData.retCode == 0) {
            
            titleArray = [self loadDBTitleWithSectorID:titleData.rootSectorID];
            [titleArray addObject:[NSNumber numberWithInt:snDateSn]];


        }
    }
    [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:titleArray waitUntilDone: NO];
}

-(NSMutableArray *)loadDBTitleWithSectorID:(int)sectorID{
    NSMutableArray *titleArray = [NSMutableArray new];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;

    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM NewsContentDate WHERE SectorID = ? ORDER BY Date DESC, Time DESC",[NSNumber numberWithInt:sectorID]];
        while ([message next]) {
            FinancialNews *newsObj = [FinancialNews new];
            newsObj.tableViewTitle = [message stringForColumn:@"Title"];
            newsObj.tableViewDate = [message intForColumn:@"Date"];
            newsObj.tableViewTime = [message intForColumn:@"Time"];
            newsObj.hadRead = [message intForColumn:@"HadRead"];
            newsObj.newsSN = [message intForColumn:@"NewsSN"];
            [titleArray addObject:newsObj];
        }
        [message close];
    }];
    return titleArray;
}

-(NSMutableArray *)loadDBContentWithNewsSN:(UInt32)newsSN{
    NSMutableArray *titleArray = [NSMutableArray new];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM NewsContentDate WHERE NewsSN = ?",[NSNumber numberWithUnsignedInt:newsSN]];
        while ([message next]) {
            FinancialNews *newsObj = [FinancialNews new];
            newsObj.tableViewTitle = [message stringForColumn:@"Title"];
            newsObj.tableViewDate = [message intForColumn:@"Date"];
            newsObj.tableViewTime = [message intForColumn:@"Time"];
            newsObj.newsSN = [message intForColumn:@"NewsSN"];
            newsObj.content = [message stringForColumn:@"Content"];
            newsObj.type = [message intForColumn:@"TypeFlag"];
            newsObj.sectorID = [message intForColumn:@"SectorID"];
            [titleArray addObject:newsObj];
        }
        [message close];
    }];
    return titleArray;
}

-(NSString *)loadDBCatNameWithSectorID:(int)sectorID{

    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block int catID = 0;
    __block NSString *childName = nil;
    __block NSString *parentName = nil;
    
    [ dbAgent inDatabase: ^ ( FMDatabase * db){
        FMResultSet *message = [db executeQuery:@"SELECT * FROM category WHERE CatID = ?", [NSNumber numberWithInt:sectorID]];
        while ([message next]){
            catID = [message intForColumn:@"ParentID"];
            childName = [message stringForColumn:@"CatName"];
            
        }
        [message close];
        
        FMResultSet *message1 = [db executeQuery:@"SELECT * FROM category WHERE CatID = ?", [NSNumber numberWithInt:catID]];
        while ([message1 next]){
            parentName = [message1 stringForColumn:@"CatName"];
        }
        if ([parentName isEqualToString:@"全球財金"]) {
            parentName = @"財金分析";
        }
        [message1 close];
    }];
    
    return [NSString stringWithFormat:@"%@/%@", parentName, childName];
    
}
-(int)loadDBCountWithSectorID:(int)sectroID{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    __block int count = 0;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT Count(*) AS COUNT FROM NewsContentDate WHERE SectorID = ?",[NSNumber numberWithInt:sectroID]];
        while ([message next]) {
            count = [message intForColumn:@"COUNT"];
        }
        [message close];

    }];
    return count;
}

-(int)loadDBCountWithSectorIDForURL:(int)sectroID{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    __block int count = 0;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT Count(*) AS COUNT FROM NewsContentUrl WHERE SectorID = ?",[NSNumber numberWithInt:sectroID]];
        while ([message next]) {
            count = [message intForColumn:@"COUNT"];
        }
        [message close];
        
    }];
    return count;
}

-(NSMutableArray *)loadDBNavNameWithRootID{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSMutableArray *navName = [NSMutableArray new];
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM category WHERE ParentID = 5 ORDER BY OrderType ASC"];
        while ([message next]) {
            NSString *name = [message stringForColumn:@"CatName"];
            [navName addObject:name];
        }
        [message close];
        
    }];
    return navName;
}

-(NSMutableArray *)loadDBContentTitleAndUrlWithSectorID:(int)sectorID{
    NSMutableArray *urlArray = [[NSMutableArray alloc]init];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM NewsContentUrl WHERE SectorID = ? ORDER BY Time DESC", [NSNumber numberWithInt:sectorID]];
        while ([message next]) {
            FinancialNews *newObj = [[FinancialNews alloc]init];
            newObj.tableViewTitle = [message stringForColumn:@"Title"];
            newObj.urlContentTime = [message stringForColumn:@"Time"];
            newObj.content = [message stringForColumn:@"ContentUrl"];
            newObj.hadRead = [message intForColumn:@"HadRead"];
            [urlArray addObject:newObj];
        }
        [message close];
        
    }];
    return urlArray;
}
-(NSString *)loadDBCatNameWithSectorIDForURL:(int)sectorID{
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block NSString *catName = nil;
    
    [ dbAgent inDatabase: ^ ( FMDatabase * db){
        FMResultSet *message = [db executeQuery:@"SELECT * FROM category WHERE CatID = ?", [NSNumber numberWithInt:sectorID]];
        while ([message next]){
            catName = [message stringForColumn:@"CatName"];
            
        }
        [message close];
    }];
    return catName;
}

//send http request to server then get xml and save to DB
-(void)parseNewsUrlAndSaveToDB{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    __block NSString *timeStamp = @"";
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT TimeStamp FROM NewsUrl LIMIT 1"];
        while ([message next]) {
            timeStamp = [message stringForColumn:@"TimeStamp"];
        }
        [message close];
    }];
    

    NSString *pathUrl = [NSString stringWithFormat:@"%@/query/rss_news.cgi?time_stamp=%@",[FSFonestock sharedInstance].queryServerURL, timeStamp];
    NSData *urlData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pathUrl]] returningResponse:nil error:nil];
    DDXMLDocument *xmlCode = [[DDXMLDocument alloc]initWithData:urlData options:0 error:nil];
    
    
    NSArray *codeArray = [xmlCode nodesForXPath:@"//code" error:nil];
    DDXMLDocument *codeNode = [codeArray objectAtIndex:0];
    NSString *code = [codeNode stringValue];
    
    if ([code isEqualToString:@"0"]) {
        NSArray *timeArray = [xmlCode nodesForXPath:@"//time_stamp" error:nil];
        DDXMLDocument *timeNode = [timeArray objectAtIndex:0];
        NSString *timeStamp = [timeNode stringValue];
        

        
        NSArray *sectorConunt = [xmlCode nodesForXPath:@"//sector" error:nil];
        for (int i = 1; i <= [sectorConunt count]; i ++){
            NSString *sectorPath = [NSString stringWithFormat:@"//sector[%d]/*", i];
            NSArray *sectorArry = [xmlCode nodesForXPath:sectorPath error:nil];
            
            int sectorID = [(NSNumber *)[sectorArry objectAtIndex:0]intValue];
            
            for (int i = 2; i < [sectorArry count]; i++){
                NSString *url = [[sectorArry objectAtIndex:i]stringValue];

                if (![[url substringWithRange:NSMakeRange(7, 8)] isEqualToString:@"tw.money"]) {
                    __block BOOL hasData = NO;
                    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
                        FMResultSet *message = [db executeQuery:@"SELECT * FROM NewsUrl WHERE Url = ?", url];
                        while ([message next]) {
                            hasData = YES;
                        }
                        [message close];
                        if (hasData) {
                            [db executeUpdate:@"UPDATE NewsUrl SET TimeStamp = ?, SectorID = ? WHERE Url = ?",timeStamp, [NSNumber numberWithInt:sectorID], url];
                        }else{
                            [db executeUpdate:@"INSERT INTO NewsUrl (TimeStamp, SectorID, Url) VALUES (?,?,?)",timeStamp, [NSNumber numberWithInt:sectorID], url];
                        }
                    }];
                }
            }
        }
    }
}

-(void)parseNewsContentUrlAndSaveToDB:(int)sectorID{

    NSMutableArray *pathUrlArray = [[NSMutableArray alloc]init];
//    NSMutableArray *newObjArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM NewsUrl WHERE SectorID = ?", [NSNumber numberWithInt:sectorID]];
        while ([message next]) {
            
            NSString *url = [message stringForColumn:@"Url"];
            [pathUrlArray addObject:url];
        }
        [message close];
    }];
    
    for (int i = 0; i < [pathUrlArray count]; i++){
        NSString *pathUrl = [pathUrlArray objectAtIndex:i];
        NSURL *url = [NSURL URLWithString:pathUrl];

//        NSData *postData = [pathUrl dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSData *postData = [pathUrl dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];

        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/xhtml+xml,application/xml,text/html;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:postData];
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init]
         completionHandler:^(NSURLResponse *response,
                             NSData *data,
                             NSError *error)
         {
             if (error) {
                 NSLog(@"0000000000000000000000000000000000000Httperror parseNewsContentUrl:%@%d", error.localizedDescription, (int)error.code);
             }else{
//                 NSString *a = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//                 NSLog(@"HttpGet parseNewsContentUrl%@" ,a);
                 DDXMLDocument *xmlCode = [[DDXMLDocument alloc]initWithData:data options:0 error:nil];
                 NSArray *itemArray = [xmlCode nodesForXPath:@"//item" error:nil];
                 for (DDXMLElement *items in itemArray) {
                     NSString *title = [[items elementForName:@"title"]stringValue];
                     NSString *url = [[items elementForName:@"link"]stringValue];
                     NSString *time = [self formatContentDate:[[items elementForName:@"pubDate"]stringValue]];
                     
                     __block BOOL hasData = NO;
                     [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
                          FMResultSet *message = [db executeQuery:@"SELECT * FROM NewsContentUrl WHERE ContentUrl = ?", url];
                          while ([message next]) {
                              hasData = YES;
                          }
                          [message close];

                          if (hasData) {
                              [db executeUpdate:@"UPDATE NewsContentUrl SET Title = ?, Time = ? WHERE ContentUrl = ?", title, time, url];
                          }else{
                              [db executeUpdate:@"INSERT INTO NewsContentUrl (Time, Title, ContentUrl, Url, HadRead, SectorID) VALUES (?,?,?,?,?,?)", time, title, url, pathUrl, [NSNumber numberWithInt:0], [NSNumber numberWithInt:sectorID]];
                          }
                     }];
                 }
             }
         }];
    }
    [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:[self loadDBContentTitleAndUrlWithSectorID:sectorID] waitUntilDone: NO];
}

-(NSString *)formatContentDate:(NSString *)date{

    NSArray *aa = [date componentsSeparatedByString:@" "];
    
    if ([[aa lastObject] isEqualToString:@"GMT"]) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];
        
//        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSDate *time = [dateFormatter dateFromString:date];
        
//        NSInteger interval = [zone secondsFromGMTForDate: time];
        
//        NSDate *localeDate = [time  dateByAddingTimeInterval:interval];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:time];
        
        NSString *pp = [NSString stringWithFormat:@"%d/%02d/%02d          %02d:%02d:%02d", (int)components.year, (int)components.month, (int)components.day, (int)components.hour, (int)components.minute, (int)components.second];
        return pp;

    }else{

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"LLL"];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        NSDate *time = [dateFormatter dateFromString:[aa objectAtIndex:2]];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:time];
        
        NSInteger month = [components month];
        NSString *pp = [NSString stringWithFormat:@"%@/%.2ld/%@          %@", [aa objectAtIndex:3], (long)month, [aa objectAtIndex:1], [aa objectAtIndex:4]];
        return pp;

    }
                    
}
-(void)sendNewsContent:(UInt32)sn{

    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dataModel.newsData setTarget:self];
    
    __block NSString *content = nil;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT Content FROM NewsContentDate Where NewsSN = ?", [NSNumber numberWithUnsignedInt:sn]];
        while ([message next]){
            content = [message stringForColumn:@"Content"];
        }
        [message close];
        
    }];
    
    NSNumber *obj = [[NSNumber alloc] initWithLong:sn];
    [self performSelector:@selector(setHadRead:) onThread:dataModel.thread withObject:obj waitUntilDone:NO];
    if ([content isEqualToString:@"0"]) {
        NewsContentOut *packet = [[NewsContentOut alloc] initWithType0SN:sn];
        [FSDataModelProc sendData:self WithPacket:packet];
    }else{
        [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:[self loadDBContentWithNewsSN:sn] waitUntilDone: NO];
    }
}

-(void)notify:(NewsContentIn *)obj{

    __block NSString *mimeString = nil;
    NSMutableArray *array = obj->mimeArray;
    if ([array count] > 0){
        NewsContentFormat2 *content = [array objectAtIndex:0];
        mimeString = content->mimeString;
        if (mimeString == nil)	mimeString = @"無內文";
    }
    else{
        mimeString = @"無內文";
    }
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE NewsContentDate SET Content = ? WHERE newsSN = ?", mimeString, [NSNumber numberWithInt:obj->newsSN]];
    }];

    if (obj->retCode == 0)
    {
        [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:[self loadDBContentWithNewsSN:obj->newsSN] waitUntilDone: NO];
    }
    
    
}

- (void) setHadRead:(NSNumber*)obj
{
    UInt32 newsSN = (UInt32)[obj longValue];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE NewsContentDate SET HadRead = 1 WHERE newsSN = ?", [NSNumber numberWithInt:newsSN]];
    }];
}

- (void) setHadReadNet:(NSString *)obj
{
//    UInt32 newsSN = (UInt32)[obj longValue];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE NewsContentUrl SET HadRead = 1 WHERE ContentUrl = ?", obj];
        
    }];
}

- (NSString *)makeDateStringByDate:(UInt16)date time:(UInt16)time {
    
    int year, month, day;
    int hour, minute;
    NSString *strTime;
    // transfer UInt16 date to normal date presentation
    year = (date>>9) + 1960;
    month = (date>>5) & 0XF;
    day = date & 0X1F;
    NSString *strDate = [NSString stringWithFormat:@"%d-%02d-%02d  ", year, month, day];
    
    // transfer UInt16 time to normal time presentation
    if (time >= 1440 || time == 0)
    {
        strTime = @"";
    }
    else
    {
        hour = time/60;
        minute = time%60;
        strTime = [NSString stringWithFormat:@"   %02d:%02d", hour, minute];
    }
    // combine strDate and strTime
    NSString *dateString = [strDate stringByAppendingString:strTime];
    
    return dateString;
    
}
@end

@implementation NewNewsContentFormat1
@synthesize sN, newsSN, time, type, contentFlag, reserved, length, mimeData, mimeString;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset{
    if (self = [super init]) {
        UInt8 *ptr = *sptr;
        
        sN = [CodingUtil getUInt16:&ptr needOffset:YES];
        newsSN = [CodingUtil getUInt32:ptr];
        ptr += 4;
        time = [CodingUtil getUint16FromBuf:ptr Offset:0 Bits:11];
        type = [CodingUtil getUint16FromBuf:ptr Offset:11 Bits:2];
        contentFlag = [CodingUtil getUint16FromBuf:ptr Offset:13 Bits:1];
        reserved = [CodingUtil getUint16FromBuf:ptr Offset:14 Bits:2];
        ptr += 2;
        
        length = [CodingUtil getUInt16:&ptr needOffset:YES];
        UInt16 mimeLength = length;
        mimeData = (UInt8*)UnpackMimeText((const char*)ptr , &mimeLength);
        if(mimeLength)
            mimeString = [[NSString alloc] initWithBytes:mimeData length:mimeLength encoding:NSUTF8StringEncoding];
        ptr += length;

        *sptr = ptr;
    }
    return self;
}

@end


@implementation FinancialNews
@end

@implementation NewsObject

+ (NewsObject *)sharedInstance
{
    static NewsObject *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NewsObject alloc] init];
    });
    return sharedInstance;
}

@end