//
//  UICollectionView+FSMultiChartExtensions.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/10/31.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSMultiChartCellRefreshingOperation;

@interface UICollectionView (FSMultiChartExtensions)
- (void)reloadCellAtIndex:(NSUInteger) index preventTooManyUpdateing:(BOOL) preventTooManyUpdateing;
@end
