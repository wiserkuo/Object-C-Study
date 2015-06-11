//
//  WarrantDrawView.h
//  FonestockPower
//
//  Created by Kenny on 2014/9/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WarrantChartViewController.h"
@interface WarrantDrawView : UIView
@property (nonatomic, strong) NSMutableArray *priceArray;
@property (nonatomic, strong) NSMutableArray *volumeArray;
@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic, strong) NSString *identCodeSymbol;
@property (nonatomic) double referencePrice;
@property (nonatomic) double ceilingPrice;
@property (nonatomic) double floorPrice;
@property (nonatomic) int startTime;
@property (nonatomic) WarrantChartViewController *controller;
- (id)initWithController:(WarrantChartViewController*)controller;
@end
