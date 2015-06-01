//
//  BalanceSheetIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BalanceSheetIn.h"


@implementation BalanceSheetIn

@synthesize sheetArray;

- (id)init
{
	if(self = [super init])
	{
		sheetArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	char type = *tmpPtr++;
    dataType = type;
	int count = *tmpPtr++;
	int offset = 0;
	retCode = retcode;
	for(int i=0 ; i<count ; i++)
	{
		TAvalueFormatData tmpTA;
		SheetParam *sheetData = [[SheetParam alloc] init];
		sheetData->dataType = type;
		sheetData->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
		offset += 16;
		sheetData->cash = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->cashUnit = tmpTA.magnitude;
		sheetData->shortInvest = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->shortInvestUnit = tmpTA.magnitude;
		sheetData->ar = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->arUnit = tmpTA.magnitude;
		sheetData->inventory = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->inventoryUnit = tmpTA.magnitude;
		sheetData->currentAsset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->currentAssetUnit = tmpTA.magnitude;
		sheetData->longInvest = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->longInvestUnit = tmpTA.magnitude;
		sheetData->fixedAsset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->fixedAssetUnit = tmpTA.magnitude;
		sheetData->totalAsset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->totalAssetUnit = tmpTA.magnitude;
		sheetData->shortLoan = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->shortLoanUnit = tmpTA.magnitude;
		sheetData->ap = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->apUnit = tmpTA.magnitude;
		sheetData->currentDebt = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->currentDebtUnit = tmpTA.magnitude;
		sheetData->longLoan = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->longLoanUnit = tmpTA.magnitude;
		sheetData->totalDebt = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->totalDebtUnit = tmpTA.magnitude;
		sheetData->equity = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->equityUnit = tmpTA.magnitude;
		sheetData->retainedEarning = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->retainedEarningUnit = tmpTA.magnitude;
		sheetData->totalEquity = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		sheetData->totalEquityUnit = tmpTA.magnitude;
		
		[sheetArray addObject:sheetData];
	}
	commodityNum = commodity;
	//送出在這
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.balanceSheet performSelector:@selector(decodeArrive:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}


@end

@implementation SheetParam

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

@end
