//
//  BiasView.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/2.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "BiasView.h"
#import "DrawAndScrollController.h"


//#define biasParameter 12


@implementation BiasView

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
        biasValues = [[NSMutableArray alloc] init];
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
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeBias];		
	NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	biasParameter = [(NSNumber *)[parmDict1 objectForKey:@"BIASparameter"]intValue];
	
    float chartWidth = chartFrame.size.width;
    float chartHeight = chartFrame.size.height;

    [drawAndScrollController drawBottomChartFrameWithOffset:chartFrameOffset frameWidth:chartWidth frameHeight:chartHeight];

    UInt32 dataCount = [historicData tickCount:drawAndScrollController.historicType];
    if (dataCount == 0) return;

    BOOL isDayLine = drawAndScrollController.analysisPeriod == AnalysisPeriodDay;

    NSUInteger frontIndex, rearIndex, seq;

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

    DecompressedHistoricData *historic;
    double close, avg;
    float v;
//    double sum = 0;

    maxValue = 0;
    
    [biasValues removeAllObjects];
    
    double BIASsum = 0;
    
    for (int i = 0; i < dataCount; i++) {
        
        historic = [self.historicData copyHistoricTick:type sequenceNo:i];
        close = historic.close;
        
        v = 0;
        BIASsum += close;
        
        if (i >= biasParameter-1) {
            
            if (i >= biasParameter) {
                historic = [self.historicData copyHistoricTick:type sequenceNo:i-biasParameter];
                BIASsum -= historic.close;
            }
            
            avg = BIASsum / biasParameter;
            
            if (avg != 0) {
                v = close / avg - 1;
                if (maxValue < fabsf(v))
                    maxValue = fabsf(v);
            }
        }
        
        double bValue = 0;
        bValue = v / maxValue;
        bValue = (maxValue*100) * bValue;
        
        [biasValues addObject:[NSNumber numberWithFloat:bValue]];
    }

    
//    [biasValues removeAllObjects];
//
//    for (int i = 0; i < dataCount; i++) {
//
//        historic = [historicData copyHistoricTick:type sequenceNo:i];
//        close = historic.close;
//        [historic release];
//
//        v = 0;
//        sum += close;
//
//        if (i >= biasParameter-1) {
//
//            if (i >= biasParameter) {
//                historic = [historicData copyHistoricTick:type sequenceNo:i-biasParameter];
//                sum -= historic.close;
//                [historic release];
//            }
//
//            avg = sum / biasParameter;
//
//            if (avg != 0) {
//                v = close / avg - 1;
//                if (maxValue < fabsf(v))
//                    maxValue = fabsf(v);
//            }
//        }
//        v=[[[dataModal.operationalIndicator getDataByIndex:i] objectForKey:@"BIAS"] floatValue];
//        [biasValues addObject:[NSNumber numberWithFloat:v]];
//    }
    
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
    
    
    NSUInteger dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
    NSUInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
    maxValue =0;
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {
        float v = [(NSNumber *)[biasValues objectAtIndex:i]floatValue];
        if (fabsf(v)>maxValue) {
            maxValue = fabsf(v);
        }
    }

//    [bottonView.dataView setNeedsDisplay];

    if (maxValue == 0) return;

    float xScale = chartWidth / xLines;
    float yScale = chartHeight / 2 / maxValue;
    float x0 = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
    float y0 = chartFrameOffset.y + chartHeight / 2;

    float x, y;
    BOOL first = TRUE;

    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor orangeColor] set];

    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {

        seq = i;

        if (seq >= biasParameter-1) {

            x = x0 + i * xScale;
			y = y0 - [(NSNumber *)[biasValues objectAtIndex:seq] floatValue] * yScale;
            if (isnan(y))
                continue;
            if (first) {
                CGContextMoveToPoint(context, x, y);
                first = FALSE;
            }

            CGContextAddLineToPoint(context, x, y);
        }

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
	double bValue = -0,befoValue = -0;
	if(index>=biasParameter-1 && index < [biasValues count])
	{
		bValue = [(NSNumber *)[biasValues objectAtIndex:index] floatValue];
        befoValue = [(NSNumber *)[biasValues objectAtIndex:index-1] floatValue];
		//bValue = maxValue * bValue;
	}
	*value1 = bValue;
	*value2 = befoValue;
	*value3 = 0;
}


@end
