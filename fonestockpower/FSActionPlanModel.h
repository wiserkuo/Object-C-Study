//
//  FSActionPlanModel.h
//  FonestockPower
//
//  Created by Derek on 2014/6/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataArriveProtocol.h"
#import "FSActionAlertViewController.h"

@class FSActionPlan;
typedef NS_OPTIONS(NSUInteger, FSActionPlanAlertType) {
    FSActionPlanAlertTypeNone = 0,
    FSActionPlanAlertTypeBuyStrategy = 1 << 0,
    FSActionPlanAlertTypeTarget = 1 << 1,
    FSActionPlanAlertTypeSellProfit = 1 << 2,
    FSActionPlanAlertTypeSellLoss = 1 << 3,
    FSActionPlanAlertTypeSellStrategy = 1 << 4
};

@interface FSActionPlanModel : NSObject<DataArriveProtocol>{
    NSMutableDictionary *longTermDict;
    NSMutableDictionary *shortTermDict;
    NSArray *longSymbolArray;
    NSArray *shortSymbolArray;
    NSMutableDictionary *dataDict;
    NSMutableDictionary *longDataDict;
    NSMutableDictionary *shortDataDict;
    NSMutableArray *symbolArray;
}
@property (weak, nonatomic) NSMutableDictionary *plistDataDict;
@property (nonatomic) NSMutableArray *longArray;
@property (nonatomic) NSMutableArray *shortArray;
@property (nonatomic) NSMutableArray *figureSearchArray;
@property (nonatomic) NSMutableArray *dataArray;
@property (nonatomic) NSMutableArray *actionPlanLongArray;
@property (nonatomic) NSMutableArray *actionPlanShortArray;
@property (nonatomic) NSMutableArray *positionsArray;
@property (strong,nonatomic) FSActionAlertViewController * viewController;

-(void)stopWatchIdentcodeSymbol:(NSString *)ids;
-(void)addWatchIdentcodeSymbol:(NSString *)ids;
-(void)loadActionPlanLongData;
-(void)loadActionPlanShortData;
-(void)getTargerAlertWithFSActionPlan:(FSActionPlan *)actionPlan;
-(void)getSellProfitAlertWithFSActionPlan:(FSActionPlan *)actionPlan;
-(void)getSellLossAlertWithFSActionPlan:(FSActionPlan *)actionPlan;
-(void)getBuyPatternAlertWithFSActionPlan:(FSActionPlan *)actionPlan FigureSearchData:(FigureSearchData *)figureSearchData;
-(void)getSellPatternAlertWithFSActionPlan:(FSActionPlan *)actionPlan FigureSearchData:(FigureSearchData *)figureSearchData;
@end

@interface FSActionPlan : NSObject
@property (strong, nonatomic) NSString *identCodeSymbol;
@property (unsafe_unretained, nonatomic) float buyStrategyID;
@property (strong, nonatomic) NSString *buyStrategyName;
@property (unsafe_unretained, nonatomic) float target;
@property (unsafe_unretained, nonatomic) float cost;
@property (unsafe_unretained, nonatomic) float last;
@property (unsafe_unretained, nonatomic) float buySP;
@property (unsafe_unretained, nonatomic) float buySL;
@property (unsafe_unretained, nonatomic) float buySPPercent;
@property (unsafe_unretained, nonatomic) float buySLPercent;
@property (unsafe_unretained, nonatomic) float sellSP;
@property (unsafe_unretained, nonatomic) float sellSL;
@property (unsafe_unretained, nonatomic) float sellSPPercent;
@property (unsafe_unretained, nonatomic) float sellSLPercent;
@property (unsafe_unretained, nonatomic) float sellStrategyID;
@property (strong, nonatomic) NSString *sellStrategyName;

@property (strong, nonatomic) NSString *longShortType;
@property (unsafe_unretained, nonatomic) float cng;
@property (unsafe_unretained, nonatomic) FSActionPlanAlertType buySellType;
@property (unsafe_unretained, nonatomic) BOOL cellType;
@property (unsafe_unretained, nonatomic) BOOL costType; //YES:最高買進價 NO:買進均價
@property (unsafe_unretained, nonatomic) float pattern1Num;
@property (unsafe_unretained, nonatomic) float pattern2Num;
@property (unsafe_unretained, nonatomic) float ref_Price;

@end
