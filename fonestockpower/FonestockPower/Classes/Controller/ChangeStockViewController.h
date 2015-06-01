//
//  ChangeStockViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/11/19.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacroeconomicDrawViewController.h"
@interface ChangeStockViewController : FSUIViewController

- (id)initWithNumber:(int)num;
-(id)initWithTarget:(MacroeconomicDrawViewController *)controller;
@end
