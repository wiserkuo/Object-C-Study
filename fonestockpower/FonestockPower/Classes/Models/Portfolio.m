//
//  Portfolio.m
//  FonestockPower
//
//  Created by Neil on 14/4/22.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "Portfolio.h"
#import "Commodity.h"
#import "PortfolioOut.h"
#import "PortfolioIn.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSSnapshotQueryOut.h"
#import "IndexQuotesViewController.h"
#import "FSSetFocusOut.h"
#import "FSSetFocusIn.h"
#import "FSEmergingQuotesViewController.h"
#import "FSEmergingRecommendViewController.h"
#import "FSBrokerInAndOutListViewController.h"
#import "BasicGoodStockViewController.h"
#import "ChipGoodStockViewController.h"
#import "TechnicalGoodStockViewController.h"
#import "RealTimeGoodStockViewController.h"
#import "WarrantViewController.h"
#import "ComparativeAnalysisViewController.h"
#import "WarrantSpreadsheetViewController.h"
#import "TQuotedPriceViewController.h"

@interface PortfolioParam : NSObject {
@public
	NSString *identCodeSymbol;
	UInt16 groupID;
	int valueAdded;
}
@end
@implementation PortfolioParam
- (PortfolioParam*) initWithSymbol:(NSString*)symbol groupID:(UInt16)group valueAdded:(int)vaType;
{
	self = [super init];
	if (self)
	{
		identCodeSymbol = [[NSString alloc] initWithString:symbol];
		groupID = group;
		valueAdded = vaType;
	}
	return self;
}

@end

@implementation Portfolio

- (Portfolio*) init
{
	self = [super init];
	if (self)
	{
		lock = [[NSRecursiveLock alloc] init];
		portfolioArray  = [[NSMutableArray alloc] init];
		watchListArray = [[NSMutableArray alloc] init];  // Current selected group
		currentSeeWatchListArray = [[NSMutableArray alloc] init];
        firstIn = YES;
        currGroupID = -1;
        [self reloadPortfolio];

	}
	return self;
}

-(void)setTarget:(id)target{
    targetObj = target;
}

- (void) reloadPortfolio
{
	
	[lock lock];

	NSMutableArray *identCodeSymbolArray  = [[NSMutableArray alloc] init];
    NSMutableDictionary *valueAddedDict = [[NSMutableDictionary alloc]init];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            FMResultSet *message = [db executeQuery:@"SELECT IdentCodeSymbol, GroupID, ValueAdded FROM groupPortfolio"];
            while ([message next]) {
                [identCodeSymbolArray addObject:[message stringForColumn:@"IdentCodeSymbol"]];
                [valueAddedDict setObject:[NSNumber numberWithInt:[message intForColumn:@"ValueAdded"]] forKey:[message stringForColumn:@"IdentCodeSymbol"]];
            }
        
        
    }];
    //加入兩檔比較之預設股票
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    NSString *icSymbol;
    if ([group isEqualToString:@"us"]) {
        icSymbol = @"US ^DJI";
    }else if ([group isEqualToString:@"cn"]){
        icSymbol = @"SS 000001";
    }else{
        icSymbol = @"TW ^tse01";
    }
    [identCodeSymbolArray addObject:icSymbol];
    [valueAddedDict setObject:[NSNumber numberWithInt:0] forKey:icSymbol];
    
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	NSMutableArray* securityArray = [dataModal.securityName securityNameWithIdentCodeSymbols:identCodeSymbolArray];
	for (SecurityName* secu in securityArray)
	{
		PortfolioItem *item;
		item = [self findInPortfolio: secu->identCode Symbol: secu->symbol];
		if (item != nil)
		{
			item->referenceCount++;
			continue;
		}
		item = [[PortfolioItem alloc] init];
		item->identCode[0] = secu->identCode[0];
		item->identCode[1] = secu->identCode[1];
		item->symbol = secu->symbol ;
		item->type_id = secu->type_id;
		item->fullName = secu->fullName;
		item->commodityNo = 0;
		item->referenceCount = 1;
		item->valueAdded = [(NSNumber *)[valueAddedDict objectForKey:[NSString stringWithFormat:@"%c%c %@",secu->identCode[0],secu->identCode[1],secu->symbol]]intValue];
        if (item->type_id==6) {
            [portfolioArray insertObject:item atIndex:0];
        }else{
            [portfolioArray addObject: item];
        }
		
	}
	[lock unlock];
}

- (int) getCount
{
	return (int)[watchListArray count];
}

-(int)getValueAddedItemCount {
	
	int vaCount = 0;
	
	PortfolioItem* item;
	for (item in portfolioArray)
	{
		if(item->valueAdded == 1)
			vaCount++;
		
	}
	
	return vaCount;
	
}

- (PortfolioItem*) getItemAt: (int)  position
{
	if (position < [watchListArray count])
		return (PortfolioItem*)[watchListArray objectAtIndex:position];
	return nil;
}

- (PortfolioItem*) getItem: (UInt32) commodityNo
{
	for (PortfolioItem* item in watchListArray)
	{
		if (item->commodityNo == commodityNo)
			return item;
	}
	return nil;
}

- (NSMutableArray*) getWatchListArray
{
	return watchListArray;
}

- (PortfolioItem*) getAllItem: (UInt32) commodityNo	
{
	for (PortfolioItem* item in portfolioArray)
	{
		if (item->commodityNo == commodityNo)
			return item;
	}
	return nil;
}

- (BOOL) AddItem: (SecurityName*) newItem
{
	
	//判斷還有多少加值自選的quota來新增自選股 (若quota容許, 新增的自選股預設是加值自選)
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	PortfolioItem* item;
	BOOL result = YES;
    
	[lock lock];
	if ([self isInWatchList: newItem->identCode Symbol: newItem->symbol])
    {
        [lock unlock];
        return result;
    }
	
	// check 加值自選有幾支..
	int quota = (int)[FSFonestock sharedInstance].portfolioQuota;
	int recentAddedValueItem = [self getValueAddedItemCount];
	
    for (int i=0;i<[portfolioArray count];i++)
	{
        PortfolioItem * item = [portfolioArray objectAtIndex:i];
		if ([item isEqualIdentCode: newItem->identCode Symbol: newItem->symbol])
		{
			
			if(item->tmpPortfolioFlag)
				item->tmpPortfolioFlag = NO;
			else
				item->referenceCount++;
			
            if (item->type_id == 6) {
                [watchListArray insertObject:item atIndex:0];
                [portfolioArray removeObjectAtIndex:i];
                [portfolioArray insertObject:item atIndex:0];
            }else if (item->type_id == 3){
                BOOL addFlag = NO;
                for (int j=0; j<[watchListArray count]; j++) {
                    PortfolioItem *newItem = [watchListArray objectAtIndex:j];
                    if (newItem->type_id != 6 && newItem->type_id != 3) {
                        [watchListArray insertObject:item atIndex:j];
                        break;
                    }
                }
                for (int j=0; j<[watchListArray count]; j++) {
                    PortfolioItem *newItem = [watchListArray objectAtIndex:j];
                    if (newItem->type_id != 6 && newItem->type_id != 3) {
                        [portfolioArray removeObjectAtIndex:i];
                        [portfolioArray insertObject:item atIndex:j];
                        addFlag = YES;
                        break;
                    }
                }
                if (!addFlag) {
                    [watchListArray addObject:item];
                }
            }else{
                [watchListArray addObject: item];
            }
			//[self AddToDB:item];
			NSString *identCodeSymbol = [NSString stringWithFormat:@"%c%c %@",item->identCode[0],item->identCode[1],item->symbol];
			PortfolioParam *param = [[PortfolioParam alloc] initWithSymbol: identCodeSymbol groupID:currGroupID valueAdded:item->valueAdded];
			
			[self performSelector:@selector(AddToDB:) onThread:dataModal.thread withObject:param waitUntilDone:NO];
            
            PortfolioParam *param2 = [[PortfolioParam alloc] initWithSymbol: identCodeSymbol groupID:0 valueAdded:item->valueAdded];
            [self performSelector:@selector(AddToDB:) onThread:dataModal.thread withObject:param2 waitUntilDone:NO];
			[lock unlock];
            return result;
		}
	}
	
	if ([portfolioArray count] >= [FSFonestock sharedInstance].portfolioQuota && 0)
	{
		result = NO;
		[lock unlock];
        return result;
	}
	item = [[PortfolioItem alloc] init];
	item->identCode[0] = newItem->identCode[0];
	item->identCode[1] = newItem->identCode[1];
	item->symbol = [[NSString alloc] initWithString:newItem->symbol];
	item->type_id = newItem->type_id;
	item->fullName = [[NSString alloc] initWithString:newItem->fullName];
	item->commodityNo = 0;
	if(quota > recentAddedValueItem)
		item->valueAdded = 1; //新的商品還可設為加值
	else // quota已滿, 新增的商品 初值不為加值自選
		item->valueAdded = 0;
    
    /////////////////////////////////////////
	item->referenceCount = 1;
    if (item->type_id == 6) {
        [portfolioArray insertObject:item atIndex:0];
        [watchListArray insertObject:item atIndex:0];
    }else if (item->type_id == 3){
        BOOL addFlag = NO;
        for (int j=0; j<[watchListArray count]; j++) {
            PortfolioItem *newItem = [watchListArray objectAtIndex:j];
            if (newItem->type_id != 6 && newItem->type_id != 3) {
                [watchListArray insertObject:item atIndex:j];
                break;
            }
        }
        for (int j=0; j<[watchListArray count]; j++) {
            PortfolioItem *newItem = [watchListArray objectAtIndex:j];
            if (newItem->type_id != 6 && newItem->type_id != 3) {
                [portfolioArray insertObject:item atIndex:j];
                addFlag = YES;
                break;
            }
        }
        if (!addFlag) {
            [portfolioArray addObject: item];
            [watchListArray addObject: item];
        }
    }else{
        [portfolioArray addObject: item];
        [watchListArray addObject: item];
    }
	
	//[self AddToDB:item];
	NSString *identCodeSymbol = [NSString stringWithFormat:@"%c%c %@",item->identCode[0],item->identCode[1],item->symbol];
	PortfolioParam *param = [[PortfolioParam alloc] initWithSymbol: identCodeSymbol groupID:currGroupID valueAdded:item->valueAdded];
	[self performSelector:@selector(AddToDB:) onThread:dataModal.thread withObject:param waitUntilDone:NO];
    PortfolioParam *param2 = [[PortfolioParam alloc] initWithSymbol: identCodeSymbol groupID:0 valueAdded:item->valueAdded];
    [self performSelector:@selector(AddToDB:) onThread:dataModal.thread withObject:param2 waitUntilDone:NO];
    
    /////////////////////////////////////////
	// send portfolio add command here.
	//NSLog([NSString stringWithFormat:@"add portfolio %@", [NSString stringWithIdentCode: item->identCode Symbol: item->symbol]]);
    
    //	不用送出PortfolioOut 假如有加入警示在送
	NSMutableArray *array  = [[NSMutableArray alloc] init];
	Commodity *obj = [[Commodity alloc] initWithIdentCode: item->identCode symbol: item->symbol];
	[array addObject: obj];
    
	PortfolioOut *packet = [[PortfolioOut alloc] init];
	[packet addPortfolio:  array];
	[FSDataModelProc sendData:self WithPacket:packet];
	
	[array removeAllObjects];
    
    [lock unlock];
	return result;
	
}

- (void) AddToDB:(PortfolioParam*) item
{
	[lock lock];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"INSERT INTO groupPortfolio(IdentCodeSymbol, groupID, ValueAdded) VALUES(?,?,?)",item->identCodeSymbol,[NSNumber numberWithUnsignedInt:item->groupID],[NSNumber numberWithInt:item->valueAdded]];
    }];
    
    [lock unlock];
}

- (void) selectGroupID: (int) groupID
{
    [lock lock];
    currGroupID = groupID;
	[watchListArray removeAllObjects];
    NSMutableArray * identCodeArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT IdentCodeSymbol, GroupID from groupPortfolio WHERE GroupID = ?",[NSNumber numberWithInt:groupID]];
        while ([message next]) {
            [identCodeArray addObject:[message stringForColumn:@"IdentCodeSymbol"]];
        }
    }];
    PortfolioItem *item;
    for (int i=0; i<[identCodeArray count]; i++) {
        SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[identCodeArray objectAtIndex:i]];
        if (secu != nil){
            item = [self findInPortfolio: secu->identCode Symbol: secu->symbol];
            if (item != nil){
                if (item->type_id == 6) {
                    [watchListArray insertObject:item atIndex:0];
                }else if (item->type_id == 3){
                    BOOL addFlag = NO;
                    for (int j=0; j<[watchListArray count]; j++) {
                        PortfolioItem *newItem = [watchListArray objectAtIndex:j];
                        if (newItem->type_id != 6 && newItem->type_id != 3) {
                            [watchListArray insertObject:item atIndex:j];
                            addFlag = YES;
                            break;
                        }
                    }
                    if (!addFlag) {
                        [watchListArray addObject:item];
                    }
                }else{
                    [watchListArray addObject:item];
                }
                
            }
        }
    }
    
    [lock unlock];
}

- (PortfolioItem *)findItemByIdentCodeSymbol:(NSString *)identCodeSymbol
{
	PortfolioItem *item;
	for (item in portfolioArray)
	{
		if ([item isIdentCodeSymbolEqual:identCodeSymbol])
			return item;
	}
	return nil;
}

- (PortfolioItem*) findInPortfolio: (char*) identCode Symbol: (NSString*) symbol
{
	for (PortfolioItem* item in portfolioArray)
	{
		if ([item isEqualIdentCode: identCode Symbol: symbol])
			return item;
	}
	return nil;
}

- (PortfolioItem *)findInPortfolio:(UInt32)commodityNo
{
	for (PortfolioItem *item in portfolioArray)
	{
		if (item->commodityNo == commodityNo)
			return item;
	}
	return nil;
}

- (void) addWatchListItemByIdentSymbolArray:(NSArray*)isArray		//下次加 會蓋掉前面的
{
	[lock lock];
	
	[currentSeeWatchListArray removeAllObjects];
	[currentSeeWatchListArray addObjectsFromArray:isArray];
	
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	
	NSMutableArray *array  = [[NSMutableArray alloc] init];
	for(NSString *identCodeSymbol in isArray)
	{
		SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol: identCodeSymbol];
		if (secu == nil) continue;
		
		PortfolioItem *item = [self findInPortfolio: secu->identCode Symbol: secu->symbol];
		if (item != nil)
		{
			Commodity *obj = [[Commodity alloc] initWithIdentCode: secu->identCode symbol: secu->symbol];
			[array addObject: obj];
			continue;
		}
		item = [[PortfolioItem alloc] init];
		item->identCode[0] = secu->identCode[0];
		item->identCode[1] = secu->identCode[1];
		item->symbol = secu->symbol;
		item->type_id = secu->type_id;
		item->fullName = secu->fullName;
		item->commodityNo = 0;
		item->referenceCount = 1;
		item->valueAdded = 0;
		item->tmpPortfolioFlag = YES;
		[portfolioArray addObject: item];
		Commodity *obj = [[Commodity alloc] initWithIdentCode: item->identCode symbol: item->symbol];
		[array addObject: obj];
	}
	/////////////////////////////////////////
	if ([array count] > 0)
	{
		PortfolioOut *packet = [[PortfolioOut alloc] init];
		[packet addWatchLists:  array];
		[FSDataModelProc sendData:self WithPacket:packet];
	}
	[lock unlock];
}
- (void) addWatchListItemNewSymbolObjArray:(NSArray*)isArray		//下次加 會蓋掉前面的
{
	[lock lock];
	
	[currentSeeWatchListArray removeAllObjects];
	[currentSeeWatchListArray addObjectsFromArray:isArray];
    
	NSMutableArray *array  = [[NSMutableArray alloc] init];
	for(NewSymbolObject *obj in isArray)
	{
		
		PortfolioItem * item = [[PortfolioItem alloc] init];
		item->identCode[0] = [obj.identCode characterAtIndex:0];
		item->identCode[1] = [obj.identCode characterAtIndex:1];
		item->symbol = obj.symbol;
		item->type_id = obj.typeId;
		item->fullName = obj.fullName;
		item->commodityNo = 0;
		item->referenceCount = 1;
		item->valueAdded = 0;
		item->tmpPortfolioFlag = YES;
		[portfolioArray addObject: item];
		Commodity *obj = [[Commodity alloc] initWithIdentCode: item->identCode symbol: item->symbol];
		[array addObject: obj];
	}
    
	/////////////////////////////////////////
	if ([array count] > 0)
	{
        PortfolioOut *packet = [[PortfolioOut alloc] init];
        [packet addWatchLists:  array];
        [FSDataModelProc sendData:self WithPacket:packet];
	}
	[lock unlock];
}

- (void) removeWatchListItemByIdentSymbolArray
{
	[lock lock];
	
	[currentSeeWatchListArray removeAllObjects];
	
	PortfolioOut *packet = [[PortfolioOut alloc] init];
	NSMutableArray *array  = [[NSMutableArray alloc] init];
	[packet addWatchLists:  array];
	[FSDataModelProc sendData:self WithPacket:packet];
    [lock unlock];
}

- (void) setCommodityNo:(PortfolioIn *) pIn
{
#ifdef SERVER_SYNC
	[lock lock];
	NSLog(@"PortfolioIn setCommodityNo:");
	
	NSArray *array = pIn.Block1dataArray;
	for (Block1 *b1 in array)
	{
		for (PortfolioItem* item in portfolioArray)
		{
			if ([item isEqualIdentCode: b1->Ident_Code Symbol: b1->symbol])
			{
				item->commodityNo = b1->sercurity1Num;
				item->market_id = b1->marketID;
				FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
				
				// Send delete portfolio command here for those had been removed already.
				if (item->referenceCount <= 0)
				{
					// Notify server to remove this portfolio.
					PortfolioOut *packet = [[PortfolioOut alloc] init];
					[packet removePortfolio:&item->commodityNo count: 1];
					[FSDataModelProc sendData:self WithPacket:packet];
					
					// Also remove from local memory.
					[portfolioArray removeObject:item];
					break; // exit "portfolioArray" for loop
				}
				else
				{
					PortfolioTick *portfolioTick = dataModal.portfolioTickBank;
					NSString *identCodeSymbol = [NSString stringWithFormat:@"%c%c %@",b1->Ident_Code[0], b1->Ident_Code[1], b1->symbol];
					[portfolioTick addEquity: identCodeSymbol WithSecurityNo: b1->sercurity1Num];
					//NSLog([NSString stringWithFormat:@"addEquity %@", identCodeSymbol]);
				}
                
                // 股票商品代碼回傳通知
                [[NSNotificationCenter defaultCenter] postNotificationName:kFSSecurityRegisterCallBackNotification object: item];
                
			}
            
            
            
            
		}
	}
    //	[array removeAllObjects];
	if(pIn->returnCode == 0)
	{
		PortfolioTick *historicTick = [[FSDataModelProc sharedInstance]historicTickBank];
		[historicTick sendGetHistoricTick];
        //neil
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
		[[dataModel alert] sendAlertSnapshot];
        if(targetObj){
            
            if ([targetObj isKindOfClass:[IndexQuotesViewController class]]) {
                if (!reloadFlag) {
                    IndexQuotesViewController * indexView = (IndexQuotesViewController *)targetObj;
                    [indexView reloadData];
                    reloadFlag = YES;
                }

            }else if ([targetObj isKindOfClass:[FSEmergingQuotesViewController class]]){
//                if (!reloadFlag) {
                    FSEmergingQuotesViewController * indexView = (FSEmergingQuotesViewController *)targetObj;
                    [indexView reloadData];
//                    reloadFlag = YES;
//                }
            }else if ([targetObj isKindOfClass:[FSEmergingRecommendViewController class]]){
                if (!reloadFlag) {
                    FSEmergingRecommendViewController * indexView = (FSEmergingRecommendViewController *)targetObj;
                    [indexView reloadData];
                    reloadFlag = YES;
                }
            }else if ([targetObj isKindOfClass:[FSBrokerInAndOutListViewController class]]){
                FSBrokerInAndOutListViewController * indexView = (FSBrokerInAndOutListViewController *)targetObj;
                [indexView reloadData];
            }else if ([targetObj isKindOfClass:[BasicGoodStockViewController class]]){
                BasicGoodStockViewController * indexView = (BasicGoodStockViewController *)targetObj;
                [indexView reloadData];
            }else if ([targetObj isKindOfClass:[ChipGoodStockViewController class]]){
                ChipGoodStockViewController * indexView = (ChipGoodStockViewController *)targetObj;
                [indexView reloadData];
            }else if ([targetObj isKindOfClass:[TechnicalGoodStockViewController class]]){
                TechnicalGoodStockViewController * indexView = (TechnicalGoodStockViewController *)targetObj;
                [indexView reloadData];
            }else if ([targetObj isKindOfClass:[RealTimeGoodStockViewController class]]){
                RealTimeGoodStockViewController * indexView = (RealTimeGoodStockViewController *)targetObj;
                [indexView reloadData];
            }
            
            
            
            
//            if(targetObj && [targetObj isKindOfClass:[WarrantViewController class]]){
//                WarrantViewController *warrant = (WarrantViewController *)targetObj;
//                if(warrant.firstFlag){
//                    [warrant pushHandler];
//                }else{
//                    if(!reloadFlag){
//                        [warrant sendHandler];
//                    }
//                    reloadFlag = YES;
//                }
//            }
//            if(targetObj && [targetObj isKindOfClass:[ComparativeAnalysisViewController class]]){
//                if (!reloadFlag) {
//                    ComparativeAnalysisViewController *comparative = (ComparativeAnalysisViewController *)targetObj;
//                    [comparative sendHandler];
//                }
//                reloadFlag = YES;
//            }
//            if(targetObj && [targetObj isKindOfClass:[WarrantSpreadsheetViewController class]]){
//                if (!reloadFlag) {
//                    WarrantSpreadsheetViewController *warrantSpread = (WarrantSpreadsheetViewController *)targetObj;
//                    [warrantSpread sendHandler];
//
//                }
//                reloadFlag = YES;
//            }
            
            
//            if(targetObj && [targetObj isKindOfClass:[TQuotedPriceViewController class]]){
//                if (!reloadFlag) {
//                    TQuotedPriceViewController *tQuoted = (TQuotedPriceViewController *)targetObj;
//                    [tQuoted sendHandler];
//                }
//                reloadFlag = YES;
//            }
            reloadFlag = NO;
        }
	}
	
	[lock unlock];
    
    
    
    
    
        
    
    
    

    
#endif
}

- (BOOL) isInWatchList: (char*) identCode Symbol: (NSString*) symbol
{
	PortfolioItem* item;
	for (item in watchListArray)
	{
		if ([item isEqualIdentCode: identCode Symbol: symbol])
			return YES;
	}
	return NO;
}

- (void) RemoveItem: (char*) identCode andSymbol: (NSString*) symbol
{
	[lock lock];
	for (PortfolioItem* item in watchListArray)
	{
		if ([item isEqualIdentCode: identCode Symbol: symbol])
		{
			//[self RemoveFromDB:item];
			NSString *identCodeSymbol = [NSString stringWithFormat:@"%c%c %@",item->identCode[0],item->identCode[1],item->symbol];
			
			//砍掉alert data
            //			if(item->valueAdded == 1)
            //neil
//            [self removeAlertDataByIdentSymbol:identCodeSymbol];
			
			
			PortfolioParam *param = [[PortfolioParam alloc] initWithSymbol: identCodeSymbol groupID:currGroupID valueAdded:item->valueAdded];
			FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
			[self performSelector:@selector(RemoveFromDB:) onThread:dataModal.thread withObject:param waitUntilDone:NO];
			item->referenceCount--;
			if (item->referenceCount <= 0)
			{
				// send portfolio del command here.
				if (item->commodityNo != 0)
				{
					UInt32 array[1];
					array[0] = item->commodityNo;
					PortfolioOut *packet = [[PortfolioOut alloc] init];
					[packet removePortfolio:  array count: 1];

					[FSDataModelProc sendData:self WithPacket:packet];
					PortfolioTick *portfolioTick = dataModal.portfolioTickBank;
					NSString *identCodeSymbol =[NSString stringWithFormat:@"%c%c %@",identCode[0],identCode[1],symbol];
					[portfolioTick removeEquity: identCodeSymbol];
				}
				[portfolioArray removeObject:item];
			}
			[watchListArray removeObject:item];
			break;
		}
	}
	[lock unlock];
}

- (void) RemoveFromDB:(PortfolioParam*) item
{
	// remove from database.
	[lock lock];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"DELETE FROM groupPortfolio WHERE IdentCodeSymbol = ?",item->identCodeSymbol];
    }];
    
   	[lock unlock];
}

- (void) RemoveFromDBMove:(PortfolioParam*) item
{
	// remove from database.
    [lock lock];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"DELETE FROM groupPortfolio WHERE IdentCodeSymbol = ? AND GroupID = ?",item->identCodeSymbol,[NSNumber numberWithUnsignedInt:item->groupID]];
    }];
    
   	[lock unlock];
}


- (void)moveWatchList:(int)rowIndex ToRowIndex:(int)toRowIndex;
{
	[lock lock];
	PortfolioItem *tmpItem = [watchListArray objectAtIndex:rowIndex];
	[watchListArray removeObjectAtIndex:rowIndex];
	[watchListArray insertObject:tmpItem atIndex:toRowIndex];
	[lock unlock];
}

- (void)loginNotify
{
    
	if([currentSeeWatchListArray count])
		[self addWatchListItemByIdentSymbolArray:currentSeeWatchListArray];
    
	if ([portfolioArray count] == 0) return; // nothing to do.

	NSMutableArray *array  = [[NSMutableArray alloc] init];
//	Alert *alert = [FSDataModelProc getDataModal].alert;
//	int count = [alert getAlertCount];
//	for(int i=0 ; i<count ; i++)
//	{
//		AlertData *alertData = [alert findAlertDataByRowIndex:i];
//		if(alertData)
//		{
//			PortfolioItem *item = [self findItemByIdentCodeSymbol:alertData.identSymbol];
//			if(item)
//			{
//				if(item->valueAdded == 1)
//				{
//					Commodity *obj = [[Commodity alloc] initWithIdentCode: item->identCode symbol: item->symbol];
//					[array addObject: obj];
//					[obj release];
//				}
//			}
//		}
//	}
    
    NSMutableArray *identCodeSymbols = [[NSMutableArray alloc] init];
	for (PortfolioItem* item in portfolioArray) {
		Commodity *obj = [[Commodity alloc] initWithIdentCode: item->identCode symbol: item->symbol];
		[array addObject: obj];
        [identCodeSymbols addObject:item.getIdentCodeSymbol];
	}
    
	// send portfolio add command here.
	if ([array count]) {
//		PortfolioOut *packet = [[PortfolioOut alloc] init];
//		[packet addPortfolio:  array];
//		[FSDataModelProc sendData:self WithPacket:packet];
    }
    
//#ifdef LPCB
    // LPCB snapshot2, 4
//    if ([identCodeSymbols count] > 0) {
//        FSSnapshotQueryOut *snapshotQueryPacket2 = [[FSSnapshotQueryOut alloc] initWithSnapshotTypes:@[@2] identCodeSymbols:identCodeSymbols];
//        [FSDataModelProc sendData:self WithPacket:snapshotQueryPacket2];
//        
//        FSSnapshotQueryOut *snapshotQueryPacket3 = [[FSSnapshotQueryOut alloc] initWithSnapshotTypes:@[@3] identCodeSymbols:identCodeSymbols];
//        [FSDataModelProc sendData:self WithPacket:snapshotQueryPacket3];
//        
//        FSSnapshotQueryOut *snapshotQueryPacket4 = [[FSSnapshotQueryOut alloc] initWithSnapshotTypes:@[@4] identCodeSymbols:identCodeSymbols];
//        [FSDataModelProc sendData:self WithPacket:snapshotQueryPacket4];
//    }
//#endif
    
}

- (void)sortWatchlistArray:(BOOL) descending
{
    [watchListArray sortUsingComparator:^NSComparisonResult(PortfolioItem *obj1, PortfolioItem *obj2) {
        NSComparisonResult result;
        
        if (obj1.valueForSorting == nil && obj2.valueForSorting == nil) {
            result = NSOrderedSame;
        }
        else if (obj1.valueForSorting == nil && obj2.valueForSorting != nil) {
            result = NSOrderedAscending;
        }
        else if (obj1.valueForSorting != nil && obj2.valueForSorting == nil) {
            result = NSOrderedDescending;
        }
        else {
            
            NSNumber *num1;
            NSNumber *num2;
            
            if ([obj1->symbol hasPrefix:@"^"]) {
                if (descending) {
                    num1 = [NSNumber numberWithDouble:[obj1.valueForSorting doubleValue] + 200000000];
                }
                else {
                    num1 = [NSNumber numberWithDouble:[obj1.valueForSorting doubleValue] - 200000000];
                }
                
            } else {
                num1 = obj1.valueForSorting;
            }
            
            if ([obj2->symbol hasPrefix:@"^"]) {
                if (descending) {
                    num2 = [NSNumber numberWithDouble:[obj2.valueForSorting doubleValue] + 200000000];
                }
                else {
                    num2 = [NSNumber numberWithDouble:[obj2.valueForSorting doubleValue] - 200000000];
                }
            }
            else {
                num2 = obj2.valueForSorting;
            }

            result = [num1 compare:num2];
        }
        /**
         *  sort預設是asending，如果要decending就必須把結果反過來
         */
        if (descending) {
            return -result;
        }
        else {
            return result;
        }
        
    }];
}

- (void)reSetNewWatchListToDB
{
	[lock lock];
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	for(PortfolioItem *tmpItem in watchListArray)
	{
		NSString *icSymbol = [tmpItem getIdentCodeSymbol];
		PortfolioParam *param = [[PortfolioParam alloc] initWithSymbol: icSymbol groupID:currGroupID valueAdded:tmpItem->valueAdded];
		[self performSelector:@selector(RemoveFromDBMove:) onThread:dataModal.thread withObject:param waitUntilDone:NO];
	}
	for(PortfolioItem *tmpItem in watchListArray)
	{
		NSString *icSymbol = [tmpItem getIdentCodeSymbol];
		PortfolioParam *param = [[PortfolioParam alloc] initWithSymbol: icSymbol groupID:currGroupID valueAdded:tmpItem->valueAdded];
		[self performSelector:@selector(AddToDB:) onThread:dataModal.thread withObject:param waitUntilDone:NO];
	}
	[lock unlock];
}


@end

@implementation PortfolioItem


- (PortfolioItem*) init
{
	self = [super init];
	if (self)
	{
		identCode[0] = 0;
		identCode[1] = 0;
		type_id = 0;
		market_id = 0;
		symbol = nil;
		fullName = nil;
		referenceCount = 0;
		valueAdded = 0;
	}
	return self;
}
- (NSString *)getIdentCodeSymbol
{
	NSString *identCodeSymbol = [NSString stringWithFormat:@"%c%c %@",identCode[0], identCode[1], symbol];
    //[NSString stringWithIdentCode: identCode Symbol: symbol];
	return identCodeSymbol;
}

- (BOOL)isIdentCodeSymbolEqual:(NSString *)identCodeSymbol
{
	NSString *innerSymbol = [NSString stringWithFormat:@"%c%c %@",identCode[0], identCode[1], symbol];
    //[NSString stringWithIdentCode: identCode Symbol: symbol];
	return [innerSymbol isEqualToString:identCodeSymbol];
}

- (BOOL)isEqualIdentCode: (char*)inCode Symbol: (NSString *)inSymbol
{
	return (identCode[0] == inCode[0] && identCode[1] == inCode[1] && [symbol isEqualToString: inSymbol]);
}


- (NSString *)getNamedAccordingToMarket
{
    NSString *identCodeString = [NSString stringWithUTF8String:identCode];
	
	if([identCodeString isEqualToString:@"TW"] || [identCodeString isEqualToString:@"SS"] || [identCodeString isEqualToString:@"SZ"] || [identCodeString isEqualToString:@"GX"] || [identCodeString isEqualToString:@"HK"] ||type_id == 10){
		return fullName;	// TW, SS, SZ, GX HK, tyie_id=10 .
	}
	else {
		return symbol; // US and others
	}
}

#pragma mark - 註冊最佳五檔
- (void)setFocus
{
	PortfolioOut *packet = [[PortfolioOut alloc] init];
	[packet addFocusd: commodityNo];
    
	[FSDataModelProc sendData:self WithPacket:packet];
}

- (void)killFocus
{
	PortfolioOut *packet = [[PortfolioOut alloc] init];
	[packet removeFocusd];
    
	[FSDataModelProc sendData:self WithPacket:packet];
}


#pragma mark - 註冊最佳五檔
- (void)setTickFocus
{
#ifdef SERVER_SYNC
    FSSetFocusOut * packet = [[FSSetFocusOut alloc] initWithFocusType:FSSetFocusTypeTick queryType:FSSetFocusOperateReplace timestamp:123 securityNumbers:@[[NSNumber numberWithUnsignedLong:commodityNo] ]];
    
	[FSDataModelProc sendData:self WithPacket:packet];
#endif
}

- (void)killTickFocus
{
#ifdef SERVER_SYNC
	FSSetFocusOut * packet = [[FSSetFocusOut alloc] initWithFocusType:FSSetFocusTypeTick queryType:FSSetFocusOperateClear timestamp:456 securityNumbers:@[[NSNumber numberWithUnsignedLong:commodityNo] ]];
    
	[FSDataModelProc sendData:self WithPacket:packet];
#endif
}


@end

