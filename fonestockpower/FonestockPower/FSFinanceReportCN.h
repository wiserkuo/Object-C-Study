//
//  FSFinanceReportCN.h
//  FonestockPower
//
//  Created by Connor on 2015/5/19.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

// MSG:10, CMD:2 or 3 or 4 or 5
typedef NS_ENUM(NSUInteger, FSFinanceReportCNCommend) {
    FSFinanceReportCNCommendBalanceSheet = 2,
    FSFinanceReportCNCommendIncomeStatementSheet = 3,
    FSFinanceReportCNCommendFinancialRatioSheet = 4,
    FSFinanceReportCNCommendCashFlowSheet = 5
};


@protocol FSFinanceReportProtocol

- (void)financeReportDataNotify;

@end




@interface FSFinanceReportCN : NSObject{
    NSObject * notifyObj;
}
@property (strong, nonatomic) NSMutableArray * bsKeyArray; //balance sheet的字串key
@property (strong, nonatomic) NSMutableArray * isKeyArray; //income statement的字串key
@property (strong, nonatomic) NSMutableArray * cfKeyArray; //cash flow的字串key
@property (strong, nonatomic) NSMutableArray * frKeyArray; //financial ratio的字串key

@property NSMutableDictionary *stockDict;

@property NSMutableArray *balance1Array;
@property NSMutableArray *balance2Array;
@property NSMutableArray *income1Array;
@property NSMutableArray *income2Array;
@property NSMutableArray *cashFlow1Array;
@property NSMutableArray *cashFlow2Array;
@property NSMutableArray *financialRatio1Array;
@property NSMutableArray *financialRatio2Array;

@property (nonatomic) NSArray *pageList1;
@property (nonatomic) NSArray *pageList2;
@property (nonatomic) NSArray *pageList3;
@property (nonatomic) NSArray *pageList4;
- (void)setTargetNotify:(id)obj;
- (void)searchAllSheetWithSecurityNumber:(UInt32)securityNumber dataType:(char)dataType searchStartDate:(NSDate *)searchDate;
@property (nonatomic) NSString *reporType;
@end

@interface FSFinanceReportCNOut : NSObject <EncodeProtocol> {
    UInt32 _securityNumber;
    UInt16 _startDate;
    UInt16 _endDate;
}

@property FSFinanceReportCNCommend financeReportCommend;
@property FSFinanceReportQueryType queryType;
@property char dataType;

- (instancetype)initWithSecurityNumber:(UInt32)securityNumber dataType:(char)dataType queryType:(FSFinanceReportQueryType)queryType searchStartDate:(UInt16)startDate;

- (instancetype)initWithSecurityNumber:(UInt32)securityNumber dataType:(char)dataType queryType:(FSFinanceReportQueryType)queryType searchStartDate:(UInt16)startDate endDate:(UInt16)endDate;



@end


// 資產負債表
@interface FSBalanceSheetCNIn : NSObject <DecodeProtocol>
@property UInt8 type;
@property UInt32 commodityNum;
@property NSMutableArray *balanceSheetArray;
@end

// 損益表
@interface FSIncomeStatementCNIn : NSObject <DecodeProtocol>
@property UInt8 type;
@property UInt32 commodityNum;
@property NSMutableArray *incomeStatementArray;
@end

// 現金流量表
@interface FSCashFlowCNIn : NSObject <DecodeProtocol>
@property UInt8 type;
@property UInt32 commodityNum;
@property NSMutableArray *cashFlowArray;
@end

// 財務比率
@interface FSFinancialRatioCNIn : NSObject <DecodeProtocol>
@property UInt8 type;
@property UInt32 commodityNum;
@property NSMutableArray *financialRatioArray;
@end