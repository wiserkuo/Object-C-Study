//
//  BrokerInfo.m
//  Bullseye
//
//  Created by steven on 2009/6/16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BrokerInfo.h"
#import "BrokersOut.h"
#import "FSCategoryTree.h"
#import "FMDB.h"

#define SYNCDATE_BROKER        3

@implementation BrokerName

@synthesize fullName;

- (BrokerName*) init
{
	self = [super init];
	if (self)
	{
		fullName = nil;
	}
	return self;
}

@end

@implementation BrokerInfo

- (void) setTarget: (NSObject <BrokerNotifyProtocol>*) obj
{
	notifyTarget = obj;
}

- (BrokerInfo*) init
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
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS brokerName (Type INTEGER, BrokerID INTEGER PRIMARY KEY  NOT NULL, Name TEXT)"];
    }];
    
//	char *zErr = NULL;
//	int rc;	
//	char *  sqliteQuery     = NULL;
//	
//	sqlite3 *database = DBOpen();	
//	const char sql_Template[] = "CREATE TABLE IF NOT EXISTS brokerName (Type INTEGER, BrokerID INTEGER PRIMARY KEY  NOT NULL, Name TEXT)";
//	sqliteQuery    = sqlite3_mprintf(sql_Template);
//	rc = sqlite3_exec(database, sqliteQuery, NULL, NULL, &zErr);
//	if(sqliteQuery) sqlite3_free(sqliteQuery);
//	if (zErr)  sqlite3_free(zErr);
//	DBClose();
}

- (void) loginNotify
{
	[lock lock];
	UInt16 nSyncDate = [self getSyncDate:SYNCDATE_BROKER];

	BrokersOut *packet = [[BrokersOut alloc] initWithRecordDate:nSyncDate];
	[FSDataModelProc sendData:self WithPacket:packet];
	
	[lock unlock];
}

-(int)getSyncDate:(int)catID{
    int date = [self getDate:catID];
	if(date < 0){
        date = [CodingUtil makeDate:1960 month:1 day:1];
    }
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
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT Type, BrokerID, Name FROM brokerName"];
        while ([message next]) {
            BrokerName * node = [[BrokerName alloc] init];
            node->Type = [message intForColumn:@"Type"];
            node->BrokerID = [message intForColumn:@"BrokerID"]; ;
            node->fullName = [message stringForColumn:@"Name"];
            [dataCacheArray addObject: node];
        }
        [message close];
    }];
    
//	sqlite3_stmt * stmt;
//	int rc;
//	[lock lock];
//	sqlite3 *database = DBOpen();	
//	const char *sqliteQuery = "SELECT Type, BrokerID, Name FROM brokerName";
//	rc = sqlite3_prepare_v2(database, sqliteQuery, -1, &stmt, NULL);
//	if (rc != SQLITE_OK) goto gotoNodeError ;
//	while (sqlite3_step(stmt) == SQLITE_ROW)
//	{
//		BrokerName * node = [[BrokerName alloc] init];
//		node->Type = sqlite3_column_int(stmt, 0);
//		node->BrokerID = sqlite3_column_int(stmt, 1) ;
//		node->fullName = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 2)];
//		[dataCacheArray addObject: node];
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

- (BrokerName*) getItemAt: (int) position
{
	[lock lock];
	if (position >= [dataCacheArray count]) return nil;
	BrokerName* node = (BrokerName*)[dataCacheArray objectAtIndex:position];
	[lock unlock];
	return node;
}

- (NSString*) getNameAt: (int) position
{
	NSString* result = nil;
	[lock lock];
	BrokerName* node = [self getItemAt: position];
	if (node != nil)
		result = node->fullName;
	[lock unlock];
	return result;
}

- (NSString*) getNameByID: (UInt16) brokerID;
{
	NSString* result = nil;
	[lock lock];
	for (BrokerName *broker in dataCacheArray)
	{
		if (broker->BrokerID == brokerID)
			result = broker->fullName;
	}
	[lock unlock];
	return result;
}

- (void) syncBrokerInfo:(BrokersIn *)obj;
{
    BOOL modify = NO;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    for (BrokersParam *broker in obj->brokersAddArray)
	{
        __block BOOL hasData = NO;
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            FMResultSet *message = [db executeQuery:@"SELECT Type, BrokerID, Name FROM brokerName WHERE BrokerID = ?",[NSNumber numberWithUnsignedInt: broker->brokerID]];
            while ([message next]) {
                hasData = YES;
            }
            [message close];
            if (hasData) {
                [db executeUpdate:@"UPDATE brokerName SET Name = ?, Type = ? WHERE BrokerID = ?",broker->brokerName,[NSNumber numberWithUnsignedInt:broker->brokerType],[NSNumber numberWithUnsignedInt:broker->brokerID]];
            }else{
                [db executeUpdate:@"INSERT INTO brokerName (Type, BrokerID, Name) VALUES (?,?,?)",[NSNumber numberWithUnsignedInt:broker->brokerType],[NSNumber numberWithUnsignedInt:broker->brokerID],broker->brokerName];
            }
            
        }];
        modify = YES;
    }
    
    for (BrokersParam *broker in obj->brokersRemoveArray)
	{
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"DELETE FROM brokerName WHERE BrokerID = ?",[NSNumber numberWithUnsignedInt:broker->brokerID]];
        }];
        modify = YES;
    }
    
    if (modify && obj->returnCode == 0)
	{
		UInt16 nSyncDate = obj->recordDate;
		[self updateSyncDate: nSyncDate  andSectorID: SYNCDATE_BROKER];
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
//	for (BrokersParam *broker in obj->brokersAddArray)
//	{
//		sqlite3_stmt *statment = NULL;
//		static const char *sql = "INSERT INTO brokerName (Type, BrokerID, Name) VALUES (?,?,?)";
//		sqlite3_prepare_v2(database, sql, -1, &statment, NULL); 
//		sqlite3_bind_int(statment, 1, broker->brokerType);
//		sqlite3_bind_int(statment, 2, broker->brokerID);
//		sqlite3_bind_text(statment, 3, [broker->brokerName UTF8String], -1, SQLITE_TRANSIENT);
//		int success = sqlite3_step(statment);
//		if (success != SQLITE_DONE) 
//			NSLog(@"%@",[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)]);
//		sqlite3_finalize(statment);
//		if (success == SQLITE_CONSTRAINT) 
//		{
//				static const char *sql = "UPDATE brokerName SET Name = ?, Type = ? WHERE BrokerID = ?;";
//				sqlite3_prepare_v2(database, sql, -1, &statment, NULL); 
//				sqlite3_bind_text(statment, 1, [broker->brokerName UTF8String], -1, SQLITE_TRANSIENT);
//				sqlite3_bind_int(statment, 2, broker->brokerType);
//				sqlite3_bind_int(statment, 3, broker->brokerID);
//				success = sqlite3_step(statment);
//				sqlite3_finalize(statment);
//		}
//		modify = YES;
//	}
//
//	for (BrokersParam *broker in obj->brokersRemoveArray)
//	{
//			sqliteQuery = sqlite3_mprintf("DELETE FROM brokerName WHERE BrokerID = '%d';", broker->brokerID);
//			rc = [mySQL exec:sqliteQuery withDB:database];
//			sqlite3_free(sqliteQuery);
//			modify = YES;
//	}
//	DBClose();
//	
//	// Return Code 	0: Last data, 1: Continuous 
//	if (modify && obj->returnCode == 0)
//	{
//		DB_Date *db_Date = [[DB_Date alloc] initWithTableName:MSIC_SYNCDATE_TABLE];
//		UInt16 nSyncDate = obj->recordDate;
//		[db_Date updateSyncDate: nSyncDate  andSectorID: SYNCDATE_BROKER];
//		[self reloadData];
//		if (notifyTarget != nil)
//			[notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
//	}
//	
//	[lock unlock];
}

- (void) updateSyncDate: (UInt16) syncDate  andSectorID: (UInt16) sectorID
{
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
    

//	char *  sqliteQuery = NULL;
//	
//	if(isDatabaseValid == NO) return -1;
//	sqlite3 *db = DBOpen();
//	if (db == NULL)	return -3;
//	
//	sqliteQuery = sqlite3_mprintf("SELECT  COUNT(*) FROM %s where SectorID = %d;", [tableName UTF8String], sectorID);
//	//nCount = [self SQL_GetCount:sqliteQuery] ;
//	int nCount = [mySQL getCount:sqliteQuery withDB:db] ;
//	sqlite3_free(sqliteQuery);
//	if(nCount == 0)
//	{
//		sqliteQuery = sqlite3_mprintf("INSERT INTO %s (SectorID, SyncDate) VALUES ('%d', '%d');",
//                                      [tableName UTF8String], sectorID, syncDate);
//		[mySQL exec:sqliteQuery withDB:db];
//		sqlite3_free(sqliteQuery);
//	}
//	else if(nCount > 0)
//	{
//		sqliteQuery = sqlite3_mprintf("UPDATE %s SET SyncDate = %d where SectorID = %d;",
//                                      [tableName UTF8String], syncDate, sectorID);
//		[mySQL exec:sqliteQuery withDB:db];
//		sqlite3_free(sqliteQuery);
//	}
//	DBClose();
//	return 0;
}


@end
