//
//  EquityTick.m
//  Bullseye
//
//  Created by steven on 2008/12/12.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EquityTick.h"
#import "Tick.h"
#import "Commodity.h"
#import "MarketInfo.h"
#import "ValueUtil.h"
#import "FSPriceByVolumeData.h"
#import "FSSnapshot.h"
#import "FSTickData.h"

@interface EquityTick ()


@property (nonatomic, strong) NSMutableDictionary *tickNoSortBox;
@property (nonatomic, strong) NSMutableDictionary *tickNoSortBoxPush;
@property (nonatomic, strong) NSMutableDictionary *tickNoSortBoxQuery;

@property (nonatomic, strong) EquitySnapshotDecompressed *snapshot;
@property (nonatomic, assign) UInt16 maxSequenceNo;
@property (atomic, strong) NSMutableArray *tickNoBox;
@property (nonatomic, strong) NSMutableArray *priceByVolumeInformation;
@property (nonatomic, assign) float progress;

///////  _tickNoBox  ///////

- (NSUInteger)countOfTickNoBox;
- (void)getTickNoBox:(id *)buffer range:(NSRange)inRange;
- (id)objectInTickNoBoxAtIndex:(NSUInteger)idx;
- (void)insertObject:(id)anObject inTickNoBoxAtIndex:(NSUInteger)idx;
- (void)insertTickNoBox:(NSArray *)_tickNoBoxArray atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectFromTickNoBoxAtIndex:(NSUInteger)idx;
- (void)removeTickNoBoxAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTickNoBoxAtIndex:(NSUInteger)idx withObject:(id)anObject;
- (void)replaceTickNoBoxAtIndexes:(NSIndexSet *)indexes withTickNoBox:(NSArray *)_tickNoBoxArray;

@end

@implementation EquityTick

@synthesize snapshot;
@synthesize identCodeSymbol;
@synthesize maxSequenceNo;
@synthesize firstBreakNo;
@synthesize lastTickNo;


//------------------------------------------------------------------------------------
// Public methods
//------------------------------------------------------------------------------------


- (EquityTick*)init {
	if (self = [super init]) {
		
        lock = [[NSRecursiveLock alloc] init];
        
        _tickNoSortBox = [[NSMutableDictionary alloc] init];
        _tickNoSortBoxPush = [[NSMutableDictionary alloc] init];
        _tickNoSortBoxQuery = [[NSMutableDictionary alloc] init];
        
        _maxLastTimeIndex = -1;
        _maxLastTime = nil;
        
        for (int i = 0; i < MAX_CELL_COUNT; i++) {
            ticks[i] = NULL;
        }
		
        maxSequenceNo = 0;
		firstBreakNo = 0;
		maxTickVolume = -1;
		doFindMaxVol = NO;
        
        self.tickNoBox = [NSMutableArray array];
        self.priceByVolumeInformation = [NSMutableArray array];
        
        _ticksData = [[NSMutableArray alloc] initWithCapacity:TW_TICKS_COUNT];
	}
	return self;
}

- (void)dealloc {
    for (int i = 0; i < MAX_CELL_COUNT; i++) {
        if (ticks[i] != NULL) {
			free(ticks[i]);
			ticks[i] = NULL;
		}
    }
}

- (void)assignIdentCodeSymbol:(NSString *)identSymbol {
	self.identCodeSymbol = identSymbol;
}

- (NSString *)getIdenCodeSymbol {
	return identCodeSymbol;
}

- (void)lock {
	[lock lock];
}

- (void)unlock {
	[lock unlock];
}

- (void)clearTicks {
    [lock lock];
	
    for (int i = 0; i < MAX_CELL_COUNT; i++) {
		if (ticks[i] != NULL) {
			free(ticks[i]);
			ticks[i] = NULL;
		}
    }
    
	maxSequenceNo = 0;
	firstBreakNo = 0;
    
	[lock unlock];
}

- (void)addEquityTicks:(NSArray *)newTicksData isLastTicksData:(BOOL)isLastTicksData {
    
    [lock lock];
    
//    for (FSTickData *tick in newTicksData) {
//        NSLog(@"%@", tick.time.timeString);
//    }
    
    for (FSTickData *tick in newTicksData) {
        
        if (tick.queryType == FSTickReceiveTypeQuery) {
            
            [_tickNoSortBoxQuery setObject:tick forKey:tick.time.timeValue];
            
        } else if (tick.queryType == FSTickReceiveTypePush) {
            
            [_tickNoSortBoxPush setObject:tick forKey:tick.time.timeValue];
            
        }
        
    }
    
    if (isLastTicksData) {
        
        
        FSTickData *tick = [newTicksData lastObject];
        if (tick.queryType == FSTickReceiveTypeQuery) {
            _maxLastTime = tick.time;
            [_tickNoSortBoxPush removeAllObjects];
        }
        
        [_tickNoSortBox removeAllObjects];
        [_tickNoSortBox addEntriesFromDictionary:_tickNoSortBoxQuery];
        [_tickNoSortBox addEntriesFromDictionary:_tickNoSortBoxPush];
        
        NSArray *blockSortedKeys = [_tickNoSortBox keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
            
            FSTickData *tick1 = (FSTickData *)obj1;
            FSTickData *tick2 = (FSTickData *)obj2;
            
            if ([tick1.time.timeValue isGreaterThan:tick2.time.timeValue]) {
                return NSOrderedDescending;
            } else if ([tick2.time.timeValue isGreaterThan:tick1.time.timeValue]) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
            
        }];
        
        [_ticksData removeAllObjects];
        for (NSNumber *num in blockSortedKeys) {
            [_ticksData addObject:[_tickNoSortBox objectForKey:num]];
        }
        
        FSTickData *lastTick = [_ticksData lastObject];

        if (_snapshot_b != nil) {
            if (lastTick.type ==FSTickType3) {
                if ([lastTick.time.timeValue isGreaterThan:_snapshot_b.tick_time.timeValue]) {
                    _snapshot_b.last_price = lastTick.last;
                    _snapshot_b.volume = lastTick.volume;
                    _snapshot_b.bid_price = lastTick.bid;
                    _snapshot_b.ask_price = lastTick.ask;
                    _snapshot_b.accumulated_volume = lastTick.accumulated_volume;

                    if (lastTick.last.calcValue > _snapshot_b.high_price.calcValue) {
                        _snapshot_b.high_price = lastTick.last;
                    }
                    if (lastTick.last.calcValue < _snapshot_b.low_price.calcValue) {
                        _snapshot_b.low_price = lastTick.last;
                    }
                }
            }else{
                if ([lastTick.time.timeValue isGreaterThan:_snapshot_b.tick_time.timeValue]) {
                    _snapshot_b.last_price = lastTick.indexValue;

                    if (lastTick.dealValue>0) {
                        _snapshot_b.volume.calcValue = lastTick.dealValue.calcValue-_snapshot_b.accumulated_volume.calcValue;
                        _snapshot_b.accumulated_volume = lastTick.dealValue;
                    }else{
                        _snapshot_b.volume.calcValue = 0;
                    }

                    if (lastTick.indexValue.calcValue > _snapshot_b.high_price.calcValue) {
                        _snapshot_b.high_price = lastTick.indexValue;
                    }
                    if (lastTick.indexValue.calcValue < _snapshot_b.low_price.calcValue) {
                        _snapshot_b.low_price = lastTick.indexValue;
                    }
                    _snapshot_b.bid_volume = lastTick.bidVolume;
                    _snapshot_b.ask_volume = lastTick.askVolume;
                    _snapshot_b.deal_volume = lastTick.dealVolume;
                    _snapshot_b.up_count = lastTick.up;
                    _snapshot_b.down_count = lastTick.down;
                    _snapshot_b.unchange_count = lastTick.unchanged;
                    _snapshot_b.dealRecord = lastTick.dealRecord;
                    _snapshot_b.bidRecord = lastTick.bidRecord;
                    _snapshot_b.askRecord = lastTick.askRecord;
                }
            }
            
        }
        
        self.progress = 1;
    } else {
        self.progress = 0;
    }
    
    
    
    [lock unlock];
}

// LPCB
- (void)addEquityTicks2:(NSArray *)newTicksData isLastTicksData:(BOOL)isLastTicksData {
    [lock lock];
    
    
    for (FSTickData *tick in newTicksData) {
        NSLog(@"%@", tick.time.timeString);
    }
    
    
    // 沒資料時, 無條件加入
    if ([_ticksData count] == 0) {
        
        // 新增Tick
        [_ticksData addObjectsFromArray:newTicksData];
        
        // 取出最後一支new tick
        FSTickData *tick = [newTicksData lastObject];
        
        /*
            判斷tick是query還是push下來的:
         
            query: 1.紀錄最後時間 2.tickdata index
         */
        if (tick.queryType == FSTickReceiveTypeQuery) {
            _maxLastTimeIndex = (int)[_ticksData count] - 1;
            _maxLastTime = tick.time;
        }
        else if (tick.queryType == FSTickReceiveTypePush) {
            _maxLastTimeIndex = -1;
            _maxLastTime = nil;
        }
        
        if (isLastTicksData) {
            self.progress = 1;
        } else {
            self.progress = 0;
        }
    }
    else {
        if ([newTicksData count] > 0) {
            
            /*
                判斷新加入的tick是否有交集, 如果有就放棄封包
             */
            
            FSTickData *lastTick = [_ticksData lastObject];
            FSTickData *newFirstTicksData = [newTicksData firstObject];
            
            if (lastTick && newFirstTicksData) {
                
                // 第二次封包進來 發現是query type
                if (newFirstTicksData.queryType == FSTickReceiveTypeQuery) {
                    
//                    if (isLastTicksData) {
                    
                        // 檢查是否是空的, -1 但代表全部都是push, 從未有query
                        if (_maxLastTimeIndex == -1) {
                            [_ticksData removeAllObjects];
                        }
                        
                        else if (([_ticksData count] - 1) > _maxLastTimeIndex) {
                            NSRange range = {_maxLastTimeIndex, [_ticksData count] - _maxLastTimeIndex};
                            [_ticksData removeObjectsInRange:range];
                        }
                        
                        
                        if ([_ticksData count] == 0) {
                            [_ticksData addObjectsFromArray:newTicksData];
                        }
                        
                        lastTick = [_ticksData lastObject];
                        _maxLastTimeIndex = (int)[_ticksData count] - 1;
                        
                        
                        
//                    }
                } else {
//                    [_ticksData addObjectsFromArray:newTicksData];
//                    lastTick = [_ticksData lastObject];
//                    _maxLastTimeIndex = [_ticksData count] - 1;
                }
                
                
                if ([lastTick.time.timeValue isLessThan:newFirstTicksData.time.timeValue]) {
                    [_ticksData addObjectsFromArray:newTicksData];
                    
                    if (newFirstTicksData.queryType == FSTickReceiveTypeQuery) {
                        _maxLastTimeIndex = (int)[_ticksData count] - 1;
                        FSTickData *newLastTicksData = [_ticksData lastObject];
                        _maxLastTime = newLastTicksData.time;
                    }
                    else if (newFirstTicksData.queryType == FSTickReceiveTypePush) {
                        
                    }
                    
                    if (isLastTicksData) {
                        self.progress = 1;
                    } else {
                        self.progress = 0;
                    }
                }
                else {
                    NSLog(@"~~~~~~~~bug count:%d", (int)[newTicksData count]);
                    
                    if (isLastTicksData) {
                        self.progress = 1;
                    } else {
                        self.progress = 0;
                    }
                }
            }
        }
    }
    
    if (isLastTicksData) {
        FSTickData *lastTick = [_ticksData lastObject];
        
        if (_snapshot_b != nil) {
            if (lastTick.type ==FSTickType3) {
                if ([lastTick.time.timeValue isGreaterThan:_snapshot_b.tick_time.timeValue]) {
                    _snapshot_b.last_price = lastTick.last;
                    _snapshot_b.volume = lastTick.volume;
                    _snapshot_b.bid_price = lastTick.bid;
                    _snapshot_b.ask_price = lastTick.ask;
                    _snapshot_b.accumulated_volume = lastTick.accumulated_volume;
                    
                    if (lastTick.last.calcValue > _snapshot_b.high_price.calcValue) {
                        _snapshot_b.high_price = lastTick.last;
                    }
                    if (lastTick.last.calcValue < _snapshot_b.low_price.calcValue) {
                        _snapshot_b.low_price = lastTick.last;
                    }
                }
            }else{
                if ([lastTick.time.timeValue isGreaterThan:_snapshot_b.tick_time.timeValue]) {
                    _snapshot_b.last_price = lastTick.indexValue;
                    
                    if (lastTick.dealValue>0) {
                        _snapshot_b.volume.calcValue = lastTick.dealValue.calcValue-_snapshot_b.accumulated_volume.calcValue;
                        _snapshot_b.accumulated_volume = lastTick.dealValue;
                    }else{
                        _snapshot_b.volume.calcValue = 0;
                    }
                    
                    if (lastTick.indexValue.calcValue > _snapshot_b.high_price.calcValue) {
                        _snapshot_b.high_price = lastTick.indexValue;
                    }
                    if (lastTick.indexValue.calcValue < _snapshot_b.low_price.calcValue) {
                        _snapshot_b.low_price = lastTick.indexValue;
                    }
                    _snapshot_b.bid_volume = lastTick.bidVolume;
                    _snapshot_b.ask_volume = lastTick.askVolume;
                    _snapshot_b.deal_volume = lastTick.dealVolume;
                    _snapshot_b.up_count = lastTick.up;
                    _snapshot_b.down_count = lastTick.down;
                    _snapshot_b.unchange_count = lastTick.unchanged;
                    _snapshot_b.dealRecord = lastTick.dealRecord;
                    _snapshot_b.bidRecord = lastTick.bidRecord;
                    _snapshot_b.askRecord = lastTick.askRecord;
                }
            }
            
        }
    }
    
    [lock unlock];
}

- (void)addEquityTick:(EquityTickParam *)TickParam WithSequenceNo:(UInt16)sequenceNo
{
	int cell = sequenceNo / COUNT_PER_CELL;
	int pos  = sequenceNo % COUNT_PER_CELL;
	
	[lock lock];
	
	//	NSAssert(snapshot, @"No snapshot has ever been created.");
	//  if (snapshot == nil)  goto exit;
    
	if (snapshot != nil && (sequenceNo > [snapshot sequenceOfTick] || sequenceNo == 0))
	{
		//if (snapshot.commodityType == kCommodityTypeStock || snapshot.commodityType == kCommodityTypeIndex
		//	|| snapshot.commodityType == kCommodityTypeFuture)
		[snapshot updateWithTick:&(TickParam->etick) andSeqNo:sequenceNo];
		
		if(seqOfLastTick == 0)
		{
			lastTickPrice = snapshot.currentPrice;
			seqOfLastTick = snapshot.sequenceOfTick;
		}
		if(lastTickPrice != snapshot.currentPrice)
		{
			if(lastTickPrice > snapshot.currentPrice)
				updateTickFlag = 1;		//跌
			else {
				updateTickFlag = 2;		//漲
			}
			lastTickPrice = snapshot.currentPrice;
		}
		
		//else if (snapshot.commodityType == kCommodityTypeMarketIndex)
		//	[(IndexSnapshotDecompressed *)snapshot updateWithTick:&(TickParam->tickData.itick) andSeqNo:sequenceNo];
	}
	
	
	if (cell >= MAX_CELL_COUNT){// sequenceNo too large
        [lock unlock];
        return;
    }
	if (ticks[cell] == NULL)
	{
		int i;
		ticks[cell] = malloc(sizeof(EquityTickData)*COUNT_PER_CELL);
		if (ticks[cell] == NULL){
            [lock unlock];
            return;
        }
		for (i = 0; i < COUNT_PER_CELL; i++)
			ticks[cell][i].tick.price = 0;
	}
	
	//if (snapshot.commodityType == kCommodityTypeStock || snapshot.commodityType == kCommodityTypeIndex
	//	|| snapshot.commodityType == kCommodityTypeFuture)
    ticks[cell][pos] = TickParam->etick;
    
    NSNumber *newTickNo = [NSNumber numberWithUnsignedInt:sequenceNo];
    NSUInteger tickNoIndex = [_tickNoBox indexOfObjectPassingTest:^BOOL(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        if ([obj compare:newTickNo] == NSOrderedSame) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (tickNoIndex == NSNotFound) {
        NSComparator comparator = ^(NSNumber *obj1, NSNumber *obj2) {
            return [obj1 compare:obj2];
        };
        NSUInteger newIndex = [_tickNoBox indexOfObject:newTickNo
                                          inSortedRange:(NSRange){0, [_tickNoBox count]}
                                                options:NSBinarySearchingInsertionIndex
                                        usingComparator:comparator];
        
//        [_tickNoBox insertObject:newTickNo atIndex:newIndex];
        [self insertObject:newTickNo inTickNoBoxAtIndex:newIndex];
    [self arrangeTicksInformationInGroups:TickParam];
    }
    

    
	if(doFindMaxVol)
		[self updateMaxVol:sequenceNo];	//找最大量
	//else if (snapshot.commodityType == kCommodityTypeMarketIndex)
	//{
	//	ticks[cell][pos].tick = TickParam->tickData.itick.tick;
	//	ticks[cell][pos].status = 0;
	//	ticks[cell][pos].bid = 0;
	//	ticks[cell][pos].ask = 0;
	//}
	if (maxSequenceNo < sequenceNo)
		maxSequenceNo = sequenceNo;
	while (firstBreakNo < maxSequenceNo)
	{
		UInt16 tempNo = firstBreakNo + 1;
		int cell = tempNo / COUNT_PER_CELL;
		int pos  = tempNo % COUNT_PER_CELL;
		if (cell >= MAX_CELL_COUNT) break; // sequenceNo too large
		if (ticks[cell] == NULL) break;
		if (ticks[cell][pos].tick.price == 0)  break;
		firstBreakNo = tempNo;
	}
	lastTickNo = sequenceNo;
    self.progress = (float)([_tickNoBox count])/(float)(snapshot.sequenceOfTick);
	[lock unlock];
}

- (void)addIndexTick:(IndexTickParam *)TickParam WithSequenceNo:(UInt16)sequenceNo
{
	int cell = sequenceNo / COUNT_PER_CELL;
	int pos  = sequenceNo % COUNT_PER_CELL;
	
	[lock lock];

	//	NSAssert(snapshot, @"No snapshot has ever been created.");
	//if (snapshot == nil)  goto exit;
	if (snapshot != nil && (sequenceNo > [snapshot sequenceOfTick] || sequenceNo == 0))
	{
		//if (snapshot.commodityType == kCommodityTypeStock || snapshot.commodityType == kCommodityTypeIndex
		//	|| snapshot.commodityType == kCommodityTypeFuture)
		//	[snapshot updateWithTick:&(TickParam->tickData.etick) andSeqNo:sequenceNo];
		//else if (snapshot.commodityType == kCommodityTypeMarketIndex)
		[(IndexSnapshotDecompressed *)snapshot updateWithTick:&(TickParam->itick) andSeqNo:sequenceNo];
		
		if(seqOfLastTick == 0)
		{
			lastTickPrice = snapshot.currentPrice;
			seqOfLastTick = snapshot.sequenceOfTick;
		}
		if(lastTickPrice != snapshot.currentPrice)
		{
			if(lastTickPrice > snapshot.currentPrice)
				updateTickFlag = 1;		//跌
			else {
				updateTickFlag = 2;		//漲
			}
			lastTickPrice = snapshot.currentPrice;
		}
	}
	
	if (cell >= MAX_CELL_COUNT) // sequenceNo too large
    {
        [lock unlock];
        return;
    }
	if (ticks[cell] == NULL)
	{
		int i;
		ticks[cell] = malloc(sizeof(EquityTickData)*COUNT_PER_CELL);
		if (ticks[cell] == NULL) {
            [lock unlock];
            return;
        }
		for (i = 0; i < COUNT_PER_CELL; i++)
			ticks[cell][i].tick.price = 0;
	}
	
	//if (snapshot.commodityType == kCommodityTypeStock || snapshot.commodityType == kCommodityTypeIndex
	//	|| snapshot.commodityType == kCommodityTypeFuture)
	//	ticks[cell][pos] = TickParam->tickData.etick;
	//else if (snapshot.commodityType == kCommodityTypeMarketIndex)
	{
		ticks[cell][pos].tick = TickParam->itick.tick;
		ticks[cell][pos].status = 0;
		ticks[cell][pos].bid = 0;
		ticks[cell][pos].ask = 0;
	}
    
    NSNumber *newTickNo = [NSNumber numberWithUnsignedInt:sequenceNo];
    NSUInteger tickNoIndex = [_tickNoBox indexOfObjectPassingTest:^BOOL(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        if ([obj compare:newTickNo] == NSOrderedSame) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (tickNoIndex == NSNotFound) {
        NSComparator comparator = ^(NSNumber *obj1, NSNumber *obj2) {
            return [obj1 compare:obj2];
        };
        NSUInteger newIndex = [_tickNoBox indexOfObject:newTickNo
                                          inSortedRange:(NSRange){0, [_tickNoBox count]}
                                                options:NSBinarySearchingInsertionIndex
                                        usingComparator:comparator];
        
//        [_tickNoBox insertObject:newTickNo atIndex:newIndex];
        [self insertObject:newTickNo inTickNoBoxAtIndex:newIndex];
//    [self arrangeTicksInformationInGroups:TickParam];
    }
    
	if(doFindMaxVol)
		[self updateMaxVol:sequenceNo];	//找最大量
	if (maxSequenceNo < sequenceNo)
		maxSequenceNo = sequenceNo;
	while (firstBreakNo < maxSequenceNo)
	{
		UInt16 tempNo = firstBreakNo + 1;
		int cell = tempNo / COUNT_PER_CELL;
		int pos  = tempNo % COUNT_PER_CELL;
		if (cell >= MAX_CELL_COUNT) break; // sequenceNo too large
		if (ticks[cell] == NULL) break;
		if (ticks[cell][pos].tick.price == 0)  break;
		firstBreakNo = tempNo;
	}
	lastTickNo = sequenceNo;
    self.progress = (float)([_tickNoBox count])/(float)(snapshot.sequenceOfTick);
	[lock unlock];
}

//---------------------------------------------------------------------
// Private method
//---------------------------------------------------------------------
//- (TickDataRef) getTick: (UInt32) sequenceNo
//{
//	int cell = sequenceNo / COUNT_PER_CELL;
//	int pos  = sequenceNo % COUNT_PER_CELL;
//	if (ticks[cell] == NULL)
//		return NULL;
//	if (ticks[cell][pos].tick.price == 0)
//		return NULL;
//	return &ticks[cell][pos].tick;
//}

- (EquityTickDataRef) getTick: (UInt32) sequenceNo
{
	int cell = sequenceNo / COUNT_PER_CELL;
	int pos  = sequenceNo % COUNT_PER_CELL;
	if (cell >= MAX_CELL_COUNT) return NULL;
	if (ticks[cell] == NULL)
		return NULL;
	if (ticks[cell][pos].tick.price == 0)
		return NULL;
    if (ticks[cell][pos].tick.volume<=0) {
        
    }
	return &ticks[cell][pos];
}

- (void)updateSnapshotWarningCode:(UInt8)warningCode
{
	if (snapshot)
	{
		[snapshot updateWarningCode:warningCode];
	}
}

- (void)updateDailyStatus:(UInt8)dailyStatus
{
	if (snapshot)
	{
		[snapshot updateDailyStatus:dailyStatus];
	}
}

- (void)updateSnapshotDelayClose:(UInt8)delayClose {

    if (snapshot)
        [snapshot updateDelayClose:delayClose];
}


- (void)updateSnapshotBValue:(FSSnapshot *)snapshot_b {
    
    if (_snapshot_b == nil) {
        _snapshot_b = snapshot_b;
    }
    else {
        if (snapshot_b.trading_date.date16 != _snapshot_b.trading_date.date16 ||
            [snapshot_b.tick_time.timeValue intValue] == 0) {
            [self clearTicks];

        }
        if ([snapshot_b.tick_time.timeValue isGreaterThan:_snapshot_b.tick_time.timeValue]) {
            _snapshot_b = snapshot_b;
        }
    }
}


- (BOOL)updateSnapshot:(Snapshot *)snap {
    
    if (snap->subType == 1) {
		if (snapshot)
		{
			if(snap->sequenceOfTick == snapshot.sequenceOfTick)
				return NO;
			snap->snapshotTypeGet = snapshot.snapshotTypeGet;
			[snapshot updateWithOtherTypeSnapshot:snap];
//			[snapshot release];
		}
		else
		{
			if (snap->commodityType == kCommodityTypeMarketIndex)
				snapshot = [[IndexSnapshotDecompressed alloc] initWithEquitySanpshot:snap];
			else if (snap->commodityType == kCommodityTypeStock || snap->commodityType == kCommodityTypeIndex 
					 || snap->commodityType == kCommodityTypeWarrant || snap->commodityType == kCommodityTypeCurrency)
				snapshot = [[EquitySnapshotDecompressed alloc] initWithEquitySanpshot:snap];
			else /* if (snap->commodityType == kCommodityTypeFuture || snap->commodityType == kCommodityTypeETF) */
				snapshot = [[EquitySnapshotDecompressed alloc] initWithEquitySanpshot:snap];
		}
		
		if(seqOfLastTick == 0)
		{
			lastTickPrice = snapshot.currentPrice;
			seqOfLastTick = snapshot.sequenceOfTick;
		}
		
		if(lastTickPrice != snapshot.currentPrice)
		{
			if(lastTickPrice > snapshot.currentPrice)
				updateTickFlag = 1;		//跌
			else {
				updateTickFlag = 2;		//漲
			}
			lastTickPrice = snapshot.currentPrice;
		}
		maxSequenceNo = [snapshot sequenceOfTick];
	}
	else
	{
		if(snapshot)
			[snapshot updateWithOtherTypeSnapshot:snap];
		
	}
	return YES;

}

- (UInt32)tickCount
{
#ifdef LPCB
    return (int)[_ticksData count];
#else
	return maxSequenceNo;
#endif
}

//- (TickDecompressed *)copyTickAtSequenceNo:(UInt32)sequenceNo
//{
//	TickDataRef tick = [self getTick:sequenceNo];
//	if (tick == NULL || tick->price == 0)
//		return nil;
//	TickDecompressed *exTick = [[TickDecompressed alloc] initWithTick:tick RefPrice:[snapshot referencePrice]];
//	return exTick;
//}

- (EquityTickDecompressed *)copyTickAtSequenceNo:(UInt32)sequenceNo
{
	EquityTickDecompressed *exTick = nil;
	[lock lock];
	EquityTickDataRef tick = [self getTick:sequenceNo];
	if (tick != NULL && tick->tick.price != 0){
		exTick = [(EquityTickDecompressed *)[EquityTickDecompressed alloc] initWithTick:tick RefPrice:[snapshot referencePrice]];
        
    }
	[lock unlock];
	return exTick;
}

- (BOOL) getTimePrice:(UInt16*)tickTime Price:(double*)tickPrice Sequence:(UInt32)seq;
{
	[lock lock];
#ifdef LPCB
    //	EquityTickDataRef tick = [self getTick:seq];
    FSTickData *tick;
    if(seq<[_ticksData count]){
        tick = [_ticksData objectAtIndex:seq];
        
    }
    if(tick.type == FSTickType3){
        *tickPrice = tick.last.calcValue;

    }else{
            *tickPrice = tick.indexValue.calcValue;

    }
    
    
	if(!tick) {
		[lock unlock];
		return NO;
	}
    
	*tickTime = [tick.time absoluteMinutesTime];
	[lock unlock];
	return YES;

#else
    
    EquityTickDataRef tick = [self getTick:seq];
    
	if(tick) {
        *tickTime = tick->tick.time;
        *tickPrice = [CodingUtil ConvertPrice:tick->tick.price RefPrice:[snapshot referencePrice]];
		[lock unlock];
		return YES;
	}
    
	[lock unlock];
	return NO;
#endif

}

- (BOOL) getTimeVolume:(UInt16*)tickTime Volume:(double*)tickVol VolUnit:(UInt16*)tickVolUnit Sequence:(UInt32)seq;
{
	[lock lock];
	EquityTickDataRef tick = [self getTick:seq];
	if(!tick)
	{
		[lock unlock];
		return NO;
	}
	*tickTime = tick->tick.time;
	*tickVol = [CodingUtil ConvertTAValue:tick->tick.volume WithType:tickVolUnit];
	[lock unlock];
	return YES;
	
}

-(float)getSameTickTimeVolume:(UInt16)time BySequence:(UInt32)seq{
    
    float totalVol=0;
    double volume;
    UInt16 tVolUnit=0;
    UInt16 tickTime = time;

    
    for (int i=0; i<=[self tickCount]; i++) {
        EquityTickDataRef newTick = [self getTick:i];
        if(newTick!=nil){
            if (i>0) {
                EquityTickDataRef oldTick = [self getTick:i-1];
                if(oldTick!=nil){
                    volume =[CodingUtil ConvertTAValue:newTick->tick.volume WithType:&tVolUnit]-[CodingUtil ConvertTAValue:oldTick->tick.volume WithType:&tVolUnit];
                }else{
                    volume =[CodingUtil ConvertTAValue:newTick->tick.volume WithType:&tVolUnit];
                }

                if (newTick->tick.time == tickTime) {
                    totalVol+=volume;
//              NSLog(@"%d:%f",newTick->tick.time,volume);
                }
            }
        }
    }
//    NSLog(@"--------------------");
    
    //印出所有tick
//    for (int i=1; i<[self tickCount]; i++) {
//        EquityTickDataRef newTick = [self getTick:i];
//        if (i>1) {
//            EquityTickDataRef oldTick = [self getTick:i-1];
//            volume =[CodingUtil ConvertTAValue:newTick->tick.volume WithType:&tVolUnit]-[CodingUtil ConvertTAValue:oldTick->tick.volume WithType:&tVolUnit];
//        }else{
//            volume =[CodingUtil ConvertTAValue:newTick->tick.volume WithType:&tVolUnit];
//        }
//        NSLog(@"%d:%f",newTick->tick.time,volume);
//    }
    
    
    return totalVol;
}

- (BOOL) getPriceVolume:(double*)tickPrice Volume:(double*)tickVol VolUnit:(UInt16*)tickVolUnit Sequence:(UInt32)seq
{
	[lock lock];
	EquityTickDataRef tick = [self getTick:seq];
	if(!tick)
	{
		[lock unlock];
		return NO;
	}
	*tickVol = [CodingUtil ConvertTAValue:tick->tick.volume WithType:tickVolUnit];
	*tickPrice = [CodingUtil ConvertPrice:tick->tick.price RefPrice:[snapshot referencePrice]];
	[lock unlock];
	return YES;
}

- (BOOL) getInOutVolume:(double*)inVol Out:(double*)outVol Sequence:(UInt32)seq
{
	[lock lock];
	BOOL errorFlag = NO;
	double ref = [snapshot referencePrice];
	double e = 0.001;
	double preTickVol;
	int preSeq = 0;
	BOOL haveAllTick = YES;
	if(inOutSeq != 0)
	{
		*inVol = inVolume;
		*outVol = outVolume;
		for(int i = inOutSeq ; i<=seq ; i++)
		{
			EquityTickDataRef tick = [self getTick:i];
			if(!tick)
			{
				haveAllTick = NO;
				continue;
			}
			UInt16 tickVolUnit = 0;
			double tickVol = [CodingUtil ConvertTAValue:tick->tick.volume WithType:&tickVolUnit];
			tickVol *= pow(1000,tickVolUnit);
			double tickPrice = [CodingUtil ConvertPrice:tick->tick.price RefPrice:ref];
			double bid = [CodingUtil ConvertPrice:tick->bid RefPrice:tickPrice];
			double ask = [CodingUtil ConvertPrice:tick->ask RefPrice:tickPrice];
			if(bid == 0 && ask ==0)
			{
				preTickVol = tickVol;
				continue;
			}
			if(preSeq == 0)
			{
				preTickVol = tickVol;
				preSeq = i;
				continue;
			}
			else
			{
				if(i != preSeq+1)
				{
					preSeq = i;
					preTickVol = tickVol;
					continue;
				}
				if(tickVol >= preTickVol)
				{
					double tmp = tickVol;
					tickVol -= preTickVol;
					preTickVol = tmp;
				}
				else
				{
					preTickVol += tickVol;
				}
				preSeq = i;
			}
			if(fabs(tickPrice -bid)<e)		//買價成交
				*inVol = *inVol + tickVol;
			else if(fabs(tickPrice - ask)<e)	//賣價成交
				*outVol = *outVol + tickVol;
			else if(fabs(tickPrice -bid) < fabs(tickPrice -ask))	//較接近買價
				*inVol = *inVol + tickVol;
			else
				*outVol = *outVol + tickVol;
			allPrice += (tickVol * tickPrice);
			allTickVolume += tickVol;
			inVolume = *inVol;
			outVolume = *outVol;
			inOutSeq = i;
		}
	}
	else
	{
		BOOL allZero = NO;
		int haveZero = 30;		//當超過30個0 就算是全部都零
		for(int i = 1 ; i<=seq ; i++)
		{
			EquityTickDataRef tick = [self getTick:i];
			if(!tick)
			{
				haveAllTick = NO;
				continue;
			}
			UInt16 tickVolUnit = 0;
			double tickVol = [CodingUtil ConvertTAValue:tick->tick.volume WithType:&tickVolUnit];
			tickVol *= pow(1000,tickVolUnit);
			double tickPrice = [CodingUtil ConvertPrice:tick->tick.price RefPrice:ref];
			double bid = [CodingUtil ConvertPrice:tick->bid RefPrice:tickPrice];
			double ask = [CodingUtil ConvertPrice:tick->ask RefPrice:tickPrice];
			if(bid == 0 && ask ==0)
			{
				preTickVol = tickVol;
				haveZero --;
				if(haveZero == 0)
					allZero = YES;
				continue;
			}
			allZero = NO;
			if(preSeq == 0)
			{
				preSeq = i;
				preTickVol = tickVol;
			}
			else
			{
				if(i != preSeq+1)
				{
					preSeq = i;
					preTickVol = tickVol;
					continue;
				}
				if(tickVol >= preTickVol)
				{
					double tmp = tickVol;
					tickVol -= preTickVol;
					preTickVol = tmp;
				}
				else
				{
					preTickVol += tickVol;
				}
				preSeq = i;
			}
			if(fabs(tickPrice -bid)<e)		//買價成交
				*inVol = *inVol + tickVol;
			else if(fabs(tickPrice - ask)<e)	//賣價成交
				*outVol = *outVol + tickVol;
			else if(fabs(tickPrice -bid) < fabs(tickPrice -ask))	//較接近買價
				*inVol = *inVol + tickVol;
			else
				*outVol = *outVol + tickVol;
			allPrice += (tickVol * tickPrice);
			allTickVolume += tickVol;
			inVolume = *inVol;
			outVolume = *outVol;
			inOutSeq = i;
		}
		if(allZero)
			inOutSeq = 999999;		//以後不做
	}
	if(*inVol == 0 && *outVol == 0)
		errorFlag = YES;
	if(!haveAllTick)
		inOutSeq = 0;
	[lock unlock];
	return !errorFlag;
}

- (int) getSequenceNumByIndexValue:(UInt16)indexValue OpenTime:(UInt16)openTime portfolioItem:(PortfolioItem *) portfolioItem
{		//回傳-1代表沒找到
	[lock lock];
	int returnSeq = 1;
	BOOL findItFlag = NO;
	for(int seq = 1 ; seq<=maxSequenceNo ; seq++)
	{
		EquityTickDataRef tick = [self getTick:seq];
		if(!tick)
			continue;
		int targetIndex = tick->tick.time + openTime;
        if([[[FSDataModelProc sharedInstance]marketInfo] isBreakTime:targetIndex marketId:portfolioItem->market_id]) {
            continue;
        }
        targetIndex = [[[FSDataModelProc sharedInstance]marketInfo] subtractTime:targetIndex by:openTime marketId:portfolioItem->market_id];
		if(targetIndex >= indexValue)
		{
			findItFlag = YES;
			break;
		}
		returnSeq = seq;
        if (seq==maxSequenceNo) {
            findItFlag = YES;
			break;
        }
	}
	[lock unlock];
    if(findItFlag)
		return returnSeq;
	else
		return -1;
}

- (int) getSequenceNumByIndexValue:(UInt16)indexValue OpenTime:(UInt16)openTime CloseTime:(UInt16)closeTime portfolioItem:(PortfolioItem *) portfolioItem
{		//回傳-1代表沒找到
	[lock lock];
	int returnSeq = 1;
	BOOL findItFlag = NO;
	for(int seq = 1 ; seq<=maxSequenceNo ; seq++)
	{
		EquityTickDataRef tick = [self getTick:seq];
		if(!tick)
			continue;
		int targetIndex = tick->tick.time + openTime;
        if([[[FSDataModelProc sharedInstance]marketInfo] isBreakTime:targetIndex marketId:portfolioItem->market_id]) {
            continue;
        }
        targetIndex = [[[FSDataModelProc sharedInstance]marketInfo] subtractTime:targetIndex by:openTime marketId:portfolioItem->market_id];
		if(targetIndex >= indexValue)
		{
			findItFlag = YES;
			break;
		}
		returnSeq = seq;
        if (seq==maxSequenceNo) {
            if (tick->tick.time>closeTime-openTime) {
                break;
            }
            findItFlag = YES;
			break;
        }
	}
	[lock unlock];
    if(findItFlag)
		return returnSeq;
	else
		return -1;
}

- (int) twoStockGetSequenceNumByIndexValue:(UInt16)indexValue OpenTime:(UInt16)openTime CloseTime:(UInt16)closeTime portfolioItem:(PortfolioItem *) portfolioItem
{		//回傳-1代表沒找到
	[lock lock];
	int returnSeq = 1;
	BOOL findItFlag = NO;
	for(int seq = 1 ; seq<=maxSequenceNo ; seq++)
	{
		EquityTickDataRef tick = [self getTick:seq];
		if(!tick)
			continue;
		int targetIndex = tick->tick.time + openTime;
        if([[[FSDataModelProc sharedInstance]marketInfo] isBreakTime:targetIndex marketId:portfolioItem->market_id]) {
            continue;
        }
        targetIndex = [[[FSDataModelProc sharedInstance]marketInfo] subtractTime:targetIndex by:openTime marketId:portfolioItem->market_id];
		if(targetIndex == indexValue)
		{
            returnSeq = seq;
			findItFlag = YES;
			break;
		}
		
        if (seq==maxSequenceNo) {
            if (tick->tick.time>closeTime-openTime) {
                break;
            }
            findItFlag = NO;
			break;
        }
	}
	[lock unlock];
    if(findItFlag)
		return returnSeq;
	else
		return -1;
}

- (void)findMaxTickVolume:(PortfolioItem *) item
{
	[lock lock];
//	BOOL findItFlag = NO;
	double preTmpVol = 0.0;
	for(int seq = 1/*,preSeq = 1*/; seq<=maxSequenceNo ; seq++)
	{
		EquityTickDataRef tick = [self getTick:seq];
		if(!tick)
		{
		//	findItFlag = NO;
			continue;
		}
        if([[[FSDataModelProc sharedInstance]marketInfo] isBreakTime:tick->tick.time marketId:item->market_id])
        {
            continue;
        }
		
	//	if(seq == preSeq)		//代表第一筆
		if(preTmpVol == 0)
		{
			maxTickVolume = [CodingUtil ConvertTAValue:tick->tick.volume WithType:&maxTickVolUnit];
			preTmpVol = maxTickVolume;
		}
		else
		{
			double tmpVol;
			UInt16 tmpVolUnit;
			tmpVol = [CodingUtil ConvertTAValue:tick->tick.volume WithType:&tmpVolUnit];
			if(tmpVol == 0)
				continue;
			if(tmpVolUnit > maxTickVolUnit)
			{
				tmpVol *= valueUnitBase[tmpVolUnit - maxTickVolUnit];
			}
			else if(tmpVolUnit < maxTickVolUnit)
			{
				preTmpVol *= valueUnitBase[maxTickVolUnit - tmpVolUnit];
				maxTickVolume *= valueUnitBase[maxTickVolUnit - tmpVolUnit];
				maxTickVolUnit = tmpVolUnit;
			}
			
			double vol;
			 //if(seq == (preSeq+1))
			{
				if(tmpVol >= preTmpVol)	//是總量
				{
					vol = tmpVol - preTmpVol;
				}
				else	//是單量
				{
					vol = tmpVol;
					tmpVol += preTmpVol;
				}
				if(maxTickVolume < vol)
					maxTickVolume = vol;
				preTmpVol = tmpVol;
			}
	//		else
//			{
//				if(tmpVol > preTmpVol)	//是總量
//					preTmpVol = tmpVol;
//				else
//					preTmpVol += tmpVol;
//			}
//			preSeq = seq;
		}
	}
	doFindMaxVol = NO;
//	if(!findItFlag)
//	{
//		doFindMaxVol = NO;
//	}
	if(maxTickVolume >= 0 && maxVolTarget)
	{
		doFindMaxVol = YES;
//		[maxVolTarget performSelectorOnMainThread:@selector(canDoVolView) withObject:nil waitUntilDone:NO];
		maxVolTarget = nil;
	}
	[lock unlock];
}

- (void)setMaxVolNotifyTarget:(id)target
{
	[lock lock];
	maxVolTarget = target;
	[lock unlock];
}

- (double) getMaxTickVolume:(UInt16*)unit;
{
	[lock lock];
	double returnVol;
	*unit = maxTickVolUnit;
	returnVol = maxTickVolume;
	[lock unlock];
	return returnVol;
}

- (void)getTotalPrice:(double*)p TotalVolume:(double*)v Sequence:(UInt32)seq		//抓成交金額與tick算出來的量
{
	[lock lock];
	if(inOutSeq < seq)
	{
		double tmpInVol = 0 , tmpOutVol = 0;
		[self getInOutVolume:&tmpInVol Out:&tmpOutVol Sequence:seq];
	}
	*p = allPrice;
	*v = allTickVolume;
	[lock unlock];
}

- (BOOL)haveMaxTickVolume
{
	[lock lock];
	if(maxTickVolume >= 0)
	{
		[lock unlock];
		return YES;
	}
	else
	{
		[lock unlock];
		return NO;
	}
}

#pragma mark  - TickBox

///////  _tickNoBox  ///////

- (NSUInteger)countOfTickNoBox
{
    return [[self tickNoBox] count];
}

- (void)getTickNoBox:(id *)buffer range:(NSRange)inRange
{
    //[[self tickNoBox] getObjects:buffer range:inRange];
}

- (id)objectInTickNoBoxAtIndex:(NSUInteger)idx
{
    return [[self tickNoBox] objectAtIndex:idx];
}

- (void)insertObject:(id)anObject inTickNoBoxAtIndex:(NSUInteger)idx
{
    [[self tickNoBox] insertObject:anObject atIndex:idx];
}

- (void)insertTickNoBox:(NSArray *)_tickNoBoxArray atIndexes:(NSIndexSet *)indexes
{
    [[self tickNoBox] insertObjects:_tickNoBoxArray atIndexes:indexes];
}

- (void)removeObjectFromTickNoBoxAtIndex:(NSUInteger)idx
{
    [[self tickNoBox] removeObjectAtIndex:idx];
}

- (void)removeTickNoBoxAtIndexes:(NSIndexSet *)indexes
{
    [[self tickNoBox] removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInTickNoBoxAtIndex:(NSUInteger)idx withObject:(id)anObject
{
    [[self tickNoBox] replaceObjectAtIndex:idx withObject:anObject];
}

- (void)replaceTickNoBoxAtIndexes:(NSIndexSet *)indexes withTickNoBox:(NSArray *)_tickNoBoxArray
{
    [[self tickNoBox] replaceObjectsAtIndexes:indexes withObjects:_tickNoBoxArray];
}



- (void)updateMaxVol:(UInt32)sequenceNo		//找最大量 畫圖用
{
//	if(sequenceNo == 1)
//	{
//		return;
//	}
//	if(maxTickVolume >= 0)	//代表Tick其全了 後面新增的
//	{
//		double tmpVol,preTmpVol;
//		UInt16 tmpVolUnit,preTmpVolUnit;
//		EquityTickDataRef tick = [self getTick:sequenceNo];
//		EquityTickDataRef preTick = [self getTick:sequenceNo-1];
//		if(!tick || !preTick)	//找不到Tick 沒辦法update
//			return;
//		tmpVol = [CodingUtil ConvertTAValue:tick->tick.volume WithType:&tmpVolUnit];
//		preTmpVol = [CodingUtil ConvertTAValue:preTick->tick.volume WithType:&preTmpVolUnit];
//		if(tmpVolUnit > maxTickVolUnit)
//		{
//			tmpVol *= [DrawAndScrollController valueUnitBase][tmpVolUnit - maxTickVolUnit];
//		}
//		else if(tmpVolUnit < maxTickVolUnit)
//		{
//			preTmpVol *= [DrawAndScrollController valueUnitBase][maxTickVolUnit - tmpVolUnit];
//			maxTickVolume *= [DrawAndScrollController valueUnitBase][maxTickVolUnit - tmpVolUnit];
//			maxTickVolUnit = tmpVolUnit;
//		}
//		
//		double vol;
//		if(tmpVol >= preTmpVol)	//是總量
//			vol = tmpVol - preTmpVol;
//		else	//是單量
//		{
//			vol = tmpVol;
//		}
//		if(maxTickVolume < vol)
//			maxTickVolume = vol;
//		
//	}
	
}

#pragma mark - 分價表用

/**
 *  回傳所有的tick分價資訊
 *
 *  @return 一個包含tick分價資訊的NSArray
 */
- (NSArray *)allPriceByVolumeInformation
{
    return [self.priceByVolumeInformation copy];
}
/**
 *  當tick下來時，call這個method可以把現有的tick依照價格分成幾個群組，放進陣列裡面
 *
 *  @return YES代表分類成功，NO代表失敗
 */
- (BOOL)arrangeTicksInformationInGroups:(EquityTickParam *) tickParam
{
    if (tickParam == nil) {
        return NO;
    }
    
    //已存在該價格，更新物件
    FSPriceByVolumeData *data = [self findPriceByVolumeDataWith:tickParam];
    if(data != nil)
    {
        EquityTickData *tick = &(tickParam->etick);
        
        UInt16 tickVolUnit = 0;
        double tickVol = [CodingUtil ConvertTAValue:tick->tick.volume WithType:&tickVolUnit];
        tickVol *= pow(1000,tickVolUnit);
        double tickPrice = [CodingUtil ConvertPrice:tick->tick.price RefPrice:[snapshot referencePrice]];
        double bid = [CodingUtil ConvertPrice:tick->bid RefPrice:tickPrice];
        double ask = [CodingUtil ConvertPrice:tick->ask RefPrice:tickPrice];
        
        data.volume += tickVol;
        data.tickCount++;
        
        double e = 0.001;
        
        if(fabs(tickPrice -bid)<e)		//買價成交
            data.tradeOnAsk++;
        else if(fabs(tickPrice - ask)<e)	//賣價成交
            data.tradeOnBid++;
        else if(fabs(tickPrice -bid) < fabs(tickPrice -ask))	//較接近買價
            data.tradeOnAsk++;
        else
            data.tradeOnBid++;
    }
    //此價格尚未出現過，加入新物件
    else {
        FSPriceByVolumeData *newData = [[FSPriceByVolumeData alloc] init];
        EquityTickData *tick = &(tickParam->etick);
        
        UInt16 tickVolUnit = 0;
        double tickVol = [CodingUtil ConvertTAValue:tick->tick.volume WithType:&tickVolUnit];
        tickVol *= pow(1000,tickVolUnit);
        double tickPrice = [CodingUtil ConvertPrice:tick->tick.price RefPrice:[snapshot referencePrice]];
        double bid = [CodingUtil ConvertPrice:tick->bid RefPrice:tickPrice];
        double ask = [CodingUtil ConvertPrice:tick->ask RefPrice:tickPrice];
        
        newData.price = tickPrice;
        newData.volume = tickVol;
        newData.tickCount++;
        
        double e = 0.001;
        
        if(fabs(tickPrice -bid)<e)		//買價成交
            newData.tradeOnAsk++;
        else if(fabs(tickPrice - ask)<e)	//賣價成交
            newData.tradeOnBid++;
        else if(fabs(tickPrice -bid) < fabs(tickPrice -ask))	//較接近買價
            newData.tradeOnAsk++;
        else
            newData.tradeOnBid++;
        
        [_priceByVolumeInformation addObject:newData];
    }
    
    for (FSPriceByVolumeData *data in self.priceByVolumeInformation) {
        //直接用data.tickCount/maxSequenceNo會是0，因為兩個都是UInt，不會有小數點
        double tickCount = data.tickCount;
        data.percentage = tickCount/maxSequenceNo*100;
    }
    
    [_priceByVolumeInformation sortUsingComparator:^NSComparisonResult(FSPriceByVolumeData *obj1, FSPriceByVolumeData *obj2) {
        NSComparisonResult result =[@(obj1.price) compare:@(obj2.price)];
        if (result == NSOrderedAscending)
            return NSOrderedDescending;
        if (result == NSOrderedDescending)
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
    return YES;
}

- (FSPriceByVolumeData *)findPriceByVolumeDataWith:(EquityTickParam *) tickParam
{
    EquityTickData *tick = &(tickParam->etick);
    double tickPrice = [CodingUtil ConvertPrice:tick->tick.price RefPrice:[snapshot referencePrice]];
//    NSPredicate *pricePredicate = [NSPredicate predicateWithFormat:@"(price - %f) < 0.01", tickPrice];
    NSPredicate *pricePredicate = [NSPredicate predicateWithBlock:^BOOL(FSPriceByVolumeData *evaluatedObject, NSDictionary *bindings) {
        if (fabs(evaluatedObject.price - tickPrice) < 0.01) {
            return YES;
        }
        else {
            return NO;
        }
    }];
//    NSPredicate *pricePredicate = [NSPredicate predicateWithFormat:@"price - %f > ", tickPrice];
    NSArray *filteredDatas = [self.priceByVolumeInformation filteredArrayUsingPredicate:pricePredicate];
    
    if ([filteredDatas count] > 0) {
        return filteredDatas.firstObject;
    }
    else {
        return nil;
    }
}


-(void)recomputeVolume{
    for (int i=1; i<=[self countOfTickNoBox]; i++) {
        EquityTickDataRef tickData = [self getTick:i];
        
        if (i>1) {
            if (tickData->tick.volumeType==1) {
                EquityTickDataRef oldTickData = [self getTick:i-1];
                
                double oldVol = [self getRealValue:oldTickData->tick.volumeDouble Unit:oldTickData->tick.volumeUnit];
                double newVol = [self getRealValue:tickData->tick.volumeDouble Unit:tickData->tick.volumeUnit];
                
                tickData->tick.volumeDouble = [CodingUtil ConvertDouble:oldVol+newVol WithType:&tickData->tick.volumeUnit];
                
                
            }else{
                tickData->tick.volumeDouble = [CodingUtil ConvertTAValue:tickData->tick.volume WithType:&tickData->tick.volumeUnit];
            }
        }else{
            tickData->tick.volumeDouble = [CodingUtil ConvertTAValue:tickData->tick.volume WithType:&tickData->tick.volumeUnit];
        }
        int cell = i / COUNT_PER_CELL;
        int pos  = i % COUNT_PER_CELL;
        ticks[cell][pos] = *tickData;
    }
}

-(double)getRealValue:(double)value Unit:(NSInteger)unit
{
	double realValue = value * pow(1000, unit);
	return realValue;
}

@end
