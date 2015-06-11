//
//  FSWatchlistItemProtocol.h
//  WirtsLeg
//
//  Created by KevinShen on 13/9/24.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSWatchlistItemProtocol <NSObject>

- (NSUInteger) count;
- (PortfolioItem *) portfolioItem:(NSIndexPath *) indexPath;
- (PortfolioItem *) portfolioItemAtIndex:(NSUInteger) index;
- (NSString *)name:(NSIndexPath *) indexPath;
- (NSMutableArray*) getWatchListArray;
- (UIColor *)alertStatus:(NSIndexPath *) indexPath;
- (BOOL)editable:(NSUInteger) watchedIndex;
- (void)sortDescending:(BOOL) descending;
@end
