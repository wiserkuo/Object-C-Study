//
//  FSTradeHistoryTableView.h
//  FonestockPower
//
//  Created by Derek on 2014/11/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTradeHistoryFixedTableViewCell.h"
#import "FSTradeHistoryMainTableViewCell.h"

@protocol FSTradeHistoryTableViewDelegate <NSObject>
@required
- (NSArray *)columnsInFixedTableView;
- (NSArray *)columnsFirstInMainTableView;
- (NSArray *)columnsSecondInMainTableView;
- (NSArray *)columnsThirdInMainTableView;
- (NSArray *)columnsFourthInMainTableView;

- (void)updateFixedTableViewCellDateLabel:(UILabel *)dateLabel cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSTradeHistoryFixedTableViewCell *)cell;
- (void)updateMainTableViewCellSymbolLabel:(UILabel *)symbolLabel qtyLabel:(UILabel *)qtyLabel buyDealLabel:(UILabel *)buyDealLabel buyAmountLabel:(UILabel *)buyAmountLabel sellDealLable:(UILabel *)sellDealLable sellAmountLabel:(UILabel *)sellAmountLabel removeBtn:(UIButton *)removeBtn cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSTradeHistoryMainTableViewCell *)cell;


@optional
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface FSTradeHistoryTableView : UIView <UITableViewDataSource, UITableViewDelegate>
- (id)initWithfixedColumnWidth:(int)fixedColumnSize mainColumnWidth:(int)mainColumnSize AndColumnHeight:(int)columnHeightSize;
@property (weak, nonatomic) id <FSTradeHistoryTableViewDelegate> delegate;
@property (strong, nonatomic) UITableView *fixedTableView;
@property (strong, nonatomic) UITableView *mainTableView;
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) NSMutableArray *fixColumnsName;

@property (assign, nonatomic) int fixedColumnSize;
@property (assign, nonatomic) int mainColumnSize;
@property (assign, nonatomic) int columnHeightSize;

- (void)reloadData;
- (void)reloadDataNoOffset;

@end
