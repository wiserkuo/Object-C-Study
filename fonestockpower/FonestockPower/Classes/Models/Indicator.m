//
//  Indicator.m
//  Bullseye
//
//  Created by Ming-Zhe Wu on 2009/5/19.
//  Copyright 2009 telepaq. All rights reserved.
//

#import "Indicator.h"
#import "IndicatorParameterUrlCenter.h"


@implementation Indicator

@synthesize indicatorCount;
@synthesize selectedIndicator;
@synthesize selectedIndicatorParameterCount;
@synthesize indicatorParameter1,indicatorParameter2,indicatorParameter3;
@synthesize indicatorParameterDictionary;

- (id)init{
	if(self = [super init])
	{

		indicatorLock = [[NSRecursiveLock alloc] init];	
		indicatorParameter1 = -1;
		indicatorParameter2 = -1;
		indicatorParameter3 = -1;	
		indicatorCount = 20;
        _indicatorCountNew = 27;
        //[self addKeyArray];
		[self readDefaultBottomViewIndicator]; //讀取預設 bottom view 的 技術指標 (bottomView1 & bottomView2)  # bottonView 因為 bottomView
		[self readIndicatorParameterTable]; //目前 table0用於歷史線圖 table1用於Alarm(unuse)
        [self readNewIndicatorParameterTable];
	}
	return self;
}

- (void)createBottomViewDefaultIndicator
{
	
	[indicatorLock lock];
    
    _UpperViewAnalysisPeriod = AnalysisPeriodDay;
    _twoStockCompare = 0;
	
	_bottomView1Indicator = BottomViewAnalysisTypeVOL;
	_bottomView2Indicator = BottomViewAnalysisTypeRSI;
    
    _bottomView1WeekIndicator = BottomViewAnalysisTypeVOL;
	_bottomView2WeekIndicator = BottomViewAnalysisTypeRSI;
    
    _bottomView1MonIndicator = BottomViewAnalysisTypeVOL;
	_bottomView2MonIndicator = BottomViewAnalysisTypeRSI;
    
    _bottomView1MinIndicator = BottomViewAnalysisTypeVOL;
	_bottomView2MinIndicator = BottomViewAnalysisTypeRSI;
    
    _upperViewDayMainChart = UpperViewCandleChar;
    _UpperViewDayIndicator = UpperViewMAIndicator;
    
    _upperViewWeekMainChart = UpperViewCandleChar;
    _UpperViewWeekIndicator = UpperViewMAIndicator;
    
    _upperViewMonMainChart = UpperViewCandleChar;
    _UpperViewMonIndicator = UpperViewMAIndicator;
    
    _upperViewMinMainChart = UpperViewCandleChar;
    _UpperViewMinIndicator = UpperViewMAIndicator;
    
    _techViewBarWidth = 3;
    
	
	[self writeDefaultBottomViewIndicator];
	
	[indicatorLock unlock];		

}

- (void)writeDefaultBottomViewIndicator
{
	
	[indicatorLock lock];
	
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *fileName = @"TechViewDefaultIndicator.plist";
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    int barWidth = _techViewBarWidth;
    NSNumber * barWidthValue =[NSNumber numberWithInt:barWidth];
	
    
    if (_bottomView1Indicator>13) {
        _bottomView1Indicator = 13;
    }
	int day1 = _bottomView1Indicator;
	NSNumber *day1Value = [NSNumber numberWithInt:day1];
	int day2 = _bottomView2Indicator;
	NSNumber *day2Value = [NSNumber numberWithInt:day2];
    
    int week1 = _bottomView1WeekIndicator;
	NSNumber *week1Value = [NSNumber numberWithInt:week1];
	int week2 = _bottomView2WeekIndicator;
	NSNumber *week2Value = [NSNumber numberWithInt:week2];
    
    int month1 = _bottomView1MonIndicator;
	NSNumber *month1Value = [NSNumber numberWithInt:month1];
	int month2 = _bottomView2MonIndicator;
	NSNumber *monthValue = [NSNumber numberWithInt:month2];
    
    int minutes1 = _bottomView1MinIndicator;
	NSNumber *minutes1Value = [NSNumber numberWithInt:minutes1];
	int minutes2 = _bottomView2MinIndicator;
	NSNumber *minutes2Value = [NSNumber numberWithInt:minutes2];
    
    int dayIndicator = _UpperViewDayIndicator;
	NSNumber *dayIndicatorValue = [NSNumber numberWithInt:dayIndicator];
	int dayMainChart = _upperViewDayMainChart;
	NSNumber *dayMainChartValue = [NSNumber numberWithInt:dayMainChart];
    
    int weekIndicator = _UpperViewWeekIndicator;
	NSNumber *weekIndicatorValue = [NSNumber numberWithInt:weekIndicator];
	int weekMainChart = _upperViewWeekMainChart;
	NSNumber *weekMainChartValue = [NSNumber numberWithInt:weekMainChart];
    
    int monIndicator = _UpperViewMonIndicator;
	NSNumber *monIndicatorValue = [NSNumber numberWithInt:monIndicator];
	int monMainChart = _upperViewMonMainChart;
	NSNumber *monMainChartValue = [NSNumber numberWithInt:monMainChart];
    
    int minIndicator = _UpperViewMinIndicator;
	NSNumber *minIndicatorValue = [NSNumber numberWithInt:minIndicator];
	int minMainChart = _upperViewMinMainChart;
	NSNumber *minMainChartValue = [NSNumber numberWithInt:minMainChart];
    
    int analysisPeriod =_UpperViewAnalysisPeriod;
    NSNumber * analysisPeriodValue = [NSNumber numberWithInt:analysisPeriod];
    
    
    NSNumber * twoStockCompareValue = [NSNumber numberWithInt:_twoStockCompare];
	
	NSMutableDictionary *bottomIndicatorDict =  [[NSMutableDictionary alloc]initWithObjectsAndKeys:barWidthValue,@"techViewBarWidth",day1Value,@"bottomView1DayIndicator",day2Value,@"bottomView2DayIndicator",week1Value,@"bottomView1WeekIndicator",week2Value,@"bottomView2WeekIndicator",month1Value,@"bottomView1MonIndicator",monthValue,@"bottomView2MonIndicator",minutes1Value,@"bottomView1MinIndicator",minutes2Value,@"bottomView2MinIndicator",dayMainChartValue,@"upperViewDayMainChart",dayIndicatorValue,@"upperViewDayIndicator",weekMainChartValue,@"upperViewWeekMainChart",weekIndicatorValue,@"upperViewWeekIndicator",monMainChartValue,@"upperViewMonMainChart",monIndicatorValue,@"upperViewMonIndicator",minMainChartValue,@"upperViewMinMainChart",minIndicatorValue,@"upperViewMinIndicator",analysisPeriodValue,@"AnalysisPeriod",twoStockCompareValue,@"stockCompareValue",nil];
	
	BOOL success = [bottomIndicatorDict writeToFile:path atomically:YES];
		
	[indicatorLock unlock];	
	
	if(!success) NSLog(@"TechViewDefaultIndicator Write to file error");

}

- (void)readDefaultBottomViewIndicator
{
	//取得預設技術指標
	[indicatorLock lock];
	
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *fileName = @"TechViewDefaultIndicator.plist";
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	NSMutableDictionary *bottomIndicatorDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
	if(!bottomIndicatorDict)
	{
		[self createBottomViewDefaultIndicator];		
	}
	else
	{
        _techViewBarWidth = [(NSNumber *)[bottomIndicatorDict objectForKey:@"techViewBarWidth"]intValue];
        
		_bottomView1Indicator = [(NSNumber *)[bottomIndicatorDict objectForKey:@"bottomView1DayIndicator"]intValue];
		_bottomView2Indicator = [(NSNumber *)[bottomIndicatorDict objectForKey:@"bottomView2DayIndicator"]intValue];
        
        _bottomView1WeekIndicator = [(NSNumber *)[bottomIndicatorDict objectForKey:@"bottomView1WeekIndicator"]intValue];
		_bottomView2WeekIndicator = [(NSNumber *)[bottomIndicatorDict objectForKey:@"bottomView2WeekIndicator"]intValue];
        
        _bottomView1MonIndicator = [(NSNumber *)[bottomIndicatorDict objectForKey:@"bottomView1MonIndicator"]intValue];
		_bottomView2MonIndicator = [(NSNumber *)[bottomIndicatorDict objectForKey:@"bottomView2MonIndicator"]intValue];
        
        _bottomView1MinIndicator = [(NSNumber *)[bottomIndicatorDict objectForKey:@"bottomView1MinIndicator"]intValue];
		_bottomView2MinIndicator = [(NSNumber *)[bottomIndicatorDict objectForKey:@"bottomView2MinIndicator"]intValue];
        
        _upperViewDayMainChart = [(NSNumber *)[bottomIndicatorDict objectForKey:@"upperViewDayMainChart"]intValue];
        _UpperViewDayIndicator = [(NSNumber *)[bottomIndicatorDict objectForKey:@"upperViewDayIndicator"]intValue];
        
        _upperViewWeekMainChart = [(NSNumber *)[bottomIndicatorDict objectForKey:@"upperViewWeekMainChart"]intValue];
        _UpperViewWeekIndicator = [(NSNumber *)[bottomIndicatorDict objectForKey:@"upperViewWeekIndicator"]intValue];
        
        _upperViewMonMainChart = [(NSNumber *)[bottomIndicatorDict objectForKey:@"upperViewMonMainChart"]intValue];
        _UpperViewMonIndicator = [(NSNumber *)[bottomIndicatorDict objectForKey:@"upperViewMonIndicator"]intValue];
        
        _upperViewMinMainChart = [(NSNumber *)[bottomIndicatorDict objectForKey:@"upperViewMinMainChart"]intValue];
        _UpperViewMinIndicator = [(NSNumber *)[bottomIndicatorDict objectForKey:@"upperViewMinIndicator"]intValue];
		
	}	
		
	[indicatorLock unlock];
	
}

- (void)setBottomViewDefaultIndicator:(BottomViewAnalysisType)analysisType indicatorViewType:(int)viewType PeriodType:(AnalysisPeriod)periodType
{
	
	[indicatorLock lock];
	
	//設定預設指標 viewType = 0 上面的技術指標圖(bottonView1) ;  viewType = 1 下面的技術指標圖(bottonView2)
	if(viewType == 0)
	{
		//bottonView1
        if (periodType == 0) {
            _bottomView1Indicator = analysisType;
        }else if (periodType == 1){
            _bottomView1WeekIndicator = analysisType;
        }else if (periodType == 2){
            _bottomView1MonIndicator = analysisType;
        }else{
            _bottomView1MinIndicator = analysisType;
        }
		
	}
	else
	{
		//bottonView2
		if (periodType == 0) {
            _bottomView2Indicator = analysisType;
        }else if (periodType == 1){
            _bottomView2WeekIndicator = analysisType;
        }else if (periodType == 2){
            _bottomView2MonIndicator = analysisType;
        }else{
            _bottomView2MinIndicator = analysisType;
        }
	}
	
	//[self writeDefaultBottomViewIndicator];
	
	[indicatorLock unlock];	
	
	

}


- (void)setUpperViewDefaultMainChart:(UpperViewMainChar)mainCharType IndicatorType:(UpperViewIndicator)indicatorType PeriodType:(AnalysisPeriod)periodType
{
	
	[indicatorLock lock];
	

    if (periodType == 0) {
        _upperViewDayMainChart = mainCharType;
        _UpperViewDayIndicator = indicatorType;
    }else if (periodType == 1){
        _upperViewWeekMainChart = mainCharType;
        _UpperViewWeekIndicator = indicatorType;
    }else if (periodType == 2){
        _upperViewMonMainChart = mainCharType;
        _UpperViewMonIndicator = indicatorType;
    }else{
        _upperViewMinMainChart = mainCharType;
        _UpperViewMinIndicator = indicatorType;
    }
	
	
	[indicatorLock unlock];

}


- (void)createIndicatorsIfNeed{
	
	// VOL

	NSMutableDictionary *VOL = [[NSMutableDictionary alloc]init];
	
	//RSI
	NSMutableDictionary *RSI = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:14],@"rsiParameter",nil];
	
	//KD
	NSMutableDictionary *KD = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
									 [NSNumber numberWithInt:9],@"kdParameter",
									 [NSNumber numberWithInt:3],@"kExponentialSmoothing",
									 [NSNumber numberWithInt:3],@"dExponentialSmoothing",nil];
	
	//MACD
	NSMutableDictionary *MACD = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
									 [NSNumber numberWithInt:12],@"shortEMAParameter",
									 [NSNumber numberWithInt:26],@"longEMAParameter",
									 [NSNumber numberWithInt:9],@"macdParameter",nil];
	
	//Bias
	NSMutableDictionary *Bias = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:12],@"biasParameter",nil];
	
    //OBV
	NSMutableDictionary *OBV = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:12],@"obvParameter",nil];

	//PSY
	NSMutableDictionary *PSY = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:12],@"psyParameter",nil];
	
	//WR
	NSMutableDictionary *WR = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:14],@"williamsParameter",nil];

	//MTM
	NSMutableDictionary *MTM = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:10],@"mtmParameter",nil];
	
    //OSC	
	NSMutableDictionary *OSC = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:10],@"oscParameter",nil];
	
	//ARBR
	NSMutableDictionary *ARBR = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
									 [NSNumber numberWithInt:26],@"arParameter",
									 [NSNumber numberWithInt:26],@"brParameter",nil];

	//DMI
	NSMutableDictionary *DMI = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:14],@"dmiParameter",nil];

	//Tower
	NSMutableDictionary *Tower = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:3],@"towerParameter",nil];

	//KDJ
	NSMutableDictionary *KDJ = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
								   [NSNumber numberWithInt:9],@"kdParameter",
								   [NSNumber numberWithInt:3],@"kExponentialSmoothing",
								   [NSNumber numberWithInt:3],@"dExponentialSmoothing",nil];

	//CCI
	NSMutableDictionary *CCI = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:14],@"cciParameter",nil];

	//VR
	NSMutableDictionary *VR = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:24],@"vrParameter",nil];

	//short MA
	NSMutableDictionary *shortMA = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:5],@"maParameter",nil];
	
	//middle MA
	NSMutableDictionary *middleMA = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:10],@"maParameter",nil];
	
	//long MA
	NSMutableDictionary *longMA = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:20],@"maParameter",nil];
	
	//bollinger
	NSMutableDictionary *BB = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:20],@"bbNumber",[NSNumber numberWithInt:2],@"devNumber",nil];

	if(indicatorParameterDictionary==nil)
	{
		
		indicatorParameterDictionary = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
										VOL,@"VOL",
										RSI,@"RSI",
										KD,@"KD",
										MACD,@"MACD",
										Bias,@"Bias",
										OBV,@"OBV",
										PSY,@"PSY",
										WR,@"WR",
										MTM,@"MTM",
										OSC,@"OSC",
										ARBR,@"ARBR",
										DMI,@"DMI",
										Tower,@"Tower",
										KDJ,@"KDJ",
										CCI,@"CCI",
										VR,@"VR",
										shortMA,@"shortMA",
										middleMA,@"middleMA",
										longMA,@"longMA",
										BB,@"BB",
										nil];
	
	}
	
	[self writeIndicatorParameterTable];


}

- (void)readIndicatorParameterTable
{

	[indicatorLock lock];
	
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *fileName = @"IndicatorParameterTableVer3.plist";
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	indicatorParameterDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
    [indicatorLock unlock];			
	
	if(!indicatorParameterDictionary)
	{
		[self createIndicatorsIfNeed];		
	}
	else if([[indicatorParameterDictionary allKeys]count] != indicatorCount)
	{
		self.indicatorParameterDictionary = nil;
		[self createIndicatorsIfNeed];				
	
	}

}


// 讀 技術指標的參數
- (void)loadIndicatorParameterByAnalysisType:(AnalysisType)analysisType
{
	
	[indicatorLock lock];	
	
	switch (analysisType) 
	{
		case AnalysisTypeVOL:
			indicatorParameter1 = -1;
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeRSI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"RSI"] objectForKey:@"rsiParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeKD:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KD"] objectForKey:@"kdParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KD"] objectForKey:@"kExponentialSmoothing"]intValue];

			indicatorParameter3 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KD"] objectForKey:@"dExponentialSmoothing"]intValue];

			break;
		case AnalysisTypeMACD:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MACD"] objectForKey:@"shortEMAParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MACD"] objectForKey:@"longEMAParameter"]intValue];
			indicatorParameter3 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MACD"] objectForKey:@"macdParameter"]intValue];
			break;
		case AnalysisTypeBias:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"Bias"] objectForKey:@"biasParameter"]intValue];

			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeOBV:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"OBV"] objectForKey:@"obvParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypePSY:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"PSY"] objectForKey:@"psyParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeWR:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"WR"] objectForKey:@"williamsParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeMTM:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MTM"] objectForKey:@"mtmParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeOSC:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"OSC"] objectForKey:@"oscParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeARBR:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"ARBR"] objectForKey:@"arParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"ARBR"] objectForKey:@"brParameter"]intValue];
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeDMI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"DMI"] objectForKey:@"dmiParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeTower:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"Tower"] objectForKey:@"towerParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeKDJ:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KDJ"] objectForKey:@"kdParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KDJ"] objectForKey:@"kExponentialSmoothing"]intValue];
			indicatorParameter3 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KDJ"] objectForKey:@"dExponentialSmoothing"]intValue];
			break;
		case AnalysisTypeCCI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"CCI"] objectForKey:@"cciParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeVR:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"VR"] objectForKey:@"vrParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeShortMA: 
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"shortMA"] objectForKey:@"maParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeMiddleMA: 
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"middleMA"] objectForKey:@"maParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeLongMA: 
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"longMA"] objectForKey:@"maParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeBB: 
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"BB"] objectForKey:@"bbNumber"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"BB"] objectForKey:@"devNumber"]intValue];
			indicatorParameter3 = -1;
			break;
		default:
			break;
			
			
			
	}
	
	[indicatorLock unlock];	
	
}

- (NSMutableDictionary *)readIndicatorParameterByAnalysisType:(AnalysisType)analysisType{
	
	NSMutableDictionary *parameterDictionary;
	
	[indicatorLock lock];	
	
	switch (analysisType) {
		case AnalysisTypeVOL:
			indicatorParameter1 = -1;
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeRSI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"RSI"] objectForKey:@"rsiParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeKD:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KD"] objectForKey:@"kdParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KD"] objectForKey:@"kExponentialSmoothing"]intValue];
			indicatorParameter3 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KD"] objectForKey:@"dExponentialSmoothing"]intValue];			
			break;
		case AnalysisTypeMACD:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MACD"] objectForKey:@"shortEMAParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MACD"] objectForKey:@"longEMAParameter"]intValue];
			indicatorParameter3 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MACD"] objectForKey:@"macdParameter"]intValue];
			break;
		case AnalysisTypeBias:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"Bias"] objectForKey:@"biasParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeOBV:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"OBV"] objectForKey:@"obvParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypePSY:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"PSY"] objectForKey:@"psyParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeWR:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"WR"] objectForKey:@"williamsParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeMTM:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MTM"] objectForKey:@"mtmParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeOSC:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"OSC"] objectForKey:@"oscParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeARBR:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"ARBR"] objectForKey:@"arParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"ARBR"] objectForKey:@"brParameter"]intValue];
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeDMI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"DMI"] objectForKey:@"dmiParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeTower:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"Tower"] objectForKey:@"towerParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeKDJ:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KDJ"] objectForKey:@"kdParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KDJ"] objectForKey:@"kExponentialSmoothing"]intValue];
			indicatorParameter3 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KDJ"] objectForKey:@"dExponentialSmoothing"]intValue];
			break;
		case AnalysisTypeCCI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"CCI"] objectForKey:@"cciParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeVR:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"VR"] objectForKey:@"vrParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeShortMA: 
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"shortMA"] objectForKey:@"maParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeMiddleMA: 
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"middleMA"] objectForKey:@"maParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeLongMA: 
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"longMA"] objectForKey:@"maParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeBB: 
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"BB"] objectForKey:@"bbNumber"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"BB"] objectForKey:@"devNumber"]intValue];
			indicatorParameter3 = -1;
			break;
			
		default:
			break;
			
	}
	
	parameterDictionary = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
						   [NSNumber numberWithInt:indicatorParameter1],@"indicatorParameter1",
						   [NSNumber numberWithInt:indicatorParameter2],@"indicatorParameter2",
	                       [NSNumber numberWithInt:indicatorParameter3],@"indicatorParameter3",nil];
	
	
	[indicatorLock unlock];	
	
	return parameterDictionary;
	
}

- (void)updateIndicatorParameterByAnalysisType:(AnalysisType)analysisType{
	
	[indicatorLock lock];		
	
	switch (analysisType) {
			
		case AnalysisTypeVOL:
			
			indicatorParameter1 = -1;
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
			
		case AnalysisTypeRSI:
			
			[[indicatorParameterDictionary objectForKey:@"RSI"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"rsiParameter"];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
			
		case AnalysisTypeKD:

			[[indicatorParameterDictionary objectForKey:@"KD"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"kdParameter"];
			[[indicatorParameterDictionary objectForKey:@"KD"] setValue:[NSNumber numberWithInt:indicatorParameter2] forKey:@"kExponentialSmoothing"];
			[[indicatorParameterDictionary objectForKey:@"KD"] setValue:[NSNumber numberWithInt:indicatorParameter3] forKey:@"dExponentialSmoothing"];				
			break;
			
		case AnalysisTypeMACD:
			
			[[indicatorParameterDictionary objectForKey:@"MACD"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"shortEMAParameter"];
			[[indicatorParameterDictionary objectForKey:@"MACD"] setValue:[NSNumber numberWithInt:indicatorParameter2] forKey:@"longEMAParameter"];
			[[indicatorParameterDictionary objectForKey:@"MACD"] setValue:[NSNumber numberWithInt:indicatorParameter3] forKey:@"macdParameter"];
			break;
			
		case AnalysisTypeBias:
			
			[[indicatorParameterDictionary objectForKey:@"Bias"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"biasParameter"];			
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;			
			break;
			
		case AnalysisTypeOBV:
			
			[[indicatorParameterDictionary objectForKey:@"OBV"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"obvParameter"];			
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;			
			break;
			
		case AnalysisTypePSY:
			
			[[indicatorParameterDictionary objectForKey:@"PSY"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"psyParameter"];			
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;			
			break;
			
		case AnalysisTypeWR:
			
			[[indicatorParameterDictionary objectForKey:@"WR"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"williamsParameter"];			
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;			
			break;
			
		case AnalysisTypeMTM:
			
			[[indicatorParameterDictionary objectForKey:@"MTM"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"mtmParameter"];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;			
			break;
			
		case AnalysisTypeOSC:
			
			[[indicatorParameterDictionary objectForKey:@"OSC"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"oscParameter"];			
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;			
			break;
			
		case AnalysisTypeARBR:
			
			[[indicatorParameterDictionary objectForKey:@"ARBR"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"arParameter"];
			[[indicatorParameterDictionary objectForKey:@"ARBR"] setValue:[NSNumber numberWithInt:indicatorParameter2] forKey:@"brParameter"];				
			indicatorParameter3 = -1;			
			break;
			
		case AnalysisTypeDMI:
			
			[[indicatorParameterDictionary objectForKey:@"DMI"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"dmiParameter"];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;			
			break;
			
		case AnalysisTypeTower:
			
			[[indicatorParameterDictionary objectForKey:@"Tower"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"towerParameter"];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			
			break;
			
		case AnalysisTypeKDJ:
			
			[[indicatorParameterDictionary objectForKey:@"KD"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"kdParameter"];
			[[indicatorParameterDictionary objectForKey:@"KD"] setValue:[NSNumber numberWithInt:indicatorParameter2] forKey:@"kExponentialSmoothing"];
			[[indicatorParameterDictionary objectForKey:@"KD"] setValue:[NSNumber numberWithInt:indicatorParameter3] forKey:@"dExponentialSmoothing"];				
			break;
			
		case AnalysisTypeCCI:
			
			[[indicatorParameterDictionary objectForKey:@"CCI"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"cciParameter"];
			break;
			
		case AnalysisTypeVR:
			[[indicatorParameterDictionary objectForKey:@"VR"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"vrParameter"];
			break;
			
		case AnalysisTypeShortMA: 
			
			[[indicatorParameterDictionary objectForKey:@"shortMA"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"maParameter"];			
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;			
			break;
		
		case AnalysisTypeMiddleMA: 
			
			[[indicatorParameterDictionary objectForKey:@"middleMA"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"maParameter"];			
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;			
			break;
			
		case AnalysisTypeLongMA: 
			
			[[indicatorParameterDictionary objectForKey:@"longMA"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"maParameter"];			
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;			
			break;
			
		case AnalysisTypeBB:
			
			[[indicatorParameterDictionary objectForKey:@"BB"] setValue:[NSNumber numberWithInt:indicatorParameter1] forKey:@"bbNumber"];
			[[indicatorParameterDictionary objectForKey:@"BB"] setValue:[NSNumber numberWithInt:indicatorParameter2] forKey:@"devNumber"];				
			indicatorParameter3 = -1;
			
			break;
			
		default:			
			NSLog(@"wnet default way , Indicator Parameter not update" );
			break;
			
			
	}
	
	[indicatorLock unlock];	
	
}

- (void)setSelectedIndicatorByAnalysisType:(BottomViewAnalysisType)analysisType{
	
	self.selectedIndicator = analysisType;

}

- (BottomViewAnalysisType)getSelectIndicator{
	
	return self.selectedIndicator;

}

- (int)getIndicatorsCount{
	
	return (int)[[self.indicatorParameterDictionary allKeys]count];

}

- (void)setIndicatorParameterCountWithAnalysisType:(BottomViewAnalysisType)analysisType{

	switch (analysisType) {
		case BottomViewAnalysisTypeVOL:
			selectedIndicatorParameterCount = 0;
			break;
		case BottomViewAnalysisTypeRSI:
			selectedIndicatorParameterCount = 1;
			break;
		case BottomViewAnalysisTypeMACD:
			selectedIndicatorParameterCount = 3;
			break;
		case BottomViewAnalysisTypeBias:
			selectedIndicatorParameterCount = 1;
			break;
		case BottomViewAnalysisTypeOBV:
			selectedIndicatorParameterCount = 1;
			break;
		case BottomViewAnalysisTypePSY:
			selectedIndicatorParameterCount = 1;
			break;
		case BottomViewAnalysisTypeWR:
			selectedIndicatorParameterCount = 1;
			break;
		case BottomViewAnalysisTypeMTM:
			selectedIndicatorParameterCount = 1;
			break;
		case BottomViewAnalysisTypeOSC:
			selectedIndicatorParameterCount = 1;
			break;
		case BottomViewAnalysisTypeARBR:
			selectedIndicatorParameterCount = 2;
			break;
		case BottomViewAnalysisTypeDMI:
			selectedIndicatorParameterCount = 1;
			break;
		case BottomViewAnalysisTypeTower:
			selectedIndicatorParameterCount = 1;
			break;
		case BottomViewAnalysisTypeKDJ:
			selectedIndicatorParameterCount = 3;
			break;
//		case AnalysisTypeCCI:
//			selectedIndicatorParameterCount = 1;
//			break;
//		case BottomViewAnalysisTypeVR:
//			selectedIndicatorParameterCount = 1;
//			break;
//		case AnalysisTypeShortMA:
//			selectedIndicatorParameterCount = 1;			
//			break;
//		case AnalysisTypeMiddleMA: 
//			selectedIndicatorParameterCount = 1;			
//			break;
//		case AnalysisTypeLongMA: 
//			selectedIndicatorParameterCount = 1;			
//			break;
//		case AnalysisTypeBB: 
//			selectedIndicatorParameterCount = 2;			
//			break;
		default:
			selectedIndicatorParameterCount = 0;						
			break;
	}
	
}

- (NSString *)indicatorNameForAnalysisType:(AnalysisType)type {
	
    switch (type) {
        case AnalysisTypeVOL:       return  NSLocalizedStringFromTable(@"Volume", @"Draw", @"Volume indicator");
			break;
        case AnalysisTypeRSI:       return NSLocalizedStringFromTable(@"RSI", @"Draw", @"RSI indicator");
			break;			
        case AnalysisTypeKD:        return NSLocalizedStringFromTable(@"KD", @"Draw", @"KD indicator");
			break;			
        case AnalysisTypeMACD:      return NSLocalizedStringFromTable(@"MACD", @"Draw", @"MACD indicator");
			break;			
        case AnalysisTypeBias:      return  NSLocalizedStringFromTable(@"Bias", @"Draw", @"Bias indicator");
			break;			
        case AnalysisTypeOBV:       return  NSLocalizedStringFromTable(@"OBV", @"Draw", @"OBV indicator");
			break;			
        case AnalysisTypePSY:       return  NSLocalizedStringFromTable(@"PSY", @"Draw", @"PSY indicator");
			break;			
        case AnalysisTypeWR:        return  NSLocalizedStringFromTable(@"Williams", @"Draw", @"Williams indicator");
			break;			
        case AnalysisTypeMTM:       return  NSLocalizedStringFromTable(@"Momentum", @"Draw", @"Momentum indicator");
			break;			
        case AnalysisTypeOSC:       return  NSLocalizedStringFromTable(@"Oscillator", @"Draw", @"Oscillator indicator");
			break;			
        case AnalysisTypeARBR:      return  NSLocalizedStringFromTable(@"ARBR", @"Draw", @"AR/BR indicator");
			break;			
        case AnalysisTypeDMI:       return  NSLocalizedStringFromTable(@"DMI", @"Draw", @"ADX/DMI indicator");
			break;			
        case AnalysisTypeTower:     return  NSLocalizedStringFromTable(@"Tower", @"Draw", @"Tower indicator");
			break;			
        case AnalysisTypeKDJ:        return NSLocalizedStringFromTable(@"KDJ", @"Draw", @"KD indicator");
			break;			
        case AnalysisTypeCCI:        return NSLocalizedStringFromTable(@"CCI", @"Draw", @"CCI indicator");
			break;			
        case AnalysisTypeVR:        return NSLocalizedStringFromTable(@"VR", @"Draw", @"CCI indicator");
			break;			
		case AnalysisTypeShortMA:   return  NSLocalizedStringFromTable(@"Moving Average",@"Draw",@"indicator"); //alarm use			
			break;
		case AnalysisTypeMiddleMA:    return  NSLocalizedStringFromTable(@"Moving Average",@"Draw",@"indicator"); //alarm use			
			break;
		case AnalysisTypeLongMA:    return  NSLocalizedStringFromTable(@"Moving Average",@"Draw",@"indicator"); //alarm use			
			break;
		case AnalysisTypeBB:        return  NSLocalizedStringFromTable(@"Bollinger Bands", @"Draw", @"BB");
			break;
        default: return nil;
			break;			
    }
	
}

- (NSString *)indicatorNameByAnalysisType:(BottomViewAnalysisType)type {
	
	NSString *titleString;
	
	[indicatorLock lock];	
	
	switch (type) {
		case BottomViewAnalysisTypeVOL:
			titleString =  NSLocalizedStringFromTable(@"VolumeTitle", @"Draw", @"Volume indicator");
			break;
		case BottomViewAnalysisTypeRSI:
			titleString = NSLocalizedStringFromTable(@"RSI", @"Draw", @"RSI indicator");
			break;
		case BottomViewAnalysisTypeMACD:
			titleString =  NSLocalizedStringFromTable(@"MACD", @"Draw", @"MACD indicator");
			break;
		case BottomViewAnalysisTypeBias:
			titleString = NSLocalizedStringFromTable(@"Bias", @"Draw", @"Bias indicator");
            break;
		case BottomViewAnalysisTypeOBV:
			titleString = NSLocalizedStringFromTable(@"OBV", @"Draw", @"OBV indicator");
			break;
		case BottomViewAnalysisTypePSY:
			titleString = NSLocalizedStringFromTable(@"PSY", @"Draw", @"PSY indicator");
			break;
		case BottomViewAnalysisTypeWR:
			titleString = NSLocalizedStringFromTable(@"Williams", @"Draw", @"Williams indicator");
			break;
		case BottomViewAnalysisTypeMTM:
			titleString = NSLocalizedStringFromTable(@"Momentum", @"Draw", @"Momentum indicator");
			break;
		case BottomViewAnalysisTypeOSC:
			titleString = NSLocalizedStringFromTable(@"Oscillator", @"Draw", @"Oscillator indicator");
			break;
		case BottomViewAnalysisTypeARBR:
			titleString = NSLocalizedStringFromTable(@"ARBR", @"Draw", @"AR/BR indicator");
			break;
		case BottomViewAnalysisTypeDMI:
			titleString = NSLocalizedStringFromTable(@"DMI", @"Draw", @"ADX/DMI indicator");					
			break;
		case BottomViewAnalysisTypeTower:
			titleString = NSLocalizedStringFromTable(@"TLB", @"Draw", @"Tower indicator");
			break;
		case BottomViewAnalysisTypeKDJ:
			titleString = NSLocalizedStringFromTable(@"KDJ", @"Draw", @"KD indicator");
            break;
		case BottomViewAnalysisTypeVR:
			titleString =  NSLocalizedStringFromTable(@"VR", @"Draw", @"VR indicator");
			break;
        case BottomViewAnalysisTypeGain:
			titleString =  NSLocalizedStringFromTable(@"Gain", @"Draw", @"Gain indicator");
			break;
		default:
			titleString =  @"";
			break;
	}
	
	[indicatorLock unlock];		
	
	return titleString;
	
	
}

- (NSString *)indicatorSymbolAndParameterByAnalysisType:(AnalysisType)type{
	
	NSString *titleString;
	
	switch (type) {
		case AnalysisTypeVOL:
			indicatorParameter1 = -1;
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  NSLocalizedStringFromTable(@"Volume", @"Draw", @"Volume indicator");			
			break;
		case AnalysisTypeRSI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"RSI"] objectForKey:@"rsiParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"RSI",indicatorParameter1];			
			break;
		case AnalysisTypeKD:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KD"] objectForKey:@"kdParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KD"] objectForKey:@"kExponentialSmoothing"]intValue];
			indicatorParameter3 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KD"] objectForKey:@"dExponentialSmoothing"]intValue];
			titleString =  [NSString stringWithFormat:@"%@(%d, %d, %d)",@"KD",indicatorParameter1,indicatorParameter2,indicatorParameter3];						
			break;
		case AnalysisTypeMACD:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MACD"] objectForKey:@"shortEMAParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MACD"] objectForKey:@"longEMAParameter"]intValue];
			indicatorParameter3 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MACD"] objectForKey:@"macdParameter"]intValue];
			titleString =  [NSString stringWithFormat:@"%@(%d, %d, %d)",@"MACD",indicatorParameter1,indicatorParameter2,indicatorParameter3];			
			break;
		case AnalysisTypeBias:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"Bias"] objectForKey:@"biasParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"BIAS",indicatorParameter1];						
			break;
		case AnalysisTypeOBV:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"OBV"] objectForKey:@"obvParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"OBV",indicatorParameter1];									
			break;
		case AnalysisTypePSY:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"PSY"] objectForKey:@"psyParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"PSY",indicatorParameter1];									
			break;
		case AnalysisTypeWR:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"WR"] objectForKey:@"williamsParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"W%R",indicatorParameter1];												
			break;
		case AnalysisTypeMTM:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MTM"] objectForKey:@"mtmParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"MTM",indicatorParameter1];													
			break;
		case AnalysisTypeOSC:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"OSC"] objectForKey:@"oscParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"OSC",indicatorParameter1];								
			break;
		case AnalysisTypeARBR:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"ARBR"] objectForKey:@"arParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"ARBR"] objectForKey:@"brParameter"]intValue];
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d, %d)",@"AR/BR",indicatorParameter1,indicatorParameter2];								
			break;
		case AnalysisTypeDMI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"DMI"] objectForKey:@"dmiParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"ADX/DMI",indicatorParameter1];								
			break;
		case AnalysisTypeTower:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"Tower"] objectForKey:@"towerParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"Tower",indicatorParameter1];					
			break;
		case AnalysisTypeKDJ:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KDJ"] objectForKey:@"kdParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KDJ"] objectForKey:@"kExponentialSmoothing"]intValue];
			indicatorParameter3 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KDJ"] objectForKey:@"dExponentialSmoothing"]intValue];
			titleString =  [NSString stringWithFormat:@"%@(%d, %d, %d)",@"KDJ",indicatorParameter1,indicatorParameter2,indicatorParameter3];			
			break;
		case AnalysisTypeCCI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"CCI"] objectForKey:@"cciParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"CCI",indicatorParameter1];					
			break;
		case AnalysisTypeVR:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"VR"] objectForKey:@"vrParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"VR",indicatorParameter1];					
			break;
		case AnalysisTypeShortMA:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"shortMA"] objectForKey:@"maParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"MA",indicatorParameter1];											
			break;
		case AnalysisTypeMiddleMA:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"middleMA"] objectForKey:@"maParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"MA",indicatorParameter1];											
			break;
		case AnalysisTypeLongMA:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"longMA"] objectForKey:@"maParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",@"MA",indicatorParameter1];											
			break;
		case AnalysisTypeBB:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"BB"] objectForKey:@"bbNumber"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"BB"] objectForKey:@"devNumber"]intValue];
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d,%d)",@"BB",indicatorParameter1,indicatorParameter2];								
			break;
			
		default: 
			indicatorParameter1 = -1;			
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  @"";
			break;		
			
			
	}

	return titleString;	


}

-(void)setIndicatorParameterByIndicatorParameterDictionary:(NSMutableDictionary*)dict{
	
	[indicatorLock lock];		
	
	self.indicatorParameter1 = [(NSNumber *)[dict objectForKey:@"indicatorParameter1"]intValue];
	self.indicatorParameter2 = [(NSNumber *)[dict objectForKey:@"indicatorParameter2"]intValue];
	self.indicatorParameter3 = [(NSNumber *)[dict objectForKey:@"indicatorParameter3"]intValue];
	
	[indicatorLock unlock];	

}


#pragma mark -
#pragma mark NEW Indicator

- (void)writeIndicatorParameterTable
{
	
	[indicatorLock lock];
	
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *fileName = @"IndicatorParameterTableVer3.plist";
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	BOOL success = [indicatorParameterDictionary writeToFile:path atomically:YES];
	
	[indicatorLock unlock];
	
	if(!success) NSLog(@"indicatorParameterDictionary Write to file error");
	
}

-(void)createNewIndicatorsIfNeed{
    //MA1
	NSMutableDictionary * MA1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:5],@"dayLine",[NSNumber numberWithInt:5],@"weekLine",[NSNumber numberWithInt:3],@"monthLine",[NSNumber numberWithInt:6],@"minuteLine",nil];
	
	//MA2
	NSMutableDictionary * MA2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:10],@"dayLine",[NSNumber numberWithInt:13],@"weekLine",[NSNumber numberWithInt:6],@"monthLine",[NSNumber numberWithInt:12],@"minuteLine",nil];
	
	//MA3
	NSMutableDictionary * MA3 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:20],@"dayLine",[NSNumber numberWithInt:26],@"weekLine",[NSNumber numberWithInt:12],@"monthLine",[NSNumber numberWithInt:24],@"minuteLine",nil];
    
    //MA4
	NSMutableDictionary * MA4 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:60],@"dayLine",[NSNumber numberWithInt:52],@"weekLine",[NSNumber numberWithInt:24],@"monthLine",[NSNumber numberWithInt:36],@"minuteLine",nil];
	
	//MA5
    NSMutableDictionary * MA5 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:120],@"dayLine",[NSNumber numberWithInt:104],@"weekLine",[NSNumber numberWithInt:60],@"monthLine",[NSNumber numberWithInt:48],@"minuteLine",nil];
	//MA6
    NSMutableDictionary * MA6 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:240],@"dayLine",[NSNumber numberWithInt:260],@"weekLine",[NSNumber numberWithInt:120],@"monthLine",[NSNumber numberWithInt:54],@"minuteLine",nil];
    
    //SAR
    NSMutableDictionary * SAR = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:10],@"dayLine",[NSNumber numberWithInt:13],@"weekLine",[NSNumber numberWithInt:12],@"monthLine",[NSNumber numberWithInt:12],@"minuteLine",nil];
    
    //BB
    NSMutableDictionary * BB = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:20],@"dayLine",[NSNumber numberWithInt:13],@"weekLine",[NSNumber numberWithInt:12],@"monthLine",[NSNumber numberWithInt:12],@"minuteLine",nil];
    
    //STD_DEV
    NSMutableDictionary * STD_DEV = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:2],@"dayLine",[NSNumber numberWithInt:2],@"weekLine",[NSNumber numberWithInt:2],@"monthLine",[NSNumber numberWithInt:2],@"minuteLine",nil];
    
    //VOL1
    NSMutableDictionary * VOL1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:5],@"dayLine",[NSNumber numberWithInt:5],@"weekLine",[NSNumber numberWithInt:6],@"monthLine",[NSNumber numberWithInt:6],@"minuteLine",nil];
    
    //VOL2
    NSMutableDictionary * VOL2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:10],@"dayLine",[NSNumber numberWithInt:13],@"weekLine",[NSNumber numberWithInt:12],@"monthLine",[NSNumber numberWithInt:12],@"minuteLine",nil];
    
    //RSI1
    NSMutableDictionary * RSI1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:5],@"dayLine",[NSNumber numberWithInt:5],@"weekLine",[NSNumber numberWithInt:6],@"monthLine",[NSNumber numberWithInt:6],@"minuteLine",nil];
    
    //RSI2
    NSMutableDictionary * RSI2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:10],@"dayLine",[NSNumber numberWithInt:13],@"weekLine",[NSNumber numberWithInt:12],@"monthLine",[NSNumber numberWithInt:12],@"minuteLine",nil];
    
    //KD
    NSMutableDictionary * KD = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:9],@"dayLine",[NSNumber numberWithInt:9],@"weekLine",[NSNumber numberWithInt:9],@"monthLine",[NSNumber numberWithInt:9],@"minuteLine",nil];
    
    //EMA1
    NSMutableDictionary * EMA1 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:12],@"dayLine",[NSNumber numberWithInt:12],@"weekLine",[NSNumber numberWithInt:12],@"monthLine",[NSNumber numberWithInt:12],@"minuteLine",nil];
    
    //EMA2
    NSMutableDictionary * EMA2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:26],@"dayLine",[NSNumber numberWithInt:26],@"weekLine",[NSNumber numberWithInt:26],@"monthLine",[NSNumber numberWithInt:26],@"minuteLine",nil];
    
    //MACD
    NSMutableDictionary * MACD = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:9],@"dayLine",[NSNumber numberWithInt:9],@"weekLine",[NSNumber numberWithInt:9],@"monthLine",[NSNumber numberWithInt:9],@"minuteLine",nil];
    
    //BIAS
    NSMutableDictionary * BIAS = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:20],@"dayLine",[NSNumber numberWithInt:13],@"weekLine",[NSNumber numberWithInt:12],@"monthLine",[NSNumber numberWithInt:12],@"minuteLine",nil];
    
    //OBV
    NSMutableDictionary * OBV = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:60],@"dayLine",[NSNumber numberWithInt:52],@"weekLine",[NSNumber numberWithInt:24],@"monthLine",[NSNumber numberWithInt:36],@"minuteLine",nil];
    
    //PSY
    NSMutableDictionary * PSY = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:20],@"dayLine",[NSNumber numberWithInt:13],@"weekLine",[NSNumber numberWithInt:12],@"monthLine",[NSNumber numberWithInt:12],@"minuteLine",nil];
    
    //W%R
    NSMutableDictionary * W_R = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:9],@"dayLine",[NSNumber numberWithInt:9],@"weekLine",[NSNumber numberWithInt:9],@"monthLine",[NSNumber numberWithInt:9],@"minuteLine",nil];
    
    //MTM
    NSMutableDictionary * MTM = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:10],@"dayLine",[NSNumber numberWithInt:13],@"weekLine",[NSNumber numberWithInt:12],@"monthLine",[NSNumber numberWithInt:12],@"minuteLine",nil];
    
    //OSC
    NSMutableDictionary * OSC = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:10],@"dayLine",[NSNumber numberWithInt:13],@"weekLine",[NSNumber numberWithInt:12],@"monthLine",[NSNumber numberWithInt:12],@"minuteLine",nil];
    
    //AR
    NSMutableDictionary * AR = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:20],@"dayLine",[NSNumber numberWithInt:26],@"weekLine",[NSNumber numberWithInt:24],@"monthLine",[NSNumber numberWithInt:24],@"minuteLine",nil];
    
    //BR
    NSMutableDictionary * BR = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:20],@"dayLine",[NSNumber numberWithInt:26],@"weekLine",[NSNumber numberWithInt:24],@"monthLine",[NSNumber numberWithInt:24],@"minuteLine",nil];
    
    //DMI
    NSMutableDictionary * DMI = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:10],@"dayLine",[NSNumber numberWithInt:13],@"weekLine",[NSNumber numberWithInt:12],@"monthLine",[NSNumber numberWithInt:12],@"minuteLine",nil];
    
    //VR
    NSMutableDictionary * VR = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:20],@"dayLine",[NSNumber numberWithInt:26],@"weekLine",[NSNumber numberWithInt:24],@"monthLine",[NSNumber numberWithInt:24],@"minuteLine",nil];
    
    
    if(_indicatorParameterDictionaryNew==nil)
	{
		
		_indicatorParameterDictionaryNew = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
										MA1,@"MA1",
										MA2,@"MA2",
										MA3,@"MA3",
										MA4,@"MA4",
										MA5,@"MA5",
										MA6,@"MA6",
										SAR,@"SAR",
										BB,@"BB",
										STD_DEV,@"SD",
										VOL1,@"AV-S",
										VOL2,@"AV-L",
										RSI1,@"RSI-1",
										RSI2,@"RSI-2",
										KD,@"KD",
										EMA1,@"EMA-1",
										EMA2,@"EMA-2",
										MACD,@"MACD",
										BIAS,@"BIAS",
										OBV,@"OBV",
										PSY,@"PSY",
                                        W_R,@"W%R",
										MTM,@"MTM",
										OSC,@"OSC",
										AR,@"AR",
										BR,@"BR",
										DMI,@"DMI",
										VR,@"VR",
										nil];
    }
    [self writeNewIndicatorParameterTable];
}


- (void)readNewIndicatorParameterTable
{
    
	[indicatorLock lock];
	
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *fileName = @"IndicatorParameterTable.plist";
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	_indicatorParameterDictionaryNew = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
    [indicatorLock unlock];
	
	if(!_indicatorParameterDictionaryNew)
	{
		[self createNewIndicatorsIfNeed];
	}
	else if([[_indicatorParameterDictionaryNew allKeys]count] != _indicatorCountNew)
	{
		self.indicatorParameterDictionaryNew = nil;
		[self createNewIndicatorsIfNeed];
        
	}
    
}

- (void)writeNewIndicatorParameterTable
{
	
	[indicatorLock lock];
	
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *fileName = @"IndicatorParameterTable.plist";
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	BOOL success = [_indicatorParameterDictionaryNew writeToFile:path atomically:YES];
	
	[indicatorLock unlock];
	
	if(!success) NSLog(@"newIndicatorParameterDictionary Write to file error");
	
}

-(NSDictionary *)getDictionaryByKey:(NSString *)key{
    
    if (_indicatorParameterDictionaryNew) {
        NSString * newKey = [self getKey:key];
        return [_indicatorParameterDictionaryNew objectForKey:newKey];
    }
    
    return nil;
}

-(NSString *)getKey:(NSString *)oldKey{
    if ([oldKey isEqualToString:@"MA_1"] || [oldKey isEqualToString:@"均價1"]) {
        return @"MA1";
    }else if ([oldKey isEqualToString:@"MA_2"] || [oldKey isEqualToString:@"均價2"]){
        return @"MA2";
    }else if ([oldKey isEqualToString:@"MA_3"] || [oldKey isEqualToString:@"均價3"]){
        return @"MA3";
    }else if ([oldKey isEqualToString:@"MA_4"] || [oldKey isEqualToString:@"均價4"]){
        return @"MA4";
    }else if ([oldKey isEqualToString:@"MA_5"] || [oldKey isEqualToString:@"均價5"]){
        return @"MA5";
    }else if ([oldKey isEqualToString:@"MA_6"] || [oldKey isEqualToString:@"均價6"]){
        return @"MA6";
    }else if ([oldKey isEqualToString:@"MAV_1"] || [oldKey isEqualToString:@"均量1"]){
        return @"AV-S";
    }else if ([oldKey isEqualToString:@"MAV_2"] || [oldKey isEqualToString:@"均量2"]){
        return @"AV-L";
    }else if ([oldKey isEqualToString:@"RSI_1"]){
        return @"RSI-1";
    }else if ([oldKey isEqualToString:@"RSI_2"]){
        return @"RSI-2";
    }else if ([oldKey isEqualToString:@"EMA_1"]){
        return @"EMA-1";
    }else if ([oldKey isEqualToString:@"EMA_2"]){
        return @"EMA-2";
    }else if ([oldKey isEqualToString:@"Swing"] || [oldKey isEqualToString:@"震盪量"]){
        return @"OSC";
    }else if ([oldKey isEqualToString:@"通道"]){
        return @"BB";
    }else if ([oldKey isEqualToString:@"標準差"]){
        return @"SD";
    }else if ([oldKey isEqualToString:@"乖離率"]){
        return @"BIAS";
    }else if ([oldKey isEqualToString:@"能量潮"]){
        return @"OBV";
    }else if ([oldKey isEqualToString:@"心理線"]){
        return @"PSY";
    }else if ([oldKey isEqualToString:@"威廉"]){
        return @"W%R";
    }else if ([oldKey isEqualToString:@"動量"]){
        return @"MTM";
    }else{
        return oldKey;
    }
}

-(void)changeValueByKey:(NSString *)key Type:(NSString *)type Value:(NSNumber *)value{
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    dictionary = [_indicatorParameterDictionaryNew objectForKey:[self getKey:key]];
    [dictionary setObject:value forKey:type];
    
    [_indicatorParameterDictionaryNew setObject:dictionary forKey:[self getKey:key]];
    
    [self writeNewIndicatorParameterTable];
}

-(void)addKeyArrayWithArray:(NSMutableArray *)array
{
	if(self.keyArray) [self.keyArray removeAllObjects];
	else self.keyArray = [[NSMutableArray alloc] init];
    
    self.keyArray = array;

}

-(void)setKeyArray
{
    
    NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *fileName = @"IndicatorParameterUrlTable.plist";
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	   
	if(!self.keyArray) {
    
        NSMutableDictionary * data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        self.keyArray = (NSMutableArray *)[data objectForKey:@"key"];
    }
}


- (void)writeIndicatorParameterUrlTableWithDictionary:(NSMutableDictionary *)dictionary
{
	
	[indicatorLock lock];
	
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *fileName = @"IndicatorParameterUrlTable.plist";
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	BOOL success = [dictionary writeToFile:path atomically:YES];
	
	[indicatorLock unlock];
	
	if(!success) NSLog(@"IndicatorParameterUrlTable Write to file error");
	
}

- (NSMutableDictionary *)readIndicatorParameterUrlTable
{
	[indicatorLock lock];
	
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *fileName = @"IndicatorParameterUrlTable.plist";
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
    [indicatorLock unlock];
	
    return returnDictionary;
    
}

-(NSString *)getTimeFromIndicatorParameterUrlTable{
    NSMutableDictionary * dic = [self readIndicatorParameterUrlTable];
    NSString * time = [dic objectForKey:@"Time"];
    if (time) {
        return time;
    }
    
    return @"2010-01-01T00:00:00";
}

- (NSMutableDictionary *)readNewIndicatorParameterByAnalysisType:(AnalysisType)analysisType{
	
	NSMutableDictionary *parameterDictionary;
	
	[indicatorLock lock];
	
	switch (analysisType) {
		case AnalysisTypeVOL:
			indicatorParameter1 = -1;
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeRSI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"RSI"] objectForKey:@"rsiParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeKD:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KD"] objectForKey:@"kdParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KD"] objectForKey:@"kExponentialSmoothing"]intValue];
			indicatorParameter3 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KD"] objectForKey:@"dExponentialSmoothing"]intValue];
			break;
		case AnalysisTypeMACD:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MACD"] objectForKey:@"shortEMAParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MACD"] objectForKey:@"longEMAParameter"]intValue];
			indicatorParameter3 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MACD"] objectForKey:@"macdParameter"]intValue];
			break;
		case AnalysisTypeBias:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"Bias"] objectForKey:@"biasParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeOBV:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"OBV"] objectForKey:@"obvParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypePSY:
			_dayParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"PSY"] objectForKey:@"dayLine"]intValue];
			_weekParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"PSY"] objectForKey:@"weekLine"]intValue];
            _monthParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"PSY"] objectForKey:@"monthLine"]intValue];
            _minuteParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"PSY"] objectForKey:@"minuteLine"]intValue];
			break;
		case AnalysisTypeWR:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"WR"] objectForKey:@"williamsParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeMTM:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"MTM"] objectForKey:@"mtmParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeOSC:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"OSC"] objectForKey:@"oscParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeARBR:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"ARBR"] objectForKey:@"arParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"ARBR"] objectForKey:@"brParameter"]intValue];
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeDMI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"DMI"] objectForKey:@"dmiParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeTower:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"Tower"] objectForKey:@"towerParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeKDJ:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KDJ"] objectForKey:@"kdParameter"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KDJ"] objectForKey:@"kExponentialSmoothing"]intValue];
			indicatorParameter3 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"KDJ"] objectForKey:@"dExponentialSmoothing"]intValue];
			break;
		case AnalysisTypeCCI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"CCI"] objectForKey:@"cciParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
		case AnalysisTypeVR:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"VR"] objectForKey:@"vrParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			break;
        case AnalysisTypeMA1:
			_dayParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA1"] objectForKey:@"dayLine"]intValue];
			_weekParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA1"] objectForKey:@"weekLine"]intValue];
            _monthParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA1"] objectForKey:@"monthLine"]intValue];
            _minuteParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA1"] objectForKey:@"minuteLine"]intValue];
			break;
        case AnalysisTypeMA2:
			_dayParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA2"] objectForKey:@"dayLine"]intValue];
			_weekParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA2"] objectForKey:@"weekLine"]intValue];
            _monthParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA2"] objectForKey:@"monthLine"]intValue];
            _minuteParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA2"] objectForKey:@"minuteLine"]intValue];
			break;
        case AnalysisTypeMA3:
			_dayParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA3"] objectForKey:@"dayLine"]intValue];
			_weekParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA3"] objectForKey:@"weekLine"]intValue];
            _monthParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA3"] objectForKey:@"monthLine"]intValue];
            _minuteParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA3"] objectForKey:@"minuteLine"]intValue];
			break;
        case AnalysisTypeMA4:
			_dayParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA4"] objectForKey:@"dayLine"]intValue];
			_weekParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA4"] objectForKey:@"weekLine"]intValue];
            _monthParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA4"] objectForKey:@"monthLine"]intValue];
            _minuteParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA4"] objectForKey:@"minuteLine"]intValue];
			break;
        case AnalysisTypeMA5:
			_dayParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA5"] objectForKey:@"dayLine"]intValue];
			_weekParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA5"] objectForKey:@"weekLine"]intValue];
            _monthParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA5"] objectForKey:@"monthLine"]intValue];
            _minuteParameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA5"] objectForKey:@"minuteLine"]intValue];
			break;
        case AnalysisTypeBB:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"BB"] objectForKey:@"bbNumber"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"BB"] objectForKey:@"devNumber"]intValue];
			indicatorParameter3 = -1;
			break;
			
		default:
			break;
			
	}
	
	parameterDictionary = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
						   [NSNumber numberWithInt:_dayParameter],@"dayParameter",
						   [NSNumber numberWithInt:_weekParameter],@"weekParameter",
	                       [NSNumber numberWithInt:_monthParameter],@"monthParameter",
	                       [NSNumber numberWithInt:_minuteParameter],@"minuteParameter",nil];
	
	
	[indicatorLock unlock];
	
	return parameterDictionary;
	
}

- (NSMutableDictionary *)readNewIndicatorParameterByPeriod:(NSString *)period{
    NSMutableDictionary *parameterDictionary;
	
	[indicatorLock lock];
    
    _ARparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"AR"] objectForKey:period]intValue];
    _AVLparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"AV-L"] objectForKey:period]intValue];
    _AVSparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"AV-S"] objectForKey:period]intValue];
    _BBparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"BB"] objectForKey:period]intValue];
    _BIASparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"BIAS"] objectForKey:period]intValue];
    _BRparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"BR"] objectForKey:period]intValue];
    _DMIparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"DMI"] objectForKey:period]intValue];
    _EMA1parameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"EMA-1"] objectForKey:period]intValue];
    _EMA2parameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"EMA-2"] objectForKey:period]intValue];
    _KDparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"KD"] objectForKey:period]intValue];
    _MA1parameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA1"] objectForKey:period]intValue];
    _MA2parameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA2"] objectForKey:period]intValue];
    _MA3parameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA3"] objectForKey:period]intValue];
    _MA4parameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA4"] objectForKey:period]intValue];
    _MA5parameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA5"] objectForKey:period]intValue];
    _MA6parameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MA6"] objectForKey:period]intValue];
    _MACDparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MACD"] objectForKey:period]intValue];
    _MTMparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MTM"] objectForKey:period]intValue];
    _OBVparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"OBV"] objectForKey:period]intValue];
    _OSCparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"OSC"] objectForKey:period]intValue];
    _PSYparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"PSY"] objectForKey:period]intValue];
    _RSI1parameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"RSI-1"] objectForKey:period]intValue];
    _RSI2parameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"RSI-2"] objectForKey:period]intValue];
    _SARparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"SAR"] objectForKey:period]intValue];
    _SDparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"SD"] objectForKey:period]intValue];
    _VRparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"VR"] objectForKey:period]intValue];
    _WRparameter = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"W%R"] objectForKey:period]intValue];
    parameterDictionary = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
						   [NSNumber numberWithInt:_ARparameter],@"ARparameter",
						   [NSNumber numberWithInt:_AVLparameter],@"AVLparameter",
	                       [NSNumber numberWithInt:_AVSparameter],@"AVSparameter",
	                       [NSNumber numberWithInt:_BBparameter],@"BBparameter",
                           [NSNumber numberWithInt:_BIASparameter],@"BIASparameter",
                           [NSNumber numberWithInt:_BRparameter],@"BRparameter",
                           [NSNumber numberWithInt:_DMIparameter],@"DMIparameter",
                           [NSNumber numberWithInt:_EMA1parameter],@"EMA1parameter",
                           [NSNumber numberWithInt:_EMA2parameter],@"EMA2parameter",
                           [NSNumber numberWithInt:_KDparameter],@"KDparameter",
                           [NSNumber numberWithInt:_MA1parameter],@"MA1parameter",
                           [NSNumber numberWithInt:_MA2parameter],@"MA2parameter",
                           [NSNumber numberWithInt:_MA3parameter],@"MA3parameter",
                           [NSNumber numberWithInt:_MA4parameter],@"MA4parameter",
                           [NSNumber numberWithInt:_MA5parameter],@"MA5parameter",
                           [NSNumber numberWithInt:_MA6parameter],@"MA6parameter",
                           [NSNumber numberWithInt:_MACDparameter],@"MACDparameter",
                           [NSNumber numberWithInt:_MTMparameter],@"MTMparameter",
                           [NSNumber numberWithInt:_OBVparameter],@"OBVparameter",
                           [NSNumber numberWithInt:_OSCparameter],@"OSCparameter",
                           [NSNumber numberWithInt:_PSYparameter],@"PSYparameter",
                           [NSNumber numberWithInt:_RSI1parameter],@"RSI1parameter",
                           [NSNumber numberWithInt:_RSI2parameter],@"RSI2parameter",
                           [NSNumber numberWithInt:_SARparameter],@"SARparameter",
                           [NSNumber numberWithInt:_SDparameter],@"SDparameter",
                           [NSNumber numberWithInt:_VRparameter],@"VRparameter",
                           [NSNumber numberWithInt:_WRparameter],@"WRparameter",nil];
	
	
	[indicatorLock unlock];
	
	return parameterDictionary;
}


- (NSString *)newIndicatorNameAndParameterByAnalysisType:(AnalysisType)type Period:(NSString *)period {
	
	NSString *titleString;
	
	[indicatorLock lock];
	
	switch (type) {
		case AnalysisTypeAVS:
            indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"AV-S"] objectForKey:period]intValue];

			titleString = [NSString stringWithFormat:@"%@%02d",NSLocalizedStringFromTable(@"Volume", @"Draw", @"Volume indicator"),indicatorParameter1];
			break;
        case AnalysisTypeAVL:
            indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"AV-L"] objectForKey:period]intValue];

			titleString = [NSString stringWithFormat:@"%@%02d",NSLocalizedStringFromTable(@"Volume", @"Draw", @"Volume indicator"),indicatorParameter1];
			break;
		case AnalysisTypeRSI1:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"RSI-1"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%@%02d",NSLocalizedStringFromTable(@"RSI", @"Draw", @"RSI indicator"),indicatorParameter1];
			break;
        case AnalysisTypeRSI2:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"RSI-2"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%@%02d",NSLocalizedStringFromTable(@"RSI", @"Draw", @"RSI indicator"),indicatorParameter1];
			break;
		case AnalysisTypeKDJ:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"KD"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%d",indicatorParameter1];
			
			break;
		case AnalysisTypeMACD:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MACD"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%d",
							indicatorParameter1];
			
			break;
		case AnalysisTypeBias:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"BIAS"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%@%d", @"BIAS",indicatorParameter1];
			
			break;
		case AnalysisTypeOBV:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"OBV"] objectForKey:period]intValue];

			titleString =  [NSString stringWithFormat:@"%@%d",@"OBV",indicatorParameter1];
			break;
		case AnalysisTypePSY:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"PSY"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%@%02d", @"PSY",indicatorParameter1];
			break;
		case AnalysisTypeWR:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"W%R"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%@%02d",@"W%R",indicatorParameter1];
			break;
		case AnalysisTypeMTM:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"MTM"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%d",indicatorParameter1];
			break;
		case AnalysisTypeOSC:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"OSC"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%d",indicatorParameter1];
			break;
		case AnalysisTypeAR:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"AR"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%d",indicatorParameter1];
			break;
        case AnalysisTypeBR:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"BR"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%d",indicatorParameter1];
			break;
		case AnalysisTypeDMI:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"DMI"] objectForKey:period]intValue];

			titleString =  [NSString stringWithFormat:@"%d",indicatorParameter1];
			break;
		case AnalysisTypeTower://VR
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"VR"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%@%02d",NSLocalizedStringFromTable(@"VR", @"Draw", @"VR indicator"),indicatorParameter1];
			break;
		case AnalysisTypeCCI:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"CCI"] objectForKey:@"cciParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",NSLocalizedStringFromTable(@"CCI", @"Draw", @"CCI indicator"),indicatorParameter1];
			break;
		case AnalysisTypeVR:
			indicatorParameter1 = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:@"VR"] objectForKey:period]intValue];
			titleString =  [NSString stringWithFormat:@"%@%02d",NSLocalizedStringFromTable(@"VR", @"Draw", @"VR indicator"),indicatorParameter1];
			break;
		case AnalysisTypeShortMA: //alarm use
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"shortMA"] objectForKey:@"maParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",NSLocalizedStringFromTable(@"Moving Average",@"Draw",@"indicator"),indicatorParameter1];
            
			break;
		case AnalysisTypeMiddleMA: //alarm use
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"middleMA"] objectForKey:@"maParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",NSLocalizedStringFromTable(@"Moving Average",@"Draw",@"indicator"),indicatorParameter1];
			
			break;
		case AnalysisTypeLongMA: //alarm use
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"longMA"] objectForKey:@"maParameter"]intValue];
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d)",NSLocalizedStringFromTable(@"Moving Average",@"Draw",@"indicator"),indicatorParameter1];
			
			break;
		case AnalysisTypeBB:
			indicatorParameter1 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"BB"] objectForKey:@"bbNumber"]intValue];
			indicatorParameter2 = [(NSNumber *)[[indicatorParameterDictionary objectForKey:@"BB"] objectForKey:@"devNumber"]intValue];
			indicatorParameter3 = -1;
			titleString =  [NSString stringWithFormat:@"%@(%d, %d)",NSLocalizedStringFromTable(@"Bollinger Bands", @"Draw", @"BB"),
							indicatorParameter1,indicatorParameter2];
			break;
		default:
			indicatorParameter1 = -1;
			indicatorParameter2 = -1;
			indicatorParameter3 = -1;
			titleString =  @"";
			break;
			
			
	}
	
	[indicatorLock unlock];
	
	return titleString;
	
	
}

-(int)getValueInNewIndicatorByParameter:(NSString *)parameter Period:(NSString *)period{
    int value = 0;
    
    value = [(NSNumber *)[[_indicatorParameterDictionaryNew objectForKey:parameter]objectForKey:period]intValue];
    
    return value;
}

-(void)loginNotify{
    IndicatorParameterUrlCenter * urlCenter = [IndicatorParameterUrlCenter sharedInstance];
    [urlCenter IndicatorParameterUrlUpWithTime:[self getTimeFromIndicatorParameterUrlTable]];
}


@end
