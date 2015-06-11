//
//  FSMultiChartPlotDataArriving.h
//  Bullseye
//
//  Created by KevinShen on 13/9/3.
//
//

#import <Foundation/Foundation.h>
#import "TickDataSource.h"

@class FSMultiChartPlotData;

@protocol FSMultiChartPlotDataArriving <NSObject>

- (void)multiChartPlotData:(FSMultiChartPlotData *) multiChartPlotData dataSource:(NSObject <TickDataSourceProtocol> *)dataSource;

@end
