//
//  FSEmergingObject.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/10/7.
//  Copyright (c) 2014年 Michael.Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StockRankIn.h"
#import "CodingUtil.h"


@protocol FSEmergingObjectCenterDelegate;

@interface FSEmergingObject : NSObject{
    
    NSRecursiveLock *datalock;
    id notifyObj;

}

-(void)stockRankCallBack:(NSMutableArray *)array;

-(void)setTarget:(id)obj;

@property (weak, nonatomic) id <FSEmergingObjectCenterDelegate> delegate;

@property SymbolFormat1 *securities;
@property UInt8 retCode;
@property UInt8 subType;
@property NSString *title;
@property UInt16 mask;
@property UInt8 resultCount;
@property UInt16 stockDividendDate;
@property UInt16 cashDividendDate;
@property UInt16 shareHolderMeetingDate;
@property NSString *directorsDate;
@property UInt16 stockDividendDate2;
@property UInt16 cashDividend;
@property UInt16 cashCapitalIncrease;

//fieldId 對照 wiki field
@property FSBValueFormat *fieldId1;
@property FSBValueFormat *fieldId2;
@property FSBValueFormat *fieldId3;
@property FSBValueFormat *fieldId4;
@property FSBValueFormat *fieldId5;
@property FSBValueFormat *fieldId6;
@property FSBValueFormat *fieldId7;
@property FSBValueFormat *fieldId8;
@property FSBValueFormat *fieldId9;
@property FSBValueFormat *fieldId10;
@property FSBValueFormat *fieldId11;
@property FSBValueFormat *fieldId12;
@property FSBValueFormat *fieldId13;
@property FSBValueFormat *fieldId14;
@property FSBValueFormat *fieldId15;
@property FSBValueFormat *fieldId16;



//column = mainTableView column
@property NSString *stockRankName;
@property NSString *column1;
@property NSString *column2;
@property NSString *column3;
@property NSString *column4;
@property NSString *column5;
@property NSString *column6;
@property NSString *column7;
@property NSString *column8;
@property NSString *column9;
@property NSString *column10;

@property float refrence;
//-(NSString *)stringWithOperatingMarginByValue:(CGFloat)value;

@property (strong, nonatomic) NSMutableArray *stockRankNameWithValue;

-(void)emergingCallBackData:(NSMutableArray *)data;

-(NSString *)stringWithMarketMover:(double)value sign:(BOOL)sign;
-(NSString *)stringWithMarketMoverPercent:(double)value sign:(BOOL)sign;
-(NSString*)convertGainsValueToString:(double)value;
-(NSString *)stringWithOperatingMarginByValue:(CGFloat)value Sign:(BOOL)sign;

-(UIColor *)compareTwoValue:(CGFloat)value1 :(CGFloat)value2;
-(NSString *)convertZeroToString:(double)value;
-(NSString *)convertQuotesToString:(double)value;
-(UIColor *)compareToZero:(CGFloat)value;
-(UIColor *)compareTwoValueBlack:(CGFloat)value1 :(CGFloat)value2;
-(NSString *)convertZeroPlusOrNot:(double)value;
-(NSString*)convertPriceValueToString:(double)value;
-(UIColor *)compareToZeroForEX:(CGFloat)value;
- (NSString*) getStringDatePlusZeroForEX:(UInt16)rdate;
-(NSString *)convertZeroToStringForAverage:(double)value;
-(NSString*)convertAverageValueToString:(double)value;
-(NSString*)convertForeighnValueToString:(double)value;
-(NSString *)convertZeroPlusOrNotForChip:(double)value;
-(NSString *)valueWithDay:(double)value;
-(NSString *)stringWithChipPercent:(double)value sign:(BOOL)sign;
-(NSString *)valueWithDirectionPercent:(double)value1 :(double)value2;
-(NSString *)valueWithDirection:(double)value1 :(double)value2;
-(NSString *)valueWithDirectionForAR:(double)value1 :(double)value2;
-(NSString *)valueWithOneDeci:(double)value;
-(NSMutableAttributedString *)valueWithDirectionAndSpace:(double)value1 :(double)value2 :(double)value3 :(double)value4;
-(NSMutableAttributedString *)valueWithDirectionAndSpacePlus:(double)value1 :(double)value2 :(double)value3 :(double)value4;
@end

@protocol FSEmergingObjectCenterDelegate <NSObject>
@required
-(void)loadDidFinishWithData:(FSEmergingObject *)rankData;
//-(void)loadDidFinishWithMarketMoverData:(FSEmergingObject *)marketMoverData;

@end

@interface FSEmergingMarketMoverObj : NSObject



@end

@interface FSEmergingObjectRegisterStock : NSObject

@property NSString *registerStockName;
@property NSString *registerStockSymbol;
@property NSString *registerStockCap;
@property NSString *registerStockSec;
@property NSString *registerStockReg_date;
@property NSString *registerStockBroker;
@property NSString *registerStockPrice;

@end

@interface FSEmergingObjectApproveStock : NSObject

@property NSString *approveStockName;
@property NSString *approveStockSymbol;
@property NSString *approveStockCap;
@property NSString *approveStockSec;
@property NSString *approveStockTo;
@property NSString *approveStockComm;
@property NSString *approveStockBoard;
@property NSString *approveStockBur;
@property NSString *approveStockList_date;
@property NSString *approveStockBroker;
@property NSString *approveStockPrice;

@end

@interface FSEmergingObjectRejectStock : NSObject

@property NSString *rejectStockName;
@property NSString *rejectStockSymbol;
@property NSString *rejectStockCap;
@property NSString *rejectStockSec;
@property NSString *rejectStockTo;
@property NSString *rejectStockRes;
@property NSString *rejectStockBroker;
@property NSString *rejectStockRej_date;

@end

@interface RecObject : NSObject

@property NSString *brokerID;
@property NSString *brokerName;
@property NSString *brokerIDWithT;

-(NSMutableArray *)getTheDB:(NSArray *)componentsArray;
-(NSArray *)parserRecBrokerNameList:(NSString *)timeNULL :(NSMutableArray *)comMutableArray;
-(NSMutableArray *)parserRecBrokerObj:(NSString *)brokerIDWithT :(NSString *)timeNULL;

+(RecObject *) sharedInstance;
@property NSString *changeBtnName;
@property NSInteger actionSheetTapIndex;

@property NSMutableArray *recBrokerName;
@property NSMutableArray *recBrokerSymbol;
@end

@interface FSEmergingQuotes : NSObject

@property NSString *QuotesCatName;
@property NSString *QuotesCatID;
-(NSMutableArray *)getQuotesCatNewObj:(NSString *)catID;
-(NSMutableArray *)getQuotesCatName;

@end



