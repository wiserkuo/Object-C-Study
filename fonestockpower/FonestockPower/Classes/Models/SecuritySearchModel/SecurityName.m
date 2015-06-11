//
//  SecurityName.m
//  Bullseye
//
//  Created by steven on 2008/12/8.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SymbolSyncOut.h"
#import "SymbolSyncIn.h"
#import "SecurityName.h"
#import "CodingUtil.h"
#import "Portfolio.h"
#import "DBManager.h"
#import "OptionSymbolSyncOut.h"
#import "OptionSymbolSyncIn.h"
#import "SecuritySearch.h"
#import "ValueUtil.h"

#define MAX_COUNT 200
BOOL doGetAllSecurities = NO; 

//@implementation SymbolFormat1 (Compare)
//- (NSComparisonResult) compare:(SymbolFormat1 *)obj
//{
//	if ([self isKindOfClass:[SymbolFormat1 class]])
//	{
//		if ([obj isKindOfClass:[SymbolFormat1 class]])
//			return [symbol compare: obj-> symbol];
//		else
//			return NSOrderedAscending;
//	}
//	else
//	{
//		if ([obj isKindOfClass:[SymbolFormat1 class]])
//			return NSOrderedDescending;
//		else 
//			return NSOrderedSame;
//	}
//}
//@end

@implementation SectorID

@synthesize group;

-(id)initWithID:(UInt16) ID
{
	if(self == [super init]) 
	{
        group = ID;
    }
    return self;
}

- (void)dealloc
{
	[super dealloc];
}


@end


@implementation NSString (identCodeSymbol)

+(NSString *) stringWithIdentCode: (char*)identCode Symbol: (NSString*)symbol
{
	NSString *identCodeSymbol = [NSString stringWithFormat:@"%c%c %@",identCode[0], identCode[1], symbol];
	return identCodeSymbol;
}

+(NSString *) newWithIdentCode: (char*)identCode Symbol: (NSString*)symbol
{
	NSString *identCodeSymbol = [[NSString alloc] initWithFormat:@"%c%c %@",identCode[0], identCode[1], symbol];
	return identCodeSymbol;
}

@end

@implementation SecurityName

@synthesize symbol;
@synthesize fullName;

- (SecurityName*) init
{
	self = [super init];
	if (self)
	{
		catID = 0;
		identCode[0] = 0;
		identCode[1] = 0;
		type_id = 0;
		symbol = nil;
		fullName = nil;
	}
	return self;
}

- (void)dealloc
{
	if(symbol) [symbol release];
	if(fullName) [fullName release];
	[super dealloc];
}

@end

@implementation SearchParam

- (SearchParam*) init
{
	self = [super init];
	if (self)
	{
		keyword = nil;
		
	}
	return self;
}

- (void)dealloc
{
	if (keyword != nil) [keyword release];
	[super dealloc];
}

@end


@implementation SecurityNameData

@synthesize notifyTarget;

- (void) setTarget: (NSObject <Notify>*) obj
{
	self.notifyTarget = obj;
}

- (SecurityNameData*) init
{
	self = [super init];
	if (self)
	{
		lock = [[NSRecursiveLock alloc] init];
		notifyTarget = nil;
		currCatID = 0;
		isDatabaseValid = NO;
		db_Date = [[DB_Date alloc] initWithTableName:@"Cat_SyncDate"];
		[self initDatabase];	
		dataCacheArray  = [[NSMutableArray alloc] init];
		autofetchArray = nil;
		autoFetingCatID = 0xFFFF;
		
		replaceMarkUpArray = [[NSMutableArray alloc]init];
	}
	return self;
}

- (void) initDatabase
{
	char *zErr = NULL;
	int rc;	
	char *  sqliteQuery     = NULL;
	
	isDatabaseValid = NO;
	if(db_Date == nil)
	{
		isDatabaseValid = NO;
		return;
	}
	sqlite3 *database = DBOpen();	
	if(database == NULL)
	{
		isDatabaseValid = NO;
		return;
	}
	
	const char sql_Template[] = "CREATE TABLE IF NOT EXISTS Cat_FullName (IdentCode TEXT, Symbol TEXT, Type_id INTEGER, FullName TEXT, SectorID INTEGER, PRIMARY KEY (SectorID, IdentCode, Symbol))";
	sqliteQuery    = sqlite3_mprintf(sql_Template);
	rc = sqlite3_exec(database, sqliteQuery, NULL, NULL, &zErr);
	if(sqliteQuery) sqlite3_free(sqliteQuery);
	if (rc != SQLITE_OK)
		isDatabaseValid = NO;
	else
		isDatabaseValid = YES;	
	if (zErr)  sqlite3_free(zErr);
	
	//////////////////////////////////////////////////////	
	const char sql_IndexTemplate[] = "CREATE INDEX IF NOT EXISTS FullNameIndex ON Cat_FullName (IdentCode ASC, Symbol ASC)";
	sqliteQuery    = sqlite3_mprintf(sql_IndexTemplate);
	rc = sqlite3_exec(database, sqliteQuery, NULL, NULL, &zErr);
	if(sqliteQuery) sqlite3_free(sqliteQuery);
	if (zErr)  sqlite3_free(zErr);
	///////////////////////////////////////////////////////////
	
	DBClose();
}

- (void)sortDataBy:(NSInteger)option
{
	switch (option) 
	{
		case 0://symbol
		{
			NSSortDescriptor *sortDescriptor;
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"symbol" ascending:YES selector:@selector(compare:)];
			NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
			[dataCacheArray sortUsingDescriptors:sortDescriptors];
			[sortDescriptor release];
			[sortDescriptors release];
			break;
		}
		default:
			break;
	}
}

- (void) getData 
{
	char *  sqliteQuery  = NULL;
	sqlite3_stmt * stmt;
	int rc;
	
	if (!isDatabaseValid) return;
	
	[lock lock];
	sqlite3 *database = DBOpen();	
	[dataCacheArray removeAllObjects];
	
	// find current nodeID leafType.
	int currentNodeLeafType =1;
	sqliteQuery = sqlite3_mprintf("SELECT Leaf from category where catID = %d", currCatID);
	rc = sqlite3_prepare(database, sqliteQuery, -1, &stmt, NULL);	
	if (rc == SQLITE_OK && sqlite3_step(stmt) == SQLITE_ROW){
		
		currentNodeLeafType = sqlite3_column_int(stmt, 0);
		
	}
	
	sqlite3_finalize(stmt);
	sqlite3_free(sqliteQuery);	
	int catID = currCatID;
	
	if(currentNodeLeafType==2)
	{ 		
		// special leaf:
		
		sqliteQuery = sqlite3_mprintf("select IdentCode, Symbol, Type_id, FullName, SectorID from cat_fullName where sectorID in (SELECT catID from category where ParentID = %d);", currCatID); // 1:formal leaf 3:special leaf(the leaf is aslo contain identcode symbol leaf)
		rc = sqlite3_prepare(database, sqliteQuery, -1, &stmt, NULL);
		sqlite3_free(sqliteQuery);	
		if (rc != SQLITE_OK) goto DataError;
		while (sqlite3_step(stmt) == SQLITE_ROW)
		{
			SecurityName * node = [[SecurityName alloc] init];
			memcpy(node->identCode, sqlite3_column_text(stmt, 0), 2);
			char *checkString = (char*)sqlite3_column_text(stmt, 1);
			if(checkString)
				node->symbol =  [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 1)];
			else
				node->symbol =  [[NSString alloc] initWithString:@""];
			node->type_id = sqlite3_column_int(stmt, 2) ;
			checkString = (char*)sqlite3_column_text(stmt, 3);
			if(checkString)
				node->fullName =  [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 3)];
			else
				node->fullName = [[NSString alloc] initWithString:@""];
			node->catID = sqlite3_column_int(stmt, 4);
			[dataCacheArray addObject: node];
			[node release];
		}
		sqlite3_finalize(stmt);
		
	}else{
		
		// normal leaf:
		
		if(catID == 754) //美國ADR要用server下來的順序做排序
			sqliteQuery = sqlite3_mprintf("SELECT IdentCode, Symbol, Type_id, FullName  FROM Cat_FullName where SectorID = %d Order By rowid ASC", catID);
		else if(catID == 958) // 港股指數要用server下來的順序做排序
			sqliteQuery = sqlite3_mprintf("SELECT IdentCode, Symbol, Type_id, FullName  FROM Cat_FullName where SectorID = %d Order By rowid ASC", catID);
#if defined (BROKER_YUANTA)		
		else if(catID == 51 || catID == 52) // 期貨近一  近二 要用server下來的順序做排序
			sqliteQuery = sqlite3_mprintf("SELECT IdentCode, Symbol, Type_id, FullName  FROM Cat_FullName where SectorID = %d Order By rowid ASC", catID);
#endif
		else	
			sqliteQuery = sqlite3_mprintf("SELECT IdentCode, Symbol, Type_id, FullName  FROM Cat_FullName where SectorID = %d", catID);
		
		rc = sqlite3_prepare(database, sqliteQuery, -1, &stmt, NULL);
		sqlite3_free(sqliteQuery);	
		if (rc != SQLITE_OK) goto DataError;
		while (sqlite3_step(stmt) == SQLITE_ROW)
		{
			SecurityName * node = [[SecurityName alloc] init];
			memcpy(node->identCode, sqlite3_column_text(stmt, 0), 2);
			char *checkString = (char*)sqlite3_column_text(stmt, 1);
			if(checkString)
				node->symbol =  [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 1)];
			else
				node->symbol =  [[NSString alloc] initWithString:@""];
			node->type_id = sqlite3_column_int(stmt, 2) ;
			checkString = (char*)sqlite3_column_text(stmt, 3);
			if(checkString)
				node->fullName =  [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 3)];
			else
				node->fullName = [[NSString alloc] initWithString:@""];
			node->catID = catID;
			[dataCacheArray addObject: node];
			[node release];
		}
		sqlite3_finalize(stmt);
		
		
	}
	
	
DataError:	
	DBClose();
	
#if defined (BROKER_YUANTA)
	if(catID == 754) //美國ADR要用server下來的順序做排序
	{
	}
	else if(catID == 958) // 港股指數要用server下來的順序做排序
	{
	}
	else if(catID == 51) // 期貨近一要用server下來的順序做排序
	{
	}
	else if(catID == 52) // 期貨近二要用server下來的順序做排序
	{
	}
	else	
	{
		[self sortDataBy:0];
	}
#endif
	[lock unlock];	
}

- (void) reloadData
{
	[self getData] ;
}

-(NSInteger)checkArea:(UInt16) groupID
{
	UInt16 rootID = [[DataModalProc getDataModal].category getRootCatID:groupID];
	NSInteger area4scuritySync = [[DataModalProc getDataModal].category checkRootCatIDArea:rootID];
	return area4scuritySync ;
}


// For Internal use.
- (void) requestCatID: (UInt16) catID
{
	char *  sqliteQuery  = NULL;
	sqlite3_stmt * stmt;
	int rc;
	
	if (!isDatabaseValid) return;
	
#if defined (BROKER_YUANTA) && !defined BROKER_GOLDEN_GATE
	NSInteger area = [self checkArea:catID];
#endif
	[lock lock];
	sqlite3 *database = DBOpen();	
	
	// find current nodeID leafType.
	int currentNodeLeafType =1;
	sqliteQuery = sqlite3_mprintf("SELECT Leaf from category where catID = %d", catID);
	rc = sqlite3_prepare(database, sqliteQuery, -1, &stmt, NULL);	
	if (rc == SQLITE_OK && sqlite3_step(stmt) == SQLITE_ROW){
		
		currentNodeLeafType = sqlite3_column_int(stmt, 0);
		
	}
	
	sqlite3_finalize(stmt);
	sqlite3_free(sqliteQuery);	
	
	// request for special leaf node 
	if(currentNodeLeafType==2)
	{ 
		// 由 sectorID parent node request special leaf 商品
		
		// special leaf:
		sqliteQuery = sqlite3_mprintf("SELECT catID from category where ParentID = %d;", catID); // 1:formal leaf 3:special leaf(the leaf is aslo contain identcode symbol leaf)
		rc = sqlite3_prepare(database, sqliteQuery, -1, &stmt, NULL);
		if (rc != SQLITE_OK) goto exit;
		
		while (sqlite3_step(stmt) == SQLITE_ROW)
		{
			int myCatID = sqlite3_column_int(stmt, 0);
			
			DataModalProc *dataModal = [DataModalProc getDataModal];
			UInt16 catType = [dataModal.category getCatType:myCatID];
			if (catType & 32) // option
			{
				UInt16 nSyncDate = [db_Date getSyncDate:myCatID];
				
#if defined (BROKER_YUANTA) && !defined BROKER_GOLDEN_GATE
				if (area == 0) 
				{
					OptionSymbolSyncOut *packet = [[OptionSymbolSyncOut alloc] initWithSectorID: myCatID Date:nSyncDate];
					[DataModalProc sendYuantadData:self WithPacket:packet];
					[packet release];
				}
				else if (area == 1) 
				{
					OptionSymbolSyncOut *packet = [[OptionSymbolSyncOut alloc] initWithSectorID: myCatID Date:nSyncDate];
					[DataModalProc sendData:self WithPacket:packet];
					[packet release];
				}
				else
				{
					OptionSymbolSyncOut *packet = [[OptionSymbolSyncOut alloc] initWithSectorID: myCatID Date:nSyncDate];
					[DataModalProc sendYuantadData:self WithPacket:packet];
					[packet release];
					
					OptionSymbolSyncOut *packet2 = [[OptionSymbolSyncOut alloc] initWithSectorID: myCatID Date:nSyncDate];
					[DataModalProc sendData:self WithPacket:packet2];
					[packet2 release];
				}
				
				
#else
				OptionSymbolSyncOut *packet = [[OptionSymbolSyncOut alloc] initWithSectorID: myCatID Date:nSyncDate];
				[DataModalProc sendData:self WithPacket:packet];
				[packet release];
#endif
			}
			else
			{
				UInt16 nSyncDate = [db_Date getSyncDate:myCatID];
				
				//NSDate *syncDate = [ValueUtil nsDateFromStkDate:nSyncDate];
				//NSLog(@"myCatID:%d SyncDate:%d (%@)",myCatID,nSyncDate,[syncDate description]);
				
	
#if defined (BROKER_YUANTA) && !defined BROKER_GOLDEN_GATE
				if (area == 0) 
				{
					SymbolSyncOut *packet = [[SymbolSyncOut alloc] initWithSectorID_SyncDate: myCatID syncDate:nSyncDate];
					[DataModalProc sendYuantadData:self WithPacket:packet];
					[packet release];
				}
				else if (area == 1) 
				{
					SymbolSyncOut *packet = [[SymbolSyncOut alloc] initWithSectorID_SyncDate: myCatID syncDate:nSyncDate];
					[DataModalProc sendData:self WithPacket:packet];
					[packet release];
				}
				else
				{
					SymbolSyncOut *packet = [[SymbolSyncOut alloc] initWithSectorID_SyncDate: myCatID syncDate:nSyncDate];
					[DataModalProc sendYuantadData:self WithPacket:packet];
					[packet release];
					
					SymbolSyncOut *packet2 = [[SymbolSyncOut alloc] initWithSectorID_SyncDate: myCatID syncDate:nSyncDate];
					[DataModalProc sendData:self WithPacket:packet2];
					[packet2 release];
				}
				
				
#else
				SymbolSyncOut *packet = [[SymbolSyncOut alloc] initWithSectorID_SyncDate: myCatID syncDate:nSyncDate];
				[DataModalProc sendData:self WithPacket:packet];
				[packet release];
#endif
				
			}
			
			
		}
		sqlite3_finalize(stmt);
		sqlite3_free(sqliteQuery);
		
	}
	else{
		
		DataModalProc *dataModal = [DataModalProc getDataModal];
		UInt16 catType = [dataModal.category getCatType:catID];
		// bit 1:news, bit2:stock, bit3:warrant, bit4:index, bit5:future, bit6:option, bit7:forex. bit8~16:reserved 
		if (catType & 32) // option
		{
			UInt16 nSyncDate = [db_Date getSyncDate:catID];
#if defined (BROKER_YUANTA) && !defined BROKER_GOLDEN_GATE
			if (area == 0) 
			{
				OptionSymbolSyncOut *packet = [[OptionSymbolSyncOut alloc] initWithSectorID: catID Date:nSyncDate];
				[DataModalProc sendYuantadData:self WithPacket:packet];
				[packet release];
			}
			else if (area == 1) 
			{
				OptionSymbolSyncOut *packet = [[OptionSymbolSyncOut alloc] initWithSectorID: catID Date:nSyncDate];
				[DataModalProc sendData:self WithPacket:packet];
				[packet release];
			}
			else
			{
				OptionSymbolSyncOut *packet = [[OptionSymbolSyncOut alloc] initWithSectorID: catID Date:nSyncDate];
				[DataModalProc sendYuantadData:self WithPacket:packet];
				[packet release];
				
				OptionSymbolSyncOut *packet2 = [[OptionSymbolSyncOut alloc] initWithSectorID: catID Date:nSyncDate];
				[DataModalProc sendData:self WithPacket:packet2];
				[packet2 release];
			}
			
			
#else
			OptionSymbolSyncOut *packet = [[OptionSymbolSyncOut alloc] initWithSectorID: catID Date:nSyncDate];
			[DataModalProc sendData:self WithPacket:packet];
			[packet release];
#endif
		}
		else
		{
			UInt16 nSyncDate = [db_Date getSyncDate:catID];
			
			//NSDate *syncDate = [ValueUtil nsDateFromStkDate:nSyncDate];
			//NSLog(@"myCatID:%d SyncDate:%d (%@)",catID,nSyncDate,[syncDate description]);
			
#if defined (BROKER_YUANTA) && !defined BROKER_GOLDEN_GATE
			if (area == 0) 
			{
				SymbolSyncOut *packet = [[SymbolSyncOut alloc] initWithSectorID_SyncDate: catID syncDate:nSyncDate];
				[DataModalProc sendYuantadData:self WithPacket:packet];
				[packet release];
			}
			else if (area == 1) 
			{
				SymbolSyncOut *packet = [[SymbolSyncOut alloc] initWithSectorID_SyncDate: catID syncDate:nSyncDate];
				[DataModalProc sendData:self WithPacket:packet];
				[packet release];
			}
			else
			{
				SymbolSyncOut *packet = [[SymbolSyncOut alloc] initWithSectorID_SyncDate: catID syncDate:nSyncDate];
				[DataModalProc sendYuantadData:self WithPacket:packet];
				[packet release];
				
				SymbolSyncOut *packet2 = [[SymbolSyncOut alloc] initWithSectorID_SyncDate: catID syncDate:nSyncDate];
				[DataModalProc sendData:self WithPacket:packet2];
				[packet2 release];
			}
			
			
#else
			SymbolSyncOut *packet = [[SymbolSyncOut alloc] initWithSectorID_SyncDate: catID syncDate:nSyncDate];
			[DataModalProc sendData:self WithPacket:packet];
			[packet release];
#endif
			
		}
		
		
	}
	
exit:
	DBClose();
	
	[lock unlock];
}


- (void) selectCatID: (UInt16) catID
{
	if (currCatID == catID) return;
	currCatID = catID;
	[self getData];
	[self requestCatID: catID];
}

- (int) getCount
{
	[lock lock];
	int count = [dataCacheArray count];
	[lock unlock];
	return count;
}

- (SecurityName*) getItemAt: (int) position
{
	[lock lock];
	if (position >= [dataCacheArray count])
	{
		[lock unlock];
		return nil;
	}
	SecurityName* node = (SecurityName*)[dataCacheArray objectAtIndex:position];
	[lock unlock];
	return node;
}

- (NSString*) getSymbolAt: (int) position
{
	NSString* result = nil;
	[lock lock];
	SecurityName* node = [self getItemAt: position];
	if (node != nil)
		result = node->symbol;
	[lock unlock];
	return result;
}

- (NSString*) getNameAt: (int) position
{
	NSString* result = nil;
	[lock lock];
	SecurityName* node = [self getItemAt: position];
	if (node != nil)
		result = node->fullName;
	[lock unlock];
	return result;
}

// for special leaf ex:黃金 白銀 天然氣
- (NSString *)getSecurityNameTitleAt: (int) position{
	
	char *  sqliteQuery  = NULL;
	sqlite3_stmt * stmt;
	int rc;
	
	[lock lock];
	
	SecurityName *secName = (SecurityName *)[dataCacheArray objectAtIndex:position];
	int sectorID = secName->catID;
	
	sqlite3 *database = DBOpen();	
	
	// find current nodeID leafType.
	int currentNodeLeafType;
	NSString *catName = nil;
	sqliteQuery = sqlite3_mprintf("SELECT Leaf,CatName from category where catID = %d", sectorID);
	rc = sqlite3_prepare(database, sqliteQuery, -1, &stmt, NULL);	
	if (rc == SQLITE_OK && sqlite3_step(stmt) == SQLITE_ROW){
		
		currentNodeLeafType = sqlite3_column_int(stmt, 0); // 1
		catName = [NSString stringWithUTF8String: (char *) sqlite3_column_text(stmt, 1)];
	}
	
	sqlite3_finalize(stmt);
	sqlite3_free(sqliteQuery);	
	DBClose();	
	
	[lock unlock];
	
	return catName;
	
	
}

- (BOOL) isCheckedAt: (int) position
{
	SecurityName *obj = [self getItemAt: position];
	if (obj == nil) return NO;
	DataModalProc *dataModal = [DataModalProc getDataModal];
	return [dataModal.portfolioData isAdded: obj->identCode andSymbol: obj->symbol];
}

- (BOOL) checkAt: (int) position
{
	SecurityName *obj = [self getItemAt: position];
	if (obj == nil) return NO;
	DataModalProc *dataModal = [DataModalProc getDataModal];
	return [dataModal.portfolioData AddItem: obj];
}

- (void) uncheckAt: (int) position;
{
	SecurityName *obj = [self getItemAt: position];
	if (obj == nil) return;
	DataModalProc *dataModal = [DataModalProc getDataModal];
	[dataModal.portfolioData RemoveItem: obj->identCode andSymbol: obj->symbol];
}

- (void) addSecurity:(SymbolSyncIn *) obj
{
	char *sqliteQuery = NULL; 
	int rc;
	BOOL modify = NO;
	char identCode[3];
	
	[lock lock];
	

//	if(obj->syncType == 0)
//		NSLog(@"addSecurity arrayCount:%d syncType:增 returnCode:%d",[obj->dataArray count],obj->retCode);
//	else if(obj->syncType == 1)
//		NSLog(@"addSecurity arrayCount:%d syncType:刪 returnCode:%d",[obj->dataArray count],obj->retCode);
//	else if(obj->syncType == 20)
//		NSLog(@"addSecurity replace");

	
	sqlite3 *database = DBOpen();
	NSMutableArray *array = obj->dataArray;
	if (obj->syncType == 0)		// Add record
	{
		for (SymbolFormat1 *security1 in array)
		{
			// Accept all commodity
			//if (!(security1->typeID == TYPE_STOCK || security1->typeID == TYPE_INDEX || security1->typeID == TYPE_MARKET_INDEX
			//	|| security1->typeID == TYPE_FUTURE || security1->typeID == TYPE_CURRENCY))
			//	continue;
			identCode[0] = security1->IdentCode[0];
			identCode[1] = security1->IdentCode[1];
			identCode[2] = 0;
			
			NSLog(@"Add symbol:%@ (%@)",security1->symbol,security1->fullName);
			
#if 0 // Cannot process FullName with special character.
			sqliteQuery = sqlite3_mprintf("INSERT INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES ('%s','%s','%d','%s', '%d');", 
										  identCode, [security1->symbol UTF8String], security1->typeID, [security1->fullName UTF8String], obj->sectorID);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);
			if (rc == SQLITE_CONSTRAINT) // 19 Exist.
			{
				sqliteQuery = sqlite3_mprintf("UPDATE Cat_FullName SET FullName = '%s', Type_id = '%d' WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';", 
											  [security1->fullName UTF8String], security1->typeID, identCode, [security1->symbol UTF8String], obj->sectorID);
				rc = [mySQL exec:sqliteQuery withDB:database];
				sqlite3_free(sqliteQuery);
			}
#else
			sqlite3_stmt *statment = NULL;
			static const char *sql = "INSERT INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES (?,?,?,?,?)";
			sqlite3_prepare_v2(database, sql, -1, &statment, NULL); 
			sqlite3_bind_text(statment, 1, identCode, -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statment, 2, [security1->symbol UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statment, 3, security1->typeID);
			sqlite3_bind_text(statment, 4, [security1->fullName UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statment, 5, obj->sectorID);
			int success = sqlite3_step(statment);
			sqlite3_finalize(statment);
			if (success == SQLITE_CONSTRAINT) 
			{
				static const char *sql = "UPDATE Cat_FullName SET FullName = ?, Type_id = ? WHERE IdentCode = ? AND Symbol = ? AND SectorID = ?;";
				sqlite3_prepare_v2(database, sql, -1, &statment, NULL); 
				sqlite3_bind_text(statment, 1, [security1->fullName UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(statment, 2, security1->typeID);
				sqlite3_bind_text(statment, 3, identCode, -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statment, 4, [security1->symbol UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(statment, 5, obj->sectorID);
				success = sqlite3_step(statment);
				sqlite3_finalize(statment);
			}
#endif
			// delete entry add for search where its sector_id = 0;
			sqliteQuery = sqlite3_mprintf("DELETE FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';", 
										  identCode, [security1->symbol UTF8String], 0);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);
			modify = YES;
		}
	}
	else if (obj->syncType == 1) 	// Delete record
	{
		for (SymbolFormat3 *security3 in array)
		{
			identCode[0] = security3->IdentCode[0];
			identCode[1] = security3->IdentCode[1];
			identCode[2] = 0;
			
			NSLog(@"Delete symbol:%@",security3->symbol);
			
			sqliteQuery = sqlite3_mprintf("DELETE FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';", 
										  identCode, [security3->symbol UTF8String], obj->sectorID);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);
			modify = YES;
		}
	}
	else if (obj->syncType == 20)  // Replace
	{

		BOOL isExist = NO;
		for(NSNumber *num in replaceMarkUpArray)
		{
			if(obj->sectorID == [num intValue])
			{
				isExist = YES;
				break;
			}
		}
		
		if(!isExist)
		{
			NSLog(@" --- NOT Exist  --- ");
			NSLog(@"DELETE OLD SECTOR :%d",obj->sectorID);	
			sqliteQuery = sqlite3_mprintf("DELETE FROM Cat_FullName WHERE SectorID = '%d';",obj->sectorID);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);	
			
			//replaceMarkUpArray;
			[replaceMarkUpArray addObject:[NSNumber numberWithInt:obj->sectorID]];
			
		}
		else
		{
			NSLog(@" ---  Exist  --- ");
		}
		
		for (SymbolFormat1 *security1 in array)
		{
			identCode[0] = security1->IdentCode[0];
			identCode[1] = security1->IdentCode[1];
			identCode[2] = 0;
			
#if 0 // Cannot process FullName with special character.
			sqliteQuery = sqlite3_mprintf("INSERT INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES ('%s','%s','%d','%s', '%d');", 
										  identCode, [security1->symbol UTF8String], security1->typeID, [security1->fullName UTF8String], obj->sectorID);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);
			if (rc == SQLITE_CONSTRAINT) // 19 Exist.
			{
				sqliteQuery = sqlite3_mprintf("UPDATE Cat_FullName SET FullName = '%s', Type_id = '%d' WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';", 
											  [security1->fullName UTF8String], security1->typeID, identCode, [security1->symbol UTF8String], obj->sectorID);
				rc = [mySQL exec:sqliteQuery withDB:database];
				sqlite3_free(sqliteQuery);
			}
			
			// delete entry add for search where its sector_id = 0;
			sqliteQuery = sqlite3_mprintf("DELETE FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';", 
										  identCode, [security1->symbol UTF8String], 0);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);
			
#else
			NSLog(@"Replace %@-%@",security1->symbol,security1->fullName);
			
			sqlite3_stmt *statment = NULL;
			static const char *sql = "INSERT INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES (?,?,?,?,?)";
			sqlite3_prepare_v2(database, sql, -1, &statment, NULL); 
			sqlite3_bind_text(statment, 1, identCode, -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statment, 2, [security1->symbol UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statment, 3, security1->typeID);
			sqlite3_bind_text(statment, 4, [security1->fullName UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statment, 5, obj->sectorID);
			int success = sqlite3_step(statment);
			sqlite3_finalize(statment);
			if (success == SQLITE_CONSTRAINT) 
			{
				NSLog(@"SQLITE_CONSTRAINT Update %@-%@",security1->symbol,security1->fullName);
				
				static const char *sql = "UPDATE Cat_FullName SET FullName = ?, Type_id = ? WHERE IdentCode = ? AND Symbol = ? AND SectorID = ?;";
				sqlite3_prepare_v2(database, sql, -1, &statment, NULL); 
				sqlite3_bind_text(statment, 1, [security1->fullName UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(statment, 2, security1->typeID);
				sqlite3_bind_text(statment, 3, identCode, -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statment, 4, [security1->symbol UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(statment, 5, obj->sectorID);
				success = sqlite3_step(statment);
				sqlite3_finalize(statment);
			}
			else  if(success != SQLITE_DONE)
			{
				NSLog(@"SQLITE_ERROR !!!%@ %@",security1->symbol,security1->fullName);				
			}

#endif
			modify = YES;
			
		}
		
		if (modify && obj->retCode == 0)
		{
			[replaceMarkUpArray removeAllObjects];
		}
		
	}
	DBClose();
	
	// Return Code 	0: Last data, 1: Continuous 
	if (modify && obj->retCode == 0)
	{
		[db_Date updateSyncDate:obj->date andSectorID:obj->sectorID];
		[self reloadData];
	}
	//if (notifyTarget != nil && obj->sectorID == currCatID)
	if (notifyTarget != nil && obj->retCode == 0) // 可能傳 currCatID 子node商品 的 symbol sync 回來
	{
		[notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
	}
#ifdef GET_ALL_SECURITIES
	if (doGetAllSecurities && obj->retCode == 0)
	{
		[self getAllSecurities];
	}
#endif
	if (obj->retCode == 0 && obj->sectorID == autoFetingCatID) // autofetch next sector;
	{
		DataModalProc *dataModal = [DataModalProc getDataModal];
		[dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
	}
	
	[array removeAllObjects];
	[lock unlock];
}


- (void) addOneSecurity:(SymbolFormat1 *) obj
{
	char *sqliteQuery = NULL;
	int rc;
	BOOL modify = NO;
	char identCode[3];
	
	[lock lock];
    
	
	sqlite3 *database = DBOpen();
	//NSMutableArray *array = obj->dataArray;
	if ([obj isKindOfClass:[SymbolFormat1 class]])		// Add record
	{
        SymbolFormat1 * security1 = (SymbolFormat1 *)obj;
        
			// Accept all commodity
			//if (!(security1->typeID == TYPE_STOCK || security1->typeID == TYPE_INDEX || security1->typeID == TYPE_MARKET_INDEX
			//	|| security1->typeID == TYPE_FUTURE || security1->typeID == TYPE_CURRENCY))
			//	continue;
			identCode[0] = security1->IdentCode[0];
			identCode[1] = security1->IdentCode[1];
			identCode[2] = 0;
			
			NSLog(@"Add symbol:%@ (%@)",security1->symbol,security1->fullName);
			
#if 0 // Cannot process FullName with special character.
			sqliteQuery = sqlite3_mprintf("INSERT INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES ('%s','%s','%d','%s', '%d');",
										  identCode, [security1->symbol UTF8String], security1->typeID, [security1->fullName UTF8String], security1->sectorID);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);
			if (rc == SQLITE_CONSTRAINT) // 19 Exist.
			{
				sqliteQuery = sqlite3_mprintf("UPDATE Cat_FullName SET FullName = '%s', Type_id = '%d' WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';",
											  [security1->fullName UTF8String], security1->typeID, identCode, [security1->symbol UTF8String], security1->sectorID);
				rc = [mySQL exec:sqliteQuery withDB:database];
				sqlite3_free(sqliteQuery);
			}
#else
			sqlite3_stmt *statment = NULL;
			static const char *sql = "INSERT INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES (?,?,?,?,?)";
			sqlite3_prepare_v2(database, sql, -1, &statment, NULL);
			sqlite3_bind_text(statment, 1, identCode, -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statment, 2, [security1->symbol UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statment, 3, security1->typeID);
			sqlite3_bind_text(statment, 4, [security1->fullName UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statment, 5, security1->sectorID);
			int success = sqlite3_step(statment);
			sqlite3_finalize(statment);
			if (success == SQLITE_CONSTRAINT)
			{
				static const char *sql = "UPDATE Cat_FullName SET FullName = ?, Type_id = ? WHERE IdentCode = ? AND Symbol = ? AND SectorID = ?;";
				sqlite3_prepare_v2(database, sql, -1, &statment, NULL);
				sqlite3_bind_text(statment, 1, [security1->fullName UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(statment, 2, security1->typeID);
				sqlite3_bind_text(statment, 3, identCode, -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statment, 4, [security1->symbol UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(statment, 5, security1->sectorID);
				success = sqlite3_step(statment);
				sqlite3_finalize(statment);
			}
#endif
			// delete entry add for search where its sector_id = 0;
			sqliteQuery = sqlite3_mprintf("DELETE FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';",
										  identCode, [security1->symbol UTF8String], 0);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);
			modify = YES;
	}
	else if ([obj isKindOfClass:[SymbolFormat3 class]]) 	// Delete record
	{
        SymbolFormat3 * security3 = (SymbolFormat3 *)obj;

			identCode[0] = security3->IdentCode[0];
			identCode[1] = security3->IdentCode[1];
			identCode[2] = 0;
			
			NSLog(@"Delete symbol:%@",security3->symbol);
			
			sqliteQuery = sqlite3_mprintf("DELETE FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';",
										  identCode, [security3->symbol UTF8String], obj->sectorID);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);
			modify = YES;
		
	}
	
	DBClose();
	
	[lock unlock];
}

- (void) addOption:(OptionSymbolSyncIn *) obj
{
	char *sqliteQuery = NULL; 
	id arrayElement;
	int rc;
	BOOL modify = NO;
	char identCode[3];
	
	[lock lock];
	sqlite3 *database = DBOpen();	
	NSMutableArray *array = obj->dataArray;
	for (arrayElement in array)
	{
		// Add record
		if([arrayElement isKindOfClass:[SymbolFormat5 class]])
		{
			SymbolFormat5 *security = (SymbolFormat5 *) arrayElement;
            //往右shift 4bits 可以得到high bits
            UInt8 week = (security->month) >> 4;
            NSString *symbol = nil;
            
            //選擇權月份商品
            if (0 == week) {
                symbol = [[NSString alloc] initWithFormat:@"%@:%d:%02d",
                                    security->symbol, security->year % 10, security->month];
            }
            //選擇權短天期商品
            else {
                //跟00001111做AND可以得到low bits
                UInt8 month = security->month & 15;
                symbol = [[NSString alloc] initWithFormat:@"%@:%d:%02dW%d",
                                    security->symbol, security->year % 10, month, week];
            }
			
			identCode[0] = security->IdentCode[0];
			identCode[1] = security->IdentCode[1];
			identCode[2] = 0;
#if 0 // Cannot process FullName with special character.
			sqliteQuery = sqlite3_mprintf("INSERT INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES ('%s','%s','%d','%s', '%d');", 
										  identCode, [symbol UTF8String], TYPE_OPTION, [security->fullName UTF8String], obj->sectorID);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);
			if (rc == 19) // Exist.
			{
				sqliteQuery = sqlite3_mprintf("UPDATE Cat_FullName SET FullName = '%s', Type_id = '%d' WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';", 
											  [security->fullName UTF8String], TYPE_OPTION, identCode, [symbol UTF8String], obj->sectorID);
				rc = [mySQL exec:sqliteQuery withDB:database];
				sqlite3_free(sqliteQuery);
			}
			
			// delete entry add for search where its sector_id = 0;
			sqliteQuery = sqlite3_mprintf("DELETE FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';", 
										  identCode, [security->symbol UTF8String], 0);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);
			
#else
			sqlite3_stmt *statment = NULL;
			static const char *sql = "INSERT INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES (?,?,?,?,?)";
			sqlite3_prepare_v2(database, sql, -1, &statment, NULL); 
			sqlite3_bind_text(statment, 1, identCode, -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statment, 2, [symbol UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statment, 3, kCommodityTypeOption);
			sqlite3_bind_text(statment, 4, [security->fullName UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(statment, 5, obj->sectorID);
			int success = sqlite3_step(statment);
			sqlite3_finalize(statment);
			
			if (success == SQLITE_CONSTRAINT)  
			{
				static const char *sql = "UPDATE Cat_FullName SET FullName = ?, Type_id = ? WHERE IdentCode = ? AND Symbol = ? AND SectorID = ?;";
				sqlite3_prepare_v2(database, sql, -1, &statment, NULL); 
				sqlite3_bind_text(statment, 1, [security->fullName UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(statment, 2, kCommodityTypeOption);
				sqlite3_bind_text(statment, 3, identCode, -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statment, 4, [symbol UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(statment, 5, obj->sectorID);
				success = sqlite3_step(statment);
				sqlite3_finalize(statment);
			}
			// delete entry add for search where its sector_id = 0;
			sqliteQuery = sqlite3_mprintf("DELETE FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';", 
										  identCode, [security->symbol UTF8String], 0);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);
			
			
#endif			
			
			modify = YES;
			continue;
		}
		// Delete record
		else if([arrayElement isKindOfClass:[SymbolFormat6 class]])
		{
			SymbolFormat6 *security = (SymbolFormat6 *) arrayElement;
            //往右shift 4bits 可以得到high bits
            UInt8 week = (security->month) >> 4;
            NSString *symbol = nil;
            
            //選擇權月份商品
            if (0 == week) {
                symbol = [[NSString alloc] initWithFormat:@"%@:%d:%02d",
                          security->symbol, security->year % 10, security->month];
            }
            //選擇權短天期商品
            else {
                //跟00001111做AND可以得到low bits
                UInt8 month = security->month & 15;
                symbol = [[NSString alloc] initWithFormat:@"%@:%d:%02dW%d",
                          security->symbol, security->year % 10, month, week];
            }

			identCode[0] = security->IdentCode[0];
			identCode[1] = security->IdentCode[1];
			identCode[2] = 0;
			sqliteQuery = sqlite3_mprintf("DELETE FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';", 
										  identCode, [symbol UTF8String], obj->sectorID);
			rc = [mySQL exec:sqliteQuery withDB:database];
			sqlite3_free(sqliteQuery);
			modify = YES;
			continue;
		}
	}
	DBClose();
	[lock unlock];
	
	// Return Code 	0: Last data, 1: Continuous 
	if (modify && obj->retCode == 0)
	{
		[db_Date updateSyncDate:obj->date andSectorID:obj->sectorID];
		[self reloadData];
	}
	if (notifyTarget != nil && obj->sectorID == currCatID)
	{
		[notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
	}
#ifdef GET_ALL_SECURITIES
	if (doGetAllSecurities && obj->retCode == 0)
	{
		[self getAllSecurities];
	}
#endif
	if (obj->retCode == 0 && obj->sectorID == autoFetingCatID) // autofetch next sector;
	{
		DataModalProc *dataModal = [DataModalProc getDataModal];
		[dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
	}
	
	[array removeAllObjects];
}

- (void) addOptionWithArray:(id)security SectorID:(NSNumber *)sectorID
{
	char *sqliteQuery = NULL;
	int rc;
	BOOL modify = NO;
	char identCode[3];
	
	[lock lock];
	sqlite3 *database = DBOpen();
		// Add record
    if([security isKindOfClass:[SymbolFormat5 class]])
    {
        SymbolFormat5 *symbolData = (SymbolFormat5 *) security;
        //往右shift 4bits 可以得到high bits
        //UInt8 week = (symbolData->month) >> 4;
        //選擇權月份商品
//        if (0 == week) {
//            symbol = [[NSString alloc] initWithFormat:@"%@:%d:%02d",
//                      symbolData->symbol, symbolData->year % 10, symbolData->month];
//        }
//        //選擇權短天期商品
//        else {
//            //跟00001111做AND可以得到low bits
//            UInt8 month = symbolData->month & 15;
//            symbol = [[NSString alloc] initWithFormat:@"%@:%d:%02dW%d",
//                      symbolData->symbol, symbolData->year % 10, month, week];
//        }
        
        identCode[0] = symbolData->IdentCode[0];
        identCode[1] = symbolData->IdentCode[1];
        identCode[2] = 0;
#if 0 // Cannot process FullName with special character.
        sqliteQuery = sqlite3_mprintf("INSERT INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES ('%s','%s','%d','%s', '%d');",identCode, [symbolData->symbol UTF8String], TYPE_OPTION, [symbolData->fullName UTF8String],sectorID);
        rc = [mySQL exec:sqliteQuery withDB:database];
        sqlite3_free(sqliteQuery);
        if (rc == 19) // Exist.
        {
            sqliteQuery = sqlite3_mprintf("UPDATE Cat_FullName SET FullName = '%s', Type_id = '%d' WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';",
                                          [symbolData->fullName UTF8String], TYPE_OPTION, identCode, [symbolData->symbol UTF8String], sectorID);
            rc = [mySQL exec:sqliteQuery withDB:database];
            sqlite3_free(sqliteQuery);
        }
        
        // delete entry add for search where its sector_id = 0;
        sqliteQuery = sqlite3_mprintf("DELETE FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';",
                                      identCode, [security->symbol UTF8String], 0);
        rc = [mySQL exec:sqliteQuery withDB:database];
        sqlite3_free(sqliteQuery);
        
#else
        sqlite3_stmt *statment = NULL;
        static const char *sql = "INSERT INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES (?,?,?,?,?)";
        sqlite3_prepare_v2(database, sql, -1, &statment, NULL);
        sqlite3_bind_text(statment, 1, identCode, -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statment, 2, [symbolData->symbol UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statment, 3, kCommodityTypeStock);
        sqlite3_bind_text(statment, 4, [symbolData->fullName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statment, 5, [sectorID intValue]);
        int success = sqlite3_step(statment);
        sqlite3_finalize(statment);
        
        if (success == SQLITE_CONSTRAINT)
        {
            static const char *sql = "UPDATE Cat_FullName SET FullName = ?, Type_id = ? WHERE IdentCode = ? AND Symbol = ? AND SectorID = ?;";
            sqlite3_prepare_v2(database, sql, -1, &statment, NULL);
            sqlite3_bind_text(statment, 1, [symbolData->fullName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statment, 2, kCommodityTypeStock);
            sqlite3_bind_text(statment, 3, identCode, -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statment, 4, [symbolData->symbol UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statment, 5, [sectorID intValue]);
            success = sqlite3_step(statment);
            sqlite3_finalize(statment);
        }
        // delete entry add for search where its sector_id = 0;
        sqliteQuery = sqlite3_mprintf("DELETE FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';",
                                      identCode, [symbolData->symbol UTF8String], 0);
        rc = [mySQL exec:sqliteQuery withDB:database];
        sqlite3_free(sqliteQuery);
        
        
#endif
        
        modify = YES;
    }
    // Delete record
    else if([security isKindOfClass:[SymbolFormat6 class]])
    {
        SymbolFormat6 *symbolData = (SymbolFormat6 *) security;
        //往右shift 4bits 可以得到high bits
        //UInt8 week = (symbolData->month) >> 4;
//        NSString *symbol = nil;
//        
//        //選擇權月份商品
//        if (0 == week) {
//            symbol = [[NSString alloc] initWithFormat:@"%@:%d:%02d",
//                      symbolData->symbol, symbolData->year % 10, symbolData->month];
//        }
//        //選擇權短天期商品
//        else {
//            //跟00001111做AND可以得到low bits
//            UInt8 month = symbolData->month & 15;
//            symbol = [[NSString alloc] initWithFormat:@"%@:%d:%02dW%d",
//                      symbolData->symbol, symbolData->year % 10, month, week];
//        }
        
        identCode[0] = symbolData->IdentCode[0];
        identCode[1] = symbolData->IdentCode[1];
        identCode[2] = 0;
        sqliteQuery = sqlite3_mprintf("DELETE FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s' AND SectorID = '%d';",
                                      identCode, [symbolData->symbol UTF8String], sectorID);
        rc = [mySQL exec:sqliteQuery withDB:database];
        sqlite3_free(sqliteQuery);
        modify = YES;
    }
	DBClose();
	[lock unlock];
}

- (void) updateSecurityName:(SecurityName *) update
{
	char identCode[3];
	identCode[0] = update->identCode[0];
	identCode[1] = update->identCode[1];
	identCode[2] = 0;
	
	[lock lock];
	sqlite3 *database = DBOpen();	
	
	sqlite3_stmt *statment = NULL;
	static const char *sql = "UPDATE Cat_FullName SET FullName = ? WHERE IdentCode = ? AND Symbol = ?;";
	sqlite3_prepare_v2(database, sql, -1, &statment, NULL); 
	sqlite3_bind_text(statment, 1, [update->fullName UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statment, 2, identCode, -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statment, 3, [update->symbol UTF8String], -1, SQLITE_TRANSIENT);
	int success = sqlite3_step(statment);
	if (success != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to save type with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(statment);
	
	DBClose();
	
	[lock unlock];
}

- (void) addSecurityForSearch:(SecurityName *) add
{
	char identCode[3];
	UInt16 nSectorID =  0; // for Search, belong to unknown sector
	
	sqlite3 *database = DBOpen();	
	identCode[0] = add->identCode[0];
	identCode[1] = add->identCode[1];
	identCode[2] = 0;
#if 0 // Cannot process FullName with special character.
	int rc;
	char *  sqliteQuery  = NULL; 
	sqliteQuery = sqlite3_mprintf("INSERT INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES ('%s','%s','%d','%s','%d');", 
								  identCode, [add->symbol UTF8String], add->type_id, [add->fullName UTF8String], nSectorID);
	
	rc = [mySQL exec:sqliteQuery withDB:database];
	sqlite3_free(sqliteQuery);
#else
	sqlite3_stmt *statment = NULL;
	static const char *sql = "INSERT INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES (?,?,?,?,?)";
	if (sqlite3_prepare_v2(database, sql, -1, &statment, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_bind_text(statment, 1, identCode, -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statment, 2, [add->symbol UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(statment, 3, add->type_id);
	sqlite3_bind_text(statment, 4, [add->fullName UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(statment, 5, nSectorID);
	int success = sqlite3_step(statment);
	if (success != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to save type with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(statment);
#endif
	DBClose();
}

- (void) dealloc
{
	//	DBClose();
	[lock release];
	[dataCacheArray removeAllObjects];
	[dataCacheArray release];
	[db_Date release];
	[super dealloc];
}

- (SecurityName*) securityNameWithIdentCodeSymbol: (NSString*)aString
{
	SecurityName *node = [[[SecurityName alloc] init] autorelease];
   	char *  sqliteQuery  = NULL;
	sqlite3_stmt * stmt;
	int rc;
	
	if (!isDatabaseValid) return nil;
	
	[lock lock];
	sqlite3 *database = DBOpen();	
	sqliteQuery = sqlite3_mprintf("SELECT IdentCode, Symbol, Type_id, FullName FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s';",
								  [[aString substringWithRange:NSMakeRange(0,2)] UTF8String], [[aString substringFromIndex:3] UTF8String]);
	rc = sqlite3_prepare(database, sqliteQuery, -1, &stmt, NULL);
	if (rc != SQLITE_OK) goto error;
	if (sqlite3_step(stmt) == SQLITE_ROW)
	{
		memcpy(node->identCode, sqlite3_column_text(stmt, 0), 2);
        const unsigned char *tmpSymbol = sqlite3_column_text(stmt, 1);
        if (NULL != tmpSymbol) {
            node->symbol =  [[NSString alloc] initWithUTF8String:(char *)tmpSymbol];
        }
        else {
            node->symbol = @"";
        }
        
//		node->symbol =  [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 1)];
		node->type_id = sqlite3_column_int(stmt, 2) ;
        const unsigned char *tmpFullName = sqlite3_column_text(stmt, 3);
        if (NULL != tmpFullName) {
            node->fullName =  [[NSString alloc] initWithUTF8String:(char *)tmpFullName];
        }
        else {
            node->fullName = @"";
        }
//		node->fullName =  [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 3)];
		node->catID = currCatID;
	}
	else
		node = nil;
	sqlite3_finalize(stmt);
error:
	sqlite3_free(sqliteQuery);	
	DBClose();
	[lock unlock];
	return node;
}

- (NSMutableArray*) securityNameWithIdentCodeSymbols: (NSMutableArray*)array;
{
   	char *  sqliteQuery  = NULL;
	sqlite3_stmt * stmt;
	int rc;
	
	NSMutableArray *dataArray  = [[[NSMutableArray alloc] init] autorelease];
	[lock lock];
	sqlite3 *database = DBOpen();	
	for (NSString *aString in array)
	{
		sqliteQuery = sqlite3_mprintf("SELECT IdentCode, Symbol, Type_id, FullName FROM Cat_FullName WHERE IdentCode = '%s' AND Symbol = '%s';",
									  [[aString substringWithRange:NSMakeRange(0,2)] UTF8String], [[aString substringFromIndex:3] UTF8String]);
		rc = sqlite3_prepare(database, sqliteQuery, -1, &stmt, NULL);
		sqlite3_free(sqliteQuery);	
		if (rc != SQLITE_OK) break;
		if (sqlite3_step(stmt) == SQLITE_ROW)
		{
			SecurityName *node = [[SecurityName alloc] init];
			memcpy(node->identCode, sqlite3_column_text(stmt, 0), 2);
			node->symbol =  [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 1)];
			node->type_id = sqlite3_column_int(stmt, 2) ;
			node->fullName =  [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 3)];
			node->catID = 0;
			[dataArray addObject:node];
			[node release];
		}
		sqlite3_finalize(stmt);
	}
	DBClose();
	[lock unlock];
	return dataArray;
}

#ifdef GET_ALL_SECURITIES
- (void) getAllSecurities
{
	// For Internal use only.
	static NSMutableArray *catArray = nil;
	static int nextCategory = 0;
	
	doGetAllSecurities = YES;
	if (catArray == nil)
	{
		DataModalProc *dataModal = [DataModalProc getDataModal];
		catArray = [dataModal.category getAllLeafCategories];
		nextCategory = 0;
		if (catArray == nil)
			return;
	}
	if (nextCategory >= [catArray count])
	{
		[catArray release];
		catArray = nil;
		doGetAllSecurities = NO;
		return;
	}
	UInt16 nCatID = [((NSNumber *) [catArray objectAtIndex:nextCategory]) intValue];
	[self requestCatID: nCatID];
	nextCategory++;
}
#endif

//- (void) localSearch:(NSString*)keyword groupID:(UInt16)groupID
- (void) localSearch:(SearchParam*) obj;
{
	DataModalProc *dataModal = [DataModalProc getDataModal];
	NSMutableArray *searchResult = [[NSMutableArray alloc] init];
	int catIDCount;
	
	catIDCount = obj->idCount;
	
	char *  sqliteQuery  = NULL;
	sqlite3_stmt * stmt;
	int rc;
	NSMutableArray* arrGroup = [[NSMutableArray alloc] init];
	//	UInt16 groups[320];
	int groupCount = 0;
	
	if(!isDatabaseValid)
	{
		[searchResult release];
		return;
	}
	
	[lock lock];
	UInt16 catID;
	int count1;
	if(!obj->bsearchIdenCode)
	{
		for(int x=0; x<catIDCount; x++)
		{
			catID = obj->targetID[x];
			[dataModal.category getLeafCatIDs:arrGroup catID:catID];
		}
		count1 = groupCount = [arrGroup count];
	}
	else
	{
		count1 = obj->idCount;
	}
	sqlite3 *database = DBOpen();	
	NSString* strQuery = [[NSString alloc] initWithString:@"SELECT IdentCode, Symbol, Type_id, FullName, SectorID FROM Cat_FullName where"];

	//串sector id 或 iden code
	strQuery = [strQuery stringByAppendingString:@" ("];  
	for(int i=0; i<count1; i++)  
	{
		NSString* temp;
		if(obj->bsearchIdenCode)  
		{
			char* idCode = (char*)(int)obj->targetID[i];
			if(i == count1-1)
			{
				temp = [NSString stringWithFormat:@"IdentCode = '%c%c'", idCode[0], idCode[1]];
			}
			else
			{
				temp = [NSString stringWithFormat:@"IdentCode = '%c%c' OR ", idCode[0], idCode[1]];
			}
		}
		else
		{
			if(i == count1-1)
			{
				SectorID* sectorID = [arrGroup objectAtIndex:i];
				temp = [NSString stringWithFormat:@"SectorID = '%d'", sectorID.group];
			}
			else
			{
				SectorID* sectorID = [arrGroup objectAtIndex:i];
				temp = [NSString stringWithFormat:@"SectorID = '%d' OR ", sectorID.group];
			}
		}
		
		strQuery = [strQuery stringByAppendingFormat:@"%@",temp];
		
	}	
	strQuery = [strQuery stringByAppendingString:@") AND"];
	
	//NSLog(strQuery);
	// stock type_ID
	strQuery = [strQuery stringByAppendingString:@" ("];  
	for(int i=0; i<obj->typeCount; i++)
	{
		NSString* temp;
		if(i == obj->typeCount-1)
		{
			temp = [NSString stringWithFormat:@"Type_id = '%d'", obj->targetType[i]];
		}
		else
		{
			temp = [NSString stringWithFormat:@"Type_id = '%d' OR ", obj->targetType[i]];
		}
		strQuery = [strQuery stringByAppendingFormat:@"%@",temp];
	}
	
	strQuery = [strQuery stringByAppendingString:@") AND"];
//	NSLog(strQuery);
	strQuery = [strQuery stringByAppendingString:@" ("];  
	if(obj->field_Type == 0) // search symbol
	{
		NSString* temp;
		if(obj->search_Type == 0)  //begin
		{
			temp = [NSString stringWithFormat:@"Symbol like '%@%%'", obj->keyword];
		}
		else if(obj->search_Type == 1) // contain
		{
			temp = [NSString stringWithFormat:@"Symbol like '%%%@%%'", obj->keyword];
		}
		else if(obj->search_Type == 2) // match
		{
			temp = [NSString stringWithFormat:@"Symbol = '%@'", obj->keyword];
		}
		strQuery = [strQuery stringByAppendingFormat:@"%@",temp];
	}
	else if(obj->field_Type == 1) // search fullname
	{
		NSString* temp;
		if(obj->search_Type == 0)  //begin
		{
			temp = [NSString stringWithFormat:@"FullName like '%@%%'", obj->keyword];
		}
		else if(obj->search_Type == 1) // contain
		{
			temp = [NSString stringWithFormat:@"FullName like '%%%@%%'", obj->keyword];
		}
		else if(obj->search_Type == 2) // match
		{
			temp = [NSString stringWithFormat:@"FullName = '%@'", obj->keyword];
		}
		strQuery = [strQuery stringByAppendingFormat:@"%@",temp];
	}
	else if(obj->field_Type == 2) // symbol/fullname
	{
		NSString* temp;
		if(obj->search_Type == 0)  //begin
		{
			temp = [NSString stringWithFormat:@"Symbol like '%@%%' OR FullName like '%@%%'", obj->keyword, obj->keyword];
		}
		else if(obj->search_Type == 1) // contain
		{
			temp = [NSString stringWithFormat:@"Symbol like '%%%@%%' OR FullName like '%%%@%%'", obj->keyword, obj->keyword];
		}
		else if(obj->search_Type == 2) // match
		{
			temp = [NSString stringWithFormat:@"Symbol = '%@' OR FullName = '%@'", obj->keyword, obj->keyword];
		}
		strQuery = [strQuery stringByAppendingFormat:@"%@",temp];
		
	}
	strQuery = [strQuery stringByAppendingString:@")"];
	sqliteQuery = sqlite3_mprintf("%s",[strQuery UTF8String]);
	rc = sqlite3_prepare(database, sqliteQuery, -1, &stmt, NULL);
	sqlite3_free(sqliteQuery);	
	if (rc != SQLITE_OK) 
	{
		DBClose();
		[lock unlock];
		[searchResult release];
		return;
	}
	int count = 0;
	while (sqlite3_step(stmt) == SQLITE_ROW)
	{
		count++;
		NSString *symbol;
		char *checkString = (char*)sqlite3_column_text(stmt, 1);
		if(checkString)
			symbol = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 1)];
		else
			symbol = [[NSString alloc] initWithString:@""];
		NSString *fullName;
		checkString = (char*)sqlite3_column_text(stmt, 3);
		if(checkString)
			fullName = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 3)];
		else
			fullName = [[NSString alloc] initWithString:@""];
		UInt16 catID = sqlite3_column_int(stmt, 4);
		UInt16 type_id = sqlite3_column_int(stmt, 2);
		SecurityName *node = [[SecurityName alloc] init];
		memcpy(node->identCode, sqlite3_column_text(stmt, 0), 2);
		node->symbol = symbol;
		node->fullName =  fullName;
		node->type_id = type_id;
		node->catID = catID;  // category = 0 means search result;
		[searchResult addObject: node];
		[node release];
		
		if(count >= MAX_COUNT)
			break;
	}		
	sqlite3_finalize(stmt);
	DBClose();
 
	/*
	//NSAssert(groupCount <= sizeof(groups)/sizeof(UInt16), @"Out of bounds(groups).");
	sqlite3 *database = DBOpen();	
	sqliteQuery = sqlite3_mprintf("SELECT IdentCode, Symbol, Type_id, FullName, SectorID  FROM Cat_FullName ");
	rc = sqlite3_prepare(database, sqliteQuery, -1, &stmt, NULL);
	sqlite3_free(sqliteQuery);	
	if (rc != SQLITE_OK) 
	{
		DBClose();
		[lock unlock];
		[searchResult release];
		return;
	}
	
	while (sqlite3_step(stmt) == SQLITE_ROW)
	{
		UInt16 catID = sqlite3_column_int(stmt, 4);
		//		if (obj->groupID != 0)
		{
			BOOL found = NO;
			for (int i = 0; i < groupCount; i++)
			{
				SectorID* sectorID = [arrGroup objectAtIndex:i];
				UInt16 groupID = sectorID.group;
				if (groupID == catID) 
				{
					found = YES;
					break;
				}
			}
			if (!found) continue;
		}
		UInt16 type_id = sqlite3_column_int(stmt, 2);
		if (obj->type == SECURITY_TYPE || obj->type == IMPORTANT_TYPE)
		{
			if (!(type_id == kCommodityTypeStock || type_id == kCommodityTypeIndex || type_id == kCommodityTypeMarketIndex
				  || type_id == kCommodityTypeWarrant || type_id == kCommodityTypeFuture || type_id == kCommodityTypeETF
				  || type_id == kCommodityTypeCurrency))
				continue;
		}
		else if (obj->type == OPTION_TYPE)
		{
			if (!(type_id == kCommodityTypeOption))
				continue;
		}
		else if (obj->type == TWFUTURE_TYPE)
		{
			if (!(type_id == kCommodityTypeFuture))
				continue;
		}
		else if (obj->type == TWSTOCK_TYPE)
		{
			char identCode[2];
			if (!(type_id == kCommodityTypeStock || type_id == kCommodityTypeETF || type_id == kCommodityTypeWarrant))
				continue;
			memcpy(identCode, sqlite3_column_text(stmt, 0), 2);
			if (!(identCode[0] == 'T' && identCode[1] == 'W'))
				continue;
		}
		else if(obj->type == CNSTOCK_TYPE)
		{
			if (!(type_id == kCommodityTypeStock))
				continue;
		}
		else if(obj->type == CORRELATION_TYPE)
		{
			if (!(type_id == kCommodityTypeStock || type_id == kCommodityTypeIndex || type_id == kCommodityTypeMarketIndex
				  || type_id == kCommodityTypeWarrant || type_id == kCommodityTypeFuture || type_id == kCommodityTypeETF
				  || type_id == kCommodityTypeCurrency))
				continue;
		}
		NSString *symbol;
		char *checkString = (char*)sqlite3_column_text(stmt, 1);
		if(checkString)
			symbol = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 1)];
		else
			symbol = [[NSString alloc] initWithString:@""];
		NSString *fullName;
		checkString = (char*)sqlite3_column_text(stmt, 3);
		if(checkString)
			fullName = [[NSString alloc] initWithUTF8String: (char *) sqlite3_column_text(stmt, 3)];
		else
			fullName = [[NSString alloc] initWithString:@""];
		rangeSymbol.length = rangeFullName.length = 0;
		if ([symbol length] >= [obj->keyword length])
			rangeSymbol = [symbol rangeOfString:obj->keyword options:NSCaseInsensitiveSearch];
		if ([fullName length] >= [obj->keyword length])
			rangeFullName = [fullName rangeOfString:obj->keyword options:NSCaseInsensitiveSearch];
#if 0  // begins with
		if ((range.location != rangeSymbol.location || range.length != rangeSymbol.length) 
			&& (range.location != rangeFullName.location || range.length != rangeFullName.length))
#else // contains
			if ((range.length != rangeSymbol.length) 
				&& (range.length != rangeFullName.length))
#endif
			{
				[symbol release];
				[fullName release];
				continue;
			}
		
		SecurityName *node = [[SecurityName alloc] init];
		memcpy(node->identCode, sqlite3_column_text(stmt, 0), 2);
		node->symbol = symbol;
		node->fullName =  fullName;
		node->type_id = type_id;
		node->catID = 0;  // category = 0 means search result;
		[searchResult addObject: node];
		[node release];
		if (count++ >= MAX_COUNT) break;
	}
	sqlite3_finalize(stmt);
	DBClose();
	 */
	[lock unlock];
	[arrGroup removeAllObjects];
	[arrGroup release];
	

	
	[dataModal.securitySearch addLocalSearch:obj->keyword Result:searchResult];
	[searchResult release];
	
}

- (int) progress
{
	if (totalToFetch == 0)
		return 100;
	return fetching * 100 / totalToFetch;
}

- (int) autofetch
{
	if (autofetchArray == nil)
	{
		DataModalProc *dataModal = [DataModalProc getDataModal];
		autofetchArray = [dataModal.category getAllLeafCategories];
		if (autofetchArray == nil)  // some error.
			return -1;
		totalToFetch = [autofetchArray count];
		fetching = 0;
	}
	DB_Date *treeDate = [[DB_Date alloc] initWithTableName:MSIC_SYNCDATE_TABLE];
	UInt16 nTreeDate = [treeDate getSyncDate: SYNCDATE_CATTREE];
	[treeDate release];
next:
	if ([autofetchArray count] == 0)  // finished.
	{
		[autofetchArray release];
		autofetchArray = nil;
		autoFetingCatID = 0xFFFF;
		return 0;
	}
	UInt16 nCatID = [((NSNumber *) [autofetchArray objectAtIndex:0]) intValue];
	[autofetchArray removeObjectAtIndex:0];
	fetching++;
	UInt16 nSyncDate = [db_Date getSyncDate:nCatID];
	if (nTreeDate < nSyncDate || nTreeDate - nSyncDate < 2) // need not sync
		goto next;
	NSLog(@"AutoFetch Security name at sector %d. ", nCatID);
	autoFetingCatID = nCatID;
	[self requestCatID: nCatID];
	return 1;
}

@end
