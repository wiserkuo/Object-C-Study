//
//  FSOptionStrategyViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/10/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSOptionStrategyViewController.h"
#import "FSOptionStrategyCell.h"
#import "FSOptionMainViewController.h"
#import "FSOptionChartView.h"

@interface FSOptionStrategyViewController () <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>{
    FSUIButton *switchGoodsBtn;
    FSUIButton *switchMonthBtn;
    FSUIButton *switchStrategyBtn;
    UIActionSheet *goodsActionSheet;
    UIActionSheet *monthActionSheet;
    UIActionSheet *strategyActionSheet;
    UIActionSheet *strikeActionSheet;
    UIView *contentView;
    UIScrollView *scrollView;
    UILabel *maxProfitTitleLabel;
    UILabel *maxProfitLabel;
    UILabel *breakEvenTitleLabel;
    UILabel *breakEvenLabel;
    UILabel *maxLossTitleLabel;
    UILabel *maxLossLabel;
    
    NSArray *titleArray;
    FSDataModelProc *dataModel;
    Option *optionData;
    FSOptionMainViewController *view;
    FSOptionChartView *optionChartView;
    
    double strike1;
    double strike2;
    NSString *powerStr1;
    NSString *powerStr2;
    NSString *priceStr1;
    NSString *priceStr2;
    NSString *maxProfitStr;
    NSString *breakEvenStr;
    NSString *maxLossStr;
    BOOL strikeFlag;
    double btnTag;
}

@end

@implementation FSOptionStrategyViewController

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
    titleArray = [[NSArray alloc] initWithObjects:@"看大漲", @"看大跌", @"看不漲", @"看不跌", @"看變盤", @"看盤整", @"看小漲", @"小漲作莊", @"看小跌", @"小跌作莊", nil];
    strikeFlag = YES;
    [self initView];
    [self initBtnTitle];
    [self initData];
    [self.view setNeedsUpdateConstraints];
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
    
    switchStrategyBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    switchStrategyBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [switchStrategyBtn addTarget:self action:@selector(switchStrategyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchStrategyBtn];
    
    _mainTableView = [[UITableView alloc] init];
    _mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.bounces = NO;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:_mainTableView];
    
    optionChartView = [[FSOptionChartView alloc] init];
    optionChartView.backgroundColor = [UIColor whiteColor];
    optionChartView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:optionChartView];
    
    contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.bounces = NO;
    scrollView.contentSize = CGSizeMake(contentView.frame.size.width, contentView.frame.size.height);
    [scrollView addSubview:contentView];
    [self.view addSubview:scrollView];
    
    maxProfitTitleLabel = [[UILabel alloc] init];
    maxProfitTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    maxProfitTitleLabel.textColor = [UIColor brownColor];
    maxProfitTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [maxProfitTitleLabel setNumberOfLines:0];
    maxProfitTitleLabel.text = @"1.最大獲利:\n ";
    [contentView addSubview:maxProfitTitleLabel];
    
    maxProfitLabel = [[UILabel alloc] init];
    maxProfitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    maxProfitLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [maxProfitLabel setNumberOfLines:0];
    [contentView addSubview:maxProfitLabel];
    
    breakEvenTitleLabel = [[UILabel alloc] init];
    breakEvenTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    breakEvenTitleLabel.textColor = [UIColor brownColor];
    breakEvenTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [breakEvenTitleLabel setNumberOfLines:0];
    breakEvenTitleLabel.text = @"2.損益平衡點:\n ";
    [contentView addSubview:breakEvenTitleLabel];
    
    breakEvenLabel = [[UILabel alloc] init];
    breakEvenLabel.translatesAutoresizingMaskIntoConstraints = NO;
    breakEvenLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [breakEvenLabel setNumberOfLines:0];
    [contentView addSubview:breakEvenLabel];
    
    maxLossTitleLabel = [[UILabel alloc] init];
    maxLossTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    maxLossTitleLabel.textColor = [UIColor brownColor];
    maxLossTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [maxLossTitleLabel setNumberOfLines:0];
    maxLossTitleLabel.text = @"3.最大損失:\n ";
    [contentView addSubview:maxLossTitleLabel];
    
    maxLossLabel = [[UILabel alloc] init];
    maxLossLabel.translatesAutoresizingMaskIntoConstraints = NO;
    maxLossLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [maxLossLabel setNumberOfLines:0];
    [contentView addSubview:maxLossLabel];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    NSDictionary *viewController = NSDictionaryOfVariableBindings(switchGoodsBtn, switchMonthBtn, switchStrategyBtn, _mainTableView, optionChartView, maxProfitTitleLabel, maxProfitLabel, breakEvenTitleLabel, breakEvenLabel, maxLossTitleLabel, maxLossLabel, scrollView, contentView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[switchStrategyBtn]-2-[switchGoodsBtn(switchStrategyBtn)]-2-[switchMonthBtn(switchStrategyBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[optionChartView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[switchStrategyBtn][_mainTableView(132)][optionChartView(180)][scrollView]|" options:0 metrics:nil views:viewController]];
    
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[maxProfitTitleLabel][maxProfitLabel(220)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[breakEvenTitleLabel][breakEvenLabel(200)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[maxLossTitleLabel][maxLossLabel(220)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[maxProfitTitleLabel]-[breakEvenTitleLabel]-[maxLossTitleLabel]|" options:0 metrics:nil views:viewController]];
}

#pragma mark - init Data
-(void)initData{
    if (strikeFlag) {
        double *strikePrice = [dataModel.option getNearestStrikePrice];
        strike1 = strikePrice[1];
        if((_cellNum > 3 && _cellNum < 6) || _cellNum > 7)
            strike2 = strikePrice[0];
        else strike2 = strikePrice[2];
    }
    optionChartView.chartViewType = _cellNum;
    OptionCallPut *option = [dataModel.option getDataByStrikePrice:strike1];
    OptionCallPut *option2 = [dataModel.option getDataByStrikePrice:strike2];
    if (_cellNum == 0) { //看大漲
        powerStr1 = @"買 CALL";
        if (option){
            priceStr1 = [NSString stringWithFormat:@"%.1f", option->call->currentPrice];
            if (isnan(option->call->currentPrice)) {
                maxProfitStr = @"結算價 --- 點以上無限獲利空間.";
            }else {
                maxProfitStr = [NSString stringWithFormat:@"結算價 %.f 點以上無限獲利空間.", strike1 + option->call->currentPrice];
            }
            if (isnan(option->call->currentPrice)) {
                breakEvenStr = @"--- 點\n ";
            }else{
                breakEvenStr = [NSString stringWithFormat:@"%.f 點\n ", strike1 + option->call->currentPrice];
            }
            if (isnan(option->call->currentPrice)) {
                maxLossStr = @"權利金 --- 元\n ";
            }else{
                maxLossStr = [NSString stringWithFormat:@"權利金 %.f 元\n ", option->call->currentPrice*50];
            }
            optionChartView.pointA = [NSString stringWithFormat:@"%.f", strike1];
            optionChartView.pointB = [NSString stringWithFormat:@"%.f", strike1+option->call->currentPrice];
        }
    }else if (_cellNum == 1){ //看大跌
        powerStr1 = @"買 PUT";
        if (option){
            priceStr1 = [NSString stringWithFormat:@"%.1f", option->put->currentPrice];
            if (isnan(option->put->currentPrice)) {
                maxProfitStr = @"結算價 --- 點以下無限獲利空間.";
            }else {
                maxProfitStr = [NSString stringWithFormat:@"結算價 %.f 點以下無限獲利空間.", strike1 - option->put->currentPrice];
            }
            if (isnan(option->put->currentPrice)) {
                breakEvenStr = @"---點 \n ";
            }else{
                breakEvenStr = [NSString stringWithFormat:@"%.f 點\n ", strike1 - option->put->currentPrice];
            }
            if (isnan(option->put->currentPrice)) {
                maxLossStr = @"權利金 --- 元 \n ";
            }else{
                maxLossStr = [NSString stringWithFormat:@"權利金 %.f 元\n ", option->put->currentPrice*50];
            }
            optionChartView.pointA = [NSString stringWithFormat:@"%.f", strike1-option->put->currentPrice];
            optionChartView.pointB = [NSString stringWithFormat:@"%.f", strike1];
            
        }
    }else if (_cellNum == 2){ //看不漲
        powerStr1 = @"賣 CALL";
        if (option){
            priceStr1 = [NSString stringWithFormat:@"%.1f", option->call->bid];
            if (isnan(option->call->bid)) {
                maxProfitStr = @"權利金 --- 元\n ";
            }else {
                maxProfitStr = [NSString stringWithFormat:@"權利金 %.f 元\n ", option->call->bid*50];
            }
            if (isnan(option->call->bid)) {
                breakEvenStr = @"--- 點\n ";
            }else{
                breakEvenStr = [NSString stringWithFormat:@"%.f 點\n ", strike1 + option->call->bid];
            }
            if (isnan(option->call->bid)) {
                maxLossStr = @"結算價 --- 點以上無限損失空間.";
            }else{
                maxLossStr = [NSString stringWithFormat:@"結算價 %.f 點以上無限損失空間.", strike1 + option->call->bid];
            }
            optionChartView.pointA = [NSString stringWithFormat:@"%.f", strike1];
            optionChartView.pointB = [NSString stringWithFormat:@"%.f", strike1+option->call->bid];
            
        }
    }else if (_cellNum == 3){ //看不跌
        powerStr1 = @"賣 PUT";
        if (option){
            priceStr1 = [NSString stringWithFormat:@"%.1f", option->put->bid];
            if (isnan(option->put->bid)) {
                maxProfitStr = @"權利金 --- 元\n ";
            }else {
                maxProfitStr = [NSString stringWithFormat:@"權利金 %.f 元\n ", option->put->bid*50];
            }
            if (isnan(option->put->bid)) {
                breakEvenStr = @"--- 點\n ";
            }else{
                breakEvenStr = [NSString stringWithFormat:@"%.f 點\n ", strike1 - option->put->bid];
            }
            if (isnan(option->put->bid)) {
                maxLossStr = @"結算價 --- 點以下無限損失空間.";
            }else{
                maxLossStr = [NSString stringWithFormat:@"結算價 %.f 點以下無限損失空間.", strike1 - option->put->bid];
            }
            optionChartView.pointA = [NSString stringWithFormat:@"%.f", strike1-option->put->bid];
            optionChartView.pointB = [NSString stringWithFormat:@"%.f", strike1];
            
        }
    }else if (_cellNum == 4){ //看變盤
        powerStr1 = @"買 CALL";
        powerStr2 = @"買 PUT";
        if (option) priceStr1 = [NSString stringWithFormat:@"%.1f", option->call->currentPrice];
        if (option2) priceStr2 = [NSString stringWithFormat:@"%.1f", option2->put->currentPrice];
        if (option && option2) {
            if (isnan(option->call->currentPrice) && isnan(option2->put->currentPrice)) {
                maxProfitStr = @"結算價 --- 點以上或 --- 點以下無限獲利空間.";
            }else {
                maxProfitStr = [NSString stringWithFormat:@"結算價 %.f 點以上或 %.f 點以下無限獲利空間.", strike1 + option->call->currentPrice + option2->put->currentPrice, strike2 - option->call->currentPrice - option2->put->currentPrice];
            }
            if (isnan(option->call->currentPrice) && isnan(option2->put->currentPrice)) {
                breakEvenStr = @"上漲為 --- 點, 下跌為 --- 點";
            }else{
                breakEvenStr = [NSString stringWithFormat:@"上漲為 %.f 點, 下跌為 %.f 點", strike1 + option->call->currentPrice + option2->put->currentPrice, strike2 - option->call->currentPrice - option2->put->currentPrice];
            }
            if (isnan(option->call->currentPrice) && isnan(option2->put->currentPrice)) {
                maxLossStr = @"權利金 --- 元\n ";
            }else{
                maxLossStr = [NSString stringWithFormat:@"權利金 %.f 元\n ", (option->call->currentPrice + option2->put->currentPrice) *50];
            }
            optionChartView.pointA = [NSString stringWithFormat:@"%.f", strike2 - option->call->currentPrice - option2->put->currentPrice];
            optionChartView.pointB = [NSString stringWithFormat:@"%.f", strike2];
            optionChartView.pointC = [NSString stringWithFormat:@"%.f", strike1];
            optionChartView.pointD = [NSString stringWithFormat:@"%.f", strike1 + option->call->currentPrice + option2->put->currentPrice];
        }
    }else if (_cellNum == 5){ //看盤整
        powerStr1 = @"賣 CALL";
        powerStr2 = @"賣 PUT";
        if (option) priceStr1 = [NSString stringWithFormat:@"%.1f", option->call->bid];
        if (option2) priceStr2 = [NSString stringWithFormat:@"%.1f", option2->put->bid];
        if (option && option2) {
            if (isnan(option->call->bid) && isnan(option2->put->bid)) {
                maxProfitStr = @"權利金---元\n ";
            }else {
                maxProfitStr = [NSString stringWithFormat:@"權利金 %.f 元\n ", (option->call->bid + option2->put->bid) *50];
            }
            if (isnan(option->call->bid) && isnan(option2->put->bid)) {
                breakEvenStr = @"上漲為 --- 點, 下跌為 --- 點";
            }else{
                breakEvenStr = [NSString stringWithFormat:@"上漲為 %.f 點, 下跌為 %.f 點", strike1 + option->call->bid + option2->put->bid, strike2 - (option->call->bid) - option2->put->bid];
            }
            if (isnan(option->call->bid) && isnan(option2->put->bid)) {
                maxLossStr = @"結算價 --- 點以上或 --- 點以下無限損失空間.";
            }else{
                maxLossStr = [NSString stringWithFormat:@"結算價 %.f 點以上或 %.f 點以下無限損失空間.", strike1 + option->call->bid + option2->put->bid, strike2 - option->call->bid - option2->put->bid];
            }
            optionChartView.pointA = [NSString stringWithFormat:@"%.f", strike2 - option->call->bid - option2->put->bid];
            optionChartView.pointB = [NSString stringWithFormat:@"%.f", strike2];
            optionChartView.pointC = [NSString stringWithFormat:@"%.f", strike1];
            optionChartView.pointD = [NSString stringWithFormat:@"%.f", strike1 + option->call->bid + option2->put->bid];
        }
    }else if (_cellNum == 6){ //看小漲
        powerStr1 = @"買 CALL";
        powerStr2 = @"賣 CALL";
        if (option) priceStr1 = [NSString stringWithFormat:@"%.1f", option->call->currentPrice];
        if (option2) priceStr2 = [NSString stringWithFormat:@"%.1f", option2->call->bid];
        if (option && option2) {
            if (isnan(option->call->currentPrice) && isnan(option2->call->bid)) {
                maxProfitStr = @"履約價差減權利價金差 --- 元";
            }else {
                maxProfitStr = [NSString stringWithFormat:@"履約價差減權利價金差 %.f 元", ((strike2 - strike1) - abs(option->call->currentPrice - option2->call->bid))*50];
            }
            if (isnan(option->call->currentPrice) && isnan(option2->call->bid)) {
                breakEvenStr = @"--- 點\n ";
            }else{
                breakEvenStr = [NSString stringWithFormat:@"%.f 點\n ", strike1 + abs(option->call->currentPrice - option2->call->bid)];
            }
            if (isnan(option->call->currentPrice) && isnan(option2->call->bid)) {
                maxLossStr = @"權利金差 --- 元\n ";
            }else{
                maxLossStr = [NSString stringWithFormat:@"權利金差 %.d 元\n ", abs(option->call->currentPrice - option2->call->bid) *50];
            }
            optionChartView.pointA = [NSString stringWithFormat:@"%.f", strike1];
            optionChartView.pointB = [NSString stringWithFormat:@"%.f", strike1 + abs(option->call->currentPrice - option2->call->bid)];
            optionChartView.pointC = [NSString stringWithFormat:@"%.f", strike2];
        }
    }else if (_cellNum == 7){ //小漲作莊
        powerStr1 = @"買 PUT";
        powerStr2 = @"賣 PUT";
        if (option) priceStr1 = [NSString stringWithFormat:@"%.1f", option->put->currentPrice];
        if (option2) priceStr2 = [NSString stringWithFormat:@"%.1f", option2->put->bid];
        if (option && option2) {
            if (isnan(option->put->currentPrice) && isnan(option2->put->bid)) {
                maxProfitStr = @"權利金差 --- 元\n ";
            }else {
                maxProfitStr = [NSString stringWithFormat:@"權利金差 %.d 元\n ", (abs(option->put->currentPrice - option2->put->bid))*50];
            }
            if (isnan(option->put->currentPrice) && isnan(option2->put->bid)) {
                breakEvenStr = @"--- 點\n ";
            }else{
                breakEvenStr = [NSString stringWithFormat:@"%.f 點\n ", strike2 - abs(option->put->currentPrice - option2->put->bid)];
            }
            if (isnan(option->put->currentPrice) && isnan(option2->put->bid)) {
                maxLossStr = @"履約價差減權利價金差 --- 元";
            }else{
                maxLossStr = [NSString stringWithFormat:@"履約價差減權利價金差 %.f 元", ((strike2-strike1) - abs(option->put->currentPrice - option2->put->bid)) *50];
            }
            optionChartView.pointA = [NSString stringWithFormat:@"%.f", strike1];
            optionChartView.pointB = [NSString stringWithFormat:@"%.f", strike2 - abs(option->put->currentPrice - option2->put->bid)];
            optionChartView.pointC = [NSString stringWithFormat:@"%.f", strike2];
        }
    }else if (_cellNum == 8){ //看小跌
        powerStr1 = @"買 PUT";
        powerStr2 = @"賣 PUT";
        if (option) priceStr1 = [NSString stringWithFormat:@"%.1f", option->put->currentPrice];
        if (option2) priceStr2 = [NSString stringWithFormat:@"%.1f", option2->put->bid];
        if (option && option2) {
            if (isnan(option->put->currentPrice) && isnan(option2->put->bid)) {
                maxProfitStr = @"履約價差減權利價金差 --- 元";
            }else {
                maxProfitStr = [NSString stringWithFormat:@"履約價差減權利價金差 %.f 元", ((strike1 - strike2) - abs(option->put->currentPrice - option2->put->bid))*50];
            }
            if (isnan(option->put->currentPrice) && isnan(option2->put->bid)) {
                breakEvenStr = @"--- 點\n ";
            }else{
                breakEvenStr = [NSString stringWithFormat:@"%.f 點\n ", strike1 - abs(option->put->currentPrice - option2->put->bid)];
            }
            if (isnan(option->put->currentPrice) && isnan(option2->put->bid)) {
                maxLossStr = @"權利金差 --- 元\n ";
            }else{
                maxLossStr = [NSString stringWithFormat:@"權利金差 %.d 元\n ", abs(option->put->currentPrice - option2->put->bid) *50];
            }
            optionChartView.pointA = [NSString stringWithFormat:@"%.f", strike1];
            optionChartView.pointB = [NSString stringWithFormat:@"%.f", strike1 - abs(option->put->currentPrice - option2->put->bid)];
            optionChartView.pointC = [NSString stringWithFormat:@"%.f", strike2];
        }
    }else if (_cellNum == 9){ //小跌作莊
        powerStr1 = @"買 CALL";
        powerStr2 = @"賣 CALL";
        if (option) priceStr1 = [NSString stringWithFormat:@"%.1f", option->call->currentPrice];
        if (option2) priceStr2 = [NSString stringWithFormat:@"%.1f", option2->call->bid];
        if (option && option2) {
            if (isnan(option->call->currentPrice) && isnan(option2->call->bid)) {
                maxProfitStr = @"權利金差 --- 元\n ";
            }else {
                maxProfitStr = [NSString stringWithFormat:@"權利金差 %.d 元\n ", (abs(option->call->currentPrice - option2->call->bid))*50];
            }
            if (isnan(option->call->currentPrice) && isnan(option2->call->bid)) {
                breakEvenStr = @"--- 點\n ";
            }else{
                breakEvenStr = [NSString stringWithFormat:@"%.f 點\n ", strike2 + abs(option->call->currentPrice - option2->call->bid)];
            }
            if (isnan(option->call->currentPrice) && isnan(option2->call->bid)) {
                maxLossStr = @"履約價差減權利價金差 --- 元";
            }else{
                maxLossStr = [NSString stringWithFormat:@"履約價差減權利價金差 %.f 元", ((strike1-strike2) - abs(option->call->currentPrice - option2->call->bid)) *50];
            }
            optionChartView.pointA = [NSString stringWithFormat:@"%.f", strike2];
            optionChartView.pointB = [NSString stringWithFormat:@"%.f", strike2 + abs(option->call->currentPrice - option2->call->bid)];
            optionChartView.pointC = [NSString stringWithFormat:@"%.f", strike1];
        }
    }
    if ([priceStr1 isEqualToString:@"nan"]) {
        priceStr1 = @"---";
    }
    if ([priceStr2 isEqualToString:@"nan"]){
        priceStr2 = @"---";
    }
    
    maxProfitLabel.text = maxProfitStr;
    breakEvenLabel.text = breakEvenStr;
    maxLossLabel.text = maxLossStr;
}

-(void)initBtnTitle{
    if ([optionData.goodsArray count] != 0) {
        [switchGoodsBtn setTitle:[NSString stringWithFormat:@"%@(%@)", [[optionData.goodsArray objectAtIndex:optionData.goodsNum] objectForKey:@"groupFullName"], [[optionData.goodsArray objectAtIndex:optionData.goodsNum] objectForKey:@"groupSymbol"]] forState:UIControlStateNormal];
        [switchMonthBtn setTitle:[[optionData.monthArray objectAtIndex:optionData.monthNum] objectForKey:@"month"] forState:UIControlStateNormal];
    }
    [switchStrategyBtn setTitle:_strategyTitle forState:UIControlStateNormal];
}

#pragma mark - Button Action
-(void)switchGoodsBtnAction:(FSUIButton *)sender{
    goodsActionSheet = [[UIActionSheet alloc] initWithTitle:@"切換商品" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (int i = 0; i < [optionData.goodsArray count]; i++) {
        [goodsActionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@(%@)", [[optionData.goodsArray objectAtIndex:i] objectForKey:@"groupFullName"], [[optionData.goodsArray objectAtIndex:i] objectForKey:@"groupSymbol"]]];
    }
    [goodsActionSheet addButtonWithTitle:@"取消"];
    goodsActionSheet.cancelButtonIndex = goodsActionSheet.numberOfButtons - 1;
    
    [self showActionSheet:goodsActionSheet];
}

-(void)switchMonthBtnAction:(FSUIButton *)sender{
    monthActionSheet = [[UIActionSheet alloc] initWithTitle:@"切換月份" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (int i = 0; i < [optionData.monthArray count]; i++) {
        [monthActionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@", [[optionData.monthArray objectAtIndex:i] objectForKey:@"month"]]];
    }
    [monthActionSheet addButtonWithTitle:@"取消"];
    monthActionSheet.cancelButtonIndex = monthActionSheet.numberOfButtons - 1;
    [self showActionSheet:monthActionSheet];
}

-(void)switchStrategyBtnAction:(FSUIButton *)sender{
    strategyActionSheet = [[UIActionSheet alloc] initWithTitle:@"策略選擇" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (int i = 0; i < [titleArray count]; i++) {
        [strategyActionSheet addButtonWithTitle:[titleArray objectAtIndex:i]];
    }
    [strategyActionSheet addButtonWithTitle:@"取消"];
    strategyActionSheet.cancelButtonIndex = strategyActionSheet.numberOfButtons - 1;
    [self showActionSheet:strategyActionSheet];
}

-(void)btnAction:(UIButton *)sender{
    strikeFlag = NO;
    btnTag = sender.tag;
    strikeActionSheet = [[UIActionSheet alloc] initWithTitle:@"履約價" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (int i = 0 ; i < [dataModel.option getRowCount]; i++) {
        OptionCallPut *option = [dataModel.option getNewRowData:i];
        [strikeActionSheet addButtonWithTitle:[NSString stringWithFormat:@"%.f", option->strikePrice]];
    }
    
    [strikeActionSheet addButtonWithTitle:@"取消"];
    strikeActionSheet.cancelButtonIndex = strikeActionSheet.numberOfButtons - 1;
    [self showActionSheet:strikeActionSheet];
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
        strikeFlag = YES;
        
    }else if ([actionSheet isEqual:monthActionSheet]){
        if (buttonIndex == monthActionSheet.cancelButtonIndex) {
            return;
        }
        optionData.monthNum = buttonIndex;
        [switchMonthBtn setTitle:[NSString stringWithFormat:@"%@", [[optionData.monthArray objectAtIndex:optionData.monthNum] objectForKey:@"month"]] forState:UIControlStateNormal];
        [view sendOptionDataWithGoodsNum:optionData.goodsNum MonthNum:optionData.monthNum];
        strikeFlag = YES;
        
    }else if ([actionSheet isEqual:strategyActionSheet]){
        if (buttonIndex == strategyActionSheet.cancelButtonIndex) {
            return;
        }
        [switchStrategyBtn setTitle:[titleArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        _cellNum = (int)buttonIndex;
        [optionChartView setChartViewType:(int)buttonIndex];
        strikeFlag = YES;
        
    }else if ([actionSheet isEqual:strikeActionSheet]){
        if (buttonIndex == strikeActionSheet.cancelButtonIndex) {
            return;
        }
        if (btnTag == 0) {
            OptionCallPut *option = [dataModel.option getNewRowData:(int)buttonIndex];
            strike1 = option->strikePrice;
            if (_cellNum > 3){
                if (_cellNum < 6 || _cellNum > 7) {
                    if (buttonIndex == 0) {  //選到最小的履約價
                        OptionCallPut *tmpOption = [dataModel.option getNewRowData:(int)++buttonIndex];
                        strike1 = tmpOption->strikePrice;
                    }
                    if(strike1<=strike2){
                        OptionCallPut *tmpOption = [dataModel.option getNewRowData:(int)buttonIndex-1];
                        strike2 = tmpOption->strikePrice;
                    }
                    
                }else{  //strike2 must > strike1
                    if(buttonIndex == [dataModel.option getRowCount]-1) {	//選到最大的
                        OptionCallPut *tmpOption = [dataModel.option getNewRowData:(int)--buttonIndex];
                        strike1 = tmpOption->strikePrice;
                    }
                    if(strike1 >= strike2){
                        OptionCallPut *tmpOption = [dataModel.option getNewRowData:(int)buttonIndex+1];
                        strike2 = tmpOption->strikePrice;
                    }
                }
            }
        }else{
            OptionCallPut *option = [dataModel.option getNewRowData:(int)buttonIndex];
            strike2 = option->strikePrice;
            if (_cellNum > 3) {
                if (_cellNum < 6 || _cellNum > 7) {
                    if(buttonIndex == [dataModel.option getRowCount]-1) {	//選到最大的
                        OptionCallPut *tmpOption = [dataModel.option getNewRowData:(int)--buttonIndex];
                        strike2 = tmpOption->strikePrice;
                    }
                    if(strike1 <= strike2){
                        OptionCallPut *tmpOption = [dataModel.option getNewRowData:(int)buttonIndex+1];
                        strike1 = tmpOption->strikePrice;
                    }
                }else {	//strike2 must > strike1
                    if(buttonIndex == 0) {	//選到最小的履約價
                        OptionCallPut *tmpOption = [dataModel.option getNewRowData:(int)++buttonIndex];
                        strike2 = tmpOption->strikePrice;
                    }
                    if(strike1 >= strike2){
                        OptionCallPut *tmpOption = [dataModel.option getNewRowData:(int)buttonIndex-1];
                        strike1 = tmpOption->strikePrice;
                    }
                }
			}
        }
    }
    [self initData];
    [_mainTableView reloadData];
}

#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_cellNum < 4) {
        return 1;
    }else{
        return 2;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString *cellIdentifier = @"historicalEPSHeaderCell";
    
    FSOptionStrategyCell *headerView = (FSOptionStrategyCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (headerView == nil) {
        headerView = [[FSOptionStrategyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    headerView.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
    
    headerView.header1.textColor = [UIColor whiteColor];
    headerView.header2.textColor = [UIColor whiteColor];
    headerView.header3.textColor = [UIColor whiteColor];
    headerView.header4.textColor = [UIColor whiteColor];
    
    headerView.header1.text = NSLocalizedStringFromTable(@"月份", @"", nil);
    headerView.header2.text = NSLocalizedStringFromTable(@"履約價", @"", nil);
    headerView.header3.text = NSLocalizedStringFromTable(@"權利", @"", nil);
    headerView.header4.text = NSLocalizedStringFromTable(@"價格", @"", nil);
    headerView.strikeBtn.hidden = YES;
    
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    FSOptionStrategyCell *cell = (FSOptionStrategyCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FSOptionStrategyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.powerLabel.textColor = [UIColor redColor];
    cell.priceLabe.textColor = [UIColor blueColor];
    cell.monthLabel.text = [NSString stringWithFormat:@"%@", [[optionData.monthArray objectAtIndex:optionData.monthNum] objectForKey:@"month"]];
    if (indexPath.row == 0) {
        [cell.strikeBtn setTitle:[[NSNumber numberWithDouble:strike1] stringValue] forState:UIControlStateNormal];
        cell.powerLabel.text = powerStr1;
        cell.priceLabe.text = priceStr1;
    }else if (indexPath.row == 1){
        [cell.strikeBtn setTitle:[[NSNumber numberWithDouble:strike2] stringValue] forState:UIControlStateNormal];
        cell.powerLabel.text = powerStr2;
        cell.priceLabe.text = priceStr2;
    }
    cell.strikeBtn.backgroundColor = [UIColor lightGrayColor];
    cell.strikeBtn.tag = indexPath.row;
    [cell.strikeBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

@end
