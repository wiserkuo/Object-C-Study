//
//  EsmTraderInfo.m
//  Bullseye
//
//  Created by steven on 2009/6/19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EsmTraderInfo.h"
#import "EsmTraderSyncOut.h"

#define SYNCDATE_ESMTRADER     4

@implementation EsmTraderInfo

- (void) setTarget: (NSObject <EsmTraderNotifyProtocol>*) obj
{
	notifyTarget = obj;
}

- (EsmTraderInfo*) init
{
	self = [super init];
	if (self)
	{
		lock = [[NSRecursiveLock alloc] init];
		notifyTarget = nil;
		[self initDatabase];	
		dataCacheArray  = [[NSMutableArray alloc] init];
		[self reloadData];
	}
	return self;
}

- (void) dealloc
{
	[dataCacheArray removeAllObjects];
}

- (void) initDatabase
{
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS esmTraderName (TraderID INTEGER PRIMARY KEY  NOT NULL, Name TEXT, Telephone TEXT)"];
    }];

//    
//    
//	char *zErr = NULL;
//	int rc;	
//	char *  sqliteQuery     = NULL;
//	
//	sqlite3 *database = DBOpen();	
//	const char sql_Template[] = "CREATE TABLE IF NOT EXISTS esmTraderName (TraderID INTEGER PRIMARY KEY  NOT NULL, Name TEXT, Telephone TEXT)";
//	sqliteQuery    = sqlite3_mprintf(sql_Template);
//	rc = sqlite3_exec(database, sqliteQuery, NULL, NULL, &zErr);
//	if(sqliteQuery) sqlite3_free(sqliteQuery);
//	if (zErr)  sqlite3_free(zErr);
//	DBClose();
}

- (void) loginNotify
{
	[lock lock];
	UInt16 nSyncDate = [self getSyncDate:SYNCDATE_ESMTRADER];
	
	EsmTraderSyncOut *packet = [[EsmTraderSyncOut alloc] initWithRecordDate:nSyncDate];
	[FSDataModelProc sendData:self WithPacket:packet];
	[lock unlock];
}

-(int)getSyncDate:(int)catID{
    int date = [self getDate:catID];
	if(date < 0) date = [CodingUtil makeDate:1960 month:1 day:1];
	return date;
}

- (int) getDate: (int) catID
{
    __block int date = -1;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT SyncDate FROM Misc_SyncDate where SectorID = ?",[NSNumber numberWithInt:catID]];
        while ([message next]) {
            date = [message intForColumn:@"syncDate"];
        }
        [message close];
    }];
    
    return date;
}


- (void) reloadData
{
    [lock lock];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT TraderID, Name, Telephone FROM esmTraderName"];
        while ([message next]) {
            EsmTraderParam * node = [[EsmTraderParam alloc] init];
            node->traderID = [message intForColumn:@"traderID"];
            node.traderName = [message stringForColumn:@"Name"]; ;
            node.traderTele = [message stringForColumn:@"Telephone"];
            [dataCacheArray addObject: node];
        }
        [message close];
    }];
    
    [lock unlock];
//	sqlite3_stmt * stmt;
//	int rc;
//	[lock lock];
//	sqlite3 *database = DBOpen();	
//	const char *sqliteQuery = "SELECT TraderID, Name, Telephone FROM esmTraderName";
//	rc = sqlite3_prepare_v2(database, sqliteQuery, -1, &stmt, NULL);
//	if (rc != SQLITE_OK) goto gotoNodeError ;
//	while (sqlite3_step(stmt) == SQLITE_ROW)
//	{
//		EsmTraderParam * node = [[EsmTraderParam alloc] init];
//		node->traderID = sqlite3_column_int(stmt, 0) ;
//		node.traderName = [NSString stringWithUTF8String: (char *)sqlite3_column_text(stmt, 1)];
//		node.traderTele = [NSString stringWithUTF8String: (char *)sqlite3_column_text(stmt, 2)];
//		[dataCacheArray addObject: node];
//		[node release];
//	}
//	sqlite3_finalize(stmt);
//	
//gotoNodeError:
//	DBClose();
//	[lock unlock];
}

- (int) getCount
{
	[lock lock];
	int count = (int)[dataCacheArray count];
	[lock unlock];
	return count;
}

- (EsmTraderParam*) getItemAt: (int) position
{
	[lock lock];
	if (position >= [dataCacheArray count]) return nil;
	EsmTraderParam* node = (EsmTraderParam*)[dataCacheArray objectAtIndex:position];
	[lock unlock];
	return node;
}

- (NSString*) getNameAt: (int) position
{
	NSString* result = nil;
	[lock lock];
	EsmTraderParam* node = [self getItemAt: position];
	if (node != nil)
		result = node.traderName;
	[lock unlock];
	return result;
}

- (NSString*) getNameByID: (UInt16) traderID;
{
	NSString* result = nil;
	[lock lock];
	for (EsmTraderParam *node in dataCacheArray)
	{
		if (node->traderID == traderID)
			result = node.traderName;
	}
	[lock unlock];
	return result;
}

- (NSString*) getPhoneByID: (UInt16) traderID;
{
	NSString* result = nil;
	[lock lock];
	for (EsmTraderParam *node in dataCacheArray)
	{
		if (node->traderID == traderID)
			result = node.traderTele;
	}
	[lock unlock];
	return result;
}

- (void) syncEsmTraderInfo:(EsmTraderSyncIn *)obj;
{
    [lock lock];
    BOOL modify = NO;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    for (EsmTraderParam *trader in obj.traderAddArray)
	{
        __block BOOL hasData = NO;
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            FMResultSet *message = [db executeQuery:@"SELECT * FROM esmTraderName WHERE TraderID = ?",[NSNumber numberWithUnsignedInt: trader->traderID]];
            while ([message next]) {
                hasData = YES;
            }
            [message close];
            if (hasData) {
                [db executeUpdate:@"UPDATE esmTraderName SET Name = ?, Telephone = ? WHERE TraderID = ?",trader.traderName,trader.traderTele,[NSNumber numberWithUnsignedInt:trader->traderID]];
            }else{
                [db executeUpdate:@"INSERT INTO esmTraderName (TraderID, Name, Telephone) VALUES (?,?,?)",[NSNumber numberWithUnsignedInt:trader->traderID],trader.traderName,trader.traderTele];
            }
            
        }];
        modify = YES;
    }
    
    for (EsmTraderParam *trader in obj.traderRemoveArray)
	{
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"DELETE FROM esmTraderName WHERE TraderID = ?",[NSNumber numberWithUnsignedInt:trader->traderID]];
        }];
        modify = YES;
    }
    
    if (modify && obj->returnCode == 0)
	{
		UInt16 nSyncDate = obj->recordDate;
		[self updateSyncDate: nSyncDate  andSectorID: SYNCDATE_ESMTRADER];
		[self reloadData];
		if (notifyTarget != nil)
			[notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
	}
    
    
//	char *sqliteQuery = NULL; 
//	int rc;
//	BOOL modify = NO;
//	
//	[lock lock];
//	sqlite3 *database = DBOpen();	
//	
//	for (EsmTraderParam *trader in obj.traderAddArray)
//	{
//		sqlite3_stmt *statment = NULL;
//		static const char *sql = "INSERT INTO esmTraderName (TraderID, Name, Telephone) VALUES (?,?,?)";
//		sqlite3_prepare_v2(database, sql, -1, &statment, NULL); 
//		sqlite3_bind_int(statment, 1, trader->traderID);
//		sqlite3_bind_text(statment, 2, [trader.traderName UTF8String], -1, SQLITE_TRANSIENT);
//		sqlite3_bind_text(statment, 3, [trader.traderTele UTF8String], -1, SQLITE_TRANSIENT);
//		int success = sqlite3_step(statment);
//		if (success != SQLITE_DONE) 
//			NSLog(@"%@",[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)]);
//		sqlite3_finalize(statment);
//		if (success == SQLITE_CONSTRAINT) 
//		{
//			static const char *sql = "UPDATE esmTraderName SET Name = ?, Telephone = ? WHERE TraderID = ?;";
//			sqlite3_prepare_v2(database, sql, -1, &statment, NULL); 
//			sqlite3_bind_text(statment, 1, [trader.traderName UTF8String], -1, SQLITE_TRANSIENT);
//			sqlite3_bind_text(statment, 2, [trader.traderTele UTF8String], -1, SQLITE_TRANSIENT);
//			sqlite3_bind_int(statment, 3, trader->traderID);
//			success = sqlite3_step(statment);
//			sqlite3_finalize(statment);
//		}
//		modify = YES;
//	}
//	
//	for (EsmTraderParam *trader in obj.traderRemoveArray)
//	{
//		sqliteQuery = sqlite3_mprintf("DELETE FROM esmTraderName WHERE TraderID = '%d';", trader->traderID);
//		rc = [mySQL exec:sqliteQuery withDB:database];
//		sqlite3_free(sqliteQuery);
//		modify = YES;
//	}
//	DBClose();
//	
//	// Return Code 	0: Last data, 1: Continuous 
//	if (modify && obj->returnCode == 0)
//	{
//		DB_Date *db_Date = [[DB_Date alloc] initWithTableName:MSIC_SYNCDATE_TABLE];
//		UInt16 nSyncDate = obj->recordDate;
//		[db_Date updateSyncDate: nSyncDate  andSectorID: SYNCDATE_ESMTRADER];
//		[db_Date release];
//		[self reloadData];
//		if (notifyTarget != nil)
//			[notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
//	}
//	
	[lock unlock];
}

- (void) updateSyncDate: (UInt16) syncDate  andSectorID: (UInt16) sectorID
{
    [lock lock];
    __block int count = 0;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT COUNT(*) AS COUNT FROM Misc_SyncDate where SectorID = ?",[NSNumber numberWithUnsignedInt:sectorID]];
        while ([message next]) {
            count = [message intForColumn:@"COUNT"];
        }
        [message close];
        
        if (count==0) {
            [db executeUpdate:@"INSERT INTO Misc_SyncDate (SectorID, SyncDate) VALUES (?,?)",[NSNumber numberWithUnsignedInt:sectorID],[NSNumber numberWithUnsignedInt:syncDate]];
        }else{
            [db executeUpdate:@"UPDATE Misc_SyncDate SET SyncDate = ? where SectorID = ?",[NSNumber numberWithUnsignedInt:syncDate],[NSNumber numberWithUnsignedInt:sectorID]];
        }
    }];
    [lock unlock];
}

@end
