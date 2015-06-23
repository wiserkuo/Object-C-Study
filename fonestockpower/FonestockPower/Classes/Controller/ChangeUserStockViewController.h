//
//  ChangeUserStockViewController.h
//  WirtsLeg
//
//  Created by Neil on 14/2/17.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"
#import "MacroeconomicDrawViewController.h"

@interface ChangeUserStockViewController : FSUIViewController <SecuritySearchDelegate>
@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;
@property (nonatomic, strong) MacroeconomicDrawViewController *macroeconomicViewController;
- (id)initWithNumber:(int)num;
-(void)setTarget:(MacroeconomicDrawViewController *)controller;
@end
