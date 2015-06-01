//
//  FSTradeViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/7/11.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSTradeViewController : FSUIViewController
@property (strong, nonatomic) NSString *symbolStr;
@property (nonatomic) float lastNum;
@property (strong, nonatomic) NSString *termStr;
@property (strong, nonatomic) NSString *dealStr;
@property (weak, nonatomic) FSActionPlan *actionPlan;
@property (unsafe_unretained, nonatomic) BOOL costType;
@property (nonatomic) float ref_Price;

@end
