//
//  Indicator.h
//  Bullseye
//
//  Created by Ming-Zhe Wu on 2009/5/19.
//  Copyright 2009 telepaq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoricDataAgent.h"

typedef enum {
    AnalysisTypeVOL,
    AnalysisTypeRSI,
    AnalysisTypeKD,
    AnalysisTypeMACD,
    AnalysisTypeBias,
    AnalysisTypeOBV,
    AnalysisTypePSY,
    AnalysisTypeWR,
    AnalysisTypeMTM,
    AnalysisTypeOSC,
    AnalysisTypeARBR,
    AnalysisTypeDMI,
	AnalysisTypeTower,
	AnalysisTypeKDJ,
	AnalysisTypeCCI,
	AnalysisTypeVR,
	AnalysisTypeShortMA,
	AnalysisTypeMiddleMA, 		
	AnalysisTypeLongMA, 	
	AnalysisTypeBB,
    AnalysisTypeAR,
    AnalysisTypeAVL,
    AnalysisTypeAVS,
    AnalysisTypeBR,
    AnalysisTypeEMA1,
    AnalysisTypeEMA2,
    AnalysisTypeMA1,
    AnalysisTypeMA2,
    AnalysisTypeMA3,
    AnalysisTypeMA4,
    AnalysisTypeMA5,
    AnalysisTypeRSI1,
    AnalysisTypeRSI2,
    AnalysisTypeSAR,
    AnalysisTypeSD,
    AnalysisTypeGain
} AnalysisType;

typedef enum {
     BottomViewAnalysisTypeVOL,
     BottomViewAnalysisTypeRSI,
     BottomViewAnalysisTypeKDJ,
     BottomViewAnalysisTypeMACD,
     BottomViewAnalysisTypeBias,
     BottomViewAnalysisTypeOBV,
     BottomViewAnalysisTypePSY,
     BottomViewAnalysisTypeWR,
     BottomViewAnalysisTypeMTM,
     BottomViewAnalysisTypeOSC,
     BottomViewAnalysisTypeARBR,
     BottomViewAnalysisTypeDMI,
     BottomViewAnalysisTypeVR,
	 BottomViewAnalysisTypeTower,
     BottomViewAnalysisTypeGain,
} BottomViewAnalysisType;

typedef enum {
	UpperViewMAIndicator, //移動平均線
	UpperViewBBIndicator, //布林格通道
    UpperViewSARIndicator,
    UpperViewTwoLine,
} UpperViewIndicator;

typedef enum {
    UpperViewCandleChar,
    UpperViewOHLCChar,
} UpperViewMainChar;


@interface Indicator : NSObject {
	
	NSRecursiveLock *indicatorLock;
	
	int indicatorCount;	
	BottomViewAnalysisType selectedIndicator;
	int selectedIndicatorParameterCount;
	int indicatorParameter1;
	int indicatorParameter2;	
	int indicatorParameter3;	
	NSMutableDictionary *indicatorParameterDictionary;


}

@property(nonatomic) int twoStockCompare;
@property(nonatomic,readwrite) AnalysisPeriod UpperViewAnalysisPeriod;
@property(nonatomic,readwrite) int indicatorCount;
@property(nonatomic,readwrite) BottomViewAnalysisType selectedIndicator;
@property(nonatomic,readwrite) int selectedIndicatorParameterCount;
@property(nonatomic,readwrite) int indicatorParameter1;
@property(nonatomic,readwrite) int indicatorParameter2;	
@property(nonatomic,readwrite) int indicatorParameter3;
@property(nonatomic,readwrite) BottomViewAnalysisType bottomView1WeekIndicator;
@property(nonatomic,readwrite) BottomViewAnalysisType bottomView2WeekIndicator;
@property(nonatomic,readwrite) BottomViewAnalysisType bottomView1MonIndicator;
@property(nonatomic,readwrite) BottomViewAnalysisType bottomView2MonIndicator;
@property(nonatomic,readwrite) BottomViewAnalysisType bottomView1MinIndicator;
@property(nonatomic,readwrite) BottomViewAnalysisType bottomView2MinIndicator;
@property(nonatomic,readwrite) BottomViewAnalysisType bottomView1Indicator;
@property(nonatomic,readwrite) BottomViewAnalysisType bottomView2Indicator;

@property(nonatomic,readwrite) UpperViewIndicator UpperViewDayIndicator;
@property(nonatomic,readwrite) UpperViewMainChar upperViewDayMainChart;
@property(nonatomic,readwrite) UpperViewIndicator UpperViewWeekIndicator;
@property(nonatomic,readwrite) UpperViewMainChar upperViewWeekMainChart;
@property(nonatomic,readwrite) UpperViewIndicator UpperViewMonIndicator;
@property(nonatomic,readwrite) UpperViewMainChar upperViewMonMainChart;
@property(nonatomic,readwrite) UpperViewIndicator UpperViewMinIndicator;
@property(nonatomic,readwrite) UpperViewMainChar upperViewMinMainChart;

@property(nonatomic) int techViewBarWidth;

@property(nonatomic,strong) NSMutableDictionary *indicatorParameterDictionary;


- (void)createBottomViewDefaultIndicator;
- (void)writeDefaultBottomViewIndicator;
- (void)readDefaultBottomViewIndicator; //取得預設技術指標
- (void)setBottomViewDefaultIndicator:(BottomViewAnalysisType)analysisType indicatorViewType:(int)viewType PeriodType:(AnalysisPeriod)periodType; //設定預設指標 viewType = 0 上面的技術指標圖(bottonView1) ;  viewType = 1 下面的技術指標圖(bottonView2)

- (void)setUpperViewDefaultMainChart:(UpperViewMainChar)mainCharType IndicatorType:(UpperViewIndicator)indicatorType PeriodType:(AnalysisPeriod)periodType;

- (void)readIndicatorParameterTable;
- (void)writeIndicatorParameterTable;

- (void)loadIndicatorParameterByAnalysisType:(AnalysisType)analysisType;
- (NSMutableDictionary *)readIndicatorParameterByAnalysisType:(AnalysisType)analysisType;
- (void)updateIndicatorParameterByAnalysisType:(AnalysisType)analysisType;

- (void)setSelectedIndicatorByAnalysisType:(BottomViewAnalysisType)analysisType;
- (int)getIndicatorsCount;
- (BottomViewAnalysisType)getSelectIndicator;
- (void)setIndicatorParameterCountWithAnalysisType:(BottomViewAnalysisType)analysisType;

- (NSString *)indicatorNameForAnalysisType:(AnalysisType)type;
- (NSString *)indicatorNameByAnalysisType:(BottomViewAnalysisType)type;
- (NSString *)indicatorSymbolAndParameterByAnalysisType:(AnalysisType)type;

- (void)setIndicatorParameterByIndicatorParameterDictionary:(NSMutableDictionary*)dict;

@property(nonatomic,readwrite) int indicatorCountNew;
@property(nonatomic,strong) NSMutableDictionary * indicatorParameterDictionaryNew;
@property(nonatomic,strong) NSMutableArray * keyArray;
@property(nonatomic,readwrite) int dayParameter;
@property(nonatomic,readwrite) int weekParameter;
@property(nonatomic,readwrite) int monthParameter;
@property(nonatomic,readwrite) int minuteParameter;
@property(nonatomic,readwrite) int MA1parameter;
@property(nonatomic,readwrite) int MA2parameter;
@property(nonatomic,readwrite) int MA3parameter;
@property(nonatomic,readwrite) int MA4parameter;
@property(nonatomic,readwrite) int MA5parameter;
@property(nonatomic,readwrite) int MA6parameter;
@property(nonatomic,readwrite) int ARparameter;
@property(nonatomic,readwrite) int AVLparameter;
@property(nonatomic,readwrite) int AVSparameter;
@property(nonatomic,readwrite) int BBparameter;
@property(nonatomic,readwrite) int BIASparameter;
@property(nonatomic,readwrite) int BRparameter;
@property(nonatomic,readwrite) int DMIparameter;
@property(nonatomic,readwrite) int EMA1parameter;
@property(nonatomic,readwrite) int EMA2parameter;
@property(nonatomic,readwrite) int KDparameter;
@property(nonatomic,readwrite) int MACDparameter;
@property(nonatomic,readwrite) int MTMparameter;
@property(nonatomic,readwrite) int OBVparameter;
@property(nonatomic,readwrite) int OSCparameter;
@property(nonatomic,readwrite) int PSYparameter;
@property(nonatomic,readwrite) int RSI1parameter;
@property(nonatomic,readwrite) int RSI2parameter;
@property(nonatomic,readwrite) int SARparameter;
@property(nonatomic,readwrite) int SDparameter;
@property(nonatomic,readwrite) int VRparameter;
@property(nonatomic,readwrite) int WRparameter;

-(NSDictionary *)getDictionaryByKey:(NSString *)key;
-(void)changeValueByKey:(NSString *)key Type:(NSString *)type Value:(NSNumber *)value;
- (void)writeIndicatorParameterUrlTableWithDictionary:(NSMutableDictionary *)dictionary;
- (NSMutableDictionary *)readIndicatorParameterUrlTable;
-(NSString *)getTimeFromIndicatorParameterUrlTable;
- (void)readNewIndicatorParameterTable;
- (void)addKeyArrayWithArray:(NSMutableArray *)array;
-(void)setKeyArray;
- (NSMutableDictionary *)readNewIndicatorParameterByAnalysisType:(AnalysisType)analysisType;
- (NSMutableDictionary *)readNewIndicatorParameterByPeriod:(NSString *)period;
- (NSString *)newIndicatorNameAndParameterByAnalysisType:(AnalysisType)type Period:(NSString *)period;
-(int)getValueInNewIndicatorByParameter:(NSString *)parameter Period:(NSString *)period;
@end
