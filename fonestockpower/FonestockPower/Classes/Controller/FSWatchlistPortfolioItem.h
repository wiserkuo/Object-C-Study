//
//  FSWatchlistPortfolioItem.h
//  WirtsLeg
//
//  Created by KevinShen on 13/9/24.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSWatchlistItemProtocol.h"

@class PortfolioItem;

@interface FSWatchlistPortfolioItem : NSObject <FSWatchlistItemProtocol>

@property(nonatomic, strong) NSIndexPath *indexPath;

- (NSUInteger)count;
- (PortfolioItem *) portfolioItem:(NSIndexPath *) indexPath;
- (PortfolioItem *) portfolioItemAtIndex:(NSUInteger) index;
- (NSString *)name:(NSIndexPath *) indexPath;
- (BOOL)editable:(NSUInteger) watchedIndex;
- (void)sortDescending:(BOOL) descending;
@end
