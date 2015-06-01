//
//  DMIView.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/6.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "DMIView.h"
#import "DrawAndScrollController.h"


//#define dmiParameter 14


@implementation DMIView

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
        plusValues = [[NSMutableArray alloc] init];
        minusValues = [[NSMutableArray alloc] init];
        adxValues = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    NSString * period;
    chartFrameOffset = drawAndScrollController.chartFrameOffset;
    
    if (drawAndScrollController.analysisPeriod==AnalysisPeriodDay) {
        type = 'D';
        period = @"dayLine";
    }else if (drawAndScrollController.analysisPeriod==AnalysisPeriodWeek){
        type = 'W';
        period = @"weekLine";
    }else if (drawAndScrollController.analysisPeriod==AnalysisPeriodMonth){
        type = 'M';
        period = @"monthLine";
    }else if (self.drawAndScrollController.analysisPeriod==AnalysisPeriod5Minute){
        type = '5';
        period = @"minuteLine";
    }else if (self.drawAndScrollController.analysisPeriod==AnalysisPeriod15Minute){
        type = 'F';
        period = @"minuteLine";
    }else if (self.drawAndScrollController.analysisPeriod==AnalysisPeriod30Minute){
        type = 'T';
        period = @"minuteLine";
    }else{
        type = 'S';
        period = @"minuteLine";
    }
	
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeDMI];
    NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	dmiParameter = [(NSNumber *)[parmDict1 objectForKey:@"DMIparameter"]intValue];
	

    float chartWidth = chartFrame.size.width;
    float chartHeight = chartFrame.size.height;

    [drawAndScrollController drawBottomChartFrameWithOffset:chartFrameOffset frameWidth:chartWidth frameHeight:chartHeight];

    UInt32 dataCount = [historicData tickCount:drawAndScrollController.historicType];
    if (dataCount == 0) return;

    BOOL isDayLine = drawAndScrollController.analysisPeriod == AnalysisPeriodDay;

    NSInteger frontIndex, rearIndex, seq;
	
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

    DecompressedHistoricData *historic;
    float v, high, low, high0, low0, close0, highDif, lowDif, plus, minus, tr, dx;
    float plusSum = 0, minusSum = 0, trSum = 0, dxSum = 0;
    float plusVal = 0, minusVal = 0, adxVal = 0;

    maxValue = 0;
    minValue = MAXFLOAT;

    [plusValues removeAllObjects];
    [minusValues removeAllObjects];
    [adxValues removeAllObjects];
    [plusValues addObject:[NSNumber numberWithFloat:0]];
    [minusValues addObject:[NSNumber numberWithFloat:0]];
    [adxValues addObject:[NSNumber numberWithFloat:0]];
    
    for (int i = 1; i < dataCount; i++) {
        
        historic = [self.historicData copyHistoricTick:type sequenceNo:i-1];
        high0 = historic.high;
        low0 = historic.low;
        close0 = historic.close;
        
        historic = [self.historicData copyHistoricTick:type sequenceNo:i];
        high = historic.high;
        low = historic.low;
        
        highDif = high - high0;
        lowDif = low0 - low;
        if (highDif < 0) highDif = 0;
        if (lowDif < 0) lowDif = 0;
        
        plus = minus = 0;
        if (highDif > lowDif)
            plus = highDif;
        else if (highDif < lowDif)
            minus = lowDif;
        else
            plus = minus = highDif;
        
        tr = fabsf(high - low);
        v = fabsf(high - close0);
        if (tr < v) tr = v;
        v = fabsf(low - close0);
        if (tr < v) tr = v;
        
        if (i <= dmiParameter-1) {
            plusSum += plus;
            minusSum += minus;
            trSum += tr;
        }
        else {
            plusSum = plusSum * (dmiParameter-1) / dmiParameter + plus;
            minusSum = minusSum * (dmiParameter-1) / dmiParameter + minus;
            trSum = trSum * (dmiParameter-1) / dmiParameter + tr;
            
            if (trSum > 0) {
                plusVal = plusSum / trSum;
                minusVal = minusSum / trSum;
            }
            else
                plusVal = minusVal = 0;
            
            v = plusVal + minusVal;
            dx = v ? fabsf(plusVal - minusVal) / v : 0;
            
            if (i <= dmiParameter+dmiParameter-2)
                dxSum += dx;
            else {
                dxSum = dxSum * (dmiParameter-1) / dmiParameter + dx;
                adxVal = dxSum / dmiParameter;
                
            }
        }
        
        [plusValues addObject:[NSNumber numberWithFloat:plusVal*100]];
        [minusValues addObject:[NSNumber numberWithFloat:minusVal*100]];
        [adxValues addObject:[NSNumber numberWithFloat:adxVal*100]];
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
    
    
    NSInteger dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
    NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
    
    maxValue = -MAXFLOAT;
    minValue = MAXFLOAT;
    
    for (NSInteger i = dataStartIndex; i <= dataEndIndex; i++) {
        float v = [(NSNumber *)[plusValues objectAtIndex:i]floatValue];
        if (maxValue < v) maxValue = v;
        if (minValue > v) minValue = v;
    }
    for (NSInteger i = dataStartIndex; i <= dataEndIndex; i++) {
        float v = [(NSNumber *)[minusValues objectAtIndex:i]floatValue];
        if (maxValue < v) maxValue = v;
        if (minValue > v) minValue = v;
    }
    for (NSInteger i = dataStartIndex; i <= dataEndIndex; i++) {
        float v = [(NSNumber *)[adxValues objectAtIndex:i]floatValue];
        if (maxValue < v) maxValue = v;
        if (minValue > v) minValue = v;
        
    }

//    [bottonView.dataView setNeedsDisplay];

    if (minValue == MAXFLOAT || maxValue == 0) {
        minValue = maxValue = 0;
        return;
    }

    float amp = maxValue - minValue;
    if (amp == 0) return;

    float x, y, y1;
    BOOL first = TRUE;
    BOOL firstAdx = TRUE;

    float xScale = chartWidth / xLines;
    float yScale = chartHeight / amp;
    float x0 = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
    float y0 = chartFrameOffset.y + chartHeight;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);

    CGMutablePathRef plusPath = CGPathCreateMutable();
    CGMutablePathRef minusPath = CGPathCreateMutable();
    CGMutablePathRef adxPath = CGPathCreateMutable();

    for (NSInteger i = dataStartIndex; i <= dataEndIndex; i++) {

        seq = i;

        x = x0 + i * xScale;
		
		if (seq >= dmiParameter) {

            y = y0 - ([(NSNumber *)[plusValues objectAtIndex:seq] floatValue] - minValue) * yScale;
            y1 = y0 - ([(NSNumber *)[minusValues objectAtIndex:seq] floatValue] - minValue) * yScale;

            if (first) {
                CGPathMoveToPoint(plusPath, NULL, x, y);
                CGPathMoveToPoint(minusPath, NULL, x, y1);
                first = FALSE;
            }

            CGPathAddLineToPoint(plusPath, NULL, x, y);
            CGPathAddLineToPoint(minusPath, NULL, x, y1);

            if (seq >= dmiParameter+dmiParameter-1) {

                y = y0 - ([(NSNumber *)[adxValues objectAtIndex:seq] floatValue] - minValue) * yScale;

                if (firstAdx) {
                    CGPathMoveToPoint(adxPath, NULL, x, y);
                    firstAdx = FALSE;
                }

                CGPathAddLineToPoint(adxPath, NULL, x, y);
            }
        }

        seq++;
    }

    //CGFloat dash[] = { 2, 0.7 };
    //CGContextSetLineDash(context, 0, dash, 2);
    //[[UIColor magentaColor] set];
    [[UIColor colorWithRed:1 green:0 blue:1 alpha:0.8] set];
    CGContextAddPath(context, plusPath);
    CGContextStrokePath(context);
    CGPathRelease(plusPath);

    [[UIColor colorWithRed:0.45 green:0.7 blue:1 alpha:0.8] set];
    //[[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1] set];
    CGContextAddPath(context, minusPath);
    CGContextStrokePath(context);
    CGPathRelease(minusPath);
    //CGContextSetLineDash(context, 0, NULL, 0);

    [[UIColor orangeColor] set];
    CGContextAddPath(context, adxPath);
    CGContextStrokePath(context);
    CGPathRelease(adxPath);

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
	
    UInt32 histCount = [historicData tickCount:self.drawAndScrollController.historicType];
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
//	double di1 = 0,di2 = 0,adx = 0;
//	if(index < [plusValues count])
//	{
//		di1 = [[plusValues objectAtIndex:index] doubleValue];
//		di2 = [[minusValues objectAtIndex:index] doubleValue];
//		adx = [[adxValues objectAtIndex:index] doubleValue];
//	}
//	*value1 = di1;
//	*value2 = di2;
//	*value3 = adx;
}

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3 Value4:(double *)value4 Value5:(double *)value5 Value6:(double *)value6
{
	double di1 = -0,di2 = -0,adx = -0,beforedi1 = -0,beforedi2 = -0,beforeadx = -0;
	if(index < [plusValues count] && index>=dmiParameter)
	{
		di1 = [(NSNumber *)[plusValues objectAtIndex:index] doubleValue];
		di2 = [(NSNumber *)[minusValues objectAtIndex:index] doubleValue];
        beforedi1 = [(NSNumber *)[plusValues objectAtIndex:index-1] doubleValue];
		beforedi2 = [(NSNumber *)[minusValues objectAtIndex:index-1] doubleValue];
	}
    
    if(index < [adxValues count] && index>=dmiParameter+dmiParameter-1)
	{
        adx = [(NSNumber *)[adxValues objectAtIndex:index] doubleValue];
        beforeadx = [(NSNumber *)[adxValues objectAtIndex:index-1] doubleValue];
    }
    
	*value1 = di1;
	*value2 = di2;
	*value3 = adx;
    *value4 = beforedi1;
	*value5 = beforedi2;
	*value6 = beforeadx;
}

@end
