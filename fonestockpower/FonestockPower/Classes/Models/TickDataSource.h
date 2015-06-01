//
//  TickDataSource.h
//  Bullseye
//
//  Created by johaiyu on 2008/12/12.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tick.h"

@class PortfolioItem;
@protocol TickDataSourceProtocol

// These method should be thread safed.

- (UInt32)tickCount;
// Sequence number starts from 1.
- (TickDecompressed *)copyTickAtSequenceNo:(UInt32)sequenceNo;
//- (EquitySnapshotDecompressed *)equitySnapshot;

- (NSString *)getIdenCodeSymbol;
- (void)lock;
- (void)unlock;

@property (readonly) NSMutableArray *tickNoBox;

// LPCB use
@property (readonly) NSMutableArray *ticksData;


@property (nonatomic, readonly) float progress;

@optional

- (BOOL) getTimePrice:(UInt16*)tickTime Price:(double*)tickPrice Sequence:(UInt32)seq;
- (BOOL) getTimeVolume:(UInt16*)tickTime Volume:(double*)tickVol VolUnit:(UInt16*)tickVolUnit Sequence:(UInt32)seq;
- (BOOL) getPriceVolume:(double*)tickPrice Volume:(double*)tickVol VolUnit:(UInt16*)tickVolUnit Sequence:(UInt32)seq;
- (double) getMaxTickVolume:(UInt16*)unit;
- (int) getSequenceNumByIndexValue:(UInt16)indexValue OpenTime:(UInt16)openTime portfolioItem:(PortfolioItem *) portfolioItem;
- (int) getSequenceNumByIndexValue:(UInt16)indexValue OpenTime:(UInt16)openTime CloseTime:(UInt16)closeTime portfolioItem:(PortfolioItem *) portfolioItem;
- (BOOL) getInOutVolume:(double*)inVol Out:(double*)outVol Sequence:(UInt32)seq;
- (void)getTotalPrice:(double*)p TotalVolume:(double*)v Sequence:(UInt32)seq;		//抓成交金額與tick算出來的量
-(float)getSameTickTimeVolume:(UInt16)time BySequence:(UInt32)seq;

@end

@protocol HistoricTickDataSourceProtocol

// These method should be thread safed.

- (UInt32)tickCount:(UInt8) tickType;
// Sequence number starts from 1.
- (id)copyHistoricTick: (UInt8) tickType sequenceNo: (UInt32) sequenceNo;
- (id)copyHistoricTick:(UInt8)tickType Date:(UInt16)date;
- (NSString *)getIdenCodeSymbol;

@optional

- (BOOL)isLatestData:(UInt8) type;
- (UInt16)quertyDataDate:(UInt8) tickType;


@end
