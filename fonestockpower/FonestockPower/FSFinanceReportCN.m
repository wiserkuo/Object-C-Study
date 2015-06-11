//
//  FSFinanceReportCN.m
//  FonestockPower
//
//  Created by Connor on 2015/5/19.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSFinanceReportCN.h"
#import "FSInstantInfoWatchedPortfolio.h"

@implementation FSFinanceReportCN

- (instancetype)init {
    if (self = [super init]) {
        //notifyObj = nil;
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        FSDatabaseAgent *dbAgent = dataModel.mainDB;
        [dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
            // 建立資料庫
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType, PRIMARY KEY (DataDate, Symbol, FieldName, ReportType));"];
        }];
        
        
#pragma mark 陸股資料表欄位初始化
        _pageList1 = [[NSArray alloc] initWithObjects:
                     NSLocalizedStringFromTable(@"流動資產", @"Finance", @"流動資產"),
                     NSLocalizedStringFromTable(@"長期投資", @"Finance", @"長期投資"),
                     NSLocalizedStringFromTable(@"固定資產", @"Finance", @"固定資產"),
                     NSLocalizedStringFromTable(@"其他資產", @"Finance", @"其他資產"),
                     NSLocalizedStringFromTable(@"資產總額", @"Finance", @"資產總額"),
                     NSLocalizedStringFromTable(@"流動負債", @"Finance", @"流動負債"),
                     NSLocalizedStringFromTable(@"長期負債", @"Finance", @"長期負債"),
                     NSLocalizedStringFromTable(@"其他負債及準備", @"Finance", @"其他負債及準備"),
                     NSLocalizedStringFromTable(@"負債總額", @"Finance", @"負債總額"),
                     NSLocalizedStringFromTable(@"普通股股本", @"Finance", @"普通股股本"),
                     NSLocalizedStringFromTable(@"優先股股本", @"Finance", @"優先股股本"),
                     NSLocalizedStringFromTable(@"資本公積", @"Finance", @"資本公積"),
                     NSLocalizedStringFromTable(@"未分配盈餘", @"Finance", @"未分配盈餘"),
                     NSLocalizedStringFromTable(@"少數股權", @"Finance", @"少數股權"),
                     NSLocalizedStringFromTable(@"所有者權益總額", @"Finance", @"所有者權益總額"),
                     NSLocalizedStringFromTable(@"負債及所有者權益總額", @"Finance", @"負債及所有者權益總額"),
                     nil];
        
        _pageList2 = [[NSArray alloc] initWithObjects:
                     NSLocalizedStringFromTable(@"營業收入淨額", @"Finance", @"營業收入淨額"),
                     NSLocalizedStringFromTable(@"營業成本", @"Finance", @"營業成本"),
                     NSLocalizedStringFromTable(@"營業毛利", @"Finance", @"營業毛利"),
                     NSLocalizedStringFromTable(@"營業費用", @"Finance", @"營業費用"),
                     NSLocalizedStringFromTable(@"營業利益", @"Finance", @"營業利益"),
                     NSLocalizedStringFromTable(@"營業外收入合計", @"Finance", @"營業外收入合計"),
                     NSLocalizedStringFromTable(@"營業外支出合計", @"Finance", @"營業外支出合計"),
                     NSLocalizedStringFromTable(@"稅前淨利", @"Finance", @"稅前淨利"),
                     NSLocalizedStringFromTable(@"所得稅費用", @"Finance", @"所得稅費用"),
                     NSLocalizedStringFromTable(@"本期稅後淨利", @"Finance", @"本期稅後淨利"),
                     NSLocalizedStringFromTable(@"每股盈餘", @"Finance", @"每股盈餘"),
                     
                     nil];
        
        _pageList3 = [[NSArray alloc] initWithObjects:
                     NSLocalizedStringFromTable(@"來自營運的現金流量", @"Finance", @"來自營運的現金流量"),
                     NSLocalizedStringFromTable(@"投資活動之現金流量", @"Finance", @"投資活動之現金流量"),
                     NSLocalizedStringFromTable(@"融資活動之現金流量", @"Finance", @"融資活動之現金流量"),
                     nil];
        
        _pageList4 = [[NSArray alloc] initWithObjects:
                     NSLocalizedStringFromTable(@"獲利能力", @"Finance", @"獲利能力"),
                     NSLocalizedStringFromTable(@"營業毛利率", @"Finance", @"營業毛利率"),
                     NSLocalizedStringFromTable(@"營業利益率", @"Finance", @"營業利益率"),
                     NSLocalizedStringFromTable(@"稅前淨利率", @"Finance", @"稅前淨利率"),
                     NSLocalizedStringFromTable(@"稅後淨利率", @"Finance", @"稅後淨利率"),
                     NSLocalizedStringFromTable(@"每股淨值", @"Finance", @"每股淨值"),
                     NSLocalizedStringFromTable(@"每股營業額", @"Finance", @"每股營業額"),
                     NSLocalizedStringFromTable(@"每股營業利益", @"Finance", @"每股營業利益"),
                     NSLocalizedStringFromTable(@"每股稅前淨利", @"Finance", @"每股稅前淨利"),
                     NSLocalizedStringFromTable(@"每股稅後淨利", @"Finance", @"每股稅後淨利"),
                     NSLocalizedStringFromTable(@"股東權益報酬率", @"Finance", @"股東權益報酬率"),
                     NSLocalizedStringFromTable(@"成長能力", @"Finance", @"成長能力"),
                     NSLocalizedStringFromTable(@"營收成長率", @"Finance", @"營收成長率"),
                     NSLocalizedStringFromTable(@"營業利益成長率", @"Finance", @"營業利益成長率"),
                     NSLocalizedStringFromTable(@"稅前淨利成長率", @"Finance", @"稅前淨利成長率"),
                     NSLocalizedStringFromTable(@"稅後淨利成長率", @"Finance", @"稅後淨利成長率"),
                     NSLocalizedStringFromTable(@"總資產成長率", @"Finance", @"總資產成長率"),
                     NSLocalizedStringFromTable(@"淨值成長率", @"Finance", @"淨值成長率"),
                     NSLocalizedStringFromTable(@"固定資產成長率", @"Finance", @"固定資產成長率"),
                     NSLocalizedStringFromTable(@"償債能力", @"Finance", @"償債能力"),
                     NSLocalizedStringFromTable(@"流動比率", @"Finance", @"流動比率"),
                     NSLocalizedStringFromTable(@"速動比率", @"Finance", @"速動比率"),
                     NSLocalizedStringFromTable(@"負債比率", @"Finance", @"負債比率"),
                     NSLocalizedStringFromTable(@"現金流量比率", @"Finance", @"現金流量比率"),
                     NSLocalizedStringFromTable(@"經營能力", @"Finance", @"經營能力"),
                     NSLocalizedStringFromTable(@"固定資產週轉率", @"Finance", @"固定資產週轉率"),
                     NSLocalizedStringFromTable(@"總資產週轉率", @"Finance", @"總資產週轉率"),
                     NSLocalizedStringFromTable(@"淨值週轉率", @"Finance", @"淨值週轉率"),
                     NSLocalizedStringFromTable(@"財務結構", @"Finance", @"財務結構"),
                     NSLocalizedStringFromTable(@"負債淨值比率", @"Finance", @"負債淨值比率"),
                     nil];
        
        
        _stockDict = [[NSMutableDictionary alloc] init];
        

        
    }
    

    return self;
}
- (void)setTargetNotify:(id)obj
{
    notifyObj = obj;
}
- (void)searchAllSheetWithSecurityNumber:(UInt32)securityNumber dataType:(char)dataType searchStartDate:(NSDate *)searchDate {
    
    if (securityNumber != 0) {
        FSFinanceReportCNOut *packout = [[FSFinanceReportCNOut alloc] initWithSecurityNumber:securityNumber dataType:'C' queryType:FSFinanceReportQueryTypeInterval searchStartDate:[searchDate uint16Value] endDate:[[NSDate date] uint16Value]];
        
        packout.financeReportCommend = FSFinanceReportCNCommendBalanceSheet;
        packout.dataType = 'Q';
        [FSDataModelProc sendData:self WithPacket:packout];
        
//        packout.financeReportCommend = FSFinanceReportCNCommendIncomeStatementSheet;
//        packout.dataType = 'C';
//        [FSDataModelProc sendData:self WithPacket:packout];
//        
//        packout.financeReportCommend = FSFinanceReportCNCommendCashFlowSheet;
//        packout.dataType = 'C';
//        [FSDataModelProc sendData:self WithPacket:packout];
//        
//        packout.financeReportCommend = FSFinanceReportCNCommendFinancialRatioSheet;
//        packout.dataType = 'Q';
//        [FSDataModelProc sendData:self WithPacket:packout];
    }
    
}
- (FSBValueFormat*)getData:(NSString*)stockType date:(NSString*)date ids:(NSString*)ids indexPath:(NSIndexPath *)indexPath{
    FSInstantInfoWatchedPortfolio *watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    FSBValueFormat *value;
    NSString* identCodeSymbol;
    if([stockType isEqualToString:@"stock1"]) identCodeSymbol=[watchPortfolio.portfolioItem getIdentCodeSymbol];
    else if([stockType isEqualToString:@"stock2"]) identCodeSymbol=[watchPortfolio.comparedPortfolioItem getIdentCodeSymbol];
    if([ids isEqualToString:@"BalanceSheet"]){
        FSBalanceSheetCN *balanceSheet= [[[_stockDict objectForKey:identCodeSymbol] objectForKey:date] objectForKey:ids];
        switch(indexPath.row){
            case 0:
                value=balanceSheet.current_asset;
                break;
            case 1: value=balanceSheet.l_term_invest;
                break;
            case 2: value=balanceSheet.fixed_asset;
                break;
            case 3: value=balanceSheet.other_asset;
                break;
            case 4: value=balanceSheet.total_asset;
                break;
            case 5: value=balanceSheet.current_debt;
                break;
            case 6: value=balanceSheet.l_term_loan;
                break;
            case 7: value=balanceSheet.other_liabilities_n_reserves;
                break;
            case 8: value=balanceSheet.total_debt;
                break;
            case 9: value=balanceSheet.equity;
                break;
            case 10: value=balanceSheet.preferred_stock_equity;
                break;
            case 11: value=balanceSheet.retained_earning;
                break;
            case 12: value=balanceSheet.undivided_profits;
                break;
            case 13: value=balanceSheet.minority_interest;
                break;
            case 14: value=balanceSheet.total_equity;
                break;
            case 15: value=balanceSheet.liabilities_n_total_equity;
                break;
        }
    }
    return value;
}

////BalanceSheetCN
//[_bsKeyArray addObject:@"current_asset"];
//[_bsKeyArray addObject:@"l_term_invest"];
//[_bsKeyArray addObject:@"fixed_asset"];
//[_bsKeyArray addObject:@"other_asset"];
//[_bsKeyArray addObject:@"total_asset"];
//[_bsKeyArray addObject:@"current_debt"];
//[_bsKeyArray addObject:@"l_term_loan"];
//[_bsKeyArray addObject:@"other_liabilities_n_reserves"];
//[_bsKeyArray addObject:@"total_debt"];
//[_bsKeyArray addObject:@"equity"];
//[_bsKeyArray addObject:@"preferred_stock_equity"];
//[_bsKeyArray addObject:@"retained_earning"];
//[_bsKeyArray addObject:@"undivided_profits"];
//[_bsKeyArray addObject:@"minority_interest"];
//[_bsKeyArray addObject:@"total_equity"];
//[_bsKeyArray addObject:@"liabilities_n_total_equity"];
//
////IncomeStetementCN
//[_isKeyArray addObject:@"net_sales"];
//[_isKeyArray addObject:@"costs_of_goods_sold"];
//[_isKeyArray addObject:@"gross_profit"];
//[_isKeyArray addObject:@"total_expanse"];
//[_isKeyArray addObject:@"net_op_income"];
//[_isKeyArray addObject:@"total_non_operating_income"];
//[_isKeyArray addObject:@"total_non_business_expense"];
//[_isKeyArray addObject:@"n_income_bt"];
//[_isKeyArray addObject:@"tax_expanse"];
//[_isKeyArray addObject:@"net_profit"];
//[_isKeyArray addObject:@"eps"];
//
////CashFlowCN
//[_cfKeyArray addObject: @"op_cash_flow"];
//[_cfKeyArray addObject: @"invest_cash_flow"];
//[_cfKeyArray addObject: @"fm_cash_flow"];
//
////FinancialRatioCN
//[_frKeyArray addObject:@"g_profit_ratio"];
//[_frKeyArray addObject:@"op_profit_ratio"];
//[_frKeyArray addObject:@"net_income_ratio"];
//[_frKeyArray addObject:@"net_value"];
//[_frKeyArray addObject:@"sale_growth_ratio"];
//[_frKeyArray addObject:@"current_ratio"];
//[_frKeyArray addObject:@"quick_ratio"];
//[_frKeyArray addObject:@"debt2asset"];
//[_frKeyArray addObject:@"debt2equity"];
//





//資產負債表
-(void)BalanceSheetCallBack:(FSBalanceSheetCNIn *)data
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *identCodeSymbol;
    
    FSInstantInfoWatchedPortfolio *watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    if (watchPortfolio.portfolioItem->commodityNo == data.commodityNum) {
        identCodeSymbol = [watchPortfolio.portfolioItem getIdentCodeSymbol];
        _reporType = @"BalanceSheet1";
    }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data.commodityNum){
        identCodeSymbol = [watchPortfolio.comparedPortfolioItem getIdentCodeSymbol];
        _reporType = @"BalanceSheet2";
    }else{
        return;
    }

    [dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (FSBalanceSheetCN *balance in data.balanceSheetArray) {
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"current_asset",
             [NSString stringWithFormat:@"%f",
              balance.current_asset.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"l_term_invest",
             [NSString stringWithFormat:@"%f",
              balance.l_term_invest.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"fixed_asset",
             [NSString stringWithFormat:@"%f",
              balance.fixed_asset.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"other_asset",
             [NSString stringWithFormat:@"%f",
              balance.other_asset.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"total_asset",
             [NSString stringWithFormat:@"%f",
              balance.total_asset.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"current_debt",
             [NSString stringWithFormat:@"%f",
              balance.current_debt.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"l_term_loan",
             [NSString stringWithFormat:@"%f",
              balance.l_term_loan.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"other_liabilities_n_reserves",
             [NSString stringWithFormat:@"%f",
              balance.other_liabilities_n_reserves.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"total_debt",
             [NSString stringWithFormat:@"%f",
              balance.total_debt.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"equity",
             [NSString stringWithFormat:@"%f",
              balance.equity.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"preferred_stock_equity",
             [NSString stringWithFormat:@"%f",
              balance.preferred_stock_equity.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"retained_earning",
             [NSString stringWithFormat:@"%f",
              balance.retained_earning.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"undivided_profits",
             [NSString stringWithFormat:@"%f",
              balance.undivided_profits.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"minority_interest",
             [NSString stringWithFormat:@"%f",
              balance.minority_interest.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"total_equity",
             [NSString stringWithFormat:@"%f",
              balance.total_equity.calcValue]
             ,@"BalanceSheet"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:balance.data_date.date16],
             identCodeSymbol, @"liabilities_n_total_equity",
             [NSString stringWithFormat:@"%f",
              balance.liabilities_n_total_equity.calcValue]
             ,@"BalanceSheet"];
            
            
        }
    }];
    
    
    [self searchFinanceDataDateWithReportType:@"BalanceSheet" identCodeSymbol:identCodeSymbol];

}




//- (NSMutableDictionary *)searchFinanceDataDateWithReportType:(NSString *)reportType identCodeSymbol:(NSString *)ids {
//    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
//    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
//    FSDatabaseAgent *dbAgent = dataModel.mainDB;
//    
//    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
//        FMResultSet *message = [db executeQuery:@"SELECT FieldName, Amount FROM FinanceReport WHERE DataDate >= ? AND DataDate <= ? AND Symbol = ? AND ReportType = ?", [NSNumber numberWithUnsignedInt:startDay], [NSNumber numberWithUnsignedInt:endDay], ids, reportType];
//        while ([message next]) {
//            NSString *fieldName = [message stringForColumn:@"FieldName"];
//            NSString * amount = [message stringForColumn:@"Amount"];
//            [dataDict setObject:amount forKey:fieldName];
//        }
//    }];
//    return dataDict;
//}


//損益表
-(void)IncomeStatementCallBack:(FSIncomeStatementCNIn *)data
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *identCodeSymbol;
    
    FSInstantInfoWatchedPortfolio *watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    if (watchPortfolio.portfolioItem->commodityNo == data.commodityNum) {
        identCodeSymbol = [watchPortfolio.portfolioItem getIdentCodeSymbol];
        _reporType = @"IncomeStatement1";
    }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data.commodityNum){
        identCodeSymbol = [watchPortfolio.comparedPortfolioItem getIdentCodeSymbol];
        _reporType = @"IncomeStatement2";
    }else{
        return;
    }
    
    
    
    [dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (FSIncomeStatementCN *incomeStatement in data.incomeStatementArray) {
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:incomeStatement.data_date.date16],
             identCodeSymbol,
             @"net_sales",
             [NSString stringWithFormat:@"%f",incomeStatement.net_sales.calcValue]
             , @"IncomeStatement"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:incomeStatement.data_date.date16],
             identCodeSymbol,
             @"costs_of_goods_sold",
             [NSString stringWithFormat:@"%f",incomeStatement.costs_of_goods_sold.calcValue]
             , @"IncomeStatement"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:incomeStatement.data_date.date16],
             identCodeSymbol,
             @"gross_profit",
             [NSString stringWithFormat:@"%f",incomeStatement.gross_profit.calcValue]
             , @"IncomeStatement"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:incomeStatement.data_date.date16],
             identCodeSymbol,
             @"total_expanse",
             [NSString stringWithFormat:@"%f",incomeStatement.total_expanse.calcValue]
             , @"IncomeStatement"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:incomeStatement.data_date.date16],
             identCodeSymbol,
             @"net_op_income",
             [NSString stringWithFormat:@"%f",incomeStatement.net_op_income.calcValue]
             , @"IncomeStatement"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:incomeStatement.data_date.date16],
             identCodeSymbol,
             @"total_non_operating_income",
             [NSString stringWithFormat:@"%f",incomeStatement.total_non_operating_income.calcValue]
             , @"IncomeStatement"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:incomeStatement.data_date.date16],
             identCodeSymbol,
             @"total_non_business_expense",
             [NSString stringWithFormat:@"%f",incomeStatement.total_non_business_expense.calcValue]
             , @"IncomeStatement"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:incomeStatement.data_date.date16],
             identCodeSymbol,
             @"n_income_bt",
             [NSString stringWithFormat:@"%f",incomeStatement.n_income_bt.calcValue]
             , @"IncomeStatement"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:incomeStatement.data_date.date16],
             identCodeSymbol,
             @"tax_expanse",
             [NSString stringWithFormat:@"%f",incomeStatement.tax_expanse.calcValue]
             , @"IncomeStatement"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:incomeStatement.data_date.date16],
             identCodeSymbol,
             @"net_profit",
             [NSString stringWithFormat:@"%f",incomeStatement.net_profit.calcValue]
             , @"IncomeStatement"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:incomeStatement.data_date.date16],
             identCodeSymbol,
             @"eps",
             [NSString stringWithFormat:@"%f",incomeStatement.eps.calcValue]
             , @"IncomeStatement"];
            
        }
    }];
    
    
    [self searchFinanceDataDateWithReportType:@"IncomeStatement" identCodeSymbol:identCodeSymbol];
    
    
//    if(notifyObj){
//        if (watchPortfolio.portfolioItem->commodityNo == data->commodityNum) {
//            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"Income1" waitUntilDone:NO];
//        }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data->commodityNum){
//            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"Income2" waitUntilDone:NO];
//        }
//        
//    }
}

//現金流量表
- (void)CashFlowCallBack:(FSCashFlowCNIn *)data
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    NSString *identCodeSymbol;
    FSInstantInfoWatchedPortfolio *watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    if (watchPortfolio.portfolioItem->commodityNo == data.commodityNum) {
        identCodeSymbol = [watchPortfolio.portfolioItem getIdentCodeSymbol];
        _reporType = @"CashFlow1";
    } else if (watchPortfolio.comparedPortfolioItem->commodityNo == data.commodityNum){
        identCodeSymbol = [watchPortfolio.comparedPortfolioItem getIdentCodeSymbol];
        _reporType = @"CashFlow2";
    } else {
        return;
    }
    
    [dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (FSCashFlowCN *cashFlow in data.cashFlowArray) {
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:cashFlow.data_date.date16],
             identCodeSymbol,
             @"op_cash_flow",
             [NSString stringWithFormat:@"%f",cashFlow.op_cash_flow.calcValue]
             , @"CashFlow"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:cashFlow.data_date.date16],
             identCodeSymbol,
             @"invest_cash_flow",
             [NSString stringWithFormat:@"%f",cashFlow.invest_cash_flow.calcValue]
             , @"CashFlow"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:cashFlow.data_date.date16],
             identCodeSymbol,
             @"fm_cash_flow",
             [NSString stringWithFormat:@"%f",cashFlow.fm_cash_flow.calcValue]
             , @"CashFlow"];
            
        }
    }];
    
    
    [self searchFinanceDataDateWithReportType:@"CashFlow" identCodeSymbol:identCodeSymbol];
    
    
//    if(notifyObj){
//        if (watchPortfolio.portfolioItem->commodityNo == data->commodityNum) {
//            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"CashFlow1" waitUntilDone:NO];
//        }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data->commodityNum){
//            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"CashFlow2" waitUntilDone:NO];
//        }
//        
//    }
}




//財務比率
-(void)FinancialRatioCallBack:(FSFinancialRatioCNIn *)data {
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *identCodeSymbol;
    
    FSInstantInfoWatchedPortfolio *watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    if (watchPortfolio.portfolioItem->commodityNo == data.commodityNum) {
        identCodeSymbol = [watchPortfolio.portfolioItem getIdentCodeSymbol];
        _reporType = @"FinancialRatio1";
    }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data.commodityNum){
        identCodeSymbol = [watchPortfolio.comparedPortfolioItem getIdentCodeSymbol];
        _reporType = @"FinancialRatio2";
    }else{
        return;
    }
    
    
    [dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (FSFinancialRatioCN *financialRatioCN in data.financialRatioArray) {
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:financialRatioCN.data_date.date16],
             identCodeSymbol,
             @"g_profit_ratio",
             [NSString stringWithFormat:@"%f",financialRatioCN.g_profit_ratio.calcValue]
             , @"FinancialRatio"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:financialRatioCN.data_date.date16],
             identCodeSymbol,
             @"op_profit_ratio",
             [NSString stringWithFormat:@"%f",financialRatioCN.op_profit_ratio.calcValue]
             , @"FinancialRatio"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:financialRatioCN.data_date.date16],
             identCodeSymbol,
             @"net_income_ratio",
             [NSString stringWithFormat:@"%f",financialRatioCN.net_income_ratio.calcValue]
             , @"FinancialRatio"];
            
            
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:financialRatioCN.data_date.date16],
             identCodeSymbol,
             @"net_value",
             [NSString stringWithFormat:@"%f",financialRatioCN.net_value.calcValue]
             , @"FinancialRatio"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:financialRatioCN.data_date.date16],
             identCodeSymbol,
             @"sale_growth_ratio",
             [NSString stringWithFormat:@"%f",financialRatioCN.sale_growth_ratio.calcValue]
             , @"FinancialRatio"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:financialRatioCN.data_date.date16],
             identCodeSymbol,
             @"current_ratio",
             [NSString stringWithFormat:@"%f",financialRatioCN.current_ratio.calcValue]
             , @"FinancialRatio"];

            
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:financialRatioCN.data_date.date16],
             identCodeSymbol,
             @"quick_ratio",
             [NSString stringWithFormat:@"%f",financialRatioCN.quick_ratio.calcValue]
             , @"FinancialRatio"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:financialRatioCN.data_date.date16],
             identCodeSymbol,
             @"debt2asset",
             [NSString stringWithFormat:@"%f",financialRatioCN.debt2asset.calcValue]
             , @"FinancialRatio"];
            
            [db executeUpdate:@"REPLACE INTO NewFinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",
             [NSNumber numberWithInt:financialRatioCN.data_date.date16],
             identCodeSymbol,
             @"debt2equity",
             [NSString stringWithFormat:@"%f",financialRatioCN.debt2equity.calcValue]
             , @"FinancialRatio"];

            
        }
    }];
    
    [self searchFinanceDataDateWithReportType:@"FinancialRatio" identCodeSymbol:identCodeSymbol];
    
//    if(notifyObj){
//        if (watchPortfolio.portfolioItem->commodityNo == data->commodityNum) {
//            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"FinancialRatio1" waitUntilDone:NO];
//        }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data->commodityNum){
//            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"FinancialRatio2" waitUntilDone:NO];
//        }
//        
//    }
}




- (void)searchFinanceDataDateWithReportType:(NSString *)reportType identCodeSymbol:(NSString *)ids {
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    FSInstantInfoWatchedPortfolio *watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM"];
    
    
    NSMutableDictionary *dateDict = [_stockDict objectForKey:ids];
    if (!dateDict) {
        dateDict = [[NSMutableDictionary alloc] init];
    }

    [dbAgent inDatabase: ^(FMDatabase *db) {
        
        FMResultSet *message = [db executeQuery:@"SELECT DataDate, Symbol, FieldName, Amount, ReportType FROM NewFinanceReport WHERE Symbol = ? AND ReportType = ? ORDER BY DataDate DESC", ids, reportType];
        while ([message next]) {
            
            NSDate *dataDate = [[NSNumber numberWithInt:[message intForColumn:@"DataDate"]] uint16ToDate];
            NSString *dataDateString = [dateFormatter stringFromDate:dataDate];
            NSLog(@"dataDateString=%@\n",dataDateString);
            NSMutableDictionary *mutiData = [dateDict objectForKey:dataDateString];
            if (!mutiData) {
                mutiData = [[NSMutableDictionary alloc] init];
            }
            
            // 資產負債表
            if ([@"BalanceSheet" isEqualToString:reportType]) {
                
                FSBalanceSheetCN *balanceSheet = [mutiData objectForKey:reportType];
                if (!balanceSheet) {
                    balanceSheet = [[FSBalanceSheetCN alloc] initWithBlankData];
                }
                
                NSString *fieldName = [message stringForColumn:@"FieldName"];
                double value = [[message stringForColumn:@"Amount"] doubleValue];
                
                if ([@"current_asset" isEqualToString:fieldName]) {
                    balanceSheet.current_asset.calcValue = value;
                }
                else if ([@"l_term_invest" isEqualToString:fieldName]) {
                    balanceSheet.l_term_invest.calcValue = value;
                }
                else if ([@"fixed_asset" isEqualToString:fieldName]) {
                    balanceSheet.fixed_asset.calcValue = value;
                }
                else if ([@"other_asset" isEqualToString:fieldName]) {
                    balanceSheet.other_asset.calcValue = value;
                }
                else if ([@"total_asset" isEqualToString:fieldName]) {
                    balanceSheet.total_asset.calcValue = value;
                }
                else if ([@"current_debt" isEqualToString:fieldName]) {
                    balanceSheet.current_debt.calcValue = value;
                }
                else if ([@"l_term_loan" isEqualToString:fieldName]) {
                    balanceSheet.l_term_loan.calcValue = value;
                }
                else if ([@"other_liabilities_n_reserves" isEqualToString:fieldName]) {
                    balanceSheet.other_liabilities_n_reserves.calcValue = value;
                }
                else if ([@"total_debt" isEqualToString:fieldName]) {
                    balanceSheet.total_debt.calcValue = value;
                }
                else if ([@"equity" isEqualToString:fieldName]) {
                    balanceSheet.equity.calcValue = value;
                }
                else if ([@"preferred_stock_equity" isEqualToString:fieldName]) {
                    balanceSheet.preferred_stock_equity.calcValue = value;
                }
                else if ([@"retained_earning" isEqualToString:fieldName]) {
                    balanceSheet.retained_earning.calcValue = value;
                }
                else if ([@"undivided_profits" isEqualToString:fieldName]) {
                    balanceSheet.undivided_profits.calcValue = value;
                }
                else if ([@"minority_interest" isEqualToString:fieldName]) {
                    balanceSheet.minority_interest.calcValue = value;
                }
                else if ([@"total_equity" isEqualToString:fieldName]) {
                    balanceSheet.total_equity.calcValue = value;
                }
                else if ([@"liabilities_n_total_equity" isEqualToString:fieldName]) {
                    balanceSheet.liabilities_n_total_equity.calcValue = value;
                }
                
                
                [mutiData setObject:balanceSheet forKey:reportType];

            }
            
            
            
            
            // 損益表
            if ([@"IncomeStatement" isEqualToString:reportType]) {
                
                FSIncomeStatementCN *incomeStatement = [mutiData objectForKey:reportType];
                if (!incomeStatement) {
                    incomeStatement = [[FSIncomeStatementCN alloc] initWithBlankData];
                }
                
                NSString *fieldName = [message stringForColumn:@"FieldName"];
                double value = [[message stringForColumn:@"Amount"] doubleValue];
                
                if ([@"net_sales" isEqualToString:fieldName]) {
                    incomeStatement.net_sales.calcValue = value;
                }
                else if ([@"costs_of_goods_sold" isEqualToString:fieldName]) {
                    incomeStatement.costs_of_goods_sold.calcValue = value;
                }
                else if ([@"gross_profit" isEqualToString:fieldName]) {
                    incomeStatement.gross_profit.calcValue = value;
                }
                else if ([@"total_expanse" isEqualToString:fieldName]) {
                    incomeStatement.total_expanse.calcValue = value;
                }
                else if ([@"net_op_income" isEqualToString:fieldName]) {
                    incomeStatement.net_op_income.calcValue = value;
                }
                else if ([@"total_non_operating_income" isEqualToString:fieldName]) {
                    incomeStatement.total_non_operating_income.calcValue = value;
                }
                else if ([@"total_non_business_expense" isEqualToString:fieldName]) {
                    incomeStatement.total_non_business_expense.calcValue = value;
                }
                else if ([@"n_income_bt" isEqualToString:fieldName]) {
                    incomeStatement.n_income_bt.calcValue = value;
                }
                else if ([@"tax_expanse" isEqualToString:fieldName]) {
                    incomeStatement.tax_expanse.calcValue = value;
                }
                else if ([@"net_profit" isEqualToString:fieldName]) {
                    incomeStatement.net_profit.calcValue = value;
                }
                else if ([@"eps" isEqualToString:fieldName]) {
                    incomeStatement.eps.calcValue = value;
                }
                
                [mutiData setObject:incomeStatement forKey:reportType];
                
            }
            
            
            
            
            // 現金流量表
            if ([@"CashFlow" isEqualToString:reportType]) {
                
                FSCashFlowCN *incomeStatement = [mutiData objectForKey:reportType];
                if (!incomeStatement) {
                    incomeStatement = [[FSCashFlowCN alloc] initWithBlankData];
                }
                
                NSString *fieldName = [message stringForColumn:@"FieldName"];
                double value = [[message stringForColumn:@"Amount"] doubleValue];
                
                if ([@"op_cash_flow" isEqualToString:fieldName]) {
                    incomeStatement.op_cash_flow.calcValue = value;
                }
                else if ([@"invest_cash_flow" isEqualToString:fieldName]) {
                    incomeStatement.invest_cash_flow.calcValue = value;
                }
                else if ([@"fm_cash_flow" isEqualToString:fieldName]) {
                    incomeStatement.fm_cash_flow.calcValue = value;
                }
                
                [mutiData setObject:incomeStatement forKey:reportType];
                
            }
            
            
            // 財務比率
            if ([@"FinancialRatio" isEqualToString:reportType]) {
                
                FSFinancialRatioCN *financialRatio = [mutiData objectForKey:reportType];
                if (!financialRatio) {
                    financialRatio = [[FSFinancialRatioCN alloc] initWithBlankData];
                }
                
                NSString *fieldName = [message stringForColumn:@"FieldName"];
                double value = [[message stringForColumn:@"Amount"] doubleValue];
                
                if ([@"g_profit_ratio" isEqualToString:fieldName]) {
                    financialRatio.g_profit_ratio.calcValue = value;
                }
                else if ([@"op_profit_ratio" isEqualToString:fieldName]) {
                    financialRatio.op_profit_ratio.calcValue = value;
                }
                else if ([@"net_income_ratio" isEqualToString:fieldName]) {
                    financialRatio.net_income_ratio.calcValue = value;
                }
                else if ([@"net_value" isEqualToString:fieldName]) {
                    financialRatio.net_value.calcValue = value;
                }
                else if ([@"sale_growth_ratio" isEqualToString:fieldName]) {
                    financialRatio.sale_growth_ratio.calcValue = value;
                }
                else if ([@"current_ratio" isEqualToString:fieldName]) {
                    financialRatio.current_ratio.calcValue = value;
                }
                else if ([@"quick_ratio" isEqualToString:fieldName]) {
                    financialRatio.quick_ratio.calcValue = value;
                }
                else if ([@"debt2asset" isEqualToString:fieldName]) {
                    financialRatio.debt2asset.calcValue = value;
                }
                else if ([@"debt2equity" isEqualToString:fieldName]) {
                    financialRatio.debt2equity.calcValue = value;
                }
                
                [mutiData setObject:financialRatio forKey:reportType];
                
            }
            [dateDict setObject:mutiData forKey:dataDateString];
        }
        NSSortDescriptor *SortDescriptor=[NSSortDescriptor sortDescriptorWithKey:Nil ascending:NO selector:@selector(compare:)];
        if([ids isEqualToString:[watchPortfolio.portfolioItem getIdentCodeSymbol]]){
            _date1Array=[[dateDict allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:SortDescriptor]];
        }
        else if([ids isEqualToString:[watchPortfolio.comparedPortfolioItem getIdentCodeSymbol]]){
            _date2Array=[[dateDict allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:SortDescriptor]];
        }
        [_stockDict setObject:dateDict forKey:ids];
    }];

    
    if(notifyObj)
        [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:_reporType waitUntilDone:NO];
    //[notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"BalanceSheet1" waitUntilDone:NO];
}

/*
-(void)setKey{
    
//BalanceSheetCN
    [_bsKeyArray addObject:@"current_asset"];
    [_bsKeyArray addObject:@"l_term_invest"];
    [_bsKeyArray addObject:@"fixed_asset"];
    [_bsKeyArray addObject:@"current_asset"];
    [_bsKeyArray addObject:@"l_term_invest"];
    [_bsKeyArray addObject:@"fixed_asset"];
    [_bsKeyArray addObject:@"other_asset"];
    [_bsKeyArray addObject:@"total_asset"];
    [_bsKeyArray addObject:@"current_debt"];
    [_bsKeyArray addObject:@"l_term_loan"];
    [_bsKeyArray addObject:@"other_liabilities_n_reserves"];
    [_bsKeyArray addObject:@"total_debt"];
    [_bsKeyArray addObject:@"equity"];
    [_bsKeyArray addObject:@"preferred_stock_equity"];
    [_bsKeyArray addObject:@"retained_earning"];
    [_bsKeyArray addObject:@"undivided_profits"];
    [_bsKeyArray addObject:@"minority_interest"];
    [_bsKeyArray addObject:@"total_equity"];
    [_bsKeyArray addObject:@"liabilities_n_total_equity"];
    
//IncomeStetementCN
    [_isKeyArray addObject:@"net_sales"];
    [_isKeyArray addObject:@"costs_of_goods_sold"];
    [_isKeyArray addObject:@"gross_profit"];
    [_isKeyArray addObject:@"total_expanse"];
    [_isKeyArray addObject:@"net_op_income"];
    [_isKeyArray addObject:@"total_non_operating_income"];
    [_isKeyArray addObject:@"total_non_business_expense"];
    [_isKeyArray addObject:@"n_income_bt"];
    [_isKeyArray addObject:@"tax_expanse"];
    [_isKeyArray addObject:@"net_profit"];
    [_isKeyArray addObject:@"eps"];

//CashFlowCN
    [_cfKeyArray addObject: @"op_cash_flow"];
    [_cfKeyArray addObject: @"invest_cash_flow"];
    [_cfKeyArray addObject: @"fm_cash_flow"];
        
//FinancialRatioCN
    [_frKeyArray addObject:@"g_profit_ratio"];
    [_frKeyArray addObject:@"op_profit_ratio"];
    [_frKeyArray addObject:@"net_income_ratio"];
    [_frKeyArray addObject:@"net_value"];
    [_frKeyArray addObject:@"sale_growth_ratio"];
    [_frKeyArray addObject:@"current_ratio"];
    [_frKeyArray addObject:@"quick_ratio"];
    [_frKeyArray addObject:@"debt2asset"];
    [_frKeyArray addObject:@"debt2equity"];
        
        
        
    
}*/
@end







@implementation FSFinanceReportCNOut

- (instancetype)initWithSecurityNumber:(UInt32)securityNumber
                              dataType:(char)dataType
                             queryType:(FSFinanceReportQueryType)queryType
                       searchStartDate:(UInt16)startDate {
    
    if (self = [super init]) {
        _dataType = dataType;
        _queryType = FSFinanceReportQueryTypeSpecify;
        _securityNumber = securityNumber;
        _startDate = startDate;
        _financeReportCommend = FSFinanceReportCNCommendBalanceSheet;
    }
    return self;
}

- (instancetype)initWithSecurityNumber:(UInt32)securityNumber
                              dataType:(char)dataType
                             queryType:(FSFinanceReportQueryType)queryType
                       searchStartDate:(UInt16)startDate
                               endDate:(UInt16)endDate {
    
    if (self = [super init]) {
        _dataType = dataType;
        _queryType = FSFinanceReportQueryTypeInterval;
        _securityNumber = securityNumber;
        _startDate = startDate;
        _endDate = endDate;
        _financeReportCommend = FSFinanceReportCNCommendBalanceSheet;
    }
    return self;
}

- (int)getPacketSize {
    if (_queryType == FSFinanceReportQueryTypeSpecify) {
        return 8;
    }
    else if (_queryType == FSFinanceReportQueryTypeInterval) {
        return 10;
    }
    return 0;
}

- (BOOL)encode:(NSObject*)account1 buffer:(char*)buffer length:(int)len {
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead->escape = 0x1B;
    phead->message = 10;
    phead->command = _financeReportCommend;
    
    [CodingUtil setUInt16:(char*)&(phead->size) Value:len];
    tmpPtr+=sizeof(OutPacketHeader);
    
    [CodingUtil setUInt32:&tmpPtr value:_securityNumber needOffset:YES];
    
    *tmpPtr++ = _dataType;
    *tmpPtr++ = _queryType;
    
    [CodingUtil setUInt16:&tmpPtr value:_startDate needOffset:YES];
    if (_queryType == FSFinanceReportQueryTypeInterval) {
        [CodingUtil setUInt16:&tmpPtr value:_endDate needOffset:YES];
    }
    return YES;
}

@end


@implementation FSCashFlowCNIn

- (void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    UInt8 *tmPtr = body;
    
    _commodityNum = commodity;
    
    _type = *tmPtr++;
    int count = *tmPtr++;
    
    _cashFlowArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        FSCashFlowCN *cashFlow = [[FSCashFlowCN alloc] init];
        cashFlow.data_date = [[FSDateFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.op_cash_flow = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.invest_cash_flow = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.fm_cash_flow = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        [_cashFlowArray addObject:cashFlow];
    }
    
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    
    if ([model.financeReportCN respondsToSelector:@selector(CashFlowCallBack:)]) {
        [model.financeReportCN performSelector:@selector(CashFlowCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
}

@end



@implementation FSBalanceSheetCNIn

- (void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    UInt8 *tmPtr = body;
    
    _commodityNum = commodity;
    
    _type = *tmPtr++;
    int count = *tmPtr++;
    
    _balanceSheetArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        FSBalanceSheetCN *balanceSheet = [[FSBalanceSheetCN alloc] init];

        balanceSheet.data_date = [[FSDateFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.current_asset = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.l_term_invest = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.fixed_asset = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.other_asset = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.total_asset = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.current_debt = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.l_term_loan = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.other_liabilities_n_reserves = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.total_debt = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.equity = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.preferred_stock_equity = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.retained_earning = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.undivided_profits = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.minority_interest = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.total_equity = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.liabilities_n_total_equity = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        
        [_balanceSheetArray addObject:balanceSheet];
        
    }
    
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if ([model.financeReportCN respondsToSelector:@selector(BalanceSheetCallBack:)]) {
        [model.financeReportCN performSelector:@selector(BalanceSheetCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
    
}
@end



@implementation FSIncomeStatementCNIn

- (void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    UInt8 *tmPtr = body;
    _commodityNum = commodity;
    
    _type = *tmPtr++;
    int count = *tmPtr++;
    
    _incomeStatementArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        FSIncomeStatementCN *incomeStatement = [[FSIncomeStatementCN alloc] init];
        incomeStatement.data_date = [[FSDateFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.net_sales = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.costs_of_goods_sold = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.gross_profit = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.total_expanse = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.net_op_income = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.total_non_operating_income = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.total_non_business_expense = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.n_income_bt = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.tax_expanse = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.net_profit = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.eps = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        [_incomeStatementArray addObject:incomeStatement];
        
        
    }
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    
    if([model.financeReportCN respondsToSelector:@selector(IncomeStatementCallBack:)]) {
        [model.financeReportCN performSelector:@selector(IncomeStatementCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
    
}
@end


@implementation FSFinancialRatioCNIn

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    UInt8 *tmPtr = body;
    
    _commodityNum = commodity;
    
    _type = *tmPtr++;
    int count = *tmPtr++;
    
    _financialRatioArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        FSFinancialRatioCN *financialRatio = [[FSFinancialRatioCN alloc] init];
        financialRatio.data_date = [[FSDateFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.g_profit_ratio = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.op_profit_ratio = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.net_income_ratio = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.net_value = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.sale_growth_ratio = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.current_ratio = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.quick_ratio = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.debt2asset = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.debt2equity = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        
        [_financialRatioArray addObject:financialRatio];
    }
    
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    
    if([model.financeReportCN respondsToSelector:@selector(FinancialRatioCallBack:)]) {
        [model.financeReportCN performSelector:@selector(FinancialRatioCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
    
}
@end

