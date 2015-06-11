//
//  WarrantRankingViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantRankingViewController.h"
#import "SKCustomTableView.h"

@interface WarrantRankingViewController ()<SKCustomTableViewDelegate, UIActionSheetDelegate>
{
    UIView *topView;
    UILabel *rankingLabel;
    FSUIButton *rankingButton;
    FSUIButton *allButton;
    FSUIButton *buyButton;
    FSUIButton *sellButton;
    SKCustomTableView *mainTableView;
    FSDataModelProc *model;
    NSMutableArray *rankingDataArray;
    UIActionSheet *rankingSheet;
    NSMutableArray *rankingOptionArray;
    int buttonType;
    int rankingType;
    int direction;
}
@end

@implementation WarrantRankingViewController

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
    [self initArray];
	[self initView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    model = [FSDataModelProc sharedInstance];
    [model.warrant setTarget:self];
    [model.warrant sendRanking:7 rankingType:1 direction:0 filltI:0];
    [FSHUD showHUDin:self.view title:NSLocalizedStringFromTable(@"搜尋中", @"Warrant", nil)];
}

-(void)initArray
{
    buttonType = 0;
    rankingType = 1;
    direction = 0;
    buttonType = 0;
    rankingOptionArray = [NSMutableArray arrayWithObjects:
                                  NSLocalizedStringFromTable(@"漲幅排行", @"Warrant", nil),
                                  NSLocalizedStringFromTable(@"跌幅排行", @"Warrant", nil),
                                  NSLocalizedStringFromTable(@"成交值排行", @"Warrant", nil),
                                  NSLocalizedStringFromTable(@"成交量排行", @"Warrant", nil),
                                  NSLocalizedStringFromTable(@"低於理論值", @"Warrant", nil),
                                  NSLocalizedStringFromTable(@"高於理論值", @"Warrant", nil),
                                  nil];
}

-(void)initView
{
    topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor colorWithRed:182.0/255.0 green:44.0/255.0 blue:137.0/255.0 alpha:1];
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topView];
    
    rankingLabel = [[UILabel alloc ]init];
    rankingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    rankingLabel.text = @"權證排行";
    rankingLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    rankingLabel.textColor = [UIColor whiteColor];
    [topView addSubview:rankingLabel];
    
    rankingButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    rankingButton.translatesAutoresizingMaskIntoConstraints = NO;
    [rankingButton setTitle:NSLocalizedStringFromTable(@"漲幅排行", @"Warrant", nil) forState:UIControlStateNormal];
    [rankingButton addTarget:self action:@selector(rankingHandler:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:rankingButton];
    
    allButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [allButton setTitle:NSLocalizedStringFromTable(@"全部", @"Warrant", nil) forState:UIControlStateNormal];
    allButton.selected = YES;
    [allButton addTarget:self action:@selector(typeHandler:) forControlEvents:UIControlEventTouchUpInside];
    allButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:allButton];
    
    buyButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [buyButton setTitle:NSLocalizedStringFromTable(@"認購", @"Warrant", nil) forState:UIControlStateNormal];
    [buyButton addTarget:self action:@selector(typeHandler:) forControlEvents:UIControlEventTouchUpInside];
    buyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:buyButton];
    
    sellButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [sellButton setTitle:NSLocalizedStringFromTable(@"認售", @"Warrant", nil) forState:UIControlStateNormal];
    [sellButton addTarget:self action:@selector(typeHandler:) forControlEvents:UIControlEventTouchUpInside];
    sellButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:sellButton];
    
    mainTableView = [[SKCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:85 AndColumnHeight:44];
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.delegate = self;
    [self.view addSubview:mainTableView];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(rankingLabel, rankingButton, allButton, buyButton, sellButton, topView, mainTableView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topView]|" options:0 metrics:nil views:viewDictionary]];
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rankingLabel(90)][rankingButton]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rankingLabel]|" options:0 metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[allButton]-2-[buyButton(==allButton)]-2-[sellButton(==allButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView(44)][allButton][mainTableView]|" options:0 metrics:nil views:viewDictionary]];
}

- (NSArray *)columnsInFixedTableView {
    return @[NSLocalizedStringFromTable(@"名稱", @"", nil)];
}

- (NSArray *)columnsInMainTableView {
    return @[NSLocalizedStringFromTable(@"類別", @"", nil), NSLocalizedStringFromTable(@"成交價", @"", nil), NSLocalizedStringFromTable(@"漲幅", @"", nil), NSLocalizedStringFromTable(@"總量", @"", nil), NSLocalizedStringFromTable(@"成交值", @"", nil), NSLocalizedStringFromTable(@"標的代碼", @"", nil), NSLocalizedStringFromTable(@"標的名稱", @"", nil), NSLocalizedStringFromTable(@"標的價格", @"", nil), NSLocalizedStringFromTable(@"漲幅", @"", nil), NSLocalizedStringFromTable(@"隱含波動", @"", nil), NSLocalizedStringFromTable(@"歷史波動", @"", nil), NSLocalizedStringFromTable(@"理論價格", @"", nil), NSLocalizedStringFromTable(@"理論價差", @"", nil), NSLocalizedStringFromTable(@"價內外", @"", nil), NSLocalizedStringFromTable(@"到期日", @"", nil)];
}

- (void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WarrantRankingObject *rankingObj = [rankingDataArray objectAtIndex:indexPath.row];
    if (columnIndex == 0) {
        label.textColor = [UIColor blueColor];
        label.textAlignment = NSTextAlignmentLeft;
        
        label.text = rankingObj->warrantName;
    }
    
}

- (void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // default value
    label.textColor = [UIColor blackColor];
    label.text = @"----";
    
    double taValue;
    //SecurityQueryParam *sqParam = [dataModel.warrant getAllocDataByRow:indexPath.row];
    WarrantRankingObject *rankingObj = [rankingDataArray objectAtIndex:indexPath.row];
    
    // 類型
    if (columnIndex == 0) {
        label.text = rankingObj->type;
        label.textColor = [UIColor blueColor];
    }
    
    // 成交價
    if (columnIndex == 1) {
        label.textAlignment = NSTextAlignmentCenter;
        double refValue = rankingObj->reference;
        taValue = rankingObj->price;
        
        if (taValue > refValue) {
            label.textColor = [StockConstant PriceUpColor];
        } else if (taValue < refValue) {
            label.textColor = [StockConstant PriceDownColor];
        } else {
            label.textColor = [UIColor blueColor];
        }
        if(rankingObj->price == 0.00){
            label.text = @"----";
        }else{
            label.text = [NSString stringWithFormat:@"%.2f", taValue];
        }
        
    }
    
    // 漲幅
    if (columnIndex == 2) {
        taValue = rankingObj->change;
        if(taValue >0){
            label.text = [NSString stringWithFormat:@"+%.0f%%", taValue*100];
            label.textColor = [StockConstant PriceUpColor];
        }else if(taValue <0){
            label.text = [NSString stringWithFormat:@"%.0f%%", taValue*100];
            label.textColor = [StockConstant PriceDownColor];
        }else{
            label.text = [NSString stringWithFormat:@"%.0f%%", taValue*100];
            label.textColor = [UIColor blueColor];
        }
    }
    
    // 總量
    if (columnIndex == 3) {
        taValue = rankingObj->volume;
        label.text = [CodingUtil ConvertDoubleValueToString:taValue];
        label.textColor = [UIColor colorWithRed:127.0f/255.0f green:15.0f/255.0f blue:137.0f/255.0f alpha:1.0];
    }
    
    // 成交值
    if (columnIndex == 4) {
        taValue = rankingObj->transactionValue;
        label.textColor = [UIColor blueColor];
        label.text = [self getTransactionValue:taValue];
    }
    
    // 標的代碼
    if (columnIndex == 5) {
        label.textColor = [UIColor blueColor];
        label.text = rankingObj->targetSymbol;
    }
    
    // 標的名稱
    if (columnIndex == 6) {
        label.textColor = [UIColor blueColor];
        label.text = rankingObj->targetName;
    }

    // 標的價格
    if (columnIndex == 7) {
        label.textAlignment = NSTextAlignmentCenter;
        double refValue = rankingObj->targetReference;
        taValue = rankingObj->targetPrice;
        
        if (taValue > refValue) {
            label.textColor = [StockConstant PriceUpColor];
        } else if (taValue < refValue) {
            label.textColor = [StockConstant PriceDownColor];
        } else {
            label.textColor = [UIColor blueColor];
        }
        if(rankingObj->targetPrice == 0.00){
            label.text = @"----";
        }else{
            label.text = [NSString stringWithFormat:@"%.2f", taValue];
        }
    }
    
    // 漲幅
    if (columnIndex == 8) {
        taValue = rankingObj->targetChange;
        if(taValue >0){
            label.text = [NSString stringWithFormat:@"+%.2f%%", taValue*100];
            label.textColor = [StockConstant PriceUpColor];
        }else if(taValue <0){
            label.text = [NSString stringWithFormat:@"%.2f%%", taValue*100];
            label.textColor = [StockConstant PriceDownColor];
        }else{
            label.text = [NSString stringWithFormat:@"%.2f%%", taValue*100];
            label.textColor = [UIColor blueColor];
        }
    }
    
    // 隱含波動
    if (columnIndex == 9) {
        taValue = rankingObj->IV * 100;
        label.text = [NSString stringWithFormat:@"%.1f%%", taValue];
        label.textColor = [UIColor blueColor];
    }
    
    // 歷史波動
    if (columnIndex == 10) {
        taValue = rankingObj->HV * 100;
        label.text = [NSString stringWithFormat:@"%.1f%%", taValue];
        label.textColor = [UIColor blueColor];
    }
    
    
    
    // 理論價格
    if (columnIndex == 11) {
        taValue = rankingObj->formulaPrice;
        if(taValue >= 0){
            label.text = [NSString stringWithFormat:@"+%.3f",taValue];
        }else if(taValue <0){
            label.text = [NSString stringWithFormat:@"%.0f%%", taValue*100];
        }else{
            label.text = [NSString stringWithFormat:@"%.0f%%", taValue*100];
        }
        label.textColor = [UIColor blueColor];
        
    }
    
    // 理論價差
    if (columnIndex == 12) {
        taValue = rankingObj->formulaChange;
        if(taValue >= 0){
            label.text = [NSString stringWithFormat:@"+%.0f%%",taValue*100];
        }else if(taValue <0){
            label.text = [NSString stringWithFormat:@"%.0f%%", taValue*100];
        }else{
            label.text = [NSString stringWithFormat:@"%.0f%%", taValue*100];
        }
        label.textColor = [UIColor blueColor];
    }
    //價內外
    if (columnIndex == 13) {
        taValue = rankingObj->inOutMoney;
        if(taValue >= 0){
            label.text = [NSString stringWithFormat:@"+%.2f%%",taValue*100];
            label.textColor = [StockConstant PriceUpColor];
        }else if(taValue <0){
            label.text = [NSString stringWithFormat:@"%.2f%%", taValue*100];
            label.textColor = [StockConstant PriceDownColor];
        }else{
            label.text = [NSString stringWithFormat:@"%.2f%%", taValue*100];
            label.textColor = [UIColor blueColor];
        }
     }
    //到期日
    if (columnIndex == 14){
        NSDate *date = [[NSDate alloc] init];
        UInt16 dateInt = [date uint16Value];
        label.text = [NSString stringWithFormat:@"%d天",rankingObj->date - dateInt];
        label.textColor = [UIColor blueColor];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [rankingDataArray count];
}


-(void)notifyData:(NSMutableArray *)dataArray
{
    rankingDataArray = dataArray;
    [mainTableView reloadAllData];
    [FSHUD hideHUDFor:self.view];
}

-(NSString *)getTransactionValue:(double)value
{
    return [NSString stringWithFormat:@"%.1fK",value/1000];
}

-(void)rankingHandler:(FSUIButton *)id
{
    rankingSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"排序方式", @"Warrant", nil)  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for(int i =0; i<[rankingOptionArray count]; i++){
        [rankingSheet addButtonWithTitle:[rankingOptionArray objectAtIndex:i]];
    }
    [rankingSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
    rankingSheet.cancelButtonIndex = [rankingOptionArray count];
    [rankingSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex !=[rankingOptionArray count]){
        [rankingButton setTitle:[rankingOptionArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        switch (buttonIndex) {
            case 0:
                rankingType = 1;
                direction = 0;
                break;
            case 1:
                rankingType = 1;
                direction = 1;
                break;
            case 2:
                rankingType = 5;
                direction = 0;
                break;
            case 3:
                rankingType = 3;
                direction = 0;
                break;
            case 4:
                rankingType = 12;
                direction = 1;
                break;
            case 5:
                rankingType = 12;
                direction = 0;
                break;
        }
    }
    [model.warrant sendRanking:7 rankingType:rankingType direction:direction filltI:buttonType];
    [FSHUD showHUDin:self.view title:NSLocalizedStringFromTable(@"搜尋中", @"Warrant", nil)];
}

-(void)typeHandler:(FSUIButton *)target
{
    if(target.selected == YES){
        return;
    }
    allButton.selected = NO;
    buyButton.selected = NO;
    sellButton.selected = NO;
    target.selected = YES;
    if([target isEqual:allButton]){
        buttonType = 0;
    }else if([target isEqual:buyButton]){
        buttonType = 1;
    }else if([target isEqual:sellButton]){
        buttonType = 2;
    }
    [model.warrant sendRanking:7 rankingType:rankingType direction:direction filltI:buttonType];
    [FSHUD showHUDin:self.view title:NSLocalizedStringFromTable(@"搜尋中", @"Warrant", nil)];
}


@end
