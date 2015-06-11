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
#import "NewsSNOut.h"
#import "NewsSNIn.h"
#import "CodingUtil.h"
#import "NewsData.h"

#define NEW_DB_SYNTAX   1

static NSString *Empty = @"";
static NSString *Blank = @"  ";
static NSString *dbName = @"NewsContent";

// for internal use class.
@interface NewsMaxSN : NSObject {
@public	
	UInt16 maxSN;
	UInt16 catID;
	UInt16 date;
}
@end

@implementation NewsMaxSN

- (id) init
{
	self = [super init];
	if (self)
	{
		catID = 0;
		date = 0;
		maxSN = 0;
	}
	return self;
}

@end

@implementation NewsContent

@synthesize title;
@synthesize content;

- (NewsContent*) init
{
	self = [super init];
	if (self)
	{
		title = nil;
		content = nil;
		catID = 0;
		date = 0;
		SN = 0;
		type = 0;
	}
	return self;
}

- (void)	setWithTitle: (NSString*) newTitle 
			andCatID: (UInt16) newCatID 
	 		andDate: (UInt16) newDate
			andSN: (UInt16) newSN
			andType: (UInt8) newType
{
	if (title != newTitle)
	{
		title = newTitle;
	}
	catID  = newCatID;
	date   = newDate;
	SN     = newSN;
	type   = newType;
}

- (void)	setContent: (NSString*) newContent
{
	if (content != newContent)
	{
		content = newContent;
	}
}



@end

//////////////////////////////////////////////////////


@implementation NewsData

@synthesize notifyTarget;

- (void) setTarget: (NSObject *) obj
{
	readingNewsSN = 0;
	self.notifyTarget = obj;
	if (dataChanged && notifyTarget != nil)
		[notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
}

- (NewsData*) init
{
	self = [super init];
	if (self)
	{
		newsCountLimit = 200;
		lock = [[NSRecursiveLock alloc] init];
		notifyTarget = nil;
		currCatID = 0;
		dataCacheArray  = [[NSMutableArray alloc] init];
		newsMaxSN = [[NSMutableArray alloc] init];
		isDatabaseValid = NO;
		[self initDatabase];	
		autofetchArray = nil;
	}
	return self;
}

- (void) initDatabase
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS NewsContent (SyncDate INTEGER, Time INTEGER, SectorID INTEGER, sn INTEGER, newsSN INTEGER, Title TEXT, Content TEXT, HadRead INTEGER, Type INTEGER, PRIMARY KEY (newsSN))"];
    }];
}

//- (void) delWithTimeLimit:(NSMutableArray *) array
//{
//	char *  sqliteQuery  = NULL; 
//	int rc;
//	int delDate, delTime, delCatID;
//	
//	delDate = [(NSNumber*)[array objectAtIndex:0] intValue];
//	delTime = [(NSNumber*)[array objectAtIndex:1] intValue];
//	delCatID = [(NSNumber*)[array objectAtIndex:2] intValue];
//		
//	[lock lock];
//	sqlite3 *db  = DBOpen();	
//	sqliteQuery = sqlite3_mprintf("DELETE FROM %s WHERE (SectorID = %d) AND  (SyncDate < %d OR (SyncDate = %d AND Time <= %d))", 
//		[dbName UTF8String], delCatID, delDate, delDate, delTime);
//	rc = [mySQL exec:sqliteQuery withDB:db];
//	sqlite3_free(sqliteQuery);		 
//	DBClose();
//	[lock unlock];
//}

//- (void) packData:(int) delDate andTime:(int) delTime andCatID:(int) catID
//{
//	NSNumber *objDate, *objTime , *objCat;
//	objDate = [[NSNumber alloc]initWithInt:delDate];
//	objTime = [[NSNumber alloc]initWithInt:delTime];
//	objCat = [[NSNumber alloc]initWithInt:catID];
//	NSMutableArray *argArray = [[NSMutableArray alloc]init];
//	[argArray addObject:objDate];
//	[argArray addObject:objTime];
//	[argArray addObject:objCat];
//
//	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//	[dataModal.newsData performSelector:@selector(delWithTimeLimit:) onThread:dataModal.thread withObject:argArray waitUntilDone:NO];
//}

//- (void) packDataWithSectorID:(int) sectorID
//{
//	char *  sqliteQuery  = NULL; 
//	int rc;
//	sqlite3_stmt * stmt;
//	int date = -1, time;
//	
//	sqlite3 *db  = DBOpen();	
//	sqliteQuery = sqlite3_mprintf("SELECT SyncDate, Time  FROM %s where SectorID = %d  ORDER BY SyncDate DESC, Time  DESC LIMIT 1 OFFSET %d",
//								  [dbName UTF8String], sectorID, newsCountLimit);
//	[lock lock];
//	rc = sqlite3_prepare(db, sqliteQuery, -1, &stmt, NULL); 
//	sqlite3_free(sqliteQuery);
//	if(rc != SQLITE_OK) goto OVER;
//	rc = sqlite3_step(stmt);
//	if(rc != SQLITE_ROW) goto OVER;
//	date   = sqlite3_column_int(stmt, 0) ;
//	time   = sqlite3_column_int(stmt, 1) ;
//OVER:
//	sqlite3_finalize(stmt);	
//	DBClose();
//	[lock unlock];
//	if(date != -1)
//	{
//		[self packData:date andTime:time andCatID:sectorID];
//	}
//}

//- (void) getData 
//{
//	char *  sqliteQuery  = NULL;
//	sqlite3_stmt * stmt;
//	int rc;
//	int count = 0;
//		
//	if (!isDatabaseValid) return;
//	
//	[lock lock];
//	sqlite3 *db  = DBOpen();	
//	dataChanged = NO;
//	[dataCacheArray removeAllObjects];
//	sqliteQuery = sqlite3_mprintf("SELECT SyncDate, Time, sn, newsSN, Title, Content, HadRead, Type  FROM %s where SectorID = %d  ORDER BY SyncDate DESC, Time  DESC", 
//			[dbName UTF8String], currCatID);
//	rc = sqlite3_prepare(db, sqliteQuery, -1, &stmt, NULL);
//	sqlite3_free(sqliteQuery);	
//	if (rc != SQLITE_OK) goto DataError;	
//	while ((count < newsCountLimit) && ((rc = sqlite3_step(stmt)) == SQLITE_ROW))
//	{
//		NewsContent * node = [[NewsContent alloc] init];
//		node->date   = sqlite3_column_int(stmt, 0) ;
//		node->time   = sqlite3_column_int(stmt, 1) ;
//		node->SN     = sqlite3_column_int(stmt, 2) ;
//		node->newsSN = sqlite3_column_int(stmt, 3) ;
//		node->title =    [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 4)];
//		node->content =  [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 5)];
//		node->hadRead = sqlite3_column_int(stmt, 6) ;
//		node->type = sqlite3_column_int(stmt, 7) ;
//		node->catID = currCatID;
//		count ++;
//		[dataCacheArray addObject: node];
//	}	
//DataError:	
//	sqlite3_finalize(stmt);	
//	DBClose();
//	[lock unlock];
//}

//- (void) reloadData
//{
//	[self getData] ;
//}

//- (void) requestTitle: (UInt16) catID
//{
//	char *  sqliteQuery     = NULL;
//	sqlite3_stmt * stmt;
//	int rc;
//	UInt16 beginSN, maxSN = 0;
//	NewsMaxSN* item = nil;
//
//	[lock lock];
//	for (item in newsMaxSN)
//	{ 
//		if (catID == item->catID)
//			break;
//	}
//	if (item == nil)
//		goto request;
//	maxSN = item->maxSN;
//	beginSN = 1;
//	sqlite3 *db  = DBOpen();	
//	sqliteQuery = sqlite3_mprintf("SELECT sn FROM %s where SyncDate == %d AND SectorID = %d ORDER BY sn ASC ",
//								  [dbName UTF8String], item->date, catID);
//	rc = sqlite3_prepare(db, sqliteQuery, -1, &stmt, NULL);
//	sqlite3_free(sqliteQuery);	
//	if (rc != SQLITE_OK) goto DataError;	
//	while ((rc = sqlite3_step(stmt)) == SQLITE_ROW)
//	{
//		UInt16 SN  = sqlite3_column_int(stmt, 0);
//		if (SN != beginSN) break;
//		beginSN++;
//	}
//DataError:
//	sqlite3_finalize(stmt);	
//	DBClose();
//request:
//	if (beginSN <= maxSN)
//	{
//		NewsTitleOut *packet = [[NewsTitleOut alloc] initWithSectorID:catID BeginSN:beginSN EndSN:maxSN];	
//		[FSDataModelProc sendData:self WithPacket:packet];
//	}
//	else
//	{	// Nothing to request
//		NewsTitleOut *packet = [[NewsTitleOut alloc] initWithSectorID:catID BeginSN:1 EndSN:1];	
//		[FSDataModelProc sendData:self WithPacket:packet];
//	}
//	[lock unlock];
//}

//- (int) selectCatID: (UInt16) catID
//{
//	if (catID != currCatID || dataChanged)
//	{
//		currCatID = catID;
//		[self getData];
		///////////////////////////////////////////////////////
		// request SN move to CategoryTree.m
		///////////////////////////////////////////////////////
		//DataModalProc *dataModal = [DataModalProc getDataModal];
		//UInt16 rootCatID = [dataModal.category getRootCatID:catID];
		//NewsSNOut *packet = [[NewsSNOut alloc] initWithNewsSectorID:&rootCatID count:1 ];	
		//[DataModalProc sendData:self WithPacket:packet];
		//[packet release];
//	}
//	[self requestTitle:currCatID];
//	return 0;
//}

//- (int) getSectorNotReadCount: (UInt16) catID
//{
//	char *  sqliteQuery     = NULL;
//	sqlite3_stmt * stmt;
//	NewsMaxSN* snItem = nil;
//	int nCount = 0, count, maxSN = 0;
//	
//	[lock lock];
//	sqlite3 *db  = DBOpen();	
//	for (NewsMaxSN* item in newsMaxSN)
//	{ 
//		if (catID == item->catID)
//		{
//			snItem = item;
//			break;
//		}
//	}
//	if (snItem != nil)
//	{
//		maxSN = snItem->maxSN;
//		sqliteQuery = sqlite3_mprintf("SELECT sn FROM %s where SyncDate = %d AND SectorID = %d ORDER BY sn DESC ",
//									  [dbName UTF8String], snItem->date, snItem->catID);
//		int rc = sqlite3_prepare(db, sqliteQuery, -1, &stmt, NULL);
//		sqlite3_free(sqliteQuery);	
//		if (rc == SQLITE_OK && (sqlite3_step(stmt) == SQLITE_ROW))
//		{
//			int SN  = sqlite3_column_int(stmt, 0);
//			if (SN > snItem->maxSN) maxSN = SN;
//		}
//		sqlite3_finalize(stmt);	
//		nCount = maxSN;
//		sqliteQuery = sqlite3_mprintf("SELECT COUNT(*) FROM %s where  SectorID = %d AND HadRead = 0 AND SyncDate < %d ",
//								[dbName UTF8String], catID, snItem->date);
//		count = [mySQL getCount:sqliteQuery withDB:db] ;
//		sqlite3_free(sqliteQuery);
//		if (count > 0)	nCount += count;
//		sqliteQuery = sqlite3_mprintf("SELECT COUNT(*) FROM %s where  SectorID = %d AND HadRead = 1 AND SyncDate = %d ",
//									  [dbName UTF8String], catID, snItem->date);
//		count = [mySQL getCount:sqliteQuery withDB:db] ;
//		sqlite3_free(sqliteQuery);
//		if (count > 0  && count <= maxSN)
//			nCount -= count;
//	}
//	else
//	{
//		sqliteQuery = sqlite3_mprintf("SELECT COUNT(*) FROM %s where  SectorID = %d AND HadRead = 0 ",
//									  [dbName UTF8String], catID);
//		count = [mySQL getCount:sqliteQuery withDB:db] ;
//		sqlite3_free(sqliteQuery);
//		if (count > 0)	nCount += count;
//	}
//	DBClose();
//	[lock unlock];
//	return nCount;
//}	

//- (int) getCount
//{
//	if (dataChanged)
//		[self getData];
//	int count = [dataCacheArray count];
//	return count;
//}

//- (NSString*) getTitleAt:(int)position andDate:(UInt16*)date  andTime:(UInt16*)time andHadRead:(UInt8*)hadRead andNewsSN:(UInt32*)newsSN
//{
//	NSString *str = nil;
//	[lock lock];
//	if (position >= [dataCacheArray count]){
//        [lock unlock];
//        return str;
//    }
//	NewsContent* node = (NewsContent*)[dataCacheArray objectAtIndex:position];
//	*date = node->date;
//	*time = node->time;
//	*hadRead = node->hadRead;
//	*newsSN = node->newsSN;
//	str = [NSString stringWithString:node->title];
//exit:
//	[lock unlock];
//	return str;	
//}

//- (void) setHadRead:(NSNumber*)obj
//{
//	char *  sqliteQuery     = NULL;
//	[lock lock];
//	UInt32 newsSN = (UInt32)[obj longValue];
//	sqlite3 *db  = DBOpen();	
//	sqliteQuery = sqlite3_mprintf("UPDATE %s SET HadRead = 1 where  newsSN = %d ;", [dbName UTF8String] , newsSN);
//	[mySQL exec:sqliteQuery withDB:db];
//	sqlite3_free(sqliteQuery);
//	DBClose();
//	[lock unlock];
//}

//- (NSString*) getContentAt:(int)position andSN:(UInt32)newsSN
//{
//	int rc;
//	NSString *str = nil;
//
//	[lock lock];
//	sqlite3 *db  = DBOpen();	
//	if (position >= [dataCacheArray count]){
//        DBClose();
//        [lock unlock];
//        return str;
//    }
//	NewsContent* node = (NewsContent*)[dataCacheArray objectAtIndex:position];
//	if (node->newsSN != newsSN)
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
//	readingNewsSN = newsSN;
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

//- (void) addWithSNIn:(NewsSNIn *) obj;
//{
//	//[NSThread sleepForTimeInterval:2];
//	[lock lock];
//	for (int i = 0; i < obj->count; i++)
//	{
//		BOOL found = NO;
//		for (NewsMaxSN* item in newsMaxSN)
//		{ 
//			if (obj->sectorID[i] == item->catID)
//			{
//				item->maxSN = obj->SN[i];
//				found = YES;
//				break;
//			}
//		}
//		if (!found)
//		{
//			NewsMaxSN* item = [[NewsMaxSN alloc] init];
//			item->catID = obj->sectorID[i];
//			item->date = [CodingUtil makeDate:obj->year month: obj->month day: obj->day];
//			item->maxSN = obj->SN[i];
//			[newsMaxSN addObject: item];
//		}
//	}
//	if (notifyTarget != nil && currCatID != 0)
////		[self requestTitle:currCatID];
//		
////	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
////	[dataModal.category notifyNewsClient];
//
//	if (obj->retCode == 0 && 0xFFFF == autoFetingCatID) // autofetch next sector;
//	{
//		autoFetingCatID = 0;
////		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
////		[dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
//	}
//
//	[lock unlock];
//}

//- (void) addWithTitle:(NewsTitleIn *) obj
//{
//	//[NSThread sleepForTimeInterval:2];
//	[lock lock];
//	sqlite3 *db  = DBOpen();	
//	NSMutableArray *array = [obj mimeArray];
//	for (NewsContentFormat1 *title in array)
//	{
//		NSString *content = title->contentFlag ? Empty : Blank;
//#if !NEW_DB_SYNTAX
//		int rc;
//		char * sqliteQuery = sqlite3_mprintf("INSERT INTO %s (SectorID, SyncDate, Time, sn, newsSN, Title, Content, HadRead, Type) VALUES ('%d', '%d','%d','%d','%d', '%q', '%q', '0', '%d');", 
//					[dbName UTF8String], obj->sectorID, obj->date, title->time, title->SN, title->newsSN, [title->mimeString UTF8String], [content UTF8String], title->type);
//		rc = [mySQL exec:sqliteQuery withDB:db];
//		sqlite3_free(sqliteQuery);
//#else
//		int success;
//		sqlite3_stmt *statment = NULL;
//		static const char *sql = "INSERT INTO NewsContent (SectorID, SyncDate, Time, sn, newsSN, Title, Content, HadRead, Type) VALUES (?, ?, ?, ?, ?, ?, ?, '0', ?);";
//		sqlite3_prepare_v2(db, sql, -1, &statment, NULL); 
//		sqlite3_bind_int(statment, 1, obj->sectorID);
//		sqlite3_bind_int(statment, 2, obj->date);
//		sqlite3_bind_int(statment, 3, title->time);
//		sqlite3_bind_int(statment, 4, title->SN);
//		sqlite3_bind_int(statment, 5, title->newsSN);
//		sqlite3_bind_text(statment, 6, [title->mimeString UTF8String], -1, SQLITE_TRANSIENT);
//		sqlite3_bind_text(statment, 7, [content UTF8String], -1, SQLITE_TRANSIENT);
//		sqlite3_bind_int(statment, 8, title->type);
//		success = sqlite3_step(statment);
//		sqlite3_finalize(statment);
//#endif 		
//	}
//	if (obj->sectorID == currCatID)
//		dataChanged = YES;
//	DBClose();
//	[lock unlock];
//	if (obj->retCode == 0)
//	{
//		[self packDataWithSectorID:currCatID];
//		if (notifyTarget != nil && obj->sectorID == currCatID && readingNewsSN == 0)
//			[notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
//	}
//	if (obj->retCode == 0 && obj->sectorID == autoFetingCatID) // autofetch next sector;
//	{
//		autoFetingCatID = 0;
//		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
////		[dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
//	}
//	[array removeAllObjects];
//}

//- (void) addWithRealTimeTitle:(NewsContentFormat3 *) title;
//{
//	BOOL Exist = NO;
//	char *  sqliteQuery     = NULL;	
//	sqlite3_stmt * stmt;
//	int rc;	
//	UInt8 Type;
//	
//	[lock lock];
//	sqlite3 *db  = DBOpen();	
//	sqliteQuery = sqlite3_mprintf("SELECT Type FROM %s WHERE newsSN = %d ;", [dbName UTF8String], title->newsSN);
//	rc = sqlite3_prepare(db, sqliteQuery, -1, &stmt, NULL);
//	sqlite3_free(sqliteQuery);	
//	if (rc == SQLITE_OK && sqlite3_step(stmt) == SQLITE_ROW)
//	{
//		Type = sqlite3_column_int(stmt, 0);
//		Exist = YES;
//	}
//	sqlite3_finalize(stmt);
//	if (Exist && Type == 1)  // Fixed numbet news;
//	{
//		NSString *content = title->contentFlag ? Empty : Blank;
//#if !NEW_DB_SYNTAX
//		sqliteQuery = sqlite3_mprintf("UPDATE %s SET Time = '%d', Content = '%q', HadRead = 0 WHERE newsSN = %d ;",
//				  [dbName UTF8String], title->time, [content UTF8String], title->newsSN);
//		rc = [mySQL exec:sqliteQuery withDB:db];
//		sqlite3_free(sqliteQuery);
//#else
//		int success;
//		sqlite3_stmt *statment = NULL;
//		static const char *sql = "UPDATE NewsContent SET Time = ?, Content = ?, HadRead = 0 WHERE newsSN = ? ;";
//		sqlite3_prepare_v2(db, sql, -1, &statment, NULL); 
//		sqlite3_bind_int(statment, 1, title->time);
//		sqlite3_bind_text(statment, 2, [content UTF8String], -1, SQLITE_TRANSIENT);
//		sqlite3_bind_int(statment, 3, title->newsSN);
//		success = sqlite3_step(statment);
//		sqlite3_finalize(statment);
//#endif
//		if (title->sectorID == currCatID)
//			dataChanged = YES;
//	}
//	if (!Exist)
//	{
//		NSString *content = title->contentFlag ? Empty : Blank;
//#if !NEW_DB_SYNTAX
//		sqliteQuery = sqlite3_mprintf("INSERT INTO %s (SectorID, SyncDate, Time, sn, newsSN, Title, Content, HadRead, Type) VALUES ('%d', '%d','%d','%d','%d', '%q', '%q', '0', '%d');", 
//					  [dbName UTF8String], title->sectorID, title->date, title->time, title->SN, title->newsSN, [title->mimeString UTF8String], [content UTF8String], title->type);
//		rc = [mySQL exec:sqliteQuery withDB:db];
//		sqlite3_free(sqliteQuery);
//#else
//		int success;
//		sqlite3_stmt *statment = NULL;
//		static const char *sql = "INSERT INTO NewsContent (SectorID, SyncDate, Time, sn, newsSN, Title, Content, HadRead, Type) VALUES (?, ?, ?, ?, ?, ?, ?, '0', ?);";
//		sqlite3_prepare_v2(db, sql, -1, &statment, NULL); 
//		sqlite3_bind_int(statment, 1, title->sectorID);
//		sqlite3_bind_int(statment, 2, title->date);
//		sqlite3_bind_int(statment, 3, title->time);
//		sqlite3_bind_int(statment, 4, title->SN);
//		sqlite3_bind_int(statment, 5, title->newsSN);
//		sqlite3_bind_text(statment, 6, [title->mimeString UTF8String], -1, SQLITE_TRANSIENT);
//		sqlite3_bind_text(statment, 7, [content UTF8String], -1, SQLITE_TRANSIENT);
//		sqlite3_bind_int(statment, 8, title->type);
//		success = sqlite3_step(statment);
//		sqlite3_finalize(statment);
//#endif
//		if (title->sectorID == currCatID)
//			dataChanged = YES;
//	}
//	DBClose();
//	if (!Exist)
//		[self packDataWithSectorID:currCatID];
//	if (notifyTarget != nil && title->sectorID == currCatID && readingNewsSN == 0)
//	{
//		[notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
//	}
//	[lock unlock];
//}

- (void) addWithContent_easy:(NewsContentIn *) obj
{
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
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"UPDATE NewsContent SET Content = ?, HadRead = 0 WHERE newsSN = ?", mimeString, [NSNumber numberWithInt:obj->newsSN]];
        
    }];
	for (NewsContent * node in dataCacheArray)
	{
		if (node->newsSN == obj->newsSN)
		{
			if (node->content != nil) 
			node->content = [[NSString alloc] initWithString:mimeString];
		}
	}
//	[lock unlock];
	
	if (obj->retCode == 0 && notifyTarget != nil && readingNewsSN == obj->newsSN)
	{
		//[self reloadData];
		[notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
	}	
	if (obj->retCode == 0 && autoFetingNewsSN == obj->newsSN)
	{
		autoFetingNewsSN = 0;
//		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//		[dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
	}
	
	// Update related news data.
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.relatedNewsData addWithContent: obj];

	[array removeAllObjects];
}


static UInt16 df_mineLen = 0;
static UInt8 *df_mimeData = NULL;
static UInt32 df_newsSN = 0;

- (void) addWithContent:(NewsContentIn *) obj
{
//	[NSThread sleepForTimeInterval:2];
//    if ([notifyTarget isKindOfClass:[FSNewsDataModel class]]){
//        [notifyTarget performSelectorOnMainThread:@selector(notify:) withObject:obj waitUntilDone: NO];
//    }else{
        NSMutableArray *array = obj->mimeArray;
        if ([array count] == 0)  // No content
        {
            if ([notifyTarget isKindOfClass:[FSNewsDataModel class]]){
                [notifyTarget performSelectorOnMainThread:@selector(notify:) withObject:obj waitUntilDone: NO];
            }else{
                [self addWithContent_easy: obj];
            }
            return;
        }

        NewsContentFormat2 *content = [array objectAtIndex:0];
        if (df_newsSN == obj->newsSN)
        {
            df_mimeData = realloc(df_mimeData, df_mineLen+content->length);
            if (df_mimeData)
            {
                memcpy(df_mimeData+df_mineLen, content->mimeData, content->length);
                df_mineLen += content->length;
                if (obj->retCode == 0)
                {
                    content->mimeString = [[NSString alloc] initWithBytes:df_mimeData length:df_mineLen encoding:NSUTF8StringEncoding];
                    if ([notifyTarget isKindOfClass:[FSNewsDataModel class]]){
                        [notifyTarget performSelectorOnMainThread:@selector(notify:) withObject:obj waitUntilDone: NO];
                    }else{
                        [self addWithContent_easy: obj];
                    }
                    free(df_mimeData);
                    df_mimeData = NULL;
                    df_newsSN = 0;
                    df_mineLen = 0;
                }
            }
            else
            {
                df_newsSN = 0;
                df_mineLen = 0;
            }
        }
        else
        {
            df_newsSN = 0;
            df_mineLen = 0;
            if (df_mimeData != NULL)
            {
                free(df_mimeData);
                df_mimeData = 0;
            }
            if (obj->retCode != 0)
            {
                df_mimeData = malloc(content->length);
                if (df_mimeData)
                {
                    memcpy(df_mimeData, content->mimeData, content->length);
                    df_mineLen = content->length;
                    df_newsSN = obj->newsSN;
                }
            }
            else
            {
                UInt16 mimeLength = content->length;
                UInt8 *mimeData = content->mimeData; 
                content->mimeString = [[NSString alloc] initWithBytes:mimeData length:mimeLength encoding:NSUTF8StringEncoding];
                if ([notifyTarget isKindOfClass:[FSNewsDataModel class]]){
                    [notifyTarget performSelectorOnMainThread:@selector(notify:) withObject:obj waitUntilDone: NO];
                }else{

                    [self addWithContent_easy: obj];
            }
        }
    }
}

- (int) progress
{
	if (totalToFetch == 0)
		return 100;
	return fetching * 100 / totalToFetch;
}

//- (int) autofetch
//{
//	char *  sqliteQuery     = NULL;
//	sqlite3_stmt * stmt;
//	int rc = 0;
//
//	autoFetingNewsSN = 0;
//	autoFetingCatID = 0;
//	if (autofetchArray == nil)
//	{
//		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//		autofetchArray = [dataModal.category getAllNewsLeafCategories];
//		if (autofetchArray == nil)  // some error.
//			return -1;
//		totalToFetch = [autofetchArray count] * 2;
//		fetching = 0;
//		NSMutableArray *rootArray = [dataModal.category getAllNewsRootCategories];
//		int rootCount = [rootArray count];
//		UInt16 *roots = malloc(sizeof(UInt16)*rootCount);
//		for (int i = 0; i < rootCount; i++)
//			roots[i] = [((NSNumber *) [rootArray objectAtIndex:i]) intValue];
//		NewsSNOut *packet = [[NewsSNOut alloc] initWithNewsSectorID:roots count:rootCount];	
//		[FSDataModelProc sendData:self WithPacket:packet];
//		free(roots);
//		autoFetingCatID = 0xFFFF;
//		return 1;  // continue
//	}
//	if ([autofetchArray count] > 0)  // not finished.
//	{
//		UInt16 nCatID = [((NSNumber *) [autofetchArray objectAtIndex:0]) intValue];
//		[self requestTitle: nCatID];
//		NSLog(@"AutoFetch News Title at sector %d. ", nCatID);
//		autoFetingCatID = nCatID;
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
//	do {
//		UInt32 newsSN = 0;
//		[lock lock];
//		sqlite3 *db  = DBOpen();	
//		sqliteQuery = sqlite3_mprintf("SELECT newsSN FROM %s where Content = '' AND HadRead = 0;", [dbName UTF8String]);
//		rc = sqlite3_prepare(db, sqliteQuery, -1, &stmt, NULL);
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
//			NSLog(@"AutoFetch News newsSN %lu. ", newsSN);
//			autoFetingNewsSN = newsSN;
//			return 1;
//		}
//	} while (0);
//	autofetchArray = nil;
//	autoFetingCatID = 0;
//	return 0;
//}

@end
