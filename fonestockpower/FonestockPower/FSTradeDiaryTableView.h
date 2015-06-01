//
//  FSTradeDiaryTableView.h
//  FonestockPower
//
//  Created by Derek on 2014/11/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTradeDiaryFixedTableViewCell.h"
#import "FSTradeDiaryMainTableViewCell.h"

@protocol FSTradeDiaryTableViewDelegate <NSObject>
@required
- (NSArray *)columnsInFixedTableView;
- (NSArray *)columnsFirstInMainTableView;
- (NSArray *)columnsSecondInMainTableView;
- (NSArray *)columnsThirdInMainTableView;
- (NSArray *)columnsFourthInMainTableView;

-(void)updateFixedTableCellSymbolLabel:(UILabel *)symbolLabel cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSTradeDiaryFixedTableViewCell *)cell;
-(void)updateMainTableCellqtyLabel:(UILabel *)qtyLabel avgSellLabel:(UILabel *)avgSellLabel sellAmountLabel:(UILabel *)sellAmountLabel gainLabel:(UILabel *)gainLabel gainPercentLabel:(UILabel *)gainPercentLabel avgCost:(UILabel *)avgCost costAmountLabel:(UILabel *)costAmountLabel hBtn:(FSUIButton *)hBtn nBtn:(FSUIButton *)nBtn gBtn:(FSUIButton *)gBtn cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSTradeDiaryMainTableViewCell *)cell;


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


@interface FSTradeDiaryTableView : UIView <UITableViewDataSource, UITableViewDelegate>
- (id)initWithfixedColumnWidth:(int)fixedColumnSize mainColumnWidth:(int)mainColumnSize AndColumnHeight:(int)columnHeightSize;
@property (weak, nonatomic) id <FSTradeDiaryTableViewDelegate> delegate;
@property (strong, nonatomic) UITableView *fixedTableView;
@property (strong, nonatomic) UITableView *mainTableView;
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) NSMutableArray *fixColumnsName;

@property (assign, nonatomic) int fixedColumnSize;
@property (assign, nonatomic) int mainColumnSize;
@property (assign, nonatomic) int columnHeightSize;

- (void)reloadData;

@end
