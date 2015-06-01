//
//  FSActionPlanTableView.h
//  FonestockPower
//
//  Created by Derek on 2014/5/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSWatchlistPortfolioItem.h"
#import "FSActionPlanMainCell.h"

@protocol FSActionPlanTableViewDelegate <NSObject>
@required
- (NSArray *)columnsInFixedTableView;
- (NSArray *)columnsInMainTableView;
- (NSArray *)columnsSecondInMainTableView;
- (NSArray *)columnsRemoveInMainTableView;
- (NSArray *)columnsManualInMainTableView;
- (void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateMainTableViewCellStrBuyBtn:(FSUIButton *)strBuyBtn TargetText:(UITextField *)TargetText BuyRefLabel:(UILabel *)buyRefLabel CostLabel:(UILabel *)costLabel LastLabel:(UILabel *)lastLabel SPText:(UITextField *)spText SLText:(UITextField *)slText StrSellBtn:(FSUIButton *)strSellBtn RefLabel:(UILabel *)refLabel RemoveLabel:(UILabel *)removeLabel cellForRowAtIndexPath:(NSIndexPath *)indexPath Cell:(FSActionPlanMainCell *)cell;
@optional
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface FSActionPlanTableView : UIView <UITableViewDelegate, UITableViewDataSource>
- (id)initWithfixedColumnWidth:(int)fixedColumnSize mainColumnWidth:(int)mainColumnSize AndColumnHeight:(int)columnHeightSize;

@property (weak, nonatomic) id <FSActionPlanTableViewDelegate> delegate;
@property (nonatomic, strong) NSObject<FSWatchlistItemProtocol> *watchlistItem;
@property (strong, nonatomic) UITableView *fixedTableView;
@property (strong, nonatomic) UITableView *mainTableView;
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) NSMutableArray *fixColumnsName;
@property (strong) NSMutableArray * labelArray;
@property (strong, nonatomic) NSMutableArray *portfolioArray;

@property (assign, nonatomic) int fixedColumnSize;
@property (assign, nonatomic) int mainColumnSize;
@property (assign, nonatomic) int columnHeightSize;
@property (nonatomic) BOOL term;

- (void)reloadData;
- (void)reloadDataNoOffset;
- (void)reloadRowsAtIndexPaths:(NSInteger)indexPaths;
- (void)reloadRowsAtIndexPaths:(NSInteger)indexPaths lastPrice:(float)lastPrice;

@end
