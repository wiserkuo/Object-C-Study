//
//  TrendEODActionModel.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TrendEODActionModel.h"
#import "TrendEODActionViewController.h"
#import "HistoricDataTypes.h"
@implementation KObject
@end
@implementation TrendEODActionModel
{
    HistoricDataAgent *historicData;
    PortfolioTick *tickBank;
    NSString *systemType;
}
-(NSString *)getStockName:(NSIndexPath*)indexPath
{
    if (_watchlistItem == nil) {
        self.watchlistItem = [[FSWatchlistPortfolioItem alloc] init];
    }
    return [_watchlistItem name:indexPath];
}

-(NSString *)getIdentCodeSymbol:(NSIndexPath*)indexPath
{
    if (_watchlistItem == nil) {
        self.watchlistItem = [[FSWatchlistPortfolioItem alloc] init];
    }
    return [[_watchlistItem portfolioItemAtIndex:indexPath.row] getIdentCodeSymbol];
}

-(int)getStockCount
{
    if (_watchlistItem == nil) {
        self.watchlistItem = [[FSWatchlistPortfolioItem alloc] init];
    }
    return (int)[_watchlistItem count];
}

-(void)setTargetNotify:(NSObject*)object
{
    notifyObj = object;
}

-(void)getFigureImage:(NSString *)symbol Type:(NSString *)type
{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    tickBank = dataModal.historicTickBank;
    systemType = type;
    [tickBank watchTarget:self ForEquity:symbol tickType:'D'];
    
}

-(void)notifyDataArrive:(NSObject<HistoricTickDataSourceProtocol> *)dataSource{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    historicData = [[HistoricDataAgent alloc] init];
    char * ident = malloc(2 * sizeof(UInt8));
    ident[0]=[[dataSource getIdenCodeSymbol] characterAtIndex:0];
    ident[1]=[[dataSource getIdenCodeSymbol] characterAtIndex:1];
    NSString *symbol = [[dataSource getIdenCodeSymbol]substringFromIndex:3];
    PortfolioItem *item = [dataModel.portfolioData findInPortfolio:ident Symbol:symbol];
    [historicData updateData:dataSource forPeriod:AnalysisPeriodDay portfolioItem:item];
    BOOL YESNO = NO;
    if([dataSource isLatestData:'D'])
    {
        YESNO = YES;
    }
    
    if(YESNO){
        int day = 120;
        DecompressedHistoricData *hist;
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        int countNum;
        if([historicData.dataArray count]<120){
            countNum = (int)[historicData.dataArray count];
        }else{
            countNum = 119;
        }
        for(NSUInteger i=[historicData.dataArray count]-1;i>=[historicData.dataArray count]-120; i--){
            hist = [historicData copyHistoricTick:'D' sequenceNo:(int)i];
            KObject *data = [[KObject alloc] init];
            data->lastPrice = hist.close;
            data->day = day;
            countNum --;
            [dataArray insertObject:data atIndex:0];
            day --;
        }
        [tickBank stopWatch:self ForEquity:[dataSource getIdenCodeSymbol]];
        [self setArray:dataArray setIdentCodeSymbol:[dataSource getIdenCodeSymbol]];
    }
}

-(void)setArray:(NSMutableArray*)array setIdentCodeSymbol:(NSString *)is;
{
    identCodeSymbol = is;
    ArrayData *arrayData = [[ArrayData alloc] init];
    
    if([array count] < 119 ){
        portfolioCount++;
        [notifyObj performSelectorOnMainThread:@selector(notifyLongData:) withObject:arrayData waitUntilDone:NO];
        [notifyObj performSelectorOnMainThread:@selector(notifyShortData:) withObject:arrayData waitUntilDone:NO];
        return ;
    }

    //最高價
    double highPrice = -MAXFLOAT;
    //最低價
    double lowPrice = MAXFLOAT;
    //LH左波段高點
    NSMutableArray *LHData = [[NSMutableArray alloc] init];
    //LL左波段低點
    NSMutableArray *LLData = [[NSMutableArray alloc] init];
    //RH右波段高點
    NSMutableArray *RHData = [[NSMutableArray alloc] init];
    //RL右波段低點
    NSMutableArray *RLData = [[NSMutableArray alloc] init];
    //軌道
    NSString *type;

    KObject *kobject = [[KObject alloc] init];
    KObject *kobject_compare = [[KObject alloc] init];
    double maxPrice = -MAXFLOAT;
    double maxPrice_compare = -MAXFLOAT;
    double minPrice = MAXFLOAT;
    double minPrice_compare = MAXFLOAT;
    for(int i = 0; i<[array count]; i++){
        kobject = [array objectAtIndex:i];
        highPrice = MAX(kobject->lastPrice, highPrice);
        lowPrice = MIN(kobject->lastPrice, lowPrice);
    }
  
    for(int i = 0; i<114; i++){
        kobject = [array objectAtIndex:i];
        maxPrice = kobject ->lastPrice;
        minPrice = kobject ->lastPrice;
        for(int y=i+1; y<i+6 ;y++){
            kobject_compare = [array objectAtIndex:y];
            maxPrice = MAX(maxPrice, kobject_compare->lastPrice);
            minPrice = MIN(minPrice, kobject_compare->lastPrice);
        }
        if(maxPrice == kobject->lastPrice){
            if(maxPrice >= maxPrice_compare){
                maxPrice_compare = maxPrice;
                [LHData addObject:kobject];
            }
        }
        if(minPrice == kobject->lastPrice){
            if(minPrice <= minPrice_compare){
                minPrice_compare = minPrice;
                [LLData addObject:kobject];
            }
        }
    }
    
    maxPrice = -MAXFLOAT;
    maxPrice_compare = -MAXFLOAT;
    minPrice = MAXFLOAT;
    minPrice_compare = MAXFLOAT;
    
    for(int i = 119; i>4; i--){
        kobject = [array objectAtIndex:i];
        maxPrice = kobject ->lastPrice;
        minPrice = kobject ->lastPrice;
        for(int y=i-1; y>i-5 ; y--){
            kobject_compare = [array objectAtIndex:y];
            maxPrice = MAX(maxPrice, kobject_compare->lastPrice);
            minPrice = MIN(minPrice, kobject_compare->lastPrice);
        }
        if(maxPrice == kobject->lastPrice){
            if(maxPrice >= maxPrice_compare){
                maxPrice_compare = maxPrice;
                [RHData addObject:kobject];
            }
        }
        if(minPrice == kobject->lastPrice){
            if(minPrice <= minPrice_compare){
                minPrice_compare = minPrice;
                [RLData addObject:kobject];
            }
        }
    }
    
    if([LHData count] >= [RHData count] && [RLData count] >= [LLData count]){
        type = @"Rise";
    }else if([LLData count] >= [RLData count] && [RHData count] >= [LHData count]){
        type = @"Decline";
    }else if([LHData count] >= [RHData count] && [LLData count] >= [RLData count]){
        type = @"Diffusion";
    }else if([RHData count] >= [LHData count] && [RLData count] >= [LLData count]){
        type = @"Astringent";
    }
    
    double dayX;
    double priceY;
    double supportPrice;
    double pressurePrice;
    //斜率
    double slope;
    //支撐線斜率
    double supportLine;
    //壓力線斜率
    double pressureLine;
    
    if([type isEqualToString:@"Rise"]){
        supportLine = MAXFLOAT;
        pressureLine = MAXFLOAT;
        //LH最大價
        double price_LH = -MAXFLOAT;
        //LH最大價天數
        double day_LH;
        //RL最小價
        double price_RL = MAXFLOAT;
        //RL最小價天數
        double day_RL;
        for(int i=0; i<[LHData count]; i++){
            kobject = [LHData objectAtIndex:i];
            price_LH = MAX(price_LH, kobject->lastPrice);
            if(price_LH == kobject->lastPrice){
                day_LH = kobject->day;
                pressurePrice = price_LH;
            }
        }
        for(int i=0; i<[LHData count]; i++){
            kobject = [LHData objectAtIndex:i];
                if(kobject->day != day_LH){
                    dayX = (day_LH - kobject->day)/120;
                    priceY = (price_LH - kobject->lastPrice)/(highPrice-lowPrice);
                    slope = priceY / dayX ;
                    NSLog(@"%f", slope);
                if(slope >=0){
                    pressureLine = MIN(slope, supportLine);
                }
            
            }
        }
        
        for(int i=0; i<[RLData count]; i++){
            kobject = [RLData objectAtIndex:i];
            price_RL = MIN(price_RL, kobject->lastPrice);
            if(price_RL == kobject->lastPrice){
                day_RL = kobject->day;
            }
        }
        for(int i=0; i<[RLData count]; i++){
            kobject = [RLData objectAtIndex:i];
            if(kobject->day != day_RL){
                dayX = (kobject->day - day_RL)/120;
                priceY = (kobject->lastPrice - price_RL)/(highPrice-lowPrice);
                slope = priceY / dayX;
                supportLine = MIN(slope, supportLine);
                if(supportLine == slope){
                    supportPrice = kobject->lastPrice;
                }
            }
        }
    }else if([type isEqualToString:@"Decline"]){
        supportLine =  -MAXFLOAT;
        pressureLine = -MAXFLOAT;
        double price_LL = MAXFLOAT;
        double day_LL;
        double price_RH = -MAXFLOAT;
        double day_RH;
        for(int i=0; i<[LLData count]; i++){
            kobject = [LLData objectAtIndex:i];
            price_LL = MIN(price_LL, kobject->lastPrice);
            if(price_LL == kobject->lastPrice){
                day_LL = kobject->day;
                supportPrice = price_LL;
            }
        }
        for(int i=0; i<[LLData count]; i++){
            kobject = [LLData objectAtIndex:i];
            if(kobject->day != day_LL){
                dayX = (day_LL - kobject->day)/120;
                priceY = (price_LL - kobject->lastPrice)/(highPrice-lowPrice);
                slope = priceY / dayX;
                if(slope <0){
                    supportLine = MAX(slope, supportLine);
                }
            }
        }
        
        for(int i=0; i<[RHData count]; i++){
            kobject = [RHData objectAtIndex:i];
            price_RH = MAX(price_RH, kobject->lastPrice);
            if(price_RH == kobject->lastPrice){
                day_RH = kobject->day;
                pressurePrice = price_RH;
            }
        }
        for(int i=0; i<[RHData count];i++){
            kobject = [RHData objectAtIndex:i];
            if(kobject->day != day_RH){
                dayX = (day_RH - kobject->day)/120;
                priceY = (price_RH - kobject->lastPrice)/(highPrice-lowPrice);
                slope = priceY / dayX;
                pressureLine = MAX(slope, pressureLine);
            }
        }
    }else if([type isEqualToString:@"Diffusion"]){
        pressureLine = MAXFLOAT;
        supportLine = -MAXFLOAT;
        double price_LH = -MAXFLOAT;
        double day_LH;
        double price_LL = MAXFLOAT;
        double day_LL;
        for(int i = 0; i<[LHData count] ; i++){
            kobject = [LHData objectAtIndex:i];
            price_LH = MAX(price_LH, kobject->lastPrice);
            if(price_LH == kobject->lastPrice){
                day_LH = kobject->day;
                pressurePrice = price_LH;
            }
        }
        for(int i =0; i<[LHData count] ; i++){
            kobject = [LHData objectAtIndex:i];
            if(kobject->day != day_LH){
                dayX = (day_LH - kobject->day)/120;
                priceY = (price_LH - kobject->lastPrice)/(highPrice-lowPrice);
                slope = priceY / dayX;
                NSLog(@"%f", slope);
                if(slope >=0){
                    pressureLine = MIN(slope, pressureLine);
                }
            }
        }
        
        for(int i = 0 ; i<[LLData count]; i++){
            kobject = [LLData objectAtIndex:i];
            price_LL = MIN(price_LL, kobject->lastPrice);
            if(price_LL == kobject->lastPrice){
                day_LL = kobject->day;
                supportPrice = price_LL;
            }
        }
        for(int i = 0;i < [LLData count]; i++){
            kobject = [LLData objectAtIndex:i];
            if(kobject->day != day_LL){
                dayX = (day_LL - kobject->day)/120;
                priceY = (price_LL - kobject->lastPrice)/(highPrice-lowPrice);
                slope = priceY / dayX;
                if(slope < 0){
                    supportLine = MAX(slope, supportLine);
                }
            }
        }
    }else{
        pressureLine = MAXFLOAT;
        supportLine = -MAXFLOAT;
        double price_RH = -MAXFLOAT;
        double day_RH;
        double price_RL = MAXFLOAT;
        double day_RL;
        for(int i =0; i < [RHData count]; i++){
            kobject = [RHData objectAtIndex:i];
            price_RH = MAX(price_RH, kobject->lastPrice);
            if(price_RH == kobject->lastPrice){
                day_RH = kobject->day;
                pressurePrice = price_RH;
            }
        }
        for(int i = 0; i < [RHData count]; i++){
            kobject = [RHData objectAtIndex:i];
            if(kobject->day != day_RH){
                dayX = (day_RH - kobject->day)/120;
                priceY = (price_RH - kobject->lastPrice)/(highPrice-lowPrice);
                slope = priceY / dayX;
                pressureLine = MIN(slope, pressureLine);
            }
        }
        
        for(int i = 0; i < [RLData count]; i++){
            kobject = [RLData objectAtIndex:i];
            price_RL = MIN(price_RL, kobject->lastPrice);
            if(price_RL == kobject->lastPrice){
                day_RL = kobject->day;
                supportPrice = price_RL;
            }
        }
        for(int i = 0; i < [RLData count]; i++){
            kobject = [RLData objectAtIndex:i];
            if(kobject->day != day_RL){
                dayX = (day_RL - kobject->day)/120;
                priceY = (price_RL - kobject->lastPrice)/(highPrice-lowPrice);
                slope = priceY / dayX;
                supportLine = MAX(slope, supportLine);
            }
        }
    }
    
    
    double supportAngle = atan(supportLine)/(M_PI/180);
    double pressureAngle = atan(pressureLine)/(M_PI/180);
    //振幅
    double amplitude;
    
    amplitude = (pressurePrice - supportPrice) / supportPrice;
    
    //振幅 = (壓力線價位 - 支撐線價位) / 支撐線價位
    NSMutableArray * resultArray = [[NSMutableArray alloc]init];
    NSMutableArray * resultNameArray = [[NSMutableArray alloc] init];
    
    //Strong Up Trend
    if(supportAngle > 30 && pressureAngle > 30){
        if(supportAngle > pressureAngle){
            if(supportAngle - pressureAngle < 5){
                [resultArray addObject:@"StrongUpTrend"];
                [resultNameArray addObject:@"StrongUpTrend"];
            }
        }else{
            if(pressureAngle - supportAngle < 5){
                [resultArray addObject:@"StrongUpTrend"];
                [resultNameArray addObject:@"StrongUpTrend"];
            }
        }
    }
    //Strong supportAngle
    if(supportAngle < -30 && pressureAngle < -30){
        if(supportAngle > pressureAngle){
            if(supportAngle - pressureAngle < 5){
                [resultArray addObject:@"StrongDownTrend"];
                [resultNameArray addObject:@"StrongDownTrend"];
            }
        }else{
            if(pressureAngle - supportAngle < 5){
                [resultArray addObject:@"StrongDownTrend"];
                [resultNameArray addObject:@"StrongDownTrend"];
            }
        }
    }
    //Up Trend
    if((supportAngle > 10 && supportAngle < 30) && (pressureAngle > 10 && pressureAngle < 30)){
        if(supportAngle > pressureAngle){
            if(supportAngle - pressureAngle < 5){
                [resultArray addObject:@"UpTrend"];
                [resultNameArray addObject:@"UpTrend"];
            }
        }else{
            if(pressureAngle - supportAngle < 5){
                [resultArray addObject:@"UpTrend"];
                [resultNameArray addObject:@"UpTrend"];
            }
        }
    }
    //Down Trend
    if((supportAngle < -10 && supportAngle > -30) && (pressureAngle < -10 && pressureAngle > -30)){
        if(supportAngle > pressureAngle){
            if(supportAngle - pressureAngle < 5){
                [resultArray addObject:@"DownTrend"];
                [resultNameArray addObject:@"DownTrend"];
            }
        }else{
            if(pressureAngle - supportAngle < 5){
                [resultArray addObject:@"DownTrend"];
                [resultNameArray addObject:@"DownTrend"];
            }
        }
    }
    //Flat Trend
    if(supportAngle < 5 && supportAngle > -5 && pressureAngle < 5 && pressureAngle > -5 && amplitude > 0.2){
        [resultArray addObject:@"FlatTrend"];
        [resultNameArray addObject:@"FlatTrend"];
    }
    //Narrow Flat Trend
    if(supportAngle < 5 && supportAngle > -5 && pressureAngle < 5 && pressureAngle > -5 && amplitude < 0.2){
        [resultArray addObject:@"NarrowFlatTrend"];
        [resultNameArray addObject:@"NarrowFlatTrend"];
    }
    
    arrayData->dataArray = resultArray;
    arrayData->nameArray = resultNameArray;
    
    if([systemType isEqualToString:@"Long"]){
        [notifyObj performSelectorOnMainThread:@selector(notifyLongData:) withObject:arrayData waitUntilDone:NO];
    }else if([systemType isEqualToString:@"Short"]){
        [notifyObj performSelectorOnMainThread:@selector(notifyShortData:) withObject:arrayData waitUntilDone:NO];
    }
}


//-(void)ImageNumber:(int)imageNumber Symbol:(NSString *)symbol FSData:(FigureSearchData *)fsData
//             Alert:(void (^)(BOOL needAlert))alert
//{
//    if(imageNumber ==0){
//        alert(NO);
//        return;
//    }
//    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
//                      [NSString stringWithFormat:@"FigureSearchData_%@.plist", symbol]];
//    
//    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//    tickBank = dataModal.historicTickBank;
//    
//    mainDict = [[NSMutableDictionary alloc] init];
//    mainDict = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
//    UInt16 now = [[NSDate date]uint16Value];
//    if(mainDict){
//        if([[mainDict objectForKey:@"Date"]uint16Value] == now ){
//            NSMutableArray *figureSearchArray = [mainDict objectForKey:@"FigureSearchData"];
//            
//            FigureSearchData *FSData1 = [figureSearchArray objectAtIndex:0];
//            if(FSData1->date != fsData->date){
//                [figureSearchArray insertObject:fsData atIndex:0];
//            }
//            
//            if(imageNumber >= 1 && imageNumber <=24){
//                if([self CalculateFormula:figureSearchArray Count:imageNumber]){
//                    alert(YES);
//                }else{
//                    alert(NO);
//                }
//            }else{
//                NSMutableArray * totalCount = [[NSMutableArray alloc]init];
//                NSMutableArray *sumtNumberArray = [[NSMutableArray alloc] init];
//                FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
//                FSDatabaseAgent *dbAgent = dataModel.mainDB;
//                __block BOOL returnFlag;
//                returnFlag = NO;
//                [dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
//                    loopFlag = NO;
//                    FMResultSet *message = [db executeQuery:@"SELECT COUNT(figureSearchKBarValue_ID) AS count FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ?", [NSNumber numberWithInt:imageNumber]];
//                    while ([message next]) {
//                        if([[NSNumber numberWithInt:[message intForColumn:@"COUNT"]]intValue] == 0){
//                            returnFlag = YES;
//                        }
//                    }
//                }];
//                if(returnFlag){
//                    alert(NO);
//                    return;
//                }
//                [dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
//                    FMResultSet *message = [db executeQuery:@"SELECT COUNT(tNumber) AS count FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ?", [NSNumber numberWithInt:imageNumber]];
//                    while ([message next]) {
//                        [totalCount addObject:[NSNumber numberWithInt:[message intForColumn:@"COUNT"]]];
//                    }
//                    for(int tNumberCount = 0 ; tNumberCount<[totalCount count] ; tNumberCount++){
//                        NSMutableArray * tNumberArray = [[NSMutableArray alloc] init];
//                        if(loopFlag){
//                            break;
//                        }
//                        FMResultSet *message = [db executeQuery:@"SELECT tNumber FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ?", [NSNumber numberWithInt:imageNumber]];
//                        while ([message next]) {
//                            [tNumberArray addObject:[NSNumber numberWithInt:[message intForColumn:@"tNumber"]]];
//                        }
//                        
//                        for(int i = 0;i<[tNumberArray count];i++){
//                            if(loopFlag){
//                                break;
//                            }
//                            FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ? and tNumber = ?", [NSNumber numberWithInt:imageNumber], [tNumberArray objectAtIndex:i]];
//                            while ([message next]) {
//                                DIYObject *diyObj = [[DIYObject alloc] init];
//                                diyObj->tNumber = [[tNumberArray objectAtIndex:i]intValue];
//                                diyObj->rangeFlag= [[message stringForColumn:@"range"]boolValue];
//                                diyObj->colorFlag=[[message stringForColumn:@"color"]boolValue];
//                                diyObj->upLineFlag=[[message stringForColumn:@"upLine"]boolValue];
//                                diyObj->kLineFlag=[[message stringForColumn:@"kLine"]boolValue];
//                                diyObj->downLineFlag=[[message stringForColumn:@"downLine"]boolValue];
//                                diyObj->highValue = [message doubleForColumn:@"highValue"];
//                                diyObj->lowValue = [message doubleForColumn:@"lowValue"];
//                                diyObj->openValue = [message doubleForColumn:@"openValue"];
//                                diyObj->closeValue = [message doubleForColumn:@"closeValue"];
//                                [sumtNumberArray addObject:diyObj];
//                            }
//                        }
//                    }
//                }];
//                if([self Calculate:sumtNumberArray FigureSearch:figureSearchArray]){
//                    alert(YES);
//                }else{
//                    alert(NO);
//                }
//            }
//        }else{
//            [tickBank watchTarget:self ForEquity:symbol tickType:'D'];
//            return;
//        }
//    }else{
//        [tickBank watchTarget:self ForEquity:symbol tickType:'D'];
//        return;
//    }
//}

@end

