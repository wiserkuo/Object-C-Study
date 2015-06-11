//
//  ChangeStockSearchViewController.h
//  WirtsLeg
//
//  Created by Neil on 14/2/17.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"
#import "MacroeconomicDrawViewController.h"
@interface ChangeStockSearchViewController : UIViewController<SecuritySearchDelegate>

@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;

- (id)initWithNumber:(int)num;
-(void)setTarget:(MacroeconomicDrawViewController *)controller;
@end
