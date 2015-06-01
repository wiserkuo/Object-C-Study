//
//  NetWorthUpperView.h
//  FonestockPower
//
//  Created by Neil on 14/6/11.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetWorthViewController.h"


typedef NS_ENUM(NSUInteger, RangeID) {
    threeMonth,
    sixMonth,
    YTD,
    oneYear,
    threeYear
};

@interface NetWorthUpperView : UIView{
    RangeID range;
}

@property(strong, nonatomic) NetWorthViewController * netWorthViewController;

@property (strong, nonatomic)NSMutableArray * netWorthDataArray;
@property (strong, nonatomic)NSMutableDictionary * netWorthDataDictionary;
@property (strong, nonatomic)NSMutableArray * histDataArray;
@property(nonatomic) double maxTotal;
@property(nonatomic) double minTotal;

-(void)setRange:(RangeID)rangeId;
-(void)removeLabel;
@end