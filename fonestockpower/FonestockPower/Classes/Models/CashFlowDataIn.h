//
//  CashFlowDataIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"


@interface CashFlowDataIn : NSObject <DecodeProtocol>{
@public
	NSMutableArray *cashFlowArray;
	UInt8 retCode;
	UInt32 commodityNum;
    UInt8 dataType;
}

@property (nonatomic,strong) NSMutableArray *cashFlowArray;

@end

@interface CashFlowParam : NSObject
{
@public
	UInt8 dataType;
	UInt16 date;
	double netIncome;
	double depriciation;
	double investGainLoss;
	double shortInvestGainLoss;
	double fixInvestGainLoss;
	double longInvestGainLoss;
	double arOffset;
	double inventoryOffset;
	double apOffset;
	double changesWorkingCapital;
	double incomeAdjustments;
	double otherOperatingFlow;
	double operatingCashFlow;
	double shortInvestSold;
	double longInvestSold;
	double longInvestment;
	double fixAssetAmnt;
	double fixedAsset;
	double capitalExpenditures;
	double investmentPurchases;
	double investmentDisposal;
	double businessAcqstnsDisposal;
	double otherInvestFlow;
	double investCashFlow;
	double capitalFund;
	double cashDiv;
	double loanOffset;
	double shortDebtChanges;
	double longDebtChanges;
	double changeInEquity;
	double otherFinancingFlow;
	double financingCashFlow;
	double effectOfExchangeRate;
	double termCashFlow;
	double botCashFlow;
	double eotCashFlow;
	double paidInterest;
	double paidInteresetTax;
	double freeCashFlow;	
	UInt8 netIncomeUnit;
	UInt8 depriciationUnit;
	UInt8 investGainLossUnit;
	UInt8 shortInvestGainLossUnit;
	UInt8 fixInvestGainLossUnit;
	UInt8 longInvestGainLossUnit;
	UInt8 arOffsetUnit;
	UInt8 inventoryOffsetUnit;
	UInt8 apOffsetUnit;
	UInt8 changesWorkingCapitalUnit;
	UInt8 incomeAdjustmentsUnit;
	UInt8 otherOperatingFlowUnit;
	UInt8 operatingCashFlowUnit;
	UInt8 shortInvestSoldUnit;
	UInt8 longInvestSoldUnit;
	UInt8 longInvestmentUnit;
	UInt8 fixAssetAmntUnit;
	UInt8 fixedAssetUnit;
	UInt8 capitalExpendituresUnit;
	UInt8 investmentPurchasesUnit;
	UInt8 investmentDisposalUnit;
	UInt8 businessAcqstnsDisposalUnit;
	UInt8 otherInvestFlowUnit;
	UInt8 investCashFlowUnit;
	UInt8 capitalFundUnit;
	UInt8 cashDivUnit;
	UInt8 loanOffsetUnit;
	UInt8 shortDebtChangesUnit;
	UInt8 longDebtChangesUnit;
	UInt8 changeInEquityUnit;
	UInt8 otherFinancingFlowUnit;
	UInt8 financingCashFlowUnit;
	UInt8 effectOfExchangeRateUnit;
	UInt8 termCashFlowUnit;
	UInt8 botCashFlowUnit;
	UInt8 eotCashFlowUnit;
	UInt8 paidInterestUnit;
	UInt8 paidInteresetTaxUnit;
	UInt8 freeCashFlowUnit;
}

@end
