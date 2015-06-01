//
//  FSTypicalTrendModel.h
//  FonestockPower
//
//  Created by Derek on 2014/8/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EODTargetController.h"

@interface SearchCriteriaModel : NSObject<NSXMLParserDelegate>
{
    NSMutableArray *criteriaArray;
}
-(NSMutableArray *)getCriteriaArray;
@end

@interface SliderObj : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic) double maxValue;
@property (nonatomic) double medianValue;
@property (nonatomic) double minValue;
@property (nonatomic) double rangeValue;
@property (nonatomic) double upperLimit;
@property (nonatomic) double lowerLimit;
@property (nonatomic) BOOL selected;
@property (nonatomic, strong) NSString *formula;
@property (nonatomic, strong) NSString *keyWrod;
@end
