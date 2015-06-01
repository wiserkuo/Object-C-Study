//
//  FSFinanceReportUSOut.h
//  FonestockPower
//
//  Created by Connor on 14/9/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSFinanceReportUS.h"

typedef NS_ENUM(NSUInteger, FSFinanceReportCommend) {
    FSFinanceReportCommendBalanceSheet = 12,
    FSFinanceReportCommendIncomeStatementSheet = 13,
    FSFinanceReportCommendFinancialRatioSheet = 14,
    FSFinanceReportCommendCashFlowSheet = 15
};

@interface FSFinanceReportUSOut : NSObject <EncodeProtocol>

- (instancetype)initWithSecurityNumber:(UInt32)securityNumber dataType:(char)dataType queryType:(FSFinanceReportQueryType)queryType searchStartDate:(UInt16)startDate;

- (instancetype)initWithSecurityNumber:(UInt32)securityNumber dataType:(char)dataType queryType:(FSFinanceReportQueryType)queryType searchStartDate:(UInt16)startDate endDate:(UInt16)endDate;

@property FSFinanceReportCommend financeReportCommend;
@end
