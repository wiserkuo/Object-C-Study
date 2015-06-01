//
//  BalanceSheetIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"


@interface BalanceSheetIn : NSObject <DecodeProtocol>{
@public
	NSMutableArray *sheetArray;
	UInt8 retCode;
	UInt32 commodityNum;
    UInt8 dataType;
}

@property (nonatomic,strong) NSMutableArray *sheetArray;

@end

@interface SheetParam : NSObject
{
@public
	UInt8 dataType;
	UInt16 date;
	double cash;
	UInt8 cashUnit;
	double shortInvest;
	UInt8 shortInvestUnit;
	double ar;
	UInt8 arUnit;
	double inventory;
	UInt8 inventoryUnit;
	double currentAsset;
	UInt8 currentAssetUnit;
	double longInvest;
	UInt8 longInvestUnit;
	double fixedAsset;
	UInt8 fixedAssetUnit;
	double totalAsset;
	UInt8 totalAssetUnit;
	double shortLoan;
	UInt8 shortLoanUnit;
	double ap;
	UInt8 apUnit;
	double currentDebt;
	UInt8 currentDebtUnit;
	double longLoan;
	UInt8 longLoanUnit;
	double totalDebt;
	UInt8 totalDebtUnit;
	double equity;
	UInt8 equityUnit;
	double retainedEarning;
	UInt8 retainedEarningUnit;
	double totalEquity;
	UInt8 totalEquityUnit;
}

@end
