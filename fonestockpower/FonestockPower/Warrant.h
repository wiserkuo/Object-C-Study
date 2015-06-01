//
//  Warrant.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/17.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WarrantQueryOut.h"
#import "WarrantQueryIn.h"
#import "WarrantBasicIn.h"
#import "WarrantBasicOut.h"
#import "WarrantHistoryIn.h"
#import "WarrantHistoryOut.h"

@class SecurityQueryParam;
@class WarrantQueryIn;

@interface WarrantObject : NSObject{
    @public
    NSString *identCodeSymbol;
    NSString *brokers;
    NSString *type;
    double price;
    int volume;
    double inOutMoney;
    double IV;
    double HV;
    NSString *warrantSymbol;
    double exercisePrice;
    double premiumRatio;
    double proportion;
    double gearingRatio;
    double light;
    NSString *method;
    int date;
    double reference;
    double BIV;
    double SIV;
    double flatSpot;
    double IV_HV;
    int circulation;
    NSString *limitType;
    double buyPrice;
    double sellPrice;
}
@end

@interface WarrantRankingObject : NSObject{
@public
    NSString *warrantName;
    NSString *warrantIdentCodeSymbol;
    NSString *type;
    double price;
    double reference;
    double transactionValue;
    int volume;
    int date;
    double HV;
    double IV;
    double exercisePrice;
    NSString *targetName;
    NSString *targetIdentCodeSymbol;
    NSString *targetSymbol;
    double targetPrice;
    double targetReference;
    double formulaPrice;
    double change;
    double targetChange;
    double formulaChange;
    double inOutMoney;
}
@end

@interface ComparativeObject : NSObject{
@public
    NSString *warrantSymbol;
    NSString *warrantIdentCodeSymbol;
    NSString *type;
    double price;
    double xValue;
    double yValue;
    CGPoint cg;
}
@end

@interface Warrant : NSObject {
    NSString *fullName;
    double targetPrice;
    id notifyObj;
}

@property (nonatomic,strong) NSMutableArray *warrantArray;
- (void)sendIdentSymbol:(NSString *)identSymbol function:(int)functionID fullName:(NSString *)name targetPrice:(double)price;
- (void)sendRanking:(int)functionID rankingType:(int)rankingNum direction:(int)dir filltI:(int)type;
-(NSMutableArray *)getWarrantData:(NSString *)formula;
-(void)setTarget:(id)obj;
-(NSMutableArray *)getBrokers;
- (void)warrantSearchDataCallBack:(WarrantQueryIn*)obj;
- (void)warrantRankingDataCallBack:(WarrantQueryIn*)obj;
- (void)warrantComparativeDataCallBack:(WarrantQueryIn*)obj;
- (void)warrantSpreadsDataCallBack:(WarrantQueryIn*)obj;
- (void)warrantTQuotedDataCallBack:(WarrantQueryIn*)obj;
-(void)warrantHistoryDataCallBack:(WarrantHistoryIn *)obj;
-(NSString *)getFullName:(NSString *)symbol;
-(NSMutableArray *)getComparativeBrokers;
-(NSMutableArray *)getXYData:(NSString *)formula xText:(NSString *)x yText:(NSString *)y;
-(NSMutableArray *)getTQuotedData:(NSString *)formula;
-(NSMutableArray *)getTQuotedBrokers;
-(void)sendWarrantBasicData:(UInt32)security_Num blockMask:(UInt16)mask;
-(void)warrantBasicDataCallBack:(WarrantBasicIn *)obj;
-(void)warrantSummaryDataCallBack:(WarrantBasicIn *)obj;
-(void)sendWarrantHistoryData:(UInt32)security_Num queryType:(UInt8)type dataCount:(UInt16)count;
-(NSString *)getBrokerName:(NSString *)brokerID;


@end


