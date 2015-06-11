//
//  FSOptionTableView.m
//  FonestockPower
//
//  Created by Derek on 2014/9/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSOptionTableView.h"

#define fixedTableViewHeaderBackgroundColor [UIColor colorWithRed: 0.0/255.0 green: 78.0/255.0 blue: 162.0/255.0 alpha: 1.0]
#define mainTableViewHeaderBackgroundColor [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0]

#define tableViewCellSeperateLineColor [UIColor colorWithRed: 155.0/255.0 green: 155.0/255.0 blue: 155.0/255.0 alpha: 1.0]

#define tableViewCellTouthInSideBackgroudColor [UIColor colorWithRed: 254.0/255.0 green: 189.0/255.0 blue: 36.0/255.0 alpha: 1.0]

@interface FSOptionTableView ()
@property (strong, nonatomic) UIScrollView *leftScrollView;
@property (strong, nonatomic) UIScrollView *rightScrollView;

@end

@implementation FSOptionTableView
- (void)setDelegate:(id<FSOptionTableViewDelegate>)delegate {
    _delegate = delegate;
}

- (id)initWithleftColumnWidth:(int)leftColumnSize fixedColumnWidth:(int)fixedColumnSize rightColumnWidth:(int)rightColumnSize AndColumnHeight:(int)columnHeightSize{
    self = [super init];
    if (self) {
        _leftColumnSize = leftColumnSize;
        _fixedColumnSize = fixedColumnSize;
        _rightColumnSize = rightColumnSize;
        _columnHeightSize = columnHeightSize;
        
        _fixedTableView = [[UITableView alloc] init];
        _fixedTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _fixedTableView.dataSource = self;
        _fixedTableView.delegate = self;
        _fixedTableView.separatorColor = tableViewCellSeperateLineColor;
        _fixedTableView.bounces = NO;
        _fixedTableView.directionalLockEnabled = NO;
        _fixedTableView.showsHorizontalScrollIndicator = NO;
        _fixedTableView.showsVerticalScrollIndicator = NO;
        [self addSubview:_fixedTableView];
        
        _leftTableView = [[UITableView alloc] init];
        _leftTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _leftTableView.dataSource = self;
        _leftTableView.delegate = self;
        _leftTableView.separatorColor = tableViewCellSeperateLineColor;
        _leftTableView.bounces = NO;
        _leftTableView.directionalLockEnabled = NO;
        _leftTableView.showsHorizontalScrollIndicator = NO;
        _leftTableView.showsVerticalScrollIndicator = NO;
        
        _leftScrollView = [[UIScrollView alloc] init];
        _leftScrollView.backgroundColor = [UIColor lightGrayColor];
        _leftScrollView.delegate = self;
        _leftScrollView.bounces = NO;
        _leftScrollView.directionalLockEnabled = NO;
        _leftScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _leftScrollView.contentSize = CGSizeMake(_leftTableView.frame.size.width, _leftScrollView.frame.size.height);
        [_leftScrollView addSubview:_leftTableView];
        [self addSubview:_leftScrollView];
        
        _rightTableView = [[UITableView alloc] init];
        _rightTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _rightTableView.dataSource = self;
        _rightTableView.delegate = self;
        _rightTableView.separatorColor = tableViewCellSeperateLineColor;
        _rightTableView.bounces = NO;
        _rightTableView.directionalLockEnabled = NO;
        _rightTableView.showsHorizontalScrollIndicator = NO;
        _rightTableView.showsVerticalScrollIndicator = NO;
        
        _rightScrollView = [[UIScrollView alloc] init];
        _rightScrollView.backgroundColor = [UIColor lightGrayColor];
        _rightScrollView.delegate = self;
        _rightScrollView.bounces = NO;
        _rightScrollView.directionalLockEnabled = NO;
        _rightScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _rightScrollView.contentSize = CGSizeMake(_rightTableView.frame.size.width, _rightScrollView.frame.size.height);
        [_rightScrollView addSubview:_rightTableView];
        [self addSubview:_rightScrollView];
    }
    return self;
}

- (void)setFixedColumnSize:(int)fixedColumnSize leftColumnWidth:(int)leftColumnSize rightColumnWidth:(int)rightColumnSize AndColumnHeight:(int)columnHeightSize{
    _fixedColumnSize = fixedColumnSize;
    _leftColumnSize = leftColumnSize;
    _rightColumnSize = rightColumnSize;
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
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_fixedTableView, _leftTableView, _leftScrollView, _rightTableView, _rightScrollView);
    
    NSString *layoutString = [NSString stringWithFormat:@"H:|[_leftScrollView][_fixedTableView(%d)][_rightScrollView(_leftScrollView)]|", _fixedColumnSize * (int)[[_delegate columnsInFixedTableView] count]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutString options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_fixedTableView]|" options:0 metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftScrollView]|" options:0 metrics:nil views:viewControllers]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightScrollView]|" options:0 metrics:nil views:viewControllers]];

    
    int leftViewWidth = _leftColumnSize * (int)[[_delegate columnsInLeftTableView] count];
    layoutString = [NSString stringWithFormat:@"H:|[_leftTableView(>=_leftScrollView@2,%d@1)]|", leftViewWidth];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutString options:0 metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftTableView(==_leftScrollView)]|" options:0 metrics:nil views:viewControllers]];
    
    int rightViewWidth = _rightColumnSize * (int)[[_delegate columnsInRightTableView] count];
    layoutString = [NSString stringWithFormat:@"H:|[_rightTableView(>=_rightScrollView@2,%d@1)]|", rightViewWidth];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:layoutString options:0 metrics:nil views:viewControllers]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightTableView(==_rightScrollView)]|" options:0 metrics:nil views:viewControllers]];
}

#pragma mark scrollview delegate 三個table同步捲動
- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if ([sender isEqual:_fixedTableView]) {
        _leftTableView.contentOffset = _fixedTableView.contentOffset;
        _rightTableView.contentOffset = _fixedTableView.contentOffset;
    } else if ([sender isEqual:_leftTableView]) {
        _fixedTableView.contentOffset = _leftTableView.contentOffset;
        _rightTableView.contentOffset = _leftTableView.contentOffset;
    } else if ([sender isEqual:_rightTableView]){
        _leftTableView.contentOffset = _rightTableView.contentOffset;
        _fixedTableView.contentOffset = _rightTableView.contentOffset;
    } else if ([sender isEqual:_leftScrollView]){
        _rightScrollView.contentOffset = _leftScrollView.contentOffset;
    } else if ([sender isEqual:_rightScrollView]){
        _leftScrollView.contentOffset = _rightScrollView.contentOffset;
    }
    if ([_delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        return [_delegate scrollViewDidScroll:sender];
    }
}

-(UIView *)fixedTableViewForHeader{
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
        label.textAlignment = NSTextAlignmentCenter;
        [fixedTableHeader addSubview:label];
    }
    return fixedTableHeader;
}

-(UIView *)leftTableViewForHeader{
    UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
    UIView *leftTableHeader = [[UIView alloc] init];
    leftTableHeader.backgroundColor = mainTableViewHeaderBackgroundColor;
    
    NSArray *columnsName = [_delegate columnsInLeftTableView];
    for (int i = 0; i < [columnsName count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * _leftColumnSize, 0, _leftColumnSize, 44)];
        label.numberOfLines = 0;
        [label setAdjustsFontSizeToFitWidth:YES];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.backgroundColor = [UIColor clearColor];
        label.font = font;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [columnsName objectAtIndex:i];
        [leftTableHeader addSubview:label];
    }
    
    return leftTableHeader;
}

-(UIView *)rightTableViewForHeader{
    UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
    UIView *rightTableHeader = [[UIView alloc] init];
    rightTableHeader.backgroundColor = mainTableViewHeaderBackgroundColor;
    
    NSArray *columnsName = [_delegate columnsInRightTableView];
    for (int i = 0; i < [columnsName count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * _rightColumnSize, 0, _rightColumnSize, 44)];
        label.numberOfLines = 0;
        [label setAdjustsFontSizeToFitWidth:YES];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.backgroundColor = [UIColor clearColor];
        label.font = font;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [columnsName objectAtIndex:i];
        [rightTableHeader addSubview:label];
    }
    
    return rightTableHeader;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_fixedTableView] && section == 0) {
        return [self fixedTableViewForHeader];
    }else if ([tableView isEqual:_leftTableView] && section == 0) {
        return [self leftTableViewForHeader];
    }else if ([tableView isEqual:_rightTableView] && section == 0) {
        return [self rightTableViewForHeader];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSOptionCell *cell = nil;
    if ([tableView isEqual:_fixedTableView]) {
        static NSString *CellIdentifier = @"StockPickingWizardResultFixedViewCell";
        
        cell = (FSOptionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            
            NSArray *columnsName = [_delegate columnsInFixedTableView];
            
            cell = [[FSOptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier AndLabelAmount:(int)[columnsName count]];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (int i = 0; i < [cell.labels count]; i++) {
            UILabel *label = [cell.labels objectAtIndex:i];
            label.frame = CGRectMake(i * _fixedColumnSize, 0, _fixedColumnSize, _columnHeightSize);
            [_delegate updateFixedTableViewCellLabel:label cellForColumnAtIndex:i cellForRowAtIndexPath:indexPath];
        }
    }else if ([tableView isEqual:_leftTableView]){
        static NSString *CellIdentifier = @"StockPickingWizardResultMainViewCell";
        
        cell = (FSOptionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[FSOptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier AndLabelAmount:25];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (int i = 0; i < [cell.labels count]; i++) {
            UILabel *label = [cell.labels objectAtIndex:i];
            label.frame = CGRectMake(i * _leftColumnSize, 0, _leftColumnSize, _columnHeightSize);
            [_delegate updateLeftTableViewCellLabel:label cellForColumnAtIndex:i cellForRowAtIndexPath:indexPath];
        }
    }else if ([tableView isEqual:_rightTableView]){
        static NSString *CellIdentifier = @"StockPickingWizardResultMainViewCell";
        
        cell = (FSOptionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[FSOptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier AndLabelAmount:25];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (int i = 0; i < [cell.labels count]; i++) {
            UILabel *label = [cell.labels objectAtIndex:i];
            label.frame = CGRectMake(i * _rightColumnSize, 0, _rightColumnSize, _columnHeightSize);
            [_delegate updateRightTableViewCellLabel:label cellForColumnAtIndex:i cellForRowAtIndexPath:indexPath];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [_delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return _columnHeightSize;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_fixedTableView]) {
        [_leftTableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        [_rightTableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
    }else if ([tableView isEqual:_leftTableView]){
        [_fixedTableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        [_rightTableView selectRowAtIndexPath:indexPath
                                     animated:YES
                               scrollPosition:UITableViewScrollPositionNone];
        if ([_delegate respondsToSelector:@selector(tableView:didSelectLeftRowAtIndexPath:)]) {
            return [_delegate tableView:_rightTableView didSelectLeftRowAtIndexPath:indexPath];
        }
    }else if ([tableView isEqual:_rightTableView]){
        [_fixedTableView selectRowAtIndexPath:indexPath
                                     animated:YES
                               scrollPosition:UITableViewScrollPositionNone];
        [_leftTableView selectRowAtIndexPath:indexPath
                                     animated:YES
                               scrollPosition:UITableViewScrollPositionNone];
        if ([_delegate respondsToSelector:@selector(tableView:didSelectRightRowAtIndexPath:)]) {
            return [_delegate tableView:_rightTableView didSelectRightRowAtIndexPath:indexPath];
        }
    }
    
    [_fixedTableView deselectRowAtIndexPath:indexPath animated:YES];
    [_leftTableView deselectRowAtIndexPath:indexPath animated:YES];
    [_rightTableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)reloadAllData {
    
    CGPoint newOffset = CGPointMake(0, 0);
    [_leftScrollView setContentOffset:newOffset animated:NO];
    [_rightScrollView setContentOffset:newOffset animated:NO];
    [_fixedTableView setContentOffset:newOffset animated:NO];
    [_leftTableView setContentOffset:newOffset animated:NO];
    [_rightTableView setContentOffset:newOffset animated:NO];
    
    [_fixedTableView reloadSectionIndexTitles];
    [_leftTableView reloadSectionIndexTitles];
    [_rightTableView reloadSectionIndexTitles];

    [_fixedTableView reloadData];
    [_leftTableView reloadData];
    [_rightTableView reloadData];
    
    [self setNeedsUpdateConstraints];
}

-(void)reloadDataNoOffset{
    [_fixedTableView reloadSectionIndexTitles];
    [_leftTableView reloadSectionIndexTitles];
    [_rightTableView reloadSectionIndexTitles];
    [_fixedTableView reloadData];
    [_leftTableView reloadData];
    [_rightTableView reloadData];
    
    [self setNeedsUpdateConstraints];
}

-(void)scrollToRowAtIndexPath:(NSIndexPath *)path{
    [_fixedTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [_rightTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [_leftTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

@end