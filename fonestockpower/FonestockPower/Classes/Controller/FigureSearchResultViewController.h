//
//  FigureSearchResultViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/10/24.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FigureSearchResultViewController : FSUIViewController<UIActionSheetDelegate>

- (id)initWithFigureSearchId:(NSNumber *)figureSearchId
                 FuctionName:(NSString *)functionName
               conditionName:(NSString *)conditionName
                 searchGroup:(NSString *)searchGroup
                    datetime:(NSDate *)datetime
                 Opportunity:(NSString *)opportunity
                targetMarket:(NSString *)targetMarket
                 totalAmount:(int)totalAmount
               displayAmount:(int)displayAmount
                   dataArray:(NSArray *)dataArray
              markPriceArray:(NSArray *)markPriceArray;

@end
