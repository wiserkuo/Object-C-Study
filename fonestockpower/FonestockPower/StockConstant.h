//
//  StockConstant.h
//  FonestockPower
//
//  Created by Neil on 14/4/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef SERVER_SYNC
#import "CPTColor.h"
#endif
@interface StockConstant : NSObject
+ (UIColor *)PriceEqualColor;
+ (UIColor *)PriceUpColor;
+ (UIColor *)PriceDownColor;
+ (UIColor *)PriceUpVolumeColor;
+ (UIColor *)PriceDownVolumeColor;
+ (UIColor *)AlertSellProfitColor;
#ifdef SERVER_SYNC
+ (CPTColor *)priceUpGradientTopColor;
+ (CPTColor *)priceUpGradientBottomColor;
+ (CPTColor *)priceDownGradientTopColor;
+ (CPTColor *)priceDownGradientBottomColor;
#endif
+ (UIColor *)watchGroupTextColor;
+ (UIColor *)watchListTextColor;
+ (UIColor *)tableViewEvenRowAlternativeColor;
+ (UIColor *)tableViewOddRowAlternativeColor;
+ (UIColor *)AlertSellLossColor;
@end
