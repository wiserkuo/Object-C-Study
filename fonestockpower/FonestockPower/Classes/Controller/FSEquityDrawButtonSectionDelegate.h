//
//  FSEquityDrawButtonSectionDelegate.h
//  WirtsLeg
//
//  Created by KevinShen on 2014/2/5.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSEquityDrawButtonSectionDelegate <NSObject>
@property (nonatomic, assign) BOOL isCDPVisible;
@property (nonatomic, assign) BOOL isAverageValueLinesVisible;
- (void)addComparedPortfolioPlot;
- (void)showComparedPortfolioPlot;
- (void)hideComparedPortfolioPlot;
- (BOOL)isComparedPortfolioPlotVisible;
- (void)addAverageValueLine;
- (void)showAverageValueLine;
- (void)hideAverageValueLine;
- (void)showCDP;
- (void)hideCDP;
- (void)resetSelectComparePortfoioButtonTitle;
- (void)changeStock;
- (void)addStockInUserStock;
- (void)FitPriceGraphScope;;
- (void)showCrossInfoPanel;
- (void)hideCrossInfoPanel;
- (BOOL)isCrossInfoPanelVisible;
- (void)hideCrossHair;
- (void)showCrossHair;
- (BOOL)isCrossHairVisible;
@end
