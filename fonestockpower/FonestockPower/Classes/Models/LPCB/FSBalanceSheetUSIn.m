//
//  FSBalanceSheetUSIn.m
//  FonestockPower
//
//  Created by Connor on 14/9/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBalanceSheetUSIn.h"

@implementation FSBalanceSheetUSIn
- (id)init
{
	if(self = [super init]){
		balanceSheetArray = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
	UInt8 *tmPtr = body;
    char type = *tmPtr++;
	int count = *tmPtr++;
    commodityNum = commodity;
    
    for (int i = 0; i < count; i++) {
        FSBalanceSheet *balanceSheet = [[FSBalanceSheet alloc] init];
        balanceSheet.type = type;
        balanceSheet.dataDate = [CodingUtil getUInt16:&tmPtr needOffset:YES];
        balanceSheet.cashAndCashEquivalents = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.shortTermInvestments = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.netReceivables = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.inventory = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.otherCurrentAssets = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.totalCurrentAssets = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.longTermInvestments = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.propertyPlantAndEquipment = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.goodwill = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.intangibleAssets = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.accumulatedAmortization = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.otherAssets = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.deferredLongTermAssetChanges = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.totalAssets = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.accountsPayable = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.shortCurrentLongTermDebt = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.otherCurrentLiabilities = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.totalCurrentLiabilities = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.longTermDebt = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.otherLiabilities = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.deferredLongTermLiabilityCharges = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.minorityInterest = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.negativeGoodwill = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.totalLiabilities = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.miscStocksOptionsWarrants = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.redeemablePreferredStock = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.preferredStock = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.commonStock = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.retainedEarnings = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.treasuryStock = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.capitalSurplus = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.otherStockholderEquity = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        balanceSheet.totalStockholderEquity = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        
        [balanceSheetArray addObject:balanceSheet];
        
    }

    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    
    if([model.financeReportUS respondsToSelector:@selector(BalanceSheetCallBack:)]) {
        [model.financeReportUS performSelector:@selector(BalanceSheetCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
//        [model.financeReportUS searchFinanceDataWithStartDay:@"27454" EndDay:@"27454" ReportType:@"BalanceSheet"];
    }

}
@end
