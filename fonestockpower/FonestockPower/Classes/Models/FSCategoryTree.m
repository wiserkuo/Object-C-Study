//
//  FSCategoryTree.m
//  FonestockPower
//
//  Created by Connor on 14/4/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSCategoryTree.h"
#import "SectorTableOut.h"
#import "SectorTableIn.h"
#import "SymbolSectorIdOut.h"
#import "FSEquityDrawViewController.h"
#import "RealtimeListController.h"
#import "FSPriceByVolumeTableViewController.h"
#import "FSNewPriceByVolumeViewController.h"

#define SYNCDATE_CATTREE       2

@implementation CategoryNode
@end

@interface FSCategoryTree() {
    CategoryNode *currNode;
    NSMutableArray *catArray;
}

@end

@implementation FSCategoryTree

- (instancetype)init {
    if (self = [super init]) {
        [self initDatabase];
        catArray  = [[NSMutableArray alloc] init];
        currNode = [[CategoryNode alloc] init];
        currNode->catID = 0xFFFF;
    }
    return self;
}

-(void)setTargetObj:(id)obj{
    targetObj = obj;
}

- (void)initDatabase {
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent =  dataModel.mainDB;
    [dbAgent inDatabase:^(FMDatabase *db) {
        NSString *sql;
        sql = @"CREATE TABLE IF NOT EXISTS category (CatID INTEGER PRIMARY KEY NOT NULL, ParentID INTEGER NOT NULL, CatName TEXT, Leaf INTEGER NOT NULL, CatType INTEGER NOT NULL)";
        
        [db executeUpdate:sql];
        
        sql = @"CREATE TABLE IF NOT EXISTS rootCatMarketId (CatID INTEGER PRIMARY KEY  NOT NULL, MarketID BLOG)";
        [db executeUpdate:sql];
    }];
}

- (void)loginNotify {
    __block UInt16 date;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT SyncDate FROM Misc_SyncDate where SectorID = 0"];
        while ([message next]) {
            date = [message intForColumn:@"SyncDate"];
        }
    }];
    if (date != [[NSDate date] uint16Value]) {
        UInt16 count = 0;
        UInt16 rootSectoers[50];
        SectorTableOut *sector = [[SectorTableOut alloc] initWithIDsync:0
                                                              recursive:1
                                                                   Sync:1
                                                            sectorCount:count
                                                               sectorID:rootSectoers];
        [sector setdate:date];
        [FSDataModelProc sendData:self WithPacket:sector];
        
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"UPDATE Misc_SyncDate SET SyncDate = ? WHERE SectorID = 0",[NSNumber numberWithUnsignedInt:[[NSDate date] uint16Value]]];
            
        }];
    }
    

}

-(void)searcgSectorTableWithSectorID:(UInt16 *)sectorID{
    SectorTableOut *sector = [[SectorTableOut alloc] initWithIDsync:0
                                                          recursive:1
                                                               Sync:0
                                                        sectorCount:1
                                                           sectorID:sectorID];
	[sector setdate:20000];
	[FSDataModelProc sendData:self WithPacket:sector];
}

- (void)updateCategory:(SectorTableIn *)obj {
    [lockCategory lock];
	for (AddSector *add in obj->sectorAdd)
	{
        if([add.sectorName  isEqual: @"行业"]||
           [add.sectorName isEqual:@"地域"]||
           [add.sectorName isEqual:@"概念"]){
            NSLog(@"=====================superID=%d,sectorID=%d , sectorName=%@ , order=%d\n",add->superID,add->sectorIDAdd , add.sectorName , add->sectorOrder);
        
        }
		[self AddWithName:add.sectorName catID:add->sectorIDAdd parentID:add->superID isLeaf:add->flag type:add->sectorType Order:add->sectorOrder];
		if (add->superID == 0)
			[self AddMarketID:add->sectorIDAdd marketID:add->marketID count:add->marketIDCount];
	}
	for (RemoveSector *remove in obj->sectorRemove)
	{
		//NSLog(@"remove sector id : %d",remove->sectorIDRemove);
		[self Remove:remove->sectorIDRemove];
	}
	if (obj->retCode == 0)
	{
		UInt16 nSyncDate = obj->sectorDate;
		[self updateSyncDate: nSyncDate  andSectorID: SYNCDATE_CATTREE];
		
	}
	[lockCategory unlock];
}

- (void) AddWithName: (NSString*)catName catID:(UInt16)catID parentID:(UInt16)parentID isLeaf:(int)leaf type:(UInt16)typeID Order:(UInt8)order
{
    [lockCategory lock];
    __block int searchCount = 0;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT COUNT(*) AS COUNT FROM category where catID = ?",[NSNumber numberWithUnsignedInt:catID]];
        while ([message next]) {
            searchCount = [message intForColumn:@"COUNT"];
        }
        [message close];
        
        if (searchCount==0) {
            [db executeUpdate:@"INSERT INTO category (CatID, ParentID, CatName, Leaf, CatType , OrderType) VALUES (?,?,?,?,?,?)",[NSNumber numberWithUnsignedInt:catID], [NSNumber numberWithUnsignedInt:parentID], catName,[NSNumber numberWithInt:leaf],[NSNumber numberWithUnsignedInt:typeID],[NSNumber numberWithUnsignedInt:order]];
        }else{
            [db executeUpdate:@"UPDATE category SET ParentID = ?, CatName = ?, Leaf = ?, CatType = ? , OrderType =? where CatID = ?",[NSNumber numberWithUnsignedInt:parentID],catName , [NSNumber numberWithInt:leaf], [NSNumber numberWithUnsignedInt:typeID] , [NSNumber numberWithUnsignedInt:order] ,[NSNumber numberWithUnsignedInt:catID]];
        }
    }];
    [lockCategory unlock];
}

- (void) AddMarketID: (UInt16)catID marketID:(unsigned char*)makert_id count: (int)count
{
    [lockCategory lock];
    
    for (int i=0; i<count; i++) {
        __block int searchCount = 0;
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        FSDatabaseAgent *dbAgent = dataModel.mainDB;
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            FMResultSet *message = [db executeQuery:@"SELECT COUNT(*) AS COUNT FROM rootCatMarketId where catID = ?",[NSNumber numberWithUnsignedInt:catID]];
            while ([message next]) {
                searchCount = [message intForColumn:@"COUNT"];
            }
            [message close];
            
            if (searchCount==0) {
                [db executeUpdate:@"INSERT INTO rootCatMarketId (CatID, MarketID) VALUES (?,?)",[NSNumber numberWithUnsignedInt:catID],[NSNumber numberWithUnsignedChar:makert_id[i]]];
            }else{
                [db executeUpdate:@"UPDATE rootCatMarketId SET MarketID = ? where CatID = ?",[NSNumber numberWithUnsignedChar:makert_id[i]],[NSNumber numberWithUnsignedInt:catID]];
            }
        }];
    }
    
    [lockCategory unlock];
}


- (void) Remove: (UInt16) catID
{
    [lockCategory lock];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"DELETE FROM category WHERE CatID = ?",[NSNumber numberWithUnsignedInt:catID]];
    }];
    [lockCategory unlock];
}

- (void) updateSyncDate: (UInt16) syncDate  andSectorID: (UInt16) sectorID
{
    [lockCategory lock];
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
    [lockCategory unlock];
}

- (UInt16) getCatType: (UInt16) catID
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block UInt16 catType = 0;
    // find current nodeID leafType.
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT CatType FROM category WHERE CatID = ?", [NSNumber numberWithUnsignedInt:catID]];
        while ([message next]) {
            catType = [message intForColumn:@"CatType"];
        }
        
    }];

	return catType;
}

- (NSMutableArray*) getAllLeafCategories
{

	NSMutableArray* newCatArray  = [[NSMutableArray alloc] init];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT catID, CatType from category where (Leaf = 1 or Leaf = 3 or Leaf = 5)"];
        while ([message next]) {
            UInt16 myCatID = [message intForColumn:@"catID"];
            UInt16 myCatType = [message intForColumn:@"catType"];
            
            if (myCatType & (2+8+16))
            {
                NSNumber  *node = [[NSNumber alloc]initWithInt:myCatID];
                [newCatArray addObject: node];
            }
        }
        [message close];
    }];

	return newCatArray;
}

-(void)searchSectorIdByIdentCode:(NSString *)ids Symbol:(NSString *)symbol{
#ifdef SERVER_SYNC
    SymbolSectorIdOut *packet = [[SymbolSectorIdOut alloc] initWithIdentCode:ids Symbol:symbol];
    [FSDataModelProc sendData:self WithPacket:packet];
#endif
}

-(void)dataCallBackWithArray:(NSMutableArray *)dataArray{
    NSMutableArray * sectorIdDataArray = [[NSMutableArray alloc]init];
    NSMutableDictionary * dataDic = [[NSMutableDictionary alloc]init];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    for (int i=0; i<[dataArray count]; i++) {
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            
            FMResultSet *message = [db executeQuery:@"SELECT ParentID, CatName from category where CatID = ?",[dataArray objectAtIndex:i]];
            while ([message next]) {
                int parentID = [message intForColumn:@"ParentID"];
                NSString * catName = [message stringForColumn:@"CatName"];
                
                if (parentID != 650) {
                    if ([dataDic objectForKey:[NSNumber numberWithInt:parentID]]) {
                        NSString * str = [dataDic objectForKey:[NSNumber numberWithInt:parentID]];
                        str = [NSString stringWithFormat:@"%@,%@",str,catName];
                        [dataDic setObject:str forKey:[NSNumber numberWithInt:parentID]];
                    }else{
                        NSString * str = [NSString stringWithFormat:@"%@",catName];
                        [dataDic setObject:str forKey:[NSNumber numberWithInt:parentID]];
                    }
                }
            }
        }];
    }
    
    NSMutableArray * idArray = [[NSMutableArray alloc]init];
    
    for(NSNumber *sectorId in [dataDic allKeys])
    {
        [idArray addObject:sectorId];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    idArray = [[NSMutableArray alloc]initWithArray:[idArray sortedArrayUsingDescriptors:sortDescriptors]];
    
    NSMutableArray * keyArray = [[NSMutableArray alloc]init];
    NSMutableArray * sectorIdArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[idArray count]; i++) {
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            
            FMResultSet *message = [db executeQuery:@"SELECT CatName from category where CatID = ?",[idArray objectAtIndex:i]];
            while ([message next]) {
                NSString * catName = [message stringForColumn:@"CatName"];
                [keyArray addObject:catName];
                [sectorIdArray addObject:[dataDic objectForKey:[idArray objectAtIndex:i]]];
            }
        }];

    }
    [sectorIdDataArray addObject:keyArray];
    [sectorIdDataArray addObject:sectorIdArray];
    
    
#ifdef SERVER_SYNC
    if (targetObj && [targetObj isKindOfClass:[FSEquityDrawViewController class]])
    {
        FSEquityDrawViewController * viewController = (FSEquityDrawViewController *)targetObj;
        [viewController sectorIdCallBack:sectorIdDataArray];
    }else if (targetObj && [targetObj isKindOfClass:[RealtimeListController class]])
    {
        RealtimeListController * viewController = (RealtimeListController *)targetObj;
        [viewController sectorIdCallBack:sectorIdDataArray];
    }else if (targetObj && [targetObj isKindOfClass:[FSPriceByVolumeTableViewController class]])
    {
        FSPriceByVolumeTableViewController * viewController = (FSPriceByVolumeTableViewController *)targetObj;
        [viewController sectorIdCallBack:sectorIdDataArray];
    }else if (targetObj && [targetObj isKindOfClass:[FSNewPriceByVolumeViewController class]])
    {
        FSNewPriceByVolumeViewController * viewController = (FSNewPriceByVolumeViewController *)targetObj;
        [viewController sectorIdCallBack:sectorIdDataArray];
    }
#endif
}

- (void)dealloc {
    
}

@end
