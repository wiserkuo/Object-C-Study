//
//  FSMultiChartCellDataSource.h
//  Bullseye
//
//  Created by KevinShen on 13/8/15.
//
//

#import <Foundation/Foundation.h>

@class PortfolioItem;

@protocol FSMultiChartPlotDataSource <NSObject>

@property (nonatomic, strong) PortfolioItem *portfolioItem;

- (id)initWithPortfolioItem:(PortfolioItem*)aPortfolioItem;
- (BOOL)startWatch;
- (void)stopWatch;
@end
