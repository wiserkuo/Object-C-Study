//
//  FSInvestedModel.m
//  FonestockPower
//
//  Created by Derek on 2014/7/1.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSInvestedModel.h"
#import "FSActionPlanDatabase.h"
#import "NetWorthViewController.h"
#import "HistoricDataTypes.h"

@implementation FSInvestedModel{
    int totalBack;
    NSMutableArray * idSymbolArray;
    NSMutableDictionary * stockCountDictionary;
    NSMutableDictionary * stockAmountDictionary;
    NSMutableDictionary * historicDataDictionary;
    NSMutableDictionary * tradeDataDictionary;
    NSMutableDictionary * firstDateDictionary;
    NSMutableDictionary * buyMoneyDictionary;

    NSString * term;
    NSString * deal;
    
    NSObject *notifyObj;
    
    UInt16 beginDate;
    NSString *identCodeSymbol;
}



-(id)init {
    self = [super init];
    if (self) {
        idSymbolArray = [[NSMutableArray alloc]init];
        historicDataDictionary = [[NSMutableDictionary alloc]init];
        stockCountDictionary = [[NSMutableDictionary alloc]init];
        stockAmountDictionary = [[NSMutableDictionary alloc]init];
        tradeDataDictionary = [[NSMutableDictionary alloc]init];
        firstDateDictionary = [[NSMutableDictionary alloc]init];
        buyMoneyDictionary = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)setTargetNotify:(NSObject*)object
{
    notifyObj = object;
}


-(void)startWithTerm:(NSString *)t Deal:(NSString *)d beginDate:(UInt16)beginDay
{
    [idSymbolArray removeAllObjects];
    totalBack = 0;
    term = t;
    deal = d;
    beginDate = beginDay;
    
    idSymbolArray = [[FSActionPlanDatabase sharedInstances] searchPositionidSymbolWithTerm:term];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        identCodeSymbol = @"US ^DJI";
    }else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN){
        identCodeSymbol = @"SS 000001";
    }else{
        identCodeSymbol = @"TW ^tse01";
    }
    
    if ([idSymbolArray count]>0) {
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        PortfolioTick * tickBank = dataModal.historicTickBank;
        for (int i=0; i<[idSymbolArray count]; i++) {
            
            [tickBank watchTarget:self ForEquity:[idSymbolArray objectAtIndex:i] tickType:'D'];
        }
        [tickBank watchTarget:self ForEquity:identCodeSymbol tickType:'D'];;
    }else{
        [self investedDataWithTerm:term Deal:deal];
    }
    
}

-(void)notifyDataArrive:(NSObject<HistoricTickDataSourceProtocol> *)dataSource{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    HistoricDataAgent *historicData = [[HistoricDataAgent alloc] init];
    char * ident = malloc(2 * sizeof(UInt8));
    ident[0]=[[dataSource getIdenCodeSymbol] characterAtIndex:0];
    ident[1]=[[dataSource getIdenCodeSymbol] characterAtIndex:1];
    NSString *symbol = [[dataSource getIdenCodeSymbol]substringFromIndex:3];
    PortfolioItem *item = [dataModel.portfolioData findInPortfolio:ident Symbol:symbol];
    [historicData updateData:dataSource forPeriod:AnalysisPeriodDay portfolioItem:item];
    if([dataSource isLatestData:'D'])
    {
        totalBack +=1;
        [historicDataDictionary setObject:historicData forKey:[dataSource getIdenCodeSymbol]];
        
    }
    
    if (totalBack == [idSymbolArray count] + 1) {
        [self investedDataWithTerm:term Deal:deal];
    }

}

-(void)investedDataWithTerm:(NSString *)t Deal:(NSString *)d{
    NSMutableArray *histDateArray = [[NSMutableArray alloc]init];
    _investedArray = [[NSMutableDictionary alloc] init];
    _diaryArray = [[NSMutableDictionary alloc] init];
    _positionArray = [[NSMutableArray alloc] init];
    _dataArray = [[NSMutableArray alloc] init];
    _dateArray = [[NSMutableArray alloc] init];
    [stockCountDictionary removeAllObjects];
    [stockAmountDictionary removeAllObjects];
    _investedArray = [[FSActionPlanDatabase sharedInstances] searchInvestedDictionaryByTerm:term];
    _dateArray = [[FSActionPlanDatabase sharedInstances] unionTablesDateColumnWithTerm:term];
    HistoricDataAgent * historicData = [historicDataDictionary objectForKey:identCodeSymbol];
    if (historicData) {
        self.historicDataArray = [[NSMutableArray alloc]initWithArray:historicData.dataArray];
    }
    for (int i=0; i<[idSymbolArray count]; i++) {
        NSMutableDictionary * dataDic = [[FSActionPlanDatabase sharedInstances] searchPositionWithIdSybol:[idSymbolArray objectAtIndex:i] Term:term];
        [tradeDataDictionary setObject:dataDic forKey:[idSymbolArray objectAtIndex:i]];
        
        NSMutableArray * dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionFirstDateWithIdSybol:[idSymbolArray objectAtIndex:i] Term:term];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:[self dateFormateDefinition]];
        NSDate *date =[dateFormat dateFromString:[dataArray objectAtIndex:0] ];
        UInt16 dateInt = [date uint16Value];
        
        [firstDateDictionary setObject:[NSNumber numberWithUnsignedInt:dateInt] forKey:[idSymbolArray objectAtIndex:i]];
        
        [_diaryArray setObject:[[FSActionPlanDatabase sharedInstances] searchRealizedWithIdSymbol:[idSymbolArray objectAtIndex:i] Term:term Deal:@"Sell"] forKey:[idSymbolArray objectAtIndex:i]];
        
        [buyMoneyDictionary setObject:[[FSActionPlanDatabase sharedInstances] searchRealizedWithIdSymbol:[idSymbolArray objectAtIndex:i] Term:term Deal:@"Buy"] forKey:[idSymbolArray objectAtIndex:i]];
    }
    _maxTotal = 0;
    _minTotal = 0;
    _maxDaily = 0;
    float totalValue = 0;
    if ([_dateArray count]>0) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:[self dateFormateDefinition]];
        NSDate *date =[dateFormat dateFromString:[[_dateArray objectAtIndex:0] objectForKey:@"Date"]];
        UInt16 dateInt = [date uint16Value];
        DecompressedHistoricData *lastDate = [_historicDataArray lastObject];
        UInt16 toDateInt = lastDate.date;
        DecompressedHistoricData * lastHist;
        double dailyTotalAmount = 0;
        double oldDaily = 0;
        double TotalPay = 0;
        for (int i = dateInt; i <= toDateInt;) {
            double realizedNum = 0;
            double unrealizedNum = 0;
            double dailyRealizedNum = 0;
            double dailyInvested = 0;
            NSDate *date = [[NSNumber numberWithUnsignedInt:i]uint16ToDate];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:[self dateFormateDefinition]];

            NSString * dateStr = [dateFormat stringFromDate:date];
            
            //投資金額
            
            dailyTotalAmount += [(NSNumber *)[_investedArray objectForKey:dateStr] floatValue];
            dailyInvested = [(NSNumber *)[_investedArray objectForKey:dateStr] floatValue];
//            NSLog(@"!!!!date:%@(%d) , total:%f",dateStr,i,dailyTotalAmount);
            
            //花費金額
            for (int j=0; j<[idSymbolArray count]; j++) {
                NSMutableDictionary * dataDic = [buyMoneyDictionary objectForKey:[idSymbolArray objectAtIndex:j]];
                NSMutableDictionary * symbolDic = [dataDic objectForKey:dateStr];
                
                if (symbolDic) {
                    int buyCount = [[symbolDic objectForKey:@"Count"]intValue];
                    float buyPrice = [(NSNumber *)[symbolDic objectForKey:@"Price"]floatValue];
                    TotalPay += buyCount * buyPrice;
                }
            }
            
           //未實現損益
            for (int j=0; j<[idSymbolArray count]; j++) {
                NSMutableDictionary * dataDic = [tradeDataDictionary objectForKey:[idSymbolArray objectAtIndex:j]];
                NSMutableDictionary * symbolDateCountDic = [dataDic objectForKey:dateStr];
        
                int count=0;
                float amount = 0.0;
                
                if (i>=[[firstDateDictionary objectForKey:[idSymbolArray objectAtIndex:j]]intValue]) {
                    if (symbolDateCountDic) {
                        count = [[stockCountDictionary objectForKey:[idSymbolArray objectAtIndex:j]]intValue] + [[symbolDateCountDic objectForKey:@"Count"]intValue];
                        amount = [(NSNumber *)[stockAmountDictionary objectForKey:[idSymbolArray objectAtIndex:j]]floatValue] + [[symbolDateCountDic objectForKey:@"Count"]intValue] * [(NSNumber *)[symbolDateCountDic objectForKey:@"Price"]floatValue];
                        
                    }else{
                        
                        count = [[stockCountDictionary objectForKey:[idSymbolArray objectAtIndex:j]]intValue];
                        amount = [(NSNumber *)[stockAmountDictionary objectForKey:[idSymbolArray objectAtIndex:j]]floatValue];
                    }
                    
                    
                    [stockCountDictionary setObject:[NSNumber numberWithInt:count] forKey:[idSymbolArray objectAtIndex:j]];
                    [stockAmountDictionary setObject:[NSNumber numberWithFloat:amount] forKey:[idSymbolArray objectAtIndex:j]];
                    
                    HistoricDataAgent * historicData = [historicDataDictionary objectForKey:[idSymbolArray objectAtIndex:j]];
                    
                    DecompressedHistoricData * hist = [historicData copyHistoricTick:'D' Date:i];
                    if (i != hist.date) {
                        hist = lastHist;
                    }else{
                        lastHist = hist;
                        [histDateArray addObject:[NSNumber numberWithUnsignedInt:hist.date]];
                    }
                    if (count!=0) {
                        unrealizedNum += (hist.close-(amount/count)) *[[stockCountDictionary objectForKey:[idSymbolArray objectAtIndex:j]]intValue];
                    }
                }
            }

            //已實現損益
            for (int j=0; j<[idSymbolArray count]; j++) {
                NSMutableDictionary * dataDic = [_diaryArray objectForKey:[idSymbolArray objectAtIndex:j]];
                NSMutableDictionary * symbolDic = [dataDic objectForKey:dateStr];
                
                if (symbolDic) {
                    int sellCount = [[symbolDic objectForKey:@"Count"]intValue];
                    float sellPrice = [(NSNumber *)[symbolDic objectForKey:@"Price"]floatValue];
                    if ([[stockCountDictionary objectForKey:[idSymbolArray objectAtIndex:j]]intValue]!=0) {
                        float sellMoney = abs(sellCount) * sellPrice - abs(sellCount) * ([(NSNumber *)[stockAmountDictionary objectForKey:[idSymbolArray objectAtIndex:j]]floatValue]/[[stockCountDictionary objectForKey:[idSymbolArray objectAtIndex:j]]intValue]);
                        realizedNum += sellMoney;
                        
                        dailyRealizedNum = sellMoney;
                    }
                }
            }
            if ([(NSNumber *)[histDateArray lastObject]intValue] == i) {
                if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW){                    unrealizedNum = unrealizedNum * 1000;
                }
                
                
                totalValue = unrealizedNum + realizedNum;
                if (![term isEqualToString:@"Long"]) {
                    totalValue = totalValue *-1;
                }
                
                if (i>=beginDate) {
                    //資產淨值最大值
                    if (_maxTotal < dailyTotalAmount + totalValue) {
                        _maxTotal = dailyTotalAmount + totalValue;
                    }
                    
                    //資產淨值最小值
                    if (_minTotal == 0) {
                        _minTotal = dailyTotalAmount + totalValue;
                    }else if (_minTotal > dailyTotalAmount + totalValue) {
                        _minTotal = dailyTotalAmount + totalValue;
                    }
                    
                    //已實現損益絕對值最大值
                    if (_maxDaily < fabs(dailyRealizedNum + totalValue)) {
                        _maxDaily = fabs(dailyRealizedNum + totalValue);
                    }
                }

                NetWorthData *investedData = [[NetWorthData alloc] init];
                investedData->date = date;
                investedData->totalValue = dailyTotalAmount + totalValue;
                investedData->dailyValue = totalValue-oldDaily;
                [_dataArray addObject:investedData];
                    
                oldDaily = totalValue;
            }
            
            //i+1
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setDay:1];
            NSDate * nextDate = [calendar dateByAddingComponents:comps toDate:date options:0];

            i = [nextDate uint16Value];

        }
    }

    [notifyObj performSelectorOnMainThread:@selector(dataCallBack:) withObject:self waitUntilDone:NO];
}
-(NSString *)dateFormateDefinition{
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        return @"MM/dd/yyyy";
    }else{
        return @"yyyy/MM/dd";
    }
}
@end

