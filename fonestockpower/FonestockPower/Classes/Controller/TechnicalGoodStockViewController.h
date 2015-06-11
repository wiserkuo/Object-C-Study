//
//  TechnicalGoodStockViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SortingCustomTableView.h"

@interface TechnicalGoodStockViewController : FSUIViewController<SortingTableViewDelegate,UIActionSheetDelegate>

-(void)reloadData;
//@property (nonatomic) int searchKey;
//@property (nonatomic) int searchGroup;
//@property (nonatomic) int nowSearch;//0=5日,1=20日,2=60日,120=5日,240=5日
//@property (nonatomic) int nowState;//0=漲幅,1=跌幅
//
//@property (strong) FSUIButton * searchKeyBtn;
//@property (strong) FSUIButton * groupBtn;
//@property (strong) SortingCustomTableView *mainTableView;
//
//@property (strong) NSMutableArray * searchKeyArray;
//@property (strong) NSMutableArray * groupArray;
//@property (strong) NSMutableArray * columnNames;
//
//@property (strong) NSMutableArray * searchUp;
//@property (strong) NSMutableArray * searchDown;
//
//@property (strong) NSMutableArray * searchNewHeight;
//@property (strong) NSMutableArray * searchNewLow;
//
//@property (strong) NSMutableArray * searchGold;
//@property (strong) NSMutableArray * searchDeath;
//
//@property (strong) NSMutableArray * searchGoldKD;
//@property (strong) NSMutableArray * searchDeathKD;
//
//@property (strong) NSMutableArray * searchBIAS;
//
//@property (strong) NSMutableArray * searchPSY;
//
//@property (strong) NSMutableArray * searchAR;

@end
