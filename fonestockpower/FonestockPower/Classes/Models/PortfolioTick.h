//
//  PortfolioTick.h
//  FonestockPower
//
//  Created by Neil on 14/5/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EquityTick.h"
#import "Snapshot.h"
#import "HistoricalParm.h"
#import "MessageType06.h"
#import "MessageType03.h"

typedef enum
{
	kTickTypeEquity,
	kTickTypeHistoricData
} TickType;

typedef enum
{
    GetTickCommand,
    GetDiscreteTickCommand
} CommandType;

@interface PortfolioTick : NSObject

- (id)initWithType:(TickType)tp;

- (EquitySnapshotDecompressed*) getSnapshotFromIdentCodeSymbol: (NSString *)identCodeSymbol;

- (void)goGetTickByIdentSymbolForStock :(NSString*)is;

- (void)addTick:(NSArray *)tickParams;
- (void)addTick:(NSArray *)tickParams recv_complete:(NSNumber *)tick_rev_complete;
- (void)updateTickDataByIdentCodeSymbol:(NSString *)identSymbol;
- (void)setTaget:(NSObject<DataArriveProtocol> *)target IdentCodeSymbol:(NSString *)identSymbol;
-(void)removeKeyWithTaget:(NSObject<DataArriveProtocol> *)target IdentCodeSymbol:(NSString *)identSymbol;
-(void)removeIndexQuotesAllKeyWithTaget:(NSObject<DataArriveProtocol> *)target;

- (void)watchTarget:(NSObject <DataArriveProtocol> *)target ForEquity:(NSString *)identCodeSymbol;
- (BOOL)watchTarget:(NSObject <HistoricDataArriveProtocol> *)target ForEquity:(NSString *)identCodeSymbol tickType:(UInt8)ttp;
- (BOOL)GetCurData:(NSObject <HistoricDataArriveProtocol> *)target ForEquity:(NSString *)identCodeSymbol tickType:(UInt8)ttp;
- (void)getEODActionForEquity:(NSString *)identCodeSymbol tickType:(UInt8)ttp SymbolType:(NSString *)symbolType;
- (void)watchTarget:(NSObject <DataArriveProtocol> *)target ForEquity:(NSString *)identCodeSymbol GetTick:(BOOL)getTick;
- (void)watchTarget:(NSObject <DataArriveProtocol> *)target ForEquity:(NSString *)identCodeSymbol GetDiscreteTick:(BOOL)getDiscreteTick;
- (void)stopWatch:(NSObject *)target ForEquity:(NSString *)identCodeSymbol;
- (void)stopWatch:(NSObject *)target ForEquity:(NSString *)identCodeSymbol discreteTick:(BOOL) discreteTick;
- (void)removeWatch:(NSObject *)target;
- (void)addHistoricTick:(HistoricalParm *)param;

- (EquityTick*)getEquityTick:(NSString *)identCodeSymbol;

- (void)updateEquitySnapshot:(SnapshotParam *)snapshot;
- (EquitySnapshotDecompressed*) getSnapshot: (UInt32)securityNo;



// connor
- (FSSnapshot *)getSnapshotBvalue:(UInt32)securityNo;
- (FSSnapshot *)getSnapshotBvalueFromIdentCodeSymbol:(NSString *)identCodeSymbol;



- (void)addClearSnapshot:(MessageType06Param *)tmParam;

- (BOOL)addEquity:(NSString *)identCodeSymbol WithSecurityNo:(UInt32)securityNo;
- (void)removeEquity:(NSString *)identCodeSymbol;
- (void)sendGetHistoricTick;

- (void)addPromptTick:(NSArray *)tickParams;

- (void)addNearestBidAsk:(MessageType03 *)baParams;

@end
