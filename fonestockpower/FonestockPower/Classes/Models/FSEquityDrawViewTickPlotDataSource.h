//
//  FSEquityDrawViewTickPlotDataSource.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/13.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSEquityDrawViewTickPlotDataSourceProtocol.h"
#import "FSEquityDrawViewTickPlotDataSourceDelegate.h"

@interface FSEquityDrawViewTickPlotDataSource : NSObject <FSEquityDrawViewTickPlotDataSourceProtocol>{
    NSRecursiveLock * dataLock;
    BOOL drawGridLine;
}
@property (nonatomic, weak) UIViewController<FSEquityDrawViewTickPlotDataSourceDelegate> *delegate;
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@property (nonatomic, strong) PortfolioItem *comparedPortfolioItem;
@property (nonatomic, strong) NSObject <TickDataSourceProtocol> *dataSource;
@property (nonatomic, strong) NSObject <TickDataSourceProtocol> *comparedDataSource;
@property (nonatomic, readonly) UInt16 chartOpenTime;
@property (nonatomic, readonly) UInt16 chartCloseTime;
@property (nonatomic, readonly) UInt16 chartBreakTime;
@property (nonatomic, readonly) UInt16 chartReopenTime;
@property (nonatomic, readonly) UInt16 totalTime;
@property (nonatomic, readonly) double maxMainVolume;
@property (nonatomic, readonly) double maxComparedVolume;
@property (nonatomic, readonly) NSArray *allVolumes;//裡面裝tickCount數量的volume
@property (nonatomic, readonly) NSArray *allComparedVolumes;//裡面裝tickCount數量的volume
@property (nonatomic, strong) NSMutableArray *volumeStore;//裡面裝tickCount數量的volume
@property (nonatomic, strong) NSMutableArray *volumeStoreInSameTime;//裡面time數量的volume
@property (nonatomic, strong) NSMutableArray *comparedVolumeStore;//裡面裝tickCount數量的volume
@property (nonatomic, strong) NSMutableArray *comparedVolumeStoreInSameTime;//裡面time數量的volume
@property (nonatomic, strong) NSMutableArray *tickStoreInSameTime;
@property (nonatomic, strong) NSMutableArray *comparedTickStoreInSameTime;
@property (nonatomic, strong) NSMutableArray *beforeFirstTickTimeData;
@property (nonatomic, strong) NSMutableArray *beforeFirstTickData;

@property (nonatomic, strong) NSMutableArray *comparedBeforeFirstTickTimeData;
@property (nonatomic, strong) NSMutableArray *comparedBeforeFirstTickData;

@property (nonatomic, strong) NSMutableArray *AVGBeforeFirstTickTimeData;
@property (nonatomic, strong) NSMutableArray *AVGBeforeFirstTickData;

- (id)initWithPortfolioItem:(PortfolioItem*)aPortfolioItem;
- (id)initWithPortfolioItem:(PortfolioItem*)aPortfolioItem comparedPortfolioItem:(PortfolioItem*)aComparedPortfolioItem;

- (BOOL)startWatchComparedEquity;
- (void)stopWatchComparedEquity;
- (void)updateMarketTime;

@end
