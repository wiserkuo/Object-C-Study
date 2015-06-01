//
//  FSEquityInfoPanel.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/29.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snapshot.h"

@interface FSEquityInfoPanel : UIScrollView

@property (nonatomic, strong) PortfolioItem *portfolioItem;

- (void)reSetInfoPanel;
- (id)initWithPortfolioItem:(PortfolioItem*)aPortfolioItem;
- (void)reloadDataWithSnapshot:(EquitySnapshotDecompressed *) snapshot;
- (void)reloadBValueSnapshot:(FSSnapshot *)snapshot;
- (void)reloadMarketInfo:(NSMutableArray *)dataArray;
@end
