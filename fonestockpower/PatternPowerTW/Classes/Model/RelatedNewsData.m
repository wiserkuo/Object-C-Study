//
//  NewsData.m
//  Bullseye
//
//  Created by steven on 2008/12/4.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NewsTitleOut.h"
#import "OutPacket.h"
#import "NewsContentOut.h"
#import "NewsContentIn.h"
#import "NewsRelateOut.h"
#import "NewsRelateIn.h"
#import "CodingUtil.h"
#import "RelatedNewsData.h"
#import "Portfolio.h"
#import "NewsData.h"
#import "FMDB.h"

#define NEW_DB_SYNTAX  1

@interface RelatedNewsDate : NSObject {
//	sqlite3 *db;
	BOOL isDatabaseValid;
	NSString *identCodeSymbol;
	UInt32 relatedID;
	UInt16 syncDate;
}

- (id) initWithName: (NSString*) identCodeSymbol;
- (UInt32) getRelatedID;
- (UInt16) getSyncDate;
- (int) updateSyncDate: (UInt16) syncDate;

@end

static NSString *NewsDateTableName = @"RelatedfNewsDate";

@implementation RelatedNewsDate

- (void) initDatabase
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS RelatedfNewsDate (IdentCodeSymbol TEXT, SyncDate INTEGER, RelatedID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)"];
    }];
}

- (void) getDate
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block BOOL hasData = NO;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT SyncDate, RelatedID FROM RelatedfNewsDate WHERE IdentCodeSymbol = ?", identCodeSymbol];
        while ([message next]) {
            syncDate = [message intForColumn:@"SyncDate"];
            relatedID = [message intForColumn:@"RelatedID"];
            hasData = YES;
        }
        [message close];
        if (!hasData) {
            [db executeUpdate:@"INSERT INTO RelatedfNewsDate (IdentCodeSymbol, SyncDate) VALUES (?, ?)", identCodeSymbol, [NSNumber numberWithInt:syncDate]];
        }
    }];
}

- (id) initWithName: (NSString*) name
{
	self = [super init];
	if (self)
	{
		identCodeSymbol = [[NSString alloc] initWithString:name];
		relatedID = 0;
		syncDate = [CodingUtil makeDate:1960 month:1 day:1];
		isDatabaseValid = NO;
		[self initDatabase];
		[self getDate];
	}
	return self;
}

- (UInt32) getRelatedID
{
	return relatedID;
}

- (UInt16) getSyncDate
{
	return syncDate;
}

- (int) updateSyncDate: (UInt16) date;
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE RelatedfNewsDate SET SyncDate = ? WHERE relatedID = ?", [NSNumber numberWithInt:syncDate], [NSNumber numberWithInt:relatedID]];
    }];
	return 0;
}

@end


static NSString *Empty = @"";
static NSString *Blank = @"  ";
static NSString *dbName = @"RelatedfNewsContent";

@implementation RelatedNewsContent

@synthesize title;
@synthesize content;

- (id) init
{
	self = [super init];
	if (self)
	{
		related = 0;
		title = nil;
		content = nil;
		date = 0;
		type = 0;
	}
	return self;
}

- (void) setWithTitle: (NSString*) newTitle
			andRelated: (UInt32) newRelated 
	 		andDate: (UInt16) newDate
			andType: (UInt8) newType
{
	if (title != newTitle)
	{
		title = newTitle;
	}
	related  = newRelated;
	date   = newDate;
	type   = newType;
}

- (void) setContent: (NSString*) newContent
{
	if (content != newContent)
	{
		content = newContent;
	}
}


@end

////////////////////////////////////////////////////////


@implementation RelatedNewsData

@synthesize notifyTarget;
@synthesize tmpNewsContent;

- (void) setTarget: (NSObject *) obj
{
	self.notifyTarget = obj;
}

- (id) init
{
	self = [super init];
	if (self)
	{
		newsCountLimit = 30;
		lock = [[NSRecursiveLock alloc] init];
		notifyTarget = nil;
		identCodeSymbol = nil;
		dataCacheArray  = [[NSMutableArray alloc] init];
		isDatabaseValid = NO;
		[self initDatabase];	

	}
	return self;
}

- (void) initDatabase
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS RelatedfNewsContent (Date INTEGER, Time INTEGER, RelatedID INTEGER, newsSN INTEGER, Title TEXT, Content TEXT, HadRead INTEGER, Type INTEGER, PRIMARY KEY (RelatedID, newsSN))"];
    }];
}

- (void) getData
{
    [dataCacheArray removeAllObjects];
    __block int count = 0;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT Date, Time, newsSN, Title, Content, HadRead, Type  FROM RelatedfNewsContent WHERE RelatedID = ?  ORDER BY Date DESC, Time DESC", [NSNumber numberWithInt:relatedID]];
        while ([message next]) {
            if ((count <= newsCountLimit)) {
                NewsContent * node = [[NewsContent alloc] init];
                node->date   = [message intForColumn:@"Date"];
                node->time   = [message intForColumn:@"Time"];
                node->newsSN = [message intForColumn:@"newsSN"];
                node->title  = [message stringForColumn:@"Title"];
                node->content = [message stringForColumn:@"Content"];
                node->hadRead = [message intForColumn:@"HadRead"];
                node->type = [message intForColumn:@"Type"];
                node->catID = relatedID;
                count ++;
                [dataCacheArray addObject: node];
            }
        }
        [message close];
    }];
}

//- (void) reloadData
//{
//	[self getData] ;
//}

- (int) selectRelated: (NSString*) name;
{
	UInt32 newRelatedID;
	UInt16 startDate, endDate;

	identCodeSymbol = [[NSString alloc] initWithString:name];
	RelatedNewsDate *newsDate = [[RelatedNewsDate alloc] initWithName: identCodeSymbol];
	newRelatedID = [newsDate getRelatedID];
    startDate = [CodingUtil makeDate:2014 month:1 day:1];
    endDate = [[NSDate date] uint16Value];
//	startDate = [newsDate getSyncDate];
//	endDate = [CodingUtil makeDate:1960+127 month:12 day:31];
	//if (newRelatedID != relatedID)
	{
		relatedID = newRelatedID;
		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
		PortfolioItem *item = [dataModal.portfolioData findItemByIdentCodeSymbol: identCodeSymbol];
		if(item)
		{
			commodityNo = item->commodityNo;
			// Get commoditySN form identCodeSymbol
            if (commodityNo != 0) {
                NewsRelateOut *packet = [[NewsRelateOut alloc] initWithSecuritySN:commodityNo StarDate:startDate EndDate:endDate CountPage:newsCountLimit PageNo:1];
                [FSDataModelProc sendData:self WithPacket:packet];
            }
		}
	}
	return 0;
}

- (int) getCount
{
	[self getData];
	int count = (int)[dataCacheArray count];
	return count;
}

- (NSString*) getTitleAt:(int)position andDate:(UInt16*)date  andTime:(UInt16*)time andHadRead:(UInt8*)hadRead andNewsSN:(UInt32*)newsSN
{
	NSString *str = nil;
	[lock lock];
	if (position >= [dataCacheArray count]) {
        [lock unlock];
        return str;
    }else{
        NewsContent* node = (NewsContent*)[dataCacheArray objectAtIndex:position];
        *date = node->date;
        *time = node->time;
        *hadRead = node->hadRead;
        *newsSN = node->newsSN;
        str = [NSString stringWithString:node->title];
        [lock unlock];
        return str;
    }
}

- (void) setHadRead:(NSNumber*)obj
{
    UInt32 newsSN = (UInt32)[obj longValue];

    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE RelatedfNewsContent SET HadRead = 1 WHERE newsSN = ?", [NSNumber numberWithInt:newsSN]];
    }];
}

- (NSString*) getContentAt:(int)position andSN:(UInt32)newsSN
{
    __block NSString *str = nil;
    [lock lock];
    if (position >= [dataCacheArray count]){
        [lock unlock];
        return str;
    }
    NewsContent* node = (NewsContent*)[dataCacheArray objectAtIndex:position];
	if (node->newsSN != newsSN){
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        FSDatabaseAgent *dbAgent = dataModel.mainDB;
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
           FMResultSet *message = [db executeQuery:@"SELECT Content FROM RelatedfNewsContent where newsSN = ?", [NSNumber numberWithInt:newsSN]];
            while ([message next]) {
                str = [message stringForColumn:@"Content"];
            }
        }];
    }
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    NSNumber *obj = [[NSNumber alloc] initWithLong:newsSN];
    [self performSelector:@selector(setHadRead:) onThread:dataModal.thread withObject:obj waitUntilDone:NO];
	if ([node->content isEqualToString:@"0"])
	{
		// send request here.
		NewsContentOut *packet = [[NewsContentOut alloc] initWithType0SN:newsSN];
		[FSDataModelProc sendData:self WithPacket:packet];
	}
	else
	{
		if (node->hadRead == 0)
		{
			node->hadRead = 1;
			FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
			NSNumber *obj = [[NSNumber alloc] initWithLong:node->newsSN];
			[self performSelector:@selector(setHadRead:) onThread:dataModal.thread withObject:obj waitUntilDone:NO];
		}
		str = [NSString stringWithString:node->content];
	}
	return str;
}

//- (int) getIndexByNewsSN:(int)newsSN {
//	
//	NewsContent* node;
//	int position =-1;
//	for(NewsContent *tmpNode in dataCacheArray){
//		
//		position++;
//		
//		if((tmpNode->newsSN) == newsSN){
//			
//			node = tmpNode;
//			break;
//			
//		}
//		
//	}
//	
//	return position;
//
//}
//
//- (NSString*) getTitleByNewsSN:(UInt32)newsSN {
//	
//	int rc;
//	NSString *str = nil;
//	
//	[lock lock];
//	sqlite3 *db = DBOpen();	
// 	
//	
//	NewsContent* node;
//	int position =-1;
//	for(NewsContent *tmpNode in dataCacheArray){
//		
//		position++;
//		
//		if((tmpNode->newsSN) == newsSN){
//			
//			node = tmpNode;
//			break;
//			
//		}
//		
//	}
//	
//	if (position==-1)
//	{
//		char *  sqliteQuery     = NULL;
//		sqlite3_stmt * stmt;
//		
//		sqliteQuery = sqlite3_mprintf("SELECT Title FROM %s where newsSN = %d ;", [dbName UTF8String], newsSN);
//		rc = sqlite3_prepare(db, sqliteQuery, -1, &stmt, NULL);
//		sqlite3_free(sqliteQuery);	
//		if (rc != SQLITE_OK) goto exit;	
//		if ((rc = sqlite3_step(stmt)) == SQLITE_ROW)
//			str = [NSString stringWithUTF8String: (char *) sqlite3_column_text(stmt, 0)];
//		sqlite3_finalize(stmt);
//		
//		goto exit;
//	}
//	if ([node->title length] == 0)
//	{
//		// send request here.
//		NewsContentOut *packet = [[NewsContentOut alloc] initWithType0SN:newsSN];
//		[FSDataModelProc sendData:self WithPacket:packet];
//	}
//	else
//	{
//		str = [NSString stringWithString:node->title];
//	}
//exit:
//	DBClose();
//	[lock unlock];
//	return str;
//
//
//}
//
//- (NSString*) getContentByNewsSN:(UInt32)newsSN
//{
//	int rc;
//	NSString *str = nil;
//	
//	[lock lock];
//	sqlite3 *db = DBOpen();	
//    	
//	NewsContent* node;
//	int position =-1;
//	for(NewsContent *tmpNode in dataCacheArray){
//		
//		position++;
//		
//		if((tmpNode->newsSN) == newsSN){
//			
//			node = tmpNode;
//			break;
//		
//		}
//	
//	}
//	
//	if (position==-1)
//	{
//		char *  sqliteQuery     = NULL;
//		sqlite3_stmt * stmt;
//		
//		sqliteQuery = sqlite3_mprintf("SELECT Content FROM %s where newsSN = %d ;", [dbName UTF8String], newsSN);
//		rc = sqlite3_prepare(db, sqliteQuery, -1, &stmt, NULL);
//		sqlite3_free(sqliteQuery);	
//		if (rc != SQLITE_OK) goto exit;	
//		if ((rc = sqlite3_step(stmt)) == SQLITE_ROW)
//			str = [NSString stringWithUTF8String: (char *) sqlite3_column_text(stmt, 0)];
//		sqlite3_finalize(stmt);
//		
//		//sqliteQuery = sqlite3_mprintf("UPDATE %s SET HadRead = 1 where  newsSN = %d ;", [dbName UTF8String] , newsSN);
//		//[mySQL exec:sqliteQuery withDB:db];
//		//sqlite3_free(sqliteQuery);
//		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//		NSNumber *obj = [[NSNumber alloc] initWithLong:newsSN];
//		[self performSelector:@selector(setHadRead:) onThread:dataModal.thread withObject:obj waitUntilDone:NO];
//		
//		goto exit;
//	}
//	if ([node->content length] == 0)
//	{
//		// send request here.
//		NewsContentOut *packet = [[NewsContentOut alloc] initWithType0SN:newsSN];
//		[FSDataModelProc sendData:self WithPacket:packet];
//	}
//	else
//	{
//		if (node->hadRead == 0)
//		{
//			node->hadRead = 1;
//			//char *  sqliteQuery     = NULL;
//			//sqliteQuery = sqlite3_mprintf("UPDATE %s SET HadRead = 1 where  newsSN = %d ;", [dbName UTF8String] , node->newsSN);
//			//[mySQL exec:sqliteQuery withDB:db];
//			//sqlite3_free(sqliteQuery);
//			FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//			NSNumber *obj = [[NSNumber alloc] initWithLong:node->newsSN];
//			[self performSelector:@selector(setHadRead:) onThread:dataModal.thread withObject:obj waitUntilDone:NO];
//		}
//		str = [NSString stringWithString:node->content];
//	}
//exit:
//	DBClose();
//	[lock unlock];
//	return str;
//}

- (void) delWithTimeLimit:(NSMutableArray *) array
{
    int delDate, delTime, delRelatedID;
    
    delDate = [(NSNumber*)[array objectAtIndex:0] intValue];
	delTime = [(NSNumber*)[array objectAtIndex:1] intValue];
	delRelatedID = [(NSNumber*)[array objectAtIndex:2] intValue];

    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM RelatedfNewsContent WHERE (RelatedID = ?) AND (Date < ? OR (Date = ? AND Time <= ?))", [NSNumber numberWithInt:delRelatedID], [NSNumber numberWithInt:delDate], [NSNumber numberWithInt:delDate], [NSNumber numberWithInt:delTime]];
    }];
}

- (void) packData:(int) delDate andTime:(int) delTime andRelatedID:(int) delRelatedID
{
	NSNumber *objDate, *objTime , *objRelated;
	objDate = [[NSNumber alloc]initWithInt:delDate];
	objTime = [[NSNumber alloc]initWithInt:delTime];
	objRelated = [[NSNumber alloc]initWithInt:delRelatedID];
	NSMutableArray *argArray = [[NSMutableArray alloc]init];
	[argArray addObject:objDate];
	[argArray addObject:objTime];
	[argArray addObject:objRelated];
    
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.relatedNewsData performSelector:@selector(delWithTimeLimit:) onThread:dataModal.thread withObject:argArray waitUntilDone:NO];
}

- (void) packDataWithRelatedID:(int) inRelatedID{
    __block int date = -1, time;
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT Date, Time  FROM RelatedfNewsContent where RelatedID = ? ORDER BY Date DESC, Time  DESC LIMIT 1 OFFSET ?", [NSNumber numberWithInt:inRelatedID], [NSNumber numberWithInt:newsCountLimit]];
        while ([message next]) {
            date = [message intForColumn:@"Date"];
            time = [message intForColumn:@"Time"];
        }

    }];
	if (date != -1){
		[self packData:date andTime:time andRelatedID:inRelatedID];
	}
}

- (void) addWithTitle:(NewsRelateIn *) obj
{
	UInt32 inRelatedID = relatedID;
	NSString *inIdentCodeSymbol;
	UInt16 latestDate = [CodingUtil makeDate:1960 month:1 day:1];
    if (commodityNo != obj->commodityNo) {
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        PortfolioItem *item = [dataModal.portfolioData findInPortfolio: obj->commodityNo];
        inIdentCodeSymbol = [NSString stringWithFormat:@"%s%@", item->identCode, item->symbol];
		RelatedNewsDate *newsDate = [[RelatedNewsDate alloc] initWithName: inIdentCodeSymbol];
		inRelatedID = [newsDate getRelatedID];
    }else{
        inIdentCodeSymbol = identCodeSymbol;
		inRelatedID = relatedID;
    }
    NSMutableArray *array = [obj mimeArray];
    for (NewsContentFormat3 *title in array) {
        NSString *content = title->contentFlag ? Empty : Blank;
        __block int count = 0;
        
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        FSDatabaseAgent *dbAgent = dataModel.mainDB;
        [ dbAgent inDatabase:^(FMDatabase *db) {
            FMResultSet *message = [db executeQuery:@"SELECT COUNT(*) FROM RelatedfNewsContent WHERE RelatedID = ? AND newsSN = ?", [NSNumber numberWithInt:inRelatedID], [NSNumber numberWithInt:title->newsSN]];
            while ([message next]) {
                count = [message intForColumn:@"COUNT(*)"];
            }
            if (count == 0) {
                [db executeUpdate:@"INSERT INTO RelatedfNewsContent (RelatedID, Date, Time, newsSN, Title, Content, HadRead, Type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", [NSNumber numberWithInt:inRelatedID], [NSNumber numberWithInt:title->date], [NSNumber numberWithInt:title->time], [NSNumber numberWithInt:title->newsSN], title->mimeString, [NSNumber numberWithInt:0], content, [NSNumber numberWithInt:title->type]];

            }
        }];
        if (latestDate < title->date) latestDate = title->date;
    }
	{ // Update syncDate
		RelatedNewsDate *newsDate = [[RelatedNewsDate alloc] initWithName: inIdentCodeSymbol];
		UInt16 prevDate = [newsDate getSyncDate];
		if (prevDate < latestDate)
			[newsDate updateSyncDate: latestDate];
	}

	if (obj->retCode == 0)
	{
		[self packDataWithRelatedID:inRelatedID];
		if (notifyTarget != nil  && inRelatedID == relatedID)
			[notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
	}
	if (obj->retCode == 0 && obj->commodityNo == autoFetingCommodityNo) // autofetch next sector;
	{
		autoFetingCommodityNo = 0;
//		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//		[dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
	}
	[array removeAllObjects];
}

- (void) addWithContent:(NewsContentIn *) obj
{
    
    if ([notifyTarget isKindOfClass:[FSNewsDataModel class]]){
        
        [notifyTarget performSelectorOnMainThread:@selector(notify:) withObject: obj waitUntilDone: NO];
    }else{
        __block NSString *mimeString = nil;
        NSMutableArray *array = obj->mimeArray;
        if ([array count] > 0){
            NewsContentFormat2 *content = [array objectAtIndex:0];
            mimeString = content->mimeString;
            if (mimeString == nil)	mimeString = @"  ";
        }
        else{
            mimeString = @"  ";
        }
        if(!seeTmpNews){ //非看暫存的新聞content回傳
            FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
            FSDatabaseAgent *dbAgent = dataModel.mainDB;
            [ dbAgent inDatabase:^(FMDatabase *db) {
                [db executeUpdate:@"UPDATE RelatedfNewsContent SET Content = ?, HadRead = 0 WHERE newsSN = ?", mimeString, [NSNumber numberWithInt:obj->newsSN]];
            }];
            for (NewsContent * node in dataCacheArray)
            {
                if (node->newsSN == obj->newsSN)
                {
                    if (node->content != nil)
                        node->content = [[NSString alloc] initWithString:mimeString];
                }
            }
        }else{
                // set 暫存的新聞 content
                tmpNewsContent = [[NSString alloc] initWithString:mimeString];
        }
        
        if (obj->retCode == 0 && notifyTarget != nil)
        {
            //[self reloadData];

            [notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
        }
        //	if (obj->retCode == 0 && autoFetingNewsSN == obj->newsSN)
    //	{
    //		autoFetingNewsSN = 0;
    //		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    //		[dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
    //	}
        
        [array removeAllObjects];
    }
}

#pragma mark -
#pragma mark for see tmp news content

//- (void) setSeeTmpNews:(BOOL)bValue{
//	
//	seeTmpNews = bValue;
//	
//}
//
//
//- (NSString *)getTmpNewsContent {
//	
//	return tmpNewsContent;
//
//}
//
//- (void) selectRelated: (NSString*)idSymbol startDate:(UInt16)startDate endDate:(UInt16)endDate {
//	
//	//UInt16 startDate, endDate;
//	//startDate = [CodingUtil makeDate:2009 month:10 day:30];
//	//endDate = [CodingUtil makeDate:2009 month:10 day:30];
//	
//	UInt32 commodityNumber;
//	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//	PortfolioItem *item = [dataModal.portfolioData findItemByIdentCodeSymbol: idSymbol];
//	if(item)
//	{
//		commodityNumber = item->commodityNo;
//		//UInt16 endDatee = [CodingUtil makeDate:1960+127 month:12 day:31];
//		NewsRelateOut *packet = [[NewsRelateOut alloc] initWithSecuritySN:commodityNumber StarDate:startDate EndDate:startDate CountPage:1 PageNo:1];	
//		[FSDataModelProc sendData:self WithPacket:packet];
//	}
//}
//
//- (void) requestContentFromServerByNewsSN:(UInt32)newsSN {
//	
//	NewsContentOut *packet = [[NewsContentOut alloc] initWithType0SN:newsSN];
//	[FSDataModelProc sendData:self WithPacket:packet];
//	
//}
//
//- (int) progress
//{
//	if (totalToFetch == 0)
//		return 100;
//	return fetching * 100 / totalToFetch;
//}

//- (int) autofetch
//{
//	char *  sqliteQuery     = NULL;
//	sqlite3_stmt * stmt;
//
//	autoFetingNewsSN = 0;
//	autoFetingCommodityNo = 0;
//	if (autofetchArray == nil)
//	{
//		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
////		autofetchArray = [dataModal.portfolioData getAllIdentCodeSymbol];
////		totalToFetch = [autofetchArray count] * 2;
//		fetching = 0;
//	}
//	if ([autofetchArray count] > 0)
//	{
//		NSString *identSymbol = [autofetchArray objectAtIndex:0];
//		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//		PortfolioItem *item = [dataModal.portfolioData findItemByIdentCodeSymbol: identSymbol];
//		NSLog(@"AutoFetch RelativeNews Title for %@ %d ", identSymbol, item->commodityNo);
//		if (item->commodityNo == 0)
//			return 0;
//		RelatedNewsDate *newsDate = [[RelatedNewsDate alloc] initWithName: identSymbol];
//		UInt16 startDate = [newsDate getSyncDate];
//		UInt16 endDate = [CodingUtil makeDate:1960+127 month:12 day:31];
//		NewsRelateOut *packet = [[NewsRelateOut alloc] initWithSecuritySN:item->commodityNo StarDate:startDate EndDate:endDate CountPage:newsCountLimit PageNo:1];	
//		[FSDataModelProc sendData:self WithPacket:packet];
//
//		autoFetingCommodityNo = item->commodityNo;
//		[autofetchArray removeObjectAtIndex:0];
//		fetching++;
//		if ([autofetchArray count] == 0)
//		{
//			sqlite3 *db  = DBOpen();	
//			sqliteQuery = sqlite3_mprintf("SELECT COUNT(*) FROM %s where Content = '' AND HadRead = 0;", [dbName UTF8String]);
//			totalToFetch = [mySQL getCount:sqliteQuery withDB:db] * 2;
//			sqlite3_free(sqliteQuery);
//			DBClose();
//			fetching = totalToFetch / 2;
//		}
//		return 1;
//	}
//	do 
//	{
//		UInt32 newsSN = 0;
//		[lock lock];
//		sqlite3 *db  = DBOpen();	
//		sqliteQuery = sqlite3_mprintf("SELECT newsSN FROM %s where Content = '' AND HadRead = 0;", [dbName UTF8String]);
//		int rc = sqlite3_prepare(db, sqliteQuery, -1, &stmt, NULL);
//		sqlite3_free(sqliteQuery);	
//		if (rc != SQLITE_OK) break;	
//		if ((rc = sqlite3_step(stmt)) == SQLITE_ROW)
//			newsSN = sqlite3_column_int(stmt, 0);
//		sqlite3_finalize(stmt);
//		DBClose();
//		[lock unlock];
//		fetching++;
//		if (newsSN)
//		{
//			NewsContentOut *packet = [[NewsContentOut alloc] initWithType0SN:newsSN];
//			[FSDataModelProc sendData:self WithPacket:packet];
//			NSLog(@"AutoFetch News newsSN %d. ", newsSN);
//			autoFetingNewsSN = newsSN;
//			return 1;
//		}
//	} while (0);
//	autofetchArray = nil;
//	autoFetingCommodityNo = 0;
//	return 0;
//}

@end
