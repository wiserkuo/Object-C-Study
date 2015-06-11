//
//  FSEquityDrawViewControllerDelegate.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/13.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Snapshot.h"

@protocol FSEquityDrawViewTickPlotDataSourceDelegate <NSObject>
- (void)insertMainPortfolioData:(NSMutableArray *) tickNoBox;
- (void)insertComparedPortfolioData:(NSMutableArray *) tickNoBox;
- (void)clearCachedMainTickBox;
- (void)clearCachedComparedTickBox;
- (void)reloadMainPortfolioData;
- (void)reloadComparedPortfolioData;
- (void)reloadReferencePricePlot;
- (void)reloadCDP;
- (void)reloadPriceGraph;
- (void)reloadVolumeGraph;
- (void)reloadInfoPanel:(NSObject *) snapshot_src;
- (void)configureXRange;
- (void)configureYRange:(EquitySnapshotDecompressed *) snapshot;
- (void)configureYRangeBValue:(FSSnapshot *) snapshot;
- (void)scaleComparedPriceGraphToFitPrice:(EquitySnapshotDecompressed *) snapshot;
- (void)scaleComparedPriceGraphToFitPriceWithBValue:(FSSnapshot *) snapshot;
- (void)clearSnapshotPriceLabel;
- (void)clearVolumeLabel;
- (void)clearCDPLabel;
- (void)showVolumePlot;
- (void)hideVolumePlot;

- (void)scaleComparedVolumeGraphToFitComparedVolume;
- (void)scaleVolumeAndShow;

- (void)drawXAxisGridLineOnPriceGraph;
- (void)drawXAxisGridLineOnVolumeGraph;

@end
