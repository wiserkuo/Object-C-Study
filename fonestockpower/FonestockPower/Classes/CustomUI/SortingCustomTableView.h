//
//  SortingCustomTableView.h
//  WirtsLeg
//
//  Created by Neil on 13/10/11.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "SKCustomTableView.h"

@interface SortingCustomTableView : SKCustomTableView
@property (strong) NSMutableArray * labelArray;
@property (nonatomic) BOOL selectType;
@property (nonatomic) int focuseLabel;
@property (nonatomic) BOOL whiteLine;
@property (nonatomic) BOOL twoLabels;
@property (strong, nonatomic) NSMutableArray *fixColumnsName;
@property (weak, nonatomic) id <SortingTableViewDelegate> delegate;
@end
