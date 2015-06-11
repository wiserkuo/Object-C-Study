//
//  IndexView.m
//  BullsEyeAlpha
//
//  Created by Ming-Zhe Wu on 2008/10/13.
//  Copyright 2008 NHCUE. All rights reserved.
//

#import "IndexView.h"
#import "drawAndScrollController.h"
#import "UpperValueView.h"


//#define BarWidthRatio 1.4


static float xSize;
static float ySize;


@implementation IndexView

@synthesize historicData;

@synthesize drawAndScrollController;

@synthesize chartFrame;
@synthesize chartFrameOffset;
@synthesize xLines,yLines;
@synthesize xScale,yScale;

@synthesize historicDataIndexes;
@synthesize zoomTransform;
@synthesize compHighScale, compLowScale;


-(void)awakeFromNib{
	
}

- (id)init 
{
    if (self = [super init]) 
	{
		yLines = 6;
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame 
{
	if (self = [super initWithFrame:frame])
	{
		// Initialization code
		
	}
	return self;
}

- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset
{
	if (self = [super initWithFrame:frame]) 
	{
		// Initialization code
		
		chartFrame = frame;
		chartFrameOffset = offset;
		baseIndex = -1;
		refIndex[0] = refIndex[1] = refIndex[2] = refIndex[3] = refIndex[4] = refIndex[5] = -1;
        historicDataIndexes = [[NSMutableArray alloc] initWithCapacity:MaximumHistoricDays+30];
		
        tmpArray1 = [[NSMutableArray alloc] init];
        tmpArray2 = [[NSMutableArray alloc] init];
        tmpArray3 = [[NSMutableArray alloc] init];
        tmpArray4 = [[NSMutableArray alloc] init];
        tmpArray5 = [[NSMutableArray alloc] init];
        tmpArray6 = [[NSMutableArray alloc] init];
		//newSBtnArray = [[NSMutableArray alloc] init];
		dataLock = [[NSRecursiveLock alloc]init];
		
	}
	
	return self;
}

- (void)setBaseIndex:(NSInteger)index
{
	
    NSUInteger count =1;
	id target;
	baseIndex = index;
	if(index == -1)
	{
		refIndex[0] = refIndex[1] = refIndex[2] = refIndex[3] = refIndex[4] = refIndex[5] = -1;
		return;
	}
	UInt8 type = drawAndScrollController.historicType;
 	DecompressedHistoricData *histB = [historicData copyHistoricTick:type sequenceNo:(int)baseIndex];
	//UInt16 date = histB.date;
	
    for (int i = 0; i < count; i++) 
	{
		refIndex[i] = -1;
        if (target != nil)
		{
			UInt32 countT = 0;//[target.historicData tickCount:type];
			if(countT == 0)
				continue;
			for(int j=0; j<countT; j++)
			{
				DecompressedHistoricData *hist = nil;//[target.historicData copyHistoricTick:type sequenceNo:j];
				if(histB.date == hist.date)
				{
					
					if (drawAndScrollController.analysisPeriod >= AnalysisPeriod5Minute) 
					{
						DecompressedHistoric5Minute *hist5Min = (DecompressedHistoric5Minute *)hist;
						DecompressedHistoric5Minute *histB5Min = (DecompressedHistoric5Minute *)histB;
						if(histB5Min.time == hist5Min.time)
						{
							refIndex[i] = j;
						}
						else
							continue;
					}
					else
					{
						refIndex[i] = j;
						break;
					}
				}
				
			}
			if(refIndex[i] == -1)
			{
				baseIndex = refIndex[0] = refIndex[1] = refIndex[2] = refIndex[3] = refIndex[4] = refIndex[5] = -1;
				return;
			}
		}
		
    }
	
}

// 多走勢最高最低值
- (void)updateCompScale:(id<HistoricTickDataSourceProtocol>)compHistData refIndex:(NSInteger)index
{
	
    UInt8 type = drawAndScrollController.historicType;
    UInt32 count = [compHistData tickCount:type];
    if (count == 0) return;
	
    //UInt32 end = count - 1;
	UInt32 end = count - 1;
	
    float scale;
	
	//  DecompressedHistoricData *hist = [compHistData copyHistoricTick:type sequenceNo:count - 1];
	int xx = (int)index;
	if(index == -1)
		xx = count-1;
	DecompressedHistoricData *hist = [compHistData copyHistoricTick:type sequenceNo:xx];
	
    float ref = hist.close;
	
    for (int i = 0; i < end; i++) 
	{
		
        hist = [compHistData copyHistoricTick:type sequenceNo:i];
        scale = (hist.close - ref) / ref;
		
        if (compHighScale < scale) compHighScale = scale;
        if (compLowScale > scale) compLowScale = scale;
    }
}


- (CGFloat)comparisonYfromPrice:(float)price
{
	
    UInt8 type = drawAndScrollController.historicType;
    UInt32 count = [historicData tickCount:type];
    if (count == 0) return 0;
	DecompressedHistoricData *hist;
	if(baseIndex == -1)
		hist = [historicData copyHistoricTick:type sequenceNo:count-1];
    else
		hist = [historicData copyHistoricTick:type sequenceNo:(int)baseIndex];
	
	float ref = hist.close;
	return chartFrameOffset.y + ySize - ((price - ref) / ref - compLowScale) / (compHighScale - compLowScale) * ySize;
}


- (void)drawComparison:(id<HistoricTickDataSourceProtocol>)compHistData refIndex:(NSInteger)index from:(int)startIndex to:(int)endIndex oldestDate:(NSDate *)oldestDate 
{
	
    UInt8 type = drawAndScrollController.historicType;
    UInt32 count = [compHistData tickCount:type];
    if (count == 0) return;
	
	// DecompressedHistoricData *hist = [compHistData copyHistoricTick:type sequenceNo:count-1];
	int xx = (int)index;
	if(index == -1)
		xx = count-1;
	DecompressedHistoricData *hist = [compHistData copyHistoricTick:type sequenceNo:xx];
    
    float ref = hist.close;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    float scaleRange = compHighScale - compLowScale;
    float x0 = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
    float y0 = chartFrameOffset.y + ySize + ySize * compLowScale / scaleRange;
    float yFactor = ySize / ref / scaleRange;
	
    AnalysisPeriod period = drawAndScrollController.analysisPeriod;
    BOOL first = YES;
    int seq = 0;
	
    UInt16 date, curDate;
    float price, x, y;
	
    if (period < AnalysisPeriod5Minute)
	{
		
        BOOL isMain = compHistData == historicData;
        //BOOL isDaily = period == AnalysisPeriodDay;
		
        NSComparisonResult r;
		
        if (isMain) 
		{
            [historicDataIndexes removeAllObjects];
            for (int i = 0; i < startIndex; i++)
                [historicDataIndexes addObject:[NSNull null]];
        }
		
        for (int i = startIndex; i <= endIndex; i++) 
		{
			
            hist = [historicData copyHistoricTick:type sequenceNo:i];
			
            curDate = hist.date;
			
            price = 0;
			
            for ( ; seq < count; seq++) 
			{
				
                hist = [compHistData copyHistoricTick:type sequenceNo:seq];
                if (hist == nil) continue;
				
                date = hist.date;
                r = [HistoricDataAgent compareDate:date with:curDate forPeriod:period];
                if (r == 0) 
				{
                    price = hist.close;
                    seq++;
                }
				
                if (r >= 0) break;
            }
			
            if (price == 0) continue;
			
            x = x0 + xScale * i;
			y = y0 - yFactor * (price - ref);
			
            if (first) 
			{
                CGContextMoveToPoint(context, x, y);
                first = NO;
            }
			
            CGContextAddLineToPoint(context, x, y);
        }
    }
    else 
	{
        DecompressedHistoric5Minute *hist5Min;
        UInt16 time, curTime;
		
        for (int i = startIndex; i <= endIndex; i++)
		{
			
            hist5Min = [historicData copyHistoricTick:type sequenceNo:i];
            if (hist5Min == nil) continue;
			
            curDate = hist5Min.date;
            curTime = hist5Min.time;
			
            price = 0;
			
            for ( ; seq < count; seq++)
			{
				
                hist5Min = [compHistData copyHistoricTick:type sequenceNo:seq];
                if (hist5Min == nil) continue;
				
                date = hist5Min.date;
                time = hist5Min.time;
                if (date == curDate && time == curTime)
				{
                    price = hist5Min.close;
                    seq++;
                }
				
                if (date > curDate || (date == curDate && time >= curTime))
                    break;
            }
			
            if (price == 0) continue;
			
            x = x0 + xScale * i;
			y = y0 - yFactor * (price - ref);
			
            if (first) 
			{
                CGContextMoveToPoint(context, x, y);
                first = NO;
            }
			
            CGContextAddLineToPoint(context, x, y);
        }
    }
	
    //CGContextStrokePath(context);
}


- (void)drawComparisonFrom:(int)startIndex to:(int)endIndex oldestDate:(NSDate *)oldestDate 
{
    NSUInteger count =0;// comparison.targetCount;
//    id target;
	
    compHighScale = compLowScale = 0;
    [self updateCompScale:historicData refIndex:baseIndex];
	
    for (int i = 0; i < count; i++) 
	{
//        if (target != nil)
//            [self updateCompScale:target.historicData refIndex:refIndex[i]];
    }
	
    if (compHighScale == compLowScale) 
	{
        compHighScale += 0.01;
        compLowScale -= 0.01;
    }
	
    [drawAndScrollController.upperValueView updateLabels];
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, drawAndScrollController.chartZoomOrigin);
	
    for (int i = 0; i < count; i++) 
	{
		
//        if (target == nil) continue;
//		
//        [target.color set];
//        [self drawComparison:target.historicData refIndex:refIndex[i] from:startIndex to:endIndex oldestDate:oldestDate];
    }
	
    [[UIColor whiteColor] set];
    [self drawComparison:historicData refIndex:baseIndex from:startIndex to:endIndex oldestDate:oldestDate];
}

- (double)getMovingAvergeValueFrom:(int)index parm:(int)maType{
    [dataLock lock];
//    NSLog(@"[dataLock lock][dataLock lock][dataLock lock]");
	if(maType==0){
		
        if(index < [tmpArray1 count]){
            [dataLock unlock];
			return [(NSNumber *)[tmpArray1 objectAtIndex:index]floatValue];
        }
        else{
            [dataLock unlock];
			return -1;
        }
		
	}
	
	else if(maType==1){
		
        if(index < [tmpArray2 count]){
            [dataLock unlock];
            return [(NSNumber *)[tmpArray2 objectAtIndex:index]floatValue];
        }
        else{
            [dataLock unlock];
            return -1;
        }
		
	}

	else if(maType==2){
		
        if(index < [tmpArray3 count]){
            [dataLock unlock];
            return [(NSNumber *)[tmpArray3 objectAtIndex:index]floatValue];
        }
        else{
            [dataLock unlock];
            return -1;
        }
		
	}
    else if(maType==3){
		
        if(index < [tmpArray4 count]){
            [dataLock unlock];
            return [(NSNumber *)[tmpArray4 objectAtIndex:index]floatValue];
        }
        else{
            [dataLock unlock];
            return -1;
        }
		
	}
    else if(maType==4){
		
        if(index < [tmpArray5 count]){
            [dataLock unlock];
            return [(NSNumber *)[tmpArray5 objectAtIndex:index]floatValue];
        }
        else{
            [dataLock unlock];
            return -1;
        }
		
	}
    else if(maType==5){
		
        if(index < [tmpArray6 count]){
            [dataLock unlock];
            return [(NSNumber *)[tmpArray6 objectAtIndex:index]floatValue];
        }
        else{
            [dataLock unlock];
            return -1;
        }
		
    }else{
        [dataLock unlock];
        return -1;
    }
    
//    NSLog(@"[dataLock unlock][dataLock unlock][dataLock unlock]");
}

#pragma mark 移動平均線*3 (短線 中線 長線)
- (void)drawMovingAverageFrom:(int)startIndex to:(int)endIndex oldestDate:(NSDate *)oldestDate 
{
	
    UIColor *colors[] = { [UIColor colorWithRed:(float)126/256 green:(float)68/256 blue:(float)200/256 alpha:1], 
		[UIColor colorWithRed:(float)255/256 green:(float)81/256 blue:(float)139/256 alpha:1],
		[UIColor orangeColor] };
	
	
    float xOffset = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
    float bottom = chartFrameOffset.y + ySize;
    float x, y, sum;
    int n, i;
	
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, drawAndScrollController.chartZoomOrigin);
	
    float levelHigh = drawAndScrollController.theHighestValue;
    float levelLow = drawAndScrollController.theLowestValue;
//    NSLog(@"==========levelHigh %f", levelHigh);
//    NSLog(@"==========levelLow %f", levelLow);
    
    float diff = levelHigh - levelLow;
	BOOL first = YES;
    for (n = 0; n < 3; n++)
	{
		CGMutablePathRef path = CGPathCreateMutable();
        [colors[n] set];
        sum = 0;
		for (i = startIndex; i <= endIndex; i++) 
		{
			if(n==0)
			{
				sum = [self getMovingAvergeValueFrom:i parm:0];
			}
			else if(n==1)
			{
				sum = [self getMovingAvergeValueFrom:i parm:1];;
			}
			else if(n==2)
			{
				sum = [self getMovingAvergeValueFrom:i parm:2];;
			}
            //TODO： diff 有時候會是空值或是nan，進而造成除以零而crash
            x = i * xScale + xOffset;
			y = bottom - (sum - levelLow) * ySize / diff;
            
            if (isnan(sum) || diff == 0)
                continue;

			if (first)
			{
                first = NO;
                CGPathMoveToPoint(path, NULL, x, y);
            }
            else
                CGPathAddLineToPoint(path, NULL, x, y);
            
			
		}
		
//        CGContextAddPath(context, path);
//		CGContextStrokePath(context);
		CGPathRelease(path);
		first = YES;
    }
}



- (double)getBollingerFrom:(int)index parm:(int)maType
{
	
	if(maType == 0)
	{ // MA
		
		if(index < [tmpArray3 count])
			return [(NSNumber *)[tmpArray3 objectAtIndex:index]floatValue];
		else
			return -1;
		
	}
	
	else if(maType == 1)
	{ // high BB
		
		if(index < [tmpArray1 count])
			return [(NSNumber *)[tmpArray1 objectAtIndex:index]floatValue];
		else
			return -1;		
		
	}
	
	else if(maType == 2)
	{ // low BB
		
		if(index < [tmpArray2 count])
			return [(NSNumber *)[tmpArray2 objectAtIndex:index]floatValue];
		else
			return -1;
		
	}
	else return -1;
	
	
}


#pragma mark 布林線
- (void)drawBollingerFrom:(int)startIndex to:(int)endIndex oldestDate:(NSDate *)oldestDate
{
	
    float levelHigh = drawAndScrollController.theHighestValue;
    float levelLow = drawAndScrollController.theLowestValue;
	
	//以布林格的參數 畫移動平均線
	[self drawMovingAverageWithBollingerParmFrom:startIndex to:endIndex oldestDate:oldestDate];
	
    float x, y;
    NSNumber *number1, *number2;
	
    //BOOL isDaily = oldestDate != nil;
    BOOL first1 = YES;
    BOOL first2 = YES;
    int seq = 0;
	
    float diff = levelHigh - levelLow;
    float xOffset = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
    float bottom = chartFrameOffset.y + ySize;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGMutablePathRef path2 = CGPathCreateMutable();
	
    CGContextSetLineWidth(context, drawAndScrollController.chartZoomOrigin);
    [[UIColor colorWithRed:(float)185/256 green:(float)155/256 blue:(float)40/256 alpha:1]set];
	
    for (int i = startIndex; i <= endIndex; i++) 
	{
		
        seq = i;
        
        if (seq<[tmpArray1 count]){
            number1 = [tmpArray1 objectAtIndex:seq];
        }
        if (seq<[tmpArray2 count]) {
            number2 = [tmpArray2 objectAtIndex:seq];
        }
        
        seq++;
		
        x = i * xScale + xOffset;
		
		if ((id)number1 != (NSNumber *)kCFNumberNaN) 
		{
			
            y = bottom - ([(NSNumber *)number1 floatValue] - levelLow) * ySize / diff;
			
            if (first1) 
			{
                first1 = NO;
                CGPathMoveToPoint(path1, NULL, x, y);
            }
            else
                CGPathAddLineToPoint(path1, NULL, x, y);
        }
		
        if ((id)number2 != (NSNumber *)kCFNumberNaN) 
		{
			
            y = bottom - ([(NSNumber *)number2 floatValue] - levelLow) * ySize / diff;
			
            if (first2) 
			{
                first2 = NO;
                CGPathMoveToPoint(path2, NULL, x, y);
            }
            else
                CGPathAddLineToPoint(path2, NULL, x, y);
        }
    }
	
    //CGContextAddPath(context, path1);
    //CGContextStrokePath(context);
    CGPathRelease(path1);
	
    //CGContextAddPath(context, path2);
    //CGContextStrokePath(context);
    CGPathRelease(path2);
}


//#pragma mark 資訊地雷
/*
 - (void)drawInformationMineBtnFrom:(int)startIndex to:(int)endIndex oldestDate:(NSDate *)oldestDate {
 
 DataModalProc *dataModal = [DataModalProc getDataModal];
 
 DecompressedHistoricData *hist;
 UInt8 type = drawAndScrollController.historicType;
 
 for (int i = startIndex; i <= endIndex; i++) 
 {
 
 hist = [historicData copyHistoricTick:type sequenceNo:i]; 
 
 int newCount = [dataModal.informationMine getNewsCountByUInt16Date:hist.date];
 
 if(newCount > 0)
 {
 
 // get x , y 
 xScale = xSize / xLines;			
 yScale = ySize / yLines;
 
 float xOffset = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
 float bottom = chartFrameOffset.y + ySize;
 float theHighValue = drawAndScrollController.theHighestValue;
 float theLowValue = drawAndScrollController.theLowestValue;			
 float theHighLowSectionValue = theHighValue - theLowValue; //高低區間
 float x,y;
 
 float elementYValue = theHighLowSectionValue / yLines;
 x = i * xScale + xOffset;
 y = bottom - (hist.high - theLowValue)/elementYValue*yScale;
 
 
 // make new btn 
 //[self madeBtnByTime: newsIndex:i newsSN:newsSN offset:chartFrameOffset size:chartRect.size];
 UIButton *newsBtn = [[UIButton alloc]init];
 UIImage *newImage = [UIImage imageNamed:@"news-icon-06.png"];
 [newsBtn setBackgroundImage:newImage forState:UIControlStateNormal];	
 newsBtn.frame = CGRectMake(x, y, 30.0, 30.0); //btn中央點對準相對映的時間刻度
 newsBtn.backgroundColor = [UIColor clearColor];		
 //newsBtn.tag = newsSN; // tag 放 news SN !!!!!!
 [newsBtn addTarget:drawAndScrollController action:@selector(newsClick:) forControlEvents:UIControlEventTouchUpInside];
 [self addSubview:newsBtn];
 [self bringSubviewToFront:newsBtn];
 [newSBtnArray addObject:newsBtn];
 [newsBtn release];
 
 }
 
 [hist release];
 }
 
 }
 */
-(BOOL)prepareDataToDraw
{
    
    [dataLock lock];
    NSString * period;
    
    if (drawAndScrollController.analysisPeriod==AnalysisPeriodDay) {
        period = @"dayLine";
    }else if (drawAndScrollController.analysisPeriod==AnalysisPeriodWeek){
        period = @"weekLine";
    }else if (drawAndScrollController.analysisPeriod==AnalysisPeriodMonth){
        period = @"monthLine";
    }else {
        period = @"minuteLine";
    }
	UInt32 seqCount = [historicData tickCount:kTickTypeDay];
    if (seqCount == 0){
        [dataLock unlock];
        return NO;
    }
	BOOL bChange = NO;
    xScale = xSize / xLines;
    yScale = ySize / yLines;
	
	int totalDayCnt = [historicData tickCount:drawAndScrollController.analysisPeriod];
	
    int startIndex = 0;
    int endIndex = startIndex + totalDayCnt - 1;
	
	if(drawAndScrollController.upperViewIndicator == UpperViewMAIndicator)  //MA
	{
		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
		int MA1Parameter = [dataModal.indicator getValueInNewIndicatorByParameter:@"MA1" Period:period];
		
		int MA2Parameter = [dataModal.indicator getValueInNewIndicatorByParameter:@"MA2" Period:period];
		
		int MA3Parameter = [dataModal.indicator getValueInNewIndicatorByParameter:@"MA3" Period:period];
        
        int MA4Parameter = [dataModal.indicator getValueInNewIndicatorByParameter:@"MA4" Period:period];
		
		int MA5Parameter = [dataModal.indicator getValueInNewIndicatorByParameter:@"MA5" Period:period];
		
		int MA6Parameter = [dataModal.indicator getValueInNewIndicatorByParameter:@"MA6" Period:period];
		
		
		NSMutableArray *maParameterArray = [[NSMutableArray alloc]initWithObjects:
											[NSNumber numberWithInt:MA1Parameter],
											[NSNumber numberWithInt:MA2Parameter],
											[NSNumber numberWithInt:MA3Parameter],
                                            [NSNumber numberWithInt:MA4Parameter],
											[NSNumber numberWithInt:MA5Parameter],
											[NSNumber numberWithInt:MA6Parameter],nil];
		
		
		DecompressedHistoricData *hist;
		UInt8 type = drawAndScrollController.historicType;
		float sum;
		int n, i, m, seq, count;
		
		[tmpArray1 removeAllObjects];
		[tmpArray2 removeAllObjects];
		[tmpArray3 removeAllObjects];
        [tmpArray4 removeAllObjects];
		[tmpArray5 removeAllObjects];
		[tmpArray6 removeAllObjects];
		
		for (n = 0; n < [maParameterArray count]; n++) 
		{
			m = [(NSNumber *)[maParameterArray objectAtIndex:n]intValue];
			
			if (endIndex < m)
				continue;
			
			sum = 0;
			count = 0;
			seq = 0;
			
			for (i = startIndex; i <= endIndex; i++) 
			{
				hist = [historicData copyHistoricTick:type sequenceNo:i];
				seq = i;
				
				if (hist == nil)
				{
					
					if(n == 0) 
						[tmpArray1 addObject:(NSNumber *)kCFNumberNaN];
					else if(n == 1)
						[tmpArray2 addObject:(NSNumber *)kCFNumberNaN];
					else if(n == 2)
						[tmpArray3 addObject:(NSNumber *)kCFNumberNaN];
					else if(n == 3)
						[tmpArray4 addObject:(NSNumber *)kCFNumberNaN];
					else if(n == 4)
						[tmpArray5 addObject:(NSNumber *)kCFNumberNaN];
                    else if(n == 5)
						[tmpArray6 addObject:(NSNumber *)kCFNumberNaN];
										
					continue;
					
				}
				
				sum += hist.close;
				
				if (count >= m) 
				{
					
					hist = [historicData copyHistoricTick:type sequenceNo:seq-m];
					sum -= hist.close;
					
					if(n == 0) 
						[tmpArray1 addObject:[NSNumber numberWithFloat:(sum / m)]];
					else if(n == 1)
						[tmpArray2 addObject:[NSNumber numberWithFloat:(sum / m)]];
					else if(n == 2)
						[tmpArray3 addObject:[NSNumber numberWithFloat:(sum / m)]];
                    else if(n == 3)
						[tmpArray4 addObject:[NSNumber numberWithFloat:(sum / m)]];
					else if(n == 4)
						[tmpArray5 addObject:[NSNumber numberWithFloat:(sum / m)]];
                    else if(n == 5)
						[tmpArray6 addObject:[NSNumber numberWithFloat:(sum / m)]];
					
				}
				else if (count == m-1) 
				{
					
					if(n == 0)
						[tmpArray1 addObject:[NSNumber numberWithFloat:(sum / m)]];
					else if(n == 1)
						[tmpArray2 addObject:[NSNumber numberWithFloat:(sum / m)]];
					else if(n == 2)
						[tmpArray3 addObject:[NSNumber numberWithFloat:(sum / m)]];
                    else if(n == 3)
						[tmpArray4 addObject:[NSNumber numberWithFloat:(sum / m)]];
					else if(n == 4)
						[tmpArray5 addObject:[NSNumber numberWithFloat:(sum / m)]];
                    else if(n == 5)
						[tmpArray6 addObject:[NSNumber numberWithFloat:(sum / m)]];
					
				}
				
				else
				{
					
					if(n == 0)
						[tmpArray1 addObject:(NSNumber *)kCFNumberNaN];
					else if(n == 1)
						[tmpArray2 addObject:(NSNumber *)kCFNumberNaN];
					else if(n == 2)
						[tmpArray3 addObject:(NSNumber *)kCFNumberNaN];
					else if(n == 3)
						[tmpArray4 addObject:(NSNumber *)kCFNumberNaN];
					else if(n == 4)
						[tmpArray5 addObject:(NSNumber *)kCFNumberNaN];
                    else if(n == 5)
						[tmpArray6 addObject:(NSNumber *)kCFNumberNaN];
					
				}
				
				seq++;
				count++;
			}
			
		}
		
	}
	else if(drawAndScrollController.upperViewIndicator == UpperViewBBIndicator) // BB
	{
		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
		NSMutableDictionary *parmDict1 = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeBB];		
		//int bbNum = [(NSNumber *)[parmDict1 objectForKey:@"indicatorParameter1"]intValue];
        int bbNum = [dataModal.indicator getValueInNewIndicatorByParameter:@"BB" Period:period];
		DecompressedHistoricData *hist;
		UInt8 type = drawAndScrollController.historicType;
		
		float sum;
		int i, m, seq, count;
		
		m = bbNum;
		sum = 0;
		count = 0;
		seq = 0;
		[tmpArray3 removeAllObjects];
		
		for (i = startIndex; i <= endIndex; i++)
		{
			hist = [historicData copyHistoricTick:type sequenceNo:i];
			seq = i;
			if (hist == nil)
			{
				[tmpArray3 addObject:(NSNumber *)kCFNumberNaN];
				continue;
			}
			sum += hist.close;
			
			if (count >= m) 
			{
				hist = [historicData copyHistoricTick:type sequenceNo:seq-m];
				sum -= hist.close;
				[tmpArray3 addObject:[NSNumber numberWithFloat:(sum / m)]];
				
			}
			else if (count == m-1) 
			{
				[tmpArray3 addObject:[NSNumber numberWithFloat:(sum / m)]];
				
			}
			else
			{
				[tmpArray3 addObject:(NSNumber *)kCFNumberNaN];
			}
			
			seq++;
			count++;
		}
		////////////////////////
		parmDict1 = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeBB];		
		int devNum = [dataModal.indicator getValueInNewIndicatorByParameter:@"SD" Period:period];
		
		if (endIndex < bbNum){
            [dataLock unlock];
            return NO;
        }
		
		float price, ma, dev, upValue, downValue;
		
		count = [historicData tickCount:type];
		sum = 0;
		float sqrSum = 0;
		
		float levelHigh = drawAndScrollController.theHighestValue;
		float levelLow = drawAndScrollController.theLowestValue;
		
		[tmpArray1 removeAllObjects];
		[tmpArray2 removeAllObjects];
		
		for (int i = 0; i < count; i++) 
		{
			hist = [historicData copyHistoricTick:type sequenceNo:i];
			price = hist.close;
			
			sum += price;
			sqrSum += price * price;
			
			if (i >= bbNum - 1) 
			{
				
				if (i >= bbNum)
				{
					
					hist = [historicData copyHistoricTick:type sequenceNo:i-bbNum];
					price = hist.close;
					
					sum -= price;
					sqrSum -= price * price;
				}
				
				ma = sum / bbNum;
				dev = sqrSum / bbNum - sum * sum / (bbNum * bbNum);
				dev = dev >= 0 ? sqrtf(dev * devNum * devNum) : 0;
				
				upValue = ma + dev;
				downValue = ma > dev ? ma - dev : 0;
				
				if (levelHigh < upValue) levelHigh = upValue;
				if (levelLow > downValue) levelLow = downValue;
				
				[tmpArray1 addObject:[NSNumber numberWithFloat:upValue]];
				[tmpArray2 addObject:[NSNumber numberWithFloat:downValue]];
			}
			else
			{
				
				[tmpArray1 addObject:(NSNumber *)kCFNumberNaN];
				[tmpArray2 addObject:(NSNumber *)kCFNumberNaN];
			}
		}
		
		if(drawAndScrollController.theHighestValue != levelHigh)
		{
			drawAndScrollController.theHighestValue = levelHigh;
			bChange = YES;
		}
		if(drawAndScrollController.theLowestValue != levelLow)
		{
			drawAndScrollController.theLowestValue = levelLow;
			bChange = YES;
		}
        [dataLock unlock];
		return bChange;
		
	}
	[dataLock unlock];
	return NO;
}

// 畫 代入布林格參數的移動平均線
- (void)drawMovingAverageWithBollingerParmFrom:(int)startIndex to:(int)endIndex oldestDate:(NSDate *)oldestDate {
	
	
	
	[[UIColor colorWithRed:(float)126/256 green:(float)68/256 blue:(float)200/256 alpha:1] set];
	
	
    float xOffset = chartFrameOffset.x + drawAndScrollController.chartBarWidth / 2;
    float bottom = chartFrameOffset.y + ySize;
    float x, y, sum;
    int i;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, drawAndScrollController.chartZoomOrigin);
	CGMutablePathRef path = CGPathCreateMutable();
	
    float levelHigh = drawAndScrollController.theHighestValue;
    float levelLow = drawAndScrollController.theLowestValue;
    float diff = levelHigh - levelLow;
	BOOL first = YES;
    sum = 0;
    for (i = startIndex; i <= endIndex; i++)
	{
		sum = [self getBollingerFrom:i parm:0];
		x = i * xScale + xOffset;
		y = bottom - (sum - levelLow) * ySize / diff;
		if (first)
		{
			first = NO;
			//CGPathMoveToPoint(path, NULL, x, y);
		}
		//else
			//CGPathAddLineToPoint(path, NULL, x, y);
		
	}
	
	//CGContextAddPath(context, path);
    //CGContextStrokePath(context);
    CGPathRelease(path);
}

- (void)drawDayLine 
{
	
    CGFloat lineWidth = drawAndScrollController.chartZoomOrigin;
    xSize = chartFrame.size.width;
    ySize = chartFrame.size.height;
	
    //畫chart frame邊框
    [drawAndScrollController drawChartFrameWithChartOffset:CGPointMake(chartFrameOffset.x-lineWidth, chartFrameOffset.y-lineWidth)
												frameWidth:xSize+2*lineWidth frameHeight:ySize+2*lineWidth];
	
    UInt32 seqCount = [historicData tickCount:kTickTypeDay];
    if (seqCount == 0) return;
	
    xScale = xSize / xLines;
    yScale = ySize / yLines;
	
    NSDate *theOrdestDate = [drawAndScrollController getOldestDate];
	
	int totalDayCnt = [historicData tickCount:drawAndScrollController.analysisPeriod];
	
    int fontSLIindex = 0;
    int rearSLIindex = fontSLIindex + totalDayCnt - 1;
	
    //[drawAndScrollController drawChartFrameYScaleWithChartOffset:chartFrameOffset frameWidth:xSize frameHeight:ySize yLines:yLines]; //畫橫線
    [drawAndScrollController drawMonthLineWithChartFrame:chartFrame xLines:xLines offsetStartPoint:chartFrameOffset]; //畫月線
	
	
#pragma mark- (DayLine) draw Comparison, MovingAverage, Bollinger or InformationMine
	
	DecompressedHistoricData *histData;
	
//	if (drawAndScrollController.comparisonSettingController.comparing)
//	{
//		
//		[self drawComparisonFrom:fontSLIindex to:rearSLIindex oldestDate:theOrdestDate];
//		
//		int seq = 0;
//		for (int i = fontSLIindex; i <= rearSLIindex; i++) 
//		{
//			
//			histData = [historicData copyHistoricTick:kTickTypeDay sequenceNo:seq];
//			
//			if (histData != nil) 
//			{
//				[historicDataIndexes addObject:[NSNumber numberWithShort:seq]];
//				seq++;
//			}
//		}
//		[drawAndScrollController updateCrossView];
//		return;	
//	}
//	else
//	{
		
		if(drawAndScrollController.upperViewIndicator == UpperViewMAIndicator)
			[self drawMovingAverageFrom:fontSLIindex to:rearSLIindex oldestDate:theOrdestDate];		 // MA
		else if(drawAndScrollController.upperViewIndicator == UpperViewBBIndicator)
			[self drawBollingerFrom:fontSLIindex to:rearSLIindex oldestDate:theOrdestDate]; // BB
		//else if(drawAndScrollController.upperViewIndicator == UpperViewInformationMine) 
		//[self drawInformationMineBtnFrom:fontSLIindex to:rearSLIindex oldestDate:theOrdestDate]; // Information Mine
		
		
//	}
	
	
	
    
	
    //暫定我們所畫的chartFrame與此view的左上(0,0)? 有chartFrameOffset的差距
    NSInteger offsetXvalue = chartFrameOffset.x; 
    NSInteger offsetYvalue = chartFrameOffset.y; 
	
    //每一單位刻度的數值
    float elementCoordinateXValue = (float)xSize/xLines;
	
    // 漲、跌長方型的寬度
    float rectWidth = drawAndScrollController.chartBarWidth; // 長條圖的寬度
	
    //算刻度 不同的table有不同的刻度表示
    int lines;
	
    //根據區間資料的最高點與最低點決定diagram的最高刻度與最低刻度 （要考慮 能描繪出多少線段）
	
    // 再現定區間內 計算此區間 最高與最低數值 !!!
    float theHightValue = drawAndScrollController.theHighestValue;
    float theLowValue = drawAndScrollController.theLowestValue;
	
    //高低區間
    float theHightLowSectionValue = (theHightValue - theLowValue);
    
//    Michael
//    TODO:
//    當日高點與低點相同時會造成Crash，設定成return也未發現對畫面造成影響
//
    if (theHightLowSectionValue == 0) {
        return;
    }

    //決定畫幾條線 再標示刻度...
    lines = (int)yLines;
	
    float elementYValue = (float)theHightLowSectionValue/lines;
    float theLowestScaleValue = theLowValue;
	
    // elementYValue 與  elementCoordinateYValue 最好能為倍數關係
    float elementCoordinateYValue = ySize / lines;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    //著顏色長條圖 以及 最高價＆最低價線段
    CGRect longRect;
	
    
    float open, close;
	float h;
	
    UInt32 seq = 0;
	
    CGContextSetLineWidth(context, lineWidth);
	
    [historicDataIndexes removeAllObjects];
    for (int i = 0; i < fontSLIindex; i++)
        [historicDataIndexes addObject:[NSNull null]];
	
	
    //根據historic data畫k線圖
    for (int i = fontSLIindex; i <= rearSLIindex; i++) 
	{
		
		histData = [historicData copyHistoricTick:kTickTypeDay sequenceNo:seq]; // historicData : HistoricDataAgent
		
        if (histData != nil) 
		{
            [historicDataIndexes addObject:[NSNumber numberWithShort:seq]];
            seq++;
        }
		/*
		 else {
		 [historicDataIndexes addObject:[NSNull null]];
		 continue;
		 }
		 */
		
        // ! 從最老的data開始畫
        //資料陣列index最小的值 為最老的資料
		
        float longRectWidth = rectWidth;
        float longRectWidthCenter;
		
        longRectWidthCenter = rectWidth/2;
        longRectWidth = rectWidth;
		
        //連接最高點與最低點
        [[UIColor yellowColor] set];
		CGContextMoveToPoint(context, i*elementCoordinateXValue + offsetXvalue + longRectWidthCenter, ySize + offsetYvalue - (histData.high - theLowestScaleValue)/elementYValue *elementCoordinateYValue);
        CGContextAddLineToPoint(context, i*elementCoordinateXValue + offsetXvalue + longRectWidthCenter, ySize + offsetYvalue - (histData.low - theLowestScaleValue)/elementYValue *elementCoordinateYValue);
        //CGContextStrokePath(context);
		
        open = histData.open;
        close = histData.close;
		
        if ( open >= close) 
		{
			
            if (open == close)
                [[UIColor yellowColor] set];
            else
                [[StockConstant PriceDownColor] set]; // 台股下跌為綠色
			
            h = (open - close) / elementYValue * elementCoordinateYValue;
			
            //漲的長方圖
//			longRect = CGRectMake(i*elementCoordinateXValue + offsetXvalue,
//                                  (float)ySize + offsetYvalue - (float)(open - theLowestScaleValue) / elementYValue * elementCoordinateYValue,
//                                  longRectWidth,
//                                  h > 0.5 ? h : 0.5);   
		}
        else
		{
			
            [[StockConstant PriceUpColor] set]; // 台股上漲為紅色
			
            h = (close - open) / elementYValue * elementCoordinateYValue;
			
            //跌的長方圖
//			longRect = CGRectMake(i*elementCoordinateXValue + offsetXvalue,
//                                  (float)ySize + offsetYvalue - (float)(close - theLowestScaleValue)/elementYValue *elementCoordinateYValue,
//                                  longRectWidth,
//                                  h > 0.5 ? h : 0.5);			
        }
		
        if (longRect.size.height < 0.9)
            longRect.size.height = 0.9;
		
        //CGContextAddRect(context, longRect);
        //CGContextFillPath(context);
		
    }
	
}


- (void)drawHistoricLine
{
	
    CGFloat lineWidth = drawAndScrollController.chartZoomOrigin;
    xSize = chartFrame.size.width;
    ySize = chartFrame.size.height;
	
    //畫chart frame邊框
    [drawAndScrollController drawChartFrameWithChartOffset:CGPointMake(chartFrameOffset.x-lineWidth, chartFrameOffset.y-lineWidth)
												frameWidth:xSize+2*lineWidth frameHeight:ySize+2*lineWidth];
	
    UInt8 type = drawAndScrollController.historicType;
    UInt32 count = [historicData tickCount:type];
    if (count == 0) return;
	
    //每一單位刻度的數值
    xScale = xSize / xLines;
    yScale = ySize / yLines;
    
    //[drawAndScrollController drawChartFrameYScaleWithChartOffset:chartFrameOffset frameWidth:xSize frameHeight:ySize yLines:yLines]; //畫橫線
    [drawAndScrollController drawDateGridWithChartFrame:chartFrame xLines:xLines offsetStartPoint:chartFrameOffset];     //畫直線
	
#pragma mark- draw Comparison, MovingAverage, Bollinger or InformationMine
	
//    if (drawAndScrollController.comparisonSettingController.comparing)
//	{
//		
//        [self drawComparisonFrom:0 to:count-1 oldestDate:nil];
//		[drawAndScrollController updateCrossView];
//        return;
//    }
//	else
//	{
		
		if(drawAndScrollController.upperViewIndicator == UpperViewMAIndicator)	
			[self drawMovingAverageFrom:0 to:count-1 oldestDate:nil];	//MA	
		else if(drawAndScrollController.upperViewIndicator == UpperViewBBIndicator)	
			[self drawBollingerFrom:0 to:count-1 oldestDate:nil]; // BB
		//else if(drawAndScrollController.upperViewIndicator == UpperViewInformationMine)
		//[self drawInformationMineBtnFrom:0 to:count-1 oldestDate:nil]; // Information Mine
		
//	}
	
	
	
    //暫定我們所畫的chartFrame與此view的左上(0,0)? 有chartFrameOffset的差距
    NSInteger offsetXvalue = chartFrameOffset.x; //與x軸差了chartFrameOffset.x個pixel
    NSInteger offsetYvalue = chartFrameOffset.y; //與y軸差了chartFrameOffset.y個pixel
	
    //漲、跌長方型的寬度
    float rectWidth = drawAndScrollController.chartBarWidth; // 長條圖的寬度
	
    //再現定區間內 計算此區間 最高與最低數值 !!!
    float theHighValue = drawAndScrollController.theHighestValue;
    float theLowValue = drawAndScrollController.theLowestValue;
	
    //高低區間
    float theHighLowSectionValue = theHighValue - theLowValue;
	
    //決定畫幾條線 再標示刻度...
    float elementYValue = theHighLowSectionValue / yLines;
	
    //著顏色長條圖 以及 最高價＆最低價線段
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetLineWidth(context, 0.9*drawAndScrollController.chartZoomOrigin);
    CGContextSetLineWidth(context, lineWidth);
	
    DecompressedHistoricData *hist;
    float open, close, longRectWidthCenter, x, h;
    CGRect longRect;
    float bottom = ySize + offsetYvalue;
	
    for (int i = 0; i < count; i++) 
	{
		
        hist = [historicData copyHistoricTick:type sequenceNo:i];
        if (hist == nil) continue;
		
        longRectWidthCenter = rectWidth/2;
		x = i * xScale + offsetXvalue;
        
        //TODO： elementYValue 有時候會是空值或是nan，進而造成除以零的crash
        if(elementYValue == 0)return;
//            elementYValue += 1;
		
		//連接最高點與最低點
        [[UIColor yellowColor] set];
        CGContextMoveToPoint(context, x + longRectWidthCenter, bottom - (hist.high - theLowValue)/elementYValue*yScale);
        CGContextAddLineToPoint(context, x + longRectWidthCenter, bottom - (hist.low - theLowValue)/elementYValue*yScale);
        //CGContextStrokePath(context);
		
        open = hist.open;
        close = hist.close;
		
        if (open >= close) 
		{ // 漲的長方圖
            if (open == close)
                [[UIColor yellowColor] set];
            else
                [[StockConstant PriceDownColor] set]; // 台股下跌為綠色
            h = (open - close) / elementYValue * yScale;
            //longRect = CGRectMake(x, bottom - (open - theLowValue) / elementYValue * yScale, rectWidth, h > 0.5 ? h : 0.5);
        }
        else 
		{ // 跌的長方圖
            [[StockConstant PriceUpColor] set]; // 台股上漲為紅色
            h = (close - open) / elementYValue * yScale;
            //longRect = CGRectMake(x, bottom - (close - theLowValue) / elementYValue * yScale, rectWidth, h > 0.5 ? h : 0.5);
        }
		
        if (longRect.size.height < 0.9)
            longRect.size.height = 0.9;
		
        CGContextAddRect(context, longRect);
        CGContextFillPath(context);
		
    }
	
}


- (void)drawRect:(CGRect)rect 
{
	
    if (drawAndScrollController.analysisPeriod == AnalysisPeriodDay)
        [self drawDayLine];
    else
        [self drawHistoricLine];
	
    if (!CGAffineTransformIsIdentity(zoomTransform)) 
	{
        self.transform = zoomTransform;
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        zoomTransform = CGAffineTransformIdentity;
    }
}

-(void)drawLineOnStartPoint:(CGPoint)point1 EndPoint:(CGPoint)point2 Offset:(CGPoint)frameOffset{
	
	CGContextRef context = UIGraphicsGetCurrentContext(); 
	
	[[UIColor clearColor] set];
	
	CGContextSetLineWidth(context, drawAndScrollController.chartZoomOrigin);
	
	if (point1.x == point2.x || point1.y == point2.y){
		
		if(point1.x != point2.x)
		{
			//橫線		
			CGContextMoveToPoint(context, frameOffset.x + point1.x, frameOffset.y + point1.y); 
			CGContextAddLineToPoint(context, frameOffset.x + point2.x, frameOffset.y + point1.y);
			//CGContextStrokePath(context);
		}
		
		if(point1.y != point2.y)
		{
			//直線
			CGContextMoveToPoint(context, point1.x, point1.y + frameOffset.y); 
			CGContextAddLineToPoint(context, point2.x, point2.y + frameOffset.y);	
			//CGContextStrokePath(context);
		}
		
	}
	else{
		// 不劃線
	}
	
	//CGContextStrokePath(context); //顯示線段 連接起終點
}	


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
//	if (drawAndScrollController.comparisonSettingController.comparing)
//		[drawAndScrollController doTouchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
//	if (drawAndScrollController.comparisonSettingController.comparing)
//		[drawAndScrollController doTouchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
//	if (drawAndScrollController.comparisonSettingController.comparing)    
//		[drawAndScrollController doTouchesEnded:touches withEvent:event];
}


@end
