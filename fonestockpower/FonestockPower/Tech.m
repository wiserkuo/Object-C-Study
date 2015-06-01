//
//  Tech.m
//  FonestockPower
//
//  Created by Kenny on 2014/12/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "Tech.h"
#import "TechOut.h"
#import "TechIn.h"
#import "TechViewController.h"

@interface Tech()
{
    TechViewController *obj;
    NSMutableArray *resultArray;
}

@end
@implementation Tech
-(id)init{
    self = [super init];
    if(self){
        resultArray = [[NSMutableArray alloc] init];
        _mNum1 = 5;
        _mNum2 = 10;
        _mNum3 = 20;
        _valueNum1 = 5;
        _valueNum2 = 10;
        _kNum = 9;
        _dNum = 9;
        _rsiNum1 = 5;
        _rsiNum2 = 10;
        _emaNum1 = 12;
        _emaNum2 = 26;
        _macdNum = 9;
        _obvNum = 60;
    }
    return self;
}

-(void)IdentCodeSymbol:(NSString *)identCodeSymbol dataType:(UInt8)dataType commodityType:(UInt8)commodityType startDate:(UInt16)startDate endDate:(UInt16)endDate{
    TechOut *techOut = [[TechOut alloc] initIdentCodeSymbol:identCodeSymbol dataType:dataType commodityType:commodityType startDate:startDate endDate:endDate];
    [FSDataModelProc sendData:self WithPacket:techOut];
    
}
-(void)sendIdnetCodeSymbol:(NSString *)identCodeSymbol dataType:(UInt8)dataType commodityType:(UInt8)commodityType count:(UInt16)count{
    TechOut *techOut = [[TechOut alloc] initWithIdentCodeSymbol:identCodeSymbol dataType:dataType commodityType:commodityType count:count];
    [FSDataModelProc sendData:self WithPacket:techOut];
}


-(void)techCallBackData:(TechIn *)tech
{
//向server 要資料後會送回此處
    [resultArray addObjectsFromArray:tech.dataArray];
    
    if(tech.retCode == 0){
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSMutableArray *sortedArray = [[NSMutableArray alloc]initWithArray:[resultArray sortedArrayUsingDescriptors:sortDescriptors]];
        [obj notifyTechData:sortedArray];
//        [obj performSelectorOnMainThread:@selector(notifyTechData:) withObject:sortedArray waitUntilDone:YES];
        [resultArray removeAllObjects];
    }
}

-(void)saveKData:(NSMutableArray *)dataArray Dict:(NSDictionary *)dict
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    if([dataArray count] == 0){
        return;
    }
    TechObject *firstObj = [dataArray objectAtIndex:0];
    TechObject *finalObj = [dataArray lastObject];
    
    [ dbAgent  inTransaction: ^ ( FMDatabase  * db , BOOL *rollback)  {
        [db executeUpdate:@"DELETE FROM TechKData WHERE Date >= ? AND Date <= ? AND IdentCodeSymbol = ?", [NSNumber numberWithInt:firstObj.date], [NSNumber numberWithInt:finalObj.date], [dict objectForKey:@"IdentCodeSymbol"]];
        for(int i = 0; i <[dataArray count]; i ++){
            TechObject *techObj = [dataArray objectAtIndex:i];
            [db executeUpdate:@"INSERT INTO TechKData (IdentCodeSymbol, IdentCode, Symbol, Date, Open, High, Low, Last, Volume) VALUES (?,?,?,?,?,?,?,?,?)", [dict objectForKey:@"IdentCodeSymbol"], [dict objectForKey:@"IdentCode"], [dict objectForKey:@"Symbol"], [NSNumber numberWithInt:techObj.date], [NSNumber numberWithDouble:techObj.open], [NSNumber numberWithDouble:techObj.high], [NSNumber numberWithDouble:techObj.low], [NSNumber numberWithDouble:techObj.last], [NSNumber numberWithDouble:techObj.volume]];
        }
    }];
    
    UInt16 endDate;
    //這個減1 是指最後一筆資料
    TechObject *techObj = [dataArray objectAtIndex:(dataArray.count - 1)];
    endDate = techObj.date;
    
    [ dbAgent  inTransaction: ^ ( FMDatabase  * db , BOOL *rollback)  {
        FMResultSet *message = [db executeQuery:@"SELECT COUNT(*) AS COUNT FROM TechTime WHERE IdentCodeSymbol = ?", [dict objectForKey:@"IdentCodeSymbol"]];
        int count = 0;
        while ([message next]) {
            count = [message intForColumn:@"COUNT"];
        }
        if(count == 0){
            [db executeUpdate:@"INSERT INTO TechTime (IdentCodeSymbol, Date) VALUES (?,?)", [dict objectForKey:@"IdentCodeSymbol"], [NSNumber numberWithInt:endDate]];
        }else{
            [db executeUpdate:@"UPDATE TechTime SET Date = ? WHERE IdentCodeSymbol = ?", [NSNumber numberWithInt:endDate], [dict objectForKey:@"IdentCodeSymbol"]];
        }
    }];
    
}


-(NSMutableArray *)getKData:(NSString *)identCodeSymbol
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSMutableArray *techResultArray = [[NSMutableArray alloc] init];
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM TechKData WHERE IdentCodeSymbol = ? ORDER BY Date ASC",identCodeSymbol];
        while ([message next]) {
            TechObject *techObj = [[TechObject alloc] init];
            techObj.date = [message intForColumn:@"Date"];
            techObj.open = [message doubleForColumn:@"Open"];
            techObj.high = [message doubleForColumn:@"High"];
            techObj.low = [message doubleForColumn:@"Low"];
            techObj.last = [message doubleForColumn:@"Last"];
            techObj.volume = [message intForColumn:@"Volume"];
            [techResultArray addObject:techObj];
        }
    }];
    return techResultArray;
}

- (int)getTechTime:(NSString *)identCodeSymbol
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block int time = 0;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT Date FROM TechTime WHERE IdentCodeSymbol = ?",identCodeSymbol];
        while ([message next]) {
            time = [message intForColumn:@"Date"];
        }
    }];
    return time;
}

-(BOOL)isTodayK:(NSString *)identCodeSymbol Time:(int)today
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block int time = 0;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT Date FROM TechKData WHERE IdentCodeSymbol = ? AND Date = ?",identCodeSymbol, [NSNumber numberWithInt:today]];
        while ([message next]) {
            time = [message intForColumn:@"Date"];
        }
    }];
    if(time == 0){
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)initDataModel:(NSString *)identCodeSymbol {
    //如果個股要過K線資料，會在DB存最新的資料日期，如果沒要過資料，techTime為0
    int techTime = [self getTechTime:identCodeSymbol];
    
    UInt16 startDate;
    UInt16 endDate;
    
    //要K線資料為4年，起始日為4年前，結束日為前一天(因當天的資料日期server隔天早上10點才會有)
    endDate = [[NSDate date] uint16Value];
    
    //如果techTime為最新的日期，那就不用送電文，直接去DB抓K線資料
//    if([self isTodayK:identCodeSymbol Time:endDate] ){
//        return YES;
//    }else{
        //如果沒要過K線資料，techTime為0的時候，則要四年的K線
        if(techTime == 0){
            [self sendIdnetCodeSymbol:identCodeSymbol dataType:'D' commodityType:1 count:120];
            //如果有要過K線資料，但資料日期不是最新的，只需要要DB存的最新日期到現在前一天的資料
        }else{
            startDate = [[[[NSNumber numberWithInt:techTime] uint16ToDate] dayOffset:1] uint16Value];
            [self IdentCodeSymbol:identCodeSymbol dataType:'D' commodityType:1 startDate:startDate endDate:endDate];
        }
//    }
    return NO;
}

-(void)setTarget:(NSObject *)object
{
    obj = (TechViewController *)object;
}

-(void)getMArray
{
    _m1Array = [self getMArray:_mNum1];
    _m2Array = [self getMArray:_mNum2];
    _m3Array = [self getMArray:_mNum3];
}

-(void)getVArrayType:(NSString *)type
{
    [_v1Array removeAllObjects];
    [_v2Array removeAllObjects];
    [_v3Array removeAllObjects];
    if([type isEqualToString:@"Vol"]){
        _v1Array = [self getVolArray:_valueNum1];
        _v2Array = [self getVolArray:_valueNum2];
    }else if([type isEqualToString:@"KD"]){
        _v1Array = [self getKArray:_kNum];
        _v2Array = [self getDArray:_dNum];
    }else if([type isEqualToString:@"RSI"]){
        _v1Array = [self getRSIArray:_rsiNum1];
        _v2Array = [self getRSIArray:_rsiNum2];
    }else if([type isEqualToString:@"MACD"]){
        _v1Array = [self getDIFArrayWithEma1:_emaNum1 Ema2:_emaNum2];
        _v2Array = [self getMACDArray:_macdNum Ema1:_emaNum1 Ema2:_emaNum2];
        _v3Array = [self getD_MArray:_v1Array MArray:_v2Array];
    }else if([type isEqualToString:@"OBV"]){
        _v1Array = [self getOBVArray:_obvNum];
    }
}

-(NSMutableArray *)getMArray:(int)dayNum
{
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    for (int i = 0; i <[_dataArray count]; i++){
        if(i < dayNum-1){
            [mArray addObject:(NSNumber *)kCFNumberNaN];
        }else{
            double sum = 0;
            for(int y = i ; y > i-dayNum;y--){
                TechObject *techObj = [_dataArray objectAtIndex:y];
                sum += techObj.last;
            }
            sum = sum / dayNum;
            [mArray addObject:[NSNumber numberWithDouble:sum]];
        }
    }
    return mArray;
}

-(NSMutableArray *)getVolArray:(int)dayNum
{
    NSMutableArray *vArray = [[NSMutableArray alloc] init];
    for (int i = 0; i <[_dataArray count]; i++){
        if(i < dayNum-1){
            [vArray addObject:(NSNumber *)kCFNumberNaN];
        }else{
            double sum = 0;
            for(int y = i ; y > i-dayNum;y--){
                TechObject *techObj = [_dataArray objectAtIndex:y];
                sum += techObj.volume;
            }
            sum = sum / dayNum;
            [vArray addObject:[NSNumber numberWithDouble:sum]];
        }
    }
    return vArray;
}

-(NSMutableArray *)getKArray:(int)dayNum
{
    NSMutableArray *vArray = [[NSMutableArray alloc] init];
    for (int i = 0; i <[_dataArray count]; i++){
        if(i < dayNum-1){
            [vArray addObject:(NSNumber *)kCFNumberNaN];
        }else{
            //K值 = 前一日K值 * 2/3 + RSV/3 第一天的最初始K值取50
            double initKValue;
            //第n日收盤價
            double last;
            //最近n日中的最低價
            double low = MAXFLOAT;
            //最近n日中的最高價
            double high = -MAXFLOAT;
            //RSV = (第n日收盤價 - 最近n日中的最低價) / (最近n日中的最高價 - 最近n日中的最低價) * 100
            double rsv;
            double kValue;
            if(i == dayNum-1){
                initKValue = 50;
            }else{
                initKValue = [(NSNumber *)[vArray objectAtIndex:i-1]doubleValue];
            }
            TechObject *openObj = [_dataArray objectAtIndex:i];
            last = openObj.last;
            for(int y = i; y > i-dayNum; y--){
                TechObject *techObj = [_dataArray objectAtIndex:y];
                low = MIN(techObj.low, low);
                high = MAX(techObj.high, high);
            }
            
            rsv = (last - low) / (high - low) * 100;
            kValue = initKValue * 2 / 3 + rsv / 3;
            [vArray addObject:[NSNumber numberWithDouble:kValue]];
        }
    }
    return vArray;
}

-(NSMutableArray *)getDArray:(int)dayNum
{
    //D = 前一日D值*2/3 + K/3
    //RSV = (第n日收盤價 - 最近n日中的最低價) / (最近n日中的最高價 - 最近n日中的最低價) * 100
    //最初始值D值取50。
    NSMutableArray *vArray = [[NSMutableArray alloc] init];
    for (int i = 0; i <[_dataArray count]; i++){
        if(i < dayNum-1){
            [vArray addObject:(NSNumber *)kCFNumberNaN];
        }else{
            double initDValue;
            double dValue;
            double kValue;
            if(i == dayNum-1){
                initDValue = 50;
            }else{
                initDValue = [(NSNumber *)[vArray objectAtIndex:i-1]doubleValue];
            }
            kValue = [(NSNumber *)[_v1Array objectAtIndex:i]doubleValue];
            
            dValue = initDValue * 2 / 3 + kValue/3;
            [vArray addObject:[NSNumber numberWithDouble:dValue]];
        }
    }
    return vArray;
}

-(NSMutableArray *)getRSIArray:(int)dayNum
{
    //RSI = (漲的 / (漲的 + 跌的) * 100)
    
    NSMutableArray *vArray = [[NSMutableArray alloc] init];
    //漲的
    double up = 0;
    //跌的
    double down = 0;
    double rsi = 0;
    for (int i = 0; i < [_dataArray count]; i++){
        if(i < dayNum){
            [vArray addObject:(NSNumber *)kCFNumberNaN];
        }else{
            if(i == dayNum){
                for(int y = i; y > i-dayNum; y--){
                    TechObject *techObj = [_dataArray objectAtIndex:y];
                    TechObject *previousObj = [_dataArray objectAtIndex:y-1];
                    
                    if(techObj.last > previousObj.last){
                        up += techObj.last-previousObj.last;
                    }else if(techObj.last < previousObj.last){
                        down += previousObj.last-techObj.last;
                    }
                }
                up = up / dayNum;
                down = down / dayNum;
                
                rsi = up / (up + down) * 100;
                [vArray addObject:[NSNumber numberWithDouble:rsi]];
            }else{
                TechObject *techObj = [_dataArray objectAtIndex:i];
                TechObject *previousObj = [_dataArray objectAtIndex:i-1];
                double change;
                if(techObj.last > previousObj.last){
                    change = techObj.last - previousObj.last;
                    up = up + (change - up) / dayNum;
                    down = down + (0 - down) / dayNum;
                    rsi = up / (up + down) * 100;
                }else if(techObj.last < previousObj.last){
                    change = previousObj.last - techObj.last;
                    up = up + (0 - up) / dayNum;
                    down = down + (change - down) / dayNum;
                    rsi = up / (up + down) * 100;
                }
                [vArray addObject:[NSNumber numberWithDouble:rsi]];
            }
        }
    }
    return vArray;
}

-(NSMutableArray *)getDIFArrayWithEma1:(int)ema1 Ema2:(int)ema2
{
    NSMutableArray *vArray = [[NSMutableArray alloc] init];
    NSMutableArray *ema1Array = [[NSMutableArray alloc] init];
    NSMutableArray *ema2Array = [[NSMutableArray alloc] init];
    double sum1 = 0;
    double sum2 = 0;
    double di = 0;
    int emaParam = MAX(ema1, ema2);
    
    for(int i =0; i < [_dataArray count]; i++){
        TechObject *techObj = [_dataArray objectAtIndex:i];
        di = (techObj.low + techObj.high + techObj.last * 2) / 4;
        if(i < ema1) {
            sum1 += di;
            if(i == ema1 - 1){
                [ema1Array addObject:[NSNumber numberWithDouble:sum1 / ema1]];
            }else{
                [ema1Array addObject:(NSNumber *)kCFNumberNaN];
            }
        }else{
            [ema1Array addObject:[NSNumber numberWithDouble:([(NSNumber *)[ema1Array objectAtIndex:i-1]doubleValue] * (ema1 - 2) + di * 2) / ema1]];
        }
        
        if(i < ema2) {
            sum2 += di;
            if(i == ema2 - 1){
                [ema2Array addObject:[NSNumber numberWithDouble:sum2 / ema2]];
            }else{
                [ema2Array addObject:(NSNumber *)kCFNumberNaN];
            }
        }else{
            [ema2Array addObject:[NSNumber numberWithDouble:([(NSNumber *)[ema2Array objectAtIndex:i-1]doubleValue] * (ema2 - 2) + di * 2) / ema2]];
        }
    }
    
    for( int i = 0; i < [ema2Array count]; i++){
        if(i < emaParam-1){
            [vArray addObject:(NSNumber *)kCFNumberNaN];
        }else{
            [vArray addObject:[NSNumber numberWithDouble:[(NSNumber *)[ema1Array objectAtIndex:i]doubleValue] - [(NSNumber *)[ema2Array objectAtIndex:i]doubleValue]]];
        }
    }
    return vArray;
}


-(NSMutableArray *)getMACDArray:(int)macd Ema1:(int)ema1 Ema2:(int)ema2
{
    NSMutableArray *vArray = [[NSMutableArray alloc] init];
    double sum = 0;
    int emaParam = MAX(ema1, ema2);
    int param = emaParam + macd - 2;
    for (int i = 0; i < [_dataArray count]; i++){
        if(i <= param){
            if(!isnan([(NSNumber *)[_v1Array objectAtIndex:i]doubleValue])){
                sum += [(NSNumber *)[_v1Array objectAtIndex:i]doubleValue];
            }
            if(i==param){
                [vArray addObject:[NSNumber numberWithDouble:sum / macd]];
            }else{
                [vArray addObject:(NSNumber *)kCFNumberNaN];
            }
        }else{
            if(isnan([[_v1Array objectAtIndex:i]doubleValue])){
                [vArray addObject:[NSNumber numberWithDouble:((macd - 1) + 2) / (macd + 1)]];
            }else{
                [vArray addObject:[NSNumber numberWithDouble:([(NSNumber *)[vArray objectAtIndex:i-1]doubleValue] * (macd - 1) + [(NSNumber *)[_v1Array objectAtIndex:i]doubleValue] * 2) / (macd + 1)]];
            }
        }
    }
    return vArray;
}

-(NSMutableArray *)getD_MArray:(NSMutableArray *)dArray MArray:(NSMutableArray *)mArray
{
    NSMutableArray *vArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < [dArray count]; i++){
        double resultValue = [(NSNumber *)[dArray objectAtIndex:i]doubleValue] - [(NSNumber *)[mArray objectAtIndex:i]doubleValue];
        [vArray addObject:[NSNumber numberWithDouble:resultValue]];
    }
    return vArray;
}

-(NSMutableArray *)getOBVArray:(int)dayNum
{
    NSMutableArray *obvArray = [[NSMutableArray alloc] init];
    double obv = 0;
    
    for(int i = 0; i < [_dataArray count]; i++){
        if(i==0){
            [obvArray addObject:(NSNumber *)kCFNumberNaN];
        }else{
            obv += [self getOBVValue:i];
            if(i > dayNum){
                obv -= [self getOBVValue:i - dayNum];
            }
            if(i >= dayNum){
                [obvArray addObject:[NSNumber numberWithDouble:obv]];
            }else{
                [obvArray addObject:(NSNumber *)kCFNumberNaN];
            }
        }
    }
    
    return obvArray;
}

-(double)getOBVValue:(int)index
{
    TechObject *techObj = [_dataArray objectAtIndex:index];
    TechObject *perviousObj = [_dataArray objectAtIndex:index-1];
    double obvValue = 0.0;
    if(techObj.last > perviousObj.last){
        obvValue = techObj.volume;
    }else if(techObj.last < perviousObj.last){
        obvValue = -techObj.volume;
    }else{
        obvValue = 0;
    }
    return obvValue;
}

-(void)dealloc
{
    
}

@end
