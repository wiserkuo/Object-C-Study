//
//  TowerView.m
//  Bullseye
//
//  Created by Yehsam on 2009/3/2.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TowerView.h"
#import "DrawAndScrollController.h"

//#define towerParameter 3

static float xScale,yScale;
static float xSize;
static float ySize;

@implementation TowerView

@synthesize drawAndScrollController;
@synthesize bottonView;
@synthesize historicData;

@synthesize chartFrame;
@synthesize chartFrameOffset;

@synthesize xLines,yLines;
@synthesize zoomTransform;
@synthesize maxValue;
@synthesize minValue;

- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		chartFrame = frame;
		chartFrameOffset = offset;
		openValues = [[NSMutableArray alloc] init];
        closeValues = [[NSMutableArray alloc] init];
		colorValues = [[NSMutableArray alloc] init];
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
	
//	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeTower];
	towerParameter =0;// [(NSNumber *)[parmDict objectForKey:@"indicatorParameter1"]intValue];
	
    // Drawing code
    xSize = chartFrame.size.width;
    ySize = chartFrame.size.height;
	
    //畫chart frame邊框
    [drawAndScrollController drawBottomChartFrameWithOffset:chartFrameOffset frameWidth:xSize frameHeight:ySize];
	
    UInt32 dataCount = [historicData tickCount:drawAndScrollController.historicType];
    if (dataCount == 0) return;
	
    BOOL isDayLine = drawAndScrollController.analysisPeriod == AnalysisPeriodDay;
	
    NSInteger offsetXvalue = chartFrameOffset.x;
	
	
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
#pragma mark ---------------------------------------------------------------- 畫 Tower Data線
		
	DecompressedHistoricData *historic;
//	maxValue = 0;
//    minValue = MAXFLOAT;

    
    historic = [self.historicData copyHistoricTick:type sequenceNo:0];
    float value, open, openBreak, closeBreak = 0;
    double close = 0;
    BOOL add, reset;
    openBreak = open = historic.close;
    int index, showStart = 0;
    int level = 1;
    [openValues removeAllObjects];
    [closeValues removeAllObjects];
    NSMutableArray  * openArray = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:0], nil];
    [openArray setObject:[NSNumber numberWithFloat:open] atIndexedSubscript:0];
    
    for (index = 0; index < dataCount; index++) {
        historic = [self.historicData copyHistoricTick:type sequenceNo:index];
        value = historic.close;
        [openValues addObject:[NSNumber numberWithFloat:open]];
        [closeValues addObject:[NSNumber numberWithDouble:value]];
        
        if (value != open) {
            closeBreak = close = value;
            showStart = index;
            index++;
            break;
        }
    }
    
    for (; index < dataCount; index++) {
        historic = [self.historicData copyHistoricTick:type sequenceNo:index];
        value = historic.close;
        add = reset = false;
        
        if (closeBreak > openBreak) {
            if (value > closeBreak)
                add = true;
            else if (value < openBreak)
                reset = true;
        } else if (closeBreak < openBreak) {
            if (value < closeBreak)
                add = true;
            else if (value > openBreak)
                reset = true;
        }
        
        if (add) {
            open = close;
            closeBreak = close = value;
            
            if (level < 3){
                level+=1;
                [openArray setObject:[NSNumber numberWithFloat:open] atIndexedSubscript:level];
            }else {
                openBreak = [(NSNumber *)[openArray objectAtIndex:1]floatValue];
                [openArray setObject:[openArray objectAtIndex:1] atIndexedSubscript:0];
                [openArray setObject:[openArray objectAtIndex:2] atIndexedSubscript:1];
                [openArray setObject:[NSNumber numberWithFloat:open] atIndexedSubscript:2];
            }
            
        }
        
        if (reset) {
            openBreak = open;
            closeBreak = close = value;
            [openArray setObject:[NSNumber numberWithFloat:open] atIndexedSubscript:0];
            level = 1;
        }
        
        [openValues addObject:[NSNumber numberWithFloat:open]];
        [closeValues addObject:[NSNumber numberWithDouble:close]];
        
    }
    
    maxValue = 0;
    minValue = MAXFLOAT;
    float xSize;
    if (drawAndScrollController.penBtn.selected == YES) {
        xSize = drawAndScrollController.indexScaleView.frame.size.width;
    }else{
        xSize = drawAndScrollController.indexScaleView.frame.size.width-offsetXvalue;
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
    
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {
        float v = [(NSNumber *)[openValues objectAtIndex:i] floatValue];
        if (maxValue < v) maxValue = v;
        if (minValue > v) minValue = v;
    }
    
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {
        float v = [(NSNumber *)[closeValues objectAtIndex:i] floatValue];

        if (maxValue < v) maxValue = v;
        if (minValue > v) minValue = v;
        
    }
	
//    [bottonView.dataView setNeedsDisplay];
	
    int fontSLIindex;
    int rearSLIindex;
    int seq;
	xSize = chartFrame.size.width;
    ySize = chartFrame.size.height;
	fontSLIindex = 0;
	rearSLIindex = dataCount - 1;

	float rectWidth = drawAndScrollController.chartBarWidth;
    float longRectWidth = rectWidth;
	double beginValue;
    CGContextRef context = UIGraphicsGetCurrentContext(); 
	for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++)
	{
		
        seq = (int)i;

        if (seq > towerParameter)
        {
            beginValue = [(NSNumber *)[openValues objectAtIndex:seq] doubleValue];
            double toValue = [(NSNumber *)[closeValues objectAtIndex:seq] doubleValue];
            double subValue = fabsf(beginValue - toValue) / (maxValue - minValue) * ySize;
            float xValue = i * xScale;
            float y;
                
            
            if (seq ==0) {
                [[UIColor blackColor] set];
                CGContextFillPath(context);
            }else{
                double beforeClose =  [(NSNumber *)[closeValues objectAtIndex:seq-1] doubleValue];
                if (toValue>beforeClose) {
                    y = (maxValue - toValue) * ySize / (maxValue - minValue);
                    CGRect longRect = CGRectMake(xValue + offsetXvalue,y , longRectWidth, subValue);
                    CGContextAddRect(context, longRect);
                    [[StockConstant PriceUpColor] set];
                    CGContextFillPath(context);
                }else if (beforeClose>toValue){
                    y = (maxValue - beginValue) * ySize / (maxValue - minValue);
                    CGRect longRect = CGRectMake(xValue + offsetXvalue,y , longRectWidth, subValue);
                    CGContextAddRect(context, longRect);
                    [[StockConstant PriceDownColor] set];
                    CGContextFillPath(context);
                }else{
                    y = (maxValue - toValue) * ySize / (maxValue - minValue);
                    CGRect longRect = CGRectMake(xValue + offsetXvalue,y , longRectWidth, 1);
                    CGContextAddRect(context, longRect);

                    [[UIColor blackColor] set];
                    CGContextFillPath(context);
                }
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

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3 Value4:(double *)value4
{
	double open = -0,close = -0,beforeOpen = -0,beforeClose = -0;
	if(index < [openValues count] && index >= towerParameter)
	{
		open = [(NSNumber *)[openValues objectAtIndex:index] doubleValue];
		close = [(NSNumber *)[closeValues objectAtIndex:index] doubleValue];
        if (index>0) {
            beforeOpen = [(NSNumber *)[openValues objectAtIndex:index-1] doubleValue];
            beforeClose = [(NSNumber *)[closeValues objectAtIndex:index-1] doubleValue];
        }
	}
	*value1 = open;
	*value2 = close;
	*value3 = beforeOpen;
    *value4 = beforeClose;
}

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3{
    
}


@end
