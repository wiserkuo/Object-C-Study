//
//  FSPriceVolumeChartDataSource.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/11.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "FSPriceVolumeViewControllerDelegate.h"

@protocol TDNotifyProtocol, DataArriveProtocol;

@interface FSPriceVolumeChartDataSource : NSObject <CPTBarPlotDataSource, DataArriveProtocol, TDNotifyProtocol>
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@property (nonatomic, assign) NSUInteger singleDayIndex;//使用者設定的單日天數
@property (nonatomic, assign) NSUInteger periodIndex;//使用者設定的區間
@property (nonatomic) BOOL singleDay;
@property (nonatomic) BOOL periodDay;
@property (nonatomic, strong) NSMutableArray *periodData;
@property (nonatomic, strong) NSMutableArray *singleDayData;
@property (nonatomic, weak) UIViewController<FSPriceVolumeViewControllerDelegate> *priceVolumeViewController;
- (void)sendSingleDayRequest:(NSUInteger) option;
- (void)sendPeriodRequest:(NSUInteger) option;
- (BOOL)startWatch;
- (void)stopWatch;
- (NSDictionary *)findNearestPriceVolumeByYAxisIndex:(NSNumber *) yAxisIndex inSingleDayData:(BOOL) enableSingleDaySearching inAccumulationData:(BOOL) enableAccumulationDataSearching;
- (float)findNearestPriceVolumeByPrice:(float) price inSingleDayData:(BOOL) enableSingleDaySearching inAccumulationData:(BOOL) enableAccumulationDataSearching;
-(void)setTodayDefaultData:(NSMutableArray *)array;
-(NSInteger)findBlock:(NSInteger)blockCount;
@end
