//
//  FSTradeHistoryViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/11/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTradeHistoryTableView.h"

@interface FSTradeHistoryViewController : FSUIViewController <FSTradeHistoryTableViewDelegate>
@property (strong, nonatomic) FSTradeHistoryTableView *tableView;
@property (strong, nonatomic) NSString *termStr;
@property (strong, nonatomic) NSString *symbolStr;

@end
