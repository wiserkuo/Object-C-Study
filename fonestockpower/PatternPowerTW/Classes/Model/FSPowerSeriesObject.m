//
//  FSPowerSeriesObject.m
//  FonestockPower
//
//  Created by CooperLin on 2014/11/26.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSPowerSeriesObject.h"
#import "PowerTwoPIn.h"
#import "PowerPPPIn.h"

@implementation FSPowerSeriesObject

-(void)powerSeriesCallBackData:(PowerPPPIn *)data
{
    self.storeBuyBranchIdAndValue = [[NSMutableArray alloc] init];
    self.storeSellBranchIdAndValue = [[NSMutableArray alloc] init];
    self.dateArray = [[NSMutableArray alloc] initWithObjects:[CodingUtil getStringDatePlusZero:data->startDate],[CodingUtil getStringDatePlusZero:data->endDate], nil];
    
    for(BuyStuff *bs in data->buyData){
        StoreBuyFormat *sbf = [[StoreBuyFormat alloc] init];
        sbf->brokerBranchId = [self getBrokerBranchId:bs.buyBrokerBranchId];
        sbf->value = bs.buyShare.calcValue / 1000;
        [_storeBuyBranchIdAndValue addObject:sbf];
    }
    
    for(SellStuff *ss in data->sellData){
        StoreSellFormat *ssf = [[StoreSellFormat alloc] init];
        ssf->brokerBranchId = [self getBrokerBranchId:ss.sellBrokerBranchId];
        ssf->value = ss.sellShare.calcValue / 1000;
        [_storeSellBranchIdAndValue addObject:ssf];
    }
    
    if ([self.delegate respondsToSelector:@selector(loadDidFinishWithData:)]) {
        [self.delegate loadDidFinishWithData:self];
    }
}

-(void)powerppSeriesCallBackData:(PowerTwoPIn *)data recv_complete:(NSNumber *)returnCode
{
    if(!_storeBrokerBranchData) _storeBrokerBranchData = [[NSMutableArray alloc] init];
    self.storeTempData = [[NSMutableArray alloc] init];
    self.dateArray = [[NSMutableArray alloc] initWithObjects:[CodingUtil getStringDatePlusZero:data.startDate],[CodingUtil getStringDatePlusZero:data.endDate], nil];
    
    for (BrokerBranchData *bbd in data.stockData){
        StoreBrokerBranch *sbb = [[StoreBrokerBranch alloc] init];
        sbb.brokerBranchId = [self getBrokerBranchId:bbd.brokerBranchID];
        sbb.stockHeadquarter = bbd.stockHeadquarter;
        sbb.sellOffset = bbd.sellOffset;
        [_storeTempData addObject:sbb];
    }
    
    [_storeBrokerBranchData addObjectsFromArray:_storeTempData];
    
    if([returnCode boolValue]){
        if([self.delegate respondsToSelector:@selector(loadDidFinishWithData:)]){
            [self.delegate loadDidFinishWithData:self];
        }
        [_storeBrokerBranchData removeAllObjects];
    }
}

-(int)getBrokerBranchCount
{
    NSMutableArray *bb = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT count(*) AS aa FROM brokerBranch"];
        while([rs next]){
            NSString *aa = [NSString stringWithFormat:@"%d",[rs intForColumn:@"aa"]];
            [bb addObject:aa];
        }
    }];
    return [(NSNumber *)[bb firstObject] intValue];
}

-(NSMutableArray *)getBrokerOptional
{
    NSMutableArray *ary = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT Name FROM BrokerOptional"];
        while([rs next]){
            NSString *aa = [NSString stringWithFormat:@"%@",[rs stringForColumn:@"Name"]];
            [ary addObject:aa];
        }
    }];
    return ary;
}

-(NSMutableArray *)queryBrokerOptionalIDTable:(NSString *)target
{
    NSMutableArray *ary = [[NSMutableArray alloc] init];
    NSMutableArray *resultData = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT BrokerBranchID FROM BrokerOptionalID WHERE GroupIndex = ?",target];
        while([rs next]){
            NSString *aa = [NSString stringWithFormat:@"%@",[rs stringForColumn:@"BrokerBranchID"]];
            
            [ary addObject:aa];
        }
    }];
    
    for(NSString *str in ary){
        NSString *aa = [self getBrokerBranchId:str];
        [resultData addObject:aa];
    }
    return resultData;
}

-(NSString *)getBrokerBranchId:(NSString *)theId
{
    NSString *aaa;
    NSMutableDictionary *storeStuff = [[NSMutableDictionary alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT Name,BrokerID FROM brokerBranch Where BrokerBranchID = ?",theId];
        while([rs next]){
            NSString *aa = [NSString stringWithFormat:@"%@",[rs stringForColumn:@"Name"]];
            NSString *brokerName = [NSString stringWithFormat:@"%d",[rs intForColumn:@"BrokerID"]];
            [storeStuff setValue:aa forKey:@"branch"];
            [storeStuff setValue:brokerName forKey:@"Name"];
        }
    }];
    
    if([storeStuff count] > 0){
        NSString *brokerName = [self getBrokerName:[storeStuff objectForKey:@"Name"]];
        if([brokerName isEqualToString:[storeStuff objectForKey:@"branch"]] || [[storeStuff objectForKey:@"Name"] isEqualToString:theId]){
            aaa = [NSString stringWithFormat:@"%@",brokerName];
        }else{
            aaa = [NSString stringWithFormat:@"%@%@",brokerName,[storeStuff objectForKey:@"branch"]];
        }
    }
    
    return aaa;
}

-(NSString *)getBrokerName:(NSString *)brokerID
{
    NSString *theReturnString;
    NSMutableArray *theBrokerName = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [dbAgent inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:@"SELECT Name FROM brokerName WHERE BrokerID = ?",brokerID];
        while([rs next]){
            //return [rs stringForColumn:@"Name"];
            NSString *aa = [NSString stringWithFormat:@"%@",[rs stringForColumn:@"Name"]];
            [theBrokerName addObject:aa];
        }
    }];
    if(theBrokerName.count > 0){
        theReturnString = [theBrokerName objectAtIndex:0];
    }else{
        theReturnString = @"";
    }
    return theReturnString;
}

@end
@implementation StoreBuyFormat
@end
@implementation StoreSellFormat
@end
@implementation StoreBrokerBranch
@end