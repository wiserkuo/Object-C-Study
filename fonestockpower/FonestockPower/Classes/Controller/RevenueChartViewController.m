//
//  RevenueChartViewController.m
//  WirtsLeg
//
//  Created by Connor on 13/12/3.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "RevenueChartViewController.h"
#import "FSUIButton.h"
#import "RadioTableViewCell.h"

@interface RevenueChartViewController ()
{
    FSDataModelProc *dataModal;
    NSString *identCode;
    int typeNum;
    NSMutableArray *titleArray;
}
@property (nonatomic, strong) UILabel *revenueLabel;
@property (nonatomic, strong) UILabel *growRateLabel;
@property (nonatomic, strong) FSUIButton *changeTypeButton;
@property (nonatomic, strong) UIActionSheet *mainActionSheet;
@property (nonatomic, strong) UITableView *actionTableView;
@end

@implementation RevenueChartViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    typeNum = 0;
#ifdef PatternPowerUS
    identCode = @"US";
#endif
    
#ifdef PatternPowerTW
    identCode = @"TW";
#endif
    
#ifdef PatternPowerTW
    identCode = @"CN";
#endif
    titleArray = [[NSMutableArray alloc] initWithObjects:NSLocalizedStringFromTable(@"合併營收", @"Revenue", nil), NSLocalizedStringFromTable(@"非合併營收", @"Revenue", nil), nil];
    self.changeTypeButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    self.changeTypeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.changeTypeButton setTitle:NSLocalizedStringFromTable(@"合併營收", @"Revenue", nil) forState:UIControlStateNormal];
    [self.changeTypeButton addTarget:self action:@selector(changeTypeHandler:) forControlEvents:UIControlEventTouchUpInside];
    if([identCode isEqualToString:@"TW"]){
        [self.view addSubview:self.changeTypeButton];
    }
    
    self.revenueLabel = [[UILabel alloc] init];
    self.revenueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.revenueLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.revenueLabel.text = NSLocalizedStringFromTable(@"營收", @"Equity", nil);
    [self.view addSubview:self.revenueLabel];
    
    self.growRateLabel = [[UILabel alloc] init];
    self.growRateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.growRateLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.growRateLabel.text = NSLocalizedStringFromTable(@"成長率", @"Equity", nil);
    self.growRateLabel.textColor = [UIColor orangeColor];
    self.growRateLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.growRateLabel];
    
    self.revenueChartView = [[RevenueChartView alloc] init];
    self.revenueChartView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.revenueChartView];
    
    [self processLayout];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dataModal = [FSDataModelProc sharedInstance];
    dataModal.nRevenue.chartViewDelegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.revenueChartView cleanChartView];
    dataModal.nRevenue.chartViewDelegate = nil;
}

- (void)processLayout {
    NSDictionary *viewControllers;
    if([identCode isEqualToString:@"TW"]){
        viewControllers = NSDictionaryOfVariableBindings(_revenueLabel, _growRateLabel, _revenueChartView, _changeTypeButton);
    }else{
         viewControllers = NSDictionaryOfVariableBindings(_revenueLabel, _growRateLabel, _revenueChartView);
    }
    
    // _revenueLabel
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_revenueLabel]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_revenueLabel]" options:0 metrics:nil views:viewControllers]];
    
    // _growRateLabel
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_growRateLabel]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_growRateLabel]" options:0 metrics:nil views:viewControllers]];
    
    // _changeTypeButton
    if([identCode isEqualToString:@"TW"]){
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_revenueLabel][_changeTypeButton(100)][_growRateLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_changeTypeButton][_revenueChartView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewControllers]];
    }
    
    // _revenueChartView
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_revenueChartView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_growRateLabel][_revenueChartView]|" options:0 metrics:nil views:viewControllers]];
}

-(void)NewRevenueChartViewNotifyData:(id)target
{
    [self.revenueChartView setNeedsDisplayWithArray:target];
}

-(void)changeTypeHandler:(FSUIButton *)target
{
    NSString *title = NSLocalizedStringFromTable(@"選擇營收", @"Revenue", nil);
    title = [title stringByAppendingString:@"\n\n\n\n\n\n\n"];
    self.mainActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Revenue", nil)  destructiveButtonTitle:nil otherButtonTitles:nil];
    [_mainActionSheet showInView:self.view.window.rootViewController.view];
    self.actionTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, 45, _mainActionSheet.frame.size.width-40, 85) style:UITableViewStylePlain];
    _actionTableView.delegate = self;
    _actionTableView.dataSource = self;
    _actionTableView.bounces = NO;
    _actionTableView.backgroundView = nil;
    [self.mainActionSheet addSubview:_actionTableView];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    RadioTableViewCell *cell = (RadioTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[RadioTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if(indexPath.row == typeNum){
        cell.checkBtn.selected = YES;
    }
    
    cell.textLabel.text = [titleArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    typeNum = (int)indexPath.row;
    [self.revenueChartView setChartViewType:(int)indexPath.row];
    [_mainActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [self.changeTypeButton setTitle:[titleArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [titleArray count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
@end
