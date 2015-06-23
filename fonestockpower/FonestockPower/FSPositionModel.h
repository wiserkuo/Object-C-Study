//
//  FSPositionModel.h
//  FonestockPower
//
//  Created by Derek on 2014/7/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSPositionModel : NSObject
@property (strong, nonatomic) NSMutableArray *positionDataArray;
@property (strong, nonatomic) NSMutableArray *positionArray;
@property (strong, nonatomic) NSMutableArray *actionArray;
@property (weak, nonatomic) FSActionPlanModel *actionPlanModel;
@property (nonatomic) BOOL isOrderByRow;

@property (strong, nonatomic) NSMutableArray *diaryDataArray;
@property (strong, nonatomic) NSMutableArray *diaryArray;
@property (strong, nonatomic) NSMutableArray *avgCostDataArray;
@property (strong, nonatomic) NSMutableArray *avgCostArray;

@property (strong, nonatomic) NSMutableArray *investedArray;

@property (strong, nonatomic) NSMutableArray *tradeHistoryArray;

@property (nonatomic) float buyCount;
@property (nonatomic) float buyPrice;
@property (nonatomic) float sellCount;
@property (nonatomic) float sellPrice;
@property (nonatomic) float lastFund;
@property (nonatomic) float netWorth;
@property (nonatomic) float realized;
@property (nonatomic) float unrealized;
@property (nonatomic) float totalRiskDollar;
@property (nonatomic) float totalCost;
@property (nonatomic) float totalCash;
@property (nonatomic) float position;
@property (nonatomic) float totalGainRatio;
@property (nonatomic) int suggestCount;
@property (nonatomic) NSString *dateFormatter;

-(void)loadPositionData:(NSString *)term;
-(void)loadDiaryData:(NSString *)deal;
-(void)loadTradeHistoryData:(NSString *)term symbol:(NSString *)symbol;
-(void)deleteTradeHistoryData:(NSUInteger)count term:(NSString *)term symbol:(NSString *)symbol;
@end

@interface FSPositions : NSObject
@property (strong, nonatomic) NSString *identCodeSymbol;
@property (unsafe_unretained, nonatomic) float qty;
@property (unsafe_unretained, nonatomic) float avgCost;
@property (unsafe_unretained, nonatomic) float total;
@property (unsafe_unretained, nonatomic) float last;
@property (unsafe_unretained, nonatomic) float gainDollar;
@property (unsafe_unretained, nonatomic) float gainPercent;
@property (unsafe_unretained, nonatomic) float sl;
@property (unsafe_unretained, nonatomic) float riskDollar;
@property (unsafe_unretained, nonatomic) float totalVal;
@property (unsafe_unretained, nonatomic) float highestBuyingPrice;
@property (unsafe_unretained, nonatomic) float lowestBuyingPrice;
@property (unsafe_unretained, nonatomic) float cng;

@end

@interface FSDiary : NSObject
@property (strong, nonatomic) NSString *identCodeSymbol;
@property (unsafe_unretained, nonatomic) float qty;
@property (unsafe_unretained, nonatomic) float avgPrice;
@property (unsafe_unretained, nonatomic) float proceeds;
@property (unsafe_unretained, nonatomic) float gainDollar;
@property (unsafe_unretained, nonatomic) float gainPercent;
@property (unsafe_unretained, nonatomic) float totalCost;
@property (unsafe_unretained, nonatomic) float avgCost;
@property (unsafe_unretained, nonatomic) float costAmount;
@property (nonatomic) NSMutableDictionary *realizedValue;
@end

@interface FSTradeHistory : NSObject
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *symbol;
@property (unsafe_unretained, nonatomic)float qty;
@property (unsafe_unretained, nonatomic)float buyDealPrice;
@property (unsafe_unretained, nonatomic)float buyAmount;
@property (unsafe_unretained, nonatomic)float sellDealPrice;
@property (unsafe_unretained, nonatomic)float sellAmount;

@end
