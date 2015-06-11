//
//  FSActionAlertTableView.h
//  FonestockPower
//
//  Created by Derek on 2014/10/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSActionAlertFixedTableViewCell.h"
#import "FSActionAlertMainTableViewCell.h"
#import "FSActionAlertSecondFixedTableViewCell.h"
#import "FSActionAlertSecondMainTableViewCell.h"

@protocol FSActionAlertTableViewDelegate <NSObject>
@required
- (NSArray *)columnsInFixedTableView;
- (NSArray *)columnsFirstInMainTableView;
- (NSArray *)columnsSecondInMainTableView;
- (NSArray *)columnsThirdInMainTableView;
- (NSArray *)columnsFourthInMainTableView;

- (void)updateFixedTableViewCellSymbolLabel:(UILabel *)symbolLabel lastLabel:(UILabel *)lastLabel tradeBtn:(UIButton *)tradeBtn cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSActionAlertFixedTableViewCell *)cell;
- (void)updateMainTableViewCellPatternView:(UIView *)patternView PatternLabel:(UILabel *)patternLabel PatternBtn:(UIButton *)patternBtn TargetTextField:(UITextField *)targetTextField SPTextField:(UITextField *)SPTextField SLTextField:(UITextField *)SLTextField RemoveBtn:(UIButton *)removeBtn cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSActionAlertMainTableViewCell *)cell;
- (void)updateSecondFixedTableViewCellSymbolLabel:(UILabel *)symbolLabel lastLabel:(UILabel *)lastLabel tradeBtn:(UIButton *)tradeBtn trade2Btn:(UIButton *)trade2Btn cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSActionAlertSecondFixedTableViewCell *)cell;
- (void)updateSecondMainTableViewCellPattern1View:(UIView *)pattern1View Pattern1Label:(UILabel *)pattern1Label PatternBtn:(UIButton *)patternBtn TargetTextField:(UITextField *)targetTextField SPTextField:(UITextField *)SPTextField SLTextField:(UITextField *)SLTextField costBtn:(UIButton *)costBtn Pattern2View:(UIView *)pattern2View Pattern2Label:(UILabel *)pattern2Label pattern2Btn:(UIButton *)pattern2Btn SP2TextField:(UITextField *)SP2TextField SL2TextField:(UITextField *)SL2TextField cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSActionAlertSecondMainTableViewCell *)cell;


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


@interface FSActionAlertTableView : UIView <UITableViewDelegate, UITableViewDataSource>
- (id)initWithfixedColumnWidth:(int)fixedColumnSize mainColumnWidth:(int)mainColumnSize AndColumnHeight:(int)columnHeightSize;
@property (weak, nonatomic) id <FSActionAlertTableViewDelegate> delegate;
@property (strong, nonatomic) UITableView *fixedTableView;
@property (strong, nonatomic) UITableView *mainTableView;
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) NSMutableArray *fixColumnsName;

@property (assign, nonatomic) int fixedColumnSize;
@property (assign, nonatomic) int mainColumnSize;
@property (assign, nonatomic) int columnHeightSize;

@property (strong, nonatomic) NSMutableArray *actionArray;
@property (nonatomic) BOOL scrollViewDraggingFlag;

- (void)reloadData;
- (void)reloadRowsAtIndexPaths:(NSInteger)indexPaths;

@end
