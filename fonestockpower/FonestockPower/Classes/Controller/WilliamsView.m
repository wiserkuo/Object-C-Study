//
//  WilliamsView.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/2.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "WilliamsView.h"
#import "DrawAndScrollController.h"


//#define williamsParameter 12


@implementation WilliamsView

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
		williamsValues = [[NSMutableArray alloc] init];
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
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeWR];
    NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	williamsParameter = [(NSNumber *)[parmDict1 objectForKey:@"WRparameter"]intValue];
	
	
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
    float winLocationX;
    if(xSize<273)
        winLocationX = 0;
    else
        winLocationX = drawAndScrollController.indexScaleView.frame.origin.x;
    
    
    dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
    NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];

    CGContextRef context = UIGraphicsGetCurrentContext();

    DecompressedHistoricData *historic;
    int j;
    float x, y;
    double close, min, max, m;
    float v;
    BOOL first = TRUE;

    float xScale = chartWidth / xLines;
    float xOrigin = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
    float yOrigin = chartFrameOffset.y + chartHeight;

    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor orangeColor] set];
	[williamsValues removeAllObjects];
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {

        seq = (int)i;

        if (seq >= williamsParameter-1) {

            historic = [historicData copyHistoricTick:type sequenceNo:seq];
            close = historic.close;

            min = MAXFLOAT;
            max = 0;

            for (j = 0; j < williamsParameter; j++) {

                historic = [historicData copyHistoricTick:type sequenceNo:seq-j];
                if (max < historic.high)
                    max = historic.high;
                if (min > historic.low)
                    min = historic.low;
            }

            m = max - min;
            v = m > 0 ? (max - close) / m : 0.5;

            x = xOrigin + i * xScale;
            y = yOrigin - (1 - v) * chartHeight;
			if (first) {
                CGContextMoveToPoint(context, x, y);
                first = FALSE;
            }

            CGContextAddLineToPoint(context, x, y);
        }
		[williamsValues addObject:[NSNumber numberWithDouble:v]];
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
	double bValue = -0;
    double beforeV = -0;
    index-=dataStartIndex;
	if(index < [williamsValues count] && index >= williamsParameter-1){
		bValue = 100*[(NSNumber *)[williamsValues objectAtIndex:index] doubleValue];
        beforeV = 100*[(NSNumber *)[williamsValues objectAtIndex:index-1] doubleValue];
    }
	*value1 = bValue;
	*value2 = beforeV;
	*value3 = 0;
}
@end
