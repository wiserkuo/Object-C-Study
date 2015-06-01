//
//  FSDiaryTableView.h
//  FonestockPower
//
//  Created by Derek on 2014/9/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSDiaryCell.h"
@protocol FSDiaryTableViewDelegate <NSObject>
@required
- (NSArray *)columnsInFixedTableView;
- (NSArray *)columnsInMainTableView;
- (void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)addToPerformance:(FSDiaryCell *)cell;

@end
@interface FSDiaryTableView : UIView <FSDiaryCellDelegate, UITableViewDelegate, UITableViewDataSource>
- (id)initWithfixedColumnWidth:(int)fixedColumnSize mainColumnWidth:(int)mainColumnSize AndColumnHeight:(int)columnHeightSize;
@property (weak, nonatomic) id <FSDiaryTableViewDelegate> delegate;
@property (strong, nonatomic) UITableView *fixedTableView;
@property (strong, nonatomic) UITableView *mainTableView;
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) NSMutableArray *fixColumnsName;
@property (strong) NSMutableArray * labelArray;

@property (assign, nonatomic) int fixedColumnSize;
@property (assign, nonatomic) int mainColumnSize;
@property (assign, nonatomic) int columnHeightSize;
-(void)reloadDataNoOffset;
-(void)reloadAllData;

@end
