//
//  FSCDP.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/26.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//
/*
ＣＤＰ操作

　　1．計算方法

　　（１）先計算ＣＤＰ值（需求值）
　　ＣＤＰ＝（Ｈ＋Ｌ＋２Ｃ）÷４
　　Ｈ：前一日最高價，Ｌ：前一日最低價，Ｃ：前一日收市價

（２）計算
　　ＡＨ（最高值）＝ＣＤＰ＋（Ｈ－Ｌ）ＮＨ（近高值）＝ＣＤＰ×２－Ｌ
　　ＡＬ（最低值）＝ＣＤＰ－（Ｈ－Ｌ）ＮＬ（近低值）＝ＣＤＰ×２－Ｈ

　　則此五個數值的排列順序為（從最高到最低）：ＡＨ，ＮＨ，ＣＤＰ，ＮＬ，ＡＬ。

　　2．運用原則

　　找出這五個數值之後，即用前一天的行情波動來將今日的未來行情做一個高低等級
的劃分，分析者可利用這個高低區分來判斷當日的走勢。研判的關鍵是開市價在ＣＤＰ
五個數值的哪個位置，因開市價通常由市場買賣雙方心理期望合理價的折衷後形成的，
影響當天的走勢。

（１）在波動並不很大的情況下，即開市價處在近高值與近低值之間，通常交易者可以
在近低值的價買進，而在近高期的價位賣出；

　　（２）在波動較大的情況下，即開市價開在最高值或最低值附近時，意味著跳空開
高或跳空開低，是一個大行情的發動開始，因此交易者可在最高值的價位去追買，最低
值的價位去追賣。通常一個跳空，意味著一個強烈的漲跌，應有相當的利潤。

　　3．功能分析

　　（１）ＣＤＰ最適合於上下振蕩的盤局行情，選擇高賣低買的區間賺取短線利潤。

（２）對於大漲大跌的行情，尤其是衝破阻力價和支撐位時，為避免軋空或橫壓，
需設停損點，防止突發性利多或利空的影響。
 */

#import <Foundation/Foundation.h>

@class CPTScatterPlot;

@protocol FSCDPDelegate <NSObject>

- (void)clearCDPLabel;
- (void)reloadCDP;

@end


@interface FSCDP : NSObject <CPTPlotDataSource, HistoricDataArriveProtocol>{
    NSRecursiveLock *dataLock;
}
@property (nonatomic, readonly) CPTScatterPlot *ahPlot;
@property (nonatomic, readonly) CPTScatterPlot *nhPlot;
@property (nonatomic, readonly) CPTScatterPlot *cdpPlot;
@property (nonatomic, readonly) CPTScatterPlot *alPlot;
@property (nonatomic, readonly) CPTScatterPlot *nlPlot;

@property (nonatomic, readonly) float ah;
@property (nonatomic, readonly) float nh;
@property (nonatomic, readonly) float cdp;
@property (nonatomic, readonly) float al;
@property (nonatomic, readonly) float nl;
@property (nonatomic, weak) UIViewController<FSCDPDelegate> *delegate;

@property (nonatomic, weak) PortfolioItem *portfolioItem;

- (BOOL)isDataEmpty;
- (id)initWithPortfolioItem:(PortfolioItem*)aPortfolioItem;
- (void)startWatch;
- (void)stopWatch;
- (void)reloadData;
- (void)clearData;
/**
 *  輸入這些參數，就可以計算出CDP系統所需的數值
 *
 *  @param highestPrice 前一日最高價
 *  @param lowestPrice  前一日最低價
 *  @param openPrice    前一日開盤價
 *  @param closePrice   前一日收盤價
 */
//- (void)computeWith:(double) highestPrice lowestPrice:(double) lowestPrice openPrice:(double) openPrice closePrice:(double) closePrice;

@end
