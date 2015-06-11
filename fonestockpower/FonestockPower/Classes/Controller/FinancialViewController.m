//
//  FinancialViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/11/12.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FinancialViewController.h"
#import "DDPageControl.h"
#import "FinancialTableViewCell.h"
#import "FSUIButton.h"
#import "ChangeStockViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "MarqueeLabel.h"



@interface FinancialViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    
    FSDataModelProc *dataModel;
    
    NSMutableDictionary * symbol1Dic;
    NSMutableDictionary * symbol2Dic;
    
    NSMutableArray *balance1Array;
    NSMutableArray *balance2Array;
    
    NSMutableArray *income1Array;
    NSMutableArray *income2Array;
    
    NSMutableArray *cashFlow1Array;
    NSMutableArray *cashFlow2Array;
    
    NSMutableArray *financialRatio1Array;
    NSMutableArray *financialRatio2Array;
    
    
    
    FSUIButton *balanceTwoStockBtn;
    FSUIButton *incomeTwoStockBtn;
    FSUIButton *cashFlowTwoStockBtn;
    FSUIButton *financialRatioTwoStockBtn;
}


@property (strong, nonatomic) NSMutableDictionary * dictionary;
@property (nonatomic) BOOL twoStock;
@property (nonatomic) BOOL balanceFlag;
@property (nonatomic) BOOL incomeFlag;
@property (nonatomic) BOOL cashFlowFlag;
@property (nonatomic) BOOL financialRatioFlag;

@property (strong, nonatomic) FSInstantInfoWatchedPortfolio * watchportfolio;

@property (strong, nonatomic) NSMutableArray * totalArray;
@property (strong, nonatomic) NSMutableArray * typeArray;
@property (nonatomic) int total;//0:累計 1:單季
@property (nonatomic) int type;//0:$ 1:% 2:$+%
//用來保護_type 這個property ，避免其在viewDidLayoutSubview 連續執行兩次時洗掉儲存在裡面的值
@property (nonatomic) BOOL isProtectType;

@property (strong, nonatomic) UILabel * percentLabel;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) DDPageControl *pageControl;

@property (unsafe_unretained, nonatomic) NSInteger numberOfPages;
@property (unsafe_unretained, nonatomic) NSInteger selectedOptionIndex;

@property (strong, nonatomic) NSString * identSymbol;
@property (strong, nonatomic) NSString * identSymbol2;

@property (nonatomic) int balancePostion;
@property (nonatomic) int balancePostion2;
@property (nonatomic) int incomePostion;
@property (nonatomic) int incomePostion2;
@property (nonatomic) int cashFlowPostion;
@property (nonatomic) int cashFlowPostion2;
@property (nonatomic) int financialRatioPostion;
@property (nonatomic) int financialRatioPostion2;

@property (nonatomic) UInt16 symbol1BeginDate;
@property (nonatomic) UInt16 symbol1EndDate;

@property (nonatomic) UInt16 symbol2BeginDate;
@property (nonatomic) UInt16 symbol2EndDate;

@property (strong, nonatomic) UIView * balanceView;
@property (strong, nonatomic) UITableView * balanceTableView;
@property (strong, nonatomic) UIView * incomeView;
@property (strong, nonatomic) UITableView * incomeTableView;
@property (strong, nonatomic) UIView * cashFlowView;
@property (strong, nonatomic) UITableView * cashFlowTableView;
@property (strong, nonatomic) UIView * financialRatioView;
@property (strong, nonatomic) UITableView * financialRatioTableView;

@property (strong, nonatomic) UIView * headerView;

@property (strong, nonatomic) FSUIButton * balanceMergeBtn;
@property (strong, nonatomic) FSUIButton * balanceTypeBtn;
@property (strong, nonatomic) FSUIButton * balanceStock1Btn;
@property (strong, nonatomic) FSUIButton * balanceStock2Btn;
@property (strong, nonatomic) UILabel * balanceheaderTitleLabel;
@property (strong, nonatomic) FSUIButton * balanceGroup1Btn;
@property (strong, nonatomic) FSUIButton * balanceGroup2Btn;

@property (strong, nonatomic) FSUIButton * incomeMergeBtn;
@property (strong, nonatomic) FSUIButton * incomeTypeBtn;
@property (strong, nonatomic) FSUIButton * incomeTotalBtn;
@property (strong, nonatomic) FSUIButton * incomeStock1Btn;
@property (strong, nonatomic) FSUIButton * incomeStock2Btn;
@property (strong, nonatomic) UILabel * incomeHeaderTitleLabel;
@property (strong, nonatomic) FSUIButton * incomeGroup1Btn;
@property (strong, nonatomic) FSUIButton * incomeGroup2Btn;

@property (strong, nonatomic) FSUIButton * cashFlowMergeBtn;
@property (strong, nonatomic) FSUIButton * cashFlowTypeBtn;
@property (strong, nonatomic) FSUIButton * cashFlowTotalBtn;
@property (strong, nonatomic) FSUIButton * cashFlowStock1Btn;
@property (strong, nonatomic) FSUIButton * cashFlowStock2Btn;
@property (strong, nonatomic) UILabel * cashFlowHeaderTitleLabel;
@property (strong, nonatomic) FSUIButton * cashFlowGroup1Btn;
@property (strong, nonatomic) FSUIButton * cashFlowGroup2Btn;

@property (strong, nonatomic) FSUIButton * financialRatioMergeBtn;
@property (strong, nonatomic) FSUIButton * financialRatioTotalBtn;
@property (strong, nonatomic) FSUIButton * financialRatioStock1Btn;
@property (strong, nonatomic) FSUIButton * financialRatioStock2Btn;
@property (strong, nonatomic) UILabel * financialRatioHeaderTitleLabel;
@property (strong, nonatomic) FSUIButton * financialRatioGroup1Btn;
@property (strong, nonatomic) FSUIButton * financialRatioGroup2Btn;

@property (strong, nonatomic) UIActionSheet *totalActionSheet;
@property (strong, nonatomic) UIActionSheet *typeActionSheet;
@property (strong, nonatomic) UIActionSheet *group1ActionSheet;
@property (strong, nonatomic) UIActionSheet *group2ActionSheet;
@property (strong, nonatomic) FSUIButton * group1Btn;
@property (strong, nonatomic) FSUIButton * group2Btn;
@property (nonatomic, strong) NSMutableDictionary *mainDict;
@end

@implementation FinancialViewController

//共有四張表balance income cashFlow financialRatio
//所需的identCode Symbol 在加入自選時就已經取得，然後在一進入"基本->財報"頁面時，會將選取的股票
//所包含的四張表 + 對應的merge 表，共八個plist 檔直接儲存下來
//之後再進行各項操作時，只是依該操作，reload 對應的資料而已

- (instancetype)init {
    if (self = [super init]) {
        
        dataModel = [FSDataModelProc sharedInstance];
        
        self.dictionary = [[NSMutableDictionary alloc] init];
        
        balance1Array = [[NSMutableArray alloc] init];
        balance2Array = [[NSMutableArray alloc] init];
        
        income1Array = [[NSMutableArray alloc] init];
        income2Array = [[NSMutableArray alloc] init];
        
        cashFlow1Array = [[NSMutableArray alloc] init];
        cashFlow2Array = [[NSMutableArray alloc] init];
        
        financialRatio1Array = [[NSMutableArray alloc] init];
        financialRatio2Array = [[NSMutableArray alloc] init];
        
        symbol1Dic = [[NSMutableDictionary alloc] init];
        symbol2Dic = [[NSMutableDictionary alloc] init];
        
        self.totalArray = [[NSMutableArray alloc] initWithObjects:
                           NSLocalizedStringFromTable(@"累計", @"Equity", nil),
                           NSLocalizedStringFromTable(@"單季", @"Equity", nil), nil];
        
        self.typeArray= [[NSMutableArray alloc] initWithObjects:
                         @"$",
                         @"%",
                         @"$+%", nil];
        _total = 1;
        
        self.watchportfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
        
        
        NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent: [NSString stringWithFormat:@"FinanceMemory.plist"]];
        self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self readFromFile];
    
    [self initScrollView];
    
    [self initPageControl];
    
    [self initTableView];
    
    [self initTitle];
    
    [self setLayout];
    
    _balanceMergeBtn.hidden = YES;
    _incomeMergeBtn.hidden = YES;
    _cashFlowMergeBtn.hidden = YES;
    _financialRatioMergeBtn.hidden = YES;
}


- (void)portfolioInAlertNotification{
    [self reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self registerLoginNotificationCallBack:self seletor:@selector(portfolioInAlertNotification)];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(portfolioInAlertNotification)];
    [self searchBalanceSheet];
//    [self reloadData];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    dataModel.indicator.twoStockCompare = _twoStock;
    [dataModel.indicator writeDefaultBottomViewIndicator];
    
    [self saveToFile];
    [self discardData];
    
    [self unregisterLoginNotificationCallBack:self];
    [self unRegisterSecurityRegisterNotificationCallBack:self];
    
    
    [super viewWillDisappear:animated];
}






- (void)reloadData {
    
}

- (void)reloadStocks {
    
    // 如果第二檔是空的 就設第一檔
    if (_watchportfolio.comparedPortfolioItem == nil) {
        _watchportfolio.comparedPortfolioItem = _watchportfolio.portfolioItem;
    }
    
    // 如果有開雙股, 不是股票就換第一檔
    if (_twoStock) {
        if (_watchportfolio.comparedPortfolioItem->type_id != 1) {
            _watchportfolio.comparedPortfolioItem = _watchportfolio.portfolioItem;
        }
    }
    
    NSString *symbol1Name;
    NSString *symbol2Name;
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        symbol1Name = _watchportfolio.portfolioItem->symbol;
        symbol2Name = _watchportfolio.comparedPortfolioItem->symbol;
    } else {
        symbol1Name = _watchportfolio.portfolioItem->fullName;
        symbol2Name = _watchportfolio.comparedPortfolioItem->fullName;
    }
    
    [_balanceStock1Btn setTitle:symbol1Name forState:UIControlStateNormal];
    [_balanceStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
    [_incomeStock1Btn setTitle:symbol1Name forState:UIControlStateNormal];
    [_incomeStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
    [_cashFlowStock1Btn setTitle:symbol1Name forState:UIControlStateNormal];
    [_cashFlowStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
    [_financialRatioStock1Btn setTitle:symbol1Name forState:UIControlStateNormal];
    [_financialRatioStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
    
    
    self.identSymbol = [_watchportfolio.portfolioItem getIdentCodeSymbol];
    self.identSymbol2 = [_watchportfolio.comparedPortfolioItem getIdentCodeSymbol];
}

-(void)dealloc{
    
}


-(void)searchBalanceSheet{
    
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        [dataModel.financeReportUS setTargetNotify:self];
        [self.balanceView showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"Equity", nil)];
        [self.incomeView showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"Equity", nil)];
        [self.cashFlowView showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"Equity", nil) ];
        [self.financialRatioView showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"Equity", nil) ];
        [self loadDefaultValue];
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock){
            [dataModel.financeReportUS searchAllSheetWithSecurityNumber:_watchportfolio.portfolioItem->commodityNo dataType:'Q' searchStartDate:[[NSDate date] yearOffset:-2]];
        }else{
            [dataModel.financeReportUS searchAllSheetWithSecurityNumber:_watchportfolio.portfolioItem->commodityNo dataType:'Q' searchStartDate:[[NSDate date] yearOffset:-2]];
            [dataModel.financeReportUS searchAllSheetWithSecurityNumber:_watchportfolio.comparedPortfolioItem->commodityNo dataType:'Q' searchStartDate:[[NSDate date] yearOffset:-2]];
        }
    } else {
        [self.balanceView showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"Equity", nil)];
        
        [dataModel.balanceSheet loadSymbol1FromIdentSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
        [dataModel.balanceSheet setTargetNotify:self];
        [dataModel.balanceSheet sendAndReadWithSymbol1:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
        [dataModel.balanceSheet loadSymbol2FromIdentSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
        
        [dataModel.balanceSheet sendAndReadWithSymbol2:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
        
        
        [self.incomeView showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"Equity", nil)];
        [dataModel.income loadSymbol1FromIdentSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
        [dataModel.income loadSymbol2FromIdentSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
        [dataModel.income setTargetNotify:self];
        [dataModel.income sendAndReadWithSymbol1:[_watchportfolio.portfolioItem getIdentCodeSymbol] Type:'Y'];
        [dataModel.income sendAndReadWithSymbol2:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol] Type:'Y'];
        
        
        [self.cashFlowView showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"Equity", nil) ];
        [dataModel.cashFlow loadSymbol1FromIdentSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
        [dataModel.cashFlow loadSymbol2FromIdentSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
        
        [dataModel.cashFlow setTargetNotify:self];
        [dataModel.cashFlow sendAndReadWithSymbol1:[_watchportfolio.portfolioItem getIdentCodeSymbol] Type:'Y'];
        [dataModel.cashFlow sendAndReadWithSymbol2:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol] Type:'Y'];
        
        
        
        [self.financialRatioView showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"Equity", nil) ];
        
        [dataModel.financialRatio loadSymbol1FromIdentSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
        [dataModel.financialRatio loadSymbol2FromIdentSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
        [dataModel.financialRatio setTargetNotify:self];
        [dataModel.financialRatio sendAndReadWithSymbol1:[_watchportfolio.portfolioItem getIdentCodeSymbol] Type:'X'];
        [dataModel.financialRatio sendAndReadWithSymbol2:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol] Type:'X'];
    }
}

-(void)loadDefaultValue{
    [balance1Array removeAllObjects];
    [balance2Array removeAllObjects];
    [income1Array removeAllObjects];
    [income2Array removeAllObjects];
    [cashFlow1Array removeAllObjects];
    [cashFlow2Array removeAllObjects];
    [financialRatio1Array removeAllObjects];
    [financialRatio2Array removeAllObjects];
    
    
    balance1Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"BalanceSheet" IdentCodeSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
    if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
        balance2Array = balance1Array;
    }else{
        balance2Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"BalanceSheet" IdentCodeSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
    }
    
    income1Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"IncomeStatement" IdentCodeSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
    if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
        income2Array = income1Array;
    }else{
        income2Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"IncomeStatement" IdentCodeSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
    }
    
    cashFlow1Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"CashFlow" IdentCodeSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
    if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
        cashFlow2Array = cashFlow1Array;
    }else{
        cashFlow2Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"CashFlow" IdentCodeSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
    }
    
    financialRatio1Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"FinancialRatio" IdentCodeSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
    if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
        financialRatio2Array = financialRatio1Array;
        [self searchDataWithGroup:@"Group2"];
    }else{
        financialRatio2Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"FinancialRatio" IdentCodeSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
    }
    
    
    [self searchDataWithGroup:@"Group1"];
    [self searchDataWithGroup:@"Group2"];
}



- (void)notifyDataUS:(NSString *)sheetTitle {
    
    if([sheetTitle isEqualToString:@"BalanceSheet1"]){
        [balance1Array removeAllObjects];
        balance1Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"BalanceSheet" IdentCodeSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
            balance2Array = balance1Array;
        }
        [_balanceTableView reloadData];
        
    }else if([sheetTitle isEqualToString:@"BalanceSheet2"]){
        [balance2Array removeAllObjects];
        balance2Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"BalanceSheet" IdentCodeSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
        [_balanceTableView reloadData];
    }else if([sheetTitle isEqualToString:@"Income1"]){
        [income1Array removeAllObjects];
        income1Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"IncomeStatement" IdentCodeSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
            income2Array = income1Array;
        }
        [_incomeTableView reloadData];
        
    }else if([sheetTitle isEqualToString:@"Income2"]){
        [income2Array removeAllObjects];
        income2Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"IncomeStatement" IdentCodeSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
        [_incomeTableView reloadData];
    }else if([sheetTitle isEqualToString:@"CashFlow1"]){
        [cashFlow1Array removeAllObjects];
        cashFlow1Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"CashFlow" IdentCodeSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
            cashFlow2Array = cashFlow1Array;
        }
        [_cashFlowTableView reloadData];
        
    }else if([sheetTitle isEqualToString:@"CashFlow2"]){
        [cashFlow2Array removeAllObjects];
        cashFlow2Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"CashFlow" IdentCodeSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
        [_cashFlowTableView reloadData];
    }else if([sheetTitle isEqualToString:@"FinancialRatio1"]){
        [financialRatio1Array removeAllObjects];
        financialRatio1Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"FinancialRatio" IdentCodeSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
            financialRatio2Array = financialRatio1Array;
            [self searchDataWithGroup:@"Group2"];
        }
        [self searchDataWithGroup:@"Group1"];
        [_financialRatioTableView reloadData];
        
    }else if([sheetTitle isEqualToString:@"FinancialRatio2"]){
        [financialRatio2Array removeAllObjects];
        financialRatio2Array = [dataModel.financeReportUS searchFinanceDataDateWithReportType:@"FinancialRatio" IdentCodeSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
        [self searchDataWithGroup:@"Group2"];
        [_financialRatioTableView reloadData];
    }
}

- (void)notifyDataTW:(NSString *)sheetTitle {
    
    
    NSLog(@"%@", sheetTitle);
    
    if([sheetTitle isEqualToString:@"BalanceSheet1"]){
        [balance1Array removeAllObjects];
        int count = [dataModel.balanceSheet getDateCountByIdentSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
        
        if (count>0) {
            self.symbol1EndDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol Postion:0];
            self.symbol1BeginDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol Postion:count-1];
            if (count>8) {
                count =8;
                self.symbol1BeginDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol Postion:7];
            }
            for(int i=0 ; i<count ; i++){
                [balance1Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol Postion:i]]];
            }
            if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
                balance2Array = balance1Array;
            }
        }
        [_balanceTableView reloadData];
        [self.balanceView hideHUD];
        
    }else if([sheetTitle isEqualToString:@"BalanceSheet2"]){
        [balance2Array removeAllObjects];
        int count2 = [dataModel.balanceSheet getDateCountByIdentSymbol:_identSymbol2];
        
        if (count2>0) {
            self.symbol2EndDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol2 Postion:0];
            self.symbol2BeginDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol2 Postion:count2-1];
            if (count2>8) {
                count2 =8;
                self.symbol2BeginDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol2 Postion:7];
            }
            for(int i=0 ; i<count2 ; i++){
                [balance2Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol2 Postion:i]]];
            }
        }
        [_balanceTableView reloadData];
    }else if ([sheetTitle isEqualToString:@"BalanceSheetNoData"]){
        [_balanceTableView reloadData];
        [self.balanceView hideHUD];
    }else if ([sheetTitle isEqualToString:@"Income1"]){
        [income1Array removeAllObjects];
        int count = [dataModel.income getDateCountByIdentSymbol:_identSymbol];
        if (count>0) {
            if (count>8) {
                count =8;
            }
            for(int i=0 ; i<count ; i++){
                [income1Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.income findDateByIdentSymbol:_identSymbol Postion:i]]];
            }
            if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
                income2Array = income1Array;
            }
        }
        
        [_incomeTableView reloadData];
        [self.incomeView hideHUD];
    }else if ([sheetTitle isEqualToString:@"Income2"]){
        [income2Array removeAllObjects];
        int count = [dataModel.income getDateCountByIdentSymbol:_identSymbol2];
        if (count>0) {
            if (count>8) {
                count =8;
            }
            for(int i=0 ; i<count ; i++){
                [income2Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.income findDateByIdentSymbol:_identSymbol2 Postion:i]]];
            }
        }
        
        [_incomeTableView reloadData];
    }else if ([sheetTitle isEqualToString:@"IncomeNoData"]){
        [_incomeTableView reloadData];
        [self.incomeView hideHUD];
    }else if ([sheetTitle isEqualToString:@"CashFlow1"]){
        [cashFlow1Array removeAllObjects];
        int count = [dataModel.cashFlow getDateCountByIdentSymbol:_identSymbol];
        if (count>0) {
            if (count>8) {
                count =8;
            }
            for(int i=0 ; i<count ; i++){
                [cashFlow1Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.cashFlow findDateByIdentSymbol:_identSymbol Postion:i]]];
            }
            if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
                cashFlow2Array = cashFlow1Array;
            }
        }
        
        [_cashFlowTableView reloadData];
        [self.cashFlowView hideHUD];
    }else if ([sheetTitle isEqualToString:@"CashFlow2"]){
        [cashFlow2Array removeAllObjects];
        int count = [dataModel.cashFlow getDateCountByIdentSymbol:_identSymbol2];
        if (count>0) {
            if (count>8) {
                count =8;
            }
            for(int i=0 ; i<count ; i++){
                [cashFlow2Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.cashFlow findDateByIdentSymbol:_identSymbol2 Postion:i]]];
            }
        }
        
        [_cashFlowTableView reloadData];
    }else if ([sheetTitle isEqualToString:@"CashFlowNoData"]){
        [_cashFlowTableView reloadData];
        [self.cashFlowView hideHUD];
    }else if ([sheetTitle isEqualToString:@"FinancialRatio1"]){
        [financialRatio1Array removeAllObjects];
        int count = [dataModel.financialRatio getDateCountByIdentSymbol:_identSymbol];
        if (count>0) {
            if (count>8) {
                count =8;
            }
            for(int i=0 ; i<count ; i++){
                [financialRatio1Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.financialRatio findDateByIdentSymbol:_identSymbol Postion:i]]];
            }
            if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
                financialRatio2Array = financialRatio1Array;
            }
        }
        
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
        NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol];
        [dic setObject:tmpDic forKey:@"incomeValueDict"];
        
        tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol];
        [dic setObject:tmpDic forKey:@"balanceValueDict"];
        
        [dataModel.financialRatio calculateWithWithIdentSymbol:_identSymbol Index:_financialRatioPostion Data:dic Date:[(NSNumber *)[financialRatio1Array objectAtIndex:_financialRatioPostion]intValue]];
        
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol2];
            [dic setObject:tmpDic forKey:@"incomeValueDict"];
            
            tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol2];
            [dic setObject:tmpDic forKey:@"balanceValueDict"];
            
            [dataModel.financialRatio calculateWithWithIdentSymbol:_identSymbol2 Index:_financialRatioPostion2 Data:dic Date:[(NSNumber *)[financialRatio2Array objectAtIndex:_financialRatioPostion2]intValue]];
        }
        
        [_financialRatioTableView reloadData];
        [self.financialRatioView hideHUD];
    }else if ([sheetTitle isEqualToString:@"FinancialRatio2"]){
        [financialRatio2Array removeAllObjects];
        int count = [dataModel.financialRatio getDateCountByIdentSymbol:_identSymbol2];
        if (count>0) {
            if (count>8) {
                count =8;
            }
            for(int i=0 ; i<count ; i++){
                [financialRatio2Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.financialRatio findDateByIdentSymbol:_identSymbol2 Postion:i]]];
            }
        }
        
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
        NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol2];
        
        [dic setObject:tmpDic forKey:@"incomeValueDict"];
        
        tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol2];
        [dic setObject:tmpDic forKey:@"balanceValueDict"];
        
        [dataModel.financialRatio calculateWithWithIdentSymbol:_identSymbol2 Index:_financialRatioPostion2 Data:dic Date:[(NSNumber *)[financialRatio2Array objectAtIndex:_financialRatioPostion2]intValue]];
        
        [_financialRatioTableView reloadData];
    }else if ([sheetTitle isEqualToString:@"FinancialRatioNoData"]){
        [_financialRatioTableView reloadData];
        [self.financialRatioView hideHUD];
    }
}


- (void)notifyData:(id)notifyObj{
    NSString *sheetTitle = notifyObj;
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        [self notifyDataUS:sheetTitle];
    } else {
        [self notifyDataTW:sheetTitle];
    }
    
}


-(int)setPostionWithPostion:(int)postion SearchArray:(NSMutableArray *)searchArray TargetArray:(NSMutableArray *)targetArray{
    int targetPostion = 0;
    
    if([searchArray count] > postion){
        targetPostion = [self findPostionWithDate:[searchArray objectAtIndex:postion] Array:targetArray];
    }
    
    return targetPostion;
}

-(int)findPostionWithDate:(NSNumber *)date Array:(NSMutableArray *)array{
    int postion = 0;
    
    for (int i=0; i<[array count]; i++) {
        NSNumber * number = [array objectAtIndex:i];
        if ([date isEqualToNumber:number]) {
            postion = i;
        }
    }
    
    return postion;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([actionSheet isEqual:_totalActionSheet]) {
        
        if (buttonIndex==0) {
            _total = 0;
            dataModel.income.total = YES;
            dataModel.cashFlow.total = YES;
            dataModel.financialRatio.total = YES;
//            _incomeHeaderTitleLabel.text = NSLocalizedStringFromTable(@"財報日期(累計)", @"Equity", nil);
//            _cashFlowHeaderTitleLabel.text = NSLocalizedStringFromTable(@"財報日期(累計)", @"Equity", nil);
//            _financialRatioHeaderTitleLabel.text = NSLocalizedStringFromTable(@"財報日期(累計)", @"Equity", nil);
        }else if (buttonIndex==1){
            _total = 1;
            dataModel.income.total = NO;
            dataModel.cashFlow.total = NO;
            dataModel.financialRatio.total = NO;
//            _incomeHeaderTitleLabel.text = NSLocalizedStringFromTable(@"財報日期(單季)", @"Equity", nil);
//            _cashFlowHeaderTitleLabel.text = NSLocalizedStringFromTable(@"財報日期(單季)", @"Equity", nil);
//            _financialRatioHeaderTitleLabel.text = NSLocalizedStringFromTable(@"財報日期(單季)", @"Equity", nil);
        }
        if (buttonIndex != 2) {
            [_incomeTotalBtn setTitle:[_totalArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            [_cashFlowTotalBtn setTitle:[_totalArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            [_financialRatioTotalBtn setTitle:[_totalArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol];
            UInt16 date = [(NSNumber *)[financialRatio1Array objectAtIndex:_financialRatioPostion]intValue];
            [dic setObject:tmpDic forKey:@"incomeValueDict"];
            
            tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol];
            [dic setObject:tmpDic forKey:@"balanceValueDict"];
            [dataModel.financialRatio calculateWithWithIdentSymbol:_identSymbol Index:_financialRatioPostion Data:dic Date:date];
            [dic removeAllObjects];
            
            tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol2];
            date = [(NSNumber *)[financialRatio2Array objectAtIndex:_financialRatioPostion2]intValue];
            [dic setObject:tmpDic forKey:@"incomeValueDict"];
            
            tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol2];
            [dic setObject:tmpDic forKey:@"balanceValueDict"];
            [dataModel.financialRatio calculateWithWithIdentSymbol:_identSymbol2 Index:_financialRatioPostion2 Data:dic Date:date];
            
            [_incomeTableView reloadData];
            [_cashFlowTableView reloadData];
            [_financialRatioTableView reloadData];
        }
        
    }else if ([actionSheet isEqual:_typeActionSheet] && buttonIndex <3){
        _type = (int)buttonIndex;
        NSString * symbol2Name = @"";
        
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        if (buttonIndex==2) {
            _percentLabel.hidden = NO;
            
            if ([group isEqualToString:@"us"])
            {
                symbol2Name = _watchportfolio.portfolioItem->symbol;
                
            }else{
                symbol2Name = _watchportfolio.portfolioItem->fullName;
            }
            
            
            [_balanceStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
            [_incomeStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
            [_cashFlowStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
            [_financialRatioStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
            
            _balanceStock1Btn.hidden = YES;
            _balanceStock2Btn.hidden = YES;
            _incomeStock1Btn.hidden = YES;
            _incomeStock2Btn.hidden = YES;
            _cashFlowStock1Btn.hidden = YES;
            _cashFlowStock2Btn.hidden = YES;
            _financialRatioStock1Btn.hidden = YES;
            _financialRatioStock2Btn.hidden = YES;

        }else{
            if ([group isEqualToString:@"us"])
            {
                symbol2Name = _watchportfolio.comparedPortfolioItem->symbol;
                
            }else{
                symbol2Name = _watchportfolio.comparedPortfolioItem->fullName;
            }
            
            
            [_balanceStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
            [_incomeStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
            [_cashFlowStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
            [_financialRatioStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
        }
        [_balanceTypeBtn setTitle:[_typeArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        [_incomeTypeBtn setTitle:[_typeArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        [_cashFlowTypeBtn setTitle:[_typeArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        [_balanceTableView reloadData];
        [_incomeTableView reloadData];
        [_cashFlowTableView reloadData];
    }else if ([actionSheet isEqual:_group1ActionSheet] && buttonIndex < [balance1Array count]){
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
        UInt16 date;
        if ([_group1Btn isEqual:_balanceGroup1Btn]) {
            _balancePostion = (int)buttonIndex;
            date = [(NSNumber *)[balance1Array objectAtIndex:buttonIndex]intValue];
            NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol];
            [dic setObject:tmpDic forKey:@"incomeValueDict"];

            tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol];
            [dic setObject:tmpDic forKey:@"balanceValueDict"];

            _incomePostion = [self setPostionWithPostion:self.balancePostion SearchArray:balance1Array TargetArray:income1Array];
            _cashFlowPostion = [self setPostionWithPostion:self.balancePostion SearchArray:balance1Array TargetArray:cashFlow1Array];
            _financialRatioPostion = [self setPostionWithPostion:self.balancePostion SearchArray:balance1Array TargetArray:financialRatio1Array];
        }else if ([_group1Btn isEqual:_incomeGroup1Btn] && buttonIndex < [income1Array count]){
            _incomePostion = (int)buttonIndex;
            NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol];
            date = [(NSNumber *)[income1Array objectAtIndex:buttonIndex]intValue];
            [dic setObject:tmpDic forKey:@"incomeValueDict"];
            
            tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol];
            [dic setObject:tmpDic forKey:@"balanceValueDict"];
            
            _balancePostion = [self setPostionWithPostion:self.incomePostion SearchArray:income1Array TargetArray:balance1Array];
            _cashFlowPostion = [self setPostionWithPostion:self.incomePostion SearchArray:income1Array TargetArray:cashFlow1Array];
            _financialRatioPostion = [self setPostionWithPostion:self.incomePostion SearchArray:income1Array TargetArray:financialRatio1Array];
        }else if ([_group1Btn isEqual:_cashFlowGroup1Btn] && buttonIndex < [cashFlow1Array count]){
            self.cashFlowPostion = (int)buttonIndex;
            NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol];
            date = [(NSNumber *)[cashFlow1Array objectAtIndex:buttonIndex]intValue];
            [dic setObject:tmpDic forKey:@"incomeValueDict"];
            
            tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol];
            [dic setObject:tmpDic forKey:@"balanceValueDict"];
            
            self.balancePostion = [self setPostionWithPostion:self.cashFlowPostion SearchArray:cashFlow1Array TargetArray:balance1Array];
            self.incomePostion = [self setPostionWithPostion:self.cashFlowPostion SearchArray:cashFlow1Array TargetArray:income1Array];
            self.financialRatioPostion = [self setPostionWithPostion:self.cashFlowPostion SearchArray:cashFlow1Array TargetArray:financialRatio1Array];

        }else if ([_group1Btn isEqual:_financialRatioGroup1Btn] && buttonIndex < [financialRatio1Array count]){
            self.financialRatioPostion = (int)buttonIndex;
            NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol];
            date = [(NSNumber *)[financialRatio1Array objectAtIndex:buttonIndex]intValue];
            [dic setObject:tmpDic forKey:@"incomeValueDict"];
            
            tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol];
            [dic setObject:tmpDic forKey:@"balanceValueDict"];
            
            self.balancePostion = [self setPostionWithPostion:self.financialRatioPostion SearchArray:financialRatio1Array TargetArray:balance1Array];
            self.incomePostion = [self setPostionWithPostion:self.financialRatioPostion SearchArray:financialRatio1Array TargetArray:income1Array];
            self.cashFlowPostion = [self setPostionWithPostion:self.financialRatioPostion SearchArray:financialRatio1Array TargetArray:cashFlow1Array];
        }
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"us"])
        {
            [self searchDataWithGroup:@"Group1"];
        }else{
            [dataModel.financialRatio calculateWithWithIdentSymbol:_identSymbol Index:_financialRatioPostion Data:dic Date:date];
            [_balanceTableView reloadData];
            [_incomeTableView reloadData];
            [_cashFlowTableView reloadData];
            [_financialRatioTableView reloadData];
        }
        
    }else if ([actionSheet isEqual:_group2ActionSheet]){
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
        UInt16 date;
        if ([_group2Btn isEqual:self.balanceGroup2Btn] && buttonIndex < [balance2Array count]) {
            self.balancePostion2 = (int)buttonIndex;
            NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol2];
            date = [(NSNumber *)[balance2Array objectAtIndex:buttonIndex]intValue];
            [dic setObject:tmpDic forKey:@"incomeValueDict"];
            
            tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol2];
            [dic setObject:tmpDic forKey:@"balanceValueDict"];

            self.incomePostion2 = [self setPostionWithPostion:self.balancePostion2 SearchArray:balance2Array TargetArray:income2Array];
            self.cashFlowPostion2 = [self setPostionWithPostion:self.balancePostion2 SearchArray:balance2Array TargetArray:cashFlow2Array];
            self.financialRatioPostion2 = [self setPostionWithPostion:self.balancePostion2 SearchArray:balance2Array TargetArray:financialRatio2Array];
        }else if ([_group2Btn isEqual:self.incomeGroup2Btn] && buttonIndex < [income2Array count]){
            self.incomePostion2 = (int)buttonIndex;
            NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol2];
            date = [(NSNumber *)[income2Array objectAtIndex:buttonIndex]intValue];
            [dic setObject:tmpDic forKey:@"incomeValueDict"];
            
            tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol2];
            [dic setObject:tmpDic forKey:@"balanceValueDict"];
            
            self.balancePostion2 = [self setPostionWithPostion:self.incomePostion2 SearchArray:income2Array TargetArray:balance2Array];
            self.cashFlowPostion2 = [self setPostionWithPostion:self.incomePostion2 SearchArray:income2Array TargetArray:cashFlow2Array];
            self.financialRatioPostion2 = [self setPostionWithPostion:self.incomePostion2 SearchArray:income2Array TargetArray:financialRatio2Array];
        }else if ([_group2Btn isEqual:self.cashFlowGroup2Btn] && buttonIndex < [cashFlow2Array count]){
            self.cashFlowPostion2 = (int)buttonIndex;
            NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol2];
            date = [(NSNumber *)[cashFlow2Array objectAtIndex:buttonIndex]intValue];
            [dic setObject:[tmpDic objectForKey:@"valueDict"] forKey:@"incomeValueDict"];
            [dic setObject:[tmpDic objectForKey:@"unitDict"] forKey:@"incomeUnitDict"];
            
            tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol2];
            [dic setObject:tmpDic forKey:@"balanceValueDict"];
            
            self.balancePostion2 = [self setPostionWithPostion:self.cashFlowPostion2 SearchArray:cashFlow2Array TargetArray:balance2Array];
            self.incomePostion2 = [self setPostionWithPostion:self.cashFlowPostion2 SearchArray:cashFlow2Array TargetArray:income2Array];
            self.financialRatioPostion2 = [self setPostionWithPostion:self.cashFlowPostion2 SearchArray:cashFlow2Array TargetArray:financialRatio2Array];
        }else if ([_group2Btn isEqual:self.financialRatioGroup2Btn] && buttonIndex < [financialRatio2Array count]){
            self.financialRatioPostion2 = (int)buttonIndex;
            NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol2];
            date = [(NSNumber *)[financialRatio2Array objectAtIndex:buttonIndex]intValue];
            [dic setObject:tmpDic forKey:@"incomeValueDict"];
            
            tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol2];
            [dic setObject:tmpDic forKey:@"balanceValueDict"];
            
            self.balancePostion2 = [self setPostionWithPostion:self.financialRatioPostion2 SearchArray:financialRatio2Array TargetArray:balance2Array];
            self.incomePostion2 = [self setPostionWithPostion:self.financialRatioPostion2 SearchArray:financialRatio2Array TargetArray:income2Array];
            self.cashFlowPostion2 = [self setPostionWithPostion:self.financialRatioPostion2 SearchArray:financialRatio2Array TargetArray:cashFlow2Array];
        }
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"us"])
        {
            [self searchDataWithGroup:@"Group2"];
        }else{
            [dataModel.financialRatio calculateWithWithIdentSymbol:_identSymbol2 Index:_financialRatioPostion2 Data:dic Date:date];
            [_balanceTableView reloadData];
            [_incomeTableView reloadData];
            [_cashFlowTableView reloadData];
            [_financialRatioTableView reloadData];
        }
    }
}

-(void)searchDataWithGroup:(NSString *)gp{
    
    if ([gp isEqualToString:@"Group1"]) {
        [symbol1Dic removeAllObjects];
        if (_balancePostion < [balance1Array count]) {
            [self searchWithIds:[_watchportfolio.portfolioItem getIdentCodeSymbol] ReportType:@"BalanceSheet" date:[(NSNumber *)[balance1Array objectAtIndex:_balancePostion] intValue] dataDic:symbol1Dic];
        }
        if (_incomePostion < [income1Array count]) {
            [self searchWithIds:[_watchportfolio.portfolioItem getIdentCodeSymbol] ReportType:@"IncomeStatement" date:[(NSNumber *)[income1Array objectAtIndex:_incomePostion] intValue] dataDic:symbol1Dic];
        }
        if (_cashFlowPostion < [cashFlow1Array count]) {
            [self searchWithIds:[_watchportfolio.portfolioItem getIdentCodeSymbol] ReportType:@"CashFlow" date:[(NSNumber *)[cashFlow1Array objectAtIndex:_cashFlowPostion] intValue] dataDic:symbol1Dic];
        }
        if (_financialRatioPostion < [financialRatio1Array count]) {
            [self searchWithIds:[_watchportfolio.portfolioItem getIdentCodeSymbol] ReportType:@"FinancialRatio" date:[(NSNumber *)[financialRatio1Array objectAtIndex:_financialRatioPostion] intValue] dataDic:symbol1Dic];
        }
    }else if ([gp isEqualToString:@"Group2"]){
        [symbol2Dic removeAllObjects];
        if (_balancePostion2 < [balance2Array count]) {
            [self searchWithIds:_identSymbol2 ReportType:@"BalanceSheet" date:[(NSNumber *)[balance2Array objectAtIndex:_balancePostion2] intValue] dataDic:symbol2Dic];
        }
        if (_incomePostion2 < [income2Array count]) {
            [self searchWithIds:_identSymbol2 ReportType:@"IncomeStatement" date:[(NSNumber *)[income2Array objectAtIndex:_incomePostion2] intValue] dataDic:symbol2Dic];
        }
        if (_cashFlowPostion2 < [cashFlow2Array count]) {
            [self searchWithIds:_identSymbol2 ReportType:@"CashFlow" date:[(NSNumber *)[cashFlow2Array objectAtIndex:_cashFlowPostion2] intValue] dataDic:symbol2Dic];
        }
        if (_financialRatioPostion2 < [financialRatio2Array count]) {
            [self searchWithIds:_identSymbol2 ReportType:@"FinancialRatio" date:[(NSNumber *)[financialRatio2Array objectAtIndex:_financialRatioPostion2] intValue] dataDic:symbol2Dic];
        }
        
    }
    [self.balanceView hideHUD];
    [self.incomeView hideHUD];
    [self.cashFlowView hideHUD];
    [self.financialRatioView hideHUD];
    [_balanceTableView reloadData];
    [_incomeTableView reloadData];
    [_cashFlowTableView reloadData];
    [_financialRatioTableView reloadData];
}

-(void)searchWithIds:(NSString *)ids ReportType:(NSString *)rt date:(UInt16)date dataDic:(NSMutableDictionary *)dic{
    UInt16 bDay = 0;
    UInt16 eDay = 0;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM"];
    NSString * month =[dateFormat stringFromDate:[[NSNumber numberWithUnsignedInt:date]uint16ToDate ]];
    [dateFormat setDateFormat:@"yyyy"];
    NSString *year = [dateFormat stringFromDate:[[NSNumber numberWithUnsignedInt:date]uint16ToDate ]];

    [dateFormat setDateFormat:@"yyyy/MM/dd"];
    if ([month intValue]==3) {
        bDay = [[dateFormat dateFromString:[NSString stringWithFormat:@"%@/03/01",year]]uint16Value];
        eDay = [[dateFormat dateFromString:[NSString stringWithFormat:@"%@/03/31",year]]uint16Value];
        
    }else if ([month intValue]==6){
        bDay = [[dateFormat dateFromString:[NSString stringWithFormat:@"%@/06/01",year]]uint16Value];
        eDay = [[dateFormat dateFromString:[NSString stringWithFormat:@"%@/06/30",year]]uint16Value];
    }else if ([month intValue]==9){
        bDay = [[dateFormat dateFromString:[NSString stringWithFormat:@"%@/09/01",year]]uint16Value];
        eDay = [[dateFormat dateFromString:[NSString stringWithFormat:@"%@/09/30",year]]uint16Value];
    }else if ([month intValue]==12){
        bDay = [[dateFormat dateFromString:[NSString stringWithFormat:@"%@/12/01",year]]uint16Value];
        eDay = [[dateFormat dateFromString:[NSString stringWithFormat:@"%@/12/31",year]]uint16Value];
    }
    
    
    [dic setObject:[dataModel.financeReportUS searchFinanceDataWithIdentCodeSymbol:ids StartDay:bDay EndDay:eDay ReportType:rt] forKey:rt];
}

-(void)totalBtnClick:(FSUIButton*)btn{
    _totalActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"選擇顯示類型", @"Equity", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Equity", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"累計", @"Equity", nil),NSLocalizedStringFromTable(@"單季", @"Equity", nil),nil];
    
    [self showActionSheet:_totalActionSheet];
}

-(void)typeBtnClick:(FSUIButton*)btn{
    _typeActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"選擇顯示類型", @"Equity", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Equity", nil) destructiveButtonTitle:nil otherButtonTitles:@"$",@"%",@"$+%",nil];
    
    [self showActionSheet:_typeActionSheet];
    int count = [dataModel.balanceSheet getDateCountByIdentSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
    
    if (count>0) {
        self.symbol1EndDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol Postion:0];
        self.symbol1BeginDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol Postion:count-1];
        if (count>8) {
            count =8;
            self.symbol1BeginDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol Postion:7];
        }
        for(int i=0 ; i<count ; i++){
            [balance1Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol Postion:i]]];
        }
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
            balance2Array = balance1Array;
        }
    }
    [balance2Array removeAllObjects];
    int count2 = [dataModel.balanceSheet getDateCountByIdentSymbol:_identSymbol2];
    
    if (count2>0) {
        self.symbol2EndDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol2 Postion:0];
        self.symbol2BeginDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol2 Postion:count2-1];
        if (count2>8) {
            count2 =8;
            self.symbol2BeginDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol2 Postion:7];
        }
        for(int i=0 ; i<count2 ; i++){
            [balance2Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol2 Postion:i]]];
        }
    }
    [_balanceTableView reloadData];
    
    [income1Array removeAllObjects];
    count = [dataModel.income getDateCountByIdentSymbol:_identSymbol];
    if (count>0) {
        if (count>8) {
            count =8;
        }
        for(int i=0 ; i<count ; i++){
            [income1Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.income findDateByIdentSymbol:_identSymbol Postion:i]]];
        }
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
            income2Array = income1Array;
        }
    }
    [income2Array removeAllObjects];
    count = [dataModel.income getDateCountByIdentSymbol:_identSymbol2];
    if (count>0) {
        if (count>8) {
            count =8;
        }
        for(int i=0 ; i<count ; i++){
            [income2Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.income findDateByIdentSymbol:_identSymbol2 Postion:i]]];
        }
    }
    [_incomeTableView reloadData];
    
    
    [cashFlow1Array removeAllObjects];
    count = [dataModel.cashFlow getDateCountByIdentSymbol:_identSymbol];
    if (count>0) {
        if (count>8) {
            count =8;
        }
        for(int i=0 ; i<count ; i++){
            [cashFlow1Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.cashFlow findDateByIdentSymbol:_identSymbol Postion:i]]];
        }
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
            cashFlow2Array = cashFlow1Array;
        }
    }
    [cashFlow2Array removeAllObjects];
    count = [dataModel.cashFlow getDateCountByIdentSymbol:_identSymbol2];
    if (count>0) {
        if (count>8) {
            count =8;
        }
        for(int i=0 ; i<count ; i++){
            [cashFlow2Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.cashFlow findDateByIdentSymbol:_identSymbol2 Postion:i]]];
        }
    }
    [_cashFlowTableView reloadData];
}

-(void)mergeBtnClick:(FSUIButton*)btn{
//    BOOL mergeBool = !btn.selected;
    BOOL mergeBool = YES;
    _balanceMergeBtn.selected = mergeBool;
    _incomeMergeBtn.selected = mergeBool;
    _cashFlowMergeBtn.selected = mergeBool;
    _financialRatioMergeBtn.selected = mergeBool;
    dataModel.balanceSheet.merge = btn.selected;
    dataModel.income.merge = btn.selected;
    dataModel.cashFlow.merge = btn.selected;
    dataModel.financialRatio.merge = btn.selected;
    [balance1Array removeAllObjects];
    int count = [dataModel.balanceSheet getDateCountByIdentSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol]];
    
    if (count>0) {
        self.symbol1EndDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol Postion:0];
        self.symbol1BeginDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol Postion:count-1];
        if (count>8) {
            count =8;
            self.symbol1BeginDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol Postion:7];
        }
        for(int i=0 ; i<count ; i++){
            [balance1Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol Postion:i]]];
        }
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
            balance2Array = balance1Array;
        }
    }
    [balance2Array removeAllObjects];
    int count2 = [dataModel.balanceSheet getDateCountByIdentSymbol:_identSymbol2];
    
    if (count2>0) {
        self.symbol2EndDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol2 Postion:0];
        self.symbol2BeginDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol2 Postion:count2-1];
        if (count2>8) {
            count2 =8;
            self.symbol2BeginDate =[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol2 Postion:7];
        }
        for(int i=0 ; i<count2 ; i++){
            [balance2Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.balanceSheet findDateByIdentSymbol:_identSymbol2 Postion:i]]];
        }
    }
    [_balanceTableView reloadData];
    
    [income1Array removeAllObjects];
    count = [dataModel.income getDateCountByIdentSymbol:_identSymbol];
    if (count>0) {
        if (count>8) {
            count =8;
        }
        for(int i=0 ; i<count ; i++){
            [income1Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.income findDateByIdentSymbol:_identSymbol Postion:i]]];
        }
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
            income2Array = income1Array;
        }
    }
    [income2Array removeAllObjects];
    count = [dataModel.income getDateCountByIdentSymbol:_identSymbol2];
    if (count>0) {
        if (count>8) {
            count =8;
        }
        for(int i=0 ; i<count ; i++){
            [income2Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.income findDateByIdentSymbol:_identSymbol2 Postion:i]]];
        }
    }
    [_incomeTableView reloadData];
    
    
    [cashFlow1Array removeAllObjects];
    count = [dataModel.cashFlow getDateCountByIdentSymbol:_identSymbol];
    if (count>0) {
        if (count>8) {
            count =8;
        }
        for(int i=0 ; i<count ; i++){
            [cashFlow1Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.cashFlow findDateByIdentSymbol:_identSymbol Postion:i]]];
        }
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
            cashFlow2Array = cashFlow1Array;
        }
    }
    [cashFlow2Array removeAllObjects];
    count = [dataModel.cashFlow getDateCountByIdentSymbol:_identSymbol2];
    if (count>0) {
        if (count>8) {
            count =8;
        }
        for(int i=0 ; i<count ; i++){
            [cashFlow2Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.cashFlow findDateByIdentSymbol:_identSymbol2 Postion:i]]];
        }
    }
    [_cashFlowTableView reloadData];
    
    [financialRatio1Array removeAllObjects];
    count = [dataModel.financialRatio getDateCountByIdentSymbol:_identSymbol];
    if (count>0) {
        if (count>8) {
            count =8;
        }
        for(int i=0 ; i<count ; i++){
            [financialRatio1Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.financialRatio findDateByIdentSymbol:_identSymbol Postion:i]]];
        }
        if ([[_watchportfolio.portfolioItem getIdentCodeSymbol] isEqualToString:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]] || !_twoStock) {
            financialRatio2Array = financialRatio1Array;
        }
    }
    [financialRatio2Array removeAllObjects];
    count = [dataModel.financialRatio getDateCountByIdentSymbol:_identSymbol2];
    if (count>0) {
        if (count>8) {
            count =8;
        }
        for(int i=0 ; i<count ; i++){
            [financialRatio2Array addObject:[NSNumber numberWithUnsignedInt:[dataModel.financialRatio findDateByIdentSymbol:_identSymbol2 Postion:i]]];
        }
    }
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol];

    [dic setObject:tmpDic forKey:@"incomeValueDict"];
    
    tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol];
    [dic setObject:tmpDic forKey:@"balanceValueDict"];

    if (_financialRatioPostion <[financialRatio1Array count]){
        [dataModel.financialRatio calculateWithWithIdentSymbol:_identSymbol Index:_financialRatioPostion Data:dic Date:[(NSNumber *)[financialRatio1Array objectAtIndex:_financialRatioPostion]intValue]];
    }
    
    
    [dic removeAllObjects];
    
    tmpDic = [dataModel.income getDataDictionaryWithIdentSymbol:_identSymbol2];
    [dic setObject:tmpDic forKey:@"incomeValueDict"];
    
    tmpDic = [dataModel.balanceSheet getDataDictionaryWithIdentSymbol:_identSymbol2 ];
    [dic setObject:tmpDic forKey:@"balanceValueDict"];
    if (_financialRatioPostion2 < [financialRatio2Array count]) {
        [dataModel.financialRatio calculateWithWithIdentSymbol:_identSymbol2 Index:_financialRatioPostion2 Data:dic Date:[(NSNumber *)[financialRatio2Array objectAtIndex:_financialRatioPostion2]intValue]];
    }
    
    [_financialRatioTableView reloadData];
}

-(void)group1BtnClickWithButton:(FSUIButton *)btn{
    _group1Btn = btn;
    NSMutableArray * array = [[NSMutableArray alloc]init];
    if ([btn isEqual:_balanceGroup1Btn]) {
        array = balance1Array;
    }else if ([btn isEqual:_incomeGroup1Btn]){
        array = income1Array;
    }else if([btn isEqual:_cashFlowGroup1Btn]){
        array = cashFlow1Array;
    }else if ([btn isEqual:_financialRatioGroup1Btn]){
        array = financialRatio1Array;
    }

    _group1ActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"選擇日期", @"Equity", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    PortfolioItem * item = _watchportfolio.portfolioItem;
    int i;
    for (i=0;i<[array count];i++){
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy"];
        NSString *year = [dateFormat stringFromDate:[[array objectAtIndex:i] uint16ToDate]];
        [dateFormat setDateFormat:@"MM"];
        NSString * month =[dateFormat stringFromDate:[[array objectAtIndex:i] uint16ToDate]];
        NSString * Q = [self dateToQuarter:month];
        if (item->identCode[0]=='T' && item->identCode[1]=='W') {
            
            NSString * dateString = [NSString stringWithFormat:@"%d-%@",[year intValue]-1911,Q];
            [_group1ActionSheet addButtonWithTitle:dateString];
        }else{
            NSString * dateString = [NSString stringWithFormat:@"%@/%d",Q,[year intValue]];
            [_group1ActionSheet addButtonWithTitle:dateString];
        }
        
        
    }
    [_group1ActionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Equity", nil)];
    [_group1ActionSheet setCancelButtonIndex:i];
    [self showActionSheet:_group1ActionSheet];
}

-(NSString *)dateToQuarter:(NSString *)month{
    NSString * q;
    if([month isEqualToString:@"03"]){
        q = @"Q1";
    }else if([month isEqualToString:@"06"]){
        q = @"Q2";
    }else if([month isEqualToString:@"09"]){
        q = @"Q3";
    }else if([month isEqualToString:@"12"]){
        q = @"Q4";
    }
    return q;
}

-(void)group2BtnClickWithButton:(FSUIButton *)btn{
    _group2Btn = btn;
    NSMutableArray * array = [[NSMutableArray alloc]init];
    if ([btn isEqual:_balanceGroup2Btn]) {
        array = balance2Array;
    }else if ([btn isEqual:_incomeGroup2Btn]){
        array = income2Array;
    }else if([btn isEqual:_cashFlowGroup2Btn]){
        array = cashFlow2Array;
    }else if ([btn isEqual:_financialRatioGroup2Btn]){
        array = financialRatio2Array;
    }
    _group2ActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"選擇日期", @"Equity", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    int i;
    PortfolioItem * item = _watchportfolio.portfolioItem;

    for (i=0;i<[array count];i++){
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy"];
        NSString *year = [dateFormat stringFromDate:[[array objectAtIndex:i] uint16ToDate]];
        [dateFormat setDateFormat:@"MM"];
        NSString * month =[dateFormat stringFromDate:[[array objectAtIndex:i] uint16ToDate]];
        NSString * Q = [self dateToQuarter:month];
        if (item->identCode[0]=='T' && item->identCode[1]=='W') {
            
            NSString * dateString = [NSString stringWithFormat:@"%d-%@",[year intValue]-1911,Q];
            [_group2ActionSheet addButtonWithTitle:dateString];
        }else{
            NSString * dateString = [NSString stringWithFormat:@"%@/%d",Q,[year intValue]];
            [_group2ActionSheet addButtonWithTitle:dateString];
        }
    }
    [_group2ActionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Equity", nil)];
    [_group2ActionSheet setCancelButtonIndex:i];
    [self showActionSheet:_group2ActionSheet];
}

- (void)setLayout {
    PortfolioItem * item = _watchportfolio.portfolioItem;
    NSNumber * heigh =[NSNumber numberWithFloat: self.view.frame.size.height - 245];
    NSNumber * width = [NSNumber numberWithFloat:self.view.frame.size.width];
    NSNumber * viewHeigh =[NSNumber numberWithFloat: self.view.frame.size.height - 122];
    NSDictionary *metrics = @{@"TableView":heigh,@"contantSize":width,@"viewH":viewHeigh};
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_scrollView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]-22-|" options:0 metrics:nil views:viewControllers]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[balanceView(viewH)]" options:0 metrics:metrics views:_dictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[incomeView(viewH)]" options:0 metrics:metrics views:_dictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cashFlowView(viewH)]" options:0 metrics:metrics views:_dictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[financialRatioView(viewH)]" options:0 metrics:metrics views:_dictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[balanceView(contantSize)][incomeView(contantSize)][cashFlowView(contantSize)][financialRatioView(contantSize)]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:_dictionary]];
    
    //資產負債表
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[balanceTitleLabel(40)]-2-[balanceTwoStockBtn(40)]-3-[_balanceTableView][balanceUnitLabel(32)]|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:_dictionary]];
    
    
    if (item->identCode[0] == 'T' && item->identCode[1] == 'W') {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[balanceTitleLabel(100)][balanceMergeBtn(40)][mergeTitleLabel(35)][balanceTypeBtn(70)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[balanceMergeBtn(40)]" options:0 metrics:nil views:_dictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[mergeTitleLabel(40)]" options:0 metrics:nil views:_dictionary]];
    }else{
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[balanceTitleLabel(175)][balanceTypeBtn(70)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];
    }
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[balanceTypeBtn(40)]" options:0 metrics:nil views:_dictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_balanceTableView]|" options:0 metrics:nil views:_dictionary]];
    
    


    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[balanceUnitLabel(300)]" options:0 metrics:nil views:_dictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[balanceTwoStockBtn(40)][balanceTwoStockLabel(90)]-2-[balanceStock1Btn(90)]-2-[balanceStock2Btn(90)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[balanceStock1Btn(40)]" options:0 metrics:nil views:_dictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[balanceStock2Btn(40)]" options:0 metrics:nil views:_dictionary]];
    
    //損益表
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[incomeTitleLabel(40)]-2-[incomeTwoStockBtn(40)]-3-[_incomeTableView][incomeUnitLabel(32)]|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:_dictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_incomeTableView]|" options:0 metrics:nil views:_dictionary]];
    
    if (item->identCode[0] == 'T' && item->identCode[1] == 'W') {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[incomeTitleLabel(100)][incomeMergeBtn(40)][incomeMergeTitleLabel(35)][incomeTypeBtn(68)]-5-[incomeTotalBtn(68)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[incomeMergeBtn(40)]" options:0 metrics:nil views:_dictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[incomeMergeTitleLabel(40)]" options:0 metrics:nil views:_dictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[incomeTotalBtn(40)]" options:0 metrics:nil views:_dictionary]];
    }else{
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[incomeTitleLabel(175)][incomeTypeBtn(70)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[incomeTypeBtn(40)]" options:0 metrics:nil views:_dictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[incomeUnitLabel(300)]" options:0 metrics:nil views:_dictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[incomeTwoStockBtn(40)][incomeTwoStockLabel(90)]-2-[incomeStock1Btn(90)]-2-[incomeStock2Btn(90)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[incomeStock1Btn(40)]" options:0 metrics:nil views:_dictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[incomeStock2Btn(40)]" options:0 metrics:nil views:_dictionary]];
    
    //現金流量表
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cashFlowTitleLabel(40)]-2-[cashFlowTwoStockBtn(40)]-3-[_cashFlowTableView][cashFlowUnitLabel(32)]|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:_dictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cashFlowTableView]|" options:0 metrics:nil views:_dictionary]];
    
    if (item->identCode[0] == 'T' && item->identCode[1] == 'W') {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cashFlowTitleLabel(100)][cashFlowMergeBtn(40)][cashFlowMergeTitleLabel(35)][cashFlowTypeBtn(68)]-5-[cashFlowTotalBtn(68)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cashFlowMergeBtn(40)]" options:0 metrics:nil views:_dictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cashFlowMergeTitleLabel(40)]" options:0 metrics:nil views:_dictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cashFlowTotalBtn(40)]" options:0 metrics:nil views:_dictionary]];
    }else{
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cashFlowTitleLabel(175)][cashFlowTypeBtn(70)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];
    }
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cashFlowTypeBtn(40)]" options:0 metrics:nil views:_dictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cashFlowUnitLabel(300)]" options:0 metrics:nil views:_dictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cashFlowTwoStockBtn(40)][cashFlowTwoStockLabel(90)]-2-[cashFlowStock1Btn(90)]-2-[cashFlowStock2Btn(90)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cashFlowStock1Btn(40)]" options:0 metrics:nil views:_dictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cashFlowStock2Btn(40)]" options:0 metrics:nil views:_dictionary]];
    
    //財務比率
    
    if (item->identCode[0] == 'T' && item->identCode[1] == 'W') {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[financialRatioTitleLabel(100)][financialRatioMergeBtn(40)][financialRatioMergeTitleLabel(35)]-70-[financialRatioTotalBtn(70)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[financialRatioMergeBtn(40)]" options:0 metrics:nil views:_dictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[financialRatioMergeTitleLabel(40)]" options:0 metrics:nil views:_dictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[financialRatioTotalBtn(40)]" options:0 metrics:nil views:_dictionary]];
    }else{
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[financialRatioTitleLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];
    }
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[financialRatioTitleLabel(40)]-2-[financialRatioTwoStockBtn(40)]-3-[_financialRatioTableView][financialRatioUnitLabel(32)]|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:_dictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_financialRatioTableView]|" options:0 metrics:nil views:_dictionary]];
    
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[financialRatioUnitLabel(300)]" options:0 metrics:nil views:_dictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[financialRatioTwoStockBtn(40)][financialRatioTwoStockLabel(90)]-2-[financialRatioStock1Btn(90)]-2-[financialRatioStock2Btn(90)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[financialRatioStock1Btn(40)]" options:0 metrics:nil views:_dictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[financialRatioStock2Btn(40)]" options:0 metrics:nil views:_dictionary]];
    
}

- (void)viewDidLayoutSubviews {
    [self.scrollView setContentSize: CGSizeMake(self.scrollView.bounds.size.width * self.numberOfPages, self.scrollView.bounds.size.height)];
    
    [self.pageControl setFrame:CGRectMake(self.scrollView.center.x, self.view.bounds.size.height - 10, self.pageControl.frame.size.width, 30)];
    [self.pageControl setCenter:CGPointMake(self.scrollView.center.x, self.view.bounds.size.height - 10)];

    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"FinanceMemory.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if(!_isProtectType){
        self.type = [[_mainDict objectForKey:@"searchType"] intValue];
        self.isProtectType = YES;
    }
    if(_mainDict){
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * [[_mainDict objectForKey:@"FinanceNumber"]intValue], 0);
    }else{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * 0, 0);
    }
    
    [self.view layoutSubviews];
    
    
}

-(void)initTitle{
    
    [self initBalanceTitle];
    [self initIncomeTitle];
    [self initCashFlowTitle];
    [self initFinancialRatioTitle];
    
}

-(void)initBalanceTitle{
    UILabel * balanceTitleLabel = [[UILabel alloc]init];
    balanceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    balanceTitleLabel.text = NSLocalizedStringFromTable(@"資產負債表", @"Equity", nil);
    balanceTitleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    balanceTitleLabel.textColor = [UIColor brownColor];
    [_dictionary setObject:balanceTitleLabel forKey:@"balanceTitleLabel"];
    [_balanceView addSubview:balanceTitleLabel];
    
    PortfolioItem * item = _watchportfolio.portfolioItem;
    if (item->identCode[0] == 'T' && item->identCode[1]=='W') {
        self.balanceMergeBtn = [[FSUIButton alloc]initWithButtonType: FSUIButtonTypeCheckBox];
        _balanceMergeBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _balanceMergeBtn.selected = NO;
        [_dictionary setObject:_balanceMergeBtn forKey:@"balanceMergeBtn"];
        [_balanceView addSubview:_balanceMergeBtn];
        [_balanceMergeBtn addTarget:self action:@selector(mergeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
        UILabel * mergeTitleLabel = [[UILabel alloc]init];
        mergeTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        mergeTitleLabel.text = NSLocalizedStringFromTable(@"合併", @"Equity", nil);
        mergeTitleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        mergeTitleLabel.hidden = YES;
        [_dictionary setObject:mergeTitleLabel forKey:@"mergeTitleLabel"];
        [_balanceView addSubview:mergeTitleLabel];
    }
    
    self.balanceTypeBtn = [[FSUIButton alloc]initWithButtonType: FSUIButtonTypeBlueGreenDetailButton];
    _balanceTypeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_balanceTypeBtn setTitle:[_typeArray objectAtIndex:_type] forState:UIControlStateNormal];
    [_dictionary setObject:_balanceTypeBtn forKey:@"balanceTypeBtn"];
    [_balanceView addSubview:_balanceTypeBtn];
    [_balanceTypeBtn addTarget:self action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    balanceTwoStockBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    [balanceTwoStockBtn setImage:[UIImage imageNamed:@"tachart_doubleline"] forState:UIControlStateNormal];
    balanceTwoStockBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [balanceTwoStockBtn addTarget:self action:@selector(twoStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dictionary setObject:balanceTwoStockBtn forKey:@"balanceTwoStockBtn"];
    [_balanceView addSubview:balanceTwoStockBtn];
    
    UILabel * balanceTwoStockLabel = [[UILabel alloc]init];
    balanceTwoStockLabel.translatesAutoresizingMaskIntoConstraints = NO;
    balanceTwoStockLabel.text = NSLocalizedStringFromTable(@"兩檔比較", @"Equity", nil);
    balanceTwoStockLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    balanceTwoStockLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:135.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    balanceTwoStockLabel.adjustsFontSizeToFitWidth = YES;
    [_dictionary setObject:balanceTwoStockLabel forKey:@"balanceTwoStockLabel"];
    [_balanceView addSubview:balanceTwoStockLabel];
    
    self.balanceStock1Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _balanceStock1Btn.translatesAutoresizingMaskIntoConstraints = NO;
    _balanceStock1Btn.hidden = !_twoStock;
    _balanceStock1Btn.tag = 0;
    [_balanceStock1Btn addTarget:self action:@selector(changeStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dictionary setObject:_balanceStock1Btn forKey:@"balanceStock1Btn"];
    [_balanceView addSubview:_balanceStock1Btn];
    
    self.balanceStock2Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _balanceStock2Btn.translatesAutoresizingMaskIntoConstraints = NO;
    [_dictionary setObject:_balanceStock2Btn forKey:@"balanceStock2Btn"];
    _balanceStock2Btn.hidden = !_twoStock;
    _balanceStock2Btn.tag = 1;
    [_balanceStock2Btn addTarget:self action:@selector(changeStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_balanceView addSubview:_balanceStock2Btn];
    
    UILabel * balanceUnitLabel = [[UILabel alloc]init];
    balanceUnitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    balanceUnitLabel.text = NSLocalizedStringFromTable(@"單位：百萬", @"Equity", nil);
    balanceUnitLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_dictionary setObject:balanceUnitLabel forKey:@"balanceUnitLabel"];
    [_balanceView addSubview:balanceUnitLabel];
}

-(void)initIncomeTitle{
    UILabel * incomeTitleLabel = [[UILabel alloc]init];
    incomeTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    incomeTitleLabel.text = NSLocalizedStringFromTable(@"損益表", @"Equity", nil);
    incomeTitleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    incomeTitleLabel.textColor = [UIColor brownColor];
    [_dictionary setObject:incomeTitleLabel forKey:@"incomeTitleLabel"];
    [_incomeView addSubview:incomeTitleLabel];
    
    
    PortfolioItem * item = _watchportfolio.portfolioItem;
    if (item->identCode[0] == 'T' && item->identCode[1]=='W') {
        self.incomeMergeBtn = [[FSUIButton alloc]initWithButtonType: FSUIButtonTypeCheckBox];
        _incomeMergeBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _incomeMergeBtn.selected = NO;
        [_dictionary setObject:_incomeMergeBtn forKey:@"incomeMergeBtn"];
        [_incomeView addSubview:_incomeMergeBtn];
        [_incomeMergeBtn addTarget:self action:@selector(mergeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel * incomeMergeTitleLabel = [[UILabel alloc]init];
        incomeMergeTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        incomeMergeTitleLabel.text = NSLocalizedStringFromTable(@"合併", @"Equity", nil);
        incomeMergeTitleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        incomeMergeTitleLabel.hidden = YES;
        [_dictionary setObject:incomeMergeTitleLabel forKey:@"incomeMergeTitleLabel"];
        [_balanceView addSubview:incomeMergeTitleLabel];
        self.incomeTotalBtn = [[FSUIButton alloc]initWithButtonType: FSUIButtonTypeBlueGreenDetailButton];
        _incomeTotalBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_incomeTotalBtn setTitle:NSLocalizedStringFromTable(@"單季", @"Equity", nil) forState:UIControlStateNormal];
        _incomeTotalBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_dictionary setObject:_incomeTotalBtn forKey:@"incomeTotalBtn"];
        [_incomeTotalBtn addTarget:self action:@selector(totalBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_incomeView addSubview:_incomeTotalBtn];
    }
    
    
    self.incomeTypeBtn = [[FSUIButton alloc]initWithButtonType: FSUIButtonTypeBlueGreenDetailButton];
    _incomeTypeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_incomeTypeBtn setTitle:[_typeArray objectAtIndex:_type] forState:UIControlStateNormal];
    
    [_dictionary setObject:_incomeTypeBtn forKey:@"incomeTypeBtn"];
    [_incomeView addSubview:_incomeTypeBtn];
    [_incomeTypeBtn addTarget:self action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    incomeTwoStockBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    [incomeTwoStockBtn setImage:[UIImage imageNamed:@"tachart_doubleline"] forState:UIControlStateNormal];
    incomeTwoStockBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [incomeTwoStockBtn addTarget:self action:@selector(twoStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dictionary setObject:incomeTwoStockBtn forKey:@"incomeTwoStockBtn"];
    [_incomeView addSubview:incomeTwoStockBtn];
    
    UILabel * incomeTwoStockLabel = [[UILabel alloc]init];
    incomeTwoStockLabel.translatesAutoresizingMaskIntoConstraints = NO;
    incomeTwoStockLabel.text = NSLocalizedStringFromTable(@"兩檔比較", @"Equity", nil);
    incomeTwoStockLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    incomeTwoStockLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:135.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    incomeTwoStockLabel.adjustsFontSizeToFitWidth = YES;
    [_dictionary setObject:incomeTwoStockLabel forKey:@"incomeTwoStockLabel"];
    [_incomeView addSubview:incomeTwoStockLabel];
    
    self.incomeStock1Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _incomeStock1Btn.translatesAutoresizingMaskIntoConstraints = NO;
    _incomeStock1Btn.hidden = !_twoStock;
    [_incomeStock1Btn addTarget:self action:@selector(changeStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dictionary setObject:_incomeStock1Btn forKey:@"incomeStock1Btn"];
    [_incomeView addSubview:_incomeStock1Btn];
    
    self.incomeStock2Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _incomeStock2Btn.translatesAutoresizingMaskIntoConstraints = NO;
    [_incomeStock2Btn addTarget:self action:@selector(changeStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dictionary setObject:_incomeStock2Btn forKey:@"incomeStock2Btn"];
    _incomeStock2Btn.hidden = !_twoStock;
    [_incomeView addSubview:_incomeStock2Btn];
    
    self.percentLabel = [[UILabel alloc]init];
    _percentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _percentLabel.text = NSLocalizedStringFromTable(@"比例", @"Equity", nil);
    _percentLabel.textAlignment = NSTextAlignmentCenter;
    [_dictionary setObject:_percentLabel forKey:@"percentLabel"];
    _percentLabel.hidden = YES;
    [_incomeView addSubview:_percentLabel];
    
    UILabel * incomeUnitLabel = [[UILabel alloc]init];
    incomeUnitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    incomeUnitLabel.text = NSLocalizedStringFromTable(@"單位：百萬", @"Equity", nil);
    incomeUnitLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_dictionary setObject:incomeUnitLabel forKey:@"incomeUnitLabel"];
    [_incomeView addSubview:incomeUnitLabel];
}

-(void)initCashFlowTitle{
    UILabel * cashFlowTitleLabel = [[UILabel alloc]init];
    cashFlowTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    cashFlowTitleLabel.text = NSLocalizedStringFromTable(@"現金流量", @"Equity", nil);
    cashFlowTitleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    cashFlowTitleLabel.textColor = [UIColor brownColor];
    [_dictionary setObject:cashFlowTitleLabel forKey:@"cashFlowTitleLabel"];
    [_cashFlowView addSubview:cashFlowTitleLabel];
    
    self.cashFlowTypeBtn = [[FSUIButton alloc]initWithButtonType: FSUIButtonTypeBlueGreenDetailButton];
    _cashFlowTypeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_cashFlowTypeBtn setTitle:[_typeArray objectAtIndex:_type] forState:UIControlStateNormal];
    [_dictionary setObject:_cashFlowTypeBtn forKey:@"cashFlowTypeBtn"];
    [_cashFlowView addSubview:_cashFlowTypeBtn];
    [_cashFlowTypeBtn addTarget:self action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    PortfolioItem * item = _watchportfolio.portfolioItem;
    if (item->identCode[0] == 'T' && item->identCode[1]=='W') {
        self.cashFlowMergeBtn = [[FSUIButton alloc]initWithButtonType: FSUIButtonTypeCheckBox];
        _cashFlowMergeBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _cashFlowMergeBtn.selected = NO;
        [_dictionary setObject:_cashFlowMergeBtn forKey:@"cashFlowMergeBtn"];
        [_cashFlowView addSubview:_cashFlowMergeBtn];
        [_cashFlowMergeBtn addTarget:self action:@selector(mergeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel * cashFlowMergeTitleLabel = [[UILabel alloc]init];
        cashFlowMergeTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        cashFlowMergeTitleLabel.text = NSLocalizedStringFromTable(@"合併", @"Equity", nil);
        cashFlowMergeTitleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        cashFlowMergeTitleLabel.hidden = YES;
        [_dictionary setObject:cashFlowMergeTitleLabel forKey:@"cashFlowMergeTitleLabel"];
        [_cashFlowView addSubview:cashFlowMergeTitleLabel];
        
        self.cashFlowTotalBtn = [[FSUIButton alloc]initWithButtonType: FSUIButtonTypeBlueGreenDetailButton];
        _cashFlowTotalBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_cashFlowTotalBtn setTitle:NSLocalizedStringFromTable(@"單季", @"Equity", nil) forState:UIControlStateNormal];
        _cashFlowTotalBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_dictionary setObject:_cashFlowTotalBtn forKey:@"cashFlowTotalBtn"];
        [_cashFlowTotalBtn addTarget:self action:@selector(totalBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_cashFlowView addSubview:_cashFlowTotalBtn];
    }

    
    cashFlowTwoStockBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    [cashFlowTwoStockBtn setImage:[UIImage imageNamed:@"tachart_doubleline"] forState:UIControlStateNormal];
    cashFlowTwoStockBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [cashFlowTwoStockBtn addTarget:self action:@selector(twoStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dictionary setObject:cashFlowTwoStockBtn forKey:@"cashFlowTwoStockBtn"];
    [_cashFlowView addSubview:cashFlowTwoStockBtn];
    
    UILabel * cashFlowTwoStockLabel = [[UILabel alloc]init];
    cashFlowTwoStockLabel.translatesAutoresizingMaskIntoConstraints = NO;
    cashFlowTwoStockLabel.text = NSLocalizedStringFromTable(@"兩檔比較", @"Equity", nil);
    cashFlowTwoStockLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    cashFlowTwoStockLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:135.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    cashFlowTwoStockLabel.adjustsFontSizeToFitWidth = YES;
    [_dictionary setObject:cashFlowTwoStockLabel forKey:@"cashFlowTwoStockLabel"];
    [_cashFlowView addSubview:cashFlowTwoStockLabel];
    
    self.cashFlowStock1Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _cashFlowStock1Btn.translatesAutoresizingMaskIntoConstraints = NO;
    _cashFlowStock1Btn.hidden = !_twoStock;
    [_cashFlowStock1Btn addTarget:self action:@selector(changeStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dictionary setObject:_cashFlowStock1Btn forKey:@"cashFlowStock1Btn"];
    [_cashFlowView addSubview:_cashFlowStock1Btn];
    
    self.cashFlowStock2Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _cashFlowStock2Btn.translatesAutoresizingMaskIntoConstraints = NO;
    [_cashFlowStock2Btn addTarget:self action:@selector(changeStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dictionary setObject:_cashFlowStock2Btn forKey:@"cashFlowStock2Btn"];
    _cashFlowStock2Btn.hidden = !_twoStock;
    [_cashFlowView addSubview:_cashFlowStock2Btn];
    
    self.percentLabel = [[UILabel alloc]init];
    _percentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _percentLabel.text = NSLocalizedStringFromTable(@"比例", @"Equity", nil);
    _percentLabel.textAlignment = NSTextAlignmentCenter;
    [_dictionary setObject:_percentLabel forKey:@"percentLabel"];
    _percentLabel.hidden = YES;
    [_cashFlowView addSubview:_percentLabel];
    
    UILabel * cashFlowUnitLabel = [[UILabel alloc]init];
    cashFlowUnitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    cashFlowUnitLabel.text = NSLocalizedStringFromTable(@"單位：百萬", @"Equity", nil);
    cashFlowUnitLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_dictionary setObject:cashFlowUnitLabel forKey:@"cashFlowUnitLabel"];
    [_cashFlowView addSubview:cashFlowUnitLabel];

}

-(void)initFinancialRatioTitle{
    UILabel * financialRatioTitleLabel = [[UILabel alloc]init];
    financialRatioTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    financialRatioTitleLabel.text = NSLocalizedStringFromTable(@"財務比率", @"Equity", nil);
    financialRatioTitleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    financialRatioTitleLabel.textColor = [UIColor brownColor];
    [_dictionary setObject:financialRatioTitleLabel forKey:@"financialRatioTitleLabel"];
    [_financialRatioView addSubview:financialRatioTitleLabel];
    
    PortfolioItem * item = _watchportfolio.portfolioItem;
    if (item->identCode[0] == 'T' && item->identCode[1]=='W') {
        self.financialRatioMergeBtn = [[FSUIButton alloc]initWithButtonType: FSUIButtonTypeCheckBox];
        _financialRatioMergeBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _financialRatioMergeBtn.selected = NO;
        [_dictionary setObject:_financialRatioMergeBtn forKey:@"financialRatioMergeBtn"];
        [_financialRatioView addSubview:_financialRatioMergeBtn];
        [_financialRatioMergeBtn addTarget:self action:@selector(mergeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel * financialRatioMergeTitleLabel = [[UILabel alloc]init];
        financialRatioMergeTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        financialRatioMergeTitleLabel.text = NSLocalizedStringFromTable(@"合併", @"Equity", nil);
        financialRatioMergeTitleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        financialRatioMergeTitleLabel.hidden = YES;
        [_dictionary setObject:financialRatioMergeTitleLabel forKey:@"financialRatioMergeTitleLabel"];
        [_financialRatioView addSubview:financialRatioMergeTitleLabel];
        
        self.financialRatioTotalBtn = [[FSUIButton alloc]initWithButtonType: FSUIButtonTypeBlueGreenDetailButton];
        _financialRatioTotalBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_financialRatioTotalBtn setTitle:NSLocalizedStringFromTable(@"單季", @"Equity", nil) forState:UIControlStateNormal];
        _financialRatioTotalBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_dictionary setObject:_financialRatioTotalBtn forKey:@"financialRatioTotalBtn"];
        [_financialRatioTotalBtn addTarget:self action:@selector(totalBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_financialRatioView addSubview:_financialRatioTotalBtn];
    }

    
    financialRatioTwoStockBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    [financialRatioTwoStockBtn setImage:[UIImage imageNamed:@"tachart_doubleline"] forState:UIControlStateNormal];
    financialRatioTwoStockBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [financialRatioTwoStockBtn addTarget:self action:@selector(twoStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dictionary setObject:financialRatioTwoStockBtn forKey:@"financialRatioTwoStockBtn"];
    [_financialRatioView addSubview:financialRatioTwoStockBtn];
    
    UILabel * financialRatioTwoStockLabel = [[UILabel alloc]init];
    financialRatioTwoStockLabel.translatesAutoresizingMaskIntoConstraints = NO;
    financialRatioTwoStockLabel.text = NSLocalizedStringFromTable(@"兩檔比較", @"Equity", nil);
    financialRatioTwoStockLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    financialRatioTwoStockLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:135.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    financialRatioTwoStockLabel.adjustsFontSizeToFitWidth = YES;
    [_dictionary setObject:financialRatioTwoStockLabel forKey:@"financialRatioTwoStockLabel"];
    [_financialRatioView addSubview:financialRatioTwoStockLabel];
    
    self.financialRatioStock1Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _financialRatioStock1Btn.translatesAutoresizingMaskIntoConstraints = NO;
    _financialRatioStock1Btn.hidden = !_twoStock;
    [_financialRatioStock1Btn addTarget:self action:@selector(changeStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dictionary setObject:_financialRatioStock1Btn forKey:@"financialRatioStock1Btn"];
    [_financialRatioView addSubview:_financialRatioStock1Btn];
    
    self.financialRatioStock2Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _financialRatioStock2Btn.translatesAutoresizingMaskIntoConstraints = NO;
    [_financialRatioStock2Btn addTarget:self action:@selector(changeStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dictionary setObject:_financialRatioStock2Btn forKey:@"financialRatioStock2Btn"];
    _financialRatioStock2Btn.hidden = !_twoStock;
    [_financialRatioView addSubview:_financialRatioStock2Btn];
    
    UILabel * financialRatioUnitLabel = [[UILabel alloc]init];
    financialRatioUnitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    financialRatioUnitLabel.text = NSLocalizedStringFromTable(@"單位：百萬", @"Equity", nil);
    financialRatioUnitLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_dictionary setObject:financialRatioUnitLabel forKey:@"financialRatioUnitLabel"];
    [_financialRatioView addSubview:financialRatioUnitLabel];
}

-(void)initTableView{
    
    self.balanceView = [[UIView alloc]init];
    self.balanceView.translatesAutoresizingMaskIntoConstraints = NO;
    [_dictionary setObject:self.balanceView forKey:@"balanceView"];
    [self.scrollView addSubview:_balanceView];
    
    self.incomeView = [[UIView alloc]init];
    self.incomeView.translatesAutoresizingMaskIntoConstraints = NO;
    [_dictionary setObject:self.incomeView forKey:@"incomeView"];
    [self.scrollView addSubview:_incomeView];
    
    self.cashFlowView = [[UIView alloc]init];
    self.cashFlowView.translatesAutoresizingMaskIntoConstraints = NO;
    [_dictionary setObject:self.cashFlowView forKey:@"cashFlowView"];
    [self.scrollView addSubview:_cashFlowView];
    
    self.financialRatioView = [[UIView alloc]init];
    self.financialRatioView.translatesAutoresizingMaskIntoConstraints = NO;
    [_dictionary setObject:self.financialRatioView forKey:@"financialRatioView"];
    [self.scrollView addSubview:_financialRatioView];

    
    self.balanceTableView = [[UITableView alloc]init];
    _balanceTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _balanceTableView.dataSource = self;
    _balanceTableView.delegate = self;
    _balanceTableView.bounces = NO;
    [_dictionary setObject:_balanceTableView forKey:@"_balanceTableView"];
    [_balanceView addSubview:_balanceTableView];
    
    self.incomeTableView = [[UITableView alloc]init];
    _incomeTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _incomeTableView.dataSource = self;
    _incomeTableView.delegate = self;
    _incomeTableView.bounces = NO;
    [_dictionary setObject:_incomeTableView forKey:@"_incomeTableView"];
    [_incomeView addSubview:_incomeTableView];
    
    self.cashFlowTableView = [[UITableView alloc]init];
    _cashFlowTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _cashFlowTableView.dataSource = self;
    _cashFlowTableView.delegate = self;
    _cashFlowTableView.bounces = NO;
    [_dictionary setObject:_cashFlowTableView forKey:@"_cashFlowTableView"];
    [_cashFlowView addSubview:_cashFlowTableView];
    
    self.financialRatioTableView = [[UITableView alloc]init];
    _financialRatioTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _financialRatioTableView.dataSource = self;
    _financialRatioTableView.delegate = self;
    _financialRatioTableView.bounces = NO;
    [_dictionary setObject:_financialRatioTableView forKey:@"_financialRatioTableView"];
    [_financialRatioView addSubview:_financialRatioTableView];
}

- (void)initScrollView {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:_scrollView];
}

- (void)initPageControl {
    // 總頁數
    self.numberOfPages = 4;
    
    self.pageControl = [[DDPageControl alloc] init];
    self.pageControl.numberOfPages = self.numberOfPages;
    
    if (_mainDict) {
        self.pageControl.currentPage = [[_mainDict objectForKey:@"FinanceNumber"] intValue];
    }else{
        self.pageControl.currentPage = 0;
    }
    
    [self.pageControl setDefersCurrentPageDisplay: YES] ;
	[self.pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
	[self.pageControl setOnColor: [UIColor redColor]];
	[self.pageControl setOffColor: [UIColor redColor]];
	[self.pageControl setIndicatorDiameter: 7.0f] ;
	[self.pageControl setIndicatorSpace: 7.0f] ;
    
    [self.view addSubview:self.pageControl];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"])
    {
        if ([tableView isEqual:_balanceTableView]) {
            return [dataModel.financeReportUS.bsKeyArray count];
            
        }else if([tableView isEqual:_incomeTableView]){
            return [dataModel.financeReportUS.isKeyArray count];
            
        }else if([tableView isEqual:_cashFlowTableView]){
            return [dataModel.financeReportUS.cfKeyArray count];
            
        }else if([tableView isEqual:_financialRatioTableView]){
            return [dataModel.financeReportUS.frKeyArray count];
        }

    }else{
        if ([tableView isEqual:_balanceTableView]) {
            return [dataModel.balanceSheet.keyArray count];
            
        }else if([tableView isEqual:_incomeTableView]){
            return [dataModel.income.keyArray count];
            
        }else if([tableView isEqual:_cashFlowTableView]){
            return [dataModel.cashFlow.keyArray count];
            
        }else if([tableView isEqual:_financialRatioTableView]){
            return [dataModel.financialRatio.allKeyArray count];
        }

    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellIdentifier";
    
    FinancialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[FinancialTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.group1Label.textColor = [UIColor blackColor];
    cell.group2Label.textColor = [UIColor blackColor];
    cell.group1Label.text = @"----";
    cell.group2Label.text = @"----";
    
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]){
        NSString * rowName = @"";
        if ([tableView isEqual:_balanceTableView]) {
            NSMutableDictionary * group1DataDic = [symbol1Dic objectForKey:@"BalanceSheet"];
            NSMutableDictionary * group2DataDic = [symbol2Dic objectForKey:@"BalanceSheet"];
            rowName = [dataModel.financeReportUS.bsKeyArray objectAtIndex:indexPath.row];
            cell.titleLabel.text = NSLocalizedStringFromTable(rowName, @"Equity", nil);
            
            if (group1DataDic) {
                if (_type==0) {
                    if ([[group1DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                        cell.group1Label.text = @"----";
                    }else{
                        cell.group1Label.text = [NSString stringWithFormat:@"%.0f",[[group1DataDic objectForKey:rowName] floatValue]/1000000];
                    }
                }else if (_type == 1){
                    float totalAssets = [[group1DataDic objectForKey:@"Total Assets"]floatValue];
                    if ([[group1DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                        cell.group1Label.text = @"----";
                    }else{
                        cell.group1Label.text = [NSString stringWithFormat:@"%.2f%%",[[group1DataDic objectForKey:rowName] floatValue]*100/totalAssets];
                        if ([cell.group1Label.text floatValue]>0){
                            cell.group1Label.text = [NSString stringWithFormat:@"+%@",cell.group1Label.text];
                        }
                    }
                    
                }else{
                    if ([[group1DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                        cell.group1Label.text = @"----";
                    }else{
                        cell.group1Label.text = [NSString stringWithFormat:@"%.0f",[[group1DataDic objectForKey:rowName] floatValue]/1000000];
                    }
                }
                
                
            }
            if (group2DataDic) {
                if (_type==0) {
                    if ([[group2DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]) {
                        cell.group2Label.text = @"----";
                    }else{
                        cell.group2Label.text = [NSString stringWithFormat:@"%.0f",[(NSNumber *)[group2DataDic objectForKey:rowName] floatValue]/1000000];
                    }
                }else if (_type == 1){
                    float totalAssets = [[group2DataDic objectForKey:@"Total Assets"]floatValue];
                    if ([[group2DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                        cell.group2Label.text = @"----";
                    }else{
                        cell.group2Label.text = [NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[group2DataDic objectForKey:rowName] floatValue]*100/totalAssets];
                        if ([cell.group2Label.text floatValue]>0){
                            cell.group2Label.text = [NSString stringWithFormat:@"+%@",cell.group2Label.text];
                        }
                    }
                }else{
                    float totalAssets = [[group1DataDic objectForKey:@"Total Assets"]floatValue];
                    if ([[group1DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                        cell.group2Label.text = @"----";
                    }else{
                        cell.group2Label.text = [NSString stringWithFormat:@"%.2f%%",[[group1DataDic objectForKey:rowName] floatValue]*100/totalAssets];
                        if ([cell.group2Label.text floatValue]>0){
                            cell.group2Label.text = [NSString stringWithFormat:@"+%@",cell.group2Label.text];
                        }
                    }
                }
                
                
                
            }
            
        }else if ([tableView isEqual:_incomeTableView]) {
            NSMutableDictionary * group1DataDic = [symbol1Dic objectForKey:@"IncomeStatement"];
            NSMutableDictionary * group2DataDic = [symbol2Dic objectForKey:@"IncomeStatement"];
            rowName = [dataModel.financeReportUS.isKeyArray objectAtIndex:indexPath.row];
            cell.titleLabel.text = NSLocalizedStringFromTable(rowName, @"Equity", nil);
            if (group1DataDic) {
                if (_type==1) {
                    float totalRevenue = [[group1DataDic objectForKey:@"Total Revenue"]floatValue];
                    if ([[group1DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                        cell.group1Label.text = @"----";
                    }else{
                        cell.group1Label.text = [NSString stringWithFormat:@"%.2f%%",[[group1DataDic objectForKey:rowName] floatValue]*100/totalRevenue];
                        if ([cell.group1Label.text floatValue]>0){
                            cell.group1Label.text = [NSString stringWithFormat:@"+%@",cell.group1Label.text];
                        }
                    }
                    
                }else{
                    if ([[group1DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                        cell.group1Label.text = @"----";
                    }else{
                        cell.group1Label.text = [NSString stringWithFormat:@"%.0f",[[group1DataDic objectForKey:rowName] floatValue]/1000000];
                    }
                }
                if ([cell.group1Label.text floatValue]>0){
                    cell.group1Label.textColor = [StockConstant PriceUpColor];
                }else if ([cell.group1Label.text floatValue]<0){
                    cell.group1Label.textColor = [StockConstant PriceDownColor];
                }else if(![cell.group1Label.text isEqualToString:@"----"]){
                    cell.group1Label.textColor = [UIColor blueColor];
                }
                
            }
            if (group2DataDic) {
                if (_type == 0) {
                    if ([[group2DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]) {
                        cell.group2Label.text = @"----";
                    }else{
                        cell.group2Label.text = [NSString stringWithFormat:@"%.0f",[(NSNumber *)[group2DataDic objectForKey:rowName] floatValue]/1000000];
                    }
                }else if (_type == 1){
                    float totalRevenue = [(NSNumber *)[group2DataDic objectForKey:@"Total Revenue"]floatValue];
                    if ([[group2DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                        cell.group2Label.text = @"----";
                    }else{
                        cell.group2Label.text = [NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[group2DataDic objectForKey:rowName] floatValue]*100/totalRevenue];
                        if ([cell.group2Label.text floatValue]>0){
                            cell.group2Label.text = [NSString stringWithFormat:@"+%@",cell.group2Label.text];
                        }
                    }
                    
                }else{
                    float totalRevenue = [(NSNumber *)[group1DataDic objectForKey:@"Total Revenue"]floatValue];
                    if ([[group1DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                        cell.group2Label.text = @"----";
                    }else{
                        cell.group2Label.text = [NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[group1DataDic objectForKey:rowName] floatValue]*100/totalRevenue];
                        if ([cell.group2Label.text floatValue]>0){
                            cell.group2Label.text = [NSString stringWithFormat:@"+%@",cell.group2Label.text];
                        }
                    }
                }
                
                
                if ([cell.group2Label.text floatValue]>0){
                    cell.group2Label.textColor = [StockConstant PriceUpColor];
                }else if ([cell.group2Label.text floatValue]<0){
                    cell.group2Label.textColor = [StockConstant PriceDownColor];
                }else if(![cell.group2Label.text isEqualToString:@"----"]){
                    cell.group2Label.textColor = [UIColor blueColor];
                }
            }
            
        }else if ([tableView isEqual:_cashFlowTableView]) {
            NSMutableDictionary * group1DataDic = [symbol1Dic objectForKey:@"CashFlow"];
            NSMutableDictionary * group2DataDic = [symbol2Dic objectForKey:@"CashFlow"];
            rowName = [dataModel.financeReportUS.cfKeyArray objectAtIndex:indexPath.row];
            cell.titleLabel.text = NSLocalizedStringFromTable(rowName, @"Equity", nil);
            if (group1DataDic) {
                if (_type==1) {
                    cell.group1Label.text = @"----";
                }else{
                    if ([[group1DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                        cell.group1Label.text = @"----";
                    }else{
                        cell.group1Label.text = [NSString stringWithFormat:@"%.0f",[(NSNumber *)[group1DataDic objectForKey:rowName] floatValue]/1000000];
                    }
                    
                    if ([cell.group1Label.text floatValue]>0){
                        cell.group1Label.textColor = [StockConstant PriceUpColor];
                    }else if ([cell.group1Label.text floatValue]<0){
                        cell.group1Label.textColor = [StockConstant PriceDownColor];
                    }else if(![cell.group1Label.text isEqualToString:@"----"]){
                        cell.group1Label.textColor = [UIColor blueColor];
                    }
                }
                
                
            }
            if (group2DataDic) {
                if (_type ==0){
                    if ([[group2DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                        cell.group2Label.text = @"----";
                    }else{
                        cell.group2Label.text = [NSString stringWithFormat:@"%.0f",[(NSNumber *)[group2DataDic objectForKey:rowName] floatValue]/1000000];
                    }
                    if ([cell.group2Label.text floatValue]>0){
                        cell.group2Label.textColor = [StockConstant PriceUpColor];
                    }else if ([cell.group2Label.text floatValue]<0){
                        cell.group2Label.textColor = [StockConstant PriceDownColor];
                    }else if(![cell.group2Label.text isEqualToString:@"----"]){
                        cell.group2Label.textColor = [UIColor blueColor];
                    }
                }else{
                    cell.group2Label.text = @"----";
                }
                
                
            }
            
        }else if ([tableView isEqual:_financialRatioTableView]) {
            NSMutableDictionary * group1DataDic = [symbol1Dic objectForKey:@"FinancialRatio"];
            NSMutableDictionary * group2DataDic = [symbol2Dic objectForKey:@"FinancialRatio"];
            rowName = [dataModel.financeReportUS.frKeyArray objectAtIndex:indexPath.row];
            cell.titleLabel.text = NSLocalizedStringFromTable(rowName, @"Equity", nil);
            if (group1DataDic) {
                if ([[group1DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                    cell.group1Label.text = @"----";
                }else{
                    if ([rowName isEqualToString:@"Profit Margin(ttm)"] || [rowName isEqualToString:@"Operating Margin(ttm)"] || [rowName isEqualToString:@"Return on Assets(ttm)"] || [rowName isEqualToString:@"Return on Equity(ttm)"] ||[rowName isEqualToString:@"Qtrly Revenue Growth(yoy)"] ||[rowName isEqualToString:@"Qtrly Earnings Growth(yoy)"]) {
                        cell.group1Label.text = [NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[group1DataDic objectForKey:rowName] floatValue]*100];
                        if ([cell.group1Label.text floatValue]>0){
                            cell.group1Label.text = [NSString stringWithFormat:@"+%@",cell.group1Label.text];
                        }
                    }else if ([rowName isEqualToString:@"Revenue Per Share(ttm)"] || [rowName isEqualToString:@"Diluted EPS(ttm)"] || [rowName isEqualToString:@"Total Cash Per Share (mrq)"] || [rowName isEqualToString:@"Total Debt/Equity(mrq)"] ||[rowName isEqualToString:@"Current Ratio(mrq)"] ||[rowName isEqualToString:@"Book Value Per Share(mrq)"]){
                        cell.group1Label.text = [NSString stringWithFormat:@"%.2f",[(NSNumber *)[group1DataDic objectForKey:rowName] floatValue]];
                    }else{
                        cell.group1Label.text = [NSString stringWithFormat:@"%.0f",[(NSNumber *)[group1DataDic objectForKey:rowName] floatValue]/1000000];
                    }
                    
                }
                if ([cell.group1Label.text floatValue]>0){
                    cell.group1Label.textColor = [StockConstant PriceUpColor];
                }else if ([cell.group1Label.text floatValue]<0){
                    cell.group1Label.textColor = [StockConstant PriceDownColor];
                }else if(![cell.group1Label.text isEqualToString:@"----"]){
                    cell.group1Label.textColor = [UIColor blueColor];
                }
                
            }
            if (group2DataDic) {
                if ([[group2DataDic objectForKey:rowName] isEqualToString:@"-0.000000"]){
                    cell.group2Label.text = @"----";
                }else{
                    if ([rowName isEqualToString:@"Profit Margin(ttm)"] || [rowName isEqualToString:@"Operating Margin(ttm)"] || [rowName isEqualToString:@"Return on Assets(ttm)"] || [rowName isEqualToString:@"Return on Equity(ttm)"] ||[rowName isEqualToString:@"Qtrly Revenue Growth(yoy)"] ||[rowName isEqualToString:@"Qtrly Earnings Growth(yoy)"]) {
                        cell.group2Label.text = [NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[group2DataDic objectForKey:rowName] floatValue]*100];
                        if ([cell.group2Label.text floatValue]>0) {
                            cell.group2Label.text = [NSString stringWithFormat:@"+%@",cell.group2Label.text];
                        }
                    }else if ([rowName isEqualToString:@"Revenue Per Share(ttm)"] || [rowName isEqualToString:@"Diluted EPS(ttm)"] || [rowName isEqualToString:@"Total Cash Per Share (mrq)"] || [rowName isEqualToString:@"Total Debt/Equity(mrq)"] ||[rowName isEqualToString:@"Current Ratio(mrq)"] ||[rowName isEqualToString:@"Book Value Per Share(mrq)"]){
                        cell.group2Label.text = [NSString stringWithFormat:@"%.2f",[(NSNumber *)[group2DataDic objectForKey:rowName] floatValue]];
                    }else{
                        cell.group2Label.text = [NSString stringWithFormat:@"%.0f",[(NSNumber *)[group2DataDic objectForKey:rowName] floatValue]/1000000];
                    }
                }
                if ([cell.group2Label.text floatValue]>0){
                    cell.group2Label.textColor = [StockConstant PriceUpColor];
                }else if ([cell.group2Label.text floatValue]<0){
                    cell.group2Label.textColor = [StockConstant PriceDownColor];
                }else if(![cell.group2Label.text isEqualToString:@"----"]){
                    cell.group2Label.textColor = [UIColor blueColor];
                }
                
            }
            
            
        }
    }else{
        if ([tableView isEqual:_balanceTableView]) {
            cell.group1Label.textColor = [UIColor blueColor];
            cell.group2Label.textColor = [UIColor blueColor];
            TAvalueParam *value;
            TAvalueParam *value2;
            TAvalueParam *Totalvalue;
            TAvalueParam *Totalvalue2;
            value = [dataModel.balanceSheet getRowDataWithIdentSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol] RowTitle:[dataModel.balanceSheet.keyArray objectAtIndex:indexPath.row] Index:_balancePostion];
            value2 = [dataModel.balanceSheet getRowDataWithIdentSymbol:_identSymbol2 RowTitle:[dataModel.balanceSheet.keyArray objectAtIndex:indexPath.row] Index:_balancePostion2];
            Totalvalue = [dataModel.balanceSheet getRowDataWithIdentSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol] RowTitle:@"Total Assets" Index:_balancePostion];
            Totalvalue2 = [dataModel.balanceSheet getRowDataWithIdentSymbol:_identSymbol2 RowTitle:@"Total Assets" Index:_balancePostion2];
            
            if([value.nameString isEqualToString:@"Retained Earnings"])
            {
                if(value->value >0 ){
                    cell.group1Label.textColor = [StockConstant PriceUpColor];
                }else if(value->value < 0){
                    cell.group1Label.textColor = [StockConstant PriceDownColor];
                }else if (value ->value == 0){
                    cell.group1Label.textColor = [UIColor blueColor];
                }
            }
            
            cell.titleLabel.text = NSLocalizedStringFromTable(value.nameString, @"Equity", nil);
            
            if (_type==0) {
                if ([[CodingUtil getValueString:value->value Unit:value->unit] isEqualToString:@"----"]) {
                    cell.group1Label.text = [CodingUtil getValueString:value->value Unit:value->unit];
                }else{
                    cell.group1Label.text = [NSString stringWithFormat:@"%.0f",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit] floatValue]];
                }
                
            }else if (_type==1){
                if ([[CodingUtil getValueString:value->value Unit:value->unit] isEqualToString:@"----"]) {
                    cell.group1Label.text = [CodingUtil getValueString:value->value Unit:value->unit];
                }else{
                    if (([(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue])>0) {
                        cell.group1Label.text =[NSString stringWithFormat:@"+%.2f%%",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue]*100];
                    }else{
                        cell.group1Label.text =[NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue]*100];
                    }
                }
                
                
            }else if (_type==2){
                if ([[CodingUtil getValueString:value->value Unit:value->unit] isEqualToString:@"----"]) {
                    cell.group1Label.text = [CodingUtil getValueString:value->value Unit:value->unit];
                }else{
                    cell.group1Label.text = [NSString stringWithFormat:@"%.0f",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit] floatValue]];
                    
                    if (([(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue])>0) {
                        cell.group2Label.text =[NSString stringWithFormat:@"+%.2f%%",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue]*100];
                    }else{
                        cell.group2Label.text =[NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue]*100];
                    }
                }
                
                
            }
            
            if([value2.nameString isEqualToString:@"Retained Earnings"])
            {
                if(value2->value >0 ){
                    cell.group2Label.textColor = [StockConstant PriceUpColor];
                }else if(value2->value < 0){
                    cell.group2Label.textColor = [StockConstant PriceDownColor];
                }else if(value2->value == 0){
                    cell.group2Label.textColor = [UIColor blueColor];
                }
            }
            
            if (_type==0) {
                if ([[CodingUtil getValueString:value2->value Unit:value2->unit] isEqualToString:@"----"]) {
                    cell.group2Label.text = [CodingUtil getValueString:value2->value Unit:value2->unit];
                }else{
                    cell.group2Label.text = [NSString stringWithFormat:@"%.0f",[(NSNumber *)[CodingUtil getValueString:value2->value Unit:value2->unit] floatValue]];
                }
                
            }else if (_type==1){
                if ([[CodingUtil getValueString:value2->value Unit:value2->unit] isEqualToString:@"----"]) {
                    cell.group2Label.text = [CodingUtil getValueString:value2->value Unit:value2->unit];
                }else{
                    if (([(NSNumber *)[CodingUtil getValueString:value2->value Unit:value2->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue2->value Unit:Totalvalue2->unit]floatValue])>0) {
                        cell.group2Label.text =[NSString stringWithFormat:@"+%.2f%%",[(NSNumber *)[CodingUtil getValueString:value2->value Unit:value2->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue2->value Unit:Totalvalue2->unit]floatValue]*100];
                    }else{
                        cell.group2Label.text =[NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[CodingUtil getValueString:value2->value Unit:value2->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue2->value Unit:Totalvalue2->unit]floatValue]*100];
                    }
                }
                
            }
        }else if ([tableView isEqual:_incomeTableView]){
            TAvalueParam *value;
            TAvalueParam *value2;
            TAvalueParam *Totalvalue;
            TAvalueParam *Totalvalue2;
            value = [dataModel.income getRowDataWithIdentSymbol:_identSymbol RowTitle:[dataModel.income.keyArray objectAtIndex:indexPath.row] Index:_incomePostion];
            value2 = [dataModel.income getRowDataWithIdentSymbol:_identSymbol2 RowTitle:[dataModel.income.keyArray objectAtIndex:indexPath.row] Index:_incomePostion2];
            Totalvalue = [dataModel.income getRowDataWithIdentSymbol:_identSymbol RowTitle:@"Total Revenue" Index:_incomePostion];
            Totalvalue2 = [dataModel.income getRowDataWithIdentSymbol:_identSymbol2 RowTitle:@"Total Revenue" Index:_incomePostion2];
            cell.group1Label.textColor = [UIColor blueColor];
            if(![value.nameString isEqualToString:@"Last Price of Quarter Ending"])
            {
                if(value->value >0 ){
                    cell.group1Label.textColor = [StockConstant PriceUpColor];
                }else if(value->value < 0){
                    cell.group1Label.textColor = [StockConstant PriceDownColor];
                }else if(value->value == 0){
                    cell.group1Label.textColor = [UIColor blueColor];
                }
            }
            
            cell.titleLabel.text = NSLocalizedStringFromTable(value.nameString, @"Equity", nil);
            if (_type==0) {
                if ([[CodingUtil getValueString:value->value Unit:value->unit] isEqualToString:@"----"]){
                    cell.group1Label.text = [CodingUtil getValueString:value->value Unit:value->unit];
                }else{
                    if([value.nameString isEqualToString:@"YTD EPS"] || [value.nameString isEqualToString:@"Last Price of Quarter Ending"] || [value.nameString isEqualToString:@"P/E Ratio of Quarter Ending"]){
                        cell.group1Label.text = [CodingUtil getValueString_2:value->value Unit:value->unit];
                    }else{
                        cell.group1Label.text = [NSString stringWithFormat:@"%.0f",[[CodingUtil getValueString:value->value Unit:value->unit]floatValue ]];
                    }
                }
                
                
            }else if (_type==1){
                if ([[CodingUtil getValueString:value->value Unit:value->unit] isEqualToString:@"----"]) {
                    cell.group1Label.text = [CodingUtil getValueString:value->value Unit:value->unit];
                }else{
                    if (([(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue])>0) {
                        cell.group1Label.text =[NSString stringWithFormat:@"+%.2f%%",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue]*100];
                    }else if ( [value.nameString isEqualToString:@"P/E Ratio of Quarter Ending"]){
                        cell.group1Label.text = [CodingUtil getValueString_2:value->value Unit:value->unit];
                    }else{
                        cell.group1Label.text =[NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue]*100];
                    }
                    if ([value.nameString isEqualToString:@"YTD EPS"] || [value.nameString isEqualToString:@"Last Price of Quarter Ending"]){
                        cell.group1Label.text = @"----";
                    }
                }
                
            }else if (_type==2){
                if ([[CodingUtil getValueString:value->value Unit:value->unit] isEqualToString:@"----"]){
                    cell.group1Label.text = [CodingUtil getValueString:value->value Unit:value->unit];
                }else{
                    if([value.nameString isEqualToString:@"YTD EPS"] || [value.nameString isEqualToString:@"Last Price of Quarter Ending"] || [value.nameString isEqualToString:@"P/E Ratio of Quarter Ending"]){
                        cell.group1Label.text = [CodingUtil getValueString_2:value->value Unit:value->unit];
                    }else{
                        cell.group1Label.text = [NSString stringWithFormat:@"%.0f",[[CodingUtil getValueString:value->value Unit:value->unit]floatValue ]];
                    }
                    if (([(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue])>0) {
                        cell.group2Label.text =[NSString stringWithFormat:@"+%.2f%%",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue]*100];
                    }else{
                        cell.group2Label.text =[NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue]*100];
                    }
                    if ([value.nameString isEqualToString:@"YTD EPS"] || [value.nameString isEqualToString:@"Last Price of Quarter Ending"] || [value.nameString isEqualToString:@"P/E Ratio of Quarter Ending"]){
                        cell.group2Label.text = @"----";
                    }
                }
                
                
                
            }
            cell.group2Label.textColor = [UIColor blueColor];
            if(![value2.nameString isEqualToString:@"Last Price of Quarter Ending"])
            {
                if(value2->value >0 ){
                    cell.group2Label.textColor = [StockConstant PriceUpColor];
                }else if(value2->value < 0){
                    cell.group2Label.textColor = [StockConstant PriceDownColor];
                }else if(value2->value == 0){
                    cell.group2Label.textColor = [UIColor blueColor];
                }
            }
            
            if (_type==0) {
                if ([[CodingUtil getValueString:value2->value Unit:value2->unit] isEqualToString:@"----"]){
                    cell.group2Label.text = [CodingUtil getValueString:value2->value Unit:value2->unit];
                }else{
                    if([value2.nameString isEqualToString:@"YTD EPS"] || [value.nameString isEqualToString:@"Last Price of Quarter Ending"] || [value.nameString isEqualToString:@"P/E Ratio of Quarter Ending"]){
                        cell.group2Label.text = [CodingUtil getValueString_2:value2->value Unit:value2->unit];
                    }else{
                        cell.group2Label.text = [NSString stringWithFormat:@"%.0f",[[CodingUtil getValueString:value2->value Unit:value2->unit]floatValue ]];
                    }
                }
                
            }else if (_type==1){
                if ([[CodingUtil getValueString:value2->value Unit:value2->unit] isEqualToString:@"----"]){
                    cell.group2Label.text = [CodingUtil getValueString:value2->value Unit:value2->unit];
                }else{
                    if (([(NSNumber *)[CodingUtil getValueString:value2->value Unit:value2->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue2->value Unit:Totalvalue2->unit]floatValue])>0) {
                        cell.group2Label.text =[NSString stringWithFormat:@"+%.2f%%",[(NSNumber *)[CodingUtil getValueString:value2->value Unit:value2->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue2->value Unit:Totalvalue2->unit]floatValue]*100];
                    }else if ( [value.nameString isEqualToString:@"P/E Ratio of Quarter Ending"]){
                        cell.group2Label.text = [CodingUtil getValueString_2:value2->value Unit:value2->unit];
                    }else{
                        cell.group2Label.text =[NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[CodingUtil getValueString:value2->value Unit:value2->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue2->value Unit:Totalvalue2->unit]floatValue]*100];
                    }
                    if ([value.nameString isEqualToString:@"YTD EPS"] || [value.nameString isEqualToString:@"Last Price of Quarter Ending"]){
                        cell.group2Label.text = @"----";
                    }
                }
                
            }
        }else if ([tableView isEqual:_cashFlowTableView]){
            TAvalueParam *value;
            TAvalueParam *value2;
            TAvalueParam *Totalvalue;
            TAvalueParam *Totalvalue2;
            value = [dataModel.cashFlow getRowDataWithIdentSymbol:_identSymbol RowTitle:[dataModel.cashFlow.keyArray objectAtIndex:indexPath.row] Index:_cashFlowPostion];
            value2 = [dataModel.cashFlow getRowDataWithIdentSymbol:_identSymbol2 RowTitle:[dataModel.cashFlow.keyArray objectAtIndex:indexPath.row] Index:_cashFlowPostion2];
            Totalvalue = [dataModel.cashFlow getRowDataWithIdentSymbol:[_watchportfolio.portfolioItem getIdentCodeSymbol] RowTitle:@"Cash & Cash Equivalents at Beginning" Index:_cashFlowPostion];
            Totalvalue2 = [dataModel.cashFlow getRowDataWithIdentSymbol:_identSymbol2 RowTitle:@"Cash & Cash Equivalents at Beginning" Index:_cashFlowPostion2];
            cell.titleLabel.text = NSLocalizedStringFromTable(value.nameString, @"Equity", nil);
            
            if([value.nameString isEqualToString:@"Depreciation Expense & Various Amortization"] || [value.nameString isEqualToString:@"Cash & Cash Equivalents at Beginning"] || [value.nameString isEqualToString:@"Cash & Cash Equivalents at End"])
            {
                cell.group1Label.textColor = [UIColor blueColor];
            }else{
                if(value->value >0 ){
                    cell.group1Label.textColor = [StockConstant PriceUpColor];
                }else if(value->value < 0){
                    cell.group1Label.textColor = [StockConstant PriceDownColor];
                }else if(value->value == 0){
                    cell.group1Label.textColor = [UIColor blueColor];
                }
            }
            if (_type==0 ||_type==2) {
                if ([[CodingUtil getValueString:value->value Unit:value->unit] isEqualToString:@"----"]){
                    cell.group1Label.text = [CodingUtil getValueString:value->value Unit:value->unit];
                }else{
                    cell.group1Label.text = [NSString stringWithFormat:@"%.0f",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit] floatValue]];
                }
                
            }else if (_type==1){
//                cell.group1Label.text = @"----";
//                cell.group1Label.textColor = [UIColor blackColor];
                if ([[CodingUtil getValueString:value->value Unit:value->unit] isEqualToString:@"----"]) {
                    cell.group1Label.text = [CodingUtil getValueString:value->value Unit:value->unit];
                }else{
                    if (([(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue])>0) {
                        cell.group1Label.text =[NSString stringWithFormat:@"+%.2f%%",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue]*100];
                    }else{
                        cell.group1Label.text =[NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[CodingUtil getValueString:value->value Unit:value->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue->value Unit:Totalvalue->unit]floatValue]*100];
                    }
                }
            }
            
            if(![self isIt:value2.nameString])
            {
                if(value2->value >0 ){
                    cell.group2Label.textColor = [StockConstant PriceUpColor];
                }else if(value2->value < 0){
                    cell.group2Label.textColor = [StockConstant PriceDownColor];
                }else if(value2->value == 0){
                    cell.group2Label.textColor = [UIColor blueColor];
                }
            }else{
                cell.group2Label.textColor = [UIColor blueColor];
            }
            if (_type==0) {
                if ([[CodingUtil getValueString:value2->value Unit:value2->unit] isEqualToString:@"----"]){
                    cell.group2Label.text = [CodingUtil getValueString:value2->value Unit:value2->unit];
                }else{
                    cell.group2Label.text = [NSString stringWithFormat:@"%.0f",[(NSNumber *)[CodingUtil getValueString:value2->value Unit:value2->unit] floatValue]];
                }
            }else if (_type==1 ||_type==2){
//                cell.group2Label.text = @"----";
//                cell.group2Label.textColor = [UIColor blackColor];
                if ([[CodingUtil getValueString:value->value Unit:value->unit] isEqualToString:@"----"]) {
                    cell.group2Label.text = [CodingUtil getValueString:value2->value Unit:value2->unit];
                }else{
                    if (([(NSNumber *)[CodingUtil getValueString:value2->value Unit:value2->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue2->value Unit:Totalvalue2->unit]floatValue])>0) {
                        cell.group2Label.text =[NSString stringWithFormat:@"+%.2f%%",[(NSNumber *)[CodingUtil getValueString:value2->value Unit:value2->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue2->value Unit:Totalvalue2->unit]floatValue]*100];
                    }else{
                        cell.group2Label.text =[NSString stringWithFormat:@"%.2f%%",[(NSNumber *)[CodingUtil getValueString:value2->value Unit:value2->unit]floatValue]/[(NSNumber *)[CodingUtil getValueString:Totalvalue2->value Unit:Totalvalue2->unit]floatValue]*100];
                    }
                }
            }
        }else if ([tableView isEqual:_financialRatioTableView]){
            TAvalueParam *value;
            TAvalueParam *value2;
            value = [dataModel.financialRatio getRowDataWithIdentSymbol:_identSymbol RowTitle:[dataModel.financialRatio.allKeyArray objectAtIndex:indexPath.row] Index:_financialRatioPostion];
            value2 = [dataModel.financialRatio getRowDataWithIdentSymbol:_identSymbol2 RowTitle:[dataModel.financialRatio.allKeyArray objectAtIndex:indexPath.row] Index:_financialRatioPostion2];
            
            
            cell.titleLabel.text = NSLocalizedStringFromTable(value.nameString, @"Equity", nil);
            
            if([value.nameString isEqualToString:@"Profitability Ratios"] || [value.nameString isEqualToString:@"Growth Rates"] || [value.nameString isEqualToString:@"Financial Strength"] || [value.nameString isEqualToString:@"Management Effectiveness"] || [value.nameString isEqualToString:@"Efficiency"]){
                cell.titleLabel.textColor = [UIColor colorWithRed:128.0f/255.0f green:42.0f/255.0f blue:42.0f/255.0f alpha:1];
                
            }else{
                cell.titleLabel.textColor = [UIColor blackColor];
            }
            
            if([value.nameString isEqualToString:@"Net Asset Value Per Share"] || [value.nameString isEqualToString:@"Sale Value Per Share"] || [value.nameString isEqualToString:@"Profit Value Per Share"] || [value.nameString isEqualToString:@"Pre-Tax Profit Value Per Share"] || [value.nameString isEqualToString:@"Net Profit Value Per Share"] ||
               [value.nameString isEqualToString:@"Index Of Financial Lever"] ||
               [value.nameString isEqualToString:@"Receivable Days"] ||
               [value.nameString isEqualToString:@"AVG Inventory Days"]){
                if ([[CodingUtil getValueString:value->value Unit:value->unit] isEqualToString:@"----"]) {
                    cell.group1Label.text = @"----";
                    cell.group1Label.textColor = [UIColor blackColor];
                }else{
                    cell.group1Label.textColor = [UIColor blueColor];
                    cell.group1Label.text = [CodingUtil getValueString_2:value->value Unit:value->unit];
                }
            }else{
                if ([value.nameString isEqualToString:@"Current Ratio"] || [value.nameString isEqualToString:@"Quick Ratio"] || [value.nameString isEqualToString:@"Total Debt to Assest"] || [value.nameString isEqualToString:@"Cash Ratio"] || [value.nameString isEqualToString:@"Cash Flow Ratio"] ||
                    [value.nameString isEqualToString:@"Receivable Turnover Rate"] ||
                    [value.nameString isEqualToString:@"Inventory Turnover Rate"] ||
                    [value.nameString isEqualToString:@"Fixed Asset Turnover Rate"] || [value.nameString isEqualToString:@"Total Asset Turnover Rate"] ||
                    [value.nameString isEqualToString:@"Net Asset Turnover Rate"] ||
                    [value.nameString isEqualToString:@"Long Capital Fit Rate"]) {
                    cell.group1Label.textColor = [UIColor blueColor];
                }else{
                    if(value->value >0 ){
                        cell.group1Label.textColor = [StockConstant PriceUpColor];
                    }else if(value->value < 0){
                        cell.group1Label.textColor = [StockConstant PriceDownColor];
                    }else if(value->value == 0){
                        cell.group1Label.textColor = [UIColor blueColor];
                    }
                }
                
                if ([[CodingUtil getValueString:value->value*100 Unit:value->unit] isEqualToString:@"----"]) {
                    cell.group1Label.text = @"----";
                    cell.group1Label.textColor = [UIColor blackColor];
                }else{
                    if ([(NSNumber *)[CodingUtil getValueString:value->value*100 Unit:value->unit]floatValue]>0.0f) {
                        cell.group1Label.text = [NSString stringWithFormat:@"+%@%%",[CodingUtil getValueString:value->value*100 Unit:value->unit]];
                    }else{
                        cell.group1Label.text = [NSString stringWithFormat:@"%@%%",[CodingUtil getValueString:value->value*100 Unit:value->unit]];
                    }
                }
            }
            
            
            if([value2.nameString isEqualToString:@"Net Asset Value Per Share"] || [value2.nameString isEqualToString:@"Sale Value Per Share"] || [value2.nameString isEqualToString:@"Profit Value Per Share"] || [value2.nameString isEqualToString:@"Pre-Tax Profit Value Per Share"] || [value2.nameString isEqualToString:@"Net Profit Value Per Share"] ||
               [value2.nameString isEqualToString:@"Index Of Financial Lever"] ||
               [value2.nameString isEqualToString:@"Receivable Days"] ||
               [value2.nameString isEqualToString:@"AVG Inventory Days"]){
                if ([[CodingUtil getValueString:value2->value Unit:value2->unit] isEqualToString:@"----"]) {
                    cell.group2Label.text = @"----";
                    cell.group2Label.textColor = [UIColor blackColor];
                }else{
                    cell.group2Label.text = [CodingUtil getValueString_2:value2->value Unit:value2->unit];
                    cell.group2Label.textColor = [UIColor blueColor];
                }
            }else{
                if ([value2.nameString isEqualToString:@"Current Ratio"] || [value2.nameString isEqualToString:@"Quick Ratio"] || [value2.nameString isEqualToString:@"Total Debt to Assest"] || [value2.nameString isEqualToString:@"Cash Ratio"] || [value2.nameString isEqualToString:@"Cash Flow Ratio"] ||
                    [value2.nameString isEqualToString:@"Receivable Turnover Rate"] ||
                    [value2.nameString isEqualToString:@"Inventory Turnover Rate"] ||
                    [value2.nameString isEqualToString:@"Fixed Asset Turnover Rate"] || [value2.nameString isEqualToString:@"Total Asset Turnover Rate"] ||
                    [value2.nameString isEqualToString:@"Net Asset Turnover Rate"] ||
                    [value2.nameString isEqualToString:@"Long Capital Fit Rate"]) {
                    cell.group2Label.textColor = [UIColor blueColor];
                }else{
                    if(value2->value >0 ){
                        cell.group2Label.textColor = [StockConstant PriceUpColor];
                    }else if(value2->value < 0){
                        cell.group2Label.textColor = [StockConstant PriceDownColor];
                    }else if(value2->value == 0){
                        cell.group2Label.textColor = [UIColor blueColor];
                    }
                }
                
                if ([[CodingUtil getValueString:value2->value*100 Unit:value2->unit] isEqualToString:@"----"]) {
                    cell.group2Label.text = @"----";
                    cell.group2Label.textColor = [UIColor blackColor];
                }else{
                    if ([(NSNumber *)[CodingUtil getValueString:value2->value*100 Unit:value2->unit]floatValue]>0.0f) {
                        cell.group2Label.text = [NSString stringWithFormat:@"+%@%%",[CodingUtil getValueString:value2->value*100 Unit:value2->unit]];
                    }else{
                        cell.group2Label.text = [NSString stringWithFormat:@"%@%%",[CodingUtil getValueString:value2->value*100 Unit:value2->unit]];
                    }
                }
            }
            
            if(value2->value == 0 && ![[[_identSymbol2 componentsSeparatedByString:@" "] objectAtIndex:0] isEqualToString:[[_identSymbol componentsSeparatedByString:@" "]objectAtIndex:0]]){
                cell.group2Label.text = @"----";
                cell.group2Label.textColor = [UIColor blackColor];
            }
        }
        
        
        
        if ([cell.group1Label.text isEqualToString:@"----%"]) {
            cell.group1Label.text = @"----";
        }
        if ([cell.group2Label.text isEqualToString:@"----%"]) {
            cell.group2Label.text = @"----";
        }
        
        if ([cell.group1Label.text isEqualToString:@"----"]) {
            cell.group1Label.textColor = [UIColor blackColor];
        }
        if ([cell.group2Label.text isEqualToString:@"----"]) {
            cell.group2Label.textColor = [UIColor blackColor];
        }
    }

    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    self.headerView = [[UIView alloc]init];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.frame=CGRectMake(0, 0, tableView.frame.size.width, 40);
    UIView * lineView = [[UIView alloc]init];
    lineView.frame=CGRectMake(0, 39, tableView.frame.size.width, 1);
    lineView.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    [_headerView addSubview:lineView];
    if (section == 0){
        PortfolioItem * item = _watchportfolio.portfolioItem;
        if ([tableView isEqual:_balanceTableView]) {
            self.balanceheaderTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 39)];
            _balanceheaderTitleLabel.text = NSLocalizedStringFromTable(@"Period Ending", @"Equity", nil);
            _balanceheaderTitleLabel.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:232.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
            [_dictionary setObject:_balanceheaderTitleLabel forKey:@"balanceheaderTitleLabel"];
            [_headerView addSubview:_balanceheaderTitleLabel];
            
            self.balanceGroup1Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
            [_balanceGroup1Btn setFrame:CGRectMake(130, 0, 90, 38)];
            [_dictionary setObject:_balanceGroup1Btn forKey:@"balanceGroup1Btn"];
            [_headerView addSubview:_balanceGroup1Btn];
            
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            if (!([balance1Array count]==0) && _balancePostion<8) {
                [dateFormat setDateFormat:@"yyyy"];
                NSString *year = [dateFormat stringFromDate:[[balance1Array objectAtIndex:_balancePostion] uint16ToDate]];
                [dateFormat setDateFormat:@"MM"];
                NSString * month =[dateFormat stringFromDate:[[balance1Array objectAtIndex:_balancePostion] uint16ToDate]];
                NSString * Q = [self dateToQuarter:month];
                if (item->identCode[0]=='T' && item->identCode[1]=='W') {
                    NSString * dateString = [NSString stringWithFormat:@"%d-%@",[year intValue]-1911,Q];
                    [_balanceGroup1Btn setTitle:dateString forState:UIControlStateNormal];
                }else{
                    NSString * dateString = [NSString stringWithFormat:@"%@/%d",Q,[year intValue]];
                    [_balanceGroup1Btn setTitle:dateString forState:UIControlStateNormal];
                }
            }
            
            [_balanceGroup1Btn addTarget:self action:@selector(group1BtnClickWithButton:) forControlEvents:UIControlEventTouchUpInside];
            
            self.balanceGroup2Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
            [_balanceGroup2Btn setFrame:CGRectMake(225, 0, 90, 38)];
            [_dictionary setObject:_balanceGroup2Btn forKey:@"balanceGroup2Btn"];
            [_headerView addSubview:_balanceGroup2Btn];
            if (![balance2Array count]==0) {
                NSString *year;
                NSString * month;
                if ([balance2Array count]>_balancePostion2){
                    [dateFormat setDateFormat:@"yyyy"];
                    year= [dateFormat stringFromDate:[[balance2Array objectAtIndex:_balancePostion2] uint16ToDate]];
                    [dateFormat setDateFormat:@"MM"];
                    month=[dateFormat stringFromDate:[[balance2Array objectAtIndex:_balancePostion2] uint16ToDate]];
                }else{
                    [dateFormat setDateFormat:@"yyyy"];
                    year= [dateFormat stringFromDate:[[balance2Array lastObject] uint16ToDate]];
                    [dateFormat setDateFormat:@"MM"];
                    month=[dateFormat stringFromDate:[[balance2Array lastObject] uint16ToDate]];
                    _balancePostion2 = (int)[balance2Array count]-1;
                }
                NSString * Q = [self dateToQuarter:month];
                if (item->identCode[0]=='T' && item->identCode[1]=='W') {
                    
                    NSString * dateString = [NSString stringWithFormat:@"%d-%@",[year intValue]-1911,Q];
                    [_balanceGroup2Btn setTitle:dateString forState:UIControlStateNormal];
                }else{
                    NSString * dateString = [NSString stringWithFormat:@"%@/%d",Q,[year intValue]];
                    [_balanceGroup2Btn setTitle:dateString forState:UIControlStateNormal];
                }
                
            }
            [_balanceGroup2Btn addTarget:self action:@selector(group2BtnClickWithButton:) forControlEvents:UIControlEventTouchUpInside];
            
            self.percentLabel = [[UILabel alloc]initWithFrame:CGRectMake(225, 0, 90, 38)];
            _percentLabel.text = NSLocalizedStringFromTable(@"比例", @"Equity", nil);
            _percentLabel.font = [UIFont boldSystemFontOfSize:20.0f];
            _percentLabel.textAlignment = NSTextAlignmentCenter;
            [_dictionary setObject:_percentLabel forKey:@"percentLabel"];
            _percentLabel.hidden = YES;
            [_headerView addSubview:_percentLabel];
            
            if (_type==2) {
                _percentLabel.hidden = NO;
                _balanceGroup2Btn.hidden = YES;
            }else{
                _percentLabel.hidden = YES;
                _balanceGroup2Btn.hidden = NO;
            }
        }else if ([tableView isEqual:_incomeTableView]){
            self.incomeHeaderTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 39)];
            if (_total==0) {
                _incomeHeaderTitleLabel.text = NSLocalizedStringFromTable(@"財報日期(累計)", @"Equity", nil);
            }else if (_total==1){
                _incomeHeaderTitleLabel.text = NSLocalizedStringFromTable(@"財報日期(單季)", @"Equity", nil);
            }
            
            _incomeHeaderTitleLabel.adjustsFontSizeToFitWidth = YES;
            _incomeHeaderTitleLabel.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:232.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
            [_dictionary setObject:_incomeHeaderTitleLabel forKey:@"incomeHeaderTitleLabel"];
            [_headerView addSubview:_incomeHeaderTitleLabel];
            
            self.incomeGroup1Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
            [_incomeGroup1Btn setFrame:CGRectMake(130, 0, 90, 38)];
            [_dictionary setObject:_incomeGroup1Btn forKey:@"incomeGroup1Btn"];
            [_headerView addSubview:_incomeGroup1Btn];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy/MM"];
            if (!([income1Array count]==0)) {
                [dateFormat setDateFormat:@"yyyy"];
                NSString *year = [dateFormat stringFromDate:[[income1Array objectAtIndex:_incomePostion] uint16ToDate]];
                [dateFormat setDateFormat:@"MM"];
                NSString * month =[dateFormat stringFromDate:[[income1Array objectAtIndex:_incomePostion] uint16ToDate]];
                NSString * Q = [self dateToQuarter:month];
                if (item->identCode[0]=='T' && item->identCode[1]=='W') {
                    
                    NSString * dateString = [NSString stringWithFormat:@"%d-%@",[year intValue]-1911,Q];
                    [_incomeGroup1Btn setTitle:dateString forState:UIControlStateNormal];
                }else{
                    NSString * dateString = [NSString stringWithFormat:@"%@/%d",Q,[year intValue]];
                    [_incomeGroup1Btn setTitle:dateString forState:UIControlStateNormal];
                }
            }
            
            [_incomeGroup1Btn addTarget:self action:@selector(group1BtnClickWithButton:) forControlEvents:UIControlEventTouchUpInside];
            
            self.incomeGroup2Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
            [_incomeGroup2Btn setFrame:CGRectMake(225, 0, 90, 38)];
            [_dictionary setObject:_incomeGroup2Btn forKey:@"incomeGroup2Btn"];
            [_headerView addSubview:_incomeGroup2Btn];
            if (!([income2Array count]==0)) {
                
                NSString *year;
                NSString * month;
                if ([income2Array count]>_incomePostion2){
                    [dateFormat setDateFormat:@"yyyy"];
                     year= [dateFormat stringFromDate:[[income2Array objectAtIndex:_incomePostion2] uint16ToDate]];
                    [dateFormat setDateFormat:@"MM"];
                    month=[dateFormat stringFromDate:[[income2Array objectAtIndex:_incomePostion2] uint16ToDate]];
                }else{
                    [dateFormat setDateFormat:@"yyyy"];
                    year= [dateFormat stringFromDate:[[income2Array lastObject] uint16ToDate]];
                    [dateFormat setDateFormat:@"MM"];
                    month=[dateFormat stringFromDate:[[income2Array lastObject] uint16ToDate]];
                     _incomePostion2 = (int)[income2Array count]-1;
                }
                
                NSString * Q = [self dateToQuarter:month];
                if (item->identCode[0]=='T' && item->identCode[1]=='W') {
                    
                    NSString * dateString = [NSString stringWithFormat:@"%d-%@",[year intValue]-1911,Q];
                    [_incomeGroup2Btn setTitle:dateString forState:UIControlStateNormal];
                }else{
                    NSString * dateString = [NSString stringWithFormat:@"%@/%d",Q,[year intValue]];
                    [_incomeGroup2Btn setTitle:dateString forState:UIControlStateNormal];
                }
            }
            
            [_incomeGroup2Btn addTarget:self action:@selector(group2BtnClickWithButton:) forControlEvents:UIControlEventTouchUpInside];
            self.percentLabel = [[UILabel alloc]initWithFrame:CGRectMake(225, 0, 90, 38)];
            _percentLabel.text = NSLocalizedStringFromTable(@"比例", @"Equity", nil);
            _percentLabel.font = [UIFont boldSystemFontOfSize:20.0f];
            _percentLabel.textAlignment = NSTextAlignmentCenter;
            [_dictionary setObject:_percentLabel forKey:@"percentLabel"];
            _percentLabel.hidden = YES;
            [_headerView addSubview:_percentLabel];
            
            if (_type==2) {
                _percentLabel.hidden = NO;
                _incomeGroup2Btn.hidden = YES;
            }else{
                _percentLabel.hidden = YES;
                _incomeGroup2Btn.hidden = NO;
            }
            
        }else if ([tableView isEqual:_cashFlowTableView]){
            self.cashFlowHeaderTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 39)];
            if (_total==0) {
                _cashFlowHeaderTitleLabel.text = NSLocalizedStringFromTable(@"財報日期(累計)", @"Equity", nil);
            }else if (_total==1){
                _cashFlowHeaderTitleLabel.text = NSLocalizedStringFromTable(@"財報日期(單季)", @"Equity", nil);
            }
            _cashFlowHeaderTitleLabel.adjustsFontSizeToFitWidth = YES;
            _cashFlowHeaderTitleLabel.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:232.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
            [_dictionary setObject:_cashFlowHeaderTitleLabel forKey:@"cashFlowHeaderTitleLabel"];
            [_headerView addSubview:_cashFlowHeaderTitleLabel];
            
            self.cashFlowGroup1Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
            [_cashFlowGroup1Btn setFrame:CGRectMake(130, 0, 90, 38)];
            [_dictionary setObject:_cashFlowGroup1Btn forKey:@"cashFlowGroup1Btn"];
            [_headerView addSubview:_cashFlowGroup1Btn];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy/MM"];
            if (!([cashFlow1Array count]==0)) {
                [dateFormat setDateFormat:@"yyyy"];
                NSString *year = [dateFormat stringFromDate:[[cashFlow1Array objectAtIndex:_cashFlowPostion] uint16ToDate]];
                [dateFormat setDateFormat:@"MM"];
                NSString * month =[dateFormat stringFromDate:[[cashFlow1Array objectAtIndex:_cashFlowPostion] uint16ToDate]];
                NSString * Q = [self dateToQuarter:month];
                if (item->identCode[0]=='T' && item->identCode[1]=='W') {
                    
                    NSString * dateString = [NSString stringWithFormat:@"%d-%@",[year intValue]-1911,Q];
                    [_cashFlowGroup1Btn setTitle:dateString forState:UIControlStateNormal];
                }else{
                    NSString * dateString = [NSString stringWithFormat:@"%@/%d",Q,[year intValue]];
                    [_cashFlowGroup1Btn setTitle:dateString forState:UIControlStateNormal];
                }
            }
            
            [_cashFlowGroup1Btn addTarget:self action:@selector(group1BtnClickWithButton:) forControlEvents:UIControlEventTouchUpInside];
            
            self.cashFlowGroup2Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
            [_cashFlowGroup2Btn setFrame:CGRectMake(225, 0, 90, 38)];
            [_dictionary setObject:_cashFlowGroup2Btn forKey:@"cashFlowGroup2Btn"];
            [_headerView addSubview:_cashFlowGroup2Btn];
            if (!([cashFlow2Array count]==0)) {
                NSString *year;
                NSString * month;
                if ([cashFlow2Array count]>_cashFlowPostion2){
                    [dateFormat setDateFormat:@"yyyy"];
                    year= [dateFormat stringFromDate:[[cashFlow2Array objectAtIndex:_cashFlowPostion2] uint16ToDate]];
                    [dateFormat setDateFormat:@"MM"];
                    month=[dateFormat stringFromDate:[[cashFlow2Array objectAtIndex:_cashFlowPostion2] uint16ToDate]];
                }else{
                    [dateFormat setDateFormat:@"yyyy"];
                    year= [dateFormat stringFromDate:[[cashFlow2Array lastObject] uint16ToDate]];
                    [dateFormat setDateFormat:@"MM"];
                    month=[dateFormat stringFromDate:[[cashFlow2Array lastObject] uint16ToDate]];
                    _cashFlowPostion2 = (int)[cashFlow2Array count]-1;
                }
                NSString * Q = [self dateToQuarter:month];
                if (item->identCode[0]=='T' && item->identCode[1]=='W') {
                    
                    NSString * dateString = [NSString stringWithFormat:@"%d-%@",[year intValue]-1911,Q];
                    [_cashFlowGroup2Btn setTitle:dateString forState:UIControlStateNormal];
                }else{
                    NSString * dateString = [NSString stringWithFormat:@"%@/%d",Q,[year intValue]];
                    [_cashFlowGroup2Btn setTitle:dateString forState:UIControlStateNormal];
                }
            }
            
            [_cashFlowGroup2Btn addTarget:self action:@selector(group2BtnClickWithButton:) forControlEvents:UIControlEventTouchUpInside];
            self.percentLabel = [[UILabel alloc]initWithFrame:CGRectMake(225, 0, 90, 38)];
            _percentLabel.text = NSLocalizedStringFromTable(@"比例", @"Equity", nil);
            _percentLabel.font = [UIFont boldSystemFontOfSize:20.0f];
            _percentLabel.textAlignment = NSTextAlignmentCenter;
            [_dictionary setObject:_percentLabel forKey:@"percentLabel"];
            _percentLabel.hidden = YES;
            [_headerView addSubview:_percentLabel];
            
            if (_type==2) {
                _percentLabel.hidden = NO;
                _cashFlowGroup2Btn.hidden = YES;
            }else{
                _percentLabel.hidden = YES;
                _cashFlowGroup2Btn.hidden = NO;
            }
            
        }else if ([tableView isEqual:_financialRatioTableView]){
            self.financialRatioHeaderTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 39)];
            if (_total==0) {
                _financialRatioHeaderTitleLabel.text = NSLocalizedStringFromTable(@"財報日期(累計)", @"Equity", nil);
            }else{
                _financialRatioHeaderTitleLabel.text = NSLocalizedStringFromTable(@"財報日期(單季)", @"Equity", nil);
            }
            
            _financialRatioHeaderTitleLabel.adjustsFontSizeToFitWidth = YES;
            _financialRatioHeaderTitleLabel.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:232.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
            [_dictionary setObject:_financialRatioHeaderTitleLabel forKey:@"financialRatioHeaderTitleLabel"];
            [_headerView addSubview:_financialRatioHeaderTitleLabel];
            
            self.financialRatioGroup1Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
            [_financialRatioGroup1Btn setFrame:CGRectMake(130, 0, 90, 38)];
            [_dictionary setObject:_financialRatioGroup1Btn forKey:@"financialRatioGroup1Btn"];
            [_headerView addSubview:_financialRatioGroup1Btn];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy/MM"];
            if (!([financialRatio1Array count]==0)) {
                [dateFormat setDateFormat:@"yyyy"];
                NSString *year = [dateFormat stringFromDate:[[financialRatio1Array objectAtIndex:_financialRatioPostion] uint16ToDate]];
                [dateFormat setDateFormat:@"MM"];
                NSString * month =[dateFormat stringFromDate:[[financialRatio1Array objectAtIndex:_financialRatioPostion] uint16ToDate]];
                NSString * Q = [self dateToQuarter:month];
                if (item->identCode[0]=='T' && item->identCode[1]=='W') {
                    
                    NSString * dateString = [NSString stringWithFormat:@"%d-%@",[year intValue]-1911,Q];
                    [_financialRatioGroup1Btn setTitle:dateString forState:UIControlStateNormal];
                }else{
                    NSString * dateString = [NSString stringWithFormat:@"%@/%d",Q,[year intValue]];
                    [_financialRatioGroup1Btn setTitle:dateString forState:UIControlStateNormal];
                }
            }
            
            [_financialRatioGroup1Btn addTarget:self action:@selector(group1BtnClickWithButton:) forControlEvents:UIControlEventTouchUpInside];
            
            self.financialRatioGroup2Btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
            [_financialRatioGroup2Btn setFrame:CGRectMake(225, 0, 90, 38)];
            [_dictionary setObject:_financialRatioGroup2Btn forKey:@"financialRatioGroup2Btn"];
            [_headerView addSubview:_financialRatioGroup2Btn];
            if (!([financialRatio2Array count]==0)) {
                NSString *year;
                NSString * month;
                if ([financialRatio2Array count]>_financialRatioPostion2){
                    [dateFormat setDateFormat:@"yyyy"];
                    year= [dateFormat stringFromDate:[[financialRatio2Array objectAtIndex:_financialRatioPostion2] uint16ToDate]];
                    [dateFormat setDateFormat:@"MM"];
                    month=[dateFormat stringFromDate:[[financialRatio2Array objectAtIndex:_financialRatioPostion2] uint16ToDate]];
                }else{
                    [dateFormat setDateFormat:@"yyyy"];
                    year= [dateFormat stringFromDate:[[financialRatio2Array lastObject] uint16ToDate]];
                    [dateFormat setDateFormat:@"MM"];
                    month=[dateFormat stringFromDate:[[financialRatio2Array lastObject] uint16ToDate]];
                    _financialRatioPostion2 = (int)[financialRatio2Array count]-1;
                }
                NSString * Q = [self dateToQuarter:month];
                if (item->identCode[0]=='T' && item->identCode[1]=='W') {
                    
                    NSString * dateString = [NSString stringWithFormat:@"%d-%@",[year intValue]-1911,Q];
                    [_financialRatioGroup2Btn setTitle:dateString forState:UIControlStateNormal];
                }else{
                    NSString * dateString = [NSString stringWithFormat:@"%@/%d",Q,[year intValue]];
                    [_financialRatioGroup2Btn setTitle:dateString forState:UIControlStateNormal];
                }
            }
            
            [_financialRatioGroup2Btn addTarget:self action:@selector(group2BtnClickWithButton:) forControlEvents:UIControlEventTouchUpInside];
        }

    }else{
        UILabel * titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 39)];
        titleLabel.text = NSLocalizedStringFromTable([dataModel.financialRatio.keyArray objectAtIndex:section], @"Equity", nil);
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:232.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
        [_headerView addSubview:titleLabel];
        
    }
    
    return _headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30.0f;
}




- (void)clearAllData {
    [balance1Array removeAllObjects];
    [balance2Array removeAllObjects];
    [income1Array removeAllObjects];
    [income2Array removeAllObjects];
    [cashFlow1Array removeAllObjects];
    [cashFlow2Array removeAllObjects];
    [financialRatio1Array removeAllObjects];
    [financialRatio2Array removeAllObjects];
}

- (void)showTwoStockMode {
    
    // 如果第二檔是空的 就設第一檔
    if (_watchportfolio.comparedPortfolioItem == nil) {
        _watchportfolio.comparedPortfolioItem = _watchportfolio.portfolioItem;
    }
    
    // 如果有開雙股, 不是股票就換相同的
    if (_twoStock) {
        if (_watchportfolio.comparedPortfolioItem->type_id != 1) {
            _watchportfolio.comparedPortfolioItem = _watchportfolio.portfolioItem;
        }
    }
    
    NSString *symbol1Name;
    NSString *symbol2Name;
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        symbol1Name = _watchportfolio.portfolioItem->symbol;
        symbol2Name = _watchportfolio.comparedPortfolioItem->symbol;
    } else {
        symbol1Name = _watchportfolio.portfolioItem->fullName;
        symbol2Name = _watchportfolio.comparedPortfolioItem->fullName;
    }
    
    [_balanceStock1Btn setTitle:symbol1Name forState:UIControlStateNormal];
    [_balanceStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
    [_incomeStock1Btn setTitle:symbol1Name forState:UIControlStateNormal];
    [_incomeStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
    [_cashFlowStock1Btn setTitle:symbol1Name forState:UIControlStateNormal];
    [_cashFlowStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
    [_financialRatioStock1Btn setTitle:symbol1Name forState:UIControlStateNormal];
    [_financialRatioStock2Btn setTitle:symbol2Name forState:UIControlStateNormal];
    
    
    self.identSymbol = [_watchportfolio.portfolioItem getIdentCodeSymbol];
    self.identSymbol2 = [_watchportfolio.comparedPortfolioItem getIdentCodeSymbol];
    
}

// 點擊雙股走勢按鈕
- (void)twoStockBtnClick:(FSUIButton *)btn {
    
    [self clearAllData];
    
    _twoStock = !_twoStock;
    
    balanceTwoStockBtn.selected = _twoStock;
    incomeTwoStockBtn.selected = _twoStock;;
    cashFlowTwoStockBtn.selected = _twoStock;;
    financialRatioTwoStockBtn.selected = _twoStock;;
    
    if (_twoStock) {
        
        // 不是 $+%
        if (_type != 2) {
            
            [self reloadStocks];
//            [self searchBalanceSheet];
        }
    }else{
        // 不是 $+%
        if (_type != 2) {
            [self reloadStocks];
        }
       
    }
    
    
    _balanceStock1Btn.hidden = !_twoStock;
    _balanceStock2Btn.hidden = !_twoStock;
    _incomeStock1Btn.hidden = !_twoStock;
    _incomeStock2Btn.hidden = !_twoStock;
    _cashFlowStock1Btn.hidden = !_twoStock;
    _cashFlowStock2Btn.hidden = !_twoStock;
    _financialRatioStock1Btn.hidden = !_twoStock;
    _financialRatioStock2Btn.hidden = !_twoStock;
    
    
}

-(void)changeStockBtnClick:(FSUIButton *)button{
    if ([button isEqual:_balanceStock1Btn]||[button isEqual:_financialRatioStock1Btn]||[button isEqual:_incomeStock1Btn]||[button isEqual:_cashFlowStock1Btn]) {
        ChangeStockViewController * changeStockView = [[ChangeStockViewController alloc]initWithNumber:1];
        [self.navigationController pushViewController:changeStockView animated:NO];
    }else{
        ChangeStockViewController * changeStockView = [[ChangeStockViewController alloc]initWithNumber:2];
        [self.navigationController pushViewController:changeStockView animated:NO];
    }
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
	CGFloat pageWidth = self.scrollView.bounds.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
	NSInteger nearestNumber = lround(fractionalPage);
	
	if (self.pageControl.currentPage != nearestNumber) {
		self.pageControl.currentPage = nearestNumber;
        [self.pageControl updateCurrentPageDisplay] ;
	}
}

- (void)readFromFile {
    
    // 讀取是否用雙股走勢
    NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *fileName = @"TechViewDefaultIndicator.plist";
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSMutableDictionary *techViewInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    self.twoStock = [(NSNumber *)[techViewInfo objectForKey:@"stockCompareValue"]intValue];
    
    
	// 財報參數
    NSString *path2 = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent: [NSString stringWithFormat:@"FinanceMemory.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path2];
    
    if (_mainDict) {
        self.type = [(NSNumber *)[_mainDict objectForKey:@"searchType"] intValue];
        _balancePostion = [(NSNumber *)[_mainDict objectForKey:@"BalancePostion"] intValue];
        _balancePostion2 = [(NSNumber *)[_mainDict objectForKey:@"BalancePostion2"] intValue];
        _incomePostion = [(NSNumber *)[_mainDict objectForKey:@"IncomePostion"] intValue];
        _incomePostion2 = [(NSNumber *)[_mainDict objectForKey:@"IncomePostion2"] intValue];
        _cashFlowPostion = [(NSNumber *)[_mainDict objectForKey:@"CashFlowPostion"] intValue];
        _cashFlowPostion2 = [(NSNumber *)[_mainDict objectForKey:@"CashFlowPostion2"] intValue];
        _financialRatioPostion = [(NSNumber *)[_mainDict objectForKey:@"FinancialRatioPostion"] intValue];
        _financialRatioPostion2 = [(NSNumber *)[_mainDict objectForKey:@"FinancialRatioPostion2"] intValue];
    }else{
        _balancePostion = 0;
        _balancePostion2 = 4;
        _incomePostion = 0;
        _incomePostion2 = 4;
        _cashFlowPostion = 0;
        _cashFlowPostion2 = 4;
        _financialRatioPostion = 0;
        _financialRatioPostion2 = 4;
    }

}


- (void)saveToFile {
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent: [NSString stringWithFormat:@"FinanceMemory.plist"]];
    
    self.mainDict = [[NSMutableDictionary alloc] init];
    
    [self.mainDict setObject:[NSNumber numberWithInteger:self.pageControl.currentPage] forKey:@"FinanceNumber"];
    [self.mainDict setObject:[NSNumber numberWithInt:self.type] forKey:@"searchType"];
    
    [self.mainDict setObject:[NSNumber numberWithInt:_balancePostion] forKey:@"BalancePostion"];
    [self.mainDict setObject:[NSNumber numberWithInt:_balancePostion2] forKey:@"BalancePostion2"];
    [self.mainDict setObject:[NSNumber numberWithInt:_incomePostion] forKey:@"IncomePostion"];
    [self.mainDict setObject:[NSNumber numberWithInt:_incomePostion2] forKey:@"IncomePostion2"];
    [self.mainDict setObject:[NSNumber numberWithInt:_cashFlowPostion] forKey:@"CashFlowPostion"];
    [self.mainDict setObject:[NSNumber numberWithInt:_cashFlowPostion2] forKey:@"CashFlowPostion2"];
    [self.mainDict setObject:[NSNumber numberWithInt:_financialRatioPostion] forKey:@"FinancialRatioPostion"];
    [self.mainDict setObject:[NSNumber numberWithInt:_financialRatioPostion2] forKey:@"FinancialRatioPostion2"];
    
    [self.mainDict writeToFile:path atomically:YES];
}

- (void)discardData{
    
    [balance1Array removeAllObjects];
    [balance2Array removeAllObjects];
    [income1Array removeAllObjects];
    [income2Array removeAllObjects];
    [cashFlow1Array removeAllObjects];
    [cashFlow2Array removeAllObjects];
    [financialRatio1Array removeAllObjects];
    [financialRatio2Array removeAllObjects];
    
    [dataModel.balanceSheet setTargetNotify:nil];
    [dataModel.income setTargetNotify:nil];
    [dataModel.cashFlow setTargetNotify:nil];
    [dataModel.financialRatio setTargetNotify:nil];
}

-(BOOL)isIt:(NSString*)keyName
{
	if([keyName isEqualToString:@"Depreciation Expense & Various Amortization"] || [keyName isEqualToString:@"Proceeds from New Issues"] || [keyName isEqualToString:@"Cash & Cash Equivalents at Beginning"] || [keyName isEqualToString:@"Cash & Cash Equivalents at End"]){
		return YES;
	}else{
		return NO;
	}
    
}


@end
