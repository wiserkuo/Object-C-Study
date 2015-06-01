//
//  SecurityName.m
//  FonestockPower
//
//  Created by Neil on 14/4/22.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "SecurityName.h"
#import "OptionSymbolSyncOut.h"
#import "SymbolSyncOut.h"
#import "SymbolSyncIn.h"
#import "OptionSymbolSyncIn.h"
#import "Commodity.h"

BOOL doGetAllSecurities = YES;

@implementation SecurityName

@end


@implementation SecurityNameData


- (SecurityNameData*) init
{
	self = [super init];
	if (self)
	{
		lock = [[NSRecursiveLock alloc] init];
		notifyTarget = nil;
		currCatID = 0;
		isDatabaseValid = NO;
		dataCacheArray  = [[NSMutableArray alloc] init];
		autofetchArray = nil;
		autoFetingCatID = 0xFFFF;
		
		replaceMarkUpArray = [[NSMutableArray alloc]init];
	}
	return self;
}


- (SecurityName*) securityNameWithIdentCodeSymbol: (NSString*)aString
{
    [lock lock];
    __block SecurityName *node = [[SecurityName alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT IdentCode, Symbol, Type_id, FullName FROM Cat_FullName WHERE IdentCode = ? AND Symbol = ?",[aString substringWithRange:NSMakeRange(0,2)], [aString substringFromIndex:3]];
        while ([message next]) {
            node->identCode[0] = [[message stringForColumn:@"IdentCode"] characterAtIndex:0];
            node->identCode[1] = [[message stringForColumn:@"IdentCode"] characterAtIndex:1];
            node->symbol = [message stringForColumn:@"Symbol"];
            node->type_id = [message intForColumn:@"Type_id"];
            node->fullName = [message stringForColumn:@"FullName"];
        }
    }];
    
    node->catID = currCatID;
	
	[lock unlock];
	return node;
}

- (NSMutableArray*) securityNameWithIdentCodeSymbols: (NSMutableArray*)array;
{
    
    [lock lock];
    NSMutableArray *dataArray  = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        for (int i=0; i<[array count]; i++) {
            SecurityName *node = [[SecurityName alloc] init];
            NSString *aString = [array objectAtIndex:i];
            FMResultSet *message = [db executeQuery:@"SELECT IdentCode, Symbol, Type_id, FullName FROM Cat_FullName WHERE IdentCode = ? AND Symbol = ?",[aString substringWithRange:NSMakeRange(0,2)], [aString substringFromIndex:3]];
            while ([message next]) {
                node->identCode[0] = [[message stringForColumn:@"IdentCode"] characterAtIndex:0];
                node->identCode[1] = [[message stringForColumn:@"IdentCode"] characterAtIndex:1];
                node->symbol = [message stringForColumn:@"Symbol"];
                node->type_id = [message intForColumn:@"Type_id"];
                node->fullName = [message stringForColumn:@"FullName"];
                node->catID = 0;
            }
            [dataArray addObject:node];
        }
        
    }];
    
    
	
	[lock unlock];
	return dataArray;
}

- (void) addOneSecurity:(SymbolFormat1 *) obj
{
    [lock lock];
    char identCode[2];
    if (obj->sectorID != 0) {
        NSLog(@"Add symbol:%c%c %@ (%@)", obj -> IdentCode[0], obj -> IdentCode[1], obj->symbol,obj->fullName);
        
        identCode[0] = obj->IdentCode[0];
        identCode[1] = obj->IdentCode[1];
        NSString * identStr = [NSString stringWithFormat:@"%c%c",obj->IdentCode[0],obj->IdentCode[1]];
        
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        FSDatabaseAgent *dbAgent = dataModel.mainDB;
        __block int count =0;
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            
            FMResultSet *message = [db executeQuery:@"SELECT count(*) AS count FROM Cat_FullName WHERE IdentCode = ? AND Symbol = ? AND SectorID = ?",identStr,obj->symbol,[NSNumber numberWithUnsignedInt:obj->sectorID]];
            while ([message next]) {
                count = [message intForColumn:@"count"];
            }
            
            if (count!=0) {
                [db executeUpdate:@"UPDATE Cat_FullName SET Type_id= ?,FullName = ? WHERE IdentCode = ? AND Symbol = ? AND SectorID = ?",[NSNumber numberWithUnsignedInt:obj->typeID],obj->fullName,identStr,obj->symbol,[NSNumber numberWithUnsignedInt:obj->sectorID]];
            }else{
                [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode, Symbol, Type_id, FullName, SectorID) VALUES(?,?,?,?,?)",identStr,obj->symbol,[NSNumber numberWithUnsignedInt:obj->typeID],obj->fullName,[NSNumber numberWithUnsignedInt:obj->sectorID]];
            }
        }];
    }
    
    [lock unlock];
}


- (void) setTarget: (NSObject*) obj
{
	notifyTarget = obj;
}

- (void) selectCatID: (UInt16) catID
{
	if (currCatID == catID) return;
	currCatID = catID;
	[self getData];
    [self requestCatID: catID];
}

- (void) getData
{
	[lock lock];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
	[dataCacheArray removeAllObjects];
    __block int currentNodeLeafType =1;
    // find current nodeID leafType.
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT Leaf from category where catID = ?",[NSNumber numberWithUnsignedInt:currCatID]];
        while ([message next]) {
            currentNodeLeafType = [message intForColumn:@"Leaf"];
        }
        
    }];
	

	int catID = currCatID;
	
	if(currentNodeLeafType==2)
	{
		// special leaf:
        
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            
            FMResultSet *message = [db executeQuery:@"select IdentCode, Symbol, Type_id, FullName, SectorID from cat_fullName where sectorID in (SELECT catID from category where ParentID = ?)", [NSNumber numberWithUnsignedInt:currCatID]];
             // 1:formal leaf 3:special leaf(the leaf is aslo contain identcode symbol leaf)
            while ([message next]) {
                SecurityName * node = [[SecurityName alloc] init];
                node->identCode[0] = (char)[[message stringForColumn:@"Leaf"] substringToIndex:1];
                node->identCode[1] = (char)[[message stringForColumn:@"Leaf"] substringFromIndex:1];
                node->symbol = [message stringForColumn:@"Symbol"];
                node->type_id = [message intForColumn:@"Type_id"];
                node->fullName = [message stringForColumn:@"FullName"];
                node->catID = [message intForColumn:@"SectorID"];
                [dataCacheArray addObject: node];
            }
            
        }];
		
	}else{
		
		// normal leaf:
        NSString * sqlStr = @"";
		
		if(catID == 754) //美國ADR要用server下來的順序做排序
			sqlStr = @"SELECT IdentCode, Symbol, Type_id, FullName  FROM Cat_FullName where SectorID = ? Order By rowid ASC";
		else if(catID == 958) // 港股指數要用server下來的順序做排序
			sqlStr = @"SELECT IdentCode, Symbol, Type_id, FullName  FROM Cat_FullName where SectorID = ? Order By rowid ASC";
#if defined (BROKER_YUANTA)
		else if(catID == 51 || catID == 52) // 期貨近一  近二 要用server下來的順序做排序
			sqlStr = @"SELECT IdentCode, Symbol, Type_id, FullName  FROM Cat_FullName where SectorID = ? Order By rowid ASC";
#endif
		else
			sqlStr = @"SELECT IdentCode, Symbol, Type_id, FullName  FROM Cat_FullName where SectorID = ?";
        
        
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            
            FMResultSet *message = [db executeQuery:sqlStr, [NSNumber numberWithInt:currCatID]];
            while ([message next]) {
                SecurityName * node = [[SecurityName alloc] init];
                node->identCode[0] = (char)[[message stringForColumn:@"IdentCode"] substringToIndex:1];
                node->identCode[1] = (char)[[message stringForColumn:@"IdentCode"] substringFromIndex:1];
                node->symbol = [message stringForColumn:@"Symbol"];
                node->type_id = [message intForColumn:@"Type_id"];
                node->fullName = [message stringForColumn:@"FullName"];
                node->catID = catID;
                [dataCacheArray addObject: node];
            }
            
        }];
		
	}
	
	
	[lock unlock];
}

-(void)clearCurrID
{
    currCatID = 0;
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
			break;
		}
		default:
			break;
	}
}


- (void) requestCatID: (UInt16) catID
{
	
	[lock lock];
	
	// find current nodeID leafType.
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block int currentNodeLeafType =1;
    // find current nodeID leafType.
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT Leaf from category where catID = ?", [NSNumber numberWithUnsignedInt:catID]];
        while ([message next]) {
            currentNodeLeafType = [message intForColumn:@"Leaf"];
        }
        
    }];
    
	
	// request for special leaf node
	if(currentNodeLeafType==2)
	{
		// 由 sectorID parent node request special leaf 商品
		__block UInt16 catType = 0;
        __block int myCatID = 0;
		// special leaf:
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            
            FMResultSet *message = [db executeQuery:@"SELECT catID from category where ParentID = ?", [NSNumber numberWithUnsignedInt:catID]];
            while ([message next]) {
                myCatID = [message intForColumn:@"catID"];
                catType = [dataModel.category getCatType:myCatID];
            }
            
        }];

        if (catType & 32) // option
        {
            UInt16 nSyncDate = [self getSyncDate:myCatID];
            
            OptionSymbolSyncOut *packet = [[OptionSymbolSyncOut alloc] initWithSectorID: myCatID Date:nSyncDate];
            [FSDataModelProc sendData:self WithPacket:packet];
        }else
        {
            UInt16 nSyncDate = [self getSyncDate:myCatID];
            
            
            SymbolSyncOut *packet = [[SymbolSyncOut alloc] initWithSectorID_SyncDate: myCatID syncDate:nSyncDate];
            [FSDataModelProc sendData:self WithPacket:packet];
            
        }
    }
	else{
		
		UInt16 catType = [dataModel.category getCatType:catID];
		// bit 1:news, bit2:stock, bit3:warrant, bit4:index, bit5:future, bit6:option, bit7:forex. bit8~16:reserved
		if (catType & 32) // option
		{
			UInt16 nSyncDate = [self getSyncDate:catID];
			OptionSymbolSyncOut *packet = [[OptionSymbolSyncOut alloc] initWithSectorID: catID Date:nSyncDate];
			[FSDataModelProc sendData:self WithPacket:packet];
		}
		else
		{
            UInt16 nSyncDate = [self getSyncDate:catID];
            SymbolSyncOut *packet = [[SymbolSyncOut alloc] initWithSectorID_SyncDate: catID syncDate:nSyncDate];
			[FSDataModelProc sendData:self WithPacket:packet];
		}
		
		
	}
	
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

- (void) addSecurity:(SymbolSyncIn *) obj
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;

	__block BOOL modify = NO;
	
	[lock lock];
	
	NSMutableArray *array = obj->dataArray;
	if (obj->syncType == 0)		// Add record
	{
        [dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (SymbolFormat1 *security1 in array) {
                NSLog(@"Add symbol:%@ (%@)",security1->symbol,security1->fullName);
                
                BOOL success = [db executeUpdate:@"REPLACE INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES (?,?,?,?,?)",[NSString stringWithFormat:@"%c%c",security1->IdentCode[0],security1->IdentCode[1]],security1->symbol,[NSNumber numberWithUnsignedInt:security1->typeID],security1->fullName,[NSNumber numberWithUnsignedInt:obj->sectorID]];
                if (!success) {
                    *rollback = YES;
                    return;
                }
                
                BOOL success2 = [db executeUpdate:@"DELETE FROM Cat_FullName WHERE IdentCode = ? AND Symbol = ? AND SectorID = ?",[NSString stringWithFormat:@"%c%c",security1->IdentCode[0],security1->IdentCode[1]],security1->symbol,[NSNumber numberWithInt:0]];
                if(!success2){
                    *rollback = YES;
                    return;
                }
                modify = YES;
            }
        }];
	}
	else if (obj->syncType == 1) 	// Delete record
	{
        [dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for(SymbolFormat3 * security3 in array){
                NSLog(@"Delete symbol:%@",security3->symbol);
                BOOL success = [db executeUpdate:@"DELETE FROM Cat_FullName WHERE IdentCode = ? AND Symbol = ? AND SectorID = ?",[NSString stringWithFormat:@"%c%c",security3->IdentCode[0],security3->IdentCode[1]],security3->symbol,[NSNumber numberWithUnsignedInt:obj->sectorID]];
                if(!success){
                    *rollback = YES;
                    return;
                }
                modify = YES;
            }
        }];
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
            
            [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                
                [db executeUpdate:@"DELETE FROM Cat_FullName WHERE SectorID = ?",obj->sectorID];
                
            }];
			
			//replaceMarkUpArray;
			[replaceMarkUpArray addObject:[NSNumber numberWithInt:obj->sectorID]];
			
		}
		else
		{
			NSLog(@" ---  Exist  --- ");
		}
        
        [ dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (SymbolFormat1 *security1 in array){
                NSLog(@"Replace %@-%@",security1->symbol,security1->fullName);
                BOOL success = [db executeUpdate:@"REPLACE INTO Cat_FullName (IdentCode, Symbol, Type_id, FullName, SectorID) VALUES (?,?,?,?,?)",[NSString stringWithFormat:@"%c%c",security1->IdentCode[0],security1->IdentCode[1]],security1->symbol,[NSNumber numberWithUnsignedInt:security1->typeID],security1->fullName,[NSNumber numberWithUnsignedInt:obj->sectorID]];
                if(!success){
                    *rollback = YES;
                    return;
                }
                modify = YES;
            }
        }];
		
		if (modify && obj->retCode == 0)
		{
			[replaceMarkUpArray removeAllObjects];
		}
		
	}
	
	// Return Code 	0: Last data, 1: Continuous
	if (modify && obj->retCode == 0)
	{
		[self updateSyncDate:obj->date andSectorID:obj->sectorID];
		[self getData];
	}
	if (notifyTarget != nil && obj->retCode == 0) // 可能傳 currCatID 子node商品 的 symbol sync 回來
	{
		[notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
	}
	if (doGetAllSecurities && obj->retCode == 0)
	{
//		[self getAllSecurities];
	}
//	if (obj->retCode == 0 && obj->sectorID == autoFetingCatID) // autofetch next sector;
//	{
//		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//		[dataModal.autoFetchManager performSelector:@selector(autofetch) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
//	}
	
	[array removeAllObjects];
	[lock unlock];
}

- (void) updateSyncDate: (UInt16) syncDate  andSectorID: (UInt16) sectorID
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL success = [db executeUpdate:@"REPLACE INTO Misc_SyncDate (SectorID, SyncDate) VALUES (?,?)",[NSNumber numberWithUnsignedInt:sectorID],[NSNumber numberWithUnsignedInt:syncDate]];
        if(!success){
            *rollback = YES;
            return;
        }
    }];
}

- (void) getAllSecurities
{
	// For Internal use only.
	static NSMutableArray *catArray = nil;
	static int nextCategory = 0;
	
	doGetAllSecurities = YES;
	if (catArray == nil)
	{
		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
		catArray = [dataModal.category getAllLeafCategories];
		nextCategory = 0;
		if (catArray == nil)
			return;
	}
	if (nextCategory >= [catArray count])
	{
		catArray = nil;
		doGetAllSecurities = NO;
		return;
	}
	UInt16 nCatID = [((NSNumber *) [catArray objectAtIndex:nextCategory]) intValue];
	[self requestCatID: nCatID];
	nextCategory++;
}


//Option
-(NSMutableArray *)searchGoods{
    [lock lock];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT substr(FullName, 1, length(FullName)-2) AS GroupFullName, substr(Symbol, 1, 3) AS GroupSymbol FROM Cat_FullName WHERE SectorID = '19' OR SectorID = '20'Group By GroupFullName Order By SectorID"];
        while ([message next]) {
            NSString *groupFullName = [message stringForColumn:@"GroupFullName"];
            NSString *groupSymbol = [message stringForColumn:@"GroupSymbol"];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:groupFullName, @"groupFullName", groupSymbol, @"groupSymbol", nil];
            [dataArray addObject:dict];
        }
    }];
    
    [lock unlock];
    return dataArray;
}

-(NSMutableArray *)searchMonthsWithFullName:(NSString *)fullName{
    [lock lock];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT substr(FullName, 1, length(FullName)-2) AS NewFullName, substr(FullName, length(FullName)-1, 2) AS Month, substr(identCode||' '||Symbol, 0, 6) AS IdentCodeSymbol, substr(Symbol, 5,2) AS MesYear, substr(Symbol, 7-length(Symbol), 4) AS MesMonth  FROM Cat_FullName Where NewFullName = ? Order By Symbol AND Month", fullName];
        while ([message next]) {
            NSString *newFullName = [message stringForColumn:@"NewFullName"];
            NSString *month = [message stringForColumn:@"Month"];
            NSString *identCodeSymbol = [message stringForColumn:@"IdentCodeSymbol"];
            NSString *mesYear = [message stringForColumn:@"MesYear"];
            NSString *mesMonth = [message stringForColumn:@"MesMonth"];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:newFullName, @"newFullName", month, @"month", identCodeSymbol, @"identCodeSymbol", mesYear, @"mesYear", mesMonth, @"mesMonth", nil];
            [dataArray addObject:dict];
        }
    }];
    [lock unlock];
    return dataArray;
}

- (void) addOption:(OptionSymbolSyncIn *) obj
{
	id arrayElement;
	BOOL modify = NO;
	[lock lock];
    NSMutableArray *array = obj->dataArray;
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
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
                          security->symbol, security->year, security->month];
            }
            //選擇權短天期商品
            else {
                //跟00001111做AND可以得到low bits
                UInt8 month = security->month & 15;
                symbol = [[NSString alloc] initWithFormat:@"%@:%d:%02dW%d",
                          security->symbol, security->year, month, week];
            }
            NSString *identCode = [NSString stringWithFormat:@"%c%c", security->IdentCode[0], security->IdentCode[1]];
            
            [ dbAgent  inDatabase: ^ ( FMDatabase  * db ) {
                [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode, Symbol, Type_id, FullName, SectorID) VALUES(?, ?, ?, ?, ?)", identCode, symbol, [NSNumber numberWithInt:kCommodityTypeOption], security->fullName, [NSNumber numberWithInt:obj->sectorID]];
                
            }];
            
            NSLog(@"insert %@, %@", identCode, symbol);
            [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                    [db executeUpdate:@"UPDATE Cat_FullName SET FullName = ?, Type_id = ? WHERE IdentCode = ? AND Symbol = ? AND SectorID = ?", security->fullName, [NSNumber numberWithInt:kCommodityTypeOption], identCode, symbol, [NSNumber numberWithUnsignedInt:obj->sectorID]];
            }];
                // delete entry add for search where its sector_id = 0;
            [ dbAgent  inDatabase: ^ ( FMDatabase  * db ) {
                [db executeUpdate:@"DELETE FROM Cat_FullName WHERE IdentCode = ? AND Symbol = ? AND SectorID = ?", identCode, security->symbol, @"0"];
            }];
            
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
                          security->symbol, security->year, security->month];
            }
            //選擇權短天期商品
            else {
                //跟00001111做AND可以得到low bits
//                UInt8 month = security->month & 15;
                symbol = [[NSString alloc] initWithFormat:@"%@:%d:%02d",
                          security->symbol, security->year, security->month];
            }
            NSString *identCode = [NSString stringWithFormat:@"%c%c", security->IdentCode[0], security->IdentCode[1]];
            
            [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                [db executeUpdate:@"DELETE FROM Cat_FullName WHERE IdentCode = ? AND Symbol = ? AND SectorID = ?", identCode, symbol, [NSNumber numberWithInt:obj->sectorID]];
            }];
            NSLog(@"delete %@, %@", identCode, symbol);
			modify = YES;
			continue;
		}
	}
	[lock unlock];
    
	// Return Code 	0: Last data, 1: Continuous
	if (modify && obj->retCode == 0)
	{
		[self updateSyncDate:obj->date andSectorID:obj->sectorID];
		[self getData];
	}
	if (notifyTarget != nil && obj->sectorID == currCatID)
	{
		[notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
	}
	if (doGetAllSecurities && obj->retCode == 0)
	{
//		[self getAllSecurities];
	}
	[array removeAllObjects];
}



@end
