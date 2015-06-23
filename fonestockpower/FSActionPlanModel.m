//
//  FSActionPlanModel.m
//  FonestockPower
//
//  Created by Derek on 2014/6/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionPlanModel.h"
#import "FigureSearchMyProfileModel.h"
#import "FSActionPlanDatabase.h"
#import "EODActionModel.h"
#import "Commodity.h"
#import "PortfolioOut.h"
#import "FSInstantInfoWatchedPortfolio.h"

@implementation FSActionPlanModel

-(id)init {
    self = [super init];
    if (self) {
        dataDict = [[NSMutableDictionary alloc] init];
        longDataDict = [[NSMutableDictionary alloc] init];
        shortDataDict = [[NSMutableDictionary alloc] init];
        [self loadActionPlanLongData];
        [self loadActionPlanShortData];
    }
    return self;
}

-(void)notification:(NSString *)text{
    UIApplication *application = [UIApplication sharedApplication];
    
    UILocalNotification* notifyAlarm = [[UILocalNotification alloc] init];
    notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
    notifyAlarm.fireDate = [[NSDate date] dateByAddingTimeInterval:3];
    notifyAlarm.repeatInterval = 0;
    notifyAlarm.soundName = UILocalNotificationDefaultSoundName;
    notifyAlarm.alertBody = text;
    [application scheduleLocalNotification:notifyAlarm];
}

-(void)loginNotify{
    symbolArray = [[FSActionPlanDatabase sharedInstances] searchActionPlanIdentCodeSymbol];
    NSMutableArray * array = [[NSMutableArray alloc]init];
    for (int i =0; i<[symbolArray count]; i++) {
        NSString * ids = [symbolArray objectAtIndex:i];
        char identCode[2];
        identCode[0] = [ids characterAtIndex:0];
        identCode[1] = [ids characterAtIndex:1];
        Commodity *obj = [[Commodity alloc] initWithIdentCode:identCode symbol: [ids substringFromIndex:3]];
        
        [array addObject: obj];
    }
    
    
    if ([array count] > 0) {
        PortfolioOut *packet = [[PortfolioOut alloc] init];
        [packet addPortfolio:  array];
        [FSDataModelProc sendData:self WithPacket:packet];
        for (int i = 0; i < [symbolArray count]; i++) {
            [[[FSDataModelProc sharedInstance] portfolioTickBank] watchTarget:self ForEquity:[symbolArray objectAtIndex:i]];
        }
    }
    
    NSString *icSymbol;
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        icSymbol = @"US ^DJI";
    } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        icSymbol = @"SS 000001";
    } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        icSymbol = @"TW ^tse01";
    } else {
        icSymbol = @"TW ^tse01";
    }
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    [dataModel.portfolioData addWatchListItemByIdentSymbolArray:@[icSymbol]];
    
    PortfolioItem *comparedPortfolioItem = [[[FSDataModelProc sharedInstance]portfolioData] findItemByIdentCodeSymbol:icSymbol];
    [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].comparedPortfolioItem = comparedPortfolioItem;
}

-(void)addWatchIdentcodeSymbol:(NSString *)ids{
    [[[FSDataModelProc sharedInstance] portfolioTickBank] watchTarget:self ForEquity:ids];
}

-(void)stopWatchIdentcodeSymbol:(NSString *)ids{
    [[[FSDataModelProc sharedInstance] portfolioTickBank]stopWatch:self ForEquity:ids];
}

-(void)loadActionPlanLongData{
    _dataArray = [[NSMutableArray alloc] init];
    _actionPlanLongArray = [[NSMutableArray alloc] init];
    _positionsArray = [[NSMutableArray alloc] init];
    longSymbolArray = [[NSArray alloc] init];
    _figureSearchArray = [[NSMutableArray alloc] init];
    FSPositionModel *positionModel = [[FSPositionModel alloc] init];
    FSActionPlanDatabase *actionPlanDB = [FSActionPlanDatabase sharedInstances];
    _dataArray = [actionPlanDB searchActionPlanDataWithTerm:@"Long"];
    [positionModel loadPositionData:@"Long"];
    _positionsArray = positionModel.positionArray;
    longSymbolArray = [actionPlanDB searchIdentCodeSymbolWithTerm:@"Long"];
    _figureSearchArray = [[FigureSearchMyProfileModel alloc] actionSearchFigureSearchId];
    
    for (int i = 0; i < [_dataArray count]; i++) {
        NSMutableArray *buyTitleArray = [[FigureSearchMyProfileModel sharedInstance] actionPlanBtnTitleSearchFigureSearchIdWithFigureSearchID:[[_dataArray objectAtIndex:i] objectForKey:@"Pattern1"]];
        NSMutableArray *sellTitleArray = [[FigureSearchMyProfileModel sharedInstance] actionPlanBtnTitleSearchFigureSearchIdWithFigureSearchID:[[_dataArray objectAtIndex:i] objectForKey:@"Pattern2"]];
        
        FSActionPlan *actionPlan = [longDataDict objectForKey:[longSymbolArray objectAtIndex:i]];
        if (actionPlan == nil || [actionPlan.longShortType isEqualToString:@"Short"]) {
            actionPlan = [[FSActionPlan alloc] init];
        }

        actionPlan.identCodeSymbol = [[_dataArray objectAtIndex:i] objectForKey:@"Symbol"];
        actionPlan.target = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"Manual"] floatValue];
        actionPlan.buyStrategyID = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"Pattern1"] floatValue];
        actionPlan.buyStrategyName = [buyTitleArray objectAtIndex:0];
        actionPlan.buySPPercent = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"SProfit"] floatValue];
        actionPlan.buySLPercent = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"SLoss"] floatValue];
        actionPlan.sellStrategyID = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"Pattern2"] floatValue];
        actionPlan.sellStrategyName = [sellTitleArray objectAtIndex:0];
        actionPlan.sellSPPercent = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"SProfit2"] floatValue];
        actionPlan.sellSLPercent = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"SLoss2"] floatValue];
        actionPlan.costType = [[[_dataArray objectAtIndex:i] objectForKey:@"CostType"] boolValue];
        
        if (actionPlan.buySPPercent != 0) {
            actionPlan.buySP = (1 + (actionPlan.buySLPercent / 100)) * actionPlan.target;
        }else if (actionPlan.buySLPercent != 0){
            actionPlan.buySL = (1 - (actionPlan.buySLPercent / 100)) * actionPlan.target;
        }
        
        if (actionPlan.costType == NO) {
            if ([_positionsArray count] == 0) {
                actionPlan.cost = 0;
            }else{
                for (int j = 0; j < [_positionsArray count]; j++) {
                    FSPositions *positions = [_positionsArray objectAtIndex:j];
                    if ([positions.identCodeSymbol isEqual:actionPlan.identCodeSymbol]) {
                        actionPlan.cost = positions.avgCost;
                    }
                }
            }
        }else if (actionPlan.costType == YES){
            if ([_positionsArray count] == 0) {
                actionPlan.cost = 0;
            }else{
                for (int j = 0; j < [_positionsArray count]; j++) {
                    FSPositions *positions = [_positionsArray objectAtIndex:j];
                    if ([positions.identCodeSymbol isEqual:actionPlan.identCodeSymbol]) {
                        actionPlan.cost = positions.highestBuyingPrice;
                    }
                }
            }
        }else{
            actionPlan.cost = 0;
        }
        
#ifdef LPCB
        PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
        FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:actionPlan.identCodeSymbol];
#else
        EquitySnapshotDecompressed *snapshot = [[[FSDataModelProc sharedInstance] portfolioTickBank] getSnapshotFromIdentCodeSymbol:actionPlan.identCodeSymbol];
#endif
        actionPlan.last = [snapshot.last_price calcValue];
        actionPlan.longShortType = @"Long";
        actionPlan.cng = ([snapshot.last_price calcValue] - [snapshot.reference_price calcValue])/[snapshot.reference_price calcValue];
        actionPlan.ref_Price = [snapshot.reference_price calcValue];
        [_actionPlanLongArray addObject:actionPlan];
        [longDataDict setObject:actionPlan forKey:actionPlan.identCodeSymbol];
        
        NSString * sharesOwnedStr = [[FSActionPlanDatabase sharedInstances] searchSharesOwnedWithSymbol:actionPlan.identCodeSymbol term:@"Long"];
        if ([(NSNumber *)sharesOwnedStr floatValue] > 0) {
            actionPlan.cellType = YES;
        }else{
            actionPlan.cellType = NO;
        }
    }
}

-(void)loadActionPlanShortData{
    _dataArray = [[NSMutableArray alloc] init];
    _actionPlanShortArray = [[NSMutableArray alloc] init];
    _positionsArray = [[NSMutableArray alloc] init];
    shortSymbolArray = [[NSMutableArray alloc] init];
    _figureSearchArray = [[NSMutableArray alloc] init];
    FSPositionModel *positionModel = [[FSPositionModel alloc] init];
    FSActionPlanDatabase *actionPlanDB = [FSActionPlanDatabase sharedInstances];
    _dataArray = [actionPlanDB searchActionPlanDataWithTerm:@"Short"];
    [positionModel loadPositionData:@"Short"];
    _positionsArray = positionModel.positionArray;
    shortSymbolArray = [actionPlanDB searchIdentCodeSymbolWithTerm:@"Short"];
    _figureSearchArray = [[FigureSearchMyProfileModel alloc] actionSearchFigureSearchId];
    
    for (int i = 0; i < [_dataArray count]; i++) {
        NSMutableArray *buyTitleArray = [[FigureSearchMyProfileModel sharedInstance] actionPlanBtnTitleSearchFigureSearchIdWithFigureSearchID:[[_dataArray objectAtIndex:i] objectForKey:@"Pattern1"]];
        NSMutableArray *sellTitleArray = [[FigureSearchMyProfileModel sharedInstance] actionPlanBtnTitleSearchFigureSearchIdWithFigureSearchID:[[_dataArray objectAtIndex:i] objectForKey:@"Pattern2"]];
        
        FSActionPlan *actionPlan = [shortDataDict objectForKey:[shortSymbolArray objectAtIndex:i]];
        if (actionPlan ==nil || [actionPlan.longShortType isEqualToString:@"Long"]) {
            actionPlan = [[FSActionPlan alloc] init];
        }
        
        actionPlan.identCodeSymbol = [[_dataArray objectAtIndex:i] objectForKey:@"Symbol"];
        actionPlan.target = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"Manual"] floatValue];
        actionPlan.buyStrategyID = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"Pattern1"] floatValue];
        actionPlan.buyStrategyName = [buyTitleArray objectAtIndex:0];
        actionPlan.buySPPercent = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"SProfit"] floatValue];
        actionPlan.buySLPercent = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"SLoss"] floatValue];
        actionPlan.sellStrategyID = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"Pattern2"] floatValue];
        actionPlan.sellStrategyName = [sellTitleArray objectAtIndex:0];
        actionPlan.sellSPPercent = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"SProfit2"] floatValue];
        actionPlan.sellSLPercent = [(NSNumber *)[[_dataArray objectAtIndex:i] objectForKey:@"SLoss2"] floatValue];
        actionPlan.costType = [[[_dataArray objectAtIndex:i] objectForKey:@"CostType"] boolValue];

        if (actionPlan.costType == NO) {
            if ([_positionsArray count] == 0) {
                actionPlan.cost = 0;
            }else{
                for (int j = 0; j < [_positionsArray count]; j++) {
                    FSPositions *positions = [_positionsArray objectAtIndex:j];
                    if ([positions.identCodeSymbol isEqual:actionPlan.identCodeSymbol]) {
                        actionPlan.cost = positions.avgCost;
                    }
                }
            }
        }else if (actionPlan.costType == YES){
            if ([_positionsArray count] == 0) {
                actionPlan.cost = 0;
            }else{
                for (int j = 0; j < [_positionsArray count]; j++) {
                    FSPositions *positions = [_positionsArray objectAtIndex:j];
                    if ([positions.identCodeSymbol isEqual:actionPlan.identCodeSymbol]) {
                        if (positions.lowestBuyingPrice == 0) {
                            actionPlan.cost = positions.highestBuyingPrice;
                        }else{
                            actionPlan.cost = positions.lowestBuyingPrice;
                        }
                    }
                }
            }
        }else{
            actionPlan.cost = 0;
        }
        
#ifdef LPCB
        PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
        FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:actionPlan.identCodeSymbol];
#else
        EquitySnapshotDecompressed *snapshot = [[[FSDataModelProc sharedInstance] portfolioTickBank] getSnapshotFromIdentCodeSymbol:actionPlan.identCodeSymbol];
#endif
        actionPlan.last = [snapshot.last_price calcValue];
        actionPlan.longShortType = @"Short";
        actionPlan.cng = ([snapshot.last_price calcValue] - [snapshot.reference_price calcValue])/[snapshot.reference_price calcValue];
        actionPlan.ref_Price = [snapshot.reference_price calcValue];
        [_actionPlanShortArray addObject:actionPlan];
        [shortDataDict setObject:actionPlan forKey:actionPlan.identCodeSymbol];
        
        NSString * sharesOwnedStr = [[FSActionPlanDatabase sharedInstances] searchSharesOwnedWithSymbol:actionPlan.identCodeSymbol term:@"Short"];
        if ([(NSNumber *)sharesOwnedStr floatValue] > 0) {
            actionPlan.cellType = YES;
        }else{
            actionPlan.cellType = NO;
        }
    }
}

-(void)notifyDataArrive:(NSObject<TickDataSourceProtocol> *)dataSource{
    EquityTick *tick = (EquityTick *)dataSource;
    for (int i = 0; i < [_actionPlanLongArray count]; i++) {
        FSActionPlan *actionPlan = [_actionPlanLongArray objectAtIndex:i];
        if ([actionPlan.identCodeSymbol isEqualToString:tick.identCodeSymbol]) {
#ifdef LPCB
            FSSnapshot *snapshot = tick.snapshot_b;
#else
            EquitySnapshotDecompressed *snapShot = tick.snapshot;
#endif
            FigureSearchData *figureSearchData = [[FigureSearchData alloc] init];
            figureSearchData -> openPrice = [snapshot.open_price calcValue];
            figureSearchData -> highPrice = [snapshot.high_price calcValue];
            figureSearchData -> lowPrice = [snapshot.low_price calcValue];
            figureSearchData -> closePrice = [snapshot.last_price calcValue];
            figureSearchData -> date = [snapshot.trading_date date16];
            
            actionPlan.last = figureSearchData -> closePrice;
            //Target Alert
            [self getTargerAlertWithFSActionPlan:actionPlan];
            
            //Sell:S@P
            [self getSellProfitAlertWithFSActionPlan:actionPlan];
            
            //Sell:S@L
            [self getSellLossAlertWithFSActionPlan:actionPlan];
            
            //Strategy
            if ([[FSFonestock sharedInstance] checkPermission:FSPermissionTypeStrategyAlert showAlertViewToShopping:NO]) {
                [self getBuyPatternAlertWithFSActionPlan:actionPlan FigureSearchData:figureSearchData];
                [self getSellPatternAlertWithFSActionPlan:actionPlan FigureSearchData:figureSearchData];
            }
            
            if ((_viewController != nil && _viewController.controllerType == YES)) {
                if ([_viewController respondsToSelector:@selector(reloadRowWithIdentCodeSymbol:lastPrice:row:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_viewController reloadRowWithIdentCodeSymbol:actionPlan.identCodeSymbol lastPrice:figureSearchData -> closePrice row:i];
                    });
                }
            }
        }
    }

    for (int i= 0; i < [_actionPlanShortArray count]; i++) {
        FSActionPlan *actionPlan = [_actionPlanShortArray objectAtIndex:i];
        if ([actionPlan.identCodeSymbol isEqualToString:tick.identCodeSymbol]) {
#ifdef LPCB
            FSSnapshot *snapshot = tick.snapshot_b;
#else
            EquitySnapshotDecompressed *snapshot = tick.snapshot;
#endif
            FigureSearchData *figureSearchData = [[FigureSearchData alloc] init];
            figureSearchData -> openPrice = [snapshot.open_price calcValue];
            figureSearchData -> highPrice = [snapshot.high_price calcValue];
            figureSearchData -> lowPrice = [snapshot.low_price calcValue];
            figureSearchData -> closePrice = [snapshot.last_price calcValue];
            figureSearchData -> date = [snapshot.trading_date date16];
            
            actionPlan.last = figureSearchData -> closePrice;
            //Target Alert
            [self getTargerAlertWithFSActionPlan:actionPlan];
            
            //Sell:S@P
            [self getSellProfitAlertWithFSActionPlan:actionPlan];
            
            //Sell:S@L
            [self getSellLossAlertWithFSActionPlan:actionPlan];
            
            //Strategy
            if ([[FSFonestock sharedInstance] checkPermission:FSPermissionTypeStrategyAlert showAlertViewToShopping:NO]) {
                [self getBuyPatternAlertWithFSActionPlan:actionPlan FigureSearchData:figureSearchData];
                [self getSellPatternAlertWithFSActionPlan:actionPlan FigureSearchData:figureSearchData];
            }
            
            if (_viewController != nil && _viewController.controllerType == NO){
//                if ((_viewController != nil && _viewController.controllerType == YES)) {
                    if ([_viewController respondsToSelector:@selector(reloadRowWithIdentCodeSymbol:lastPrice:row:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_viewController reloadRowWithIdentCodeSymbol:actionPlan.identCodeSymbol lastPrice:figureSearchData -> closePrice row:i];
                        });
                    }
//                }
            }
        }
    }
}

-(NSString *)getGroupTextWithids:(NSString *)ids{
    NSString *string = ids;
    NSString *identCode = [string substringToIndex:2];
    NSString *symbol = [string substringFromIndex:3];
    NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:identCode Symbol:symbol];
    NSString *appid = [FSFonestock sharedInstance].appId;
    NSString *group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]) {
        return symbol;
    }else{
        return fullName;
    }
}

-(void)getTargerAlertWithFSActionPlan:(FSActionPlan *)actionPlan{
    NSString *str = [self getGroupTextWithids:actionPlan.identCodeSymbol];
    
    if ([actionPlan.longShortType isEqualToString:@"Long"]) {
        if (actionPlan.target != 0 && actionPlan.last != 0 && actionPlan.target >= actionPlan.last) {
            if (actionPlan.buySellType & FSActionPlanAlertTypeTarget) {
                //up
                [[NSNotificationCenter defaultCenter]postNotificationName:@"alertNotification" object:longDataDict];
            }else{
                actionPlan.buySellType |= FSActionPlanAlertTypeTarget;
                
                [self notification:[NSString stringWithFormat:@"%@(多方)目標價", str]];
            }
        }else{
            if (actionPlan.buySellType & FSActionPlanAlertTypeTarget){
                actionPlan.buySellType -= FSActionPlanAlertTypeTarget;
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelAlertNotification" object:longDataDict];
        }
    }else{
        if (actionPlan.target != 0 && actionPlan.last != 0 && actionPlan.target <= actionPlan.last) {
            if (actionPlan.buySellType & FSActionPlanAlertTypeTarget) {
                //up
                [[NSNotificationCenter defaultCenter]postNotificationName:@"alertNotification" object:longDataDict];
            }else{
                actionPlan.buySellType |= FSActionPlanAlertTypeTarget;
                
                [self notification:[NSString stringWithFormat:@"%@(空方)目標價", str]];
            }
        }else{
            if (actionPlan.buySellType & FSActionPlanAlertTypeTarget){
                actionPlan.buySellType -= FSActionPlanAlertTypeTarget;
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelAlertNotification" object:longDataDict];
        }
    }
}

-(void)getSellProfitAlertWithFSActionPlan:(FSActionPlan *)actionPlan{
    NSString *str = [self getGroupTextWithids:actionPlan.identCodeSymbol];
//    sellSP = 停利價
//    sellSL = 停損價
//    停利 < 現價 = 停利亮紅燈 && 成本 < 現價
//    停損 > 現價 = 停損亮綠燈 && 成本 > 現價
    
    if ([actionPlan.longShortType isEqualToString:@"Long"]) {
        if (actionPlan.cellType) {
            if (actionPlan.sellSPPercent != 0 && actionPlan.last != 0 && actionPlan.last > actionPlan.sellSP) {
                if (actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
                    //up
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"alertNotification" object:longDataDict];
                }else{
                    actionPlan.buySellType |= FSActionPlanAlertTypeSellProfit;
                    
                    [self notification:[NSString stringWithFormat:@"%@(多方)獲利", str]];
                }
            }else{
                if (actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
                    actionPlan.buySellType -= FSActionPlanAlertTypeSellProfit;
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelAlertNotification" object:longDataDict];
                }
            }
        }else{
            if (actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
                actionPlan.buySellType -= FSActionPlanAlertTypeSellProfit;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelAlertNotification" object:longDataDict];
            }
        }
    }else{
        if (actionPlan.cellType) {
            if (actionPlan.sellSPPercent != 0 && actionPlan.last != 0 && actionPlan.last < actionPlan.sellSP) {
                if (actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
                    //up
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"alertNotification" object:shortDataDict];
                }else{
                    actionPlan.buySellType |= FSActionPlanAlertTypeSellLoss;
                    
                    [self notification:[NSString stringWithFormat:@"%@(空方)獲利", str]];
                }
            }else{
                if (actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
                    actionPlan.buySellType -= FSActionPlanAlertTypeSellLoss;
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelAlertNotification" object:shortDataDict];
                }
            }
        }else{
            if (actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
                actionPlan.buySellType -= FSActionPlanAlertTypeSellLoss;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelAlertNotification" object:shortDataDict];
            }
        }
    }
}

-(void)getSellLossAlertWithFSActionPlan:(FSActionPlan *)actionPlan{
    NSString *str = [self getGroupTextWithids:actionPlan.identCodeSymbol];

    if ([actionPlan.longShortType isEqualToString:@"Long"]) {
        if (actionPlan.cellType) {
            if (actionPlan.sellSLPercent != 0 && actionPlan.last != 0 && actionPlan.last < actionPlan.sellSL) {
                if (actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
                    //up
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"alertNotification" object:longDataDict];
                }else{
                    actionPlan.buySellType |= FSActionPlanAlertTypeSellLoss;
                    
                    [self notification:[NSString stringWithFormat:@"%@(多方)停損", str]];
                }
            }else{
                if (actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
                    actionPlan.buySellType -= FSActionPlanAlertTypeSellLoss;
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelAlertNotification" object:longDataDict];
                }
            }
        }else{
            if (actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
                actionPlan.buySellType -= FSActionPlanAlertTypeSellLoss;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelAlertNotification" object:longDataDict];
            }
        }
    }else{
        if (actionPlan.cellType) {
            if (actionPlan.sellSLPercent != 0 && actionPlan.last != 0 && actionPlan.last > actionPlan.sellSL) {
                if (actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
                    //up
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"alertNotification" object:shortDataDict];
                }else{
                    actionPlan.buySellType |= FSActionPlanAlertTypeSellProfit;
                    
                    [self notification:[NSString stringWithFormat:@"%@(空方)停損", str]];
                }
            }else{
                if (actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
                    actionPlan.buySellType -= FSActionPlanAlertTypeSellProfit;
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelAlertNotification" object:shortDataDict];
                }
            }
        }else{
            if (actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
                actionPlan.buySellType -= FSActionPlanAlertTypeSellProfit;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelAlertNotification" object:shortDataDict];
            }
        }
    }
}

-(void)getBuyPatternAlertWithFSActionPlan:(FSActionPlan *)actionPlan FigureSearchData:(FigureSearchData *)figureSearchData{
    NSString *str = [self getGroupTextWithids:actionPlan.identCodeSymbol];
    if ([actionPlan.longShortType isEqualToString:@"Long"]) {
        EODActionModel *eodActionModel = [[FSDataModelProc sharedInstance] edoActionModel];
        [eodActionModel ImageNumber:actionPlan.buyStrategyID Symbol:actionPlan.identCodeSymbol FSData:figureSearchData Alert:^(BOOL needAlert) {
            if (needAlert == YES) {
                if (actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
                }else{
                    actionPlan.buySellType |= FSActionPlanAlertTypeBuyStrategy;
                    actionPlan.pattern1Num = figureSearchData -> closePrice;
                    [self notification:[NSString stringWithFormat:@"%@(買進)警示型態", str]];
                }
            }else{
                if (actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
                    actionPlan.buySellType -= FSActionPlanAlertTypeBuyStrategy;
                }
            }
        }];
    }else{
        EODActionModel *eodActionModel = [[FSDataModelProc sharedInstance] edoActionModel];
        [eodActionModel ImageNumber:actionPlan.buyStrategyID Symbol:actionPlan.identCodeSymbol FSData:figureSearchData Alert:^(BOOL needAlert) {
            if (needAlert == YES) {
                if (actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
                }else{
                    actionPlan.buySellType |= FSActionPlanAlertTypeBuyStrategy;
                    actionPlan.pattern1Num = figureSearchData -> closePrice;
                    [self notification:[NSString stringWithFormat:@"%@(放空)警示型態", str]];
                }
            }else{
                if (actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
                    actionPlan.buySellType -= FSActionPlanAlertTypeBuyStrategy;
                }
            }
        }];
    }
}


-(void)getSellPatternAlertWithFSActionPlan:(FSActionPlan *)actionPlan FigureSearchData:(FigureSearchData *)figureSearchData{
    NSString *str = [self getGroupTextWithids:actionPlan.identCodeSymbol];
    if ([actionPlan.longShortType isEqualToString:@"Long"]) {
        EODActionModel *eodActionModel = [[FSDataModelProc sharedInstance] edoActionModel];
        [eodActionModel ImageNumber:actionPlan.sellStrategyID Symbol:actionPlan.identCodeSymbol FSData:figureSearchData Alert:^(BOOL needAlert) {
            if (needAlert == YES) {
                if (actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
                    
                }else{
                    actionPlan.buySellType |= FSActionPlanAlertTypeSellStrategy;
                    actionPlan.pattern2Num = figureSearchData -> closePrice;
                    
                    [self notification:[NSString stringWithFormat:@"%@(賣出)警示型態", str]];
                }
            }else{
                if (actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
                    actionPlan.buySellType -= FSActionPlanAlertTypeSellStrategy;
                }
            }
        }];
    }else{
        EODActionModel *eodActionModel = [[FSDataModelProc sharedInstance] edoActionModel];
        [eodActionModel ImageNumber:actionPlan.sellStrategyID Symbol:actionPlan.identCodeSymbol FSData:figureSearchData Alert:^(BOOL needAlert) {
            if (needAlert == YES) {
                if (actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
                }else{
                    actionPlan.buySellType |= FSActionPlanAlertTypeSellStrategy;
                    actionPlan.pattern2Num = figureSearchData -> closePrice;
                    
                    [self notification:[NSString stringWithFormat:@"%@(回補)警示型態", str]];
                }
            }else{
                if (actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
                    actionPlan.buySellType -= FSActionPlanAlertTypeSellStrategy;
                }
            }
        }];
    }
}

@end

@implementation FSActionPlan
-(float)buySP{
    if ([_longShortType isEqualToString:@"Long"]) {
        if(_target != 0){
            _buySP = (1 + _buySPPercent / 100) * _target;
        }else{
            _buySP = 0;
        }
    }else{
        if(_target != 0){
            _buySP = (1 - _buySPPercent / 100) * _target;
        }else{
            _buySP = 0;
        }
    }
    return _buySP;
}

-(float)buySL{
    if ([_longShortType isEqualToString:@"Long"]) {
        if(_target != 0){
            _buySL = (1 - _buySLPercent / 100) * _target;
        }else{
            _buySL = 0;
        }
    }else{
        if(_target != 0){
            _buySL = (1 + _buySLPercent / 100) * _target;
        }else{
            _buySL = 0;
        }
    }
    return _buySL;
}

-(float)sellSP{
    if ([_longShortType isEqualToString:@"Long"]) {
        if (_cost != 0) {
            _sellSP = (1 + _sellSPPercent / 100) * _cost;
        }else{
            _sellSP = 0;
        }
    }else{
        if (_cost != 0) {
            _sellSP = (1 - _sellSPPercent / 100) * _cost;
        }
    }
    _sellSL = [self sellSL];
    if ([_longShortType isEqualToString:@"Long"]) {
        if (_sellSL > _sellSP) {
            _sellSP = _sellSL;
        }
    }else{
        if (_sellSL < _sellSP) {
            _sellSP = _sellSL;
        }
    }
    
    return _sellSP;
}

-(float)sellSL{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    EquityTick *ticks = [dataModel.portfolioTickBank getEquityTick:_identCodeSymbol];
    FSSnapshot * snapshot = ticks.snapshot_b;
    
    if ([_longShortType isEqualToString:@"Long"]) {
        if (_cost != 0) {
            _sellSL = (1 - _sellSLPercent / 100) * _cost;
        }else{
            _sellSL = 0;
        }
    }else{
        if (_cost != 0) {
            _sellSL = (1 + _sellSLPercent / 100) * _cost;
        }
    }
    
    //當參考價 > 停利價
    if ([_longShortType isEqualToString:@"Long"]) {
        if ([snapshot.reference_price calcValue] > _sellSP && _cost != 0) {
            if ((1 - _sellSLPercent / 100) * [snapshot.reference_price calcValue] >= _sellSL) {
                _sellSL = (1 - _sellSLPercent / 100) * [snapshot.reference_price calcValue];
            }
        }
    }else{
        if ([snapshot.reference_price calcValue] < _sellSP && _cost != 0) {
            if ((1 + _sellSLPercent / 100) * [snapshot.reference_price calcValue] <= _sellSL) {
                _sellSL = (1 + _sellSLPercent / 100) * [snapshot.reference_price calcValue];
            }
        }
    }

    
    return _sellSL;
}

@end
