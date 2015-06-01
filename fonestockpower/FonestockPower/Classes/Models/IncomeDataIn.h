//
//  IncomeDataIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"


@interface IncomeDataIn : NSObject {
@public
	NSMutableArray *incomeArray;
	UInt8 retCode;
	UInt32 commodityNum;
    UInt8 dataType;
}

@property (nonatomic,strong) NSMutableArray *incomeArray;

@end

@interface IncomeParam : NSObject
{
@public
	UInt8 dataType;
	UInt16 date;
	double netSales;
	UInt8 netSalesUnit;
	double costRevenue;
	UInt8 costRevenueUnit;
	double grossProfit;
	UInt8 grossProfitUnit;
	double rdExp;
	UInt8 rdExpUnit;
	double sga;
	UInt8 sgaUnit;
	double depreciationAmortization;
	UInt8 depreciationAmortizationUnit;
	double indirectExp;
	UInt8 indirectExpUnit;
	double totalExpanse;
	UInt8 totalExpanseUnit;
	double operatingIncome;
	UInt8 operatingIncomeUnit;
	double nonOperatingGains;
	UInt8 nonOperatingGainsUnit;
	double cashFlow;
	UInt8 cashFlowUnit;
	double interestIncome;
	UInt8 interestIncomeUnit;
	double interestExpanse;
	UInt8 interestExpanseUnit;
	double investLose;
	UInt8 investLoseUnit;
	double forexLose;
	UInt8 forexLoseUnit;
	double incomeBeforeTax;
	UInt8 incomeBeforeTaxUnit;
	double taxExpanse;
	UInt8 taxExpanseUnit;
	double profit;
	UInt8 profitUnit;
	double dilutedShares;
	UInt8 dilutedSharesUnit;
	double dilutedEps;
	UInt8 dilutedEpsUnit;
	double stockValue;
	UInt8 stockValueUnit;
}


@end
