//
//  FSActionPlanTableView.m
//  FonestockPower
//
//  Created by Derek on 2014/5/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionPlanTableView.h"
#import "FSActionPlanCell.h"
#import "FSActionPlanMainCell.h"
#import "FSActionPlanDatabase.h"

@implementation FSActionPlanTableView
- (void)setDelegate:(id<FSActionPlanTableViewDelegate>)delegate {
    _delegate = delegate;
}

- (id)initWithfixedColumnWidth:(int)fixedColumnSize mainColumnWidth:(int)mainColumnSize AndColumnHeight:(int)columnHeightSize{
    self = [super init];
    if (self) {
        _fixedColumnSize = fixedColumnSize;
        _mainColumnSize = mainColumnSize;
        _columnHeightSize = columnHeightSize;
        
        _fixedTableView = [[UITableView alloc] init];
        _fixedTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _fixedTableView.dataSource = self;
        _fixedTableView.delegate = self;
        _fixedTableView.bounces = NO;
        _fixedTableView.directionalLockEnabled = NO;
        _fixedTableView.showsHorizontalScrollIndicator = NO;
        _fixedTableView.showsVerticalScrollIndicator = NO;
        [self addSubview:_fixedTableView];
        
        _mainTableView = [[UITableView alloc] init];
        _mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
        _mainTableView.bounces = NO;
        _mainTableView.directionalLockEnabled = NO;
        
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.backgroundColor = [UIColor lightGrayColor];
        _mainScrollView.delegate = self;
        _mainScrollView.bounces = NO;
        _mainScrollView.directionalLockEnabled = NO;
        _mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _mainScrollView.contentSize = CGSizeMake(_mainTableView.frame.size.width, _mainScrollView.frame.size.height);
        [_mainScrollView addSubview:_mainTableView];
        [self addSubview:_mainScrollView];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self removeConstraints:self.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_fixedTableView, _mainTableView, _mainScrollView);
    
    NSString *layoutString = [NSString stringWithFormat:@"H:|[_fixedTableView(%d)][_mainScrollView]|", _fixedColumnSize * (int)[[_delegate columnsInFixedTableView] count]];
        
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutString options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_fixedTableView]|" options:0 metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainScrollView]|" options:0 metrics:nil views:viewControllers]];
    
    int mainViewWidth = _mainColumnSize * ((int)[[_delegate columnsInMainTableView] count] + (int)[[_delegate columnsRemoveInMainTableView] count]) + 62;
    layoutString = [NSString stringWithFormat:@"H:|[_mainTableView(>=_mainScrollView@2,%d@1)]|", mainViewWidth];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutString options:0 metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainTableView(==_mainScrollView)]|" options:0 metrics:nil views:viewControllers]];
}

#pragma mark scrollview delegate 二個table同步捲動
- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if ([sender isEqual:_fixedTableView]) {
        _mainTableView.contentOffset = _fixedTableView.contentOffset;
    } else if ([sender isEqual:_mainTableView]) {
        _fixedTableView.contentOffset = _mainTableView.contentOffset;
    }
    if ([_delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        return [_delegate scrollViewDidScroll:sender];
    }
}


#pragma mark - Table View Header Setting
-(UIView *)FixedtableViewForHeader{
    UIView *fixedTableHeader = [[UIView alloc] init];
    fixedTableHeader.backgroundColor = [UIColor colorWithRed: 0.0/255.0 green: 78.0/255.0 blue: 162.0/255.0 alpha: 1.0];

    NSArray *columnsName = [_delegate columnsInFixedTableView];
    for (int i = 0; i < [columnsName count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * _fixedColumnSize, 0, _fixedColumnSize, 44)];
        label.font = [UIFont boldSystemFontOfSize:18.0f];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = [columnsName objectAtIndex:i];
        label.textAlignment = NSTextAlignmentCenter;
        [fixedTableHeader addSubview:label];
    }
    return fixedTableHeader;
}

-(UIView *)MaintableViewForHeader{
    UIView *mainTableHeader = [[UIView alloc] init];
    mainTableHeader.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
    
    NSArray *columnsName = [_delegate columnsInMainTableView];
    for (int i = 0; i < [columnsName count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * (_mainColumnSize + 14) + 77, 0, _mainColumnSize + 14, 22)];
        label.numberOfLines = 0;
        [label setAdjustsFontSizeToFitWidth:YES];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:18.0f];
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.borderWidth = 0.5;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [columnsName objectAtIndex:i];
        [mainTableHeader addSubview:label];
    }
    
    NSArray *columnsSecondName = [_delegate columnsSecondInMainTableView];
    for (int i = 0; i < [columnsSecondName count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * (_mainColumnSize + 14) / 2 + 77, 22, (_mainColumnSize + 14) / 2, 22)];
        label.numberOfLines = 0;
        [label setAdjustsFontSizeToFitWidth:YES];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:17.0f];
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.borderWidth = 0.5;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [columnsSecondName objectAtIndex:i];
        [mainTableHeader addSubview:label];
    }
    
    NSArray *columnsRemove = [_delegate columnsRemoveInMainTableView];
    for (int i = 0; i < [columnsRemove count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4 * (_mainColumnSize + 14) + 77, 0, _mainColumnSize - 70, 44)];
        label.numberOfLines = 0;
        [label setAdjustsFontSizeToFitWidth:YES];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
        label.font = [UIFont boldSystemFontOfSize:18.0f];
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.borderWidth = 0.5;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [columnsRemove objectAtIndex:i];
        [mainTableHeader addSubview:label];
    }
    
    NSArray *columnsManual = [_delegate columnsManualInMainTableView];
    for (int i = 0; i < [columnsManual count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * (_mainColumnSize + 14), 0, (_mainColumnSize + 14) / 2, 44)];
        label.numberOfLines = 0;
        [label setAdjustsFontSizeToFitWidth:YES];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
        label.font = [UIFont boldSystemFontOfSize:18.0f];
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.borderWidth = 0.5;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [columnsManual objectAtIndex:i];
        [mainTableHeader addSubview:label];
    }
    
    return mainTableHeader;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_fixedTableView] && section == 0) {
        return [self FixedtableViewForHeader];
    }else if ([tableView isEqual:_mainTableView] && section == 0) {
        return [self MaintableViewForHeader];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_delegate numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_delegate tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [_delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return _columnHeightSize;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_fixedTableView]) {
        FSActionPlanCell *cell = nil;
        static NSString *CellIdentifier = @"ActionPlanFixedViewCell";
        cell = (FSActionPlanCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            NSArray *columnsName = [_delegate columnsInFixedTableView];
            cell = [[FSActionPlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier AndLabelAmount:(int)[columnsName count]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        for (int i = 0; i < [cell.labels count]; i++) {
            UILabel *label = [cell.labels objectAtIndex:i];
            label.frame = CGRectMake(i * _fixedColumnSize, 0, _fixedColumnSize, _columnHeightSize);
            [_delegate updateFixedTableViewCellLabel:label cellForColumnAtIndex:i cellForRowAtIndexPath:indexPath];
        }
        return cell;
    } else if ([tableView isEqual:_mainTableView]) {
        FSActionPlanMainCell *cell = nil;
        static NSString *CellIdentifier;
        if (_term) {
            CellIdentifier = @"Long";
        }else{
            CellIdentifier = @"Short";
        }

        cell = (FSActionPlanMainCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[FSActionPlanMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        [_delegate updateMainTableViewCellStrBuyBtn:cell.strBuyBtn TargetText:cell.targetText BuyRefLabel:cell.buyLabel CostLabel:cell.costLabel LastLabel:cell.lastLabel SPText:cell.spText SLText:cell.slText StrSellBtn:cell.strSellBtn RefLabel:cell.refLabel RemoveLabel:cell.remove cellForRowAtIndexPath:indexPath Cell:cell];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:_fixedTableView]) {
        
        [_mainTableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        
    } else if ([tableView isEqual:_mainTableView]) {
        
        [_fixedTableView selectRowAtIndexPath:indexPath
                                     animated:YES
                               scrollPosition:UITableViewScrollPositionNone];
    }
    
    [_mainTableView deselectRowAtIndexPath:indexPath animated:YES];
    [_fixedTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        return [_delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:NSClassFromString(@"FSActionPlanCell")]) {
        if ([_delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
            return [_delegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
        }
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        return [_delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        return [_delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (NSArray *)indexPathsForVisibleRows{
    return [_mainTableView indexPathsForVisibleRows];
}

-(void)reloadData{
    [_mainTableView reloadData];
    [_fixedTableView reloadData];
}

-(void)reloadDataNoOffset{
    [_fixedTableView reloadSectionIndexTitles];
    [_mainTableView reloadSectionIndexTitles];
    [_fixedTableView reloadData];
    [_mainTableView reloadData];
}

- (void)reloadRowsAtIndexPaths:(NSInteger)indexPaths{
    NSIndexPath *path = [NSIndexPath indexPathForRow:indexPaths inSection:0];
    NSArray *myArray = [NSArray arrayWithObjects:path, nil];
    [_fixedTableView reloadRowsAtIndexPaths:myArray withRowAnimation:UITableViewRowAnimationNone];
    [_mainTableView reloadRowsAtIndexPaths:myArray withRowAnimation:UITableViewRowAnimationNone];
}

-(void)reloadRowsAtIndexPaths:(NSInteger)indexPaths lastPrice:(float)lastPrice{
    NSArray *cellArray = [_mainTableView indexPathsForVisibleRows];
    NSArray *array = [_mainTableView visibleCells];
    for (int i = 0; i < [cellArray count]; i++) {
        NSIndexPath *path = [cellArray objectAtIndex:i];
        if (path.row == indexPaths) {
            FSActionPlanMainCell *cell = [array objectAtIndex:i];
            cell.lastLabel.text = [NSString stringWithFormat:@"%.2f", lastPrice];
            break;
        }
    }
}

@end
