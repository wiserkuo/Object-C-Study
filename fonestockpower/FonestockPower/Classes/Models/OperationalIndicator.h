//
//  OperationalIndicator.h
//  WirtsLeg
//
//  Created by Neil on 13/12/4.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TickDataSource.h"
#import "HistoricDataAgent.h"

@class Indicator;
@class DrawAndScrollController;


@interface OperationalIndicator : NSObject{
	NSRecursiveLock *datalock;
}

@property (nonatomic, assign) DrawAndScrollController *drawAndScrollController;

@property (nonatomic)UInt8 type;
@property (nonatomic)int VRparameter;
@property (nonatomic)int OSCparameter;
@property (nonatomic)int MTMparameter;
@property (nonatomic)UInt8 maxVolUnit;
@property (nonatomic)AnalysisPeriod range;

@property (nonatomic,strong) NSObject <HistoricTickDataSourceProtocol> *historicData;
@property (nonatomic ,strong) Indicator * indicator;
@property (nonatomic ,strong) NSMutableDictionary * dataDictionary;
@property (nonatomic ,strong) NSMutableArray * MA1Array;
@property (nonatomic ,strong) NSMutableArray * MA2Array;
@property (nonatomic ,strong) NSMutableArray * MA3Array;
@property (nonatomic ,strong) NSMutableArray * MA4Array;
@property (nonatomic ,strong) NSMutableArray * MA5Array;
@property (nonatomic ,strong) NSMutableArray * MA6Array;
@property (nonatomic ,strong) NSMutableArray * AVLArray;
@property (nonatomic ,strong) NSMutableArray * AVSArray;
@property (nonatomic ,strong) NSMutableArray * PSYArray;
@property (nonatomic ,strong) NSMutableArray * BB1Array;
@property (nonatomic ,strong) NSMutableArray * BB2Array;
@property (nonatomic ,strong) NSMutableArray * WRArray;
@property (nonatomic ,strong) NSMutableArray * VRArray;
@property (nonatomic ,strong) NSMutableArray * RSI1Array;
@property (nonatomic ,strong) NSMutableArray * RSI2Array;
@property (nonatomic ,strong) NSMutableArray * OBVArray;
@property (nonatomic ,strong) NSMutableArray * OSCArray;
@property (nonatomic ,strong) NSMutableArray * OSCMAArray;
@property (nonatomic ,strong) NSMutableArray * ARArray;
@property (nonatomic ,strong) NSMutableArray * BRArray;
@property (nonatomic ,strong) NSMutableArray * BIASArray;
@property (nonatomic ,strong) NSMutableArray * DMIplusArray;
@property (nonatomic ,strong) NSMutableArray * DMIminusArray;
@property (nonatomic ,strong) NSMutableArray * DMIadxArray;
@property (nonatomic ,strong) NSMutableArray * KDKArray;
@property (nonatomic ,strong) NSMutableArray * KDDArray;
@property (nonatomic ,strong) NSMutableArray * KDJArray;
@property (nonatomic ,strong) NSMutableArray * MTMArray;
@property (nonatomic ,strong) NSMutableArray * MTMMAArray;
@property (nonatomic ,strong) NSMutableArray * diffEMAArray;
@property (nonatomic ,strong) NSMutableArray * MACDArray;
@property (nonatomic ,strong) NSMutableArray * SARArray;
@property (nonatomic ,strong) NSMutableArray * SARBreakArray;
@property (nonatomic ,strong) NSMutableArray * TLBopenArray;
@property (nonatomic ,strong) NSMutableArray * TLBcloseArray;

-(void)prepareDataToDrawByPeriod;
-(NSMutableDictionary *)getDataByIndex:(int)index;
- (NSMutableArray *)getArrayByType:(NSString *)type;
- (double)getValueFrom:(int)index parm:(NSString *)type;
@end
