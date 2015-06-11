//
//  EquityTick.h
//  Bullseye
//
//  Created by steven on 2008/12/12.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TickDataSource.h"
#import "Tick.h"
#import "DataArriveProtocol.h"
#import "Snapshot.h"
#import "FSSnapshot.h"
#import "FSTickData.h"

#define MAX_CELL_COUNT   200
#define COUNT_PER_CELL   100

#define TW_TICKS_COUNT 270


@class PortfolioItem;

@interface EquityTick : NSObject <TickDataSourceProtocol>
{
	NSString *identCodeSymbol;
    
    EquitySnapshotDecompressed *snapshot;
	EquityTickDataRef ticks[MAX_CELL_COUNT];
	UInt16 maxSequenceNo, firstBreakNo,lastTickNo;
	NSRecursiveLock *lock;
	double maxTickVolume;
	UInt16 maxTickVolUnit;
	
	id maxVolTarget;
	BOOL doFindMaxVol;
	
	double inVolume;
	double outVolume;
	int inOutSeq;
	
	double allTickVolume;
	double allPrice;
	
	UInt16 seqOfLastTick;
	double lastTickPrice;
@public
	UInt8 updateTickFlag;
}

@property (readonly) EquitySnapshotDecompressed *snapshot;
@property (readonly) FSSnapshot *snapshot_b;

@property (strong)   NSString *identCodeSymbol;
@property (readonly) UInt16 maxSequenceNo;
@property (readonly) UInt16 firstBreakNo;
@property (readonly) UInt16 lastTickNo;
@property (readonly) NSMutableArray *tickNoBox;
@property (readonly) NSArray *allPriceByVolumeInformation;
@property (nonatomic, readonly) float progress;
@property int maxLastTimeIndex;
@property FSBTimeFormat *maxLastTime;

@property NSMutableArray *ticksData;
- (void)addEquityTicks:(NSArray *)newTicksData isLastTicksData:(BOOL)isLastTicksData;




- (void)updateSnapshotBValue:(FSSnapshot *)snapshot;

- (void)assignIdentCodeSymbol:(NSString *)identCodeSymbol;
- (NSString *)getIdenCodeSymbol;
- (void)updateSnapshotWarningCode:(UInt8)warningCode;
- (void)updateSnapshotDelayClose:(UInt8)delayClose;
- (void)updateDailyStatus:(UInt8)dailyStatus;
- (BOOL)updateSnapshot:(Snapshot *)snapshot;
- (void)addEquityTick:(EquityTickParam *)tickParam WithSequenceNo:(UInt16)sequenceNo;
- (void)addIndexTick:(IndexTickParam *)tickParam WithSequenceNo:(UInt16)sequenceNo;
- (EquityTickDecompressed *)copyTickAtSequenceNo:(UInt32)sequenceNo;
- (void)lock;
- (void)unlock;
- (void)clearTicks;
- (void)setMaxVolNotifyTarget:(id)target;
- (void)findMaxTickVolume:(PortfolioItem *) item;
- (BOOL)haveMaxTickVolume;
- (void)updateMaxVol:(UInt32)sequenceNo;	//找最大量 畫圖用

-(void)recomputeVolume;
@end
