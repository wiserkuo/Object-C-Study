//
//  FSFinanceReportUS.m
//  FonestockPower
//
//  Created by Connor on 14/9/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSFinanceReportUS.h"
#import "FSBalanceSheetUSIn.h"
#import "FSFinanceReportUSOut.h"
#import "NSDate+Extensions.h"
#import "FSInstantInfoWatchedPortfolio.h"

@implementation FSFinanceReportUS{
    NSObject * notifyObj;
    FSInstantInfoWatchedPortfolio * watchPortfolio;
}


-(id)init{
    if(self = [super init])
	{
		_bsKeyArray = [[NSMutableArray alloc] init];
        _isKeyArray = [[NSMutableArray alloc] init];
        _cfKeyArray = [[NSMutableArray alloc] init];
        _frKeyArray = [[NSMutableArray alloc] init];
        [self setKey];
	}
	return self;
}

- (void)setTargetNotify:(id)obj
{
	notifyObj = obj;
}


- (void)searchAllSheetWithSecurityNumber:(UInt32)securityNumber dataType:(char)dataType searchStartDate:(NSDate *)searchDate {
    watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    
    FSFinanceReportUSOut *packout = [[FSFinanceReportUSOut alloc] initWithSecurityNumber:securityNumber dataType:'Q' queryType:FSFinanceReportQueryTypeInterval searchStartDate:[searchDate uint16Value] endDate:[[NSDate date] uint16Value]];
    
    packout.financeReportCommend = FSFinanceReportCommendBalanceSheet;
    [FSDataModelProc sendData:self WithPacket:packout];

    packout.financeReportCommend = FSFinanceReportCommendIncomeStatementSheet;
    [FSDataModelProc sendData:self WithPacket:packout];
    
    packout.financeReportCommend = FSFinanceReportCommendCashFlowSheet;
    [FSDataModelProc sendData:self WithPacket:packout];

    packout.financeReportCommend = FSFinanceReportCommendFinancialRatioSheet;
    [FSDataModelProc sendData:self WithPacket:packout];
    
    
    
}


//資產負債表
-(void)BalanceSheetCallBack:(FSBalanceSheetUSIn *)data
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *identCodeSymbol;
    
    if (watchPortfolio.portfolioItem->commodityNo == data->commodityNum) {
        identCodeSymbol = [watchPortfolio.portfolioItem getIdentCodeSymbol];
    }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data->commodityNum){
        identCodeSymbol = [watchPortfolio.comparedPortfolioItem getIdentCodeSymbol];
    }else{
        return;
    }

    for(int i = 0; i<[data->balanceSheetArray count]; i++){
        FSBalanceSheet *balance = [[FSBalanceSheet alloc] init];
        balance = [data->balanceSheetArray objectAtIndex:i];
        
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Cash And Cash Equivalents", [NSString stringWithFormat:@"%f", balance.cashAndCashEquivalents.calcValue] , @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)", [NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Short Term Investments", [NSString stringWithFormat:@"%f",balance.shortTermInvestments.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Net Receivables", [NSString stringWithFormat:@"%f",balance.netReceivables.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Inventory", [NSString stringWithFormat:@"%f",balance.inventory.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Other Current Assets", [NSString stringWithFormat:@"%f",balance.otherCurrentAssets.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Total Current Assets", [NSString stringWithFormat:@"%f",balance.totalCurrentAssets.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Short Term Investments", [NSString stringWithFormat:@"%f",balance.shortTermInvestments.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Long Term Investments", [NSString stringWithFormat:@"%f",balance.longTermInvestments.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Property Plant and Equipment", [NSString stringWithFormat:@"%f",balance.propertyPlantAndEquipment.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Goodwill", [NSString stringWithFormat:@"%f",balance.goodwill.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Intangible Assets", [NSString stringWithFormat:@"%f",balance.intangibleAssets.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Accumulated Amortization", [NSString stringWithFormat:@"%f",balance.accumulatedAmortization.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Other Assets", [NSString stringWithFormat:@"%f",balance.otherAssets.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Deferred Long Term Asset Changes", [NSString stringWithFormat:@"%f",balance.deferredLongTermAssetChanges.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Total Assets", [NSString stringWithFormat:@"%f",balance.totalAssets.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Accounts Payable", [NSString stringWithFormat:@"%f",balance.accountsPayable.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Short/Current Long Term Debt",[NSString stringWithFormat:@"%f",balance.shortCurrentLongTermDebt.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Other Current Liabilities", [NSString stringWithFormat:@"%f",balance.otherCurrentLiabilities.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Total Current Liabilities", [NSString stringWithFormat:@"%f",balance.totalCurrentLiabilities.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Long Term Debt", [NSString stringWithFormat:@"%f",balance.longTermDebt.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Other Liabilities", [NSString stringWithFormat:@"%f",balance.otherLiabilities.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Deferred Long Term Liability Charges", [NSString stringWithFormat:@"%f",balance.deferredLongTermLiabilityCharges.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Minority Interest", [NSString stringWithFormat:@"%f",balance.minorityInterest.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Negative Goodwill", [NSString stringWithFormat:@"%f",balance.negativeGoodwill.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Total Liabilities", [NSString stringWithFormat:@"%f",balance.totalLiabilities.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Misc Stocks Options Warrants", [NSString stringWithFormat:@"%f",balance.miscStocksOptionsWarrants.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Redeemable Preferred Stock", [NSString stringWithFormat:@"%f",balance.redeemablePreferredStock.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Preferred Stock", [NSString stringWithFormat:@"%f",balance.preferredStock.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Common Stock", [NSString stringWithFormat:@"%f",balance.commonStock.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Retained Earnings", [NSString stringWithFormat:@"%f",balance.retainedEarnings.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Treasury Stock", [NSString stringWithFormat:@"%f",balance.treasuryStock.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Capital Surplus", [NSString stringWithFormat:@"%f",balance.capitalSurplus.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Other Stockholder Equity", [NSString stringWithFormat:@"%f",balance.otherStockholderEquity.calcValue], @"BalanceSheet"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:balance.dataDate], identCodeSymbol, @"Total Stockholder Equity", [NSString stringWithFormat:@"%f",balance.totalStockholderEquity.calcValue], @"BalanceSheet"];
        }];
    }
    if(notifyObj){
        if (watchPortfolio.portfolioItem->commodityNo == data->commodityNum) {
            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"BalanceSheet1" waitUntilDone:NO];
        }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data->commodityNum){
            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"BalanceSheet2" waitUntilDone:NO];
        }
        
    }
    
}

-(NSMutableArray *)searchFinanceDataDateWithReportType:(NSString *)reportType IdentCodeSymbol:(NSString *)ids{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT distinct(DataDate) FROM FinanceReport WHERE Symbol = ? AND ReportType = ? ORDER BY DataDate DESC", ids, reportType];
        while ([message next]) {
            int dataDate = [message intForColumn:@"DataDate"];
            [dataArray addObject:[NSNumber numberWithInt:dataDate]];
        }
    }];
    return dataArray;
}

-(NSMutableDictionary *)searchFinanceDataWithIdentCodeSymbol:(NSString *)ids StartDay:(UInt16)startDay EndDay:(UInt16)endDay ReportType:(NSString *)reportType{
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT FieldName, Amount FROM FinanceReport WHERE DataDate >= ? AND DataDate <= ? AND Symbol = ? AND ReportType = ?", [NSNumber numberWithUnsignedInt:startDay], [NSNumber numberWithUnsignedInt:endDay], ids, reportType];
        while ([message next]) {
            NSString *fieldName = [message stringForColumn:@"FieldName"];
            NSString * amount = [message stringForColumn:@"Amount"];
            [dataDict setObject:amount forKey:fieldName];
        }
    }];
    return dataDict;
}

//損益表
-(void)IncomeStatementCallBack:(FSIncomeStatementUSIn*)data
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *identCodeSymbol;
    
    if (watchPortfolio.portfolioItem->commodityNo == data->commodityNum) {
        identCodeSymbol = [watchPortfolio.portfolioItem getIdentCodeSymbol];
    }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data->commodityNum){
        identCodeSymbol = [watchPortfolio.comparedPortfolioItem getIdentCodeSymbol];
    }else{
        return;
    }
    
    for(int i = 0; i<[data->incomeStatementArray count]; i++){
        FSIncomeStatement *incomeStatement = [[FSIncomeStatement alloc] init];
        incomeStatement = [data->incomeStatementArray objectAtIndex:i];
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Total Revenue", [NSString stringWithFormat:@"%f",incomeStatement.totalRevenue.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Cost of Revenue", [NSString stringWithFormat:@"%f",incomeStatement.costofRevenue.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Gross Profit", [NSString stringWithFormat:@"%f",incomeStatement.grossProfit.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Research Development", [NSString stringWithFormat:@"%f",incomeStatement.researchDevelopment.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Selling General and Administrative", [NSString stringWithFormat:@"%f",incomeStatement.sellingGeneralandAdministrative.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Non Recurring", [NSString stringWithFormat:@"%f",incomeStatement.nonRecurring.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Others", [NSString stringWithFormat:@"%f",incomeStatement.others.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Total Operating Expenses", [NSString stringWithFormat:@"%f",incomeStatement.totalOperatingExpenses.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Operating Income or Loss", [NSString stringWithFormat:@"%f",incomeStatement.operatingIncomeorLoss.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Total Other Income/Expenses Net", [NSString stringWithFormat:@"%f",incomeStatement.totalOtherIncomeExpensesNet.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Earnings before Interest And Taxes", [NSString stringWithFormat:@"%f",incomeStatement.earningsbeforeInterestAndTaxes.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Interest Expense", [NSString stringWithFormat:@"%f",incomeStatement.interestExpense.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Income Before Tax", [NSString stringWithFormat:@"%f",incomeStatement.incomeBeforeTax.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Income Tax Expense", [NSString stringWithFormat:@"%f",incomeStatement.incomeTaxExpense.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Minority Interest", [NSString stringWithFormat:@"%f",incomeStatement.minorityInterest.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Net Income From Continuing Ops", [NSString stringWithFormat:@"%f",incomeStatement.netIncomeFromContinuingOps.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Discontinued Operations", [NSString stringWithFormat:@"%f",incomeStatement.discontinuedOperations.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Net Income", [NSString stringWithFormat:@"%f",incomeStatement.netIncome.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Preferred Stock And Other Adjustments", [NSString stringWithFormat:@"%f",incomeStatement.preferredStockAndOtherAdjustments.calcValue] , @"IncomeStatement"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:incomeStatement.dataDate], identCodeSymbol, @"Net Income Applicable To Common shares", [NSString stringWithFormat:@"%f",incomeStatement.netIncomeApplicableToCommonshares.calcValue] , @"IncomeStatement"];
        }];
    }
    if(notifyObj){
        if (watchPortfolio.portfolioItem->commodityNo == data->commodityNum) {
            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"Income1" waitUntilDone:NO];
        }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data->commodityNum){
            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"Income2" waitUntilDone:NO];
        }
        
    }
}

//現金流量表
-(void)CashFlowCallBack:(FSCashFlowUSIn *)data
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *identCodeSymbol;
    
    if (watchPortfolio.portfolioItem->commodityNo == data->commodityNum) {
        identCodeSymbol = [watchPortfolio.portfolioItem getIdentCodeSymbol];
    }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data->commodityNum){
        identCodeSymbol = [watchPortfolio.comparedPortfolioItem getIdentCodeSymbol];
    }else{
        return;
    }
    
    for(int i = 0; i<[data->cashFlowArray count]; i++){
        FSCashFlow *cashFlow = [[FSCashFlow alloc] init];
        cashFlow = [data->cashFlowArray objectAtIndex:i];
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Net Income", [NSString stringWithFormat:@"%f",cashFlow.netIncome.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Depreciation", [NSString stringWithFormat:@"%f",cashFlow.depreciation.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Adjustments To Net Income", [NSString stringWithFormat:@"%f",cashFlow.adjustmentsToNetIncome.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Changes In Accounts Receivables", [NSString stringWithFormat:@"%f",cashFlow.changesInAccountsReceivables.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Changes In Liabilities", [NSString stringWithFormat:@"%f",cashFlow.changesInLiabilities.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Changes In Inventories", [NSString stringWithFormat:@"%f",cashFlow.changesInInventories.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Changes In Other Operating Activites", [NSString stringWithFormat:@"%f",cashFlow.changesInOtherOperatingActivites.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Total Cash Flow From Operating Activities", [NSString stringWithFormat:@"%f",cashFlow.totalCashFlowFromOperatingActivities.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Capital Expenditures", [NSString stringWithFormat:@"%f",cashFlow.capitalExpenditures.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Investments", [NSString stringWithFormat:@"%f",cashFlow.investments.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Other Cash Flows From Investing Activities", [NSString stringWithFormat:@"%f",cashFlow.otherCashFlowsFromInvestingActivities.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Total Cash Flows From Investing Activities", [NSString stringWithFormat:@"%f",cashFlow.totalCashFlowsFromInvestingActivities.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Dividends Paid", [NSString stringWithFormat:@"%f",cashFlow.dividendsPaid.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Sale Purchase of Stock", [NSString stringWithFormat:@"%f",cashFlow.salePurchaseofStock.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Net Borrowings", [NSString stringWithFormat:@"%f",cashFlow.netBorrowings.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Other Cash Flows From Financing Activities", [NSString stringWithFormat:@"%f",cashFlow.otherCashFlowsFromFinancingActivities.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Total Cash Flows From Financing Activities", [NSString stringWithFormat:@"%f",cashFlow.totalCashFlowsFromFinancingActivities.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Effect Of Exchange Rate Changes", [NSString stringWithFormat:@"%f",cashFlow.effectOfExchangeRateChanges.calcValue] , @"CashFlow"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:cashFlow.dataDate], identCodeSymbol, @"Change In Cash and Cash Equivalents", [NSString stringWithFormat:@"%f",cashFlow.changeInCashandCashEquivalents.calcValue] , @"CashFlow"];
        }];
    }
    if(notifyObj){
        if (watchPortfolio.portfolioItem->commodityNo == data->commodityNum) {
            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"CashFlow1" waitUntilDone:NO];
        }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data->commodityNum){
            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"CashFlow2" waitUntilDone:NO];
        }
        
    }
}

//財務比率
-(void)FinancialRatioCallBack:(FSFinancialRatioUSIn *)data
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *identCodeSymbol;
    
    if (watchPortfolio.portfolioItem->commodityNo == data->commodityNum) {
        identCodeSymbol = [watchPortfolio.portfolioItem getIdentCodeSymbol];
    }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data->commodityNum){
        identCodeSymbol = [watchPortfolio.comparedPortfolioItem getIdentCodeSymbol];
    }else{
        return;
    }
    
    for(int i = 0; i<[data->financialRatioArray count]; i++){
        FSFinancialRatios *financialRatio = [[FSFinancialRatios alloc] init];
        financialRatio = [data->financialRatioArray objectAtIndex:i];
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Profit Margin(ttm)", [NSString stringWithFormat:@"%f",financialRatio.profitMargin.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Operating Margin(ttm)", [NSString stringWithFormat:@"%f",financialRatio.operatingMargin.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Return on Assets(ttm)", [NSString stringWithFormat:@"%f",financialRatio.returnOnAssets.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Return on Equity(ttm)", [NSString stringWithFormat:@"%f",financialRatio.returnOnEquity.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Revenue Per Share(ttm)", [NSString stringWithFormat:@"%f",financialRatio.revenuePerShare.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Qtrly Revenue Growth(yoy)", [NSString stringWithFormat:@"%f",financialRatio.qtrlyRevenueGrowth.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"EBITDA(ttm)", [NSString stringWithFormat:@"%f",financialRatio.eBITDA.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Diluted EPS(ttm)", [NSString stringWithFormat:@"%f",financialRatio.dilutedEPS.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Qtrly Earnings Growth(yoy)", [NSString stringWithFormat:@"%f",financialRatio.qtrlyEarningsGrowth.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Total Cash Per Share(mrq)", [NSString stringWithFormat:@"%f",financialRatio.totalCashPerShare.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Total Debt/Equity(mrq)", [NSString stringWithFormat:@"%f",financialRatio.totalDebtEquity.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Current Ratio(mrq)", [NSString stringWithFormat:@"%f",financialRatio.currentRatio.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Book Value Per Share(mrq)", [NSString stringWithFormat:@"%f",financialRatio.bookValuePerShare.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Operating Cash Flow(ttm)", [NSString stringWithFormat:@"%f",financialRatio.operatingCashFlow.calcValue] , @"FinancialRatio"];
            [db executeUpdate:@"INSERT INTO FinanceReport(DataDate, Symbol, FieldName, Amount, ReportType) VALUES(?,?,?,?,?)",[NSNumber numberWithInt:financialRatio.dataDate], identCodeSymbol, @"Levered Free Cash Flow(ttm)", [NSString stringWithFormat:@"%f",financialRatio.leveredFreeCashFlow.calcValue] , @"FinancialRatio"];
        }];
    }
    if(notifyObj){
        if (watchPortfolio.portfolioItem->commodityNo == data->commodityNum) {
            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"FinancialRatio1" waitUntilDone:NO];
        }else if (watchPortfolio.comparedPortfolioItem->commodityNo == data->commodityNum){
            [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:@"FinancialRatio2" waitUntilDone:NO];
        }
        
    }
}


-(void)setKey{
    //BS
    [_bsKeyArray addObject:@"Cash And Cash Equivalents"];
    [_bsKeyArray addObject:@"Short Term Investments"];
    [_bsKeyArray addObject:@"Net Receivables"];
    [_bsKeyArray addObject:@"Inventory"];
    [_bsKeyArray addObject:@"Other Current Assets"];
    [_bsKeyArray addObject:@"Total Current Assets"];
    [_bsKeyArray addObject:@"Long Term Investments"];
    [_bsKeyArray addObject:@"Property Plant and Equipment"];
    [_bsKeyArray addObject:@"Goodwill"];
    [_bsKeyArray addObject:@"Intangible Assets"];
    [_bsKeyArray addObject:@"Accumulated Amortization"];
    [_bsKeyArray addObject:@"Other Assets"];
    [_bsKeyArray addObject:@"Deferred Long Term Asset Changes"];
    [_bsKeyArray addObject:@"Total Assets"];
    [_bsKeyArray addObject:@"Accounts Payable"];
    [_bsKeyArray addObject:@"Short/Current Long Term Debt"];
    [_bsKeyArray addObject:@"Other Current Liabilities"];
    [_bsKeyArray addObject:@"Total Current Liabilities"];
    [_bsKeyArray addObject:@"Long Term Debt"];
    [_bsKeyArray addObject:@"Other Liabilities"];
    [_bsKeyArray addObject:@"Deferred Long Term Liability Charges"];
    [_bsKeyArray addObject:@"Minority Interest"];
//    [_bsKeyArray addObject:@"Negative Goodwill"];
    [_bsKeyArray addObject:@"Total Liabilities"];
    [_bsKeyArray addObject:@"Misc Stocks Options Warrants"];
    [_bsKeyArray addObject:@"Redeemable Preferred Stock"];
    [_bsKeyArray addObject:@"Preferred Stock"];
    [_bsKeyArray addObject:@"Common Stock"];
    [_bsKeyArray addObject:@"Retained Earnings"];
    [_bsKeyArray addObject:@"Treasury Stock"];
    [_bsKeyArray addObject:@"Capital Surplus"];
    [_bsKeyArray addObject:@"Other Stockholder Equity"];
    [_bsKeyArray addObject:@"Total Stockholder Equity"];
    
    
    //IS
    [_isKeyArray addObject:@"Total Revenue"];
    [_isKeyArray addObject:@"Cost of Revenue"];
    [_isKeyArray addObject:@"Gross Profit"];
    [_isKeyArray addObject:@"Research Development"];
    [_isKeyArray addObject:@"Selling General and Administrative"];
    [_isKeyArray addObject:@"Non Recurring"];
    [_isKeyArray addObject:@"Others"];
    [_isKeyArray addObject:@"Total Operating Expenses"];
    [_isKeyArray addObject:@"Operating Income or Loss"];
    [_isKeyArray addObject:@"Total Other Income/Expenses Net"];
    [_isKeyArray addObject:@"Earnings before Interest And Taxes"];
    [_isKeyArray addObject:@"Interest Expense"];
    [_isKeyArray addObject:@"Income Before Tax"];
    [_isKeyArray addObject:@"Income Tax Expense"];
    [_isKeyArray addObject:@"Minority Interest"];
    [_isKeyArray addObject:@"Net Income From Continuing Ops"];
    [_isKeyArray addObject:@"Discontinued Operations"];
    [_isKeyArray addObject:@"Net Income"];
    [_isKeyArray addObject:@"Preferred Stock And Other Adjustments"];
    [_isKeyArray addObject:@"Net Income Applicable To Common shares"];

    
    //cashFlow
    
    [_cfKeyArray addObject:@"Net Income"];
    [_cfKeyArray addObject:@"Depreciation"];
    [_cfKeyArray addObject:@"Adjustments To Net Income"];
    [_cfKeyArray addObject:@"Changes In Accounts Receivables"];
    [_cfKeyArray addObject:@"Changes In Liabilities"];
    [_cfKeyArray addObject:@"Changes In Inventories"];
    [_cfKeyArray addObject:@"Changes In Other Operating Activites"];
    [_cfKeyArray addObject:@"Total Cash Flow From Operating Activities"];
    [_cfKeyArray addObject:@"Capital Expenditures"];
    [_cfKeyArray addObject:@"Investments"];
    [_cfKeyArray addObject:@"Other Cash Flows From Investing Activities"];
    [_cfKeyArray addObject:@"Total Cash Flows From Investing Activities"];
    [_cfKeyArray addObject:@"Dividends Paid"];
    [_cfKeyArray addObject:@"Sale Purchase of Stock"];
    [_cfKeyArray addObject:@"Net Borrowings"];
    [_cfKeyArray addObject:@"Other Cash Flows From Financing Activities"];
    [_cfKeyArray addObject:@"Total Cash Flows From Financing Activities"];
    [_cfKeyArray addObject:@"Effect Of Exchange Rate Changes"];
    [_cfKeyArray addObject:@"Change In Cash and Cash Equivalents"];
    
    //financialRario
    
    [_frKeyArray addObject:@"Profit Margin(ttm)"];
    [_frKeyArray addObject:@"Operating Margin(ttm)"];
    [_frKeyArray addObject:@"Return on Assets(ttm)"];
    [_frKeyArray addObject:@"Return on Equity(ttm)"];
    [_frKeyArray addObject:@"Revenue Per Share(ttm)"];
    [_frKeyArray addObject:@"Qtrly Revenue Growth(yoy)"];
    [_frKeyArray addObject:@"EBITDA(ttm)"];
    [_frKeyArray addObject:@"Diluted EPS(ttm)"];
    [_frKeyArray addObject:@"Qtrly Earnings Growth(yoy)"];
    [_frKeyArray addObject:@"Total Cash Per Share(mrq)"];
    [_frKeyArray addObject:@"Total Debt/Equity(mrq)"];
    [_frKeyArray addObject:@"Current Ratio(mrq)"];
    [_frKeyArray addObject:@"Book Value Per Share(mrq)"];
    [_frKeyArray addObject:@"Operating Cash Flow(ttm)"];
    [_frKeyArray addObject:@"Levered Free Cash Flow(ttm)"];
}

@end

@implementation FSBalanceSheet

@end

@implementation FSIncomeStatement

@end

@implementation FSCashFlow

@end

@implementation FSFinancialRatios

@end
