//
//  IncomeDataIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IncomeDataIn.h"


@implementation IncomeDataIn

@synthesize incomeArray;

- (id)init
{
	if(self = [super init])
	{
		incomeArray = [[NSMutableArray alloc] init];
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
		IncomeParam *incomeData = [[IncomeParam alloc] init];
		incomeData->dataType = type;
		incomeData->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
		offset += 16;
		incomeData->netSales = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->netSalesUnit = tmpTA.magnitude;
		incomeData->costRevenue = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->costRevenueUnit = tmpTA.magnitude;
		incomeData->grossProfit = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->grossProfitUnit = tmpTA.magnitude;
		incomeData->rdExp = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->rdExpUnit = tmpTA.magnitude;
		incomeData->sga = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->sgaUnit = tmpTA.magnitude;
		incomeData->depreciationAmortization = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->depreciationAmortizationUnit = tmpTA.magnitude;
		incomeData->indirectExp = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->indirectExpUnit = tmpTA.magnitude;
		incomeData->totalExpanse = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->totalExpanseUnit = tmpTA.magnitude;
		incomeData->operatingIncome = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->operatingIncomeUnit = tmpTA.magnitude;
		incomeData->nonOperatingGains = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->nonOperatingGainsUnit = tmpTA.magnitude;
		incomeData->cashFlow = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->cashFlowUnit = tmpTA.magnitude;
		incomeData->interestIncome = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->interestIncomeUnit = tmpTA.magnitude;
		incomeData->interestExpanse = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->interestExpanseUnit = tmpTA.magnitude;
		incomeData->investLose = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->investLoseUnit = tmpTA.magnitude;
		incomeData->forexLose = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->forexLoseUnit = tmpTA.magnitude;
		incomeData->incomeBeforeTax = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->incomeBeforeTaxUnit = tmpTA.magnitude;
		incomeData->taxExpanse = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->taxExpanseUnit = tmpTA.magnitude;
		incomeData->profit = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->profitUnit = tmpTA.magnitude;
		incomeData->dilutedShares = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->dilutedSharesUnit = tmpTA.magnitude;
		incomeData->dilutedEps = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->dilutedEpsUnit = tmpTA.magnitude;
		incomeData->stockValue = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		incomeData->stockValueUnit = tmpTA.magnitude;

		[incomeArray addObject:incomeData];
	}
	commodityNum = commodity;
	//送出在這
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.income performSelector:@selector(decodeArrive:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end

@implementation IncomeParam

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}


@end
