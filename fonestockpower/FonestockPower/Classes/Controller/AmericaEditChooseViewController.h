//
//  AmericaEditChooseViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/10/14.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"

@interface AmericaEditChooseViewController : UIViewController<SecuritySearchDelegate>
@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;
@property (strong)NSMutableArray * dataArray;//搜尋出來的股票 symbol name
@property (strong)NSMutableArray * dataIdArray;//搜尋出來的股票symbol
@property (strong)NSMutableArray * dataIdentCodeArray;
@property (strong)NSMutableArray * chooseArray;
@property (nonatomic) int searchGroupId;
@property (strong) UILabel * noStockLabel;
-(void)reloadBtn;
-(void)totalCount:(NSNumber *)count;
@end
