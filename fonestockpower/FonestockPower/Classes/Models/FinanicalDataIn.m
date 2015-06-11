//
//  FinanicalDataIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FinanicalDataIn.h"


@implementation FinanicalDataIn

@synthesize finanicalArray;

- (id)init
{
	if(self = [super init])
	{
		finanicalArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	char type = *tmpPtr++;
	int count = *tmpPtr++;
	int offset = 0;
    dataType = type;
	retCode = retcode;
	for(int i=0 ; i<count ; i++)
	{
		TAvalueFormatData tmpTA;
		FinanicalParam *finanicalData = [[FinanicalParam alloc] init];
		finanicalData->dataType = type;
		finanicalData->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
		offset += 16;
		finanicalData->priceEps = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->priceEpsUnit = tmpTA.magnitude;
		finanicalData->priceSales = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->pirceSalesUnit = tmpTA.magnitude;
		finanicalData->avgDividendYield = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->avgDividendYieldUnit = tmpTA.magnitude;
		finanicalData->payoutRatio = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->payoutRatioUnit = tmpTA.magnitude;
		finanicalData->grossMargin = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->grossMarginUnit = tmpTA.magnitude;
		finanicalData->operatingMargin = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->operatingMarginUnit = tmpTA.magnitude;
		finanicalData->preTaxMargin = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->preTaxMarginUnit = tmpTA.magnitude;
		finanicalData->netProfitMargin = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->netProfitMarginUnit = tmpTA.magnitude;
		finanicalData->salesGrowthRatio = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->salesGrowthRatioUnit = tmpTA.magnitude;
		finanicalData->netGrowthRatio = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->netGrowthRatioUnit = tmpTA.magnitude;
		finanicalData->netValues = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->netValuesUnit = tmpTA.magnitude;
		finanicalData->arDay = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->arDayUnit = tmpTA.magnitude;
		finanicalData->sales5yrGrowthRate = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->sales5yrGrowthRateUnit = tmpTA.magnitude;
		finanicalData->eps5yrGrowthRate = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->eps5yrGrowthRateUnit = tmpTA.magnitude;
		finanicalData->capex5yrGrowthRate = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->capex5yrGrowthRateUnit = tmpTA.magnitude;
		finanicalData->currentRatio = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->currentRatioUnit = tmpTA.magnitude;
		finanicalData->quickRatio = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->quickRatioUnit = tmpTA.magnitude;
		finanicalData->debtToEquity = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->debtToEquityUnit = tmpTA.magnitude;
		finanicalData->debtToAsset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->debtToAssetUnit = tmpTA.magnitude;
		finanicalData->interestCoverage = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->interestCoverageUnit = tmpTA.magnitude;
		finanicalData->returnOnAsset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->returnOnAssetUnit = tmpTA.magnitude;
		finanicalData->returnOnAsset5yrAvg = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->returnOnAsset5yrAvgUnit = tmpTA.magnitude;
		finanicalData->returnOnInvestment = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->returnOnInvestmentUnit = tmpTA.magnitude;
		finanicalData->returnOnInvestment5yrAvg = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->returnOnInvestment5yrAvgUnit = tmpTA.magnitude;
		finanicalData->returnOnEquity = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->returnOnEquityUnit = tmpTA.magnitude;
		finanicalData->returnOnEquity5yrAvg = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->returnOnEquity5yrAvgUnit = tmpTA.magnitude;
		finanicalData->revenueEmployee = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->revenueEmployeeUnit = tmpTA.magnitude;
		finanicalData->netIcomeEmployee = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->netIcomeEmployeeUnit = tmpTA.magnitude;
		finanicalData->receivableTurnover = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->receivableTurnoverUnit = tmpTA.magnitude;
		finanicalData->inventoryTurnover = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->inventoryTurnoverUnit = tmpTA.magnitude;
		finanicalData->assetTurnover = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		finanicalData->assetTurnoverUnit = tmpTA.magnitude;
		
		[finanicalArray addObject:finanicalData];
	}
	commodityNum = commodity;
	//送出在這~~
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.financialRatio performSelector:@selector(decodeArrive:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}


@end

@implementation FinanicalParam

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

@end

