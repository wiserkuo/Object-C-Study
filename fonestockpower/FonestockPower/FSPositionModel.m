//
//  FSPositionModel.m
//  FonestockPower
//
//  Created by Derek on 2014/7/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSPositionModel.h"
#import "FSActionPlanDatabase.h"

@implementation FSPositionModel
-(id)init {
    self = [super init];
    if (self) {
        [self countryDefinition];
    }
    return self;
}

-(void)loadPositionData:(NSString *)term{
    _positionDataArray = [[NSMutableArray alloc] init];
    _positionArray = [[NSMutableArray alloc] init];
    _actionArray = [[NSMutableArray alloc] init];
    _investedArray = [[NSMutableArray alloc] init];
    _diaryArray = [[NSMutableArray alloc] init];
    if (_isOrderByRow) {
        _positionDataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:term];
    }else{
        _positionDataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTermNotOrderBySeq:term];
    }

    _actionPlanModel = [[FSDataModelProc sharedInstance] actionPlanModel];
    _investedArray = [[FSActionPlanDatabase sharedInstances] searchInvestedByTerm:term];
    _lastFund = [(NSNumber *)[[_investedArray valueForKey:@"Total_Amount"] valueForKey:@"@firstObject"] floatValue];
    _realized = 0;
    _unrealized = 0;
    _totalRiskDollar = 0;
    _totalCost = 0;
    _totalCash = 0;
    _position = 0;
    if ([term isEqualToString:@"Long"]) {
        _actionArray = _actionPlanModel.actionPlanLongArray;
        [self loadDiaryData:@"Sell"];
    }else{
        _actionArray = _actionPlanModel.actionPlanShortArray;
        [self loadDiaryData:@"Cover"];
    }
    
    _diaryArray = self.diaryArray;
    for (FSDiary *diary in _diaryArray) {
        if (isnan(diary.gainDollar)) {
            _realized = 0;
        }else{
            _realized += diary.gainDollar;
        }
    }

    for (int i = 0; i < [_positionDataArray count]; i++) {
        NSMutableArray *costArray = [[NSMutableArray alloc] init];
        costArray = [[FSActionPlanDatabase sharedInstances] searchAvgCostWithSymbol:[[_positionDataArray objectAtIndex:i] objectForKey:@"Symbol"]];
        NSMutableArray *buyDataArray = [[NSMutableArray alloc] init];
        NSMutableArray *sellDataArray = [[NSMutableArray alloc] init];
        if ([term isEqualToString:@"Long"]) {
            buyDataArray = [[FSActionPlanDatabase sharedInstances] searchBuyDataOrderByPriceWithSymbol:[[_positionDataArray objectAtIndex:i] objectForKey:@"Symbol"] deal:@"Buy"];
            sellDataArray = [[FSActionPlanDatabase sharedInstances] searchBuyDataOrderByPriceWithSymbol:[[_positionDataArray objectAtIndex:i] objectForKey:@"Symbol"] deal:@"Sell"];
        }else{
            buyDataArray = [[FSActionPlanDatabase sharedInstances] searchBuyDataOrderByPriceWithSymbol:[[_positionDataArray objectAtIndex:i] objectForKey:@"Symbol"] deal:@"Short"];
            sellDataArray = [[FSActionPlanDatabase sharedInstances] searchBuyDataOrderByPriceWithSymbol:[[_positionDataArray objectAtIndex:i] objectForKey:@"Symbol"] deal:@"Cover"];
        }
        
        float highestBuyingPrice = 0;
        float lowestBuyingPrice = 0;
        float buyCount = 0;
        float sellCount = 0;
        float totalHold = 0;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:_dateFormatter];
        NSMutableArray *costAddArray = [[NSMutableArray alloc] init];
        
        //最高買進價
        for (int j = 0 ; j < [ costArray count]; j++) {
            NSString *deal = [[costArray objectAtIndex:j] objectForKey:@"Deal"];
            if ([deal isEqualToString:@"Buy"]||[deal isEqualToString:@"Short"]) {
                buyCount = [(NSNumber *)[[costArray objectAtIndex:j] objectForKey:@"Count"] floatValue];
                totalHold += buyCount;
                [costAddArray addObject:[costArray objectAtIndex:j]];
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Price" ascending:NO selector:@selector(compare:)];
                NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
                [costAddArray sortUsingDescriptors:sortDescriptors];
            }else{
                sellCount = [(NSNumber *)[[costArray objectAtIndex:j] objectForKey:@"Count"] floatValue];
                totalHold += sellCount;
                for (int z = 0; z < [costAddArray count]; z++) {
                    float mostHighPriceBuyCount = [(NSNumber *)[[costAddArray objectAtIndex:z] objectForKey:@"Count"] floatValue];
                    if (abs(sellCount) > mostHighPriceBuyCount) {
                        sellCount += mostHighPriceBuyCount;
                        NSDictionary *dict = [costAddArray objectAtIndex:z];
                        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                        [mutableDict setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"Count"];
                        [costAddArray setObject: mutableDict atIndexedSubscript:z];
                    }else if (abs(sellCount) == mostHighPriceBuyCount){
                        sellCount += mostHighPriceBuyCount;
                        NSDictionary *dict = [costAddArray objectAtIndex:z];
                        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                        [mutableDict setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"Count"];
                        [costAddArray setObject: mutableDict atIndexedSubscript:z];
                    }else{
                        NSDictionary *dict = [costAddArray objectAtIndex:z];
                        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                        [mutableDict setObject:[NSString stringWithFormat:@"%.f",mostHighPriceBuyCount + sellCount] forKey:@"Count"];
                        [costAddArray setObject: mutableDict atIndexedSubscript:z];
                        sellCount = 0;
                        highestBuyingPrice = [(NSNumber *)[[costAddArray objectAtIndex:z] objectForKey:@"Price"] floatValue];
                        lowestBuyingPrice = [(NSNumber *)[[costAddArray objectAtIndex:z] objectForKey:@"Price"] floatValue];
                        break;
                    }
                }
            }
        }
        
        float longstoreBuyPrice = 0;
        float shortstoreBuyPrice = 0;
        float longHighestPrice = 0;
        float shortLowestPrice = 0;
        
        
        //買進均價
        float totalAvgCost = 0;
        float totalLongPrice = 0;
        float totalLongCount = 0;
        float totalShortPrice = 0;
        float totalShortCount = 0;

        for (int j = 0; j < [costAddArray count]; j++) {
            NSString *deal = [[costAddArray objectAtIndex:j] objectForKey:@"Deal"];
            if ([deal isEqualToString:@"Buy"] || [deal isEqualToString:@"Sell"]){
                float buyCount = [(NSNumber *)[[costAddArray objectAtIndex:j] objectForKey:@"Count"] floatValue];
                float buyPrice = [(NSNumber *)[[costAddArray objectAtIndex:j] objectForKey:@"Price"] floatValue];
                if(buyPrice > longstoreBuyPrice && buyCount > 0){
                    longstoreBuyPrice = buyPrice;
                    longHighestPrice = buyPrice;
                }
                totalLongPrice += buyPrice * buyCount;
                totalLongCount += buyCount;
            }else {
                float buyCount = [(NSNumber *)[[costAddArray objectAtIndex:j] objectForKey:@"Count"] floatValue];
                float buyPrice = [(NSNumber *)[[costAddArray objectAtIndex:j] objectForKey:@"Price"] floatValue];
                
                if (shortLowestPrice == 0) {
                    shortLowestPrice = buyPrice;
                    shortstoreBuyPrice = buyPrice;
                }else{
                    if (buyPrice < shortstoreBuyPrice && buyCount > 0) {
                        lowestBuyingPrice =  MIN(shortLowestPrice, buyPrice);
                    }
                    highestBuyingPrice = MAX(shortLowestPrice, highestBuyingPrice);
                }
                totalShortPrice += buyPrice * buyCount;
                totalShortCount += buyCount;
            }
        }
        if ([term isEqualToString:@"Long"]) {
            highestBuyingPrice = longHighestPrice;
            totalAvgCost = totalLongPrice / totalLongCount;
        }else{
            highestBuyingPrice = shortLowestPrice;
            totalAvgCost = totalShortPrice / totalShortCount;
        }
        

//        float totalAvgCost = 0;
//        float totalBuyPrice = 0;
//        float totalBuyCount = 0;
//
//        for (int j = 0; j < [costAddArray count]; j++) {
//            float buyPrice = [(NSNumber *)[[costAddArray objectAtIndex:j] objectForKey:@"Price"] floatValue];
//            float buyPriceCount = [(NSNumber *)[[costAddArray objectAtIndex:j] objectForKey:@"Count"] floatValue];
//            totalBuyPrice += buyPrice * buyPriceCount;
//            totalBuyCount += buyPriceCount;
//        }
        
//        totalAvgCost = totalBuyPrice / totalBuyCount;
        
        //停損價
        float slNum = 0;
        float slPercent = 0;
        for (FSActionPlan *actionPlan in _actionArray) {
            if ([actionPlan.identCodeSymbol isEqualToString:[[_positionDataArray objectAtIndex:i] objectForKey:@"Symbol"]]) {
                slNum = actionPlan.sellSL;
                slPercent = actionPlan.sellSLPercent;
                break;
            }
        }
        
#ifdef LPCB
        PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
        FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:[[_positionDataArray objectAtIndex:i] objectForKey:@"Symbol"]];
#else
        EquitySnapshotDecompressed *snapShot = [[[FSDataModelProc sharedInstance] portfolioTickBank] getSnapshotFromIdentCodeSymbol:[[_positionDataArray objectAtIndex:i] objectForKey:@"Symbol"]];
#endif
        FSPositions *position = [[FSPositions alloc] init];
        position.identCodeSymbol = [[_positionDataArray objectAtIndex:i] objectForKey:@"Symbol"];
        position.qty = [(NSNumber *)[[_positionDataArray objectAtIndex:i] objectForKey:@"TotalCount"] floatValue];
        position.avgCost = totalAvgCost;
        position.total = position.qty * totalAvgCost;
        position.last = [snapshot.last_price calcValue];
        position.totalVal = [snapshot.last_price calcValue] * position.qty;
        
        //獲利
        if ([term isEqualToString:@"Long"]) {
            position.gainDollar = (position.last - position.avgCost) * (position.qty);
        }else{
            position.gainDollar = (position.avgCost - position.last) * (position.qty);
        }
        position.highestBuyingPrice = highestBuyingPrice;
        position.lowestBuyingPrice = lowestBuyingPrice;
        position.gainPercent = position.gainDollar / position.total;
        position.cng = ([snapshot.last_price calcValue] - [snapshot.reference_price calcValue])/[snapshot.reference_price calcValue];
        
        //曝險金額
        if ([term isEqualToString:@"Long"]) {
            if ([snapshot.last_price calcValue] >= slNum) {
                if (position.avgCost >= slNum) {
                    position.riskDollar = (position.avgCost - slNum) * position.qty;
                }else{
                    position.riskDollar = 0;
                }
            }else if ([snapshot.last_price calcValue] < slNum){
                if ([snapshot.last_price calcValue] < position.avgCost * (1 - (slPercent / 100))) {
                    position.riskDollar = (position.avgCost - [snapshot.last_price calcValue]) * position.qty;
                }else{
                    position.riskDollar = (position.avgCost - position.avgCost * (1 - (slPercent / 100))) * position.qty;
                }
            }
        }else{
            if ([snapshot.last_price calcValue] <= slNum) {
                if (position.avgCost <= slNum) {
                    position.riskDollar = (slNum - position.avgCost) * position.qty;
                }else{
                    position.riskDollar = 0;
                }
            }else if ([snapshot.last_price calcValue] > slNum){
                if ([snapshot.last_price calcValue] > position.avgCost * (1 - (slPercent / 100))) {
                    position.riskDollar = ([snapshot.last_price calcValue] - position.avgCost) * position.qty;
                }else{
                    position.riskDollar = (position.avgCost * (1 - (slPercent / 100)) - position.avgCost) * position.qty;
                }
            }
        }

        //未實現損益
        if (!isnan(position.gainDollar)) {
            _unrealized += position.gainDollar;
        }
        if (isnan(_unrealized)) {
            _unrealized = 0;
        }
        _totalRiskDollar += position.riskDollar;
        if (isnan(_totalRiskDollar)) {
            _totalRiskDollar = 0;
        }
        
        //庫存成本
        _totalCost += position.total;
        if (isnan(_totalCost)) {
            _totalCost = 0;
        }
        
        if (position.qty > 0) {
            [_positionArray addObject:position];
        }
        _position += position.qty * [snapshot.last_price calcValue];

    }
    _netWorth = _lastFund + _realized * _suggestCount + _unrealized * _suggestCount;
}

-(void)loadDiaryData:(NSString *)deal{
    _diaryDataArray = [[NSMutableArray alloc] init];
    _diaryArray = [[NSMutableArray alloc] init];
    _diaryDataArray = [[FSActionPlanDatabase sharedInstances] searchDiaryWithDeal:deal];
    _totalGainRatio = 0;
    
    for (int i = 0; i < [_diaryDataArray count]; i++) {
        NSMutableArray *costArray = [[NSMutableArray alloc] init];
        costArray = [[FSActionPlanDatabase sharedInstances] searchAvgCostWithSymbol:[[_diaryDataArray objectAtIndex:i] objectForKey:@"Symbol"]];
        
        NSMutableArray *buyCostDataArray = [[NSMutableArray alloc] init];
        if ([deal isEqualToString:@"Sell"]) {
            buyCostDataArray = [[FSActionPlanDatabase sharedInstances] searchBuyDataOrderByPriceWithSymbol:[[_diaryDataArray objectAtIndex:i] objectForKey:@"Symbol"] deal:@"Buy"];
        }else{
            buyCostDataArray = [[FSActionPlanDatabase sharedInstances] searchBuyDataOrderByPriceWithSymbol:[[_diaryDataArray objectAtIndex:i] objectForKey:@"Symbol"] deal:@"Short"];
        }

        NSMutableArray *diaryGainArray = [[NSMutableArray alloc] init];
        float sellTotalCost = 0;
        float sellTotalCount = 0;
        float sellAvgCost = 0;
        float totalGain = 0;
        
        for (int j = 0; j < [costArray count]; j++) {
            NSString *deal = [[costArray objectAtIndex:j] objectForKey:@"Deal"];
            if ([deal isEqualToString:@"Sell"]||[deal isEqualToString:@"Cover"]){
                float sellCount = [(NSNumber *)[[costArray objectAtIndex:j] objectForKey:@"Count"] floatValue];
                for (int z = 0; z < [buyCostDataArray count]; z++) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:_dateFormatter];
                    NSDate *date = [dateFormatter dateFromString:[[costArray objectAtIndex:j] objectForKey:@"Date"]];
                    NSDate *buyDate = [dateFormatter dateFromString:[[buyCostDataArray objectAtIndex:z] objectForKey:@"Date"]];
                    if ([date compare:buyDate] == NSOrderedDescending || [date compare:buyDate] == NSOrderedSame) {
                        float buyCount = [(NSNumber *)[[buyCostDataArray objectAtIndex:z] objectForKey:@"Count"] floatValue];
                        if (abs(sellCount) >= buyCount && buyCount > 0) {
                            NSDictionary *dict = [buyCostDataArray objectAtIndex:z];
                            NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                            [diaryGainArray addObject:[buyCostDataArray objectAtIndex:z]];
                            
                            //更新count
                            [mutableDict setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"Count"];
                            [buyCostDataArray setObject: mutableDict atIndexedSubscript:z];
                            
                            //獲利
                            if ([deal isEqualToString:@"Sell"]) {
                                totalGain += [(NSNumber *)[[costArray objectAtIndex:j] objectForKey:@"Price"] floatValue]*abs(sellCount) - [(NSNumber *)[[buyCostDataArray objectAtIndex:z] objectForKey:@"Price"] floatValue]*abs(sellCount);
                            }else{
                                totalGain += [(NSNumber *)[[buyCostDataArray objectAtIndex:z] objectForKey:@"Price"] floatValue]*abs(sellCount) - [(NSNumber *)[[costArray objectAtIndex:j] objectForKey:@"Price"] floatValue]*abs(sellCount);
                            }
                            
                            sellCount = sellCount + buyCount;
                        }else if (buyCount > abs(sellCount) && abs(sellCount) > 0){
                            NSDictionary *dict = [buyCostDataArray objectAtIndex:z];
                            NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                            
                            //更新count
                            [mutableDict setObject:[NSString stringWithFormat:@"%.f", buyCount + sellCount] forKey:@"Count"];
                            
                            NSDictionary *addGaindict = [buyCostDataArray objectAtIndex:z];
                            NSMutableDictionary *addGainMutableDict = [NSMutableDictionary dictionaryWithDictionary:addGaindict];
                            [addGainMutableDict setObject:[NSString stringWithFormat:@"%d", abs(sellCount)] forKey:@"Count"];
                            
                            [diaryGainArray addObject:addGainMutableDict];
                            [buyCostDataArray setObject:mutableDict atIndexedSubscript:z];
                            
                            //獲利
                            if ([deal isEqualToString:@"Sell"]) {
                                totalGain += [(NSNumber *)[[costArray objectAtIndex:j] objectForKey:@"Price"] floatValue]*abs(sellCount) - [(NSNumber *)[[buyCostDataArray objectAtIndex:z] objectForKey:@"Price"] floatValue]*abs(sellCount);
                            }else{
                                totalGain += [(NSNumber *)[[buyCostDataArray objectAtIndex:z] objectForKey:@"Price"] floatValue]*abs(sellCount) - [(NSNumber *)[[costArray objectAtIndex:j] objectForKey:@"Price"] floatValue]*abs(sellCount);
                            }

                            sellCount = 0;
                        }
                    }
                }
            }
        }
        
        for (int j = 0; j < [diaryGainArray count]; j++) {
            float count = [(NSNumber *)[[diaryGainArray objectAtIndex:j] objectForKey:@"Count"] floatValue];
            float price = [(NSNumber *)[[diaryGainArray objectAtIndex:j] objectForKey:@"Price"] floatValue];
            sellTotalCost += count * price;
            sellTotalCount += count;
        }
        sellAvgCost = sellTotalCost / sellTotalCount;
        
        FSDiary *diary = [[FSDiary alloc] init];
        diary.identCodeSymbol = [[_diaryDataArray objectAtIndex:i] objectForKey:@"Symbol"];
        diary.qty = fabs([(NSNumber *)[[_diaryDataArray objectAtIndex:i] objectForKey:@"TotalCount"] floatValue]);
        diary.avgPrice = [(NSNumber *)[[_diaryDataArray objectAtIndex:i] objectForKey:@"AvgCost"] floatValue];
        diary.proceeds = diary.qty * diary.avgPrice;
        diary.avgCost = sellAvgCost;
        diary.totalCost = sellTotalCost;
        diary.gainDollar = totalGain;
        if ([deal isEqualToString:@"Sell"]) {
            diary.gainPercent = (diary.avgPrice - diary.avgCost) / diary.avgCost;
        }else{
            diary.gainPercent = (diary.avgCost - diary.avgPrice) / diary.avgCost;
        }
        [_diaryArray addObject:diary];
        _totalGainRatio += diary.gainDollar / (diary.proceeds - diary.gainDollar);
    }
}

-(void)loadTradeHistoryData:(NSString *)term symbol:(NSString *)symbol{
    _tradeHistoryArray = [[NSMutableArray alloc] init];
    NSMutableArray *tradeHistoryDataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:term Symbol:symbol];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:_dateFormatter];
    for (int i = 0; i < [tradeHistoryDataArray count]; i++) {
        FSTradeHistory *tradeHistory = [[FSTradeHistory alloc] init];
        
        NSString *identCode = [symbol substringToIndex:2];
        NSString *symbolName = [symbol substringFromIndex:3];
        NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:identCode Symbol:symbolName];

        NSDate *date = [formatter dateFromString:[[tradeHistoryDataArray objectAtIndex:i] objectForKey:@"Date"]];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
        int year = (int)[comps year];
        int month = (int)[comps month];
        int day = (int)[comps day];
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            tradeHistory.symbol = symbolName;
            tradeHistory.date = [NSString stringWithFormat:@"%02d/%02d/%d", month, day, year];
        }else {
            tradeHistory.symbol = fullName;
            tradeHistory.date = [NSString stringWithFormat:@"%d/%02d/%02d", year, month, day];
        }
        
        tradeHistory.qty = [(NSNumber *)[[tradeHistoryDataArray objectAtIndex:i] objectForKey:@"Count"] floatValue];
        NSString *dealStr = [[tradeHistoryDataArray objectAtIndex:i] objectForKey:@"Deal"];
        if ([dealStr isEqualToString:@"Buy"]||[dealStr isEqualToString:@"Short"]) {
            tradeHistory.buyDealPrice = [(NSNumber *)[[tradeHistoryDataArray objectAtIndex:i] objectForKey:@"Price"] floatValue];
            tradeHistory.buyAmount = tradeHistory.buyDealPrice * tradeHistory.qty;
        }else {
            tradeHistory.sellDealPrice = [(NSNumber *)[[tradeHistoryDataArray objectAtIndex:i] objectForKey:@"Price"] floatValue];
            tradeHistory.sellAmount = tradeHistory.sellDealPrice * tradeHistory.qty;
        }
        [_tradeHistoryArray addObject:tradeHistory];
    }
}

-(void)deleteTradeHistoryData:(NSUInteger)count term:(NSString *)term symbol:(NSString *)symbol{
    NSMutableArray *tradeHistoryDataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:term Symbol:symbol];
    [[FSActionPlanDatabase sharedInstances] deletePositionsWithrowid:[[tradeHistoryDataArray objectAtIndex:count] objectForKey:@"Seq"]];
    [self loadTradeHistoryData:term symbol:symbol];
}

-(void)countryDefinition{
    switch ([FSFonestock sharedInstance].marketVersion) {
        case FSMarketVersionTW:
            self.dateFormatter = @"yyyy/MM/dd";
            self.suggestCount = 1000;
            break;
        case FSMarketVersionUS:
            self.dateFormatter = @"MM/dd/yyyy";
            self.suggestCount = 1;
            break;
        case FSMarketVersionCN:
            self.dateFormatter = @"yyyy/MM/dd";
            self.suggestCount = 100;
            break;
        default:
            break;
    }
}

@end

@implementation FSPositions

@end

@implementation FSDiary

@end

@implementation FSTradeHistory

@end
