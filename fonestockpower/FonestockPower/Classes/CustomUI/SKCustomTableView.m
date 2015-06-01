//
//  SKCustomTableView.m
//  WirtsLeg
//
//  Created by Connor on 13/8/16.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "SKCustomTableView.h"
#import "SKCustomTableViewCell.h"

@interface SKCustomTableView ()

@property (strong, nonatomic) UIScrollView *mainScrollView;

@end

#define fixedTableViewHeaderBackgroundColor [UIColor colorWithRed: 0.0/255.0 green: 78.0/255.0 blue: 162.0/255.0 alpha: 1.0]
#define mainTableViewHeaderBackgroundColor [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0]

#define tableViewCellSeperateLineColor [UIColor colorWithRed: 155.0/255.0 green: 155.0/255.0 blue: 155.0/255.0 alpha: 1.0]

#define tableViewCellTouthInSideBackgroudColor [UIColor colorWithRed: 254.0/255.0 green: 189.0/255.0 blue: 36.0/255.0 alpha: 1.0]

@implementation SKCustomTableView

- (void)setDelegate:(id<SKCustomTableViewDelegate>)delegate {
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
        _fixedTableView.separatorColor = tableViewCellSeperateLineColor;
        _fixedTableView.showsHorizontalScrollIndicator = NO;
        _fixedTableView.showsVerticalScrollIndicator = NO;
        [self addSubview:_fixedTableView];
        
        _mainTableView = [[UITableView alloc] init];
        _mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
        _mainTableView.bounces = NO;
        _mainTableView.directionalLockEnabled = NO;
        _mainTableView.separatorColor = tableViewCellSeperateLineColor;
        
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

- (void)setFixedColumnSize:(int)fixedColumnSize mainColumnWidth:(int)mainColumnSize AndColumnHeight:(int)columnHeightSize {
    _fixedColumnSize = fixedColumnSize;
    _mainColumnSize = mainColumnSize;
    _columnHeightSize = columnHeightSize;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self removeConstraints:self.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_fixedTableView, _mainTableView, _mainScrollView);
    
    NSString *layoutString = [NSString stringWithFormat:@"H:|[_fixedTableView(%d)][_mainScrollView]|", (int)_fixedColumnSize * (int)[[_delegate columnsInFixedTableView] count]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutString options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_fixedTableView]|" options:0 metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainScrollView]|" options:0 metrics:nil views:viewControllers]];
    
    int mainViewWidth = (int)_mainColumnSize * (int)[[_delegate columnsInMainTableView] count];
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

-(UIView *)FixedtableViewForHeader{
    UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
    
    UIView *fixedTableHeader = [[UIView alloc] init];
    fixedTableHeader.backgroundColor = fixedTableViewHeaderBackgroundColor;
        
    NSArray *columnsName = [_delegate columnsInFixedTableView];
    for (int i = 0; i < [columnsName count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * _fixedColumnSize, 0, _fixedColumnSize, 44)];
        label.font = font;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = [columnsName objectAtIndex:i];
        label.textAlignment = NSTextAlignmentLeft;
        [fixedTableHeader addSubview:label];
    }
    return fixedTableHeader;
}

-(UIView *)MaintableViewForHeader{
    UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
    UIView *mainTableHeader = [[UIView alloc] init];
    mainTableHeader.backgroundColor = mainTableViewHeaderBackgroundColor;
    
    NSArray *columnsName = [_delegate columnsInMainTableView];
    for (int i = 0; i < [columnsName count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * _mainColumnSize, 0, _mainColumnSize, 44)];
        label.numberOfLines = 0;
        [label setAdjustsFontSizeToFitWidth:YES];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.backgroundColor = [UIColor clearColor];
        label.font = font;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [columnsName objectAtIndex:i];
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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SKCustomTableViewCell *cell = nil;
    
    if ([tableView isEqual:_fixedTableView]) {
        
        static NSString *CellIdentifier = @"StockPickingWizardResultFixedViewCell";
        
        cell = (SKCustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {

            NSArray *columnsName = [_delegate columnsInFixedTableView];
            
            cell = [[SKCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier AndLabelAmount:(int)[columnsName count]];
            
//            UIView *selectedBackgroundView = [[UIView alloc] init];
//            selectedBackgroundView.backgroundColor = tableViewCellTouthInSideBackgroudColor;
//            cell.selectedBackgroundView = selectedBackgroundView;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (int i = 0; i < [cell.labels count]; i++) {
            UILabel *label = [cell.labels objectAtIndex:i];
            label.frame = CGRectMake(i * _fixedColumnSize, 0, _fixedColumnSize, _columnHeightSize);
            label.textAlignment = NSTextAlignmentCenter;
            [_delegate updateFixedTableViewCellLabel:label cellForColumnAtIndex:i cellForRowAtIndexPath:indexPath];
        }
        
    } else if ([tableView isEqual:_mainTableView]) {
        
        static NSString *CellIdentifier = @"StockPickingWizardResultMainViewCell";
        
        cell = (SKCustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[SKCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier AndLabelAmount:25];

//            UIView *selectedBackgroundView = [[UIView alloc] init];
//            selectedBackgroundView.backgroundColor = tableViewCellTouthInSideBackgroudColor;
//            cell.selectedBackgroundView = selectedBackgroundView;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
                
        for (int i = 0; i < [cell.labels count]; i++) {
            UILabel *label = [cell.labels objectAtIndex:i];
            label.frame = CGRectMake(i * _mainColumnSize, 0, _mainColumnSize, _columnHeightSize);
            label.textAlignment = NSTextAlignmentRight;
            [_delegate updateMainTableViewCellLabel:label cellForColumnAtIndex:i cellForRowAtIndexPath:indexPath];
        }
    }
	
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_delegate tableView:tableView numberOfRowsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_delegate numberOfSectionsInTableView:tableView];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [_delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return _columnHeightSize;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        return [_delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}


@end
