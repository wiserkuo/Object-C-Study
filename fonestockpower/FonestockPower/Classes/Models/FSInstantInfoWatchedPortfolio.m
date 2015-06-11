//
//  FSInstantInfoWatchedPortfolio.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/28.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSInstantInfoWatchedPortfolio.h"

@implementation FSInstantInfoWatchedPortfolio

+ (FSInstantInfoWatchedPortfolio *)sharedFSInstantInfoWatchedPortfolio
{
    static dispatch_once_t onceQueue;
    static FSInstantInfoWatchedPortfolio *fSInstantInfoWatchedPortfolio = nil;
    
    dispatch_once(&onceQueue, ^{ fSInstantInfoWatchedPortfolio = [[self alloc] init]; });
    return fSInstantInfoWatchedPortfolio;
}

-(void)setPortfolioItem:(PortfolioItem *)portfolioItem
{
    if(_comparedPortfolioItem == nil){
        
    }
    else if([portfolioItem->fullName isEqualToString:_comparedPortfolioItem->fullName]){
        PortfolioItem *tempStore = _portfolioItem;
        if (tempStore) {
//            _portfolioItem = _comparedPortfolioItem;
            _comparedPortfolioItem = tempStore;
        }
    }
    _portfolioItem = portfolioItem;
}

@end
