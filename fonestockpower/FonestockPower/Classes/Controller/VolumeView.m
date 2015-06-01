//
//  VolumeView.m
//  Bullseye
//
//  Created by Ming-Zhe Wu on 2009/1/4.
//  Copyright 2009 NHCUE. All rights reserved.
//

#import "VolumeView.h"
#import "DrawAndScrollController.h"
#import "BottonView.h"


static float xScale,yScale;
static float xSize;
static float ySize;


@implementation VolumeView

@synthesize drawAndScrollController;
@synthesize bottonView;

@synthesize historicData;
@synthesize chartFrame;
@synthesize chartFrameOffset;
@synthesize xLines,yLines;

@synthesize zoomTransform;


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	}
	return self;
}

- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset{
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		
		chartFrame = frame;
		chartFrameOffset = offset;
		
		drawAndScrollController = nil;
        dataLock = [[NSRecursiveLock alloc]init];
        AVSArray = [[NSMutableArray alloc]init];
        AVLArray = [[NSMutableArray alloc]init];
	}
	
	return self;
}


- (void)drawRect:(CGRect)rect {
    [dataLock lock];
    chartFrameOffset = drawAndScrollController.chartFrameOffset;
    NSString * period;
    
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
    NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	volParameter1 = [(NSNumber *)[parmDict1 objectForKey:@"AVSparameter"]intValue];
    volParameter2 = [(NSNumber *)[parmDict1 objectForKey:@"AVLparameter"]intValue];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context,rect);
	
	// Drawing code

    xSize = chartFrame.size.width;
    ySize = chartFrame.size.height;

	//畫chart frame邊框
    [drawAndScrollController drawBottomChartFrameWithOffset:chartFrameOffset frameWidth:xSize frameHeight:ySize];

    UInt32 dataCount = [historicData tickCount:drawAndScrollController.historicType];
    if (dataCount == 0){
        [dataLock unlock];
        return;
    }

    BOOL isDayLine = drawAndScrollController.analysisPeriod == AnalysisPeriodDay;

	NSInteger offsetXvalue = chartFrameOffset.x;
	NSInteger offsetYvalue = chartFrameOffset.y;
    
	
	xScale = (float)xSize / xLines;
	yScale = (float)ySize / yLines;		
	
	
#pragma mark ---------------------------------------------------------------- 畫邊框 與 ＸＹ軸刻度線	

	//畫橫線
	[drawAndScrollController drawChartFrameYScaleWithChartOffset:CGPointMake(0, 1) frameWidth:xSize frameHeight:ySize yLines:yLines lineIncrement:2];

    //畫直線
    if (isDayLine) {
        //畫直線
		//[drawAndScrollController drawChartFrameXScaleWithChartOffset:chartFrameOffset frameWidth:xSize frameHeight:ySize xLines:xLines xScaleType:2];
        [drawAndScrollController drawMonthLineWithChartFrame:chartFrame xLines:xLines offsetStartPoint:chartFrameOffset];
    }
    else {
        [drawAndScrollController drawDateGridWithChartFrame:chartFrame xLines:xLines offsetStartPoint:chartFrameOffset];
    }

	
	
#pragma mark ---------------------------------------------------------------- 畫量 長條圖
    
    float xSize;
    if (drawAndScrollController.penBtn.selected == YES) {
        xSize = drawAndScrollController.indexScaleView.frame.size.width;
    }else{
        xSize = drawAndScrollController.indexScaleView.frame.size.width-offsetXvalue;
    }
    
    float winLocationX;
    if(xSize<273)
        winLocationX = 0;
    else
        winLocationX = drawAndScrollController.indexScaleView.frame.origin.x;
    
    
    NSInteger dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
    NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
	
// 歷史最高量: highestVolume
// 歷史最低量:	 lowestVolume
//		
	int fontSLIindex;
	int rearSLIindex;

	fontSLIindex = 0;
	rearSLIindex = dataCount - 1; 				
	
	float lowestVolume = drawAndScrollController.theLowestVolume;
    float highestVolume = drawAndScrollController.theHighestVolume;
    
    
    
    
    
    
    
    
    
    
#pragma mark ---------------------------------------------------------------- 畫線圖
    
    
    NSMutableArray *avParameterArray = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:volParameter2],[NSNumber numberWithInt:volParameter1],nil];
    
    [AVLArray removeAllObjects];
    [AVSArray removeAllObjects];
    
    int n,m,seq, count,i;
    float sum;
    DecompressedHistoricData *hist;
    
    for (n = 0; n < [avParameterArray count]; n++)
    {
        m = [(NSNumber *)[avParameterArray objectAtIndex:n]intValue];
        
        if (rearSLIindex < m)
            continue;
        
        sum = 0;
        count = 0;
        seq = 0;
        
        for (i = fontSLIindex; i <= rearSLIindex; i++)
        {
            hist = [self.historicData copyHistoricTick:type sequenceNo:i];
            seq = i;
            
            if (hist == nil)
            {
                
                if(n == 0)
                    [AVLArray addObject:(NSNumber *)kCFNumberNaN];
                else if(n == 1)
                    [AVSArray addObject:(NSNumber *)kCFNumberNaN];
                
                continue;
                
            }
            
            sum += hist.volume * pow(1000,hist.volumeUnit);
            
            if (count >= m)
            {
                
                hist = [self.historicData copyHistoricTick:type sequenceNo:seq-m];
                sum -= hist.volume * pow(1000,hist.volumeUnit);
                
                if(n == 0)
                    [AVLArray addObject:[NSNumber numberWithFloat:(sum / m)]];
                else if(n == 1)
                    [AVSArray addObject:[NSNumber numberWithFloat:(sum / m)]];
            }
            else if (count == m-1)
            {
                
                if(n == 0)
                    [AVLArray addObject:[NSNumber numberWithFloat:(sum / m)]];
                else if(n == 1)
                    [AVSArray addObject:[NSNumber numberWithFloat:(sum / m)]];
            }
            
            else
            {
                
                if(n == 0)
                    [AVLArray addObject:(NSNumber *)kCFNumberNaN];
                else if(n == 1)
                    [AVSArray addObject:(NSNumber *)kCFNumberNaN];
            }
            seq++;
            count++;
        }
        
    }
    // drawing
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGMutablePathRef path2 = CGPathCreateMutable();
    seq=0;
    
    fontSLIindex = 0;
    rearSLIindex = dataCount - 1;
    
    //DecompressedHistoricData *historic;
    BOOL first = TRUE;
    float avs, avl;
    float heightMaxValue = fabs(highestVolume - lowestVolume);
    
    for (NSUInteger i = dataStartIndex; i < dataEndIndex; i++) {
        
        seq = (int)i;
        
        if (seq >= volParameter1-1) {
            
            avs = [(NSNumber *)[AVSArray objectAtIndex:seq] floatValue];
            
            
            // x軸座標值：
            float xValue = i * xScale;
            float yValueOfK;
            // y軸座標值：
            if (heightMaxValue==0) {
                yValueOfK = 0;
            }else{
                yValueOfK = (avs - lowestVolume) * ySize / heightMaxValue;
            }
            
            
            if (first) {
                //AVS init point
                CGPathMoveToPoint(path1, NULL, offsetXvalue + xValue, ySize - yValueOfK + chartFrameOffset.y);
                
                first = FALSE;
            }
            
            CGPathAddLineToPoint(path1, NULL, xValue + offsetXvalue, ySize - yValueOfK + chartFrameOffset.y);
            
            CGContextStrokePath(context);
        }
        
        seq++;
    }
    
    
    CGContextAddPath(context,path1);
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor magentaColor] set];
    CGContextStrokePath(context);
    CGPathRelease(path1);
    
    first = TRUE;
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {
        
        seq = (int)i;
        
        if (seq >= volParameter2-1) {
            
            avl = [(NSNumber *)[AVLArray objectAtIndex:seq] floatValue];
            
            
            // x軸座標值：
            float xValue = i * xScale;
            
            float yValueOfK;
            // y軸座標值：
            if (heightMaxValue==0) {
                yValueOfK = 0;
            }else{
                yValueOfK = (avl - lowestVolume) * ySize / heightMaxValue;
            }
            
            if (first) {
                //AVS init point
                CGPathMoveToPoint(path2, NULL, offsetXvalue + xValue, ySize - yValueOfK + chartFrameOffset.y);
                
                first = FALSE;
            }
            
            CGPathAddLineToPoint(path2, NULL, xValue + offsetXvalue, ySize - yValueOfK + chartFrameOffset.y);
            
            CGContextStrokePath(context);
        }
        
        seq++;
    }
    
    CGContextAddPath(context,path2);
    CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1] set];
    CGContextStrokePath(context);
    CGPathRelease(path2);
    
    
    
    
    
    
    

    UInt8 maxUnit = drawAndScrollController.maxVolumeUnit;
    const float *unitBase = [DrawAndScrollController valueUnitBase];

	float rectWidth = drawAndScrollController.chartBarWidth;
	//資料陣列index最小的值 為最老的資料
	float longRectWidth = rectWidth;

	DecompressedHistoricData *histData;
	float volume;
	
	
	for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {
		
		histData = [historicData copyHistoricTick:type sequenceNo:(int)i];
		if (histData == nil)continue;
		
		float currentvolume = histData.volume;

        if (histData.volumeUnit > maxUnit)
            currentvolume *= unitBase[histData.volumeUnit - maxUnit];

		volume = (currentvolume - lowestVolume)/(highestVolume-lowestVolume) * ySize;
				
		//NSLog(@"index:(%d) volume:%.1f unit:%d--- High:%.1f Low:%.1f",i,volume,histData.volumeUnit,highestVolume,lowestVolume);
		
        // x軸座標值：
        float xValue = i * xScale;		
		
		//著色
		if(histData.open > histData.close)
			[[StockConstant PriceDownColor] set];
		else if (histData.open < histData.close)
			[[StockConstant PriceUpColor] set];
        else
            [[UIColor colorWithRed:6.0f/255.0f green:158.0f/255.0f blue:234.0f/255.0f alpha:1.0f]set];
		
		CGRect longRect = CGRectMake(xValue + offsetXvalue, ySize + offsetYvalue - volume, longRectWidth, volume);
		CGContextAddRect(context, longRect);		
		CGContextFillPath(context);		
		
		
	}


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

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3{
//    UInt8 type = drawAndScrollController.historicType;
//	DecompressedHistoricData *histData;
//	double volume = 0;
//    
//	UInt8 maxUnit = drawAndScrollController.maxVolumeUnit;
//
//    const float *unitBase = [DrawAndScrollController valueUnitBase];
//	histData = [historicData copyHistoricTick:type sequenceNo:index];
//	if (histData == nil)
//	{
//		*value1 = 0;
//	}
//	else
//	{
//		volume = histData.volume;
//		if (histData.volumeUnit > maxUnit)
//			volume *= unitBase[histData.volumeUnit - maxUnit];
//	}
//	*value1 = volume;
//	*value2 = 0;
//	*value3 = 0;
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

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3 Value4:(double *)value4{
    
    double volValue = 0, vol2Value=0,beforeVol1=0,beforeVol2 = 0;
    
    NSMutableArray * avs = AVSArray;
    NSMutableArray * avl = AVLArray;
    
    if (index<[avs count] && index >=volParameter1-1) {
        volValue = [(NSNumber *)[avs objectAtIndex:index]doubleValue];
        beforeVol1 = [(NSNumber *)[avs objectAtIndex:index-1]doubleValue];
    }
    
    if (index<[avl count] && index >=volParameter2-1) {
        vol2Value = [(NSNumber *)[avl objectAtIndex:index]doubleValue];
        beforeVol2 = [(NSNumber *)[avl objectAtIndex:index-1]doubleValue];
    }
    
    *value1 = volValue;
	*value2 = beforeVol1;
	*value3 = vol2Value;
    *value4 = beforeVol2;
}

@end
