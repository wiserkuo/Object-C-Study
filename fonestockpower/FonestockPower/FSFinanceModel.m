//
//  FSFinanceModel.m
//  FonestockPower
//
//  Created by Connor on 2015/5/18.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSFinanceModel.h"

@implementation FSFinanceModel

- (instancetype)init {
    if (self = [super init]) {
        
        _lock = [[NSRecursiveLock alloc] init];
        
        _model = [[FSFinanceReportCN alloc] init];
        
        _pageList1 = _model.pageList1;
        _pageList2 = _model.pageList2;
        _pageList3 = _model.pageList3;
        _pageList4 = _model.pageList4;
        
        _balance1Array = _model.balance1Array;
        _balance2Array = _model.balance2Array;
        _income1Array = _model.income1Array;
        _income2Array = _model.income2Array;
        _cashFlow1Array = _model.cashFlow1Array;
        _cashFlow2Array = _model.cashFlow2Array;
        _financialRatio1Array = _model.financialRatio1Array;
        _financialRatio2Array = _model.financialRatio2Array;
        
        _categoryList = [[NSArray alloc] initWithObjects:
                        NSLocalizedStringFromTable(@"累計", @"Finance", @"累計"),
                        NSLocalizedStringFromTable(@"單季", @"Finance", @"單季"),
                        nil];
        
        _typeList = [[NSArray alloc] initWithObjects:
                    NSLocalizedStringFromTable(@"$", @"Finance", @"$"),
                    NSLocalizedStringFromTable(@"%", @"Finance", @"%"),
                    NSLocalizedStringFromTable(@"$+%", @"Finance", @"$+%"),
                    nil];
        
    }
    return self;
}

- (void)removeAllData {
    [_lock lock];
    
    [_balance1Array removeAllObjects];
    [_balance2Array removeAllObjects];
    [_income1Array removeAllObjects];
    [_income2Array removeAllObjects];
    [_cashFlow1Array removeAllObjects];
    [_cashFlow2Array removeAllObjects];
    [_financialRatio1Array removeAllObjects];
    [_financialRatio1Array removeAllObjects];
    
    [_lock unlock];
}

- (void)searchAllSheetWithSecurityNumber:(UInt32)securityNumber dataType:(char)dataType searchStartDate:(NSDate *)searchDate {
    
    [_model searchAllSheetWithSecurityNumber:securityNumber dataType:dataType searchStartDate:searchDate];
}

@end

@implementation FSCashFlowCN : NSObject
- (instancetype)initWithBlankData {
    if (self = [super init]) {
        _op_cash_flow = [[FSBValueFormat alloc] init];
        _invest_cash_flow = [[FSBValueFormat alloc] init];
        _fm_cash_flow = [[FSBValueFormat alloc] init];
    }
    return self;
}
@end

@implementation FSBalanceSheetCN : NSObject
- (instancetype)initWithBlankData {
    if (self = [super init]) {
        _current_asset = [[FSBValueFormat alloc] init];
        _l_term_invest = [[FSBValueFormat alloc] init];
        _fixed_asset = [[FSBValueFormat alloc] init];
        _other_asset = [[FSBValueFormat alloc] init];
        _total_asset = [[FSBValueFormat alloc] init];
        _current_debt = [[FSBValueFormat alloc] init];
        _l_term_loan = [[FSBValueFormat alloc] init];
        _other_liabilities_n_reserves = [[FSBValueFormat alloc] init];
        _total_debt = [[FSBValueFormat alloc] init];
        _equity = [[FSBValueFormat alloc] init];
        _preferred_stock_equity = [[FSBValueFormat alloc] init];
        _retained_earning = [[FSBValueFormat alloc] init];
        _undivided_profits = [[FSBValueFormat alloc] init];
        _minority_interest = [[FSBValueFormat alloc] init];
        _total_equity = [[FSBValueFormat alloc] init];
        _liabilities_n_total_equity = [[FSBValueFormat alloc] init];
    }
    return self;
}
@end

@implementation FSIncomeStatementCN: NSObject
- (instancetype)initWithBlankData {
    if (self = [super init]) {
        _net_sales = [[FSBValueFormat alloc] init];
        _costs_of_goods_sold = [[FSBValueFormat alloc] init];
        _gross_profit = [[FSBValueFormat alloc] init];
        _total_expanse = [[FSBValueFormat alloc] init];
        _net_op_income = [[FSBValueFormat alloc] init];
        _total_non_operating_income = [[FSBValueFormat alloc] init];
        _total_non_business_expense = [[FSBValueFormat alloc] init];
        _n_income_bt = [[FSBValueFormat alloc] init];
        _tax_expanse = [[FSBValueFormat alloc] init];
        _net_profit = [[FSBValueFormat alloc] init];
        _eps = [[FSBValueFormat alloc] init];
    }
    return self;
}
@end

@implementation FSFinancialRatioCN : NSObject
- (instancetype)initWithBlankData {
    if (self = [super init]) {
        _g_profit_ratio = [[FSBValueFormat alloc] init];
        _op_profit_ratio = [[FSBValueFormat alloc] init];
        _net_income_ratio = [[FSBValueFormat alloc] init];
        _net_value = [[FSBValueFormat alloc] init];
        _sale_growth_ratio = [[FSBValueFormat alloc] init];
        _current_ratio = [[FSBValueFormat alloc] init];
        _quick_ratio = [[FSBValueFormat alloc] init];
        _debt2asset = [[FSBValueFormat alloc] init];
        _debt2equity = [[FSBValueFormat alloc] init];
    }
    return self;
}
@end