//
//  PsychologicalLine.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/1/23.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "PsychologicalLine.h"
#import "DrawAndScrollController.h"


//#define psyParameter 12


@implementation PsychologicalLine

@synthesize drawAndScrollController;
@synthesize bottonView;
@synthesize historicData;
@synthesize chartFrame;
@synthesize xLines;
@synthesize yLines;
@synthesize zoomTransform;


- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        chartFrame = frame;
        chartFrameOffset = offset;
		psyValues = [[NSMutableArray alloc] init];
        dataLock = [[NSRecursiveLock alloc]init];
    }
    return self;
}


- (int)getPsyValue:(UInt8)type sequence:(int)index {

    if (index == 0) return 0;

    DecompressedHistoricData *historic = [historicData copyHistoricTick:type sequenceNo:index-1];
    double prevClose = historic.close;

    historic = [historicData copyHistoricTick:type sequenceNo:index];
    int v = historic.close - prevClose > 0 ? 1 : 0;

    return v;
}


- (void)drawRect:(CGRect)rect {
    [dataLock lock];
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
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypePSY];
	NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	psyParameter = [(NSNumber *)[parmDict1 objectForKey:@"PSYparameter"]intValue];
	
    float chartWidth = chartFrame.size.width;
    float chartHeight = chartFrame.size.height;

    [drawAndScrollController drawBottomChartFrameWithOffset:chartFrameOffset frameWidth:chartWidth frameHeight:chartHeight];

    UInt8 type = drawAndScrollController.historicType;
    UInt32 dataCount = [historicData tickCount:type];
    if (dataCount == 0){
        [dataLock unlock];
        return;
    }

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

    CGContextRef context = UIGraphicsGetCurrentContext();

    float x, y;
    float sum = 0;
    BOOL first = TRUE;

    float xScale = chartWidth / xLines;
    float xOrigin = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
    float yOrigin = chartFrameOffset.y + chartHeight;

    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor orangeColor] set];
	[psyValues removeAllObjects];

    for (int i = frontIndex; i <= rearIndex; i++) {

        seq = i;

        sum += [self getPsyValue:type sequence:seq];

        if (seq >= psyParameter) {

            sum -= [self getPsyValue:type sequence:seq-psyParameter];

            x = xOrigin + i * xScale;
			y = yOrigin - (sum / psyParameter) * chartHeight;

            if (first) {
                CGContextMoveToPoint(context, x, y);
                first = FALSE;
            }

            CGContextAddLineToPoint(context, x, y);
        }
		[psyValues addObject:[NSNumber numberWithDouble:sum]];
        seq++;
    }

    CGContextStrokePath(context);

    if (!CGAffineTransformIsIdentity(zoomTransform)) {
        self.transform = zoomTransform;
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        zoomTransform = CGAffineTransformIdentity;
    }
    //設定預設數值
    [drawAndScrollController setDefaultValue];
    
    [dataLock unlock];
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
	double bValue = -0,beforeV = -0;
    if(index < [psyValues count] && index >= psyParameter){
		bValue = 100*([(NSNumber *)[psyValues objectAtIndex:index] doubleValue] / psyParameter);
        if (index>psyParameter) {
            beforeV =100*([(NSNumber *)[psyValues objectAtIndex:index-1] doubleValue] / psyParameter);
        } 
    }
	*value1 = bValue;
	*value2 = beforeV;
	*value3 = 0;
}

@end
