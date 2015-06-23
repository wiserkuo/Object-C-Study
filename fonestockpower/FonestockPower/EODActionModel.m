//
//  EDOActionModel.m
//  FonestockPower
//
//  Created by Kenny on 2014/6/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "EODActionModel.h"
#import "EODActionController.h"
#import "HistoricDataTypes.h"
#import "EODActionController.h"
@interface EODActionModel ()
{
    EODActionController *notifyObj;
}

@end
@implementation FigureSearchData
- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        date = [coder decodeIntForKey:@"date"];
        openPrice = [coder decodeDoubleForKey:@"openPrice"];
        highPrice = [coder decodeDoubleForKey:@"highPrice"];
        lowPrice = [coder decodeDoubleForKey:@"lowPrice"];
        closePrice = [coder decodeDoubleForKey:@"closePrice"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if ([coder isKindOfClass:[NSKeyedArchiver class]]) {
        [coder encodeInt:date forKey:@"date"];
        [coder encodeDouble:openPrice forKey:@"openPrice"];
        [coder encodeDouble:highPrice forKey:@"highPrice"];
        [coder encodeDouble:lowPrice forKey:@"lowPrice"];
        [coder encodeDouble:closePrice forKey:@"closePrice"];
    } else {
        [NSException raise:NSInvalidArchiveOperationException
                    format:@"Only supports NSKeyedArchiver coders"];
    }
}
@end
@implementation DIYObject
@end
@implementation ArrayData
@end
@implementation EODActionModel
{
    HistoricDataAgent *historicData;
    PortfolioTick *tickBank;
    NSString *systemType;
    NSInteger hour;
    NSInteger minute;
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

-(void)setTargetNotify:(EODActionController *)object
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
    item = [dataModel.portfolioData findInPortfolio:ident Symbol:symbol];
    [historicData updateData:dataSource forPeriod:AnalysisPeriodDay portfolioItem:item];
    PortfolioTick *itickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
    FSSnapshot *snapShot = [itickBank getSnapshotBvalueFromIdentCodeSymbol:[dataSource getIdenCodeSymbol]];
    MarketInfoItem *pMarket = [[[FSDataModelProc sharedInstance]marketInfo] getMarketInfo: item ->market_id];
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [cal components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:nowDate];
    int tempHour = (int)[dateComponents hour];
    int tempMinute = (int)[dateComponents minute];
    int tempNowDate = tempHour * 60 + tempMinute;
    int snapShotDate = snapShot.trading_date.date16;
    
    BOOL YESNO = NO;

    if([dataSource isLatestData:'D'])
    {
        YESNO = YES;
    }
    
    if(YESNO){
        DecompressedHistoricData *hist;

        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        int countNum;
            if([historicData.dataArray count] < 60){
                countNum = (int)[historicData.dataArray count];
            }else{
                countNum = 60;
            }
        for(NSUInteger i = [historicData.dataArray count] - 1; countNum >=0; i--){
            hist = [historicData copyHistoricTick:'D' sequenceNo:(int)i];
            FigureSearchData *data = [[FigureSearchData alloc]init];
            
//            即時盤
            if (isOnSession) {
                if (i == [historicData.dataArray count] - 1 ) {
                    if (hist.date < snapShotDate) {
                        data->highPrice = snapShot.high_price.calcValue;
                        data->closePrice = snapShot.last_price.calcValue;
                        data->lowPrice = snapShot.low_price.calcValue;
                        data->openPrice = snapShot.open_price.calcValue;
                        data->date = snapShotDate;
                    }else{
                        data = [self setFigureSearchData:data DecompressedHistoricData:hist];
                    }
                }else{
                    data = [self setFigureSearchData:data DecompressedHistoricData:hist];
                }
                
//             盤後
            }else{
                if (pMarket -> startTime_1 < tempNowDate && pMarket -> endTime_1 > tempNowDate) {
                    if (hist.date < snapShotDate) {
                        data = [self setFigureSearchData:data DecompressedHistoricData:hist];
                    }
                }else{
                    if (hist.date <= snapShotDate) {
                        data = [self setFigureSearchData:data DecompressedHistoricData:hist];
                    }
                }
            }
            countNum --;
            if (data -> date != 0) {
                [dataArray addObject:data];
            }
        }
        [tickBank stopWatch:self ForEquity:[dataSource getIdenCodeSymbol]];
        [self setArray:dataArray setIdentCodeSymbol:[dataSource getIdenCodeSymbol]];
    }
}

-(FigureSearchData *)setFigureSearchData:(FigureSearchData *)figureSearchData DecompressedHistoricData:(DecompressedHistoricData *)decompressedHistoricData {
    
    figureSearchData->highPrice = decompressedHistoricData.high;
    figureSearchData->closePrice = decompressedHistoricData.close;
    figureSearchData->lowPrice = decompressedHistoricData.low;
    figureSearchData->openPrice = decompressedHistoricData.open;
    figureSearchData->date = decompressedHistoricData.date;
    
    return figureSearchData;
}
-(void)setArray:(NSMutableArray*)array setIdentCodeSymbol:(NSString *)is;
{
    ArrayData *arrayData = [[ArrayData alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    if([array count] < 6 ){
        portfolioCount++;
        [notifyObj performSelectorOnMainThread:@selector(notifyLongData:) withObject:arrayData waitUntilDone:NO];
        [notifyObj performSelectorOnMainThread:@selector(notifyShortData:) withObject:arrayData waitUntilDone:NO];
        return ;
    }
    

    
    if(!components){
        NSUInteger componentFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
        components = [[NSCalendar currentCalendar] components:componentFlags fromDate:[[NSDate alloc]init]];
        hour = [components hour];
        minute = [components minute];
    }
//    MarketInfoItem *market = [[[FSDataModelProc sharedInstance]marketInfo] getMarketInfo:item->market_id];
//    int time = (int)hour * 60 + (int)minute;
//    if(time >= market->startTime_1 && time <= market->endTime_1){
//        [array removeObjectAtIndex:0];
//    }
    
    NSMutableArray *imageArray = [[ NSMutableArray alloc] init];
    NSMutableArray *figureSearchArray = [[NSMutableArray alloc] init];
    
    for(int i=0; i<[array count] ; i++){
        FigureSearchData *figureSearchData = [[FigureSearchData alloc] init];
        figureSearchData = [array objectAtIndex:i];
        if(i==0){
//            NSLog(@"%@",[[NSNumber numberWithInt:figureSearchData->date]uint16ToDate]);
        }
        [figureSearchArray addObject:figureSearchData];
    
    }

    portfolioCount ++;
    
    for(int i = 1; i < 25; i++){
        if([self CalculateFormula:figureSearchArray Count:i]){
            [imageArray addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    //DIY Pattern
    NSMutableArray * imageDIYResultArray = [[NSMutableArray alloc] init];
    NSMutableArray * figureDIYSearchID = [[NSMutableArray alloc] init];
    NSMutableArray * totalCount = [[NSMutableArray alloc]init];
    figureDIYSearchID = [self getDIYFigureSearch_ID];
    
    for(int figureSearchIDCount = 0; figureSearchIDCount<[figureDIYSearchID count] ; figureSearchIDCount++){
        [dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            loopFlag = NO;
            FMResultSet *message = [db executeQuery:@"SELECT COUNT(tNumber) AS count FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ?", [figureDIYSearchID objectAtIndex:figureSearchIDCount]];
            while ([message next]) {
                [totalCount addObject:[NSNumber numberWithInt:[message intForColumn:@"count"]]];
            }
        
            NSMutableArray *sumtNumberArray = [[NSMutableArray alloc] init];
            for(int tNumberCount = 0 ; tNumberCount<[(NSNumber *)[totalCount objectAtIndex:figureSearchIDCount]intValue] ; tNumberCount++){
                NSMutableArray * tNumberArray = [[NSMutableArray alloc] init];
                if(loopFlag){
                    break;
                }
                FMResultSet *message = [db executeQuery:@"SELECT tNumber FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ?",[figureDIYSearchID objectAtIndex:figureSearchIDCount]];
                while ([message next]) {
                    [tNumberArray addObject:[NSNumber numberWithInt:[message intForColumn:@"tNumber"]]];
                }
                
                
                for(int i = 0;i<[tNumberArray count];i++){
                    if(loopFlag){
                        break;
                    }
                    FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ? and tNumber = ?", [figureDIYSearchID objectAtIndex:figureSearchIDCount], [tNumberArray objectAtIndex:i]];
                    while ([message next]) {
                        DIYObject *diyObj = [[DIYObject alloc] init];
                        diyObj->tNumber = [(NSNumber *)[tNumberArray objectAtIndex:i]intValue];
                        diyObj->rangeFlag= [[message stringForColumn:@"range"]boolValue];
                        diyObj->colorFlag=[[message stringForColumn:@"color"]boolValue];
                        diyObj->upLineFlag=[[message stringForColumn:@"upLine"]boolValue];
                        diyObj->kLineFlag=[[message stringForColumn:@"kLine"]boolValue];
                        diyObj->downLineFlag=[[message stringForColumn:@"downLine"]boolValue];
                        diyObj->highValue = [message doubleForColumn:@"highValue"];
                        diyObj->lowValue = [message doubleForColumn:@"lowValue"];
                        diyObj->openValue = [message doubleForColumn:@"openValue"];
                        diyObj->closeValue = [message doubleForColumn:@"closeValue"];
                        [sumtNumberArray addObject:diyObj];
                    }
                }
                
            }
            if([self Calculate:sumtNumberArray FigureSearch:figureSearchArray]){
                [imageDIYResultArray addObject:[figureDIYSearchID objectAtIndex:figureSearchIDCount]];
            }
        }];
    }
    
    NSMutableArray * resultArray = [[NSMutableArray alloc]init];
    NSMutableArray * resultNameArray = [[NSMutableArray alloc] init];
    
    [dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        for(int i=0;i<[imageArray count];i++){
            FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearch WHERE figureSearch_ID = ?",[imageArray objectAtIndex:i]];
            while ([message next]) {
                [resultArray addObject:[message dataForColumn:@"image_binary"]];
                [resultNameArray addObject:NSLocalizedStringFromTable([message stringForColumn:@"title"], @"FigureSearch", nil)];
                arrayData->dataArray = resultArray;
                arrayData->nameArray = resultNameArray;
            }
                 
        }
        for(int i=0;i<[imageDIYResultArray count];i++){
            FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearch WHERE figureSearch_ID = ?",[imageDIYResultArray objectAtIndex:i]];
            while ([message next]) {
                [resultArray addObject:[message dataForColumn:@"image_binary"]];
                [resultNameArray addObject:NSLocalizedStringFromTable([message stringForColumn:@"title"], @"FigureSearch", nil)];
                arrayData->dataArray = resultArray;
                arrayData->nameArray = resultNameArray;
            }
        }
    }];
    
    eodDictionary = [[NSMutableDictionary alloc]init];
    
    NSDate * now = [NSDate date];
    [eodDictionary setObject:now forKey:@"Date"];
    [eodDictionary setObject:figureSearchArray forKey:@"FigureSearchData"];
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"FigureSearchData_%@.plist", is]];
    
    [NSKeyedArchiver archiveRootObject:eodDictionary toFile:path];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getAlert" object:nil userInfo:nil];
    if([systemType isEqualToString:@"Long"]){
        [notifyObj notifyLongData:arrayData];
    }else if([systemType isEqualToString:@"Short"]){
        [notifyObj notifyShortData:arrayData];
    }

}

-(BOOL)CalculateFormula:(NSMutableArray *)DataArray Count:(int)count
{

    BOOL isTW;
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        isTW = YES;
    }else{
        isTW = NO;
    }
    //今天的開高低收
    FigureSearchData *todayData =[DataArray objectAtIndex:0];
    //1日前的開高低收
    FigureSearchData *oneData =[DataArray objectAtIndex:1];
    //2日前的開高低收
    FigureSearchData *twoData =[DataArray objectAtIndex:2];
    //3日前的開高低收
    FigureSearchData *threeData =[DataArray objectAtIndex:3];
    //4日前的開高低收
    FigureSearchData *fourData =[DataArray objectAtIndex:4];
    //------------------------------------------------------------------------------------------------------------------------
    //價創20日新高
    price0_20HighFlag = YES;
    for(int i = 1; i < [DataArray count] && i < 21;i++){
        FigureSearchData *data =[DataArray objectAtIndex:i];
        if(todayData->highPrice < data->highPrice){
            price0_20HighFlag = NO;
        }
    }
    
    //價創20日新低
    price0_20LowFlag = YES;
    for(int i = 1; i < [DataArray count] && i < 21; i++){
        FigureSearchData *data =[DataArray objectAtIndex:i];
        if(todayData->lowPrice > data->lowPrice){
            price0_20LowFlag = NO;
        }
    }
    
    //1日前的價創20日新高
    price1_20HighFlag = YES;
    for(int i = 2 ; i < [DataArray count] && i < 22;i++){
        FigureSearchData *data =[DataArray objectAtIndex:i];
        if(oneData->highPrice < data->highPrice){
            price1_20HighFlag = NO;
        }
    }
    //1日前的價創15日新高
    price1_15HighFlag = YES;
    for(int i = 2 ; i < [DataArray count] && i < 17;i++){
        FigureSearchData *data =[DataArray objectAtIndex:i];
        if(oneData->highPrice < data->highPrice){
            price1_15HighFlag = NO;
        }
    }
    
    //1日前的價創20日新低
    price1_20LowFlag = YES;
    for(int i = 2 ; i < [DataArray count] && i < 22;i++){
        FigureSearchData *data =[DataArray objectAtIndex:i];
        if(oneData->lowPrice > data->lowPrice){
            price1_20LowFlag = NO;
        }
    }
    //1日前的價創15日新低
    price1_15LowFlag = YES;
    for(int i = 2 ; i < [DataArray count] && i < 17;i++){
        FigureSearchData *data =[DataArray objectAtIndex:i];
        if(oneData->lowPrice > data->lowPrice){
            price1_15LowFlag = NO;
        }
    }
    //2日前的價創20日新低
    price2_20LowFlag = YES;
    for(int i = 3 ; i < [DataArray count] && i < 23;i++){
        FigureSearchData *data =[DataArray objectAtIndex:i];
        if(twoData->lowPrice > data->lowPrice){
            price2_20LowFlag = NO;
        }
    }
    
    //2日前的價創20日新高
    price2_20HighFlag = YES;
    for(int i = 3 ; i < [DataArray count] && i < 23;i++){
        FigureSearchData *data =[DataArray objectAtIndex:i];
        if(twoData->highPrice > data->highPrice){
            price2_20HighFlag = NO;
        }
    }

    //1日前的近3日日收盤價最大值
    double last1_3MaxPrice = MAX(oneData->closePrice, MAX(twoData->closePrice,threeData->closePrice));
    //1日前的近3日日開盤價最大值
    double open1_3MaxPrice = MAX(oneData->openPrice, MAX(twoData->openPrice,threeData->openPrice));
    //1日前的近3日日開盤價最小值
    double open1_3MinPrice = MIN(oneData->openPrice, MIN(twoData->openPrice,threeData->openPrice));
    //1日前的近3日日收盤價最小值
    double close1_3MinPrice = MIN(oneData->closePrice, MIN(twoData->closePrice,threeData->closePrice));
    
    //1日前的近20日5日均價最大值
    double breakSumValue;
    double breakAvgValue;
    double maxAvg1_20_5Price;
    double minAvg1_20_5Price;
    maxAvg1_20_5Price = 0;
    minAvg1_20_5Price = 0;
    for(int i = 1 ; i + 4 < [DataArray count] && i < 21;i++){
        breakSumValue = 0;
        for(int j = i; j < i + 5;j++){
            FigureSearchData *data =[DataArray objectAtIndex:j];
            breakSumValue = data->closePrice + breakSumValue;
        }
        breakAvgValue = breakSumValue / 5.0f;
        if(breakAvgValue > maxAvg1_20_5Price){
            maxAvg1_20_5Price = breakAvgValue;
        }
        if(breakAvgValue < maxAvg1_20_5Price || breakAvgValue < maxAvg1_20_5Price == 0 ){
            minAvg1_20_5Price = breakAvgValue;
        }
    }
    
    //近3日日最高價最大值
    double high3MaxPrice = MAX(todayData->highPrice, MAX(oneData->highPrice,twoData->highPrice));
    
    //近3日日最低價最小值
    double low3MinPrice = MIN(todayData->lowPrice, MIN(oneData->lowPrice,twoData->lowPrice));
    
    double last3MinPrice = MIN(todayData->closePrice, MIN(oneData->closePrice,twoData->closePrice));
    
    
    
    //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓LongSystem↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    switch (count) {
        case 1:
            //長紅棒
            if((todayData->closePrice - todayData->openPrice)> oneData->closePrice * [NSLocalizedStringFromTable(@"LONGPARAM_Day_2", @"FigureSearchFormula", nil)doubleValue]){
                return YES;
            }
            return NO;
            break;
        case 2:
            //雙錘打樁
            if((todayData->highPrice / todayData->closePrice) < [NSLocalizedStringFromTable(@"TWOPARAM_Day", @"FigureSearchFormula", nil)doubleValue] && todayData->closePrice >= todayData->openPrice && (todayData->openPrice - todayData->lowPrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && (oneData->highPrice / oneData->closePrice) < [NSLocalizedStringFromTable(@"TWOPARAM_Day", @"FigureSearchFormula", nil)doubleValue] && oneData->closePrice > oneData->openPrice && (oneData->openPrice - oneData->lowPrice) > twoData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                return YES;
            }
            return NO;
            break;
        case 3:
            //晨星十字
            if (isTW) {
                if(oneData->closePrice >= oneData->openPrice){
                    if(price1_20LowFlag && (todayData->closePrice - todayData->openPrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && todayData->closePrice>= twoData->openPrice && todayData->lowPrice >= oneData->highPrice &&((oneData->closePrice - oneData->openPrice)/oneData->closePrice) < [NSLocalizedStringFromTable(@"MULT_Day", @"FigureSearchFormula", nil)doubleValue] && oneData->highPrice <= twoData->lowPrice && (twoData->openPrice - twoData->closePrice) > threeData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                        return YES;
                    }
                }else{
                    if(price1_20LowFlag && (todayData->closePrice - todayData->openPrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && todayData->closePrice >= twoData->openPrice && todayData->lowPrice >= oneData->highPrice &&((oneData->openPrice - oneData->closePrice)/oneData->closePrice) < [NSLocalizedStringFromTable(@"MULT_Day", @"FigureSearchFormula", nil)doubleValue] && oneData->highPrice <= twoData->lowPrice && (twoData->openPrice - twoData->closePrice) > threeData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                        return YES;
                    }
                }
            }else{
                if(oneData->closePrice >= oneData->openPrice){
                    if (price1_15LowFlag && (todayData -> closePrice - todayData -> openPrice) > oneData -> closePrice * 0.02 && todayData -> closePrice - twoData -> closePrice > (twoData -> openPrice - twoData -> closePrice) * 0.5 && todayData -> lowPrice >= oneData -> highPrice * 0.995 && (oneData -> closePrice - oneData -> openPrice) < oneData -> closePrice * 0.01 && oneData -> highPrice <= twoData -> lowPrice * 1.005 && (twoData -> openPrice - twoData -> closePrice) > threeData -> closePrice * 0.02) {
                        return YES;
                    }
                }else{
                    if (price1_15LowFlag && (todayData -> closePrice - todayData -> openPrice) > oneData -> closePrice * 0.02 && todayData -> closePrice - twoData -> closePrice > (twoData -> openPrice - twoData -> closePrice) * 0.5 && todayData -> lowPrice >= oneData -> highPrice * 0.995 && (oneData -> openPrice - oneData -> closePrice) < oneData -> closePrice * 0.01 && oneData -> highPrice <= twoData -> lowPrice * 1.005 && (twoData -> openPrice - twoData -> closePrice) > threeData -> closePrice * 0.02) {
                        return YES;
                    }
                }
            }

            return NO;
            break;
        case 4:
            //紅三兵
            if (isTW) {
                if(((todayData->closePrice > todayData->openPrice) &&
                    (oneData->closePrice > oneData->openPrice) &&
                    (twoData->closePrice > twoData->openPrice)) &&
                   ((todayData->highPrice > oneData->highPrice) &&
                    (oneData->highPrice > twoData->highPrice) &&
                    (twoData->highPrice > threeData->highPrice)) &&
                   ((todayData->lowPrice > oneData->lowPrice) &&
                    (oneData->lowPrice > twoData->lowPrice) &&
                    (twoData->lowPrice > threeData->lowPrice))){
                       return YES;
                   }
            }else{
                if(((todayData->closePrice > todayData->openPrice) &&
                    (oneData->closePrice > oneData->openPrice) &&
                    (twoData->closePrice > twoData->openPrice)) &&
                   ((todayData->highPrice > oneData->highPrice) &&
                    (oneData->highPrice > twoData->highPrice) &&
                    (twoData->highPrice > threeData->highPrice)) &&
                   ((todayData->lowPrice > oneData->lowPrice) &&
                    (oneData->lowPrice > twoData->lowPrice) &&
                    (twoData->lowPrice > threeData->lowPrice)) &&
                   ((todayData->closePrice > oneData->closePrice) &&
                    (oneData->closePrice > twoData->closePrice) &&
                    (twoData->closePrice > threeData->closePrice))){
                       return YES;
                   }
            }
            return NO;
            break;
        case 5:
            //雙龍環抱
            if((todayData->closePrice - todayData->openPrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && oneData->openPrice > oneData->closePrice && (twoData->closePrice - twoData->openPrice) > threeData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && todayData->closePrice > oneData->openPrice && todayData->openPrice < oneData->closePrice && oneData->openPrice < twoData->closePrice && oneData->closePrice > twoData->openPrice){
                return YES;
            }
            return NO;
            break;
        case 6:
            //紅k吞噬
            if(((oneData->openPrice >= oneData->closePrice) &&
                (twoData->openPrice >= twoData->closePrice) &&
                (threeData->openPrice >= threeData->closePrice)) &&
               todayData->closePrice > todayData->openPrice &&
               todayData->closePrice >= open1_3MaxPrice &&
               todayData->openPrice <= close1_3MinPrice){
                return YES;
            }
            return NO;
            break;
        case 7:
            //多方孤島
            if(price1_20LowFlag && todayData->lowPrice > oneData->highPrice * 1.02 && twoData->lowPrice > oneData->highPrice * 1.02){
                return  YES;
            }
            return NO;
            break;
        case 8:
            //橫盤突破
            if(maxAvg1_20_5Price / minAvg1_20_5Price < [NSLocalizedStringFromTable(@"SPMULT_Day_2", @"FigureSearchFormula", nil)doubleValue] && price0_20HighFlag && (todayData->closePrice - todayData->openPrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                return  YES;
            }
            return NO;
            break;
        case 9:
            //下影探底
            if(todayData->closePrice >= todayData->openPrice){
                if(price0_20LowFlag && (todayData->openPrice - todayData->lowPrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"LONGHORNPARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                    return YES;
                }
            }else{
                if(price0_20LowFlag && (todayData->closePrice - todayData->lowPrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"LONGHORNPARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                    return YES;
                }
            }
            return NO;
            break;
        case 10:
            //多方醞釀
            if (isTW) {
                if((threeData->closePrice - threeData->openPrice) > fourData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && high3MaxPrice <= threeData->highPrice &&
                    last3MinPrice >= (threeData->openPrice + threeData->closePrice)/2){
                    return YES;
                }
            }else{
                if((threeData->closePrice - threeData->openPrice) > fourData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && high3MaxPrice <= threeData->highPrice &&
                   low3MinPrice >= (threeData->openPrice + threeData->closePrice)/2){
                    return YES;
                }
            }
            return NO;
            break;
        case 11:
            //空頭抵抗
            if (isTW) {
                if(price0_20HighFlag && todayData->closePrice < todayData->openPrice && todayData->closePrice >= oneData -> highPrice && (todayData->openPrice - todayData->closePrice) < (oneData->closePrice - oneData->openPrice) && (todayData->openPrice - todayData->closePrice) < (twoData->closePrice - twoData->openPrice)){
                    return YES;
                }
            }else{
                if(price0_20HighFlag && todayData->closePrice < todayData->openPrice && todayData->lowPrice >= oneData->highPrice && (todayData->openPrice - todayData->closePrice) < (oneData->closePrice - oneData->openPrice) && (todayData->openPrice - todayData->closePrice) < (twoData->closePrice - twoData->openPrice)){
                    return YES;
                }
            }

            return NO;
            break;
        case 12:
            //紅K脫困
            if(price2_20LowFlag && twoData->openPrice > twoData->closePrice && oneData->highPrice <= twoData->highPrice && oneData->lowPrice >= twoData->lowPrice && oneData->closePrice > oneData->openPrice && (todayData->closePrice - todayData->openPrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && todayData->closePrice >= twoData->highPrice){
                return YES;
            }
            return NO;
            break;
            
        //↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑LongSystem↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
        //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ShortSystem↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        case 13:
            //長黑棒
            if((todayData->openPrice - todayData->closePrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"LONGPARAM_Day_2", @"FigureSearchFormula", nil)doubleValue]){
                return YES;
            }
            return NO;
            break;
        case 14:
            //雙T倒反
            if((todayData->closePrice / todayData->lowPrice) < [NSLocalizedStringFromTable(@"TWOPARAM_Day", @"FigureSearchFormula", nil)doubleValue] && todayData->openPrice >= todayData->closePrice && (todayData->highPrice - todayData->openPrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && (oneData->closePrice / oneData->lowPrice) < [NSLocalizedStringFromTable(@"TWOPARAM_Day", @"FigureSearchFormula", nil)doubleValue] && oneData->openPrice >= oneData->closePrice && (oneData->highPrice - oneData->openPrice) > twoData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                return YES;
            }
            return NO;
            break;
        case 15:
            //夜星十字
            if (isTW) {
                if(oneData->closePrice >= oneData->openPrice){
                    if(price1_20HighFlag && (todayData->openPrice - todayData->closePrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && todayData->closePrice <= twoData->openPrice && todayData->highPrice <= oneData->lowPrice && ((oneData->closePrice - oneData->openPrice) / oneData->closePrice) < [NSLocalizedStringFromTable(@"MULT_Day", @"FigureSearchFormula", nil)doubleValue] && oneData->lowPrice >= twoData->highPrice && (twoData->closePrice - twoData->openPrice) > threeData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                        return YES;
                    }
                }else{
                    if(price1_20HighFlag && (todayData->openPrice - todayData->closePrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && todayData->closePrice <= twoData->openPrice && todayData->highPrice <= oneData->lowPrice && ((oneData->openPrice - oneData->closePrice) / oneData->closePrice) < [NSLocalizedStringFromTable(@"MULT_Day", @"FigureSearchFormula", nil)doubleValue] && oneData->lowPrice >= twoData->highPrice && (twoData->closePrice - twoData->openPrice) > threeData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                        return YES;
                    }
                }
            }else{
                if(oneData->closePrice >= oneData->openPrice){
                    if(price1_15HighFlag && (todayData->openPrice - todayData->closePrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day2", @"FigureSearchFormula", nil)doubleValue] && todayData->closePrice - twoData->openPrice < (twoData -> closePrice - twoData -> openPrice) * 0.5 && todayData->highPrice <= oneData->lowPrice * 1.005 && (oneData->closePrice - oneData->openPrice) < oneData -> closePrice * 0.01 &&oneData->lowPrice >= twoData->highPrice * 0.995 && (twoData->closePrice - twoData->openPrice) > threeData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                        return YES;
                    }
                }else{
                    if(price1_15HighFlag && (todayData->openPrice - todayData->closePrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day2", @"FigureSearchFormula", nil)doubleValue] && todayData->closePrice - twoData->openPrice < (twoData -> closePrice - twoData -> openPrice) * 0.5 && todayData->highPrice <= oneData->lowPrice * 1.005 && (oneData->openPrice - oneData -> closePrice) < oneData -> closePrice * 0.01 &&oneData->lowPrice >= twoData->highPrice * 0.995 && (twoData->closePrice - twoData->openPrice) > threeData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                        return YES;
                    }
                }
            }

            return NO;
            break;
        case 16:
            //黑三鴉
            if (isTW) {
                if(((todayData->openPrice > todayData->closePrice) &&
                    (oneData->openPrice > oneData->closePrice) &&
                    (twoData->openPrice > twoData->closePrice)) &&
                   ((todayData->highPrice < oneData->highPrice) &&
                    (oneData->highPrice < twoData->highPrice) &&
                    (twoData->highPrice < threeData->highPrice)) &&
                   ((todayData->lowPrice < oneData->lowPrice) &&
                    (oneData->lowPrice < twoData->lowPrice) &&
                    (twoData->lowPrice < threeData->lowPrice))){
                       return YES;
                   }
            }else{
                if(((todayData->openPrice > todayData->closePrice) &&
                    (oneData->openPrice > oneData->closePrice) &&
                    (twoData->openPrice > twoData->closePrice)) &&
                   ((todayData->highPrice < oneData->highPrice) &&
                    (oneData->highPrice < twoData->highPrice) &&
                    (twoData->highPrice < threeData->highPrice)) &&
                   ((todayData->lowPrice < oneData->lowPrice) &&
                    (oneData->lowPrice < twoData->lowPrice) &&
                    (twoData->lowPrice < threeData->lowPrice)) &&
                   ((todayData->closePrice < oneData->closePrice) &&
                    (oneData->closePrice < twoData->closePrice) &&
                    (twoData->closePrice < threeData->closePrice))){
                       return YES;
                   }
            }
            return NO;
            break;
        case 17:
            //雙龍棄守
            if((todayData->openPrice - todayData->closePrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && oneData->closePrice > oneData->openPrice && (twoData->openPrice - twoData->closePrice) > threeData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && todayData->openPrice > oneData->closePrice && todayData->closePrice < oneData->openPrice && oneData->closePrice < twoData->openPrice && oneData->openPrice > twoData->closePrice){
                return YES;
            }
            return NO;
            break;
        case 18:
            //黑K吞噬
            if(((oneData->closePrice >= oneData->openPrice) &&
                (twoData->closePrice >= twoData->openPrice) &&
                (threeData->closePrice >= threeData->openPrice)) &&
               todayData->openPrice > todayData->closePrice &&
               todayData->openPrice >= last1_3MaxPrice &&
               todayData->closePrice <= open1_3MinPrice){
                return YES;
            }
            return NO;
            break;
        case 19:
            //空方孤島
            if(price1_20HighFlag && oneData->lowPrice > todayData->highPrice * 1.02 && oneData->lowPrice > twoData->highPrice * 1.02){
                return YES;
            }
            return NO;
            break;
        case 20:
            //橫盤下殺
            if(maxAvg1_20_5Price / minAvg1_20_5Price < [NSLocalizedStringFromTable(@"SPMULT_Day", @"FigureSearchFormula", nil)doubleValue] && price0_20LowFlag && (todayData->openPrice - todayData->closePrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                return YES;
            }
            return NO;
        case 21:
            //上影摸頭
            if(todayData->closePrice >= todayData->openPrice){
                if(price0_20HighFlag && (todayData->highPrice - todayData->closePrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"LONGHORNPARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                    return YES;
                }
            }else{
                if(price0_20HighFlag && (todayData->highPrice - todayData->openPrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"LONGHORNPARAM_Day", @"FigureSearchFormula", nil)doubleValue]){
                    return YES;
                }
            }
            return NO;
            break;
        case 22:
            //空方暫歇
            if((threeData->openPrice - threeData->closePrice) > fourData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && low3MinPrice >= threeData->lowPrice && high3MaxPrice <= ((threeData->openPrice + threeData->closePrice)/2)){
                return YES;
            }
            return NO;
            break;
        case 23:
            //多頭抵抗
            if(price0_20LowFlag && todayData->closePrice > todayData->openPrice && todayData->highPrice <= oneData->lowPrice && (todayData->closePrice - todayData->openPrice) < (oneData->openPrice - oneData->closePrice) && (todayData->closePrice - todayData->openPrice) < (twoData->openPrice - twoData->closePrice)){
                return YES;
            }
            return NO;
            break;
        case 24:
            //黑K入甕
            if(price2_20HighFlag && twoData->closePrice > twoData->openPrice && oneData->highPrice <= twoData->highPrice && oneData->lowPrice >= twoData->lowPrice && oneData->openPrice > oneData->closePrice && (todayData->openPrice - todayData->closePrice) > oneData->closePrice * [NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)doubleValue] && todayData->closePrice <= twoData->lowPrice){
                return YES;
            }
            return NO;
            break;
        default:
            return NO;
    }
    //↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ShortSystem↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
}

-(NSMutableArray *)getDIYFigureSearch_ID
{
    NSMutableArray *figureSearchID = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT DISTINCT ref_figureSearch_ID FROM FigureSearchKBarValue ORDER BY ref_figureSearch_ID"];
        while ([message next]) {
            if([message intForColumn:@"ref_figureSearch_ID"]>=24 && [message intForColumn:@"ref_figureSearch_ID"] <=48){
                [figureSearchID addObject:[NSNumber numberWithInt:[message intForColumn:@"ref_figureSearch_ID"]]];
            }
        }
    }];
    return figureSearchID;
}

-(BOOL)Calculate:(NSMutableArray*)kArray FigureSearch:(NSMutableArray*)array
{
    for(int i =0; i<[kArray count]; i++){
        DIYObject * obj = [[DIYObject alloc] init];
        obj = [kArray objectAtIndex:i];
        FigureSearchData *todayData = [array objectAtIndex:obj->tNumber];
        FigureSearchData *oneData = [array objectAtIndex:obj->tNumber+1];
        //計算range
        if(obj->rangeFlag){
            double rangeMax;
            double rangeMin;
            if(obj->closeValue >0){
                rangeMin = [self getRangeMin:obj->closeValue];
                rangeMax = rangeMin + 0.02;
            }else{
                if(obj->closeValue>-0.02 && obj->closeValue<=0){
                    rangeMax = 0;
                    rangeMin = -0.02;
                }else if(obj->closeValue>-0.04 && obj->closeValue<= -0.02){
                    rangeMax = -0.02;
                    rangeMin = -0.04;
                }else if(obj->closeValue>-0.06 && obj->closeValue<= -0.04){
                    rangeMax = -0.04;
                    rangeMin = -0.06;
                }else if(obj->closeValue>-0.08 && obj->closeValue<= -0.06){
                    rangeMax = -0.06;
                    rangeMin = -0.08;
                }else if(obj->closeValue>-0.1 && obj->closeValue<= -0.08){
                    rangeMax = -0.08;
                    rangeMin = -0.1;
                }else{
                    rangeMax = -0.1;
                    rangeMin = -1.0;
                }
            }
            double closeRange = todayData->closePrice - oneData->closePrice ;
            double result = closeRange / oneData->closePrice;

            if(!(result > rangeMin && result <= rangeMax)){
                loopFlag = YES;
                return NO;
            }
        }
        
        //計算color
        if(obj->colorFlag){
            if(obj->openValue > obj->closeValue){
                if(!(todayData->openPrice > todayData->closePrice)){
                    loopFlag = YES;
                    return NO;
                }
            }else if(obj->openValue < obj->closeValue){
                if(!(todayData->openPrice < todayData->closePrice)){
                    loopFlag = YES;
                    return NO;
                }
            }else{
                if(!(todayData->openPrice == todayData->closePrice)){
                    loopFlag = YES;
                    return NO;
                }
            }
        }
        //計算upLine
        if(obj->upLineFlag){
            double upLineRate;
            double stockRate;
            double stockPrice;
            double rangeMin;
            double rangeMax;
            if(obj->openValue > obj->closeValue){
                upLineRate = obj->highValue - obj->openValue;
            }else if(obj->closeValue > obj->openValue){
                upLineRate = obj->highValue - obj->closeValue;
            }else{
                upLineRate = 0;
            }
        
            rangeMin = [self getRangeMin:upLineRate];
            rangeMax = rangeMin + 0.02;
            
            if(todayData->openPrice > todayData->closePrice){
                stockPrice = todayData->highPrice - todayData->openPrice;
                stockRate = stockPrice / todayData->openPrice;
            }else if(todayData->closePrice > todayData->openPrice){
                stockPrice = todayData->highPrice - todayData->closePrice;
                stockRate = stockPrice / todayData->closePrice;
            }else{
                stockRate = 0;
            }
            if(!(stockRate > rangeMin && stockRate < rangeMax)){
                loopFlag = YES;
                return NO;
            }
        }
        
        
        //DownLine
        if(obj->downLineFlag){
            double downLineRate;
            double stockRate;
            double stockPrice;
            double rangeMin;
            double rangeMax;
            if(obj->openValue > obj->closeValue){
                downLineRate = obj->closeValue - obj->lowValue;
            }else if(obj->closeValue > obj->openValue){
                downLineRate = obj->openValue - obj->lowValue;
            }else{
                downLineRate = 0;
            }
            
            rangeMin = [self getRangeMin:downLineRate];
            rangeMax = rangeMin + 0.02;
            
            if(todayData->openPrice > todayData->closePrice){
                stockPrice = todayData->closePrice - todayData->lowPrice;
                stockRate = stockPrice / todayData->lowPrice;
            }else if(todayData->closePrice > todayData->openPrice){
                stockPrice = todayData->openPrice - todayData->lowPrice;
                stockRate = stockPrice / todayData->lowPrice;
            }else{
                stockRate = 0;
            }
            if(!(stockRate > rangeMin && stockRate < rangeMax)){
                loopFlag = YES;
                return NO;
            }
        }
        
        //計算kLine
        if(obj->kLineFlag){
            double kRate;
            double stockRate;
            double stockPrice;
            double rangeMin;
            double rangeMax;
            if(obj->openValue > obj->closeValue){
                kRate = obj->openValue - obj->closeValue;
            }else if(obj->closeValue > obj->openValue){
                kRate = obj->closeValue - obj->openValue;
            }else{
                kRate = 0;
            }
            
            rangeMin = [self getRangeMin:kRate];
            rangeMax = rangeMin + 0.02;
            
            if(todayData->openPrice > todayData->closePrice){
                stockPrice = todayData->openPrice - todayData->closePrice;
                stockRate = stockPrice / todayData->closePrice;
            }else if(todayData->closePrice > todayData->openPrice){
                stockPrice = todayData->closePrice - todayData->openPrice;
                stockRate = stockPrice / todayData->openPrice;
            }else{
                stockRate = 0;
            }
            if(!(stockRate > rangeMin && stockRate < rangeMax)){
                loopFlag = YES;
                return NO;
            }
        }
    }
    return YES;
}

-(double)getRangeMin:(double)Value
{
    double rangeMin;
    if(Value>0 && Value<=0.02){
        rangeMin = 0.00;
    }else if(Value>0.02 && Value<= 0.04){
        rangeMin = 0.02;
    }else if(Value>0.04 && Value<= 0.06){
        rangeMin = 0.04;
    }else if(Value>0.06 && Value<= 0.08){
        rangeMin = 0.06;
    }else if(Value>0.08 && Value<= 0.1){
        rangeMin = 0.08;
    }else{
        rangeMin = 0.1;
    }
    return rangeMin;
}

-(void)ImageNumber:(int)imageNumber Symbol:(NSString *)symbol FSData:(FigureSearchData *)fsData
             Alert:(void (^)(BOOL needAlert))alert
{
    if(imageNumber ==0){
        alert(NO);
        return;
    }
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"FigureSearchData_%@.plist", symbol]];
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    tickBank = dataModal.historicTickBank;
    
    mainDict = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    UInt16 now = [[NSDate date]uint16Value];
    if([mainDict objectForKey:@"Date"]){
        if([[mainDict objectForKey:@"Date"]uint16Value] == now ){
            NSMutableArray *figureSearchArray = [mainDict objectForKey:@"FigureSearchData"];
            
            FigureSearchData *FSData1 = [figureSearchArray objectAtIndex:0];
            if(FSData1->date != fsData->date && fsData->date !=0){
                [figureSearchArray insertObject:fsData atIndex:0];
            }
            
            if(imageNumber >= 1 && imageNumber <=24){
                if([self CalculateFormula:figureSearchArray Count:imageNumber]){
                    alert(YES);
                }else{
                    alert(NO);
                }
            }else{
                NSMutableArray * totalCount = [[NSMutableArray alloc]init];
                NSMutableArray *sumtNumberArray = [[NSMutableArray alloc] init];
                FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
                FSDatabaseAgent *dbAgent = dataModel.mainDB;
                __block BOOL returnFlag;
                returnFlag = NO;
                [dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                    loopFlag = NO;
                    FMResultSet *message = [db executeQuery:@"SELECT COUNT(figureSearchKBarValue_ID) AS count FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ?", [NSNumber numberWithInt:imageNumber]];
                    while ([message next]) {
                        if([[NSNumber numberWithInt:[message intForColumn:@"COUNT"]]intValue] == 0){
                            returnFlag = YES;
                        }
                    }
                }];
                if(returnFlag){
                    alert(NO);
                    return;
                }
                [dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                    FMResultSet *message = [db executeQuery:@"SELECT COUNT(tNumber) AS count FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ?", [NSNumber numberWithInt:imageNumber]];
                    while ([message next]) {
                        [totalCount addObject:[NSNumber numberWithInt:[message intForColumn:@"COUNT"]]];
                    }
                    for(int tNumberCount = 0 ; tNumberCount<[totalCount count] ; tNumberCount++){
                        NSMutableArray * tNumberArray = [[NSMutableArray alloc] init];
                        if(loopFlag){
                            break;
                        }
                        FMResultSet *message = [db executeQuery:@"SELECT tNumber FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ?", [NSNumber numberWithInt:imageNumber]];
                        while ([message next]) {
                            [tNumberArray addObject:[NSNumber numberWithInt:[message intForColumn:@"tNumber"]]];
                        }
                        
                        for(int i = 0;i<[tNumberArray count];i++){
                            if(loopFlag){
                                break;
                            }
                            FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearchKBarValue WHERE ref_figureSearch_ID = ? and tNumber = ?", [NSNumber numberWithInt:imageNumber], [tNumberArray objectAtIndex:i]];
                            while ([message next]) {
                                DIYObject *diyObj = [[DIYObject alloc] init];
                                diyObj->tNumber = [(NSNumber *)[tNumberArray objectAtIndex:i]intValue];
                                diyObj->rangeFlag= [[message stringForColumn:@"range"]boolValue];
                                diyObj->colorFlag=[[message stringForColumn:@"color"]boolValue];
                                diyObj->upLineFlag=[[message stringForColumn:@"upLine"]boolValue];
                                diyObj->kLineFlag=[[message stringForColumn:@"kLine"]boolValue];
                                diyObj->downLineFlag=[[message stringForColumn:@"downLine"]boolValue];
                                diyObj->highValue = [message doubleForColumn:@"highValue"];
                                diyObj->lowValue = [message doubleForColumn:@"lowValue"];
                                diyObj->openValue = [message doubleForColumn:@"openValue"];
                                diyObj->closeValue = [message doubleForColumn:@"closeValue"];
                                [sumtNumberArray addObject:diyObj];
                            }
                        }
                    }
                }];
                if([self Calculate:sumtNumberArray FigureSearch:figureSearchArray]){
                    alert(YES);
                }else{
                    alert(NO);
                }
            }
        }else{
            [tickBank watchTarget:self ForEquity:symbol tickType:'D'];
            return;
        }
    }else{
        [tickBank watchTarget:self ForEquity:symbol tickType:'D'];
        return;
    }
}

@end
