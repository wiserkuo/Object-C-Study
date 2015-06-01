//
//  FSPriceByVolumeTableViewDelegate.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/7.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSPriceByVolumeTableViewDelegate : NSObject <UITableViewDelegate>
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@property (nonatomic, weak) UIView *priceByVolumeTableViewHeaderView;

@end
