//
//  FSEquityDrawViewController.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/13.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSEquityDrawViewTickPlotDataSourceDelegate.h"
#import "FSEquityDrawButtonSectionDelegate.h"
#import "FSCDP.h"

@protocol FSEquityDrawViewTickPlotDataSourceProtocol;

enum CrossHairInfoPanelPosition {
    Leftside = 0,
    RightSide = 1
};

@interface FSEquityDrawViewController : FSUIViewController <FSEquityDrawViewTickPlotDataSourceDelegate, CPTPlotSpaceDelegate, UIScrollViewDelegate, FSEquityDrawButtonSectionDelegate, FSCDPDelegate,UIActionSheetDelegate>{
    NSRecursiveLock *dataLock;
}
@property (nonatomic, strong) NSObject<FSEquityDrawViewTickPlotDataSourceProtocol> *tickPlotDataSource;
//@property (nonatomic, strong) PortfolioItem *portfolioItem;
@property (nonatomic, assign) BOOL isAverageValueLinesVisible;
@property (nonatomic, assign) BOOL isCDPVisible;
@property (nonatomic) double minPrice;
@property (nonatomic) double maxPrice;
@property (nonatomic) BOOL changeYRangeForCDP;
@property (nonatomic) BOOL twoStock;
@property (nonatomic) BOOL comparedValue;

- (void)insertMainPortfolioData:(NSMutableArray *) tickNoBox;
- (void)insertComparedPortfolioData:(NSMutableArray *) tickNoBox;

- (void)reloadMainPortfolioData;
- (void)reloadComparedPortfolioData;
- (void)reloadReferencePricePlot;
- (void)reloadCDP;
- (void)reloadPriceGraph;
- (void)reloadVolumeGraph;
- (void)reloadInfoPanel:(NSObject *) snapshot_src;

- (void)clearCachedMainTickBox;
- (void)clearCachedComparedTickBox;

- (void)clearSnapshotPriceLabel;
- (void)clearVolumeLabel;
- (void)clearCDPLabel;

-(void)sectorIdCallBack:(NSMutableArray *)dataArray;

@end
