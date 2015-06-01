//
//  MACDView.m
//  BullsEyeAlpha
//
//  Created by Ming-Zhe Wu on 2008/10/13.
//  Copyright 2008 NHCUE. All rights reserved.
//

#import "MACDView.h"
#import "DrawAndScrollController.h"
#import "BottonView.h"
#import "BottomDataView.h"


//#define shortEMAParameter 12 
//#define longEMAParameter 26

//static float dNumber[200];
 
static float xScale,yScale;


static float xSize;
static float ySize;


@implementation MACDView

@synthesize drawAndScrollController;
@synthesize bottonView;

@synthesize historicData;

@synthesize chartFrame;
@synthesize chartFrameOffset;

@synthesize xLines,yLines;
@synthesize maxValue;
@synthesize zoomTransform;

@synthesize diffEMA,macd;


- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset{
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		
		chartFrame = frame;
		chartFrameOffset = offset;
		
		diffEMA = [[NSMutableArray alloc] init];
		macd = [[NSMutableArray alloc] init];
		
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect {
    NSString * period;
    chartFrameOffset = drawAndScrollController.chartFrameOffset;
    
    if (drawAndScrollController.analysisPeriod==AnalysisPeriodDay) {
        period = @"dayLine";
    }else if (drawAndScrollController.analysisPeriod==AnalysisPeriodWeek){
        period = @"weekLine";
    }else if (drawAndScrollController.analysisPeriod==AnalysisPeriodMonth){
        period = @"monthLine";
    }else {
        period = @"minuteLine";
    }
   
	
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeMACD];
     NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	shortEMAParameter = [(NSNumber *)[parmDict1 objectForKey:@"EMA1parameter"]intValue];
	longEMAParameter = [(NSNumber *)[parmDict1 objectForKey:@"EMA2parameter"]intValue];
	macdParameter = [(NSNumber *)[parmDict1 objectForKey:@"MACDparameter"]intValue];
	
	
    xSize = chartFrame.size.width;
    ySize = chartFrame.size.height;

    //畫chart frame邊框
    [drawAndScrollController drawBottomChartFrameWithOffset:chartFrameOffset frameWidth:xSize frameHeight:ySize];

    UInt8 type = drawAndScrollController.historicType;
    UInt32 dataCount = [historicData tickCount:type];
    if (dataCount == 0) return;

    BOOL isDayLine = drawAndScrollController.analysisPeriod == AnalysisPeriodDay;

    NSInteger offsetXvalue = chartFrameOffset.x;
    NSInteger offsetYvalue = chartFrameOffset.y;

    xScale = xSize / xLines;
    yScale = ySize / yLines;

#pragma mark ---------------------------------------------------------------- 畫邊框 與 ＸＹ軸刻度線

    //畫橫線
    [drawAndScrollController drawChartFrameYScaleWithChartOffset:CGPointMake(0, 1) frameWidth:xSize frameHeight:ySize yLines:yLines lineIncrement:2];

    //畫直線
    if (isDayLine) {
        //畫直線(週線暫不畫,需再調整)		
        //[drawAndScrollController drawChartFrameXScaleWithChartOffset:chartFrameOffset frameWidth:xSize frameHeight:ySize xLines:xLines xScaleType:2];
        [drawAndScrollController drawMonthLineWithChartFrame:chartFrame xLines:xLines offsetStartPoint:chartFrameOffset];
    }
    else {
        [drawAndScrollController drawDateGridWithChartFrame:chartFrame xLines:xLines offsetStartPoint:chartFrameOffset];
    }

#pragma mark ---------------------------------------------------------------- 畫 MACD Data線

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGMutablePathRef pathDiff = CGPathCreateMutable();
    CGMutablePathRef pathMACD = CGPathCreateMutable();

    CGContextBeginPath (context);

    int emaDayStart = fmax(shortEMAParameter, longEMAParameter)-1;
    int macdDayStart = emaDayStart + macdParameter-1;

    self.diffEMA = [self diffEMAWithDataRange:dataCount emaParameter1:shortEMAParameter emaParameter2:longEMAParameter];
    self.macd = [self macdWithGivenArray:diffEMA hDays:macdParameter emaParameter:emaDayStart];

// 找出最大值
    //DecompressedHistoricData *historic;
    //UInt16 dt, startDate, endDate;
    float xSize;
    if (drawAndScrollController.penBtn.selected == YES) {
        xSize = drawAndScrollController.indexScaleView.frame.size.width;
    }else{
        xSize = drawAndScrollController.indexScaleView.frame.size.width-chartFrameOffset.x;
    }
    float ySize = drawAndScrollController.indexScaleView.frame.size.height;
    ySize -=1;
    float winLocationX;
    if(xSize<273)
        winLocationX = 0;
    else
        winLocationX = drawAndScrollController.indexScaleView.frame.origin.x;
    
    
    NSInteger dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
    NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
    
    float d, m, v;
//    int count = diffEMA.count;

    maxValue = 0;

    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {

        if (i >= emaDayStart) {
            d = fabsf([(NSNumber *)[diffEMA objectAtIndex:i] floatValue]);
            if (maxValue < d) maxValue = d;
        }

        if (i >= macdDayStart) {
            m = fabsf([(NSNumber *)[macd objectAtIndex:i] floatValue]);
            if (maxValue < m) maxValue = m;

            v = fabsf(d - m);
            if (maxValue < v) maxValue = v;
        }
    }

    [bottonView.dataView setNeedsDisplay];

    int fontSLIindex;
    int rearSLIindex;
    int seq;

	fontSLIindex = 0;
	rearSLIindex = dataCount - 1;
    
    xSize = chartFrame.size.width;
    ySize = chartFrame.size.height;


    float amp = ySize / 2 - 0.2;
    float y0 = ySize / 2 + offsetYvalue;

    float diff_yValue, macd_yValue;

    BOOL firstEma = TRUE;
    BOOL firstMacd = TRUE;
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {

        seq = (int)i;
		
        // x軸座標值：
        float xValue = i * xScale;
		
		// diff y軸座標值：
        if (seq >= emaDayStart) {
            diff_yValue = [(NSNumber *)[diffEMA objectAtIndex:seq] floatValue] * amp / maxValue;
            if (firstEma) {
                CGPathMoveToPoint(pathDiff, NULL, offsetXvalue + xValue, y0 - diff_yValue);
                firstEma = FALSE;
            }
            CGPathAddLineToPoint(pathDiff, NULL, xValue + offsetXvalue, y0 - diff_yValue);
        }

        // macd y軸座標值：
        if (seq >= macdDayStart) {
            macd_yValue = [(NSNumber *)[macd objectAtIndex:seq] floatValue] * amp / maxValue;
            if (firstMacd) {
                CGPathMoveToPoint(pathMACD, NULL, offsetXvalue + xValue, y0 - macd_yValue);
                firstMacd = FALSE;
            }
            CGPathAddLineToPoint(pathMACD, NULL, xValue + offsetXvalue, y0 - macd_yValue);
        }

        seq++;
    }

    //diff path
    CGContextAddPath(context,pathDiff);
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor magentaColor]set];
    CGContextStrokePath(context);
    CGPathRelease(pathDiff);

    //macd path
    CGContextAddPath(context,pathMACD);
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1]set];
    CGContextStrokePath(context);
    CGPathRelease(pathMACD);

#pragma mark ---------------------------------------------------------------- 畫 DIF 減去 MACD後的柱形圖(BAR)

    //float rectWidth = floor(xScale)/1.75;
    float rectWidth = drawAndScrollController.chartBarWidth;
    float longRectWidth = rectWidth;
    float subValue;

    for (int i = fontSLIindex; i <= rearSLIindex; i++) {


        seq = i;


        if (seq >= macdDayStart) {

            subValue = [(NSNumber *)[diffEMA objectAtIndex:seq] floatValue] - [(NSNumber *)[macd objectAtIndex:seq] floatValue];

            longRectWidth = rectWidth;

            float xValue = i * xScale;
			
			subValue = subValue * amp / maxValue;

            if (subValue == 0) {
                // 不畫
            }
            else if (subValue > 0) { // subValue為正數

                CGRect longRect = CGRectMake(xValue + offsetXvalue, y0 - subValue, longRectWidth, subValue);
                CGContextAddRect(context, longRect);
                [[UIColor orangeColor] set];
                CGContextFillPath(context);
            }
            else { // subValue 是負數

                CGRect longRect = CGRectMake(xValue + offsetXvalue, y0, longRectWidth, -subValue);
                CGContextAddRect(context, longRect);
                [[UIColor colorWithRed:122.0f/255.0f green:142.0f/255.0f blue:190.0f/255.0f alpha:1.0f] set];
                CGContextFillPath(context);
            }
        }

        seq++;
    }

    if (!CGAffineTransformIsIdentity(zoomTransform)) {
        self.transform = zoomTransform;
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        zoomTransform = CGAffineTransformIdentity;
    }
    
    //設定預設數值
    [drawAndScrollController setDefaultValue];
}


-(int)getSeqNumberFromPointXValue:(float)x
{
	
	UInt8 type = self.drawAndScrollController.historicType;
    UInt32 histCount = [historicData tickCount:type];
    if (histCount == 0) return -1;
	
    float xScale = drawAndScrollController.barDateWidth;
    int x0 =0;// offsetX;
    int n = x > x0 ? (x - x0) / xScale : 0;
	
    if (n >= histCount)
		n = histCount - 1;
    
	return n;
}



-(NSMutableArray *)diffEMAWithDataRange:(int)totalDayCnt emaParameter1:(int)p1 emaParameter2:(int)p2{

	// En_t = En_[t-1] + 2/(1 + n) * (P_t – En_[t-1])
	// 即 En_t 為 P_t的 n 天exponential moving average(EMA)
    //int emaShortPvalue = fmin(p1, p2);
	int emaLongPvalue = fmax(p1, p2);	
	
	int daysThreshold = emaLongPvalue;

	NSMutableArray *shortEMAValueArray = [[NSMutableArray alloc]init];
	NSMutableArray *longEMAValueArray = [[NSMutableArray alloc]init];	
	NSMutableArray *diffEMAvalueArray = [[NSMutableArray alloc]init];	
	
	float shortEMAvalue;
	float longEMAvalue;

    float di;

    UInt8 type = drawAndScrollController.historicType;
    UInt32 count = [historicData tickCount:type];

    for (int i = 0; i < count; i++) {

        di = [self demandIndexOnGivenDataIndex:i type:type];

        // short EMA
        if (i < p1) {
            shortEMAvalue = (i == 0 ? -0 : [(NSNumber *)[shortEMAValueArray objectAtIndex:i-1] floatValue]) + di;
            if (i == p1 - 1)
                shortEMAvalue /= p1;
        }
        else {
            shortEMAvalue = ([(NSNumber *)[shortEMAValueArray objectAtIndex:i-1] floatValue] * (p1 - 2) + di * 2) / p1;
        }
        [shortEMAValueArray insertObject:[NSNumber numberWithFloat:shortEMAvalue] atIndex:i];

        // long EMA
        if (i < p2) {
            longEMAvalue = (i == 0 ? -0 : [(NSNumber *)[longEMAValueArray objectAtIndex:i-1] floatValue]) + di;
            if (i == p2 - 1)
                longEMAvalue /= p2;
        }
        else {
            longEMAvalue = ([(NSNumber *)[longEMAValueArray objectAtIndex:i-1] floatValue] * (p2 - 2) + di * 2) / p2;
        }
        [longEMAValueArray insertObject:[NSNumber numberWithFloat:longEMAvalue] atIndex:i];

        // diff EMA
        if (i < daysThreshold-1)
            [diffEMAvalueArray addObject:[NSNumber numberWithFloat:-0.0f]];
        else
            [diffEMAvalueArray addObject:[NSNumber numberWithFloat:(shortEMAvalue - longEMAvalue)]];
    }

	return diffEMAvalueArray;

	
}


- (NSMutableArray *)macdWithGivenArray:(NSMutableArray *)emaArray hDays:(int)days emaParameter:(int)emaParameter {

	NSMutableArray *macdArray = [[NSMutableArray alloc]init];
	
    int count = (int)emaArray.count;
    int n = days + emaParameter;
    float ema, macdV;

    for (int i = 0; i < count; i++) {

        ema = [(NSNumber *)[emaArray objectAtIndex:i] floatValue];

        if (i < n) {
            macdV = (i == 0 ? -0 : [(NSNumber *)[macdArray objectAtIndex:i-1] floatValue]) + ema;
            if (i == n - 1)
                macdV /= days;
        }
        else {
            macdV = ([(NSNumber *)[macdArray objectAtIndex:i-1] floatValue] * (days - 1) + ema * 2) / (days + 1);
        }

        [macdArray addObject:[NSNumber numberWithFloat:macdV]];
    }

	return macdArray;


}


// 計算 Demand Index 價格需求指數
- (float)demandIndexOnGivenDataIndex:(int)dataIndex type:(UInt8)type {

    DecompressedHistoricData *historic = [historicData copyHistoricTick:type sequenceNo:dataIndex];
    float high_t = historic.high;
    float low_t = historic.low;
    float close_t = historic.close;

	//Demand Index 價格需求指數
	float demandIndexValue = (float)(high_t + low_t + 2*close_t)/4;
	
	return demandIndexValue; 
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [bottonView doTouchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [bottonView doTouchesEnded:touches withEvent:event];
}


#pragma mark -
#pragma mark 抓技術分析的值

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3;
{
//	double diffValue = 0,macdValue = 0;
//	if(index < [diffEMA count])
//	{
//		diffValue = [[diffEMA objectAtIndex:index] floatValue];
//		macdValue = [[macd objectAtIndex:index] floatValue];
//	}
//	*value1 = diffValue;
//	*value2 = macdValue;
//	*value3 = 0;
}

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3 Value4:(double *)value4
{
	double diffValue = -0,macdValue = -0,diffBeforeValue = -0,macdBeforeValue = -0;
    int parameter = MAX(shortEMAParameter, longEMAParameter)-1;
	if(index < [diffEMA count] && index>=parameter)
	{
		diffValue = [(NSNumber *)[diffEMA objectAtIndex:index] floatValue];
        diffBeforeValue = [(NSNumber *)[diffEMA objectAtIndex:index-1] floatValue];
	}
    
    if (index<[macd count] && index >=parameter+macdParameter-1) {
        macdValue = [(NSNumber *)[macd objectAtIndex:index] floatValue];
        if (index !=parameter+macdParameter-1) {
            macdBeforeValue = [(NSNumber *)[macd objectAtIndex:index-1] floatValue];
        }
    }
	*value1 = diffValue;
	*value2 = macdValue;
	*value3 = diffBeforeValue;
    *value4 = macdBeforeValue;
}



@end
	
	
