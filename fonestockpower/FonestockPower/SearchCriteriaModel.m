//
//  FSTypicalTrendModel.m
//  FonestockPower
//
//  Created by Derek on 2014/8/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "SearchCriteriaModel.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "FMDB.h"

@implementation SearchCriteriaModel
-(NSMutableArray *)getCriteriaArray
{
    NSString *value;
#ifdef PatternPowerTW
    value = @"100";
#elif PatternPowerUS || PatternPowerCN
    value = @"300";
#endif

    criteriaArray = [[NSMutableArray alloc] init];
    
    SliderObj *market_Volume = [[SliderObj alloc] init];
    market_Volume.title = NSLocalizedStringFromTable(@"成交量排行", @"SearchCriteria", nil);
    market_Volume.selected = NO;
    market_Volume.formula = [NSString stringWithFormat:@"#RANGE#TP_VOL <= %@", value];
    [criteriaArray addObject:market_Volume];
    
    SliderObj *market_Volatility = [[SliderObj alloc] init];
    market_Volatility.title = NSLocalizedStringFromTable(@"振幅排行", @"SearchCriteria", nil);
    market_Volatility.selected = NO;
    market_Volatility.formula = [NSString stringWithFormat:@"#RANGE#TP_VOLA <= %@", value];
    [criteriaArray addObject:market_Volatility];
    
    SliderObj *market_TurnoverRate = [[SliderObj alloc] init];
    market_TurnoverRate.title = NSLocalizedStringFromTable(@"週轉率排行", @"SearchCriteria", nil);
    market_TurnoverRate.selected = NO;
    market_TurnoverRate.formula = [NSString stringWithFormat:@"#RANGE#TP_TOR <= %@", value];
    [criteriaArray addObject:market_TurnoverRate];
    
    SliderObj *market_MarketCap = [[SliderObj alloc] init];
    market_MarketCap.title = NSLocalizedStringFromTable(@"市值排行", @"SearchCriteria", nil);
    market_MarketCap.selected = NO;
    market_MarketCap.formula = [NSString stringWithFormat:@"#RANGE#TP_MCAP <= %@", value];
    [criteriaArray addObject:market_MarketCap];
    
    SliderObj *price = [[SliderObj alloc] init];
    price.title = NSLocalizedStringFromTable(@"股價區間", @"SearchCriteria", nil);
    price.selected = NO;
    price.keyWrod = @"#RANGE#LAST";
    price.maxValue = 200;
    price.upperLimit = 200;
    price.minValue = 0;
    price.lowerLimit = 0;
    price.medianValue = 100;
    price.rangeValue = 1;
    [criteriaArray addObject:price];
    
    SliderObj *volume = [[SliderObj alloc] init];
    volume.title = NSLocalizedStringFromTable(@"成交量", @"SearchCriteria", nil);
    volume.selected = NO;
    volume.keyWrod = @"#RANGE#VOLUME";
    volume.maxValue = 49000;
    volume.upperLimit = 49000;
    volume.minValue = 0;
    volume.medianValue = 24000;
    volume.rangeValue = 1000;
    [criteriaArray addObject:volume];
    
    SliderObj *volume20Avg = [[SliderObj alloc] init];
    volume20Avg.title = NSLocalizedStringFromTable(@"成交量/20日均量", @"SearchCriteria" , nil);
    volume20Avg.selected = NO;
    volume20Avg.keyWrod = @"#RANGE#VOLUME / #RANGE#VOL_MA20";
    volume20Avg.maxValue = 4.9;
    volume20Avg.upperLimit = 4.9;
    volume20Avg.minValue = 0;
    volume20Avg.medianValue = 2.4;
    volume20Avg.rangeValue = 0.1;
    [criteriaArray addObject:volume20Avg];
    
    SliderObj *peRatio = [[SliderObj alloc]init];
    peRatio.title = NSLocalizedStringFromTable(@"本益比", @"SearchCriteria", nil);
    peRatio.selected = NO;
    peRatio.keyWrod = @"#RANGE#PE";
    peRatio.maxValue = 30;
    peRatio.upperLimit = 30;
    peRatio.minValue = 0;
    peRatio.lowerLimit = 0;
    peRatio.medianValue = 25;
    peRatio.rangeValue = 1;
    [criteriaArray addObject:peRatio];
    
    SliderObj *eps = [[SliderObj alloc] init];
    eps.title = NSLocalizedStringFromTable(@"每股盈餘", @"SearchCriteria", nil);
    eps.selected = NO;
    eps.keyWrod = @"Q0EPS";
    eps.maxValue = 2;
    eps.upperLimit = 2;
    eps.minValue = -2;
    eps.lowerLimit = -2;
    eps.medianValue = 0;
    eps.rangeValue = 0.1;
    [criteriaArray addObject:eps];
    
    SliderObj *epsGrowthRate = [[SliderObj alloc] init];
    epsGrowthRate.title = NSLocalizedStringFromTable(@"每股盈餘成長率", @"SearchCriteria", nil);
    epsGrowthRate.selected = NO;
    epsGrowthRate.keyWrod = @"Q0EPS_QOQ";
    epsGrowthRate.maxValue = 0.3;
    epsGrowthRate.upperLimit = 0.3;
    epsGrowthRate.minValue = -0.3;
    epsGrowthRate.lowerLimit = -0.3;
    epsGrowthRate.medianValue = 0;
    epsGrowthRate.rangeValue = 0.01;
    [criteriaArray addObject:epsGrowthRate];
    
    SliderObj *operating_Margin = [[SliderObj alloc] init];
    operating_Margin.title = NSLocalizedStringFromTable(@"營業利益率", @"SearchCriteria", nil);
    operating_Margin.selected = NO;
    operating_Margin.keyWrod = @"Q0OP_MRG";
    operating_Margin.maxValue = 0.3;
    operating_Margin.upperLimit = 0.3;
    operating_Margin.minValue = -0.3;
    operating_Margin.lowerLimit = -0.3;
    operating_Margin.medianValue = 0;
    operating_Margin.rangeValue = 0.01;
    [criteriaArray addObject:operating_Margin];
    
    SliderObj *operating_GrowthRate = [[SliderObj alloc] init];
    operating_GrowthRate.title = NSLocalizedStringFromTable(@"營業利益成長率", @"SearchCriteria", nil);
    operating_GrowthRate.selected = NO;
    operating_GrowthRate.keyWrod = @"Q0OPM_QOQ";
    operating_GrowthRate.maxValue = 0.3;
    operating_GrowthRate.upperLimit = 0.3;
    operating_GrowthRate.minValue = -0.3;
    operating_GrowthRate.lowerLimit = -0.3;
    operating_GrowthRate.medianValue = 0;
    operating_GrowthRate.rangeValue = 0.01;
    [criteriaArray addObject:operating_GrowthRate];
    
    SliderObj *revenue = [[SliderObj alloc]init];
    revenue.title = NSLocalizedStringFromTable(@"營收成長率", @"SearchCriteria", nil);
    revenue.selected = NO;
    revenue.keyWrod = @"Q0RVN_YOY";
    revenue.maxValue = 0.3;
    revenue.upperLimit = 0.3;
    revenue.minValue = -0.3;
    revenue.lowerLimit = -0.3;
    revenue.medianValue = 0;
    revenue.rangeValue = 0.01;
    [criteriaArray addObject:revenue];
    
    SliderObj *roe = [[SliderObj alloc] init];
    roe.title = NSLocalizedStringFromTable(@"股東權益報酬率", @"SearchCriteria", nil);
    roe.selected = NO;
    roe.keyWrod = @"Q0ROE";
    roe.maxValue = 0.2;
    roe.upperLimit = 0.2;
    roe.minValue = -0.2;
    roe.lowerLimit = -0.2;
    roe.medianValue = 0;
    roe.rangeValue = 0.01;
    [criteriaArray addObject:roe];
    
    return criteriaArray;
}

@end

@implementation SliderObj
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _title = [coder decodeObjectForKey:@"title"];
        _maxValue = [coder decodeDoubleForKey:@"maxValue"];
        _medianValue = [coder decodeDoubleForKey:@"medianValue"];
        _minValue = [coder decodeDoubleForKey:@"minValue"];
        _rangeValue = [coder decodeDoubleForKey:@"rangeValue"];
        _upperLimit = [coder decodeDoubleForKey:@"upperLimit"];
        _lowerLimit = [coder decodeDoubleForKey:@"lowerLimit"];
        _selected = [coder decodeBoolForKey:@"selected"];
        _formula = [coder decodeObjectForKey:@"formula"];
        _keyWrod = [coder decodeObjectForKey:@"keyWrod"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if ([coder isKindOfClass:[NSKeyedArchiver class]]) {
        [coder encodeObject:_title forKey:@"title"];
        [coder encodeDouble:_maxValue forKey:@"maxValue"];
        [coder encodeDouble:_medianValue forKey:@"medianValue"];
        [coder encodeDouble:_minValue forKey:@"minValue"];
        [coder encodeDouble:_rangeValue forKey:@"rangeValue"];
        [coder encodeDouble:_upperLimit forKey:@"upperLimit"];
        [coder encodeDouble:_lowerLimit forKey:@"lowerLimit"];
        [coder encodeBool:_selected forKey:@"selected"];
        [coder encodeObject:_formula forKey:@"formula"];
        [coder encodeObject:_keyWrod forKey:@"keyWrod"];
    } else {
        [NSException raise:NSInvalidArchiveOperationException
                    format:@"Only supports NSKeyedArchiver coders"];
    }
}
    

@end
