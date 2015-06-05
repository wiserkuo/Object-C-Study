//
//  FSFinanceModel.h
//  FonestockPower
//
//  Created by Connor on 2015/5/18.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSFinanceReportCN.h"

typedef NS_ENUM(NSUInteger, FSFinanceType) {
    FSFinanceType1 = 0,       // 0: $
    FSFinanceType2,           // 1: %
    FSFinanceType3            // 2: $+%
};

typedef NS_ENUM(NSUInteger, FSFinanceCategory) {
    FSFinanceCategory1 = 0,       // 0: 累計
    FSFinanceCategory2,           // 1: 單季
};

@interface FSFinanceModel : NSObject{
    NSObject * notifyObj;
}

@property FSFinanceType type;
@property FSFinanceCategory category;

@property NSRecursiveLock *lock;
@property FSFinanceReportCN *model;

@property (nonatomic) NSArray *pageList1;
@property (nonatomic) NSArray *pageList2;
@property (nonatomic) NSArray *pageList3;
@property (nonatomic) NSArray *pageList4;

@property (nonatomic) NSArray *categoryList;
@property (nonatomic) NSArray *typeList;

@property (weak) NSMutableArray *balance1Array;
@property (weak) NSMutableArray *balance2Array;
@property (weak) NSMutableArray *income1Array;
@property (weak) NSMutableArray *income2Array;
@property (weak) NSMutableArray *cashFlow1Array;
@property (weak) NSMutableArray *cashFlow2Array;
@property (weak) NSMutableArray *financialRatio1Array;
@property (weak) NSMutableArray *financialRatio2Array;
- (void)setTargetNotify:(id)obj;
- (void)searchAllSheetWithSecurityNumber:(UInt32)securityNumber dataType:(char)dataType searchStartDate:(NSDate *)searchDate;
- (FSBValueFormat*)getData:(NSString*)stockType date:(NSString*)date ids:(NSString*)ids indexPath:(NSIndexPath *)indexPath;
@end




// 陸股財報

@interface FSBalanceSheetCN : NSObject

- (instancetype)initWithBlankData;

@property FSDateFormat *data_date;
@property FSBValueFormat *current_asset;
@property FSBValueFormat *l_term_invest;
@property FSBValueFormat *fixed_asset;
@property FSBValueFormat *other_asset;
@property FSBValueFormat *total_asset;
@property FSBValueFormat *current_debt;
@property FSBValueFormat *l_term_loan;
@property FSBValueFormat *other_liabilities_n_reserves;
@property FSBValueFormat *total_debt;
@property FSBValueFormat *equity;
@property FSBValueFormat *preferred_stock_equity;
@property FSBValueFormat *retained_earning;
@property FSBValueFormat *undivided_profits;
@property FSBValueFormat *minority_interest;
@property FSBValueFormat *total_equity;
@property FSBValueFormat *liabilities_n_total_equity;
@end

@interface FSIncomeStatementCN : NSObject

- (instancetype)initWithBlankData;

@property FSDateFormat *data_date;
@property FSBValueFormat *net_sales;
@property FSBValueFormat *costs_of_goods_sold;
@property FSBValueFormat *gross_profit;
@property FSBValueFormat *total_expanse;
@property FSBValueFormat *net_op_income;
@property FSBValueFormat *total_non_operating_income;
@property FSBValueFormat *total_non_business_expense;
@property FSBValueFormat *n_income_bt;
@property FSBValueFormat *tax_expanse;
@property FSBValueFormat *net_profit;
@property FSBValueFormat *eps;
@end

@interface FSCashFlowCN : NSObject

- (instancetype)initWithBlankData;

@property FSDateFormat *data_date;
@property FSBValueFormat *op_cash_flow;
@property FSBValueFormat *invest_cash_flow;
@property FSBValueFormat *fm_cash_flow;
@end

@interface FSFinancialRatioCN : NSObject

- (instancetype)initWithBlankData;

@property FSDateFormat *data_date;
@property FSBValueFormat *g_profit_ratio;
@property FSBValueFormat *op_profit_ratio;
@property FSBValueFormat *net_income_ratio;
@property FSBValueFormat *net_value;
@property FSBValueFormat *sale_growth_ratio;
@property FSBValueFormat *current_ratio;
@property FSBValueFormat *quick_ratio;
@property FSBValueFormat *debt2asset;
@property FSBValueFormat *debt2equity;
@end
