//
//  FSPriceByVolumeTableViewDelegate.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/7.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSPriceByVolumeTableViewDelegate.h"
#import "FSPriceByVolumeTableViewCell.h"
#import "FSArrayTableViewDataSource.h"
#import "TradeDistributeIn.h"

@interface FSPriceByVolumeTableViewDelegate ()
@end

@implementation FSPriceByVolumeTableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 33.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.priceByVolumeTableViewHeaderView;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    EquityTick *equityTick = [[[FSDataModelProc sharedInstance]portfolioTickBank] getEquityTick:[_portfolioItem getIdentCodeSymbol]];
//    FSPriceByVolumeTableViewCell *priceByVolumeTableViewCell = (FSPriceByVolumeTableViewCell *)cell;
//    FSArrayTableViewDataSource *arrayTableViewDataSource = (FSArrayTableViewDataSource *)tableView.dataSource;
//    TradeDistributeParam *data = (TradeDistributeParam *) arrayTableViewDataSource.allItems[indexPath.row];

}

@end
