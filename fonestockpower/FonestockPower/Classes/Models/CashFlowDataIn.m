//
//  CashFlowDataIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CashFlowDataIn.h"


@implementation CashFlowDataIn

@synthesize cashFlowArray;

- (id)init
{
	if(self = [super init])
	{
		cashFlowArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	char type = *tmpPtr++;
	int count = *tmpPtr++;
	int offset = 0;
	retCode = retcode;
    dataType = type;
	for(int i=0 ; i<count ; i++)
	{
		TAvalueFormatData tmpTA;
		CashFlowParam *cashFlowData = [[CashFlowParam alloc] init];
		cashFlowData->dataType = type;
		cashFlowData->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
		offset += 16;
		cashFlowData->netIncome = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->netIncomeUnit = tmpTA.magnitude;
		cashFlowData->depriciation = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->depriciationUnit = tmpTA.magnitude;
		cashFlowData->investGainLoss = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->investGainLossUnit = tmpTA.magnitude;
		cashFlowData->shortInvestGainLoss = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->shortInvestGainLossUnit = tmpTA.magnitude;
		cashFlowData->fixInvestGainLoss = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->fixInvestGainLossUnit = tmpTA.magnitude;
		cashFlowData->longInvestGainLoss = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->longInvestGainLossUnit = tmpTA.magnitude;
		cashFlowData->arOffset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->arOffsetUnit = tmpTA.magnitude;
		cashFlowData->inventoryOffset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->inventoryOffsetUnit = tmpTA.magnitude;
		cashFlowData->apOffset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->apOffsetUnit = tmpTA.magnitude;
		cashFlowData->changesWorkingCapital = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->changesWorkingCapitalUnit = tmpTA.magnitude;
		cashFlowData->incomeAdjustments = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->incomeAdjustmentsUnit = tmpTA.magnitude;
		cashFlowData->otherOperatingFlow = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->otherOperatingFlowUnit = tmpTA.magnitude;
		cashFlowData->operatingCashFlow = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->operatingCashFlowUnit = tmpTA.magnitude;
		cashFlowData->shortInvestSold = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->shortInvestSoldUnit = tmpTA.magnitude;
		cashFlowData->longInvestSold = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->longInvestSoldUnit = tmpTA.magnitude;
		cashFlowData->longInvestment = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->longInvestmentUnit = tmpTA.magnitude;
		cashFlowData->fixAssetAmnt = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->fixAssetAmntUnit = tmpTA.magnitude;
		cashFlowData->fixedAsset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->fixedAssetUnit = tmpTA.magnitude;
		cashFlowData->capitalExpenditures = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->capitalExpendituresUnit = tmpTA.magnitude;
		cashFlowData->investmentPurchases = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->investmentPurchasesUnit = tmpTA.magnitude;
		cashFlowData->investmentDisposal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->investmentDisposalUnit = tmpTA.magnitude;
		cashFlowData->businessAcqstnsDisposal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->businessAcqstnsDisposalUnit = tmpTA.magnitude;
		cashFlowData->otherInvestFlow = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->otherInvestFlowUnit = tmpTA.magnitude;
		cashFlowData->investCashFlow = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->investCashFlowUnit = tmpTA.magnitude;
		cashFlowData->capitalFund = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->capitalFundUnit = tmpTA.magnitude;
		cashFlowData->cashDiv = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->cashDivUnit = tmpTA.magnitude;
		cashFlowData->loanOffset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->loanOffsetUnit = tmpTA.magnitude;
		cashFlowData->shortDebtChanges = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->shortDebtChangesUnit = tmpTA.magnitude;
		cashFlowData->longDebtChanges = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->longDebtChangesUnit = tmpTA.magnitude;
		cashFlowData->changeInEquity = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->changeInEquityUnit = tmpTA.magnitude;
		cashFlowData->otherFinancingFlow = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->otherFinancingFlowUnit = tmpTA.magnitude;
		cashFlowData->financingCashFlow = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->financingCashFlowUnit = tmpTA.magnitude;
		cashFlowData->effectOfExchangeRate = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->effectOfExchangeRateUnit = tmpTA.magnitude;
		cashFlowData->termCashFlow = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->termCashFlowUnit = tmpTA.magnitude;
		cashFlowData->botCashFlow = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->botCashFlowUnit = tmpTA.magnitude;
		cashFlowData->eotCashFlow = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->eotCashFlowUnit = tmpTA.magnitude;
		cashFlowData->paidInterest = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->paidInterestUnit = tmpTA.magnitude;
		cashFlowData->paidInteresetTax = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->paidInteresetTaxUnit = tmpTA.magnitude;
		cashFlowData->freeCashFlow = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		cashFlowData->freeCashFlowUnit = tmpTA.magnitude;
		
		[cashFlowArray addObject:cashFlowData];
	}
	commodityNum = commodity;
	//送出在這邊~~
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.cashFlow performSelector:@selector(decodeArrive:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}


@end

@implementation CashFlowParam

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

@end
