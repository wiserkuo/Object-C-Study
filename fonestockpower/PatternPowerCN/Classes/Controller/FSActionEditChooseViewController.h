//
//  FSActionEditChooseViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/5/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"

@interface FSActionEditChooseViewController : FSUIViewController <SecuritySearchDelegate, UITextFieldDelegate>
@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;
@property (strong)NSMutableArray * dataArray;//搜尋出來的股票 symbol name
@property (strong)NSMutableArray * dataIdArray;//搜尋出來的股票symbol
@property (strong)NSMutableArray * dataIdentCodeArray;
@property (strong)NSMutableArray * chooseArray;
@property (nonatomic) int searchGroupId;
@property (strong) UILabel * noStockLabel;
@property (nonatomic)int searchNum;
-(void)reloadBtn;
-(void)totalCount:(NSNumber *)count;
-(void)reSearch;

@end
