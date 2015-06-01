//
//  FSOptionStrategyViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/10/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSOptionStrategyViewController : UIViewController
@property (strong, nonatomic) NSString *strategyTitle;
@property (unsafe_unretained, nonatomic) int cellNum;
@property (strong, nonatomic) UITableView *mainTableView;

-(void)initData;
@end
