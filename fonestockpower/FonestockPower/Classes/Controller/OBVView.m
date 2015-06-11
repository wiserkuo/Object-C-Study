//
//  OBVView.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/3.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "OBVView.h"
#import "DrawAndScrollController.h"


//#define obvParameter 12


extern const float valueUnitBase[];


@implementation OBVView

@synthesize drawAndScrollController;
@synthesize bottonView;
@synthesize historicData;
@synthesize chartFrame;
@synthesize xLines;
@synthesize yLines;
@synthesize zoomTransform;
@synthesize maxValue;
@synthesize maxVolUnit;


- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        chartFrame = frame;
        chartFrameOffset = offset;
        obvValues = [[NSMutableArray alloc] init];
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
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeOBV];
	NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	obvParameter = [(NSNumber *)[parmDict1 objectForKey:@"OBVparameter"]intValue];
	

    float chartWidth = chartFrame.size.width;
    float chartHeight = chartFrame.size.height;

    [drawAndScrollController drawBottomChartFrameWithOffset:chartFrameOffset frameWidth:chartWidth frameHeight:chartHeight];

    UInt32 dataCount = [historicData tickCount:self.drawAndScrollController.analysisPeriod];
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
    //運算OBV
    double obv = 0;
    [obvValues removeAllObjects];
    
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:type sequenceNo:0];
    maxVolUnit = historic.volumeUnit;
    
    for (int i = 1; i < dataCount; i++) {
        historic = [self.historicData copyHistoricTick:type sequenceNo:i];
        if (maxVolUnit > historic.volumeUnit && historic.volume > 0)
            maxVolUnit = historic.volumeUnit;
    }
    
    for (int i = 0; i < dataCount; i++) {
        
        obv += [self getObvBySequence:i];
        
        if (i >= obvParameter) {
            
            obv -= [self getObvBySequence:i-obvParameter];
            
        }
        
        [obvValues addObject:[NSNumber numberWithDouble:obv]];
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
    maxValue =0;
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {
        if  ([obvValues count]>i){
            float v = [(NSNumber *)[obvValues objectAtIndex:i]floatValue];
            if (fabsf(v)>maxValue) {
                maxValue = fabsf(v);
            }
        }
    }

    //[bottonView.dataView setNeedsDisplay];

    //if (maxVol == 0) return;
    //繪圖
    float x, y;
    BOOL first = TRUE;

    float xScale = chartWidth / xLines;
    float yScale;
    if (maxValue==0) {
        yScale = 0;
    }else{
        yScale= chartHeight / 2 / maxValue;
    }
    
    float x0 = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
    float y0 = chartFrameOffset.y + chartHeight / 2;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor orangeColor] set];

    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {

        seq = (int)i;

        if (seq >= obvParameter) {

            x = x0 + i * xScale;
            y = y0 - (float)[[obvValues objectAtIndex:seq] doubleValue] * yScale;

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

- (double)getObvBySequence:(int)index {
    
    if (index == 0) return 0;
    
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:type sequenceNo:index-1];
    double prevClose = historic.close;
    
    historic = [self.historicData copyHistoricTick:type sequenceNo:index];
    double close = historic.close;
    double vol = historic.volume;
    UInt8 unit = historic.volumeUnit;
    
    if (unit > maxVolUnit)
        vol *= valueUnitBase[unit - maxVolUnit];
    
    return close > prevClose ? vol :
    close < prevClose ? -vol : 0;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [bottonView doTouchesBegan:touches withEvent:event];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [bottonView doTouchesEnded:touches withEvent:event];
}

-(int)getSeqNumberFromPointXValue:(float)x
{
	
	UInt8 newType = self.drawAndScrollController.historicType;
    UInt32 histCount = [historicData tickCount:newType];
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
	double bValue = -0,beforeValue = -0;
	if(index < [obvValues count] && index >= obvParameter){
		bValue = [(NSNumber *)[obvValues objectAtIndex:index] doubleValue];
        if (index>obvParameter) {
            beforeValue = [(NSNumber *)[obvValues objectAtIndex:index-1] doubleValue];
        }
    }
	*value1 = bValue;
	*value2 = beforeValue;
	*value3 = 0;
}

@end
