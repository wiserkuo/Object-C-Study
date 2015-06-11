//
//  FSPriceByVolumeTableViewController.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/5.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "DataArriveProtocol.h"
@interface FSPriceByVolumeTableViewController : UIViewController <DataArriveProtocol>
@property (nonatomic, strong) UITableView *priceByVolumeTableView;
@property (nonatomic, strong) PortfolioItem *portfolioItem;

-(void)sectorIdCallBack:(NSMutableArray *)dataArray;
@end
