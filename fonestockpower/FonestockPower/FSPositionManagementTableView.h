//
//  FSPositionManagementTableView.h
//  FonestockPower
//
//  Created by Derek on 2014/11/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPositionFixedTableViewCell.h"
#import "FSPositionMainTableViewCell.h"

@protocol FSPositionManagementTableViewDelegate <NSObject>
@required
- (NSArray *)columnsInFixedTableView;
- (NSArray *)columnsFirstInMainTableView;
- (NSArray *)columnsSecondInMainTableView;
- (NSArray *)columnsThirdInMainTableView;
- (NSArray *)columnsFourthInMainTableView;

- (void)updateFixedTableViewCellSymbolLabel:(UILabel *)symbolLabel cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSPositionFixedTableViewCell *)cell;
- (void)updateMainTableViewCellqtyLabel:(UILabel *)qtyLabel avgCostLabel:(UILabel *)avgCostLabel totalCostLabel:(UILabel *)totalCostLabel lastLabel:(UILabel *)lastLabel totalValLabel:(UILabel *)totalValLabel gainLabel:(UILabel *)gainLabel gainPercentLabel:(UILabel *)gainPercentLabel riskLabel:(UILabel *)riskLabel riskPercentLabel:(UILabel *)riskPercentLabel hBtn:(FSUIButton *)hBtn nBtn:(FSUIButton *)nBtn gBtn:(FSUIButton *)gBtn cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSPositionMainTableViewCell *)cell;

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


@interface FSPositionManagementTableView : UIView <UITableViewDelegate, UITableViewDataSource>
- (id)initWithfixedColumnWidth:(int)fixedColumnSize mainColumnWidth:(int)mainColumnSize AndColumnHeight:(int)columnHeightSize;
@property (weak, nonatomic) id <FSPositionManagementTableViewDelegate> delegate;
@property (strong, nonatomic) UITableView *fixedTableView;
@property (strong, nonatomic) UITableView *mainTableView;
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) NSMutableArray *fixColumnsName;

@property (assign, nonatomic) int fixedColumnSize;
@property (assign, nonatomic) int mainColumnSize;
@property (assign, nonatomic) int columnHeightSize;

- (void)reloadData;

@end
