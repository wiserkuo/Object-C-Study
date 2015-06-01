//
//  ARBRView.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/5.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "ARBRView.h"
#import "DrawAndScrollController.h"


//#define arParameter 26
//#define brParameter 26


@implementation ARBRView

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
        arValues = [[NSMutableArray alloc] init];
        brValues = [[NSMutableArray alloc] init];
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
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeARBR];
	NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	arParameter = [(NSNumber *)[parmDict1 objectForKey:@"ARparameter"]intValue];
	brParameter = [(NSNumber *)[parmDict1 objectForKey:@"BRparameter"]intValue];
	

    float chartWidth = chartFrame.size.width;
    float chartHeight = chartFrame.size.height;

    [drawAndScrollController drawBottomChartFrameWithOffset:chartFrameOffset frameWidth:chartWidth frameHeight:chartHeight];

    UInt32 dataCount = [historicData tickCount:drawAndScrollController.historicType];
    if (dataCount == 0) return;

    BOOL isDayLine = drawAndScrollController.analysisPeriod == AnalysisPeriodDay;

    int frontIndex, rearIndex, seq;

    [drawAndScrollController drawChartFrameYScaleWithChartOffset:CGPointMake(0, 1) frameWidth:chartWidth frameHeight:chartHeight yLines:(int)yLines lineIncrement:2];

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
    double arPrice;
    float v = 0;
    double up = 0;
    double dn = 0;
    
    [arValues removeAllObjects];
    
    for (int i = 0; i < dataCount; i++) {
        v=0;
        historic = [self.historicData copyHistoricTick:type sequenceNo:i];
        arPrice = historic.open;
        up += historic.high - arPrice;
        dn += arPrice - historic.low;
        
        if (i >= arParameter-1) {
            historic = [self.historicData copyHistoricTick:type sequenceNo:i-arParameter];
            arPrice = historic.open;
            up -= historic.high - arPrice;
            dn -= arPrice - historic.low;
            
            v = dn ? up / dn : 0;
            
        }
        
        [arValues addObject:[NSNumber numberWithFloat:v]];
    }

    v = 0;
    up = dn = arPrice = 0;
    [brValues removeAllObjects];
    [brValues addObject:[NSNumber numberWithFloat:0]];
    
    for (int i = 1; i < dataCount; i++) {

        historic = [self.historicData copyHistoricTick:type sequenceNo:i-1];
        arPrice = historic.close;
        
        historic = [self.historicData copyHistoricTick:type sequenceNo:i];
        up += historic.high - arPrice;
        dn += arPrice - historic.low;
        
        if (i >= brParameter) {

            if (i>brParameter) {
                historic = [self.historicData copyHistoricTick:type sequenceNo:i-brParameter-1];
                arPrice = historic.close;
                
                historic = [self.historicData copyHistoricTick:type sequenceNo:i-brParameter];
                up -= historic.high - arPrice;
                dn -= arPrice - historic.low;
                
                v = dn ? up / dn : 0;
            }else{
                v = dn ? up / dn : 0;
                
            }
        }
        
        [brValues addObject:[NSNumber numberWithFloat:v]];
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
    
    
    int dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
    int dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
    
    maxValue = -MAXFLOAT;
    minValue = MAXFLOAT;
    
    for (int i = dataStartIndex; i <= dataEndIndex; i++) {
        float v = [(NSNumber *)[arValues objectAtIndex:i] floatValue];
        if (maxValue < v) maxValue = v;
        if (minValue > v) minValue = v;
    }
    
    for (int i = dataStartIndex; i <= dataEndIndex; i++) {
        float v = [(NSNumber *)[brValues objectAtIndex:i] floatValue];
        if (maxValue < v) maxValue = v;
        if (minValue > v) minValue = v;
    
    }

//    [bottonView.dataView setNeedsDisplay];

    if (minValue == MAXFLOAT || maxValue == -MAXFLOAT) {
        minValue = maxValue = 0;
        return;
    }

    float amp = maxValue - minValue;
    if (amp == 0) return;

    float x, y;
    BOOL firstAr = TRUE;
    BOOL firstBr = TRUE;

    float xScale = chartWidth / xLines;
    float yScale = chartHeight / amp;
    float x0 = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
    float y0 = chartFrameOffset.y + chartHeight;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);

    CGMutablePathRef arPath = CGPathCreateMutable();
    CGMutablePathRef brPath = CGPathCreateMutable();

    for (int i = dataStartIndex; i <= dataEndIndex; i++) {

        seq = i;

        x = x0 + i * xScale;
		
		if (seq >= arParameter-1) {

            y = y0 - ([(NSNumber *)[arValues objectAtIndex:seq] floatValue] - minValue) * yScale;

            if (firstAr) {
                CGPathMoveToPoint(arPath, NULL, x, y);
                firstAr = FALSE;
            }

            CGPathAddLineToPoint(arPath, NULL, x, y);
        }

        if (seq >= brParameter) {

            y = y0 - ([(NSNumber *)[brValues objectAtIndex:seq] floatValue] - minValue) * yScale;

            if (firstBr) {
                CGPathMoveToPoint(brPath, NULL, x, y);
                firstBr = FALSE;
            }

            CGPathAddLineToPoint(brPath, NULL, x, y);
        }

        seq++;
    }

    [[UIColor magentaColor] set];
    CGContextAddPath(context, arPath);
    CGContextStrokePath(context);
    CGPathRelease(arPath);

    [[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1] set];
    CGContextAddPath(context, brPath);
    CGContextStrokePath(context);
    CGPathRelease(brPath);

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
//	double ar = 0,br = 0;
//	if(index < [arValues count])
//	{
//		ar = [[arValues objectAtIndex:index] doubleValue];
//		br = [[brValues objectAtIndex:index] doubleValue];
//	}
//	*value1 = ar;
//	*value2 = br;
//	*value3 = 0;
}
- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3 Value4:(double *)value4
{
	double ar = -0,br = -0,beforeAr = -0,beforeBr = -0;
	if(index >= arParameter-1 && index < [arValues count])
	{
		ar = [(NSNumber *)[arValues objectAtIndex:index] doubleValue];
        beforeAr = [(NSNumber *)[arValues objectAtIndex:index-1] doubleValue];
        
	}
    if(index >= brParameter && index < [brValues count])
	{
		br = [(NSNumber *)[brValues objectAtIndex:index] doubleValue];
        beforeBr = [(NSNumber *)[brValues objectAtIndex:index-1] doubleValue];
        
	}
	*value1 = ar;
	*value2 = br;
	*value3 = beforeAr;
    *value4 = beforeBr;
}

@end
