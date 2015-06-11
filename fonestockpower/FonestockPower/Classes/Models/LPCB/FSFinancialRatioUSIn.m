//
//  FSFinancialRatioUSIn.m
//  FonestockPower
//
//  Created by Derek on 2014/9/12.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSFinancialRatioUSIn.h"

@implementation FSFinancialRatioUSIn
- (id)init
{
	if(self = [super init]){
		financialRatioArray = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    UInt8 *tmPtr = body;
    char type = *tmPtr++;
	int count = *tmPtr++;
    commodityNum = commodity;
    
    for (int i = 0; i < count; i++) {
        FSFinancialRatios *financialRatio = [[FSFinancialRatios alloc] init];
        financialRatio.type = type;
        financialRatio.dataDate = [CodingUtil getUInt16:&tmPtr needOffset:YES];
        financialRatio.profitMargin = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.operatingMargin = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.returnOnAssets = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.returnOnEquity = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.revenuePerShare = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.qtrlyRevenueGrowth = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.eBITDA = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.dilutedEPS = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.qtrlyEarningsGrowth = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.totalCashPerShare = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.totalDebtEquity = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.currentRatio = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.bookValuePerShare = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.operatingCashFlow = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        financialRatio.leveredFreeCashFlow = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];

        [financialRatioArray addObject:financialRatio];
    }
    
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    
    if([model.financeReportUS respondsToSelector:@selector(FinancialRatioCallBack:)]) {
        [model.financeReportUS performSelector:@selector(FinancialRatioCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
    
}
@end
