//
//  NetWorthBottonView.h
//  FonestockPower
//
//  Created by Neil on 14/6/11.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetWorthBottonView : UIView

@property (strong, nonatomic)NSMutableArray * netWorthDataArray;
@property (strong, nonatomic)NSMutableDictionary * netWorthDataDictionary;
@property (strong, nonatomic)NSMutableArray * histDataArray;
@property(nonatomic) double maxDaily;
@property(strong, nonatomic)NSDate * beginDay;

-(void)changeDate:(NSString *)date Value:(float)value;

@end
