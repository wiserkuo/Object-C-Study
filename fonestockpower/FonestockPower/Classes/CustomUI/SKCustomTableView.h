//
//  SKCustomTableView.h
//  WirtsLeg
//
//  Created by Connor on 13/8/16.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKCustomTableViewCell.h"


@protocol SKCustomTableViewDelegate <NSObject>

@required
- (NSArray *)columnsInFixedTableView;
- (NSArray *)columnsInMainTableView;
- (void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell;

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@protocol SortingTableViewDelegate <SKCustomTableViewDelegate>
@optional
-(void)labelTap:(UILabel *)label;
@end


@interface SKCustomTableView : UIView <UITableViewDelegate, UITableViewDataSource>
- (id)initWithfixedColumnWidth:(int)fixedColumnSize mainColumnWidth:(int)mainColumnSize AndColumnHeight:(int)columnHeightSize ;
- (void)setFixedColumnSize:(int)fixedColumnSize mainColumnWidth:(int)mainColumnSize AndColumnHeight:(int)columnHeightSize;
-(UIView *)FixedtableViewForHeader;
-(UIView *)MaintableViewForHeader;
@property (weak, nonatomic) id <SKCustomTableViewDelegate> delegate;
@property (strong, nonatomic) NSArray *fixedTableViewColumnNameArray;
@property (strong, nonatomic) NSArray *mainTableViewColumnNameArray;
@property (strong, nonatomic) UITableView *fixedTableView;
@property (strong, nonatomic) UITableView *mainTableView;
@property (assign, nonatomic) int fixedColumnSize;
@property (assign, nonatomic) int mainColumnSize;
@property (assign, nonatomic) int columnHeightSize;
-(void)reloadDataNoOffset;
- (void)reloadAllData;
- (NSArray *)indexPathsForVisibleRows;
@end
