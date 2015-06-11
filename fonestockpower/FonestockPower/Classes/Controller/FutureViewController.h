//
//  FutureViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/9/27.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKCustomTableView.h"

@class SKCustomTableView;

@interface FutureViewController : UIViewController<SKCustomTableViewDelegate,UIActionSheetDelegate>{
    BOOL scrollFlag;
}

- (void) notify;

@property (nonatomic) int searchNum;
@property (nonatomic) int typeNum;
@property (nonatomic) int searchTimes;

@property (strong) FSUIButton * stateBtn;
@property (strong) UILabel * stateLabel;
@property (strong) SKCustomTableView *mainTableView;

@property (strong) NSMutableArray *categoryArray;
@property (strong) NSMutableArray *categoryIdArray;
@property (strong) NSMutableArray *columnNames;

@property (strong) NSMutableArray *stockNameArray;
@property (strong) NSMutableArray *stockIdArray;
@property (strong) NSMutableArray *stockIdentCodeArray;


@property (strong) NSMutableArray *updateListArray;


@property (strong) NSMutableDictionary * currentPriceDictionary;
@property (strong) NSMutableDictionary * bidPriceDictionary;
@property (strong) NSMutableDictionary * askPriceDictionary;
@property (strong) NSMutableDictionary * highestPriceDictionary;
@property (strong) NSMutableDictionary * lowestPriceDictionary;
@property (strong) NSMutableDictionary * chgDictionary;
@property (strong) NSMutableDictionary * p_chgDictionary;
@property (strong) NSMutableDictionary * VolumeDictionary;
@property (strong) NSMutableDictionary * accumulatedVolumeDictionary;
@property (strong) NSMutableDictionary * referencePriceDictionary;
@property (strong) NSMutableDictionary * statusDictionary;
@property (strong) NSMutableDictionary * topPriceDictionary;
@property (strong) NSMutableDictionary * bottomPriceDictionary;
@property (strong) NSMutableArray * allDataArray;

-(void)SnapshotNnotifyDataArrive:(NSMutableArray *)array;
@end
