//
//  FSFinanceReportUS.h
//  FonestockPower
//
//  Created by Connor on 14/9/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSBalanceSheetUSIn.h"
#import "FSIncomeStatementUSIn.h"
#import "FSCashFlowUSIn.h"
#import "FSFinancialRatioUSIn.h"


typedef NS_ENUM(NSUInteger, FSFinanceReportQueryType) {
    FSFinanceReportQueryTypeSpecify,
    FSFinanceReportQueryTypeInterval
};

typedef NS_ENUM(NSUInteger, FSFinanceReportType) {
    FSFinanceReportTypeBalanceSheet,
    FSFinanceReportTypeIncomeStatementSheet,
    FSFinanceReportTypeCashFlowSheet,
    FSFinanceReportTypeFinancialRatioSheet
};

@interface FSFinanceReportUS : NSObject


@property (strong, nonatomic) NSMutableArray * bsKeyArray;
@property (strong, nonatomic) NSMutableArray * isKeyArray;
@property (strong, nonatomic) NSMutableArray * cfKeyArray;
@property (strong, nonatomic) NSMutableArray * frKeyArray;

- (void)setTargetNotify:(id)obj;

- (void)searchAllSheetWithSecurityNumber:(UInt32)securityNumber dataType:(char)dataType searchStartDate:(NSDate *)searchDate;
//- (void)searchBalanceSheetWithSecurityNumber:(UInt32)securityNumber searchStartDate:(NSDate *)searchDate;
//- (void)searchIncomeStatementSheetWithSecurityNumber:(UInt32)securityNumber searchStartDate:(NSDate *)searchDate;
//
//
//- (void)searchSheetType:(FSFinanceReportType)reportType securityNumber:(UInt32)securityNumber dataType:(char)dataType searchStartDate:(NSDate *)searchDate;
-(void)BalanceSheetCallBack:(FSBalanceSheetUSIn *)data;
-(void)IncomeStatementCallBack:(FSIncomeStatementUSIn *)data;
-(void)CashFlowCallBack:(FSCashFlowUSIn *)data;
-(void)FinancialRatioCallBack:(FSFinancialRatioUSIn *)data;

-(NSMutableArray *)searchFinanceDataDateWithReportType:(NSString *)reportType IdentCodeSymbol:(NSString *)ids;
-(NSMutableDictionary *)searchFinanceDataWithIdentCodeSymbol:(NSString *)ids StartDay:(UInt16)startDay EndDay:(UInt16)endDay ReportType:(NSString *)reportType;

@end

@interface FSBalanceSheet : NSObject
// 資產負債表
@property UInt8 type;
@property UInt16 dataDate;
@property FSBValueFormat *cashAndCashEquivalents;
@property FSBValueFormat *shortTermInvestments;
@property FSBValueFormat *netReceivables;
@property FSBValueFormat *inventory;
@property FSBValueFormat *otherCurrentAssets;
@property FSBValueFormat *totalCurrentAssets;
@property FSBValueFormat *longTermInvestments;
@property FSBValueFormat *propertyPlantAndEquipment;
@property FSBValueFormat *goodwill;
@property FSBValueFormat *intangibleAssets;
@property FSBValueFormat *accumulatedAmortization;
@property FSBValueFormat *otherAssets;
@property FSBValueFormat *deferredLongTermAssetChanges;
@property FSBValueFormat *totalAssets;
@property FSBValueFormat *accountsPayable;
@property FSBValueFormat *shortCurrentLongTermDebt;
@property FSBValueFormat *otherCurrentLiabilities;
@property FSBValueFormat *totalCurrentLiabilities;
@property FSBValueFormat *longTermDebt;
@property FSBValueFormat *otherLiabilities;
@property FSBValueFormat *deferredLongTermLiabilityCharges;
@property FSBValueFormat *minorityInterest;
@property FSBValueFormat *negativeGoodwill;
@property FSBValueFormat *totalLiabilities;
@property FSBValueFormat *miscStocksOptionsWarrants;
@property FSBValueFormat *redeemablePreferredStock;
@property FSBValueFormat *preferredStock;
@property FSBValueFormat *commonStock;
@property FSBValueFormat *retainedEarnings;
@property FSBValueFormat *treasuryStock;
@property FSBValueFormat *capitalSurplus;
@property FSBValueFormat *otherStockholderEquity;
@property FSBValueFormat *totalStockholderEquity;

@end

@interface FSIncomeStatement : NSObject
// 損益表
@property UInt8 type;
@property UInt16 dataDate;
@property FSBValueFormat *totalRevenue;
@property FSBValueFormat *costofRevenue;
@property FSBValueFormat *grossProfit;
@property FSBValueFormat *researchDevelopment;
@property FSBValueFormat *sellingGeneralandAdministrative;
@property FSBValueFormat *nonRecurring;
@property FSBValueFormat *others;
@property FSBValueFormat *totalOperatingExpenses;
@property FSBValueFormat *operatingIncomeorLoss;
@property FSBValueFormat *totalOtherIncomeExpensesNet;
@property FSBValueFormat *earningsbeforeInterestAndTaxes;
@property FSBValueFormat *interestExpense;
@property FSBValueFormat *incomeBeforeTax;
@property FSBValueFormat *incomeTaxExpense;
@property FSBValueFormat *minorityInterest; //資產負債表重複?!
@property FSBValueFormat *netIncomeFromContinuingOps;
@property FSBValueFormat *discontinuedOperations;
@property FSBValueFormat *netIncome;
@property FSBValueFormat *preferredStockAndOtherAdjustments;
@property FSBValueFormat *netIncomeApplicableToCommonshares;

@end

@interface FSCashFlow : NSObject
// 現金流量表
@property UInt8 type;
@property UInt16 dataDate;
@property FSBValueFormat *netIncome;    // 損益表重複?!
@property FSBValueFormat *depreciation;
@property FSBValueFormat *adjustmentsToNetIncome;
@property FSBValueFormat *changesInAccountsReceivables;
@property FSBValueFormat *changesInLiabilities;
@property FSBValueFormat *changesInInventories;
@property FSBValueFormat *changesInOtherOperatingActivites;
@property FSBValueFormat *totalCashFlowFromOperatingActivities;
@property FSBValueFormat *capitalExpenditures;
@property FSBValueFormat *investments;
@property FSBValueFormat *otherCashFlowsFromInvestingActivities;
@property FSBValueFormat *totalCashFlowsFromInvestingActivities;
@property FSBValueFormat *dividendsPaid;
@property FSBValueFormat *salePurchaseofStock;
@property FSBValueFormat *netBorrowings;
@property FSBValueFormat *otherCashFlowsFromFinancingActivities;
@property FSBValueFormat *totalCashFlowsFromFinancingActivities;
@property FSBValueFormat *effectOfExchangeRateChanges;
@property FSBValueFormat *changeInCashandCashEquivalents;

@end

@interface FSFinancialRatios : NSObject
// 財務比例
@property UInt8 type;
@property UInt16 dataDate;
@property FSBValueFormat *profitMargin;
@property FSBValueFormat *operatingMargin;
@property FSBValueFormat *returnOnAssets;
@property FSBValueFormat *returnOnEquity;
@property FSBValueFormat *revenuePerShare;
@property FSBValueFormat *qtrlyRevenueGrowth;
@property FSBValueFormat *eBITDA;
@property FSBValueFormat *dilutedEPS;
@property FSBValueFormat *qtrlyEarningsGrowth;
@property FSBValueFormat *totalCashPerShare;
@property FSBValueFormat *totalDebtEquity;
@property FSBValueFormat *currentRatio;
@property FSBValueFormat *bookValuePerShare;
@property FSBValueFormat *operatingCashFlow;
@property FSBValueFormat *leveredFreeCashFlow;

@end