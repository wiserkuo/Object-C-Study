//
//  RealTimeGoodStockViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKCustomTableView.h"


@interface RealTimeGoodStockViewController : FSUIViewController<SKCustomTableViewDelegate,UIActionSheetDelegate>

-(void)reloadData;

@property (nonatomic) int searchKey;
@property (nonatomic) int searchGroup;

@property (strong) FSUIButton * searchKeyBtn;
@property (strong) FSUIButton * groupBtn;
@property (strong) SKCustomTableView *mainTableView;

@property (strong) NSMutableArray * searchKeyArray;
@property (strong) NSMutableArray * groupArray;
@property (strong) NSMutableArray * columnNames;

@property (retain) NSMutableArray * dataArray;
@property (retain) NSMutableArray * stockArray;
@property (retain) NSMutableArray * fieldIdArray;
@property (retain) NSMutableArray * fieldDataArray;


@end
