//
//  OscillatorView.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/5.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "OscillatorView.h"
#import "DrawAndScrollController.h"
#import "BottomDataView.h"


//#define oscParameter 10


@implementation OscillatorView

@synthesize drawAndScrollController;
@synthesize bottonView;
@synthesize historicData;
@synthesize chartFrame;
@synthesize xLines;
@synthesize yLines;
@synthesize zoomTransform;
@synthesize maxValue;
@synthesize minValue;


- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        chartFrame = frame;
        chartFrameOffset = offset;
		oscValues = [[NSMutableArray alloc] init];
		sumValues = [[NSMutableArray alloc] init];
		
    }
    return self;
}


- (float)getOscValue:(UInt8)type sequence:(int)index {

    DecompressedHistoricData *historic = [historicData copyHistoricTick:type sequenceNo:index-oscParameter];
    double v = historic.close;

    historic = [historicData copyHistoricTick:type sequenceNo:index];
    v = v ? historic.close / v : 0;

    return v;
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
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeOSC];
    NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	oscParameter = [(NSNumber *)[parmDict1 objectForKey:@"OSCparameter"]intValue];
	

    float chartWidth = chartFrame.size.width;
    float chartHeight = chartFrame.size.height;

    [drawAndScrollController drawBottomChartFrameWithOffset:chartFrameOffset frameWidth:chartWidth frameHeight:chartHeight];

    UInt8 type = drawAndScrollController.historicType;
    UInt32 dataCount = [historicData tickCount:type];
    if (dataCount == 0) return;

    BOOL isDayLine = drawAndScrollController.analysisPeriod == AnalysisPeriodDay;

    int frontIndex, rearIndex, seq;

    [drawAndScrollController drawChartFrameYScaleWithChartOffset:CGPointMake(0, 1) frameWidth:chartWidth frameHeight:chartHeight yLines:yLines lineIncrement:2];

    if (isDayLine) {

        frontIndex = 0;
        rearIndex = dataCount - 1;
		
        //畫直線(週線暫不畫,需再調整)		
        //[drawAndScrollController drawChartFrameXScaleWithChartOffset:chartFrameOffset frameWidth:chartWidth frameHeight:chartHeight xLines:xLines xScaleType:2];
        [drawAndScrollController drawMonthLineWithChartFrame:chartFrame xLines:xLines offsetStartPoint:chartFrameOffset];
    }
    else {

        frontIndex = 0;
        rearIndex = dataCount - 1;

        [drawAndScrollController drawDateGridWithChartFrame:chartFrame xLines:xLines offsetStartPoint:chartFrameOffset];
    }
    
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
    
    
    dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
    NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];

    float osc;
    float sum = 0,ma=0;
    maxValue = 0;
    minValue = MAXFLOAT;

    for (NSUInteger i = dataStartIndex; i < dataEndIndex; i++) {
        if (i >= oscParameter){
            osc = [self getOscValue:type sequence:(int)i];
            if (maxValue < osc) maxValue = osc;
            if (minValue > osc){
                minValue = osc;
            }
        }
    }
    
    
    for (NSUInteger i = dataStartIndex; i < dataEndIndex; i++) {
        if (i >= oscParameter+oscParameter){
            sum=0;
            for (int j=9; j>=0; j--) {
                osc = [self getOscValue:type sequence:(int)i-j];
                sum += osc;
                
            }
//            sum -= [self getOscValue:type sequence:i-oscParameter];
            ma = sum / oscParameter;
            if (maxValue < ma) maxValue = ma;
            if (minValue > ma){
                minValue = ma;
            }
        }
    }

    [bottonView.dataView setNeedsDisplay];

    if (minValue == MAXFLOAT || maxValue == 0) {
        minValue = 0;
        return;
    }

    float amp = maxValue - minValue;
    if (amp == 0) return;

    float x, y;
    sum = 0;
    BOOL first = TRUE;
    BOOL avgFirst = TRUE;

    float xScale = chartWidth / xLines;
    float yScale = chartHeight / amp;
    float x0 = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
    float y0 = chartFrameOffset.y + chartHeight;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);

    CGMutablePathRef path = CGPathCreateMutable();
    CGMutablePathRef avgPath = CGPathCreateMutable();

	[oscValues removeAllObjects];
	[sumValues removeAllObjects];
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {

        seq = (int)i;

        if (seq >= oscParameter) {

            osc = [self getOscValue:type sequence:seq];
//            sum += osc;

            x = x0 + i * xScale;
			y = y0 - (osc - minValue) * yScale;

            if (first) {
                CGPathMoveToPoint(path, NULL, x, y);
                first = FALSE;
            }

            CGPathAddLineToPoint(path, NULL, x, y);

        }
		[oscValues addObject:[NSNumber numberWithDouble:osc]];
		
        seq++;
    }
    
    for (NSUInteger i = dataStartIndex-oscParameter; i <= dataEndIndex; i++) {
        osc = [self getOscValue:type sequence:(int)i];
        sum += osc;
        if (i>dataStartIndex-1 && i>oscParameter + oscParameter-1) {
            x = x0 + i * xScale;
            sum -= [self getOscValue:type sequence:(int)i-oscParameter];
            y = y0 - (sum / oscParameter - minValue) * yScale;
                
            if (avgFirst) {
                CGPathMoveToPoint(avgPath, NULL, x, y);
                    avgFirst = FALSE;
            }
                
            CGPathAddLineToPoint(avgPath, NULL, x, y);
            

        }
        if (i>oscParameter + oscParameter-1) {
            [sumValues addObject:[NSNumber numberWithDouble:sum]];
        }
        
    }

    [[UIColor magentaColor] set];
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);

    [[UIColor colorWithRed:0.45 green:0.65 blue:1 alpha:0.8] set];
    //[[UIColor colorWithRed:0.5 green:0.7 blue:1 alpha:1] set];
    //CGFloat dash[] = { 2, 1 };
    //CGContextSetLineDash(context, 0, dash, 2);
    CGContextAddPath(context, avgPath);
    CGContextStrokePath(context);
    CGPathRelease(avgPath);
    //CGContextSetLineDash(context, 0, NULL, 0);

    if (!CGAffineTransformIsIdentity(zoomTransform)) {
        self.transform = zoomTransform;
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        zoomTransform = CGAffineTransformIdentity;
    }
    
    //設定預設數值
    [drawAndScrollController setDefaultValue];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [bottonView doTouchesBegan:touches withEvent:event];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [bottonView doTouchesEnded:touches withEvent:event];
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

#pragma mark -
#pragma mark 抓技術分析的值

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3;
{
//	double sum = 0,osc = 0;
//	if(index < [oscValues count] && index >= oscParameter)
//	{
//		sum = ([[sumValues objectAtIndex:index] doubleValue] / oscParameter)  * 100;
//		osc = [[oscValues objectAtIndex:index] doubleValue] * 100;
//	}
//	*value1 = sum;
//	*value2 = osc;
//	*value3 = 0;
}

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3 Value4:(double *)value4
{
	double sum = -0,osc = -0,beforeSum = -0,beforeOSC = -0;
    index-=dataStartIndex;
	if(index < [oscValues count])
	{
		osc = [(NSNumber *)[oscValues objectAtIndex:index] doubleValue] * 100;
        if (index>oscParameter) {
            beforeOSC = [(NSNumber *)[oscValues objectAtIndex:index-1] doubleValue] * 100;

        }
    }
    index+=10;
    if (index<[sumValues count]) {
        sum = ([(NSNumber *)[sumValues objectAtIndex:index] doubleValue] / oscParameter)  * 100;
        if (index>0) {
            beforeSum = ([(NSNumber *)[sumValues objectAtIndex:index-1] doubleValue] / oscParameter)  * 100;
        }
    }
    
	*value1 = osc ;
	*value2 = sum;
	*value3 = beforeOSC;
    *value4 = beforeSum;
}

@end
