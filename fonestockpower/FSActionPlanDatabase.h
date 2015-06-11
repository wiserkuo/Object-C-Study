//
//  FSActionPlanDatabase.h
//  FonestockPower
//
//  Created by Derek on 2014/5/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSActionPlanDatabase : NSObject

+(FSActionPlanDatabase *)sharedInstances;
-(void)setUpTables;

//Portfolio
-(NSMutableArray *)searchPortfolioWithTerm:(NSString *)Term;
-(void)insertPortfolioWithDate:(NSString *)date Symbol:(NSString *)symbol Price:(NSString *)price Count:(NSString *)count Term:(NSString *)term;
-(NSMutableArray *)searchPortfolioWithSymbol:(NSString *)symbol;
-(void)deletePortfolioWithSymbol:(NSString *)symbol;
-(void)deletePortfolioWithrowID:(NSString *)rowid;
-(void)updatePortfolioCount:(NSString *)count Withrowid:(NSString *)rowid;

//Invested
-(id)searchInvestedByTerm:(NSString *)term;
-(NSMutableDictionary *)searchInvestedDictionaryByTerm:(NSString *)term;
-(NSString *)searchInvestedTotalAmountByTerm:(NSString *)term Date:(NSString *)date;
-(void)insertInvestedWithDate:(NSString *)date Remit:(NSString *)remit Amount:(NSString *)amount Term:(NSString *)term;
-(void)deleteInvestedDataWithrowid:(NSString *)rowid;
-(id)searchInvestedData;

//K
-(NSMutableArray *)searchSameDayBuyOrSellAVGWithIdentCodeSymbol:(NSString *)ids Date:(NSString *)date Deal:(NSString *)deal;

//Performance
-(NSMutableArray *)searchPerformanceWithTerm:(NSString *)Term;
-(void)insertPerformanceWithEntryDate:(NSString *)entryDate ExitDate:(NSString *)exitDate Symbol:(NSString *)symbol EntryPrice:(NSString *)entryPrice ExitPrice:(NSString *)exitPrice Quantity:(NSString *)quantity Fee:(NSString *)fee Term:(NSString *)term;
-(void)updatePerformanceNote:(NSString *)note WithPerformanceNum:(NSString *)date;
-(void)updateReason:(NSString *)reason WithPerformanceNum:(NSString *)date;
-(NSData *)searchimageWithFigureSearchId:(NSNumber *)idNum;
-(void)deletePerformanceWithSymbol:(NSString *)rowid;

-(void)insertReasonWithIdSymbol:(NSString *)ids Date:(NSString *)date num:(NSNumber *)num Type:(NSString *)type;
-(void)deleteReasonWithIdSymbol:(NSString *)ids andDate:(NSString *)date Type:(NSString *)type;
-(NSMutableArray *)searchReasonWithIdSymbol:(NSString *)ids andDate:(NSString *)date Type:(NSString *)type;

-(id)unionTablesDateColumnWithTerm:(NSString *)term;

//Trade
-(NSMutableArray *)searchPositionWithTerm:(NSString *)term;
-(NSMutableArray *)searchPositionWithTermNotOrderBySeq:(NSString *)term;
-(NSMutableArray *)searchPositionidSymbolWithTerm:(NSString *)term;
-(NSMutableDictionary *)searchPositionWithIdSybol:(NSString *)ids Term:(NSString *)term;
-(NSMutableArray *)searchPositionFirstDateWithIdSybol:(NSString *)ids Term:(NSString *)term;
-(NSMutableArray *)searchPositionWithTerm:(NSString *)term Symbol:(NSString *)symbol;
-(NSMutableArray *)searchTradeCountWithSymbol:(NSString *)symbol Date:(NSString *)date;
-(NSMutableArray *)searchDiaryWithDeal:(NSString *)deal;
-(NSMutableArray *)searchAvgCostWithSymbol:(NSString *)symbol;
-(NSMutableDictionary *)searchRealizedWithIdSymbol:(NSString *)ids Term:(NSString *)term Deal:(NSString *)deal;
-(NSMutableArray *)searchPositionWithTerm:(NSString *)term Deal:(NSString *)deal;
-(NSMutableArray *)searchRealizedOfNetWorthWithTerm:(NSString *)term;
-(NSMutableArray *)searchRealizedOfTradeWithDate:(NSString *)date;
-(NSMutableArray *)searchCostOfTradeWithTerm:(NSString *)term Date:(NSString *)Date;
-(NSMutableArray *)searchAvgCosOfTradetWithSymbol:(NSString *)symbol Date:(NSString *)Date;
-(NSMutableArray *)searchBuyDataOrderByPriceWithSymbol:(NSString *)symbol deal:(NSString *)deal;
-(NSMutableArray *)searchBuyDataOrderByPriceWithSymbol:(NSString *)symbol deal:(NSString *)deal date:(NSString *)date;
-(NSMutableArray *)searchGainDataWithSymbol:(NSString *)symbol Term:(NSString *)term DealBuy:(NSString *)dealBuy DealSell:(NSString *)dealSell;
-(NSString *)searchSharesOwnedWithSymbol:(NSString *)symbol term:(NSString *)term;
-(NSString *)searchQTYOfTradeWithSymbol:(NSString *)symbol Date:(NSString *)date Term:(NSString *)term;

-(BOOL)insertTradeWithDate:(NSString *)date Symbol:(NSString *)symbol Deal:(NSString *)deal Count:(NSString *)count Price:(NSString *)price Term:(NSString *)term Note:(NSString *)note;
-(void)deletePositionsWithrowid:(NSString *)rowid;
-(void)deletePositionsWithIdentCodeSymbol:(NSString *)symbol;
-(void)deletePositionsWithIdentCodeSymbol:(NSString *)symbol Term:(NSString *)term;
-(double)searchPositionQTYWithTerm:(NSString *)term symbol:(NSString *)symbol;

//ActionPlan
-(NSMutableArray *)searchActionPlanDataWithSymbol:(NSString *)symbol;
-(int)searchActionPlanDataWithSymbol:(NSString *)symbol term:(NSString *)term;
-(NSMutableArray *)searchActionPlanDataWithTerm:(NSString *)term;
-(NSMutableArray *)searchActionPlanIdentCodeSymbol;
-(NSArray *)searchIdentCodeSymbolWithTerm:(NSString *)term;

-(float)searchNumberOfActionPlan;
-(BOOL)searchExistSymbolWithSymbol:(NSString *)symbol;

-(void)insertActionPlanWithSybmol:(NSString *)symbol Manual:(NSNumber *)manual Pattern1:(NSNumber *)pattern1 SProfit:(NSNumber *)sProfit SLoss:(NSNumber *)sLoss Pattern2:(NSNumber *)pattern2 Term:(NSString *)term SProfit2:(NSNumber *)SProfit2 SLoss2:(NSNumber *)SLoss2 CostType:(NSString *)costType;

-(void)updateActionPlanDataWithManual:(NSString *)manual Symbol:(NSString *)symbol Term:(NSString *)term;
-(void)updateActionPlanDataWithSProfit:(NSString *)SProfit Symbol:(NSString *)symbol Term:(NSString *)term;
-(void)updateActionPlanDataWithSLoss:(NSString *)SLoss Symbol:(NSString *)symbol Term:(NSString *)term;
-(void)updateActionPlanDataWithSProfit2:(NSString *)SProfit2 Symbol:(NSString *)symbol Term:(NSString *)term;
-(void)updateActionPlanDataWithSLoss2:(NSString *)SLoss2 Symbol:(NSString *)symbol Term:(NSString *)term;
-(void)updateActionPlanDataWithPattern1:(NSString *)pattern1 Symbol:(NSString *)symbol Term:(NSString *)term;
-(void)updateActionPlanDataWithPattern2:(NSString *)pattern2 Symbol:(NSString *)symbol Term:(NSString *)term;
-(void)updateActionPlanDataWithCostType:(NSString *)costType Symbol:(NSString *)symbol Term:(NSString *)term;
-(void)updateActionPlanDataWithPattern2:(NSString *)pattern2 SProfit2:(NSString *)SProfit2 SLoss2:(NSString *)SLoss2 Symbol:(NSString *)symbol Term:(NSString *)term;

-(void)deleteActionbPlanDataWithSymbol:(NSString *)symbol;
-(void)deleteActionPlanDataWithSymbol:(NSString *)symbol Term:(NSString *)term;

//groupPortfolio
-(int)searchGroupPortfolioWithids:(NSString *)ids;
-(int)searchNumberOfgroupPortfolio;

@end
