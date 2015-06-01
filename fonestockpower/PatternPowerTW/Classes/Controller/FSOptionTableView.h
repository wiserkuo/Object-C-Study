//
//  FSOptionTableView.h
//  FonestockPower
//
//  Created by Derek on 2014/9/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSOptionCell.h"

@protocol FSOptionTableViewDelegate <NSObject>
@required
- (NSArray *)columnsInFixedTableView;
- (NSArray *)columnsInLeftTableView;
- (NSArray *)columnsInRightTableView;
- (void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateLeftTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateRightTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)scrollViewDidScroll:(UIScrollView *)sender;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectLeftRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRightRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface FSOptionTableView : UIView <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) id <FSOptionTableViewDelegate> delegate;
@property (strong, nonatomic) UITableView *leftTableView;
@property (strong, nonatomic) UITableView *fixedTableView;
@property (strong, nonatomic) UITableView *rightTableView;
@property (assign, nonatomic) int leftColumnSize;
@property (assign, nonatomic) int fixedColumnSize;
@property (assign, nonatomic) int rightColumnSize;
@property (assign, nonatomic) int columnHeightSize;
- (id)initWithleftColumnWidth:(int)leftColumnSize fixedColumnWidth:(int)fixedColumnSize rightColumnWidth:(int)rightColumnSize AndColumnHeight:(int)columnHeightSize;
- (void)setFixedColumnSize:(int)fixedColumnSize leftColumnWidth:(int)leftColumnSize rightColumnWidth:(int)rightColumnSize AndColumnHeight:(int)columnHeightSize;
-(UIView *)fixedTableViewForHeader;
-(UIView *)leftTableViewForHeader;
-(UIView *)rightTableViewForHeader;
- (void)reloadAllData;
-(void)reloadDataNoOffset;
-(void)scrollToRowAtIndexPath:(NSIndexPath *)path;
@end
