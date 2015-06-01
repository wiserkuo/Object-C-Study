//
//  FSOptionMainViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/10/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSOptionMainViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSOptionViewController.h"
#import "FSOptionTrialViewController.h"
#import "FSOptionStrategyViewController.h"

@interface FSOptionMainViewController ()<UIActionSheetDelegate>{
    FSUIButton *quoteBtn;
    FSUIButton *trialBtn;
    FSUIButton *strategyBtn;
    UIView *mainframeView;
    FSDataModelProc *dataModel;
    FSOptionViewController *view;
    FSOptionTrialViewController *view2;
    FSOptionStrategyViewController *view3;
    
    BOOL back;
    BOOL back2;
    Option *optionData;
}

@end

@implementation FSOptionMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dataModel = [FSDataModelProc sharedInstance];
    optionData = [[FSDataModelProc sharedInstance] option];
    
	// Do any additional setup after loading the view.
    quoteBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    quoteBtn.frame = CGRectMake(0, 0, 55, 44);
    [quoteBtn setTitle:@"報價" forState:UIControlStateNormal];
    [quoteBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *quoteBtnItem = [[UIBarButtonItem alloc] initWithCustomView:quoteBtn];
    quoteBtn.selected = YES;
    
    trialBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    trialBtn.frame = CGRectMake(0, 0, 55, 44);
    [trialBtn setTitle:@"試算" forState:UIControlStateNormal];
    [trialBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *trialBtnItem = [[UIBarButtonItem alloc] initWithCustomView:trialBtn];
    
    strategyBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    strategyBtn.frame = CGRectMake(0, 0, 55, 44);
    [strategyBtn setTitle:@"策略" forState:UIControlStateNormal];
    [strategyBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *strategyBtnItem = [[UIBarButtonItem alloc] initWithCustomView:strategyBtn];
    
    NSArray *buttons = @[strategyBtnItem, trialBtnItem, quoteBtnItem];
    self.navigationItem.rightBarButtonItems = buttons;
    
    [self.navigationItem setTitle:@"選擇權"];
    [self setUpImageBackButton];
    
    mainframeView = [[UIView alloc] init];
    mainframeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainframeView];
    
    _titleArray = [[NSArray alloc] initWithObjects:@"看大漲", @"看大跌", @"看不漲", @"看不跌", @"看變盤", @"看盤整", @"看小漲", @"小漲作莊", @"看小跌", @"小跌作莊", nil];
    
    view = [[FSOptionViewController alloc] init];
    view2 = [[FSOptionTrialViewController alloc] init];
    [self insertViewControllerInMainFrameView:view];
    
    optionData.goodsNum = 0;
    optionData.monthNum = 0;
    
    //catID = 19:指數 catID = 20:股票
    [dataModel.securityName setTarget:self];
    [dataModel.option setNotifyObj:self];
    SecurityNameData *stockData = dataModel.securityName;
    catID = 19;
    [stockData selectCatID:catID];
    catID = 20;
    [stockData selectCatID:catID];
    
    [self.view setNeedsUpdateConstraints];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notify Data Arrive
-(void)notify{
    if (back) {
        [self sendOptionDataWithGoodsNum:optionData.goodsNum MonthNum:optionData.monthNum];
        [view initBtnTitle];
    }
    back = YES;
}

-(void)notifyData{
    if (back2) {
        [view initLabelText];
        [dataModel.option sortArray];
        [view.tableView reloadAllData];
        [view scrollToNearestStrikePrice];
        
        [view2 initLabelText];
        [view2.tableView reloadDataNoOffset];
        
        [view3 initData];
        [view3.mainTableView reloadData];
    }
    back2 = YES;
}

-(void)notifyTickData{
    [view initLabelText];
    [view.tableView reloadDataNoOffset];
    [view2 initLabelText];
    [view2.tableView reloadDataNoOffset];
    [view3 initData];
    [view3.mainTableView reloadData];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    NSDictionary *viewController = NSDictionaryOfVariableBindings(mainframeView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainframeView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainframeView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
}

#pragma mark - Send
-(void)sendOptionDataWithGoodsNum:(NSUInteger)goodsArrayNum MonthNum:(NSUInteger)monthArrayNum{
    dataModel = [FSDataModelProc sharedInstance];
    optionData = [[FSDataModelProc sharedInstance] option];
    optionData.goodsArray = [dataModel.securityName searchGoods];
    optionData.monthArray = [dataModel.securityName searchMonthsWithFullName:[[optionData.goodsArray objectAtIndex:goodsArrayNum] objectForKey:@"groupFullName"]];
    UInt8 year = [(NSNumber *)[[optionData.monthArray objectAtIndex:monthArrayNum] objectForKey:@"mesYear"] intValue];
    UInt8 month = [(NSNumber *)[[optionData.monthArray objectAtIndex:monthArrayNum] objectForKey:@"mesMonth"] intValue];
    [dataModel.option sendAndRead:[[optionData.monthArray objectAtIndex:monthArrayNum] objectForKey:@"identCodeSymbol"] Year:year Month:month];
}

#pragma mark - Button Action
-(void)btnAction:(id)sender{
    if ([sender isEqual:quoteBtn]) {
        quoteBtn.selected = YES;
        trialBtn.selected = NO;
        strategyBtn.selected = NO;
        view = [[FSOptionViewController alloc] init];
        [self insertViewControllerInMainFrameView:view];
    }else if ([sender isEqual:trialBtn]){
        trialBtn.selected = YES;
        quoteBtn.selected = NO;
        strategyBtn.selected = NO;
        view2 = [[FSOptionTrialViewController alloc] init];
        [self insertViewControllerInMainFrameView:view2];
    }else if ([sender isEqual:strategyBtn]){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"策略選擇" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        for (int i = 0; i < [_titleArray count]; i++) {
            [actionSheet addButtonWithTitle:[_titleArray objectAtIndex:i]];
        }
        [actionSheet addButtonWithTitle:@"取消"];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
        [self showActionSheet:actionSheet];
    }
}

#pragma makr - ActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }else{
        trialBtn.selected = NO;
        quoteBtn.selected = NO;
        strategyBtn.selected = YES;
        view3 = [[FSOptionStrategyViewController alloc] init];
        view3.strategyTitle = [_titleArray objectAtIndex:buttonIndex];
        view3.cellNum = (int)buttonIndex;
        [self insertViewControllerInMainFrameView:view3];
    }
}

#pragma makr - Insert View
- (void)insertViewControllerInMainFrameView:(UIViewController *)newController {
    // mainframe移除所有view和controller
    [[mainframeView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_mainViewController removeFromParentViewController];
    newController.view.frame = mainframeView.bounds;
    newController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // mainframe新增view和controller
    _mainViewController = newController;
    [newController willMoveToParentViewController:self];
    [self addChildViewController:newController];
    [newController didMoveToParentViewController:self];
    [mainframeView addSubview:newController.view];
}

@end
