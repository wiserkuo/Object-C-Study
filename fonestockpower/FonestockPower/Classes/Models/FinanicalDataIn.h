//
//  FinanicalDataIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"


@interface FinanicalDataIn : NSObject <DecodeProtocol>{
@public
	NSMutableArray *finanicalArray;
	UInt8 retCode;
	UInt32 commodityNum;
    UInt8 dataType;
}

@property (nonatomic,strong) NSMutableArray *finanicalArray;

@end

@interface FinanicalParam : NSObject
{
@public
	UInt8 dataType;
	UInt16 date;
	double priceEps;
	UInt8 priceEpsUnit;
	double priceSales;
	UInt8 pirceSalesUnit;
	double avgDividendYield;
	UInt8 avgDividendYieldUnit;
	double payoutRatio;
	UInt8 payoutRatioUnit;
	double grossMargin;
	UInt8 grossMarginUnit;
	double operatingMargin;
	UInt8 operatingMarginUnit;
	double preTaxMargin;
	UInt8 preTaxMarginUnit;
	double netProfitMargin;
	UInt8 netProfitMarginUnit;
	double salesGrowthRatio;
	UInt8 salesGrowthRatioUnit;
	double netGrowthRatio;
	UInt8 netGrowthRatioUnit;
	double netValues;
	UInt8 netValuesUnit;
	double arDay;
	UInt8 arDayUnit;
	double sales5yrGrowthRate;
	UInt8 sales5yrGrowthRateUnit;
	double eps5yrGrowthRate;
	UInt8 eps5yrGrowthRateUnit;
	double capex5yrGrowthRate;
	UInt8 capex5yrGrowthRateUnit;
	double currentRatio;
	UInt8 currentRatioUnit;
	double quickRatio;
	UInt8 quickRatioUnit;
	double debtToEquity;
	UInt8 debtToEquityUnit;
	double debtToAsset;
	UInt8 debtToAssetUnit;
	double interestCoverage;
	UInt8 interestCoverageUnit;
	double returnOnAsset;
	UInt8 returnOnAssetUnit;
	double returnOnAsset5yrAvg;
	UInt8 returnOnAsset5yrAvgUnit;
	double returnOnInvestment;
	UInt8 returnOnInvestmentUnit;
	double returnOnInvestment5yrAvg;
	UInt8 returnOnInvestment5yrAvgUnit;
	double returnOnEquity;
	UInt8 returnOnEquityUnit;
	double returnOnEquity5yrAvg;
	UInt8 returnOnEquity5yrAvgUnit;
	double revenueEmployee;
	UInt8 revenueEmployeeUnit;
	double netIcomeEmployee;
	UInt8 netIcomeEmployeeUnit;
	double receivableTurnover;
	UInt8 receivableTurnoverUnit;
	double inventoryTurnover;
	UInt8 inventoryTurnoverUnit;
	double assetTurnover;
	UInt8 assetTurnoverUnit;
}

@end
