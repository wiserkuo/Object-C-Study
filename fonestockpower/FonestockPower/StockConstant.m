//
//  StockConstant.m
//  FonestockPower
//
//  Created by Neil on 14/4/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "StockConstant.h"

@implementation StockConstant

+ (UIColor *)PriceEqualColor {
        return [UIColor blueColor];
}

+ (UIColor *)PriceUpColor
{
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
	
	if (![group isEqualToString:@"us"])
		return [UIColor redColor];
	else
		return [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
}

+ (UIColor *)PriceDownColor
{
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
	
	if (![group isEqualToString:@"us"])
		return [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
	else
		return [UIColor redColor];
}

#ifdef SERVER_SYNC
+ (CPTColor *)priceUpGradientTopColor
{
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
	
	if (![group isEqualToString:@"us"]) {
        return [CPTColor colorWithCGColor:[UIColor colorWithRed:1.0 green:165.0f/255.0f blue:175.0f/255.0f alpha:1.0].CGColor];//red
    }
    else {
        return [CPTColor colorWithCGColor:[UIColor colorWithRed:0.000 green:1.000 blue:0.200 alpha:1.000].CGColor];//green
    }
}

+ (CPTColor *)priceUpGradientBottomColor
{
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
	
	if (![group isEqualToString:@"us"]) {
        return [CPTColor colorWithCGColor:[UIColor colorWithRed:255.0f/255.0f green:15.0f/255.0f blue:35.0f/255.0f alpha:1.000].CGColor];
    }
    else {
        return [CPTColor colorWithCGColor:[UIColor colorWithRed:0.075 green:0.575 blue:0.137 alpha:1.000].CGColor];
    }
}

+ (CPTColor *)priceDownGradientTopColor
{
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
	
	if (![group isEqualToString:@"us"]) {
        return [CPTColor colorWithComponentRed:35.0/255.0 green:202.0/255.0 blue:44.0/255.0 alpha:1];//green
    }
    else {
        return [CPTColor colorWithComponentRed:214.0/255.0 green:124.0/255.0 blue:124.0/255.0 alpha:1];//red
    }
}

+ (CPTColor *)priceDownGradientBottomColor
{
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
	
	if (![group isEqualToString:@"us"]) {
        return [CPTColor colorWithComponentRed:182.0/255.0 green:234.0/255.0 blue:180.0/255.0 alpha:1];
    }
    else {
        return [CPTColor colorWithComponentRed:212.0/255.0 green:26.0/255.0 blue:23.0/255.0 alpha:1];
    }
}
#endif
+ (UIColor *)PriceUpVolumeColor
{
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
	
	if (![group isEqualToString:@"us"])
		return [UIColor redColor];
	else
		return [UIColor greenColor];
    
}

+ (UIColor *)PriceDownVolumeColor
{
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
	
	if (![group isEqualToString:@"us"])
		return [UIColor greenColor];
    
	else
		return [UIColor redColor];
}

+ (UIColor *)watchGroupTextColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)watchListTextColor
{
    return [UIColor blueColor];
}

+ (UIColor *)tableViewEvenRowAlternativeColor
{
    return [UIColor colorWithWhite:0.400 alpha:1.000];
}

+ (UIColor *)tableViewOddRowAlternativeColor
{
    return [UIColor colorWithWhite:0.098 alpha:1.000];
}

+ (UIColor *)AlertSellProfitColor
{
    return [UIColor colorWithRed:236/255.0f green:122/255.0f blue:161/255.0f alpha:1.0f];
}

+ (UIColor *)AlertSellLossColor
{
    return [UIColor colorWithRed:169/255.0f green:208/255.0f blue:107/255.0f alpha:1.0f];
}

@end
