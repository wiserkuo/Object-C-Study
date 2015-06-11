//
//  UICollectionView+FSMultiChartExtensions.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/10/31.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "UICollectionView+FSMultiChartExtensions.h"
#import "FSMultiChartCellRefreshingOperation.h"

@implementation UICollectionView (FSMultiChartExtensions)

- (void)reloadCellAtIndex:(NSUInteger) index preventTooManyUpdateing:(BOOL) preventTooManyUpdateing
{
    if (preventTooManyUpdateing) {
        for (NSOperation *operation in [[NSOperationQueue mainQueue] operations]) {
            if ([operation isKindOfClass:[FSMultiChartCellRefreshingOperation class]] == NO) {
                continue;
            }
            FSMultiChartCellRefreshingOperation *cellRefreshingOperation = (FSMultiChartCellRefreshingOperation *)operation;
            if (cellRefreshingOperation.index == index) {
                [cellRefreshingOperation cancel];
            }
        }
    }
    FSMultiChartCellRefreshingOperation *operation = [[FSMultiChartCellRefreshingOperation alloc] init];
    operation.index = index;
    [[NSOperationQueue mainQueue] addOperation:operation];
}

@end
