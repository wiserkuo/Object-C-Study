//
//  FSOptionViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/9/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSOptionViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSOptionTableView.h"
#import "FSOptionMainViewController.h"
#import "FSOptionInfoViewController.h"
#import "CustomIOS7AlertView.h"

@interface FSOptionViewController () <UIActionSheetDelegate>{
    NSUInteger goodsNum;
    NSUInteger monthNum;
    BOOL callPutFlag;
    
    FSUIButton *switchGoodsBtn;
    FSUIButton *switchMonthBtn;
    FSUIButton *quoteBtn;
    FSUIButton *trialBtn;
    FSUIButton *strategyBtn;
    UILabel *pcTotalTitleLable;
    UILabel *pcTotalLabel;
    UILabel *pcRatioTitleLabel;
    UILabel *pcRatioLabel;
    UILabel *callLabel;
    UILabel *strikeLabel;
    UILabel *putLabel;
    UIActionSheet *goodsActionSheet;
    UIActionSheet *monthActionSheet;
    FSDataModelProc *dataModel;
    FSOptionMainViewController *view;
    FSOptionInfoViewController *view2;
    Option *optionData;
    
    NSMutableArray *layoutContraints;

}

@end

@implementation FSOptionViewController

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
    layoutContraints = [[NSMutableArray alloc] init];
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

#pragma mark - init view
-(void)initLabelText{
    strikeLabel.text = [NSString stringWithFormat:@"%.f", dataModel.option.targetPrice];
    if (isnan([dataModel.option getPCVol])) {
        pcTotalLabel.textColor = [UIColor blackColor];
        pcTotalLabel.text = @"---";
    }else{
        if ([dataModel.option getPCVol] > 1) {
            pcTotalLabel.textColor = [StockConstant PriceDownColor];
        }else{
            pcTotalLabel.textColor = [StockConstant PriceUpColor];
        }
        pcTotalLabel.text = [NSString stringWithFormat:@"%.2f", [dataModel.option getPCVol]];
    }
    if (isnan([dataModel.option getPCPreIntest])) {
        pcRatioLabel.textColor = [UIColor blackColor];
        pcRatioLabel.text = @"---";
    }else{
        if ([dataModel.option getPCPreIntest] > 1) {
            pcRatioLabel.textColor = [StockConstant PriceDownColor];
        }else{
            pcRatioLabel.textColor = [StockConstant PriceUpColor];
        }
        pcRatioLabel.text = [NSString stringWithFormat:@"%.2f", [dataModel.option getPCPreIntest]];
    }
}

-(void)initBtnTitle{
    if ([optionData.goodsArray count] != 0) {
        [switchGoodsBtn setTitle:[NSString stringWithFormat:@"%@(%@)", [[optionData.goodsArray objectAtIndex:optionData.goodsNum] objectForKey:@"groupFullName"], [[optionData.goodsArray objectAtIndex:optionData.goodsNum] objectForKey:@"groupSymbol"]] forState:UIControlStateNormal];
        [switchMonthBtn setTitle:[[optionData.monthArray objectAtIndex:optionData.monthNum] objectForKey:@"month"] forState:UIControlStateNormal];
    }
}

-(void)initView{
    switchGoodsBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    switchGoodsBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [switchGoodsBtn addTarget:self action:@selector(switchGoodsBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchGoodsBtn];
    
    switchMonthBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    switchMonthBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [switchMonthBtn addTarget:self action:@selector(switchMonthBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchMonthBtn];
    
    //P/C總量
    pcTotalTitleLable = [[UILabel alloc] init];
    pcTotalTitleLable.translatesAutoresizingMaskIntoConstraints = NO;
    pcTotalTitleLable.backgroundColor = [UIColor clearColor];
    pcTotalTitleLable.font = [UIFont systemFontOfSize:18];
    pcTotalTitleLable.text = @"P/C總量:";
    [self.view addSubview:pcTotalTitleLable];
    
    pcTotalLabel = [[UILabel alloc] init];
    pcTotalLabel.translatesAutoresizingMaskIntoConstraints = NO;
    pcTotalLabel.backgroundColor = [UIColor clearColor];
    pcTotalLabel.font = [UIFont systemFontOfSize:18];
    pcTotalLabel.text = @"0.00";
    [self.view addSubview:pcTotalLabel];
    
    //P/C昨倉
    pcRatioTitleLabel = [[UILabel alloc] init];
    pcRatioTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    pcRatioTitleLabel.backgroundColor = [UIColor clearColor];
    pcRatioTitleLabel.font = [UIFont systemFontOfSize:18];
    pcRatioTitleLabel.text = @"P/C昨倉:";
    [self.view addSubview:pcRatioTitleLabel];
    
    pcRatioLabel = [[UILabel alloc] init];
    pcRatioLabel.translatesAutoresizingMaskIntoConstraints = NO;
    pcRatioLabel.backgroundColor = [UIColor clearColor];
    pcRatioLabel.font = [UIFont systemFontOfSize:18];
    pcRatioLabel.text = @"0.00";
    [self.view addSubview:pcRatioLabel];
    
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
    _tableView = [[FSOptionTableView alloc] initWithleftColumnWidth:66 fixedColumnWidth:66 rightColumnWidth:66 AndColumnHeight:44];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    [self.view removeConstraints:layoutContraints];
    [layoutContraints removeAllObjects];
    
    NSDictionary *viewController = NSDictionaryOfVariableBindings(switchGoodsBtn, switchMonthBtn, pcTotalTitleLable, pcTotalLabel, pcRatioTitleLabel, pcRatioLabel, callLabel, strikeLabel, putLabel, _tableView);
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[switchGoodsBtn]-2-[switchMonthBtn(switchGoodsBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[pcTotalTitleLable(80)][pcTotalLabel]-20-[pcRatioTitleLabel(pcTotalTitleLable)][pcRatioLabel(pcTotalLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[callLabel]-2-[strikeLabel(60)][putLabel(callLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[switchGoodsBtn][pcTotalTitleLable(44)][callLabel(40)]-2-[_tableView]|" options:0 metrics:nil views:viewController]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[switchGoodsBtn][pcTotalTitleLable(44)][callLabel(40)]-2-[_tableView]|" options:0 metrics:nil views:viewController]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[switchGoodsBtn][pcTotalTitleLable(44)][putLabel(40)]-2-[_tableView]|" options:0 metrics:nil views:viewController]];

    [self.view addConstraints:layoutContraints];
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[switchGoodsBtn]-2-[switchMonthBtn(switchGoodsBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[pcTotalTitleLable(80)][pcTotalLabel]-20-[pcRatioTitleLabel(pcTotalTitleLable)][pcRatioLabel(pcTotalLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[callLabel]-2-[strikeLabel(60)][putLabel(callLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:viewController]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[switchGoodsBtn][pcTotalTitleLable(44)][callLabel(40)]-2-[_tableView]|" options:0 metrics:nil views:viewController]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[switchGoodsBtn][pcTotalTitleLable(44)][putLabel(40)]" options:0 metrics:nil views:viewController]];
}

#pragma mark - Button Action
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
    }
}

#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [dataModel.option getRowCount];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    label.textColor = [UIColor brownColor];
    label.font = [UIFont boldSystemFontOfSize:18.0f];
    OptionCallPut *option = [dataModel.option getNewRowData:(int)indexPath.row];
    label.text = [NSString stringWithFormat:@"%.f", option->strikePrice];
}

-(void)updateLeftTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OptionCallPut *option = [dataModel.option getNewRowData:(int)indexPath.row];
    double putChgNum;
    putChgNum = option->call->currentPrice - option->call->referencePrice;
    [label setAdjustsFontSizeToFitWidth:YES];
    
    if (columnIndex == 0) { //買價
        if (isnan(option->call->bid)) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [[NSNumber numberWithFloat:option->call->bid] stringValue];
            if (option->call->bid > option->call->referencePrice) {
                label.textColor = [StockConstant PriceUpColor];
            }else if (option->call->bid < option->call->referencePrice){
                label.textColor = [StockConstant PriceDownColor];
            }else{
                label.textColor = [UIColor blueColor];
            }
        }
    }else if (columnIndex == 1){ //賣價
        if (isnan(option->call->ask)) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [[NSNumber numberWithFloat:option->call->ask] stringValue];
            if (option->call->ask > option->call->referencePrice) {
                label.textColor = [StockConstant PriceUpColor];
            }else if (option->call->ask < option->call->referencePrice){
                label.textColor = [StockConstant PriceDownColor];
            }else{
                label.textColor = [UIColor blueColor];
            }
        }
    }else if (columnIndex == 2){ //成交
        if (isnan(option->call->currentPrice)) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [[NSNumber numberWithFloat:option->call->currentPrice] stringValue];
            if (putChgNum > 0) {
                label.textColor = [StockConstant PriceUpColor];
            }else if (putChgNum < 0){
                label.textColor = [StockConstant PriceDownColor];
            }else{
                label.textColor = [UIColor blueColor];
            }
        }
    }else if (columnIndex == 3){ //總量
        if (option->call->volume == 0) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [[NSNumber numberWithFloat:option->call->volume] stringValue];
            label.textColor = [UIColor blueColor];
        }
    }else if (columnIndex == 4){ //漲跌
        if (isnan(putChgNum)) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            if (putChgNum > 0) {
                label.text = [NSString stringWithFormat:@"+%@", [[NSNumber numberWithFloat:putChgNum] stringValue]];
                label.textColor = [StockConstant PriceUpColor];
            }else if (putChgNum < 0){
                label.text = [NSString stringWithFormat:@"%@", [[NSNumber numberWithFloat:putChgNum] stringValue]];
                label.textColor = [StockConstant PriceDownColor];
            }else{
                label.text = [NSString stringWithFormat:@"%@", [[NSNumber numberWithFloat:putChgNum] stringValue]];
                label.textColor = [UIColor blueColor];
            }
        }
    }else if (columnIndex == 5){ //漲幅
        if (isnan(putChgNum/option->call->referencePrice)) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            if (putChgNum > 0) {
                label.text = [NSString stringWithFormat:@"+%.1f%%", (putChgNum/option->call->referencePrice)*100];
                label.textColor = [StockConstant PriceUpColor];
            }else if (putChgNum < 0){
                label.text = [NSString stringWithFormat:@"%.1f%%", (putChgNum/option->call->referencePrice)*100];
                label.textColor = [StockConstant PriceDownColor];
            }else{
                label.text = [NSString stringWithFormat:@"%.1f%%", (putChgNum/option->call->referencePrice)*100];
                label.textColor = [UIColor blueColor];
            }
        }
    }
}

-(void)updateRightTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OptionCallPut *option = [dataModel.option getNewRowData:(int)indexPath.row];
    double putChgNum;
    putChgNum = option->put->currentPrice - option->put->referencePrice;
    [label setAdjustsFontSizeToFitWidth:YES];
    
    if (columnIndex == 0) {
        if (isnan(option->put->bid)) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [[NSNumber numberWithFloat:option->put->bid] stringValue];
            if (option->put->bid > option->put->referencePrice) {
                label.textColor = [StockConstant PriceUpColor];
            }else if (option->put->bid < option->put->referencePrice){
                label.textColor = [StockConstant PriceDownColor];
            }else{
                label.textColor = [UIColor blueColor];
            }
        }
    }else if (columnIndex  == 1){
        if (isnan(option->put->ask)) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [[NSNumber numberWithFloat:option->put->ask] stringValue];
            if (option->put->ask > option->put->referencePrice) {
                label.textColor = [StockConstant PriceUpColor];
            }else if (option->put->ask < option->put->referencePrice){
                label.textColor = [StockConstant PriceDownColor];
            }else{
                label.textColor = [UIColor blueColor];
            }
        }
    }else if (columnIndex == 2){
        if (isnan(option->put->currentPrice)) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [[NSNumber numberWithFloat:option->put->currentPrice] stringValue];
            if (putChgNum > 0) {
                label.textColor = [StockConstant PriceUpColor];
            }else if (putChgNum < 0){
                label.textColor = [StockConstant PriceDownColor];
            }else{
                label.textColor = [UIColor blueColor];
            }
        }
    }else if (columnIndex == 3){
        if (option->put->volume == 0) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [[NSNumber numberWithFloat:option->put->volume] stringValue];
            label.textColor = [UIColor blueColor];
        }
    }else if (columnIndex == 4){
        if (isnan(putChgNum)) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            if (putChgNum > 0) {
                label.text = [NSString stringWithFormat:@"+%@", [[NSNumber numberWithFloat:putChgNum] stringValue]];
                label.textColor = [StockConstant PriceUpColor];
            }else if (putChgNum < 0){
                label.text = [NSString stringWithFormat:@"%@", [[NSNumber numberWithFloat:putChgNum] stringValue]];
                label.textColor = [StockConstant PriceDownColor];
            }else{
                label.text = [NSString stringWithFormat:@"%@", [[NSNumber numberWithFloat:putChgNum] stringValue]];
                label.textColor = [UIColor blueColor];
            }
        }
    }else if (columnIndex == 5){
        if (isnan(putChgNum/option->put->referencePrice)) {
            label.text = @"---";
            label.textColor = [UIColor blackColor];
        }else{
            if (putChgNum > 0) {
                label.text = [NSString stringWithFormat:@"+%.1f%%", (putChgNum/option->put->referencePrice)*100];
                label.textColor = [StockConstant PriceUpColor];
            }else if (putChgNum < 0){
                label.text = [NSString stringWithFormat:@"%.1f%%", (putChgNum/option->put->referencePrice)*100];
                label.textColor = [StockConstant PriceDownColor];
            }else{
                label.text = [NSString stringWithFormat:@"%.1f%%", (putChgNum/option->put->referencePrice)*100];
                label.textColor = [UIColor blueColor];
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

#pragma mark - TableView Title
-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"履約價", @"", nil)];
}

-(NSArray *)columnsInLeftTableView{
    return @[NSLocalizedStringFromTable(@"買價", @"", nil), NSLocalizedStringFromTable(@"賣價", @"", nil), NSLocalizedStringFromTable(@"成交", @"", nil), NSLocalizedStringFromTable(@"總量", @"", nil), NSLocalizedStringFromTable(@"漲跌", @"", nil), NSLocalizedStringFromTable(@"漲幅", @"", nil)];
}

-(NSArray *)columnsInRightTableView{
    return @[NSLocalizedStringFromTable(@"買價", @"", nil), NSLocalizedStringFromTable(@"賣價", @"", nil), NSLocalizedStringFromTable(@"成交", @"", nil), NSLocalizedStringFromTable(@"總量", @"", nil), NSLocalizedStringFromTable(@"漲跌", @"", nil), NSLocalizedStringFromTable(@"漲幅", @"", nil)];
}

#pragma mark - 最佳五欓
-(void)optionInfoAlertView{
    CustomIOS7AlertView *custAlert = [[CustomIOS7AlertView alloc] init];
    view2 = [[FSOptionInfoViewController alloc] init];
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 305)];
    [infoView setBackgroundColor:[UIColor blackColor]];
    [infoView addSubview:view2.view];
    [custAlert setContainerView:infoView];
    [custAlert show];
}

#pragma mark - scroll
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
