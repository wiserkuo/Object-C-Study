//
//  FSOptionTrialViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/10/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSOptionTrialViewController.h"
#import "FSOptionMainViewController.h"
#import "CustomIOS7AlertView.h"
#import "FSOptionInfoViewController.h"

@interface FSOptionTrialViewController () <UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate>{
    FSUIButton *switchGoodsBtn;
    FSUIButton *switchMonthBtn;
    FSUIButton *buySellBtn;
    FSUIButton *bargainBtn;
    UIButton *strikeInputBtn;
    UILabel *callLabel;
    UILabel *strikeLabel;
    UILabel *putLabel;
    
    UIActionSheet *goodsActionSheet;
    UIActionSheet *monthActionSheet;
    UIActionSheet *buySellActionSheet;
    UIActionSheet *bargainActionSheet;
    FSDataModelProc *dataModel;
    FSOptionMainViewController *view;
    FSOptionInfoViewController *view2;
    Option *optionData;
    
    UIAlertView *alert;
    
    BOOL buySellFlag;
    BOOL bargainFlag;
    BOOL callPutFlag;
}

@end

@implementation FSOptionTrialViewController

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
	// Do any additional setup after loading the view.
    dataModel = [FSDataModelProc sharedInstance];
    optionData = [dataModel option];
    [self initView];
    [self initTableView];
    [self initLabelText];
    [self initBtnTitle];
    [self.view setNeedsUpdateConstraints];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self scrollToNearestStrikePrice];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init View
-(void)initView{
    switchGoodsBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    switchGoodsBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [switchGoodsBtn addTarget:self action:@selector(switchGoodsBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchGoodsBtn];
    
    switchMonthBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    switchMonthBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [switchMonthBtn addTarget:self action:@selector(switchMonthBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchMonthBtn];
    
    strikeInputBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    strikeInputBtn.layer.borderWidth = 1.0f;
    strikeInputBtn.layer.cornerRadius = 5.0f;
    strikeInputBtn.layer.borderColor = [UIColor blackColor].CGColor;
    strikeInputBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [strikeInputBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    strikeInputBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [strikeInputBtn addTarget:self action:@selector(strikeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:strikeInputBtn];
    
    buySellBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    buySellBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [buySellBtn addTarget:self action:@selector(buySellBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [buySellBtn setTitle:@"買入" forState:UIControlStateNormal];
    [self.view addSubview:buySellBtn];
    
    bargainBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    bargainBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [bargainBtn addTarget:self action:@selector(bargainBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [bargainBtn setTitle:@"賣價" forState:UIControlStateNormal];
    [self.view addSubview:bargainBtn];
    
    callLabel = [[UILabel alloc] init];
    callLabel.translatesAutoresizingMaskIntoConstraints = NO;
    callLabel.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
    callLabel.font = [UIFont boldSystemFontOfSize:18];
    callLabel.textColor = [UIColor whiteColor];
    callLabel.textAlignment = NSTextAlignmentCenter;
    callLabel.text = @"CALL";
    [self.view addSubview:callLabel];
    
    strikeLabel = [[UILabel alloc] init];
    strikeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    strikeLabel.backgroundColor = [UIColor clearColor];
    strikeLabel.font = [UIFont boldSystemFontOfSize:18];
    strikeLabel.textColor = [UIColor brownColor];
    strikeLabel.textAlignment = NSTextAlignmentCenter;
    strikeLabel.text = @"---";
    [self.view addSubview:strikeLabel];
    
    putLabel = [[UILabel alloc] init];
    putLabel.translatesAutoresizingMaskIntoConstraints = NO;
    putLabel.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
    putLabel.font = [UIFont boldSystemFontOfSize:18];
    putLabel.textColor = [UIColor whiteColor];
    putLabel.textAlignment = NSTextAlignmentCenter;
    putLabel.text = @"PUT";
    [self.view addSubview:putLabel];
}

-(void)initTableView{
    _tableView = [[FSOptionTableView alloc] initWithleftColumnWidth:64 fixedColumnWidth:66 rightColumnWidth:64 AndColumnHeight:44];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    NSDictionary *viewController = NSDictionaryOfVariableBindings(switchGoodsBtn, switchMonthBtn, strikeInputBtn, buySellBtn, bargainBtn, callLabel, strikeLabel, putLabel, _tableView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[switchGoodsBtn]-2-[switchMonthBtn(switchGoodsBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[strikeInputBtn]-2-[buySellBtn(strikeInputBtn)]-2-[bargainBtn(strikeInputBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[callLabel]-2-[strikeLabel(60)][putLabel(callLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[switchGoodsBtn]-4-[strikeInputBtn(40)]-4-[callLabel(40)]-2-[_tableView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[switchGoodsBtn]-4-[strikeInputBtn(40)]-4-[putLabel(40)]" options:0 metrics:nil views:viewController]];
}

-(void)initLabelText{
    strikeLabel.text = [NSString stringWithFormat:@"%.f", dataModel.option.targetPrice];
    [strikeInputBtn setTitle:[NSString stringWithFormat:@"%.1f", dataModel.option.targetPrice] forState:UIControlStateNormal];
}

-(void)initBtnTitle{
    if ([optionData.goodsArray count] != 0) {
        [switchGoodsBtn setTitle:[NSString stringWithFormat:@"%@(%@)", [[optionData.goodsArray objectAtIndex:optionData.goodsNum] objectForKey:@"groupFullName"], [[optionData.goodsArray objectAtIndex:optionData.goodsNum] objectForKey:@"groupSymbol"]] forState:UIControlStateNormal];
        [switchMonthBtn setTitle:[[optionData.monthArray objectAtIndex:optionData.monthNum] objectForKey:@"month"] forState:UIControlStateNormal];
    }
}

#pragma mark - Button Action
-(void)strikeBtnAction:(id)sender{
    alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle =  UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
    [[alert textFieldAtIndex:0] becomeFirstResponder];
    [alert show];
}

-(void)switchGoodsBtnAction:(FSUIButton *)sender{
    goodsActionSheet = [[UIActionSheet alloc] initWithTitle:@"切換商品" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (int i = 0; i < [optionData.goodsArray count]; i++) {
        [goodsActionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@(%@)", [[optionData.goodsArray objectAtIndex:i] objectForKey:@"groupFullName"], [[optionData.goodsArray objectAtIndex:i] objectForKey:@"groupSymbol"]]];
    }
    [goodsActionSheet addButtonWithTitle:@"取消"];
    goodsActionSheet.cancelButtonIndex = goodsActionSheet.numberOfButtons -1;
    
    [self showActionSheet:goodsActionSheet];
}

-(void)switchMonthBtnAction:(FSUIButton *)sender{
    monthActionSheet = [[UIActionSheet alloc] initWithTitle:@"切換月份" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (int i = 0; i < [optionData.monthArray count]; i++) {
        [monthActionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@", [[optionData.monthArray objectAtIndex:i] objectForKey:@"month"]]];
    }
    [monthActionSheet addButtonWithTitle:@"取消"];
    monthActionSheet.cancelButtonIndex = monthActionSheet.numberOfButtons -1;
    [self showActionSheet:monthActionSheet];
}

-(void)buySellBtnAction:(FSUIButton *)sender{
    buySellActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"買入", @"賣出", nil];
    [self showActionSheet:buySellActionSheet];
}

-(void)bargainBtnAction:(FSUIButton *)sender{
    bargainActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"賣價", @"成交", nil];
    [self showActionSheet:bargainActionSheet];
}

#pragma mark - AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UITextField *alertTextField = [alert textFieldAtIndex:0];
        [strikeInputBtn setTitle:[NSString stringWithFormat:@"%@", alertTextField.text] forState:UIControlStateNormal];
        strikeInputBtn.titleLabel.text = alertTextField.text;
        [_tableView reloadDataNoOffset];
    }
}

#pragma mark - ActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    view = [[FSOptionMainViewController alloc] init];
    
    if ([actionSheet isEqual:goodsActionSheet]) {
        if (buttonIndex == goodsActionSheet.cancelButtonIndex) {
            return;
        }
        optionData.goodsNum = buttonIndex;
        optionData.monthNum = 0;
        [switchGoodsBtn setTitle:[NSString stringWithFormat:@"%@(%@)", [[optionData.goodsArray objectAtIndex:buttonIndex] objectForKey:@"groupFullName"], [[optionData.goodsArray objectAtIndex:buttonIndex] objectForKey:@"groupSymbol"]] forState:UIControlStateNormal];
        [switchMonthBtn setTitle:[NSString stringWithFormat:@"%@", [[optionData.monthArray objectAtIndex:optionData.monthNum] objectForKey:@"month"]] forState:UIControlStateNormal];
        [view sendOptionDataWithGoodsNum:optionData.goodsNum MonthNum:optionData.monthNum];
        
    }else if ([actionSheet isEqual:monthActionSheet]){
        if (buttonIndex == monthActionSheet.cancelButtonIndex) {
            return;
        }
        optionData.monthNum = buttonIndex;
        [switchMonthBtn setTitle:[NSString stringWithFormat:@"%@", [[optionData.monthArray objectAtIndex:optionData.monthNum] objectForKey:@"month"]] forState:UIControlStateNormal];
        [view sendOptionDataWithGoodsNum:optionData.goodsNum MonthNum:optionData.monthNum];
        
    }else if ([actionSheet isEqual:buySellActionSheet]){
        if (buttonIndex == 0) {
            buySellFlag = NO;
            [buySellBtn setTitle:@"買入" forState:UIControlStateNormal];
        }else if (buttonIndex == 1){
            buySellFlag = YES;
            [buySellBtn setTitle:@"賣出" forState:UIControlStateNormal];
        }
        [_tableView reloadDataNoOffset];
    }else if ([actionSheet isEqual:bargainActionSheet]){
        if (buttonIndex == 0) {
            bargainFlag = NO;
            [bargainBtn setTitle:@"賣價" forState:UIControlStateNormal];
        }else if (buttonIndex == 1){
            bargainFlag = YES;
            [bargainBtn setTitle:@"成交" forState:UIControlStateNormal];
        }
        [_tableView reloadDataNoOffset];
    }
}

#pragma mark - TableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [dataModel.option getRowCount];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OptionCallPut *option = [dataModel.option getNewRowData:(int)indexPath.row];
    label.font = [UIFont boldSystemFontOfSize:18.0f];
    label.textColor = [UIColor brownColor];
    label.text = [NSString stringWithFormat:@"%.f", option->strikePrice];
}

-(void)updateLeftTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OptionCallPut *option = [dataModel.option getNewRowData:(int)indexPath.row];
    label.adjustsFontSizeToFitWidth = YES;
    if (columnIndex == 0) {
        //損平
        if (isnan([self calcCallProfitNLoss:option])) {
            label.textColor = [UIColor blackColor];
            label.text = @"---";
        }else{
            label.textColor = [UIColor blueColor];
            label.text = [NSString stringWithFormat:@"%.f", [self calcCallProfitNLoss:option]];
        }
    }else if (columnIndex == 1){
        //報酬%
        if (isnan([self calcCallReward:option])) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            if ([self calcCallReward:option] > 0) {
                label.text = [NSString stringWithFormat:@"+%.1f", [self calcCallReward:option]];
                label.textColor = [StockConstant PriceUpColor];
            }else{
                label.text = [NSString stringWithFormat:@"%.1f", [self calcCallReward:option]];
                label.textColor = [StockConstant PriceDownColor];
            }
        }
    }
}

-(void)updateRightTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OptionCallPut *option = [dataModel.option getNewRowData:(int)indexPath.row];
    label.adjustsFontSizeToFitWidth = YES;
    if (columnIndex == 0) {
        //損平
        if (isnan([self calcPutProfitNLoss:option])) {
            label.textColor = [UIColor blackColor];
            label.text = @"---";
        }else{
            label.textColor = [UIColor blueColor];
            label.text = [NSString stringWithFormat:@"%.f", [self calcPutProfitNLoss:option]];
        }
    }else if (columnIndex == 1){
        //報酬%
        if (isnan([self calcPutReward:option])) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            if ([self calcPutReward:option] > 0) {
                label.text = [NSString stringWithFormat:@"+%.1f", [self calcPutReward:option]];
                label.textColor = [StockConstant PriceUpColor];
            }else{
                label.text = [NSString stringWithFormat:@"%.1f", [self calcPutReward:option]];
                label.textColor = [StockConstant PriceDownColor];
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectLeftRowAtIndexPath:(NSIndexPath *)indexPath{
    OptionCallPut *option = [dataModel.option getNewRowData:(int)indexPath.row];
    callPutFlag = NO;
    [self optionInfoAlertView];
    [view2 showLabelInfoWithStrikePrice:option->strikePrice callOrPut:callPutFlag];
}

-(void)tableView:(UITableView *)tableView didSelectRightRowAtIndexPath:(NSIndexPath *)indexPath{
    OptionCallPut *option = [dataModel.option getNewRowData:(int)indexPath.row];
    callPutFlag = YES;
    [self optionInfoAlertView];
    [view2 showLabelInfoWithStrikePrice:option->strikePrice callOrPut:callPutFlag];
}

#pragma mark - calculate the profit & loss and rewards
- (double) calcCallProfitNLoss:(OptionCallPut *) optionDatas
{
	double profit;
	double strikePrice = optionDatas->strikePrice;
	double buy = optionDatas->call->bid;
	double sell = optionDatas->call->ask;
	double deal = optionDatas->call->currentPrice;
	
	// to determine that what pairs is
	// segment layout : ("buy", "sell")   ("sell/buy price", "deal")
	if (buySellFlag == NO && bargainFlag == NO) // buy & sell price
	{
		profit = strikePrice + sell;
	}else if (buySellFlag == YES && bargainFlag == NO) // sell & buy price
	{
		profit = strikePrice + buy;
	}else // buy/sell & deal
	{
		profit = strikePrice + deal;
	}
	
	return profit;
}


- (double) calcPutProfitNLoss:(OptionCallPut *) optionDatas
{
	double profit;
	double strikePrice = optionDatas->strikePrice;
	double buy = optionDatas->put->bid;
	double sell = optionDatas->put->ask;
	double deal = optionDatas->put->currentPrice;
	
	// to determine that what pairs is
	// segment layout : ("buy", "sell")   ("sell/buy price", "deal")
    if (buySellFlag == NO && bargainFlag == NO) // buy & sell price
    {
        profit = strikePrice - sell;
    }
    else if (buySellFlag == YES && bargainFlag == NO) // sell & buy price
    {
        profit = strikePrice - buy;
    }
    else // buy/sell & deal
    {
        profit = strikePrice - deal;
    }
    
	return profit;
}

- (double) calcCallReward:(OptionCallPut *)optionDatas
{
	double reward;
	double strikePrice = optionDatas->strikePrice;
	double buy = optionDatas->call->bid;
	double sell = optionDatas->call->ask;
	double deal = optionDatas->call->currentPrice;
	double targetPrice = [strikeInputBtn.titleLabel.text doubleValue];
	
	
    //	NSLog(@"targetPrice:%.1f",targetPrice);
	
	// to determine that what pairs is
	// segment layout : ("buy", "sell")   ("sell/buy price", "deal")
	if (buySellFlag == NO && bargainFlag == NO) // buy & sell price
	{
		reward = ((targetPrice - (strikePrice + sell)) / sell) * 100;
	}else if (buySellFlag == YES && bargainFlag == NO) // sell & buy price
	{
		reward = (((strikePrice + buy) - targetPrice) / buy) * 100;
	}else if (buySellFlag == NO && bargainFlag == YES) // buy & deal
	{
		reward = ((targetPrice - (strikePrice + deal)) / deal) * 100;
	}else // sell & deal
	{
		reward = (((strikePrice + deal) - targetPrice) / deal) * 100;
	}
    
    if (buySellFlag == YES && reward > 100)
        reward = 100;
    else if (buySellFlag == NO && reward < -100)
        reward = -100;
    
	return reward;
}


- (double) calcPutReward:(OptionCallPut *)optionDatas
{
	double reward;
	double strikePrice = optionDatas->strikePrice;
	double buy = optionDatas->put->bid;
	double sell = optionDatas->put->ask;
	double deal = optionDatas->put->currentPrice;
	double targetPrice = [strikeInputBtn.titleLabel.text doubleValue];
	
	// to determine that what pairs is
	// segment layout : ("buy", "sell")   ("sell/buy price", "deal")
    if (buySellFlag == NO && bargainFlag == NO) // buy & sell price
    {
        reward = (((strikePrice - sell) - targetPrice) / sell) * 100;
    }
    else if (buySellFlag == YES && bargainFlag == NO) // sell & buy price
    {
        reward = ((targetPrice - (strikePrice - buy)) / buy) * 100;
    }
    else if (buySellFlag == NO && bargainFlag == YES) // buy & deal
    {
        reward = (((strikePrice - deal) - targetPrice) / deal) * 100;
    }
    else // sell & deal
    {
        reward = ((targetPrice - (strikePrice - deal)) / deal) * 100;
    }
    
    if (buySellFlag == YES && reward > 100)
        reward = 100;
    else if (buySellFlag == NO && reward < -100)
        reward = -100;
    
	return reward;
}

-(void)optionInfoAlertView{
    CustomIOS7AlertView *custAlert = [[CustomIOS7AlertView alloc] init];
    view2 = [[FSOptionInfoViewController alloc] init];
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 305)];
    [infoView setBackgroundColor:[UIColor blackColor]];
    [infoView addSubview:view2.view];
    [custAlert setContainerView:infoView];
    [custAlert show];
}

#pragma mark - TableView Title
-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"履約價", @"", nil)];
}

-(NSArray *)columnsInLeftTableView{
    return @[NSLocalizedStringFromTable(@"損平", @"", nil), NSLocalizedStringFromTable(@"報酬%", @"", nil)];
}

-(NSArray *)columnsInRightTableView{
    return @[NSLocalizedStringFromTable(@"損平", @"", nil), NSLocalizedStringFromTable(@"報酬%", @"", nil)];
}

#pragma mark - Scroll
-(void)scrollToNearestStrikePrice{
    double *strikePrice = [dataModel.option getNearestStrikePrice];
    int rowCount = [dataModel.option getRowCount];
    int rowNum = 0;
    for (int i = 0; i < rowCount; i++) {
        OptionCallPut *option = [dataModel.option getNewRowData:i];
        if (option->strikePrice == *strikePrice) {
            rowNum = i;
            break;
        }
    }
    if (rowNum > 0) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:rowNum inSection:0];
        [_tableView scrollToRowAtIndexPath:newIndexPath];
        
    }
}

@end
