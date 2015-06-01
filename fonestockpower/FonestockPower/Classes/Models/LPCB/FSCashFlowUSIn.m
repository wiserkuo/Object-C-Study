//
//  FSCashFlowUSIn.m
//  FonestockPower
//
//  Created by Derek on 2014/9/12.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSCashFlowUSIn.h"

@implementation FSCashFlowUSIn
- (id)init
{
	if(self = [super init]){
		cashFlowArray = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    UInt8 *tmPtr = body;
    char type = *tmPtr++;
	int count = *tmPtr++;
    commodityNum = commodity;
    
    for (int i = 0; i < count; i++) {
        FSCashFlow *cashFlow = [[FSCashFlow alloc] init];
        cashFlow.type = type;
        cashFlow.dataDate = [CodingUtil getUInt16:&tmPtr needOffset:YES];
        cashFlow.netIncome = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.depreciation = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.adjustmentsToNetIncome = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.changesInAccountsReceivables = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.changesInLiabilities = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.changesInInventories = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.changesInOtherOperatingActivites = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.totalCashFlowFromOperatingActivities = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.capitalExpenditures = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.investments = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.otherCashFlowsFromInvestingActivities = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.totalCashFlowsFromInvestingActivities = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.dividendsPaid = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.salePurchaseofStock = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.netBorrowings = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.otherCashFlowsFromFinancingActivities = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.totalCashFlowsFromFinancingActivities = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.effectOfExchangeRateChanges = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        cashFlow.changeInCashandCashEquivalents = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];

        [cashFlowArray addObject:cashFlow];
    }
    
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    
    if([model.financeReportUS respondsToSelector:@selector(CashFlowCallBack:)]) {
        [model.financeReportUS performSelector:@selector(CashFlowCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }

    
}

@end
