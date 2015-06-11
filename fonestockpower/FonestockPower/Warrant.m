//
//  Warrant.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/17.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "Warrant.h"
#import "FSDataModelProc.h"
#import "CodingUtil.h"
#import "WarrantBasicViewController.h"
#import "ValueSummaryViewController.h"
#import "VolatilityViewController.h"
static BOOL removeFlag;


@interface Warrant()
@end




@implementation Warrant


- (id)init
{
	if(self = [super init])
	{
        self.warrantArray = [[NSMutableArray alloc]init];
	}
	return self;
}

#pragma mark 權證搜尋
-(void)sendIdentSymbol:(NSString *)identSymbol function:(int)functionID fullName:(NSString *)name targetPrice:(double)price
{
    fullName = name;
    targetPrice = price;
    [self.warrantArray removeAllObjects];
	WarrantQueryOut *wqOut = [[WarrantQueryOut alloc] initWithIdentCodeSymbol:identSymbol function:functionID];
	removeFlag = YES;

	[FSDataModelProc sendData:self WithPacket:wqOut];

}

- (void)warrantSearchDataCallBack:(WarrantQueryIn*)obj
{
    [self.warrantArray addObjectsFromArray:obj->dataArray];
    if(obj->retCode == 0){
        
        
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        FSDatabaseAgent *dbAgent = dataModel.mainDB;
        
        
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            [db executeUpdate:@"DELETE FROM Warrant"];
        }];
        
        
        for(int i =0; i<[_warrantArray count];i++){
            
            SymbolFormat1 *symbolData = [[_warrantArray objectAtIndex:i]objectAtIndex:0];
            WarrantObject *warrantData = [[WarrantObject alloc] init];
            warrantData->warrantSymbol = symbolData->fullName;
            warrantData->identCodeSymbol = [NSString stringWithFormat:@"%c%c %@", symbolData->IdentCode[0], symbolData->IdentCode[1], symbolData->symbol];
            for(int y = 0; y<[[[_warrantArray objectAtIndex:i] objectAtIndex:2] count]; y++){
                
                //成交價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 2){
                    warrantData->price = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //參考價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 3){
                    warrantData->reference = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //總量
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 4){
                    warrantData->volume = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]intValue];
                }
                //到期日
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 7){
                    warrantData->date = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]intValue];
                }
                //槓桿倍數
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 8){
                    warrantData->gearingRatio = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //歷史波動
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 9){
                    warrantData->HV = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //隱含波動
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 10){
                    warrantData->IV = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //警示燈號
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 11){
                    warrantData->light= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //發行量
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 38){
                    warrantData->circulation= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]intValue];
                }
                //券商id
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 12){
                    shortStringFormat *shortStringDate = [[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y];
                    __block NSString *name;
                    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                        FMResultSet *message = [db executeQuery:@"SELECT Name FROM brokerName WHERE BrokerID = ?", shortStringDate->dataString];
                        while ([message next]) {
                            name = [message stringForColumn:@"Name"];
                        }
                    }];
                    warrantData->brokers = name;
                }
                //溢價比
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 13){
                    warrantData->premiumRatio= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //履約價
                if([[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 14){
                    warrantData->exercisePrice= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //類型
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 15){
                    NSString *typeStr = [[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]stringValue];
                    if([(NSNumber *)[typeStr substringToIndex:1]intValue] == 1){
                        warrantData->type= @"認購";
                    }else if([(NSNumber *)[typeStr substringToIndex:1]intValue] == 2){
                        warrantData->type= @"認售";
                    }else{
                        warrantData->type= @"----";
                    }
                    if([(NSNumber *)[typeStr substringWithRange:NSMakeRange(1, 1)]intValue] == 1){
                        warrantData->method= @"美式";
                    }else if([(NSNumber *)[typeStr substringWithRange:NSMakeRange(1, 1)]intValue] == 2){
                        warrantData->method= @"歐式";
                    }else{
                        warrantData->method= @"----";
                    }
                }
                //行使比例
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 24){
                    warrantData->proportion= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //SIV
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 31){
                    warrantData->SIV= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //BIV
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 32){
                    warrantData->BIV= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
            }
            double flatSpot;
            double inOutMoney;
            if([warrantData->type isEqualToString:@"認購"]){
                //距損平點
                double point = warrantData->exercisePrice + warrantData->SIV / warrantData->proportion;
                flatSpot = (point - targetPrice) / targetPrice;
                //價內外
                inOutMoney = ((targetPrice - warrantData->exercisePrice) / warrantData->exercisePrice);
            }else{
                //距損平點
                double point = warrantData->exercisePrice - warrantData->SIV / warrantData->proportion;
                flatSpot = (targetPrice - point) / targetPrice;
                //價內外
                inOutMoney = (warrantData->exercisePrice - targetPrice) / warrantData->exercisePrice;
            }
            warrantData->flatSpot = flatSpot;
            warrantData->inOutMoney = inOutMoney;
            
            //IV-HV
            warrantData->IV_HV = warrantData->IV - warrantData->HV;

        
            [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                [db executeUpdate:@"INSERT INTO Warrant(TargetSymbol, Brokers, Type, Price, Volume, InOutMoney, IV, HV, WarrantSymbol, ExercisePrice, PremiumRatio, Proportion, GearingRatio, Light, Method, Date, Reference, FlatSpot, IV_HV, IdentCodeSymbol, Circulation) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",fullName, warrantData->brokers, warrantData->type, [NSNumber numberWithDouble:warrantData->price], [NSNumber numberWithInt:warrantData->volume], [NSNumber numberWithDouble:warrantData->inOutMoney], [NSNumber numberWithDouble:warrantData->IV], [NSNumber numberWithDouble:warrantData->HV], warrantData->warrantSymbol, [NSNumber numberWithDouble:warrantData->exercisePrice], [NSNumber numberWithDouble:warrantData->premiumRatio], [NSNumber numberWithDouble:warrantData->proportion], [NSNumber numberWithDouble:warrantData->gearingRatio], [NSNumber numberWithDouble:warrantData->light], warrantData->method, [NSNumber numberWithUnsignedInt:warrantData->date], [NSNumber numberWithDouble:warrantData->reference], [NSNumber numberWithDouble:warrantData->flatSpot], [NSNumber numberWithDouble:warrantData->IV_HV], warrantData->identCodeSymbol, [NSNumber numberWithInt:warrantData->circulation]];
                 }];
        }
        [notifyObj performSelectorOnMainThread:@selector(notifyData) withObject:nil waitUntilDone:NO];
	}
}

-(NSMutableArray *)getWarrantData:(NSString *)formula
{
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *test = [NSString stringWithFormat:@"SELECT * FROM Warrant %@ ORDER BY WarrantSymbol", formula];
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:test];
        while ([message next]) {
            WarrantObject *warrantData = [[WarrantObject alloc] init];
            warrantData->identCodeSymbol = [message stringForColumn:@"IdentCodeSymbol"];
            warrantData->brokers = [message stringForColumn:@"Brokers"];
            warrantData->type = [message stringForColumn:@"Type"];
            warrantData->price = [message doubleForColumn:@"Price"];
            warrantData->volume = [message intForColumn:@"Volume"];
            warrantData->inOutMoney = [message doubleForColumn:@"InOutMoney"];
            warrantData->IV = [message doubleForColumn:@"IV"];
            warrantData->HV = [message doubleForColumn:@"HV"];
            warrantData->warrantSymbol = [message stringForColumn:@"WarrantSymbol"];
            warrantData->exercisePrice = [message doubleForColumn:@"ExercisePrice"];
            warrantData->premiumRatio = [message doubleForColumn:@"PremiumRatio"];
            warrantData->proportion = [message doubleForColumn:@"Proportion"];
            warrantData->gearingRatio = [message doubleForColumn:@"GearingRatio"];
            warrantData->light = [message doubleForColumn:@"Light"];
            warrantData->method = [message stringForColumn:@"Method"];
            warrantData->date = [message intForColumn:@"Date"];
            warrantData->reference = [message doubleForColumn:@"Reference"];
            warrantData->flatSpot = [message doubleForColumn:@"FlatSpot"];
            warrantData->circulation = [message intForColumn:@"Circulation"];
            [dataArray addObject:warrantData];
        }
    }];
    return dataArray;
}

-(NSMutableArray *)getBrokers
{
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    [dataArray addObject:@"全部"];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT DISTINCT Brokers FROM Warrant"];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"Brokers"]];
        }
    }];
    return dataArray;
}

#pragma mark 權證排行

- (void)sendRanking:(int)functionID rankingType:(int)rankingNum direction:(int)dir filltI:(int)type
{
    [self.warrantArray removeAllObjects];
    WarrantQueryOut *wqOut = [[WarrantQueryOut alloc] initWithFunction:7 rankingType:rankingNum direction:dir filltI:type];
    [FSDataModelProc sendData:self WithPacket:wqOut];
}

- (void)warrantRankingDataCallBack:(WarrantQueryIn*)obj
{
    [self.warrantArray addObjectsFromArray:obj->dataArray];
    if(obj->retCode == 0){
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        for(int i =0; i<[_warrantArray count];i++){
            SymbolFormat1 *symbolData = [[_warrantArray objectAtIndex:i]objectAtIndex:0];
            WarrantRankingObject *rankingData = [[WarrantRankingObject alloc] init];
            rankingData->warrantName = symbolData->fullName;
            rankingData->warrantIdentCodeSymbol =[NSString stringWithFormat:@"%c%c %@",symbolData->IdentCode[0], symbolData->IdentCode[1], symbolData->symbol];
            for(int y = 0; y<[[[_warrantArray objectAtIndex:i] objectAtIndex:2] count]; y++){
                //成交價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 2){
                    rankingData->price = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //參考價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 3){
                    rankingData->reference = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //總量
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 4){
                    rankingData->volume = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]intValue];
                }
                //到期日
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 7){
                    rankingData->date = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]intValue];
                }
                //歷史波動
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 9){
                    rankingData->HV = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //隱含波動
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 10){
                    rankingData->IV = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //履約價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 14){
                    rankingData->exercisePrice= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //類型
                if([[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 15){
                    NSString *typeStr = [[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]stringValue];
                    if([(NSNumber *)[typeStr substringToIndex:1]intValue] == 1){
                        rankingData->type= @"認購";
                    }else if([(NSNumber *)[typeStr substringToIndex:1]intValue] == 2){
                        rankingData->type= @"認售";
                    }else{
                        rankingData->type= @"----";
                    }
                }
                //成交值
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 16){
                    rankingData->transactionValue= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //標的名稱
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 40){
                    shortStringFormat *stringData = [[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y];
                    rankingData->targetName= stringData->dataString;
                }
                //標的代碼
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 39){
                    shortStringFormat *stringData = [[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y];
                    rankingData->targetIdentCodeSymbol= [NSString stringWithFormat:@"%@ %@", [stringData->dataString substringToIndex:2], [stringData->dataString substringFromIndex:3]];
                    rankingData->targetSymbol = [stringData->dataString substringFromIndex:3];
                }
                //標的價格
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 41){
                    rankingData->targetPrice= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //標的參考價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 42){
                    rankingData->targetReference= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //理論價格
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 47){
                    rankingData->formulaPrice= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
            }
            
            //漲幅
            rankingData->change = (rankingData->price - rankingData->reference)/rankingData->reference;
            //標的漲幅
            rankingData->targetChange = (rankingData->targetPrice - rankingData->targetReference)/rankingData->targetReference;
            //理論價差
            rankingData->formulaChange = (rankingData->price - rankingData->formulaPrice)/rankingData->formulaPrice;
            //價內外
            if([rankingData->type isEqualToString:@"認購"]){
                rankingData->inOutMoney = (rankingData->targetPrice - rankingData->exercisePrice) / rankingData->exercisePrice;
            }else{
                rankingData->inOutMoney = (rankingData->exercisePrice - rankingData->targetPrice ) / rankingData->exercisePrice;
            }
            [dataArray addObject:rankingData];
        }
        [notifyObj performSelectorOnMainThread:@selector(notifyData:) withObject:dataArray waitUntilDone:NO];
	}
}

#pragma mark 對比分析
- (void)warrantComparativeDataCallBack:(WarrantQueryIn*)obj
{
    [self.warrantArray addObjectsFromArray:obj->dataArray];
    if(obj->retCode == 0){
        
        NSDate *todayDate = [[NSDate alloc] init];
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        FSDatabaseAgent *dbAgent = dataModel.mainDB;
        
        
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            [db executeUpdate:@"DELETE FROM ComparativeAnalysis"];
        }];
        
        for(int i =0; i<[_warrantArray count];i++){
            
            SymbolFormat1 *symbolData = [[_warrantArray objectAtIndex:i]objectAtIndex:0];
            WarrantObject *warrantData = [[WarrantObject alloc] init];
            warrantData->warrantSymbol = symbolData->fullName;
            warrantData->identCodeSymbol = [NSString stringWithFormat:@"%c%c %@", symbolData->IdentCode[0], symbolData->IdentCode[1], symbolData->symbol];
            for(int y = 0; y<[[[_warrantArray objectAtIndex:i] objectAtIndex:2] count]; y++){
                
                
                //成交價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 2){
                    warrantData->price = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //參考價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 3){
                    warrantData->reference = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //到期日
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 7){
                    NSDate *endDate = [[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]uint16ToDate];
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *component = [gregorian components:NSCalendarUnitDay fromDate:todayDate toDate:endDate options:0];
                    int dayCount = (int)[component day];
                    warrantData->date = dayCount+1;
                }
                //槓桿倍數
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 8){
                    warrantData->gearingRatio = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //隱含波動
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 10){
                    warrantData->IV = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue]*100;
                }
                //券商id
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 12){
                    shortStringFormat *shortStringDate = [[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y];
                    __block NSString *name;
                    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                        FMResultSet *message = [db executeQuery:@"SELECT Name FROM brokerName WHERE BrokerID = ?", shortStringDate->dataString];
                        while ([message next]) {
                            name = [message stringForColumn:@"Name"];
                        }
                    }];
                    warrantData->brokers = name;
                }
                //履約價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 14){
                    warrantData->exercisePrice= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //類型
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 15){
                    NSString *typeStr = [[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]stringValue];
                    if([(NSNumber *)[typeStr substringToIndex:1]intValue] == 1){
                        warrantData->type= @"認購";
                    }else if([(NSNumber *)[typeStr substringToIndex:1]intValue] == 2){
                        warrantData->type= @"認售";
                    }else{
                        warrantData->type= @"----";
                    }
                }
                //行使比例
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 24){
                    warrantData->proportion= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //SIV
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 31){
                    warrantData->SIV= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
            }
            
            double flatSpot;
            double inOutMoney;
            if([warrantData->type isEqualToString:@"認購"]){
                //距損平點
                double point = warrantData->exercisePrice + warrantData->SIV / warrantData->proportion;
                flatSpot = (point - targetPrice) / targetPrice *100;
                //價內外
                inOutMoney = ((targetPrice - warrantData->exercisePrice) / warrantData->exercisePrice)*100;
            }else{
                //距損平點
                double point = warrantData->exercisePrice - warrantData->SIV / warrantData->proportion;
                flatSpot = (targetPrice - point) / targetPrice *100;
                //價內外
                inOutMoney = ((warrantData->exercisePrice - targetPrice) / warrantData->exercisePrice)*100;
            }
            warrantData->flatSpot = flatSpot;
            warrantData->inOutMoney = inOutMoney;
            
            
            [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                [db executeUpdate:@"INSERT INTO ComparativeAnalysis(TargetSymbol, Brokers, Type, Price, InOutMoney, IV, WarrantSymbol, ExercisePrice, GearingRatio, Date, Reference, FlatSpot, IdentCodeSymbol) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)",fullName, warrantData->brokers, warrantData->type, [NSNumber numberWithDouble:warrantData->price], [NSNumber numberWithDouble:warrantData->inOutMoney], [NSNumber numberWithDouble:warrantData->IV], warrantData->warrantSymbol, [NSNumber numberWithDouble:warrantData->exercisePrice], [NSNumber numberWithDouble:warrantData->gearingRatio], [NSNumber numberWithUnsignedInt:warrantData->date], [NSNumber numberWithDouble:warrantData->reference], [NSNumber numberWithDouble:warrantData->flatSpot], warrantData->identCodeSymbol];
            }];
        }
        [notifyObj performSelectorOnMainThread:@selector(notifyData) withObject:nil waitUntilDone:NO];
	}
}

-(NSMutableArray *)getComparativeBrokers
{
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    [dataArray addObject:@"全部"];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT DISTINCT Brokers FROM ComparativeAnalysis"];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"Brokers"]];
        }
    }];
    return dataArray;
}


-(NSMutableArray *)getXYData:(NSString *)formula xText:(NSString *)x yText:(NSString *)y
{
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *test = [NSString stringWithFormat:@"SELECT * FROM ComparativeAnalysis %@", formula];
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:test];
        while ([message next]) {
            ComparativeObject *comparativeData = [[ComparativeObject alloc] init];
            comparativeData->warrantSymbol = [message stringForColumn:@"WarrantSymbol"];
            comparativeData->warrantIdentCodeSymbol = [message stringForColumn:@"IdentCodeSymbol"];
            comparativeData->type = [message stringForColumn:@"Type"];
            comparativeData->xValue = [message doubleForColumn:[NSString stringWithFormat:@"%@",x]];
            comparativeData->yValue = [message doubleForColumn:[NSString stringWithFormat:@"%@",y]];
            [dataArray addObject:comparativeData];
        }
    }];
    return dataArray;

}

#pragma mark 模擬試算
- (void)warrantSpreadsDataCallBack:(WarrantQueryIn*)obj
{
    [self.warrantArray addObjectsFromArray:obj->dataArray];
    if(obj->retCode == 0){
        
        NSDate *todayDate = [[NSDate alloc] init];
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        FSDatabaseAgent *dbAgent = dataModel.mainDB;
        
        
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            [db executeUpdate:@"DELETE FROM ComparativeAnalysis"];
        }];
        
        for(int i =0; i<[_warrantArray count];i++){
            
            SymbolFormat1 *symbolData = [[_warrantArray objectAtIndex:i]objectAtIndex:0];
            WarrantObject *warrantData = [[WarrantObject alloc] init];
            warrantData->warrantSymbol = symbolData->fullName;
            warrantData->identCodeSymbol = [NSString stringWithFormat:@"%c%c %@", symbolData->IdentCode[0], symbolData->IdentCode[1], symbolData->symbol];
            for(int y = 0; y<[[[_warrantArray objectAtIndex:i] objectAtIndex:2] count]; y++){
                
                
                //成交價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 2){
                    warrantData->price = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //參考價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 3){
                    warrantData->reference = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //到期日
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 7){
                    NSDate *endDate = [[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]uint16ToDate];
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *component = [gregorian components:NSCalendarUnitDay fromDate:todayDate toDate:endDate options:0];
                    int dayCount = (int)[component day];
                    warrantData->date = dayCount+1;
                }
                //槓桿倍數
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 8){
                    warrantData->gearingRatio = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //隱含波動
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 10){
                    warrantData->IV = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue]*100;
                }
                //歷史波動
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 9){
                    warrantData->HV = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //券商id
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 12){
                    shortStringFormat *shortStringDate = [[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y];
                    __block NSString *name;
                    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                        FMResultSet *message = [db executeQuery:@"SELECT Name FROM brokerName WHERE BrokerID = ?", shortStringDate->dataString];
                        while ([message next]) {
                            name = [message stringForColumn:@"Name"];
                        }
                    }];
                    warrantData->brokers = name;
                }
                //履約價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 14){
                    warrantData->exercisePrice= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //類型
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 15){
                    NSString *typeStr = [[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]stringValue];
                    if([(NSNumber *)[typeStr substringToIndex:1]intValue] == 1){
                        warrantData->type= @"認購";
                    }else if([(NSNumber *)[typeStr substringToIndex:1]intValue] == 2){
                        warrantData->type= @"認售";
                    }else{
                        warrantData->type= @"----";
                    }
                    if([(NSNumber *)[typeStr substringWithRange:NSMakeRange(1, 1)]intValue] == 1){
                        warrantData->method= @"美式";
                    }else if([(NSNumber *)[typeStr substringWithRange:NSMakeRange(1, 1)]intValue] == 2){
                        warrantData->method= @"歐式";
                    }else{
                        warrantData->method= @"----";
                    }
                    if([(NSNumber *)[typeStr substringWithRange:NSMakeRange(2, 1)]intValue] == 1){
                        warrantData->limitType= @"一般型";
                    }else if([(NSNumber *)[typeStr substringWithRange:NSMakeRange(2, 1)]intValue] == 2){
                        warrantData->limitType= @"上下限型";
                    }else{
                        warrantData->limitType= @"----";
                    }
                }
                //SIV
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 31){
                    warrantData->SIV= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
            }
            
            double flatSpot;
            double inOutMoney;
            if([warrantData->type isEqualToString:@"認購"]){
                //距損平點
                double point = warrantData->exercisePrice + warrantData->SIV / warrantData->proportion;
                flatSpot = (point - targetPrice) / targetPrice *100;
                //價內外
                inOutMoney = ((targetPrice - warrantData->exercisePrice) / warrantData->exercisePrice)*100;
            }else{
                //距損平點
                double point = warrantData->exercisePrice - warrantData->SIV / warrantData->proportion;
                flatSpot = (targetPrice - point) / targetPrice *100;
                //價內外
                inOutMoney = ((warrantData->exercisePrice - targetPrice) / warrantData->exercisePrice)*100;
            }
            warrantData->flatSpot = flatSpot;
            warrantData->inOutMoney = inOutMoney;
            
            
            [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                [db executeUpdate:@"INSERT INTO ComparativeAnalysis(TargetSymbol, Brokers, Type, Price, InOutMoney, IV, WarrantSymbol, ExercisePrice, GearingRatio, Date, Reference, FlatSpot, IdentCodeSymbol) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)",fullName, warrantData->brokers, warrantData->type, [NSNumber numberWithDouble:warrantData->price], [NSNumber numberWithDouble:warrantData->inOutMoney], [NSNumber numberWithDouble:warrantData->IV], warrantData->warrantSymbol, [NSNumber numberWithDouble:warrantData->exercisePrice], [NSNumber numberWithDouble:warrantData->gearingRatio], [NSNumber numberWithUnsignedInt:warrantData->date], [NSNumber numberWithDouble:warrantData->reference], [NSNumber numberWithDouble:warrantData->flatSpot], warrantData->identCodeSymbol];
            }];
        }
        [notifyObj performSelectorOnMainThread:@selector(notifyData) withObject:nil waitUntilDone:NO];
	}
}

#pragma mark T字報價
- (void)warrantTQuotedDataCallBack:(WarrantQueryIn*)obj
{
    [self.warrantArray addObjectsFromArray:obj->dataArray];
    if(obj->retCode == 0){
        
        NSDate *todayDate = [[NSDate alloc] init];
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        FSDatabaseAgent *dbAgent = dataModel.mainDB;
        
        
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            [db executeUpdate:@"DELETE FROM TQuotedPrice"];
        }];
        
        for(int i =0; i<[_warrantArray count];i++){
            
            SymbolFormat1 *symbolData = [[_warrantArray objectAtIndex:i]objectAtIndex:0];
            WarrantObject *warrantData = [[WarrantObject alloc] init];
            warrantData->warrantSymbol = symbolData->fullName;
            warrantData->identCodeSymbol = [NSString stringWithFormat:@"%c%c %@", symbolData->IdentCode[0], symbolData->IdentCode[1], symbolData->symbol];
            for(int y = 0; y<[[[_warrantArray objectAtIndex:i] objectAtIndex:2] count]; y++){
                //買價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 5){
                    warrantData->buyPrice = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //賣價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 6){
                    warrantData->sellPrice = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                
                //成交價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 2){
                    warrantData->price = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //參考價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 3){
                    warrantData->reference = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //券商id
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 12){
                    shortStringFormat *shortStringDate = [[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y];
                    __block NSString *name;
                    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                        FMResultSet *message = [db executeQuery:@"SELECT Name FROM brokerName WHERE BrokerID = ?", shortStringDate->dataString];
                        while ([message next]) {
                            name = [message stringForColumn:@"Name"];
                        }
                    }];
                    warrantData->brokers = name;
                }
                //到期日
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 7){
                    NSDate *endDate = [[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]uint16ToDate];
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *component = [gregorian components:NSCalendarUnitDay fromDate:todayDate toDate:endDate options:0];
                    int dayCount = (int)[component day];
                    warrantData->date = dayCount+1;
                }
                //隱含波動
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 10){
                    warrantData->IV = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue]*100;
                }
                //歷史波動
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 9){
                    warrantData->HV = [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //券商id
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 12){
                    shortStringFormat *shortStringDate = [[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y];
                    __block NSString *name;
                    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                        FMResultSet *message = [db executeQuery:@"SELECT Name FROM brokerName WHERE BrokerID = ?", shortStringDate->dataString];
                        while ([message next]) {
                            name = [message stringForColumn:@"Name"];
                        }
                    }];
                    warrantData->brokers = name;
                }
                //履約價
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 14){
                    warrantData->exercisePrice= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //類型
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 15){
                    NSString *typeStr = [[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]stringValue];
                    if([(NSNumber *)[typeStr substringToIndex:1]intValue] == 1){
                        warrantData->type= @"認購";
                    }else if([(NSNumber *)[typeStr substringToIndex:1]intValue] == 2){
                        warrantData->type= @"認售";
                    }else{
                        warrantData->type= @"----";
                    }
                }
                //SIV
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 31){
                    warrantData->SIV= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
                //行使比例
                if([(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:2]objectAtIndex:y]intValue] == 24){
                    warrantData->proportion= [(NSNumber *)[[[_warrantArray objectAtIndex:i]objectAtIndex:3]objectAtIndex:y]doubleValue];
                }
            }
            
            double flatSpot;
            if([warrantData->type isEqualToString:@"認購"]){
                //距損平點
                double point = warrantData->exercisePrice + warrantData->SIV / warrantData->proportion;
                flatSpot = (point - targetPrice) / targetPrice *100;
            }else{
                //距損平點
                double point = warrantData->exercisePrice - warrantData->SIV / warrantData->proportion;
                flatSpot = (targetPrice - point) / targetPrice *100;
            }
            warrantData->flatSpot = flatSpot;
            
            
            [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
                [db executeUpdate:@"INSERT INTO TQuotedPrice(TargetSymbol, Brokers, Type, Price, BuyPrice, SellPrice, IV, WarrantSymbol, ExercisePrice, Date, FlatSpot, IdentCodeSymbol) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)",fullName, warrantData->brokers, warrantData->type, [NSNumber numberWithDouble:warrantData->price], [NSNumber numberWithDouble:warrantData->buyPrice], [NSNumber numberWithDouble:warrantData->sellPrice], [NSNumber numberWithDouble:warrantData->IV], warrantData->warrantSymbol, [NSNumber numberWithDouble:warrantData->exercisePrice], [NSNumber numberWithUnsignedInt:warrantData->date], [NSNumber numberWithDouble:warrantData->flatSpot], warrantData->identCodeSymbol];
            }];
        }
        [notifyObj performSelectorOnMainThread:@selector(notifyData) withObject:nil waitUntilDone:NO];
	}
}

-(NSMutableArray *)getTQuotedData:(NSString *)formula
{
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *request = [NSString stringWithFormat:@"SELECT * FROM TQuotedPrice %@ Order by ExercisePrice", formula];
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:request];
        while ([message next]) {
            WarrantObject *warrantData = [[WarrantObject alloc] init];
            warrantData->type = [message stringForColumn:@"Type"];
            warrantData->price = [message doubleForColumn:@"Price"];
            warrantData->buyPrice = [message doubleForColumn:@"BuyPrice"];
            warrantData->sellPrice = [message doubleForColumn:@"SellPrice"];
            warrantData->IV = [message doubleForColumn:@"IV"];
            warrantData->warrantSymbol = [message stringForColumn:@"WarrantSymbol"];
            warrantData->exercisePrice = [message doubleForColumn:@"ExercisePrice"];
            warrantData->date = [message intForColumn:@"Date"];
            warrantData->flatSpot = [message doubleForColumn:@"FlatSpot"];
            [dataArray addObject:warrantData];
        }
    }];
    return dataArray;
}

-(NSMutableArray *)getTQuotedBrokers
{
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    [dataArray addObject:@"全部"];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT DISTINCT Brokers FROM TQuotedPrice"];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"Brokers"]];
        }
    }];
    return dataArray;
}


#pragma mark 權證搜尋基本
-(void)sendWarrantBasicData:(UInt32)security_Num blockMask:(UInt16)mask
{
    WarrantBasicOut *wbOut = [[WarrantBasicOut alloc] initWithSecuity_num:security_Num blockMask:mask];
    [FSDataModelProc sendData:self WithPacket:wbOut];
}

-(void)warrantBasicDataCallBack:(WarrantBasicIn *)obj;
{
    if([notifyObj isKindOfClass:[WarrantBasicViewController class]]){
        WarrantBasicViewController *warrantBasic = (WarrantBasicViewController *)notifyObj;
        [warrantBasic notifyBasicData:obj.dict];
    }
}

-(void)warrantSummaryDataCallBack:(WarrantBasicIn *)obj
{
    if([notifyObj isKindOfClass:[ValueSummaryViewController class]]){
        ValueSummaryViewController *valueSummaryViewController = (ValueSummaryViewController *)notifyObj;
        [valueSummaryViewController notifySummaryData:obj.dict];
    }
}

-(void)sendWarrantHistoryData:(UInt32)security_Num queryType:(UInt8)type dataCount:(UInt16)count
{
    WarrantHistoryOut *whOut = [[WarrantHistoryOut alloc] initWithSecuity_num:security_Num queryType:type dataCount:count];
    [FSDataModelProc sendData:self WithPacket:whOut];
}

#pragma mark 權證搜尋價值分析

-(void)warrantHistoryDataCallBack:(WarrantHistoryIn *)obj
{
    if([notifyObj isKindOfClass:[VolatilityViewController class]]){
        VolatilityViewController *volatilityViewController = (VolatilityViewController *)notifyObj;
        [volatilityViewController notifyHistoryData:obj.dataArray];
    }
}


#pragma mark 其他
-(void)setTarget:(id)obj
{
    notifyObj = obj;
}

-(NSString *)getBrokerName:(NSString *)brokerID
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block NSString *brokerName;
    NSString *request = [NSString stringWithFormat:@"SELECT Name FROM brokerName Where BrokerID = %d", [brokerID intValue]];
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:request];
        while ([message next]) {
            brokerName = [message stringForColumn:@"Name"];
        }
    }];
    return brokerName;
}

-(NSString *)getFullName:(NSString *)symbol
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block NSString *name;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM Cat_FullName WHERE Symbol = ?", symbol];
        while ([message next]) {
            name = [message stringForColumn:@"FullName"];
        }
    }];
    
    return name;
}

@end


@implementation WarrantObject
@end
@implementation WarrantRankingObject
@end
@implementation ComparativeObject
@end
             
