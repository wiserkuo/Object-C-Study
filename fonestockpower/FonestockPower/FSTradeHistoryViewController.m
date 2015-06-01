//
//  FSTradeHistoryViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/11/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSTradeHistoryViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSActionPlanDatabase.h"

@interface FSTradeHistoryViewController ()<UIAlertViewDelegate>{
    FSUIButton *moreOptionButton;
    FSUIButton *zeroOptionButton;
    FSUIButton *moreOptionBtnNav;
    FSUIButton *zeroOptionBtnNav;
    
    NSMutableArray *tradeHistoryArray;
    NSMutableArray *layoutContraints;
    
    UILabel *titleLabel;
    
    FSPositionModel *positionModel;
    FSTradeHistory *tradeHistory;
    NSUInteger count;
}

@end

@implementation FSTradeHistoryViewController

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    positionModel = [[FSDataModelProc sharedInstance] positionModel];
    [self initView];
    [self setNavigation];
    if ([_termStr isEqualToString:@"Long"]) {
        moreOptionButton.selected = YES;
        moreOptionBtnNav.selected = YES;
        zeroOptionButton.selected = NO;
        zeroOptionBtnNav.selected = NO;
    }else{
        moreOptionButton.selected = NO;
        moreOptionBtnNav.selected = NO;
        zeroOptionButton.selected = YES;
        zeroOptionBtnNav.selected = YES;
    }
    
    layoutContraints = [[NSMutableArray alloc] init];
    [self.view setNeedsUpdateConstraints];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initData];
    [self setNavigationBtn];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    titleLabel.text = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - set navigation
-(void)setNavigation{
    [self setUpImageBackButton];
    [self setTitle:NSLocalizedStringFromTable(@"History", @"Launcher", nil)];
    NSString *moreOptionTitle = NSLocalizedStringFromTable(@"多方選股形勢", @"Trade", nil);
    moreOptionBtnNav = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    moreOptionBtnNav.frame = CGRectMake(0, 0, 132, 33);
//    moreOptionBtnNav.selected = YES;
    [moreOptionBtnNav setTitle:moreOptionTitle forState:UIControlStateNormal];
    [moreOptionBtnNav addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *zeroOptionTitle = NSLocalizedStringFromTable(@"空方選股形勢", @"Trade", nil);
    zeroOptionBtnNav = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    zeroOptionBtnNav.frame = CGRectMake(0, 0, 132, 33);
//    zeroOptionBtnNav.selected = NO;
    [zeroOptionBtnNav setTitle:zeroOptionTitle forState:UIControlStateNormal];
    [zeroOptionBtnNav addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *moreBtnItem = [[UIBarButtonItem alloc] initWithCustomView:moreOptionBtnNav];
    UIBarButtonItem *zeroBtnItem = [[UIBarButtonItem alloc] initWithCustomView:zeroOptionBtnNav];
    NSArray *itemArray = [[NSArray alloc] initWithObjects:zeroBtnItem, moreBtnItem, nil];
    [self.navigationItem setRightBarButtonItems:itemArray];
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width-8, 66)];
    }else{
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.height-8, 66)];
    }
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [self.navigationController.view addSubview:titleLabel];
}

-(void)setNavigationBtn{
    titleLabel.text = NSLocalizedStringFromTable(@"History", @"Launcher", nil);
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        titleLabel.hidden = NO;
        moreOptionBtnNav.hidden = YES;
        zeroOptionBtnNav.hidden = YES;
    }else{
        titleLabel.hidden = YES;
        moreOptionBtnNav.hidden = NO;
        zeroOptionBtnNav.hidden = NO;
    }
}

#pragma mark - init View
-(void)initView{
    NSString *moreOptionTitle = NSLocalizedStringFromTable(@"多方選股形勢", @"Trade", nil);
    moreOptionButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    moreOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [moreOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    moreOptionButton.selected = YES;
    [moreOptionButton setTitle:moreOptionTitle forState:UIControlStateNormal];
    [moreOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreOptionButton];
    
    NSString *zeroOptionTitle = NSLocalizedStringFromTable(@"空方選股形勢", @"Trade", nil);
    zeroOptionButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    zeroOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [zeroOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [zeroOptionButton setTitle:zeroOptionTitle forState:UIControlStateNormal];
    [zeroOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zeroOptionButton];
    
    _tableView = [[FSTradeHistoryTableView alloc] initWithfixedColumnWidth:100 mainColumnWidth:100 AndColumnHeight:50];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    [self.view removeConstraints:layoutContraints];
    [layoutContraints removeAllObjects];
    
    NSDictionary *viewController = NSDictionaryOfVariableBindings(moreOptionButton, zeroOptionButton, _tableView);
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[moreOptionButton]-2-[zeroOptionButton(==moreOptionButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[moreOptionButton(44)]-2-[_tableView]|" options:0 metrics:nil views:viewController]];
        [self.view addConstraints:layoutContraints];
    }else{
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:viewController]];
        [self.view addConstraints:layoutContraints];
    }
}

#pragma mark - InitData
-(void)initData{
    tradeHistoryArray = [[NSMutableArray alloc] init];
    [positionModel loadTradeHistoryData:_termStr symbol:_symbolStr];
    if (moreOptionButton.selected == YES) {
        [positionModel loadTradeHistoryData:@"Long" symbol:_symbolStr];
        _termStr = @"Long";
    }else{
        [positionModel loadTradeHistoryData:@"Short" symbol:_symbolStr];
        _termStr = @"Short";
    }
    tradeHistoryArray = positionModel.tradeHistoryArray;
    [_tableView reloadData];
}

#pragma mark - Button Action
-(void)optionButtonClick:(FSUIButton *)btn{
    if ([btn isEqual:moreOptionButton] || [btn isEqual:moreOptionBtnNav]) {
        zeroOptionButton.selected = NO;
        moreOptionButton.selected = YES;
        zeroOptionBtnNav.selected = NO;
        moreOptionBtnNav.selected = YES;
    }else if ([btn isEqual:zeroOptionButton] || [btn isEqual:zeroOptionBtnNav]){
        zeroOptionButton.selected = YES;
        moreOptionButton.selected = NO;
        zeroOptionBtnNav.selected = YES;
        moreOptionBtnNav.selected = NO;
    }
    [self initData];
}

-(void)deleteTradeData:(UIButton *)sender{
    UIButton *button = (UIButton *)sender;
    count = button.tag;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"確定刪除此筆記錄?", @"ActionPlan", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil) otherButtonTitles:nil];
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil)];
    [alert show];
}

#pragma mark - 判斷刪除
-(void)judgementDeleteData{
    NSMutableArray *dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:_termStr Symbol:_symbolStr];
    for (int i = 0; i < count; i++) {
        float stockCount = [(NSNumber *)[[dataArray objectAtIndex:count] objectForKey:@"Count"] floatValue];
        float totalCount = [(NSNumber *)[[dataArray objectAtIndex:i] objectForKey:@"TotalCount"] floatValue];
        if (stockCount > totalCount) {
            NSString *alertStr;
            if ([_termStr isEqualToString:@"Long"]) {
                alertStr = NSLocalizedStringFromTable(@"總買進數量需大於總賣出數量，請確認刪除動作", @"ActionPlan", nil);
            }else{
                alertStr = NSLocalizedStringFromTable(@"總放空數量需大於總回補數量，請確認刪除動作", @"ActionPlan", nil);
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil) otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }
    [positionModel deleteTradeHistoryData:count term:_termStr symbol:_symbolStr];
    tradeHistoryArray = positionModel.tradeHistoryArray;
    
    //沒有在ActionPlan則加入
    int exist = [[FSActionPlanDatabase sharedInstances] searchActionPlanDataWithSymbol:_symbolStr term:_termStr];
    if (exist == 0) {
        FSActionPlanDatabase *actionPlanDB = [FSActionPlanDatabase sharedInstances];
        [actionPlanDB insertActionPlanWithSybmol:_symbolStr Manual:[NSNumber numberWithFloat:0.0] Pattern1:[NSNumber numberWithInteger:0] SProfit:[NSNumber numberWithFloat:15] SLoss:[NSNumber numberWithFloat:8] Pattern2:[NSNumber numberWithInteger:0] Term:_termStr SProfit2:[NSNumber numberWithFloat:15] SLoss2:[NSNumber numberWithFloat:8] CostType:@"YES"];
    }
    
    //沒有在watchList則加入
    exist = [[FSActionPlanDatabase sharedInstances] searchGroupPortfolioWithids:_symbolStr];
    if (exist == 0) {
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:_symbolStr];
        [dataModal.portfolioData selectGroupID: 1];
        [dataModal.portfolioData AddItem:secu];
    }
    [_tableView reloadDataNoOffset];
}

#pragma mark - AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        //判斷是否在ActionPlan裡
        int exist = [[FSActionPlanDatabase sharedInstances] searchActionPlanDataWithSymbol:_symbolStr term:_termStr];
        if (exist == 1) {
            [self judgementDeleteData];
        }else{
            //判斷ActionPlan是否加入20隻
            int actionPlanCount = [[FSActionPlanDatabase sharedInstances] searchNumberOfActionPlan];
            if (actionPlanCount >= 19) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"警示個股數量已達設定上限", @"ActionPlan", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil) otherButtonTitles:nil];
                [alert show];
            }else{
                //判斷是否在watchList裡
                exist = [[FSActionPlanDatabase sharedInstances] searchGroupPortfolioWithids:_symbolStr];
                if (exist == 1) {
                    [self judgementDeleteData];
                }else{
                    int groupPortfolioCount = [[FSActionPlanDatabase sharedInstances] searchNumberOfgroupPortfolio];
                    if (groupPortfolioCount >= 79) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"自選股數量已達設定上限", @"ActionPlan", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil) otherButtonTitles:nil];
                        [alert show];
                    }else{
                        [self judgementDeleteData];
                    }
                }
            }
        }
    }
}

#pragma mark - TableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tradeHistoryArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"日期", @"ActionPlan", nil)];
}

-(NSArray *)columnsFirstInMainTableView{
    return @[NSLocalizedStringFromTable(@"股名", @"ActionPlan", nil)];
}

-(NSArray *)columnsSecondInMainTableView{
    return @[NSLocalizedStringFromTable(@"張數", @"ActionPlan", nil)];
}

-(NSArray *)columnsThirdInMainTableView{
    if (moreOptionButton.selected == YES) {
        return @[NSLocalizedStringFromTable(@"(買)成交價", @"ActionPlan", nil), NSLocalizedStringFromTable(@"金額History", @"ActionPlan", nil)];
    }else{
        return @[NSLocalizedStringFromTable(@"(放空)成交價", @"ActionPlan", nil), NSLocalizedStringFromTable(@"金額History", @"ActionPlan", nil)];
    }
}

-(NSArray *)columnsFourthInMainTableView{
    if (moreOptionButton.selected == YES) {
        return @[NSLocalizedStringFromTable(@"(賣)成交價", @"ActionPlan", nil), NSLocalizedStringFromTable(@"金額History", @"ActionPlan", nil)];
    }else{
        return @[NSLocalizedStringFromTable(@"(回補)成交價", @"ActionPlan", nil), NSLocalizedStringFromTable(@"金額History", @"ActionPlan", nil)];
    }
}

-(void)updateFixedTableViewCellDateLabel:(UILabel *)dateLabel cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSTradeHistoryFixedTableViewCell *)cell{
    tradeHistory = [tradeHistoryArray objectAtIndex:indexPath.row];
//    NSString *dateStr = [NSDate dateStringFormat:tradeHistory.date];
    dateLabel.text = [NSString stringWithFormat:@"%@", tradeHistory.date];
}

-(void)updateMainTableViewCellSymbolLabel:(UILabel *)symbolLabel qtyLabel:(UILabel *)qtyLabel buyDealLabel:(UILabel *)buyDealLabel buyAmountLabel:(UILabel *)buyAmountLabel sellDealLable:(UILabel *)sellDealLable sellAmountLabel:(UILabel *)sellAmountLabel removeBtn:(UIButton *)removeBtn cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSTradeHistoryFixedTableViewCell *)cell{
    //股名
    tradeHistory = [tradeHistoryArray objectAtIndex:indexPath.row];
    symbolLabel.text = tradeHistory.symbol;
    buyAmountLabel.textColor = sellAmountLabel.textColor = [UIColor blueColor];
    
    //張數
    if (tradeHistory.buyDealPrice != 0) {
        qtyLabel.text = [NSString stringWithFormat:@"+%@", [CodingUtil CoverFloatWithComma:tradeHistory.qty DecimalPoint:0]];
    }else{
        qtyLabel.text = [NSString stringWithFormat:@"%@", [CodingUtil CoverFloatWithComma:tradeHistory.qty DecimalPoint:0]];
    }

    //(買)成交價
    if (tradeHistory.buyDealPrice != 0) {
        buyDealLabel.text = [NSString stringWithFormat:@"%@", [CodingUtil ConvertFloatWithComma:tradeHistory.buyDealPrice DecimalPoint:2]];
        buyAmountLabel.text = [self setPrice:tradeHistory.buyAmount * positionModel.suggestCount Decimal:0];
    }else{
        buyDealLabel.text = @"";
        buyAmountLabel.text = @"";
    }
    
    //(賣)成交價
    if (tradeHistory.sellDealPrice != 0) {
        sellDealLable.text = [NSString stringWithFormat:@"%@", [CodingUtil ConvertFloatWithComma:tradeHistory.sellDealPrice DecimalPoint:2]];
        sellAmountLabel.text = [self setPrice:abs(tradeHistory.sellAmount * positionModel.suggestCount) Decimal:0];
    }else{
        sellDealLable.text = @"";
        sellAmountLabel.text = @"";
    }
    
    //刪除
    removeBtn.tag = indexPath.row;
    [removeBtn addTarget:self action:@selector(deleteTradeData:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.view setNeedsUpdateConstraints];
    [self setNavigationBtn];
}

-(NSString *)setPrice:(float)Price Decimal:(int)decimal{
    NSString *tempStr = @"";
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        tempStr = [CodingUtil CoverFloatWithCommaForCN:Price];
    }else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        tempStr = [CodingUtil CoverFloatWithComma:Price DecimalPoint:decimal];
    }else{
        tempStr = [CodingUtil CoverFloatWithCommaPositionInfoForCN:Price];
    }
    
    return tempStr;
}

@end
