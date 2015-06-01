//
//  FSActionPlanViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/4/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSActionPlanTableView.h"

@interface FSActionPlanViewController : FSUIViewController <FSActionPlanTableViewDelegate>

@property (nonatomic) BOOL keyBoardShow;
@property (nonatomic) BOOL actionSheetShow;
@property (nonatomic) BOOL controllerType;
@property (strong, nonatomic) FSActionPlanTableView *tableView;
@property (nonatomic) BOOL btnTerm; //按鈕顏色
-(void)reloadRowWithIdentCodeSymbol:(NSString *)ids lastPrice:(float)lastPrice row:(int)row;
-(void)rotate;

@end

