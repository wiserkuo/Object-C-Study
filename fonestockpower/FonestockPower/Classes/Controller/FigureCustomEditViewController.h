//
//  FigureCustomEditViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/10/29.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FigureSearchModel.h"

@interface FigureCustomEditViewController : FSUIViewController

//currentOption：註1    searchNum：第幾個型態     kNumber：第幾個k bar
- (id)initWithCurrentOption:(enum CurrentOption)current SearchNum:(int)searchNumber kNumber:(int)kNum forDWM:(int)dwm;
//註1：因為有分標竿型態及我的型態，而各自又有多方跟空方，所以才用此參數區分
//LongSystem→標竿型態的多方  ShortSystem→標竿型態的空方  LongCustom→我的型態的多方  ShortCustom→我的型態的空方

//因為必須用popViewController的方式回到這一頁，所以沒辦法用init的方式將所需的三個值放進來
//於是用property的方式，各別將值放進去，並修改了viewWillAppear的method，以達到進來本頁時做必要的動作
//必要的動作：重讀資料庫以取得在detailViewController所做的修改
@property (nonatomic) int searchNum;
@property (nonatomic) int currentOption;
@property (nonatomic) int kNumber;
@property (nonatomic) BOOL firstIn;
-(void)reloadDBData;

@end
