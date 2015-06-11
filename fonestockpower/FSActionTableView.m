//
//  FSActionTableView.m
//  FonestockPower
//
//  Created by Derek on 2014/5/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionTableView.h"
#import "FSActionCell.h"

@implementation FSActionTableView
- (void)setDelegate:(id<FSActionTableViewDelegate>)delegate {
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
    
    NSString *layoutString = [NSString stringWithFormat:@"H:|[_fixedTableView(%d)][_mainScrollView]|", (int)((int)_fixedColumnSize * [[_delegate columnsInFixedTableView] count])];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutString options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_fixedTableView]|" options:0 metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainScrollView]|" options:0 metrics:nil views:viewControllers]];
    
    NSInteger mainViewWidth = _mainColumnSize * [[_delegate columnsInMainTableView] count] + 100;
    layoutString = [NSString stringWithFormat:@"H:|[_mainTableView(>=_mainScrollView@2,%d@1)]|", (int)mainViewWidth];
    
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
        label.adjustsFontSizeToFitWidth = YES;
        [fixedTableHeader addSubview:label];
    }
    return fixedTableHeader;
}

-(UIView *)MaintableViewForHeader{
    UIView *mainTableHeader = [[UIView alloc] init];
    mainTableHeader.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
    
    NSArray *columnsName = [_delegate columnsInMainTableView];
    for (int i = 0; i < [columnsName count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * _mainColumnSize - 20, 0, _mainColumnSize, 44)];
        if (i == 0) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _mainColumnSize - 30, 44)];
        }
        if (i == 4) {
            label.frame = CGRectMake(i * _mainColumnSize, 0, _mainColumnSize * 1.5, 44);
        }
        if (i == 5) {
            label.frame = CGRectMake(i * _mainColumnSize + 50, 0, _mainColumnSize, 44);
        }
        if (i == 6) {
            label.frame = CGRectMake(i * _mainColumnSize + 50, 0, _mainColumnSize * 1.5, 44);
        }
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:18.0f];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentRight;
        label.text = [columnsName objectAtIndex:i];
        label.adjustsFontSizeToFitWidth = YES;
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
    return 1;
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
   FSActionCell *cell = nil;
    
    if ([tableView isEqual:_fixedTableView]) {
        
        static NSString *CellIdentifier = @"ActionPlanFixedViewCell";
        
        cell = (FSActionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            
            NSArray *columnsName = [_delegate columnsInFixedTableView];
            
            cell = [[FSActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier AndLabelAmount:[columnsName count]+2];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (int i = 0; i < [cell.labels count]; i++) {
            UILabel *label = [cell.labels objectAtIndex:i];
            label.frame = CGRectMake(i * _fixedColumnSize, 0, _fixedColumnSize, 44);
            [_delegate updateFixedTableViewCellLabel:label cellForColumnAtIndex:i cellForRowAtIndexPath:indexPath];
        }
        
    } else if ([tableView isEqual:_mainTableView]) {
        
        static NSString *CellIdentifier = @"ActionPlanMainViewCell";
        
        cell = (FSActionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            NSArray *columnsName = [_delegate columnsInMainTableView];
            
            cell = [[FSActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier AndLabelAmount:[columnsName count]];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (int i = 0; i < [cell.labels count]; i++) {
            UILabel *label = [cell.labels objectAtIndex:i];
            label.frame = CGRectMake(i * _mainColumnSize - 20, 0, _mainColumnSize, 44);
            if (i == 0) {
                label.frame = CGRectMake(0, 0, _mainColumnSize - 30, 44);
            }
            if (i == 4) {
                label.frame = CGRectMake(i * _mainColumnSize, 0, _mainColumnSize * 1.5, 44);
            }
            if (i == 5) {
                label.frame = CGRectMake(i * _mainColumnSize + 50, 0, _mainColumnSize, 44);
            }
            if (i == 6) {
                label.frame = CGRectMake(i * _mainColumnSize + 50, 0, _mainColumnSize * 1.5, 44);
            }
            [_delegate updateMainTableViewCellLabel:label cellForColumnAtIndex:i cellForRowAtIndexPath:indexPath];
        }
    }
	cell.delegate = self;
    cell.tag = indexPath.row;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        return [_delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
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

-(void)reloadDataNoOffset{
    [_fixedTableView reloadSectionIndexTitles];
    [_mainTableView reloadSectionIndexTitles];
    [_fixedTableView reloadData];
    [_mainTableView reloadData];
    
    [self setNeedsUpdateConstraints];
}

- (void)reloadAllData {
    
    CGPoint newOffset = CGPointMake(0, 0);
    [_mainScrollView setContentOffset:newOffset animated:NO];
    [_fixedTableView setContentOffset:newOffset animated:NO];
    [_mainTableView setContentOffset:newOffset animated:NO];
    
    [_fixedTableView reloadSectionIndexTitles];
    [_mainTableView reloadSectionIndexTitles];
    [_fixedTableView reloadData];
    [_mainTableView reloadData];
    
    [self setNeedsUpdateConstraints];
}
-(void)toTableView:(FSActionCell *)cell{
    [_delegate addToPerformance:cell];
}
@end
