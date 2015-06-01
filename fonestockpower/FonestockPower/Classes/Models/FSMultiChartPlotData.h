//
//  FSMultiChartCellDataSource.h
//  Bullseye
//
//  Created by Shen Kevin on 13/8/9.
//
//

#import <Foundation/Foundation.h>
#import "Portfolio.h"
#import "FSMultiChartPlotDataSource.h"
#import "FSMultiChartPlotDataArriving.h"

@interface FSMultiChartPlotData : NSObject <CPTPlotDataSource, DataArriveProtocol, FSMultiChartPlotDataSource>
@property (nonatomic, strong) PortfolioItem *portfolioItem;

/*
 dataSource一定要是weak，不然會因為PortfolioTick retain了EquityNotification，EquityNotification再retain FSMultiChartPlotData(放進queue裡會retain)
 而造成retain cycle
 */
@property (nonatomic, weak) NSObject <TickDataSourceProtocol> *dataSource;

@property (nonatomic, weak) NSObject<FSMultiChartPlotDataArriving> *delegate;
@property (readonly) CPTGraphHostingView *hostView;

- (id)initWithPortfolioItem:(PortfolioItem*)aPortfolioItem;

- (BOOL)startWatch;
- (void)stopWatch;
- (void)reloadGraph;

- (UIImage *)imageOfChart:(CGRect) frame;
@end
