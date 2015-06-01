//
//  FSInstantInfoWatchedPortfolio.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/28.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSInstantInfoWatchedPortfolio : NSObject
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@property (nonatomic, strong) PortfolioItem *comparedPortfolioItem;

- (void)setPortfolioItem:(PortfolioItem *)portfolioItem;
+ (FSInstantInfoWatchedPortfolio *)sharedFSInstantInfoWatchedPortfolio;
@end
