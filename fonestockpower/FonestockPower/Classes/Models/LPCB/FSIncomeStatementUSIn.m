//
//  FSIncomeStatementUSIn.m
//  FonestockPower
//
//  Created by Derek on 2014/9/12.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSIncomeStatementUSIn.h"

@implementation FSIncomeStatementUSIn
- (id)init
{
	if(self = [super init]){
		incomeStatementArray = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    UInt8 *tmPtr = body;
    char type = *tmPtr++;
	int count = *tmPtr++;
    commodityNum = commodity;
    
    for (int i = 0; i < count; i++) {
        FSIncomeStatement *incomeStatement = [[FSIncomeStatement alloc] init];
        incomeStatement.type = type;
        incomeStatement.dataDate = [CodingUtil getUInt16:&tmPtr needOffset:YES];
        incomeStatement.totalRevenue = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.costofRevenue = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.grossProfit = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.researchDevelopment = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.sellingGeneralandAdministrative = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.nonRecurring = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.others = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.totalOperatingExpenses = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.operatingIncomeorLoss = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.totalOtherIncomeExpensesNet = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.earningsbeforeInterestAndTaxes = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.interestExpense = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.incomeBeforeTax = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.incomeTaxExpense = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.minorityInterest = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.netIncomeFromContinuingOps = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.discontinuedOperations = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.netIncome = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.preferredStockAndOtherAdjustments = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        incomeStatement.netIncomeApplicableToCommonshares = [[FSBValueFormat alloc] initWithByte:&tmPtr needOffset:YES];
        
        [incomeStatementArray addObject:incomeStatement];

        
    }
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    
    if([model.financeReportUS respondsToSelector:@selector(IncomeStatementCallBack:)]) {
        [model.financeReportUS performSelector:@selector(IncomeStatementCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }

}
@end
