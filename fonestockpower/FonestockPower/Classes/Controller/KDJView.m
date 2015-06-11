//
//  KDJView.m
//  Bullseye
//
//  Created by Yehsam on 2009/9/1.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "KDJView.h"
#import "DrawAndScrollController.h"


//#define kdParameter 9


static float xSize;
static float ySize;

static NSArray *viewColorList = nil;


@implementation KDJView
@synthesize drawAndScrollController;
@synthesize bottonView;

@synthesize historicData;

@synthesize chartFrame;
@synthesize chartFrameOffset;



@synthesize xLines,yLines;
@synthesize xScale,yScale;

@synthesize zoomTransform;

@synthesize KDdictionary;


- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset{
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		
		chartFrame = frame;
		chartFrameOffset = offset;
		KDdictionary = [[NSMutableDictionary alloc] init];
		
	}
	
	return self;
}

- (float)maxValue
{
	return theKDJMaxValue;
}

- (float)minValue
{
	return theKDJMinValue;
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
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeKDJ];
    NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	kdParameter = [(NSNumber *)[parmDict1 objectForKey:@"KDparameter"]intValue];
    
	kExponentialSmoothing = [(NSNumber *)[parmDict1 objectForKey:@"KDparameter"]intValue];
	dExponentialSmoothing = [(NSNumber *)[parmDict1 objectForKey:@"KDparameter"]intValue];
	
	
	
    xSize = chartFrame.size.width;
    ySize = chartFrame.size.height;
	
    //畫chart frame邊框
    [drawAndScrollController drawBottomChartFrameWithOffset:chartFrameOffset frameWidth:xSize frameHeight:ySize];
	
    UInt32 dataCount = [historicData tickCount:drawAndScrollController.historicType];
    if (dataCount == 0) return;
	
    BOOL isDayLine = drawAndScrollController.analysisPeriod == AnalysisPeriodDay;
	
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
    
	
#pragma mark ---------------------------------------------------------------- 畫 KD index
    
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
    
    
    NSInteger dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
    NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
	
    // get K & D array from KDdictionary
	
    self.KDdictionary = [self KDindexWithParameter:kdParameter kExponentialSmoothing:kExponentialSmoothing dExponentialSmoothing:dExponentialSmoothing];
    theKDJMaxValue = 100;
	theKDJMinValue = 0;
/*	if(theKDJMinValue < 0)
		theKDJMinValue -= 5;
	if(theKDJMaxValue > 100)
		theKDJMaxValue += 5;
*/	
    // drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGMutablePathRef pathK = CGPathCreateMutable();
    CGMutablePathRef pathD = CGPathCreateMutable();
    CGMutablePathRef pathJ = CGPathCreateMutable();
	
    int fontSLIindex;
    int rearSLIindex;
    int seq;
	
	fontSLIindex = 0;
	rearSLIindex = dataCount - 1;
	
    //DecompressedHistoricData *historic;
    BOOL first = TRUE;
    float k, d ,j;
	float heightMaxValue = fabs(theKDJMaxValue - theKDJMinValue);
	
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {
		
        seq = (int)i;
		
        if (seq >= kdParameter-1) {
			
            k = [(NSNumber *)[[KDdictionary valueForKey:@"kLineArray"] objectAtIndex:seq] floatValue];
            d = [(NSNumber *)[[KDdictionary valueForKey:@"dLineArray"] objectAtIndex:seq] floatValue];
            j = [(NSNumber *)[[KDdictionary valueForKey:@"jLineArray"] objectAtIndex:seq] floatValue];
			
            // x軸座標值：
            float xValue = i * xScale;
			
			// K線 y軸座標值：
            float yValueOfK = (k - theKDJMinValue) * ySize / heightMaxValue;
			
            // D線 y軸座標值：
            float yValueOfD = (d - theKDJMinValue) * ySize / heightMaxValue;

			float yValueOfJ = (j - theKDJMinValue) * ySize / heightMaxValue;

            if (first) {
                // K 線 init point
                CGPathMoveToPoint(pathK, NULL, chartFrameOffset.x + xValue, ySize - yValueOfK + chartFrameOffset.y);
				
                // D 線 init point
                CGPathMoveToPoint(pathD, NULL, chartFrameOffset.x + xValue, ySize - yValueOfD + chartFrameOffset.y);

				CGPathMoveToPoint(pathJ, NULL, chartFrameOffset.x + xValue, ySize - yValueOfJ + chartFrameOffset.y);

                first = FALSE;
            }
			
            CGPathAddLineToPoint(pathK, NULL, xValue + chartFrameOffset.x, ySize - yValueOfK + chartFrameOffset.y);
            CGPathAddLineToPoint(pathD, NULL, xValue + chartFrameOffset.x, ySize - yValueOfD + chartFrameOffset.y);
            CGPathAddLineToPoint(pathJ, NULL, xValue + chartFrameOffset.x, ySize - yValueOfJ + chartFrameOffset.y);
            CGContextStrokePath(context);
        }
		
        seq++;
    }
	
//    [KDdictionary release];
	
    CGContextAddPath(context,pathK);
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor magentaColor] set];
    CGContextStrokePath(context);
    CGPathRelease(pathK);
	
    CGContextAddPath(context,pathD);
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1] set];
    CGContextStrokePath(context);
    CGPathRelease(pathD);

	CGContextAddPath(context,pathJ);
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor orangeColor] set];
    CGContextStrokePath(context);
    CGPathRelease(pathJ);
	
#pragma mark ---------------------------------------------------------------- 畫門檻線 30/70 or 20/80
	
    if (dataCount >= kdParameter) {
		
//        float upperPercentLine = (80.0 - theKDJMinValue) / heightMaxValue;
//        float upperThresholdLine = (float)ySize - upperPercentLine*ySize;
        //[self drawPercentLineWithThresholdLine:upperThresholdLine withColorIndex:1 chartFrameOffset:chartFrameOffset];
		
//        float bottomPercentLine = (20.0 - theKDJMinValue) / heightMaxValue;
//        float bottomThresholdLine = (float)ySize - bottomPercentLine*ySize;
        //[self drawPercentLineWithThresholdLine:bottomThresholdLine withColorIndex:1 chartFrameOffset:chartFrameOffset];
    }
	
    if (!CGAffineTransformIsIdentity(zoomTransform)) {
        self.transform = zoomTransform;
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        zoomTransform = CGAffineTransformIdentity;
    }
	
	//設定預設數值
    [drawAndScrollController setDefaultValue];

}


- (NSMutableDictionary *)KDindexWithParameter:(int)nDays kExponentialSmoothing:(int)kSMValue dExponentialSmoothing:(int)dSMValue{
	nDays -=1;
	NSMutableDictionary *KDdictionaryTmp;
	
	float rsv,tmpRsv;
	NSMutableArray *kLineArray = [[NSMutableArray alloc]init];
	NSMutableArray *dLineArray = [[NSMutableArray alloc]init];	
	NSMutableArray *jLineArray = [[NSMutableArray alloc]init];
	
    
    UInt32 count = [self.historicData tickCount:type];
    [kLineArray removeAllObjects];
    [dLineArray removeAllObjects];
    [jLineArray removeAllObjects];
	
    for (int i = 0; i < count; i++) {
		
		if(i < kdParameter)
		{
			rsv = 0;
			[kLineArray addObject:[NSNumber numberWithFloat:0]];
			[dLineArray addObject:[NSNumber numberWithFloat:0]];
			[jLineArray addObject:[NSNumber numberWithFloat:0]];
		}
		else{
			// do
			if (i == kdParameter) {
				
				//KD(3,3,3):
				//當日K值(%K)= 2/3 前一日 K值 + 1/3 RSV
				//當日D值(%D)= 2/3 前一日 D值＋ 1/3 當日K值
				
				//init 無前一日的Ｋ值與Ｄ值
				rsv = [self RSVonTheDateOfIndex:i parameter:kdParameter];
				
				float kValue = (float)2/3 * 50 + (float)1/3 * rsv;
				float dValue = (float)2/3 * 50 + (float)1/3 * kValue;
				float jValue = 3*dValue - 2*kValue;
				
				[kLineArray addObject:[NSNumber numberWithFloat:kValue]];
				[dLineArray addObject:[NSNumber numberWithFloat:dValue]];
				[jLineArray addObject:[NSNumber numberWithFloat:jValue]];
                
			}
			else{
				
				rsv = [self RSVonTheDateOfIndex:i parameter:kdParameter];
				if([[NSNumber numberWithFloat:rsv] isEqualToNumber:(NSNumber*)kCFNumberNaN])
					rsv = tmpRsv;
				else
					tmpRsv = rsv;
				
				
				float kValue = (float)2/3 * [(NSNumber *)[kLineArray objectAtIndex:i-1] floatValue] + (float)1/3*rsv;
				float dValue = (float)2/3 * [(NSNumber *)[dLineArray objectAtIndex:i-1] floatValue] + (float)1/3*kValue;
				float jValue = 3*dValue - 2*kValue;
                
				[kLineArray addObject:[NSNumber numberWithFloat:kValue]];
				[dLineArray addObject:[NSNumber numberWithFloat:dValue]];
				[jLineArray addObject:[NSNumber numberWithFloat:jValue]];
                
			}
		}
	}
    
	
	KDdictionaryTmp = [[NSMutableDictionary alloc] initWithObjectsAndKeys:kLineArray, @"kLineArray", dLineArray, @"dLineArray", jLineArray,@"jLineArray" , nil];
	
	return KDdictionaryTmp;	
	
	
}

//求RSV
- (float)RSVonTheDateOfIndex:(int)index parameter:(int)nDays{
	
	//             第n天收盤價-最近n天內最低價
	//   RSV ＝ ───────────────────────────── × 100
	//           最近n天內最高價-最近n天內最低價
	
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:type sequenceNo:index];
    float closeValue = historic.close;
	
	float theMaxValue = [self theHighestValueOfRecentDays:nDays dataIndex:index];
	float theMinValue = [self theLowestValueOfRecentDays:nDays dataIndex:index];
	
	float rsv = (float)(closeValue - theMinValue)/(theMaxValue-theMinValue)*100;
	
	return rsv;
}

//最近Ｎ天內最低價
- (float)theLowestValueOfRecentDays:(int)nDays dataIndex:(int)index{
	
    int rearIndex = index;
	
	//最大index 減去 days區間 算區間頭在 dataList中的index
	int fontIndex = index - nDays +1;
	
	
	//int minValue = [(NSNumber *)[[dataList objectAtIndex:fontIndex]valueForKey:@"dataLow"]intValue];
	
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:type sequenceNo:fontIndex];
    float minValue = historic.low;
	
	for(int i=fontIndex+1;i<=rearIndex;i++){
		
        historic = [self.historicData copyHistoricTick:type sequenceNo:i];
        if (minValue > historic.low)
            minValue = historic.low;
	}
	return minValue;
}

//最近Ｎ天內最高價
- (float)theHighestValueOfRecentDays:(int)nDays dataIndex:(int)index{
	
    int rearIndex = index;
	
	//最大index 減去 days區間 算區間頭在 dataList中的index
	int fontIndex = index - nDays +1;
	
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:type sequenceNo:fontIndex];
    float maxValue = historic.high;
	
	for(int i=fontIndex+1;i<=rearIndex;i++){
		
        historic = [self.historicData copyHistoricTick:type sequenceNo:i];
        if (maxValue < historic.high)
            maxValue = historic.high;
        
	}
	return maxValue;
}

//給定起終點 繪線
-(void)drawLineOnStartPoint:(CGPoint)point1 EndPoint:(CGPoint)point2 Offset:(CGPoint)frameOffset withColorIndex:(int)colorIndex{
	
	CGContextRef context = UIGraphicsGetCurrentContext(); 
	
	[[self viewColorWithIndex:colorIndex] set];
	
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

// 給定門檻percent值 畫percentLine
- (void)drawPercentLineWithThresholdLine:(float)thresholdLine withColorIndex:(int)colorIndex chartFrameOffset:(CGPoint)offsetPoint{
	
	CGRect frameSize = self.chartFrame;
	
	CGPoint thresholdPoint[] =
	{
		CGPointMake(0,thresholdLine),
		CGPointMake(frameSize.size.width,thresholdLine),
	};
	
	[self drawLineOnStartPoint:thresholdPoint[0] EndPoint:thresholdPoint[1] Offset:offsetPoint withColorIndex:colorIndex];
	
}


- (UIColor *)viewColorWithIndex:(NSUInteger)index {
    if (viewColorList == nil) {
        viewColorList = [[NSArray alloc] initWithObjects:[UIColor redColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor], 
						 [UIColor magentaColor], [UIColor purpleColor], [UIColor blackColor], [UIColor whiteColor], nil];
    }
	
    return [viewColorList objectAtIndex:index % [viewColorList count]];
	
}

-(int)getSeqNumberFromPointXValue:(float)x
{
	
	UInt8 newType = self.drawAndScrollController.historicType;
    UInt32 histCount = [historicData tickCount:newType];
    if (histCount == 0) return -1;
	
    float newxScale = drawAndScrollController.barDateWidth;
    int x0 =0;// offsetX;
    int n = x > x0 ? (x - x0) / newxScale : 0;
	
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

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3
{
	
}

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3 Value4:(double *)value4 Value5:(double *)value5 Value6:(double *)value6{
    float k=-0,d=-0,j=-0,bk=-0,bd=-0,bj=-0;
    
    if( [[KDdictionary valueForKey:@"kLineArray"] count]>index && index >= kdParameter-1){
        k = [(NSNumber *)[[KDdictionary valueForKey:@"kLineArray"] objectAtIndex:index] floatValue];
        d = [(NSNumber *)[[KDdictionary valueForKey:@"dLineArray"] objectAtIndex:index] floatValue];
        j = [(NSNumber *)[[KDdictionary valueForKey:@"jLineArray"] objectAtIndex:index] floatValue];
        bk = [(NSNumber *)[[KDdictionary valueForKey:@"kLineArray"] objectAtIndex:index-1] floatValue];
        bd = [(NSNumber *)[[KDdictionary valueForKey:@"dLineArray"] objectAtIndex:index-1] floatValue];
        bj = [(NSNumber *)[[KDdictionary valueForKey:@"jLineArray"] objectAtIndex:index-1] floatValue];
    }
    
	
	
	*value1 = k;
	*value2 = d;
	*value3 = j;
    *value4 = bk;
    *value5 = bd;
    *value6 = bj;
}

@end
