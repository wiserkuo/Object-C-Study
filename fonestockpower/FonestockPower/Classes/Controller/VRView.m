//
//  VRView.m
//  Bullseye
//
//  Created by Yehsam on 2009/9/2.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "VRView.h"
#import "DrawAndScrollController.h"

//#define towerParameter 3

static float xScale,yScale;
static float xSize;
static float ySize;

@implementation VRView

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
		vrValues = [[NSMutableArray alloc] init];
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
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeVR];
	NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	nDayParameter = [(NSNumber *)[parmDict1 objectForKey:@"VRparameter"]intValue];
	
    // Drawing code
    xSize = chartFrame.size.width;
    ySize = chartFrame.size.height;
	
    //畫chart frame邊框
    [drawAndScrollController drawBottomChartFrameWithOffset:chartFrameOffset frameWidth:xSize frameHeight:ySize];
	
    UInt32 dataCount = [historicData tickCount:drawAndScrollController.historicType];
    if (dataCount == 0) return;
	
    BOOL isDayLine = drawAndScrollController.analysisPeriod == AnalysisPeriodDay;
	
    NSInteger offsetXvalue = chartFrameOffset.x;
//    NSInteger offsetYvalue = chartFrameOffset.y;
	
	
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
	
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGMutablePathRef pathVR = CGPathCreateMutable();
	minValue = 160;
	maxValue = 40;
	[self goVR];
	
	int fontSLIindex;
    int rearSLIindex;
    int seq;
	
	fontSLIindex = 0;
	rearSLIindex = dataCount - 1;
    
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
    
    maxValue = -MAXFLOAT;
    minValue = MAXFLOAT;
    
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {
        float v = [(NSNumber *)[vrValues objectAtIndex:i] floatValue];
        if (maxValue < v) maxValue = v;
        if (minValue > v) minValue = v;
    }
    
    if (maxValue == -MAXFLOAT) {
        maxValue =0;
    }
    if (minValue == MAXFLOAT) {
        minValue = 0;
    }
	
    //DecompressedHistoricData *historic;
    BOOL first = TRUE;
    float vrV;
	float heightMaxValue = fabs(maxValue - minValue);
	float xValue = 0 , yValue = 0;
    xSize = chartFrame.size.width;
    ySize = chartFrame.size.height;
/*	float upperPercentLine = (100.0 - minValue) / heightMaxValue;
	float upperThresholdLine = (float)ySize - upperPercentLine*ySize;
	float bottomPercentLine = (-100.0 - minValue) / heightMaxValue;
	float bottomThresholdLine = (float)ySize - bottomPercentLine*ySize;
*/
	
#pragma mark ---------------------------------------------------------------- 畫 VR 線
	
	for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {
		
        seq = (int)i;
		
        if (seq >= nDayParameter) {
			
            vrV = [(NSNumber *)[vrValues objectAtIndex:seq] floatValue];
			
            // x軸座標值：
            xValue = i * xScale;
            
            if (heightMaxValue == 0) {
                yValue = 0;
            }else{
                yValue = (vrV - minValue) * ySize / heightMaxValue;
            }
			
            
			
            if (first) {
				CGPathMoveToPoint(pathVR, NULL, xValue + offsetXvalue, ySize - yValue + chartFrameOffset.y);
                first = FALSE;
            }
			
            CGPathAddLineToPoint(pathVR, NULL, xValue + offsetXvalue, ySize - yValue + chartFrameOffset.y);
            CGContextStrokePath(context);
        }
		
        seq++;
    }
	
	CGContextAddPath(context,pathVR);
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor orangeColor] set];
    CGContextStrokePath(context);
	CGPathRelease(pathVR);	

	
	if (!CGAffineTransformIsIdentity(zoomTransform)) {
        self.transform = zoomTransform;
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        zoomTransform = CGAffineTransformIdentity;
    }
	
    //設定預設數值
    [drawAndScrollController setDefaultValue];
	
}

- (void)drawPercentLineWithThresholdLine:(float)thresholdLine withColorIndex:(int)colorIndex chartFrameOffset:(CGPoint)offsetPoint{
	
	CGRect frameSize = self.chartFrame;
	
	CGPoint thresholdPoint[] =
	{
		CGPointMake(0,thresholdLine),
		CGPointMake(frameSize.size.width,thresholdLine),
	};
	
	[self drawLineOnStartPoint:thresholdPoint[0] EndPoint:thresholdPoint[1] Offset:offsetPoint withColorIndex:colorIndex];
	
}

//給定起終點 繪線
-(void)drawLineOnStartPoint:(CGPoint)point1 EndPoint:(CGPoint)point2 Offset:(CGPoint)frameOffset withColorIndex:(int)colorIndex{
	
	CGContextRef context = UIGraphicsGetCurrentContext(); 
	
//	NSArray *colorList = [[NSArray alloc] initWithObjects:[UIColor redColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor], [UIColor magentaColor], [UIColor purpleColor], [UIColor blackColor], [UIColor whiteColor], nil];
	
//	[[colorList objectAtIndex:colorIndex % [colorList count]] set];

	
	CGContextSetLineWidth(context, 1);
	
	if (point1.x == point2.x || point1.y == point2.y){
		
		if(point1.x != point2.x)
		{
			//橫線		
			CGContextMoveToPoint(context, frameOffset.x + point1.x, frameOffset.y + point1.y); 
			CGContextAddLineToPoint(context, frameOffset.x + point2.x, frameOffset.y + point1.y);
			CGContextStrokePath(context);
		}
		
		if(point1.y != point2.y)
		{
			//直線
			CGContextMoveToPoint(context, point1.x + frameOffset.x, point1.y + frameOffset.y); 
			CGContextAddLineToPoint(context, point2.x + frameOffset.x, point2.y + frameOffset.y);	
			CGContextStrokePath(context);			
		}
		
	}
	else{
		// 不畫線
	}
	
	CGContextStrokePath(context); //顯示線段 連接起終點 	
}

- (void)goVR
{
//	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    UInt32 count = [historicData tickCount:drawAndScrollController.historicType];
//	[vrValues removeAllObjects];
//	for (int i = 0; i < count; i++) {
//		
//		if(i < nDayParameter)
//		{
//			[vrValues addObject:[NSNumber numberWithFloat:0]];
//		}
//		else{
///*
// 1．24天以来凡是股价上涨那一天的成交量都称为AV，将24天内的AV总和相加后称为AVS。
// 2．24天以来凡是股价下跌那一天的成交量都称为BV，将24天内的BV总和相加后称为BVS。
// 3．24天以来凡是股价不涨不跌，则那一天的成交量都称为CV，将24天内的CV总和相加后称为CVS。
// 4． 24天开始计算：
// VR= 100*（AVS+1/2CVS）/（BVS+1/2CVS）
//*/
//			double avs = 0 , bvs = 0 , cvs = 0;
//			double vrV;
//			[self getAVS:&avs BVS:&bvs CVS:&cvs Index:i];
//			vrV = 100*(avs + (cvs/2)) / (bvs + (cvs/2));
//			if(vrV > maxValue)
//				maxValue = vrV;
//			if(vrV < minValue)
//				minValue = vrV;
//            vrV = [[[dataModal.operationalIndicator getDataByIndex:i]objectForKey:@"VR"]floatValue];
//			[vrValues addObject:[NSNumber numberWithFloat:vrV]];
//		}
//	}
    
    [vrValues removeAllObjects];
    
    count = [self.historicData tickCount:type];
	for (int i = 0; i < count; i++) {
		
		if(i < nDayParameter)
		{
			[vrValues addObject:[NSNumber numberWithDouble:0]];
		}
		else{
            /*
             1．24天以来凡是股价上涨那一天的成交量都称为AV，将24天内的AV总和相加后称为AVS。
             2．24天以来凡是股价下跌那一天的成交量都称为BV，将24天内的BV总和相加后称为BVS。
             3．24天以来凡是股价不涨不跌，则那一天的成交量都称为CV，将24天内的CV总和相加后称为CVS。
             4． 24天开始计算：
             VR= 100*（AVS+1/2CVS）/（BVS+1/2CVS）
             */
			double avs = 0 , bvs = 0 , cvs = 0;
			double vrV=0;
			[self getAVS:&avs BVS:&bvs CVS:&cvs Index:i];
			vrV = (avs+cvs/2)/(bvs+cvs/2);
			[vrValues addObject:[NSNumber numberWithDouble:vrV*100]];
		}
	}
	
}

- (void)getAVS:(double*)avs BVS:(double*)bvs CVS:(double*)cvs Index:(int)index
{
	int rearIndex = index;
	
	//最大index 減去 days區間 算區間頭在 dataList中的index
	int fontIndex = index - nDayParameter +1;
	
	for(int i=fontIndex ; i<=rearIndex ;i++){
		
		DecompressedHistoricData *historic = [self.historicData copyHistoricTick:type sequenceNo:i];
        DecompressedHistoricData *oldHistoric = [self.historicData copyHistoricTick:type sequenceNo:i-1];
		if(historic)
		{
			if(fabs(oldHistoric.close - historic.close) < 0.0001)		//平盤
				*cvs += historic.volume * pow(1000,historic.volumeUnit);
			else if(oldHistoric.close > historic.close)		//跌
				*bvs += historic.volume * pow(1000,historic.volumeUnit);
			else if(historic.close > oldHistoric.close)
				*avs += historic.volume * pow(1000,historic.volumeUnit);
		}
	}
}


//- (void)getAVS:(double*)avs BVS:(double*)bvs CVS:(double*)cvs Index:(int)index
//{
//	int rearIndex = index;	
//	
//	//最大index 減去 days區間 算區間頭在 dataList中的index
//	int fontIndex = index - nDayParameter +1;	
//	
//	for(int i=fontIndex ; i<=rearIndex ;i++){
//		
//		DecompressedHistoricData *historic = [historicData copyHistoricTick:drawAndScrollController.historicType sequenceNo:i];
//		if(historic)
//		{
//			if(fabs(historic.open - historic.close) < 0.0001)		//平盤
//				*cvs += historic.volume * pow(1000,historic.volumeUnit);
//			else if(historic.open > historic.close)		//跌
//				*bvs += historic.volume * pow(1000,historic.volumeUnit);
//			else
//				*avs += historic.volume * pow(1000,historic.volumeUnit);
//		}
//		[historic release];
//		
//	}
//}

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
{   float vrV=-0,beforeVr = -0;
    if ([vrValues count]>index && index >=nDayParameter) {
        vrV= [(NSNumber *)[vrValues objectAtIndex:index] floatValue];
        beforeVr = [(NSNumber *)[vrValues objectAtIndex:index-1] floatValue];

    }
    *value1 = vrV;
	*value2 = beforeVr;
	*value3 = 0;
}

@end
