//
//  FSActionAlertTableView.m
//  FonestockPower
//
//  Created by Derek on 2014/10/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionAlertTableView.h"

@implementation FSActionAlertTableView

- (void)setDelegate:(id<FSActionAlertTableViewDelegate>)delegate {
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
        _scrollViewDraggingFlag = NO;
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self removeConstraints:self.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_fixedTableView, _mainTableView, _mainScrollView);
    
    NSString *layoutString = [NSString stringWithFormat:@"H:|[_fixedTableView(%d)][_mainScrollView]|", _fixedColumnSize + 66];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutString options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_fixedTableView]|" options:0 metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainScrollView]|" options:0 metrics:nil views:viewControllers]];
    
    int mainViewWidth = _mainColumnSize * 5 - 50;
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
        UILabel *label = [[UILabel alloc] init];
        label.layer.borderWidth = 0.3;
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        if (i == 0) {
            label.frame = CGRectMake(i * _fixedColumnSize, 0, _fixedColumnSize, 44);
        }else{
            label.frame = CGRectMake(i * _fixedColumnSize, 0, 66, 44);
        }
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
    
    NSArray *columnsFirstName = [_delegate columnsFirstInMainTableView];
    for (int i = 0; i < [columnsFirstName count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _mainColumnSize, 44)];
        label.font = [UIFont boldSystemFontOfSize:18.0f];
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.borderWidth = 0.5;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = [columnsFirstName objectAtIndex:i];
        label.textAlignment = NSTextAlignmentCenter;
        [mainTableHeader addSubview:label];
    }
    
    NSArray *columnsSecondName = [_delegate columnsSecondInMainTableView];
    for (int i = 0; i < [columnsSecondName count]; i++) {
        UILabel *label = [[UILabel alloc] init];
        if (i == 0) {
            label.frame = CGRectMake(_mainColumnSize, 0, _mainColumnSize, 22);
        }else{
            label.frame = CGRectMake(_mainColumnSize, 22, _mainColumnSize, 22);
        }
        label.numberOfLines = 0;
        [label setAdjustsFontSizeToFitWidth:YES];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:18.0f];
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.borderWidth = 0.5;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [columnsSecondName objectAtIndex:i];
        [mainTableHeader addSubview:label];
    }
    
    NSArray *columnsThirdName = [_delegate columnsThirdInMainTableView];
    for (int i = 0; i < [columnsThirdName count]; i++) {
        UILabel *label = [[UILabel alloc] init];
        if (i == 0) {
            label.frame = CGRectMake(_mainColumnSize * 2, 0, _mainColumnSize * 2, 22);
        }else if (i == 1){
            label.frame = CGRectMake(_mainColumnSize * 2, 22, _mainColumnSize, 22);
        }else{
            label.frame = CGRectMake(_mainColumnSize * 3, 22, _mainColumnSize, 22);
        }
        label.numberOfLines = 0;
        [label setAdjustsFontSizeToFitWidth:YES];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:18.0f];
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.borderWidth = 0.5;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [columnsThirdName objectAtIndex:i];
        [mainTableHeader addSubview:label];
    }
    
    NSArray *columnsFourthName = [_delegate columnsFourthInMainTableView];
    for (int i = 0; i < [columnsFourthName count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_mainColumnSize * 4, 0, _mainColumnSize, 44)];
        label.numberOfLines = 0;
        [label setAdjustsFontSizeToFitWidth:YES];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:18.0f];
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.borderWidth = 0.5;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [columnsFourthName objectAtIndex:i];
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
    FSActionPlan *actionPlan = [_actionArray objectAtIndex:indexPath.row];
    
    if ([tableView isEqual:_fixedTableView]) {
        if (actionPlan.cellType) {
            FSActionAlertSecondFixedTableViewCell *cell = nil;
            static NSString *CellIdentifier = @"FSActionAlertSecondFixedTableViewCell";
            
            cell = (FSActionAlertSecondFixedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
//            if (cell == nil) {
                NSArray *columnsName = [_delegate columnsInFixedTableView];
                cell = [[FSActionAlertSecondFixedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier AndLabelAmount:(int)[columnsName count]];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            }
            [_delegate updateSecondFixedTableViewCellSymbolLabel:cell.symbolLabel lastLabel:cell.lastLabel tradeBtn:cell.tradeBtn trade2Btn:cell.trade2Btn cellForRowAtIndexPath:indexPath cell:cell];
            return cell;
        }else{
            FSActionAlertFixedTableViewCell *cell = nil;
            NSString *CellIdentifier = @"FSActionAlertFixedTableViewCell";
            
            cell = (FSActionAlertFixedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
//            if (cell == nil) {
                NSArray *columnsName = [_delegate columnsInFixedTableView];
                cell = [[FSActionAlertFixedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier AndLabelAmount:(int)[columnsName count]];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            }
            [_delegate updateFixedTableViewCellSymbolLabel:cell.symbolLabel lastLabel:cell.lastLabel tradeBtn:cell.tradeBtn cellForRowAtIndexPath:indexPath cell:cell];
            return cell;
        }

    } else if ([tableView isEqual:_mainTableView]) {
        if (actionPlan.cellType) {
            FSActionAlertSecondMainTableViewCell *cell = nil;
            static NSString *CellIdentifier = @"FSActionAlertSecondMainTableViewCell";
            
            cell = (FSActionAlertSecondMainTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[FSActionAlertSecondMainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [_delegate updateSecondMainTableViewCellPattern1View:cell.pattern1View Pattern1Label:cell.pattern1Label PatternBtn:cell.patternBtn TargetTextField:cell.targetTextField SPTextField:cell.spTextField SLTextField:cell.slTextField costBtn:cell.costBtn Pattern2View:cell.pattern2View Pattern2Label:cell.pattern2Label pattern2Btn:cell.pattern2Btn SP2TextField:cell.sp2TextField SL2TextField:cell.sl2TextField cellForRowAtIndexPath:indexPath cell:cell];
            return cell;
        }else{
            FSActionAlertMainTableViewCell *cell = nil;
            static NSString *CellIdentifier = @"FSActionAlertMainTableViewCell";
            
            cell = (FSActionAlertMainTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[FSActionAlertMainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [_delegate updateMainTableViewCellPatternView:cell.patternView PatternLabel:cell.patternLabel PatternBtn:cell.patternBtn TargetTextField:cell.targetTextField SPTextField:cell.spTextField SLTextField:cell.slTextField RemoveBtn:cell.removeBtn cellForRowAtIndexPath:indexPath cell:cell];
            return cell;
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:_fixedTableView]) {
        
        [_mainTableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        
        [_mainTableView deselectRowAtIndexPath:indexPath animated:YES];
        [_fixedTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if ([_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            return [_delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
        
    } else if ([tableView isEqual:_mainTableView]) {
        
        return;
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
    if (!decelerate) {
        if (_scrollViewDraggingFlag) {
            _scrollViewDraggingFlag = NO;
        }
    }
    
    if (_scrollViewDraggingFlag) {
        _scrollViewDraggingFlag = NO;
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
    if (!_scrollViewDraggingFlag) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:indexPaths inSection:0];
        NSArray *myArray = [NSArray arrayWithObjects:path, nil];
        [_fixedTableView reloadRowsAtIndexPaths:myArray withRowAnimation:UITableViewRowAnimationNone];
        [_mainTableView reloadRowsAtIndexPaths:myArray withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (!_scrollViewDraggingFlag) {
        _scrollViewDraggingFlag = YES;
    }
}

@end
