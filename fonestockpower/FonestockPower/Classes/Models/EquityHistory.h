//
//  EquityHistory.h
//  FonestockPower
//
//  Created by Neil on 14/5/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoricalParm.h"

@interface EquityHistory : NSObject

- (void)assignIdentCodeSymbol:(NSString *)identCodeSymbol;

- (NSString *)getIdenCodeSymbol;

- (BOOL)loadFromFile:(UInt8) type;
- (UInt16)quertyDataDate:(UInt8) tickType;

- (BOOL)loadWithTickType:(UInt8) tickType;

- (void)setLatestData:(UInt8) type value:(BOOL)value;

- (void)addHistoricTicks:(HistoricalParm*) param;

- (BOOL)isLatestData:(UInt8) type;

- (id)copyHistoricTick: (UInt8) tickType sequenceNo: (UInt32) sequenceNo;

- (void)todayOtherMK_finalize;
@end
