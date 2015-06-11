//
//  FSMultiChartCellDataSourceManager.h
//  Bullseye
//
//  Created by KevinShen on 13/8/13.
//
//

#import <Foundation/Foundation.h>
#import "FSMultiChartPlotDataArriving.h"
#import "FSMultiChartPlotManagerDelegate.h"
#import "FSWatchlistItemProtocol.h"

@interface FSMultiChartPlotManager : NSObject <FSMultiChartPlotDataArriving>

@property (nonatomic, strong) NSMutableArray *plotDataSources;
@property (nonatomic, weak) NSObject<FSMultiChartPlotManagerDelegate> *delegate;

//Singleton
+ (FSMultiChartPlotManager *)sharedInstance;

- (void)generatePlotDataSourceForItem:(NSObject<FSWatchlistItemProtocol> *) watchlistItem;
- (void)watchEquityForAllItems;
- (void)watchEquityForVisibleItems:(NSArray *) indexPaths;
- (void)stopWatchEquityForAllItems;
- (void)multiChartPlotData:(FSMultiChartPlotData *) multiChartPlotData dataSource:(NSObject <TickDataSourceProtocol> *)dataSource;

@end
