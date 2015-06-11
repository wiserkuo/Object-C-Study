//
//  MomentumView.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/4.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "MomentumView.h"
#import "DrawAndScrollController.h"
#import "BottomDataView.h"
#import "HistoricDataTypes.h"


//#define mtmParameter 10


@implementation MomentumView

@synthesize drawAndScrollController;
@synthesize bottonView;
@synthesize historicData;
@synthesize chartFrame;
@synthesize xLines;
@synthesize yLines;
@synthesize zoomTransform;
@synthesize maxValue;


- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        chartFrame = frame;
        chartFrameOffset = offset;
		mtmValues = [[NSMutableArray alloc] init];
		sumValues = [[NSMutableArray alloc] init];
    }
    return self;
}


- (float)getMtmValue:(UInt8)type sequence:(int)index {

    DecompressedHistoricData *historic = [historicData copyHistoricTick:type sequenceNo:index];
    double v = historic.close;

    historic = [historicData copyHistoricTick:type sequenceNo:index-mtmParameter];
    v -= historic.close;

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
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeMTM];
	NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	mtmParameter = [(NSNumber *)[parmDict1 objectForKey:@"MTMparameter"]intValue];
	
	
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

    float mtm;
    maxValue = 0;
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

    for (NSUInteger i = dataStartIndex; i < dataEndIndex; i++) {
        if (i>mtmParameter) {
            mtm = [self getMtmValue:type sequence:(int)i];
            if (isnan(mtm))
                continue;
            if (maxValue < fabsf(mtm))
                maxValue = fabsf(mtm);
        }
    }
    float sum = 0,ma=0;
    for (NSUInteger i = dataStartIndex; i < dataEndIndex; i++) {
        if (i>=mtmParameter) {
            mtm = [self getMtmValue:type sequence:(int)i];
            sum += mtm;
        }
        if (i>=mtmParameter + mtmParameter) {
            sum -= [self getMtmValue:type sequence:(int)i-mtmParameter];
            ma = sum / mtmParameter ;
            if (isnan(ma))
                continue;
            if (maxValue < fabsf(ma))
                maxValue = fabsf(ma);
        }
    }
    
    

    [bottonView.dataView setNeedsDisplay];

    if (maxValue == 0) return;

    float x, y;
    sum = 0;
    BOOL first = TRUE;
    BOOL avgFirst = TRUE;

    float xScale = chartWidth / xLines;
    float yScale = chartHeight / 2 / maxValue;
    float x0 = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
    float y0 = chartFrameOffset.y + chartHeight / 2;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);

    CGMutablePathRef path = CGPathCreateMutable();
    CGMutablePathRef avgPath = CGPathCreateMutable();
	
	[mtmValues removeAllObjects];
	[sumValues removeAllObjects];
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {

        seq = (int)i;

        if (seq >= mtmParameter) {

            mtm = [self getMtmValue:type sequence:seq];

            x = x0 + i * xScale;
			y = y0 - mtm * yScale;

            if (first) {
                CGPathMoveToPoint(path, NULL, x, y);
                first = FALSE;
            }

            CGPathAddLineToPoint(path, NULL, x, y);

                    }
		[mtmValues addObject:[NSNumber numberWithDouble:mtm]];
		

        seq++;
    }
    
    
    for (NSUInteger i=dataStartIndex-mtmParameter; i<=dataEndIndex; i++) {
        mtm = [self getMtmValue:type sequence:(int)i];
        sum += mtm;
        if (i > dataStartIndex -1 && i>mtmParameter+mtmParameter) {
            sum -= [self getMtmValue:type sequence:(int)i-mtmParameter];
            x = x0 + i * xScale;
            y = y0 - sum / mtmParameter * yScale;
            
            if (avgFirst) {
                CGPathMoveToPoint(avgPath, NULL, x, y);
                avgFirst = FALSE;
            }
            
            CGPathAddLineToPoint(avgPath, NULL, x, y);
        }
        if (i>dataStartIndex-1 && i>mtmParameter+mtmParameter) {
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
//	double sum = 0,mtm = 0;
//	if(index < [mtmValues count] && index >= mtmParameter)
//	{
//		sum = [[sumValues objectAtIndex:index] doubleValue] / mtmParameter;
//		mtm = [[mtmValues objectAtIndex:index] doubleValue];
//	}
//	*value1 = sum;
//	*value2 = mtm;
//	*value3 = 0;
}

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3 Value4:(double *)value4
{
	double sum = -0,mtm = -0,beforeSum = -0,beforeMtm = -0;
    index-=dataStartIndex;
	if(index < [mtmValues count])
	{
		mtm = [(NSNumber *)[mtmValues objectAtIndex:index] doubleValue];
        if (index>mtmParameter) {
            beforeMtm = [(NSNumber *)[mtmValues objectAtIndex:index-1] doubleValue];
        }
        
	}
    
    if (index < [sumValues count]) {
        sum = [(NSNumber *)[sumValues objectAtIndex:index] doubleValue] / mtmParameter;
        if (index>mtmParameter+mtmParameter-1) {
            beforeSum = [(NSNumber *)[sumValues objectAtIndex:index-1] doubleValue] / mtmParameter;
        }
        
    }
	*value1 = mtm;
	*value2 = sum;
	*value3 = beforeMtm;
    *value4 = beforeSum;
}


@end
