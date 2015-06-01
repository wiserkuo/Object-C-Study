//
//  IndexScaleView.m
//  Bullseye
//
//  Created by ilien.liao on 2009/12/31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IndexScaleView.h"
#import "IndexView.h"
#import "UpperValueView.h"
#import "FSPositionViewController.h"

//#define BarDateWidth     4.0


static float xSize;
static float ySize;

@implementation Line
@end

@implementation IndexScaleView

@synthesize historicData;

@synthesize drawAndScrollController;
@synthesize yLines,offsetX,offsetY;
@synthesize highestValue,lowestValue;

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame])
	{
        // Initialization code
		dateLabelInfoDict = [[NSMutableDictionary alloc] init];		
		newsBtnArray = [[NSMutableArray alloc]init];
        self.compArray = [[NSMutableArray alloc]init];
        self.compDictionary = [[NSMutableDictionary alloc]init];
        self.compVolumeDictionary = [[NSMutableDictionary alloc]init];
        self.pointDictionary = [[NSMutableDictionary alloc]init];
        self.drawLinePoints = [[NSMutableArray alloc]init];
        trendLineAngleArray = [[NSMutableArray alloc]init];
        FibonacciRetracementArray = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:2],[NSNumber numberWithInt:3],[NSNumber numberWithInt:5],[NSNumber numberWithInt:8],[NSNumber numberWithInt:13],[NSNumber numberWithInt:21],[NSNumber numberWithInt:34],[NSNumber numberWithInt:55],[NSNumber numberWithInt:89],[NSNumber numberWithInt:144],[NSNumber numberWithInt:233],[NSNumber numberWithInt:377],[NSNumber numberWithInt:610],[NSNumber numberWithInt:987], nil];
        objArray = [[NSMutableArray alloc]init];
        _objDataArray = [[NSMutableArray alloc]init];
        self.event = [[UIEvent alloc]init];
        dataLock = [[NSRecursiveLock alloc]init];
        
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handLongPress:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:longPress];
	}
    return self;
}

-(NSInteger)getSeqNumberFromPointXValue:(float)x 
{
	
	UInt8 type = self.drawAndScrollController.historicType;
    UInt32 histCount = [historicData tickCount:type];
    if (histCount == 0) return -1;
	
    float xScale = drawAndScrollController.barDateWidth;
    int x0 = (int)offsetX;
    int n = x > x0 ? (x - x0) / xScale : 0; 
	
    if (n >= histCount)
		n = histCount - 1;
    
	return n;
}

- (void) removeAllNewsbtn
{
	for(UIButton *btn in newsBtnArray)
	{
		[btn removeFromSuperview];	
	}

}

- (void)placeInformationButton
{
	
	[self removeAllNewsbtn];
	
	UInt8 type = self.drawAndScrollController.historicType;
	if(type != 'D')
		return;
	
	
	float winLocationX;
	if(xSize<273)
		winLocationX = 0;
	else
		winLocationX = self.frame.origin.x;
	NSInteger offsetXvalue = offsetX - winLocationX ;
	
	NSInteger dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
	NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
	
	if(dataStartIndex == -1 || dataEndIndex == -1)
		return;

	
	DecompressedHistoricData *hist;
	
	hist = [historicData copyHistoricTick:type sequenceNo:(int)dataStartIndex];
	UInt16 startDate = hist.date;
	hist = [historicData copyHistoricTick:type sequenceNo:(int)dataEndIndex];
	UInt16 endDate = hist.date;
	
	
	NSDate *todayDate = [drawAndScrollController setTodayDate];
	NSDate *oldesetDate = [drawAndScrollController getOldestDate];
	NSMutableArray *firstDateDateArray = [drawAndScrollController getMonthArrayFromTodayDate:todayDate toOldestDate:oldesetDate];
	
	[dateLabelInfoDict removeAllObjects];
	
	int rangeNewsCount = 0;
	for (int i = 0; i < firstDateDateArray.count; i++)  //array index第一筆為最近的日期 , index愈大日期愈古老
	{
		
		NSDate *tmpDate = [firstDateDateArray objectAtIndex:i];
		UInt16 tmpStkDate = [ValueUtil stkDateFromNSDate:tmpDate];
				
		if(tmpStkDate < startDate || tmpStkDate > endDate)
			continue;
		
		if(i==0)
		{
			//區間內最近的日期
			UInt16 endDate =  [ValueUtil stkDateFromNSDate:todayDate];
			
			//區間內最古的日期
			NSDate *startNSDate = [firstDateDateArray objectAtIndex:i];
			UInt16 startDate = [ValueUtil stkDateFromNSDate:startNSDate];
			
//			rangeNewsCount = [[FSDataModelProc getDataModal].informationMine getNewsCountByStartDate:startDate endDate:endDate];
			if(rangeNewsCount > 0)
			{
				NSMutableDictionary *dateDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:(int)startDate],@"startDate",[NSNumber numberWithInt:(int)endDate],@"endDate",nil];
				[dateLabelInfoDict setObject:dateDict forKey:[NSNumber numberWithInt:i]];
			}
			
		}
		else if(i < (firstDateDateArray.count - 1))
		{
			
			//區間內最近的日期
			NSDate *endNSDate = [firstDateDateArray objectAtIndex:i-1];
			UInt16 endDate = [ValueUtil stkDateFromNSDate:endNSDate]-1;
			
			//區間內最古的日期
			NSDate *startNSDate = tmpDate;
			UInt16 startDate =  [ValueUtil stkDateFromNSDate:startNSDate];
			
//			rangeNewsCount = [[DataModalProc getDataModal].informationMine getNewsCountByStartDate:startDate endDate:endDate];				
			if(rangeNewsCount > 0)
			{
				NSMutableDictionary *dateDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:(int)startDate],@"startDate",[NSNumber numberWithInt:(int)endDate],@"endDate",nil];
				[dateLabelInfoDict setObject:dateDict forKey:[NSNumber numberWithInt:i]];
			}
			
			
		}
		else if(i == firstDateDateArray.count-1)
		{
			
			//區間內最近的日期
			NSDate *endNSDate = [firstDateDateArray objectAtIndex:i-1];				
			UInt16 endDate = [ValueUtil stkDateFromNSDate:endNSDate]-1;
			
			//區間內最古的日期
			UInt16 startDate = [ValueUtil stkDateFromNSDate:tmpDate];
			
//			rangeNewsCount = [[DataModalProc getDataModal].informationMine getNewsCountByStartDate:startDate endDate:endDate];
			if(rangeNewsCount > 0)
			{
				NSMutableDictionary *dateDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:(int)startDate],@"startDate",[NSNumber numberWithInt:(int)endDate],@"endDate",nil];
				[dateLabelInfoDict setObject:dateDict forKey:[NSNumber numberWithInt:i]];
			}
			
		}
		
		float lineXcoordinate;
		float lineYcoordinate;
		float open, close, h;
		NSInteger offsetYvalue = offsetY;
		float bottom = ySize + offsetYvalue;
		float yScale = ySize / yLines;		
		
		// find x
        int scaleLocationIndex = [self.drawAndScrollController scaleLocationIndexValueFromDate:tmpDate ordestDate:oldesetDate];		
        float xScale = drawAndScrollController.barDateWidth;
        lineXcoordinate = (float)xScale * scaleLocationIndex + offsetXvalue;		

		
		// find y
		float theHighValue = highestValue;
		float theLowValue = lowestValue;
		float theHighLowSectionValue = theHighValue - theLowValue; //高低區間
		
		//決定畫幾條線 再標示刻度...
		float elementYValue = theHighLowSectionValue / yLines;		
		
		NSInteger dataIndex = [self getSeqNumberFromPointXValue:lineXcoordinate+winLocationX];
		hist = [historicData copyHistoricTick:type sequenceNo:(int)dataIndex];
        open = hist.open;
        close = hist.close;		

		h = (open - close) / elementYValue * yScale;

		lineYcoordinate = bottom - (open - lowestValue) / elementYValue * yScale;
		
		//NSLog(@"%d %@ x:%.2f y:%.2f",hist.date,[NSString stringWithFormat:@"%02d", [[DrawAndScrollController sharedGregorianCalendar] components:NSMonthCalendarUnit fromDate:tmpDate].month],lineXcoordinate,lineYcoordinate);
		float y;
		if(hist.open > hist.close)
		{
			//K線往下長
			y = ceil(lineYcoordinate);				
		}
		else 
		{
			//K線往上長		
			y = floor(lineYcoordinate);				
		}

		if(y <= (self.frame.size.height)/2) // self.frame.size.height = 184
			lineYcoordinate = self.frame.size.height - 25;
		else
			lineYcoordinate = 0;
		
		
		if(rangeNewsCount > 0)
		{
			UIButton *newsBtn = [[UIButton alloc]init];
			UIImage *newImage = [UIImage imageNamed:@"news-icon-06.png"];
			[newsBtn setBackgroundImage:newImage forState:UIControlStateNormal];	
			newsBtn.tag = i;
			newsBtn.frame = CGRectMake(lineXcoordinate+1, lineYcoordinate, 25.0, 25.0); //btn中央點對準相對映的時間刻度
			newsBtn.backgroundColor = [UIColor clearColor];		
			
			[self addSubview:newsBtn];
			[newsBtnArray addObject:newsBtn];

		}
	}
	
	
}

#pragma mark 移動平均線*3 (短線 中線 長線)
- (void)drawMovingAverageFrom:(int)startIndex to:(int)endIndex 
{
	 UIColor *colors[] = { [UIColor colorWithRed:(float)192/255 green:(float)16/255 blue:(float)192/255 alpha:1],
						   [UIColor colorWithRed:(float)197/255 green:(float)128/255 blue:(float)32/255 alpha:1],
	                       [UIColor colorWithRed:(float)102/255 green:(float)128/255 blue:(float)200/255 alpha:1],
                            [UIColor colorWithRed:(float)140/255 green:(float)180/255 blue:(float)99/255 alpha:1],
                            [UIColor colorWithRed:(float)255/255 green:(float)20/255 blue:(float)147/255 alpha:1],
                            [UIColor colorWithRed:(float)130/255 green:(float)190/255 blue:(float)210/255 alpha:1]};
	
	float winLocationX;
	if(xSize<273)
		winLocationX = 0;
	else
		winLocationX = self.frame.origin.x;
    float xOffset = offsetX + drawAndScrollController.chartBarWidth / 2 - winLocationX;
    float bottom = offsetY + ySize;
    float x, y, sum;
    int n, i;
	float xScale = drawAndScrollController.barDateWidth;
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat lineWidth = drawAndScrollController.lineWidth;
    CGContextSetLineWidth(context, lineWidth);
	float levelHigh = highestValue;
    float levelLow = lowestValue;
    
	BOOL first = YES;
  // update 最高最低值  
/*	for (n = 0; n < 3; n++) 
	{
	    for (i = startIndex; i <= endIndex; i++) 
		{
			
			if(n==0)
			{
				sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:0];
			}
			else if(n==1)
			{
				sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:1];;
			}
			else if(n==2)
			{
				sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:2];;
			}
			
			if(sum < 0)
				continue;
			if(sum > levelHigh)
				levelHigh = sum;
			else if(sum < levelLow)
				levelLow = sum;
            			
		}
    }
	*/
//	highestValue = levelHigh;
//	lowestValue = levelLow;
	
	float diff = levelHigh - levelLow;

// 拿現成的資料  indexView算好了	
//	tmpArray1 	// 短MA 
//	tmpArray2 	// 中MA	
//	tmpArray3 	// 長MA
    int lineNum;
    if ((drawAndScrollController.autoLayoutIndex%3)==2) {
        lineNum = 6;
    }else{
        lineNum = 3;
    }
	
    for (n = 0; n < lineNum; n++)
	{
		CGMutablePathRef path = CGPathCreateMutable();
		[colors[n] set];
        		
        for (i = startIndex; i <= endIndex; i++) 
		{
			           
			if(n==0)
			{
				sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:0];
			}
			else if(n==1)
			{
				sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:1];
			}
			else if(n==2)
			{
				sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:2];;
			}else if(n==3){
                sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:3];
            }else if (n==4){
                sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:4];
            }else if (n==5){
                sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:5];
            }
            
            x = i * xScale + xOffset;
            //TODO： diff 有時候會是空值或是nan，進而造成除以零的crash
            if(diff == 0)
                continue;
//                diff += 1;
			y = bottom - (sum - levelLow) * ySize / diff;
            
            
            if (isnan(sum) || isnan(y))
                continue;
			if (first)
			{
                first = NO;
                CGPathMoveToPoint(path, NULL, x, y);
            }
            else
                CGPathAddLineToPoint(path, NULL, x, y);
            
				
		}
		
        CGContextAddPath(context, path);
		CGContextStrokePath(context);
		CGPathRelease(path);
		first = YES;
    }
	
	
}

// 畫 代入布林格參數的移動平均線
- (void)drawMovingAverageWithBollingerParmFrom:(int)startIndex to:(int)endIndex 
{
	
		
	[[UIColor colorWithRed:(float)197/255 green:(float)128/255 blue:(float)32/255 alpha:1] set];
	float winLocationX;
	if(xSize<273)
		winLocationX = 0;
	else
		winLocationX = self.frame.origin.x;
    float xOffset = offsetX + drawAndScrollController.chartBarWidth / 2 - winLocationX;
    float bottom = offsetY + ySize;
    float x, y, sum;
    int i;
	float xScale = drawAndScrollController.barDateWidth;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, drawAndScrollController.lineWidth);
	CGMutablePathRef path = CGPathCreateMutable();
	
    float levelHigh = highestValue;
    float levelLow = lowestValue;
    float diff = levelHigh - levelLow;
	BOOL first = YES;
    sum = 0;
    
    for (i = startIndex; i <= endIndex; i++)
	{
		sum = [drawAndScrollController.indexView getBollingerFrom:i parm:0];
		x = i * xScale + xOffset;
		y = bottom - (sum - levelLow) * ySize / diff;
        if (isnan(sum))
            continue;
        
        if (first)
		{
			first = NO;
			CGPathMoveToPoint(path, NULL, x, y);
		}
		else
			CGPathAddLineToPoint(path, NULL, x, y);
		
			
	}
	
	CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);

	
}
#pragma mark SAR線
- (void)drawSARFrom:(int)startIndex to:(int)endIndex{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [[UIColor colorWithRed:(float)197/255 green:(float)128/255 blue:(float)32/255 alpha:1] set];
	float winLocationX;
	if(xSize<273)
		winLocationX = 0;
	else
		winLocationX = self.frame.origin.x;
    float xOffset = offsetX + drawAndScrollController.chartBarWidth / 2 - winLocationX;
    float bottom = offsetY + ySize;
    float x, y, sum;
    int i;
	float xScale = drawAndScrollController.barDateWidth;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, drawAndScrollController.lineWidth);
	CGMutablePathRef path = CGPathCreateMutable();
	
    float levelHigh = highestValue;
    float levelLow = lowestValue;
    float diff = levelHigh - levelLow;
	BOOL first = YES;
    BOOL after = NO;
    BOOL Begin = YES;
    sum = 0;
    
    for (i = startIndex; i <= endIndex; i++)
	{
		sum = [dataModal.operationalIndicator getValueFrom:i parm:@"SAR"];
		x = i * xScale + xOffset;
		y = bottom - (sum - levelLow) * ySize / diff;
        first = [dataModal.operationalIndicator getValueFrom:i parm:@"SARBreak"]==1;
        if (i<endIndex) {
            after = [dataModal.operationalIndicator getValueFrom:i+1 parm:@"SARBreak"]==1;
        }
        if (isnan(sum))
            continue;
        
        if (Begin)
		{
            if (!first) {
                Begin=NO;
                CGPathMoveToPoint(path, NULL, x-1, y);
            }else {
                CGRect openRect =CGRectMake(x-1, y,3,3);
                CGContextAddRect(context, openRect);
                CGContextFillPath(context);
            }
            
		}
		else{
            if (first) {
                CGPathAddLineToPoint(path, NULL, x-1, y);
                
                CGContextAddPath(context, path);
                CGContextStrokePath(context);
                
                Begin =YES;
                
            }else{
                CGPathAddLineToPoint(path, NULL, x-1, y);
                
            }
            
        }
		
        
	}
	CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);
	
}

#pragma mark 布林線
- (void)drawBollingerFrom:(int)startIndex to:(int)endIndex
{
	
    float levelHigh = highestValue;
    float levelLow = lowestValue;
	float xScale = drawAndScrollController.barDateWidth;
	float x, y;
  
    float number1;
	float number2;
/*	for (int i = startIndex; i <= endIndex; i++) 
	{
		number1 = [drawAndScrollController.indexView getBollingerFrom:i parm:1];
		if(number1 > levelHigh)
			levelHigh = number1;
		if(number1 < levelLow)
			levelLow = number1;
        number2 = [drawAndScrollController.indexView getBollingerFrom:i parm:2];
		if(number2 > levelHigh)
			levelHigh = number2;
		if(number2 < levelLow)
			levelLow = number2;
		
	}
	*/
//	highestValue = levelHigh;
//	lowestValue = levelLow;
	
	[self drawMovingAverageWithBollingerParmFrom:startIndex to:endIndex];
	
    BOOL first1 = YES;
    BOOL first2 = YES;
   	
    float diff = levelHigh - levelLow;
	float winLocationX;
	if(xSize<273)
		winLocationX = 0;
	else
		winLocationX = self.frame.origin.x;	
    float xOffset = offsetX + drawAndScrollController.chartBarWidth / 2 - winLocationX;
    float bottom = offsetY + ySize;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGMutablePathRef path2 = CGPathCreateMutable();
	
    CGContextSetLineWidth(context, drawAndScrollController.lineWidth);
    [[UIColor colorWithRed:(float)192/255 green:(float)16/256 blue:(float)192/256 alpha:1]set];
	
    for (int i = startIndex; i <= endIndex; i++) 
	{
		
        number1 = [drawAndScrollController.indexView getBollingerFrom:i parm:1];
        number2 = [drawAndScrollController.indexView getBollingerFrom:i parm:2];
        		
        x = i * xScale + xOffset;
		
		if (number1 > 0)
		{
			
            y = bottom - (number1 - levelLow) * ySize / diff;
			
            if (first1)
			{
                first1 = NO;
                CGPathMoveToPoint(path1, NULL, x, y);
            }
            else
                CGPathAddLineToPoint(path1, NULL, x, y);
        }
		
        if (number2 > 0) 
		{
			
            y = bottom - (number2 - levelLow) * ySize / diff;
			
            if (first2) 
			{
                first2 = NO;
                CGPathMoveToPoint(path2, NULL, x, y);
            }
            else
                CGPathAddLineToPoint(path2, NULL, x, y);
        }
    }
	
    CGContextAddPath(context, path1);
    CGContextStrokePath(context);
    CGPathRelease(path1);
	
    CGContextAddPath(context, path2);
    CGContextStrokePath(context);
    CGPathRelease(path2);
}



- (void)drawMonthLineFrom:(UInt16)startD End:(UInt16)endD
{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	
	UInt16 year;
	UInt8 month,day;
	float winLocationX;
	if(xSize<273)
		winLocationX = 0;
	else
		winLocationX = self.frame.origin.x;
//	NSInteger offsetXvalue = offsetX - winLocationX ;
	[CodingUtil getDate:startD year:&year month:&month day:&day];
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyy-d-M";
	NSString* time = [NSString stringWithFormat:@"%d-%d-%d",year,day,month];
	NSDate* startDate = [formatter dateFromString:time];
	
	[CodingUtil getDate:endD year:&year month:&month day:&day];
	time = [NSString stringWithFormat:@"%d-%d-%d",year,day,month];
	NSDate* endDate = [formatter dateFromString:time];
	
	//取得每月第一天的陣列
	NSMutableArray *firstDateDateArray = [self.drawAndScrollController getMonthArrayFromTodayDate:endDate toOldestDate:startDate];
    int cntFirstDayDate = (int)[firstDateDateArray count];
	
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetLineWidth(context, 1);
    CGFloat length[]={3,1};

    for (int i = 0; i < cntFirstDayDate; i++) 
	{
//		NSDate *tmpDate = [firstDateDateArray objectAtIndex:i];
		
        //每個月第一天的SLI （從最近期的月份開始）
//        int scaleLocationIndex = [self.drawAndScrollController scaleLocationIndexValueFromDate:tmpDate ordestDate:startDate];
		
//        float scale = drawAndScrollController.barDateWidth;
//        float lineXcoordinate = (float)scale * scaleLocationIndex + offsetXvalue;
		
//        CGPoint startPoint = CGPointMake(lineXcoordinate,0);
//        CGPoint endPoint = CGPointMake(lineXcoordinate,ySize+1);
		
        //劃線 (直線)
		[[UIColor clearColor] set];
        CGContextSetLineDash(context, 0, length, 0);
//        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
//        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextStrokePath(context);
	   
	}
	
    CGContextSetLineDash(context, 0, NULL, 0);
}

- (void)drawDateGridFrom:(NSInteger)startIndex End:(NSInteger)endIndex 
{
	
    UInt8 type = self.drawAndScrollController.historicType;
    UInt32 count = [historicData tickCount:type];
    if (count == 0) return;
	float winLocationX;
	if(xSize<273)
		winLocationX = 0;
	else
		winLocationX = self.frame.origin.x;
	NSInteger offsetXvalue = offsetX - winLocationX ;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    [[UIColor darkGrayColor] set];
	
    float x;
    float scale = drawAndScrollController.barDateWidth;
	
    switch (drawAndScrollController.analysisPeriod) 
	{
		case AnalysisPeriodDay:
            break;
        case AnalysisPeriodWeek:
        case AnalysisPeriodMonth: 
		{
			
            int bitOffset = drawAndScrollController.analysisPeriod == AnalysisPeriodWeek ? 5 : 9;
            int date, prevDate;
			
            DecompressedHistoricData *historic = [historicData copyHistoricTick:type sequenceNo:(int)startIndex];
            prevDate = historic.date >> bitOffset;
			
            for (NSInteger i = startIndex; i < endIndex+1; i++)
			{
				
                historic = [historicData copyHistoricTick:type sequenceNo:(int)i];
                date = historic.date >> bitOffset;
				
                if (prevDate != date) 
				{
					
					prevDate = date;
                    x = scale * i + offsetXvalue;
					
//                    CGContextMoveToPoint(context, x, 0);
//                    CGContextAddLineToPoint(context, x, ySize+1);
                    CGContextStrokePath(context);
                }
            }
            break;
        }
			
        case AnalysisPeriod5Minute: 
		case AnalysisPeriod15Minute:
		case AnalysisPeriod30Minute:
		case AnalysisPeriod60Minute:
		{
			
            int date, prevDate;
            int time, prevTime;
			
            DecompressedHistoric5Minute *historic = [historicData copyHistoricTick:type sequenceNo:(int)startIndex];
            prevDate = historic.date;
            prevTime = historic.time;
			
            for (NSInteger i = startIndex+1; i < endIndex+1; i++)
			{
				
                historic = [historicData copyHistoricTick:type sequenceNo:(int)i];
                date = historic.date;
                time = historic.time;
				
                if (prevDate != date || prevTime/60 != time/60) 
				{
					
                    x = scale * i + offsetXvalue;
//                    CGContextMoveToPoint(context, x, 0);
//                    CGContextAddLineToPoint(context, x, ySize+1);
                    CGContextStrokePath(context);
					
                    prevDate = date;
                    prevTime = time;
                }
            }
            break;
        }
    }
	
    CGContextSetLineDash(context, 0, NULL, 0);
}

-(BOOL)getHigestAndLowest
{
	BOOL bChange = NO;
	float highestValueTemp;
	float lowestValueTemp;
	
	float winLocationX;
	UInt8 type = self.drawAndScrollController.historicType;
	xSize = self.frame.size.width;
	if(xSize<273)
		winLocationX = 0;
	else
		winLocationX = self.frame.origin.x;

	UInt32 count = [historicData tickCount:type];
    if (count == 0) 
		return NO;
	
	NSInteger dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
	NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
	
	lowestValueTemp = [drawAndScrollController.historicData getTheLowestValueFromStartIndex:dataStartIndex toEndIndex:dataEndIndex]; //抓區間最高值
	highestValueTemp = [drawAndScrollController.historicData getTheHightestValueFromStartIndex:dataStartIndex toEndIndex:dataEndIndex]; //抓區間最低值
	
	if(drawAndScrollController.upperViewIndicator == UpperViewBBIndicator)
	{
		float number1;
		float number2;
		for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++)
		{
			number1 = [drawAndScrollController.indexView getBollingerFrom:(int)i parm:1];
			if(number1 > highestValueTemp)
				highestValueTemp = number1;
			if(number1 < lowestValueTemp)
				lowestValueTemp = number1;
			number2 = [drawAndScrollController.indexView getBollingerFrom:(int)i parm:2];
			if(number2 > highestValueTemp)
				highestValueTemp = number2;
			if(number2 < lowestValueTemp)
				lowestValueTemp = number2;
			
		}
		
	}
	else if(drawAndScrollController.upperViewIndicator == UpperViewMAIndicator)
	{
        int num;
        if ((drawAndScrollController.autoLayoutIndex%3)==2) {
            num = 6;
        }else{
            num=3;
        }
		float sum;
		int n, i;
		for (n = 0; n < num; n++) 
		{
			for (i = (int)dataStartIndex; i <= dataEndIndex; i++)
			{
				
				if(n==0)
				{
					sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:0];
				}
				else if(n==1)
				{
					sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:1];;
				}
				else if(n==2)
				{
					sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:2];;
				}else if(n==3)
				{
					sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:3];;
				}else if(n==4)
				{
					sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:4];;
				}else if(n==5)
				{
					sum = [drawAndScrollController.indexView getMovingAvergeValueFrom:i parm:5];;
				}
				
				if(sum < 0)
					continue;
				if(sum > highestValueTemp)
					highestValueTemp = sum;
				else if(sum < lowestValueTemp)
					lowestValueTemp = sum;
				
			}
		}
		
	}else if (drawAndScrollController.upperViewIndicator ==UpperViewSARIndicator){
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        float number;
		for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++)
		{
			number = [dataModal.operationalIndicator getValueFrom:(int)i parm:@"SAR"];
			if(number > highestValueTemp)
				highestValueTemp = number;
			if(number < lowestValueTemp)
				lowestValueTemp = number;
			
		}
    }
	
	if(highestValueTemp != highestValue)
	{
		highestValue = highestValueTemp;
		bChange = YES;
	}

	if(lowestValueTemp != lowestValue)
	{
		lowestValue = lowestValueTemp;
		bChange = YES;
	}
	return bChange;
}
- (void)drawDayLine
{
    
    for (UIImageView * arrow in objArray) {
        [arrow removeFromSuperview];
    }
    
    [objArray removeAllObjects];
    [_objDataArray removeAllObjects];
	DecompressedHistoricData *hist;
	
	CGFloat lineWidth = drawAndScrollController.chartZoomOrigin;
	UInt8 type = self.drawAndScrollController.historicType;
	xSize = self.frame.size.width;
    ySize = self.frame.size.height;
	ySize -=1;
	float winLocationX;
	if(xSize<273)
		winLocationX = 0;
	else
		winLocationX = self.frame.origin.x;
	
	UInt32 count = [historicData tickCount:type];
    if (count == 0){
        return;
    }
    
	
	NSInteger dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
	NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];

	hist = [historicData copyHistoricTick:type sequenceNo:(int)dataStartIndex];
	UInt16 startDate = hist.date;
	hist = [historicData copyHistoricTick:type sequenceNo:(int)dataEndIndex];
	UInt16 endDate = hist.date;
	
	[drawAndScrollController drawChartFrameYScaleWithChartOffset:CGPointMake(0,1) frameWidth:xSize frameHeight:ySize yLines:yLines]; //畫橫線
	if (drawAndScrollController.analysisPeriod == AnalysisPeriodDay)
		[self drawMonthLineFrom:startDate End:endDate]; //畫月線
	else
		[self drawDateGridFrom:dataStartIndex End:dataEndIndex];     //畫直線
	
//	lowestValue = [drawAndScrollController.historicData getTheLowestValueFromStartIndex:dataStartIndex toEndIndex:dataEndIndex]; //抓區間最高值
//	highestValue = [drawAndScrollController.historicData getTheHightestValueFromStartIndex:dataStartIndex toEndIndex:dataEndIndex]; //抓區間最低值
    
    if (!drawAndScrollController.twoLine) {
        if(drawAndScrollController.upperViewIndicator == UpperViewMAIndicator)
        {
            [self drawMovingAverageFrom:(int)dataStartIndex to:(int)dataEndIndex];		 // MA
        }
        else if(drawAndScrollController.upperViewIndicator == UpperViewBBIndicator)
        {
            [self drawBollingerFrom:(int)dataStartIndex to:(int)dataEndIndex]; // BB
        }else if (drawAndScrollController.upperViewIndicator == UpperViewSARIndicator) {
            [self drawSARFrom:(int)dataStartIndex to:(int)dataEndIndex]; // SAR
        }
        
        if (!firstDraw) {
            firstDraw = YES;
            NSNumber *tempDate = 0;
            for (NSNumber *date in [_dateDictionary allKeys]) {
                if ([date intValue] > [tempDate intValue]) {
                    tempDate = date;
                }
                NSMutableDictionary * sameDateDic = [_dateDictionary objectForKey:tempDate];
                for (NSString *type in [sameDateDic allKeys]) {
                    arrowData * data = [sameDateDic objectForKey:type];
                    [drawAndScrollController arrowTapWithArrowData:data];
                }
            }
        }
        
        //暫定我們所畫的chartFrame與此view的左上(0,0)? 有chartFrameOffset的差距
        NSInteger offsetXvalue = offsetX - winLocationX ; //與x軸差了chartFrameOffset.x個pixel
        NSInteger offsetYvalue = offsetY; //與y軸差了chartFrameOffset.y個pixel
        
        //漲、跌長方型的寬度
        float rectWidth = drawAndScrollController.chartBarWidth; // 長條圖的寬度
        
        //再現定區間內 計算此區間 最高與最低數值 !!!
        float theHighValue = highestValue;
        float theLowValue = lowestValue;
        
        //高低區間
        float theHighLowSectionValue = theHighValue - theLowValue;
        
        //決定畫幾條線 再標示刻度...
        float elementYValue = theHighLowSectionValue / yLines;
        
        float open, close, longRectWidthCenter, x, h;
        CGRect longRect;
        CGRect openRect;
        CGRect closeRect;
        float bottom = ySize + offsetYvalue;
        viewBottom = bottom;
        float xScale = drawAndScrollController.barDateWidth;
        float yScale = ySize / yLines;
        [self.pointDictionary removeAllObjects];
        UInt16 lastDate = 0;
        for (NSUInteger i = dataStartIndex; i < dataEndIndex+1; i++)
        {
            
            hist = [historicData copyHistoricTick:type sequenceNo:(int)i];
            if (hist == nil) continue;
            
            longRectWidthCenter = rectWidth/2;
            x = i * xScale + offsetXvalue;
            if (i==dataStartIndex) {
                firstX = x;
            }else if (i==dataEndIndex){
                lastX = x;
            }
            
            //畫箭頭
            if ((_arrowType ==AnalysisPeriodMonth && type == 'M') ||(_arrowType ==AnalysisPeriodWeek && type == 'W')) {
                if(_arrowUpDownType == 3){
                    if (_buyDay !=0 && _buyDay>=lastDate && _buyDay<=hist.date) {
                        [self drawArrowWithX:x Y:bottom arrowType:1 date:_buyDay];
                        
                    }
                    if (_sellDay !=0 && _sellDay>=lastDate && _sellDay<=hist.date) {
                        [self drawArrowWithX:x Y:0 arrowType:2 date:_sellDay];
                    }
                }else if (_arrowUpDownType == 4 || _arrowUpDownType == 5){
                    for (NSNumber* date in [_dateDictionary allKeys]) {
                        NSMutableDictionary * sameDateDic = [_dateDictionary objectForKey:date];
                        for (NSString * type in [sameDateDic allKeys]) {
                            int dateInt = [date intValue];
                            if (dateInt !=0 && dateInt>=lastDate && dateInt<=hist.date) {
                                arrowData * data = [sameDateDic objectForKey:type];
                                if (data->arrowType==1) {
                                    [self drawArrowWithX:x Y:bottom arrowType:1 date:dateInt];
                                }else{
                                    [self drawArrowWithX:x Y:0 arrowType:2 date:dateInt];
                                }
                            }
                        }
                    }
                    
                }else{
                    if (_arrowDate !=0 && _arrowDate>=lastDate && _arrowDate<=hist.date) {
                        if (_arrowUpDownType ==1) {
                            [self drawArrowWithX:x Y:bottom arrowType:1 date:_arrowDate];
                        }else{
                            [self drawArrowWithX:x Y:0 arrowType:2 date:_arrowDate];
                        }
                    }
                }
                
            }else if (_arrowType ==AnalysisPeriodDay && type == 'D'){
                if(_arrowUpDownType == 3){
                    if (_buyDay !=0 && _buyDay==hist.date) {
                        [self drawArrowWithX:x Y:bottom arrowType:1 date:_buyDay];
                        
                    }
                    if (_sellDay !=0 && _sellDay==hist.date) {
                        [self drawArrowWithX:x Y:0 arrowType:2 date:_sellDay];
                    }
                }else if (_arrowUpDownType == 4 || _arrowUpDownType == 5){
                    for (NSNumber* date in [_dateDictionary allKeys]) {
                        NSMutableDictionary * sameDateDic = [_dateDictionary objectForKey:date];
                        for (NSString * type in [sameDateDic allKeys]) {
                            int dateInt = [date intValue];
                            if (dateInt !=0 && dateInt == hist.date) {
                                arrowData * data = [sameDateDic objectForKey:type];
                                if (data->arrowType==1) {
                                    [self drawArrowWithX:x Y:bottom arrowType:1 date:dateInt];
                                }else{
                                    [self drawArrowWithX:x Y:0 arrowType:2 date:dateInt];
                                }
                            }
                        }
                    }
                    
                }else{
                    if (_arrowDate !=0 && hist.date == _arrowDate) {
                        if (_arrowUpDownType ==1) {
                            [self drawArrowWithX:x Y:bottom arrowType:1 date:_arrowDate];
                        }else{
                            [self drawArrowWithX:x Y:0 arrowType:2 date:_arrowDate];
                        }
                    }
                }
                
            }
            lastDate = hist.date;

        }
        
        //著顏色長條圖 以及 最高價＆最低價線段
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, lineWidth);
        
        
        for (NSUInteger i = dataStartIndex; i < dataEndIndex+1; i++)
        {
            
            hist = [historicData copyHistoricTick:type sequenceNo:(int)i];
            if (hist == nil) continue;
            
            longRectWidthCenter = rectWidth/2;
            x = i * xScale + offsetXvalue;
            if (i==dataStartIndex) {
                firstX = x;
            }else if (i==dataEndIndex){
                lastX = x;
            }

            
            //連接最高點與最低點
            //TODO： elementYValue 有時候會是空值或是nan，進而造成除以零的crash
            if(elementYValue == 0)continue;
//                elementYValue += 1;
            [[UIColor blueColor] set];
                CGContextSetLineWidth(context, drawAndScrollController.ChartLineWidth);
                CGContextMoveToPoint(context, x + longRectWidthCenter, bottom - (hist.high - theLowValue)/elementYValue*yScale);
                CGContextAddLineToPoint(context, x + longRectWidthCenter, bottom - (hist.low - theLowValue)/elementYValue*yScale);
                CGContextStrokePath(context);

            
            open = hist.open;
            close = hist.close;
            
            if (open >= close)
            { // 跌的長方圖
                if (open == close)
                    [[UIColor blueColor] set];
                else
                    [[StockConstant PriceDownColor] set]; // 台股下跌為綠色
                h = (open - close) / elementYValue * yScale;
                longRect = CGRectMake(x, bottom - (open - theLowValue) / elementYValue * yScale, rectWidth, h > 0.5 ? h : 0.5);
                
            }
            else
            { // 漲的長方圖
                [[StockConstant PriceUpColor] set]; // 台股上漲為紅色
                h = (close - open) / elementYValue * yScale;
                longRect = CGRectMake(x, bottom - (close - theLowValue) / elementYValue * yScale, rectWidth, h > 0.5 ? h : 0.5);
                
            }
            [_pointDictionary setObject:[NSNumber numberWithFloat:bottom - (close - theLowValue) / elementYValue * yScale] forKey:[NSNumber numberWithInt:(int)i]];
            closeRect =CGRectMake(x+rectWidth/2, bottom - (close - theLowValue) / elementYValue * yScale,rectWidth/2,1.5);
            openRect =CGRectMake(x, bottom - (open - theLowValue) / elementYValue * yScale,rectWidth/2,1.5);
            
            if (longRect.size.height < 0.9)
                longRect.size.height = 0.9;
            
            if (drawAndScrollController.upperViewMainChar==UpperViewCandleChar) {
                CGContextAddRect(context, longRect);
            }else if(drawAndScrollController.upperViewMainChar == UpperViewOHLCChar){
                [[UIColor blueColor]set];
                CGContextAddRect(context, openRect);
                CGContextAddRect(context, closeRect);
            }
            
            CGContextFillPath(context);
            
            
        }

    }else{
        [self drawTwoLineFrom:(int)dataStartIndex to:(int)dataEndIndex];
    }
	

    drawAndScrollController.upperValueView.lowest = lowestValue;
	drawAndScrollController.upperValueView.highest = highestValue; 
	[drawAndScrollController.upperValueView updateLabels];
//    [drawAndScrollController drawOver];
}

-(void)drawArrowWithX:(float)x Y:(float)y arrowType:(int)arrowType date:(UInt16)date{
    [_objDataArray addObject:[NSNumber numberWithInt:date]];
    float rectWidth = drawAndScrollController.chartBarWidth;
    if(rectWidth<5){
        rectWidth=5;
    }
    if (arrowType ==1) {
        UIImageView * arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"upArrow"]];
        arrow.tag = 1;
        arrow.alpha = 0.6;
        [arrow setFrame:CGRectMake(x-rectWidth/4, y-rectWidth*2, rectWidth+rectWidth/2, rectWidth*2)];
        [self addSubview:arrow];
        [objArray addObject:arrow];
        
        
        if (_arrowUpDownType == 4) {
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(arrowTap:)];
            arrow.userInteractionEnabled = YES;
            [arrow addGestureRecognizer:tap];
        }

    }else{
        UIImageView * arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"downArrow"]];
        arrow.tag = 2;
        arrow.alpha = 0.6;
        [arrow setFrame:CGRectMake(x-rectWidth/4,y,rectWidth+rectWidth/2,rectWidth*2)];
        [self addSubview:arrow];
        [objArray addObject:arrow];
        if (_arrowUpDownType == 4) {
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(arrowTap:)];
            arrow.userInteractionEnabled = YES;
            [arrow addGestureRecognizer:tap];
        }
    }

}
-(void)arrowTap:(UITapGestureRecognizer *)sender{
    UIImageView * arrow = (UIImageView *)sender.view;
    
    int same = -1;
    for (int i=0;i<[objArray count];i++) {
        UIImageView * view = [objArray objectAtIndex:i];;
        if ([arrow isEqual:view]) {
            same = i;
            break;
        }
    }
    if (same >-1) {
        NSLog(@"%d",[(NSNumber *)[_objDataArray objectAtIndex:same]intValue]);
        NSMutableDictionary * dic =[_dateDictionary objectForKey:[_objDataArray objectAtIndex:same]];
        arrowData * data = [[arrowData alloc]init];
        if (arrow.tag==1) {
            data = [dic objectForKey:@"Buy"];
            if (!data) {
                data = [dic objectForKey:@"Cover"];
            }
        }else{
            data = [dic objectForKey:@"Sell"];
            if (!data) {
                data = [dic objectForKey:@"Short"];
            }
        }
        [drawAndScrollController arrowTapWithArrowData:data];
    }
}

-(void)changeNote:(NSString *)note Key:(NSNumber *)key arrowType:(int)type{
    NSMutableDictionary * data = [_dateDictionary objectForKey:key];
    arrowData * aData;
    NSString * typeStr;
    if(type==1){
        aData = [data objectForKey:@"Buy"];
        typeStr = @"Buy";
    }else{
        aData = [data objectForKey:@"Sell"];
        typeStr = @"Sell";
    }
    aData->note = note;
    [data setObject:aData forKey:typeStr];
    [_dateDictionary setObject:data forKey:key];
}

-(void)changReason:(NSString *)reason Key:(NSNumber *)key{
    arrowData * data = [_dateDictionary objectForKey:key];
    data->reason = reason;
    [_dateDictionary setObject:data forKey:key];
}


- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context,rect);
    [self drawDayLine];
    [self placeInformationButton];
    
    [drawAndScrollController setDefaultValue];
    
    [self drawUserLine];

}

-(void)drawUserLine{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] setStroke];
    
    xSize = self.frame.size.width;
    float winLocationX;
    if(xSize<273)
        winLocationX = 0;
    else
        winLocationX = self.frame.origin.x;
    
    NSInteger dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
    NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
    NSInteger offsetXvalue = offsetX - winLocationX ;
    float xScale = drawAndScrollController.barDateWidth;
    NSInteger offsetYvalue = offsetY;
    float bottom = ySize + offsetYvalue;
    float theHighValue = highestValue;
    float theLowValue = lowestValue;
    float theHighLowSectionValue = theHighValue - theLowValue;
    float elementYValue = theHighLowSectionValue / yLines;
    float yScale = ySize / yLines;
    float X, Y;
    
    switch (drawAndScrollController.lineType) {
        case PreviousLines:{
            break;
        }
#pragma mark 趨勢線
        case TrendLine:{
            if (drawAndScrollController.penBtn.selected==YES || drawAndScrollController.eraserBtn.selected==YES) {
                if (ac == KMoveAction) {
                    UIBezierPath *additionPolygon = [UIBezierPath bezierPath];
                    if (drawAndScrollController.eraserBtn.selected) {
                        [[UIColor clearColor] setStroke];
                    }
                    [additionPolygon moveToPoint:_firstTouch];
                    [additionPolygon addLineToPoint:_lastTouch];
                    [additionPolygon setLineWidth:1.0f];
                    [additionPolygon stroke];
                }
            }
            
            break;
        }
#pragma mark 平行線
        case ParallelLine:{
            if (secParallelLine) {
                //第二條
                Line *line = [_drawLinePoints lastObject];
                
                int d = (_firstTouch.x-offsetXvalue)/xScale;
                float p = (viewBottom-_firstTouch.y)/yScale * elementYValue +theLowValue;
                
                double m = (line.pointB.y - line.pointA.y) / (line.pointB.x - line.pointA.x);
                
                double c = p - m*d;
                CGPoint firPoint;
                CGPoint secPoint;
                if (line.pointB.x == line.pointA.x) {
                    firPoint = CGPointMake(d, line.pointA.y);
                    secPoint = CGPointMake(d, line.pointB.y);
                }else{
                    firPoint = CGPointMake(d, p);
                    secPoint = CGPointMake(d+1, m*(d+1)+c);
                }
                
                
                if (_drawEnd) {
                    if (drawAndScrollController.penBtn.selected==YES && [_drawLinePoints count]%2==1){
                        Line *line = [[Line alloc] init];
                        line.pointA = firPoint;
                        line.pointB = secPoint;
                        line.lineType = ParallelLine;
                        line.lineNum = 2;
                        [self.drawLinePoints addObject:line];
                    }
                    secParallelLine = NO;
                }else{
                    
                    [[UIColor blackColor] setStroke];
                    if (line.pointB.x == line.pointA.x) {
                        X = d * xScale + offsetXvalue;
                        CGContextMoveToPoint(context, X, 0);
                        CGContextAddLineToPoint(context, X, bottom);
                        CGContextStrokePath(context);
                    }else{
                        for (NSUInteger i = dataStartIndex; i < dataEndIndex+50; i++)
                        {
                            
                            X = i * xScale + offsetXvalue;
                            
                            double m = (secPoint.y - firPoint.y) / (secPoint.x - firPoint.x);
                            double c = secPoint.y - m*secPoint.x;
                            Y = m * i + c;
                            CGContextSetLineWidth(context, drawAndScrollController.ChartLineWidth);
                            
                            
                            if (i==dataStartIndex) {
                                CGContextMoveToPoint(context, X, bottom - (Y - theLowValue)/elementYValue*yScale);
                            }else{
                                CGContextAddLineToPoint(context, X, bottom - (Y - theLowValue)/elementYValue*yScale);
                            }
                        }
                        CGContextStrokePath(context);
                    }

                }
            }else{
                //第一條
                
                if (drawAndScrollController.penBtn.selected==YES || drawAndScrollController.eraserBtn.selected==YES) {
                    if (ac == KMoveAction) {
                        UIBezierPath *additionPolygon = [UIBezierPath bezierPath];
                        if (drawAndScrollController.eraserBtn.selected) {
                            [[UIColor clearColor] setStroke];
                        }
                        [additionPolygon moveToPoint:_firstTouch];
                        [additionPolygon addLineToPoint:_lastTouch];
                        [additionPolygon setLineWidth:1.0f];
                        [additionPolygon stroke];
                    }
                }
                
                if (_drawEnd) {
                    secParallelLine = YES;
                }
            }
            break;
        }
#pragma mark 黃金分割線
        case FibonacciLine:{
            if (drawAndScrollController.penBtn.selected==YES || drawAndScrollController.eraserBtn.selected==YES) {
                if (ac == KMoveAction && _drawEnd) {
                    UIBezierPath *additionPolygon = [UIBezierPath bezierPath];
                    if (drawAndScrollController.eraserBtn.selected) {
                        [[UIColor clearColor] setStroke];
                    }
                    [additionPolygon moveToPoint:CGPointMake(0, _lastTouch.y)];
                    [additionPolygon addLineToPoint:CGPointMake(500, _lastTouch.y)];
                    [additionPolygon setLineWidth:1.0f];
                    [additionPolygon stroke];
                }
                
                if (drawAndScrollController.penBtn.selected==YES){
                    if (_drawEnd){
                        float lastPrice = (viewBottom-_lastTouch.y)/yScale * elementYValue +theLowValue;
                        float firstPrice = (viewBottom-_firstTouch.y)/yScale * elementYValue +theLowValue;
                        
                        if (lastPrice != firstPrice) {
                            float price = MAX(lastPrice, firstPrice)-MIN(lastPrice, firstPrice);
                            int d = (_lastTouch.x-offsetXvalue)/xScale;
                            //中間三條
                            Line *line1 = [[Line alloc] init];
                            line1.pointA = CGPointMake(d, MIN(lastPrice, firstPrice)+price*0.382);
                            line1.pointB = CGPointMake(d+1, MIN(lastPrice, firstPrice)+price*0.382);
                            line1.lineType = FibonacciLine;
                            line1.lineNum = 2;
                            [self.drawLinePoints addObject:line1];
                            
                            Line *line2 = [[Line alloc] init];
                            line2.pointA = CGPointMake(d, MIN(lastPrice, firstPrice)+price*0.5);
                            line2.pointB = CGPointMake(d+1, MIN(lastPrice, firstPrice)+price*0.5);
                            line2.lineType = FibonacciLine;
                            line2.lineNum = 3;
                            [self.drawLinePoints addObject:line2];
                            
                            Line *line3 = [[Line alloc] init];
                            line3.pointA = CGPointMake(d, MIN(lastPrice, firstPrice)+price*0.618);
                            line3.pointB = CGPointMake(d+1, MIN(lastPrice, firstPrice)+price*0.618);
                            line3.lineType = FibonacciLine;
                            line3.lineNum = 4;
                            [self.drawLinePoints addObject:line3];
                            
                            
                            //最後一條
                            
                            Line *line4 = [[Line alloc] init];
                            line4.pointA = CGPointMake(d, lastPrice);
                            line4.pointB = CGPointMake(d+1, lastPrice);
                            line4.lineType = FibonacciLine;
                            line4.lineNum = 5;
                            [self.drawLinePoints addObject:line4];
                        }
                    }
                }
            }
            break;
        }
#pragma mark 甘氏角度線
        case TrendlineAngle:{
            if (drawAndScrollController.penBtn.selected==YES) {
                
                if ((ac == KprepareAction || ac == KMoveAction) && _drawEnd==NO) {
                    [trendLineAngleArray removeAllObjects];
                    int d = (_lastTouch.x-offsetXvalue)/xScale;
                    float p = (viewBottom-_lastTouch.y)/yScale * elementYValue +theLowValue;
                    
                    
                    float X = d * xScale + offsetXvalue;
                    float X2 = (d+12) * xScale + offsetXvalue;
                    float Y = (p - theLowValue)/elementYValue*yScale;
                    float Y2 = X2-X+Y;
                    float p2 = Y2/yScale * elementYValue +theLowValue;
                    
                    float pNum = p2-p;
                    
                    
                    
                    Line *line0 = [[Line alloc] init];
                    line0.pointA = CGPointMake(d, p);
                    line0.pointB = CGPointMake(d+12, p2);
                    line0.lineType = TrendlineAngle;
                    line0.lineNum = 1;
                    [trendLineAngleArray addObject:line0];
                    
                    //下面三條
                    
                    Line *line1 = [[Line alloc] init];
                    line1.pointA = CGPointMake(d, p);
                    line1.pointB = CGPointMake(d+12, p2-pNum/2.0f);
                    line1.lineType = TrendlineAngle;
                    line1.lineNum = 2;
                    [trendLineAngleArray addObject:line1];
                    
                    Line *line2 = [[Line alloc] init];
                    
                    line2.pointA = CGPointMake(d, p);
                    line2.pointB = CGPointMake(d+12, p2-pNum*2/3.0f);
                    line2.lineType = TrendlineAngle;
                    line2.lineNum = 3;
                    
                    [trendLineAngleArray addObject:line2];

                    Line *line3 = [[Line alloc] init];
                    line3.pointA = CGPointMake(d, p);
                    line3.pointB = CGPointMake(d+12, p2-pNum*3/4.0f);
                    line3.lineType = TrendlineAngle;
                    line3.lineNum = 4;
                    [trendLineAngleArray addObject:line3];
                    

                    //上面三條
                    
                    Line *line4 = [[Line alloc] init];
                    line4.pointA = CGPointMake(d, p);
                    line4.pointB = CGPointMake(d+6, p2);
                    line4.lineType = TrendlineAngle;
                    line4.lineNum = 5;
                    [trendLineAngleArray addObject:line4];
                    
                    Line *line5 = [[Line alloc] init];
                    line5.pointA = CGPointMake(d, p);
                    line5.pointB = CGPointMake(d+4, p2);
                    line5.lineType = TrendlineAngle;
                    line5.lineNum = 6;
                    [trendLineAngleArray addObject:line5];
                    
                    Line *line6 = [[Line alloc] init];
                    line6.pointA = CGPointMake(d, p);
                    line6.pointB = CGPointMake(d+3, p2);
                    line6.lineType = TrendlineAngle;
                    line6.lineNum = 7;
                    [trendLineAngleArray addObject:line6];
                    
                    
                    for (int i=0; i<[trendLineAngleArray count]; i++) {
                        Line *line = [trendLineAngleArray objectAtIndex:i];
                        
                        for (int j = line.pointA.x; j < dataEndIndex+50; j++)
                        {
                        
                            X = j * xScale + offsetXvalue;
                            
                            double m = (line.pointB.y - line.pointA.y) / (line.pointB.x - line.pointA.x);
                            double c = line.pointB.y - m*line.pointB.x;
                            Y = m * j + c;
                            CGContextSetLineWidth(context, drawAndScrollController.ChartLineWidth);
                            
                            
                            if (j==line.pointA.x) {
                                CGContextMoveToPoint(context, X, bottom - (Y - theLowValue)/elementYValue*yScale);
                            }else{
                                CGContextAddLineToPoint(context, X, bottom - (Y - theLowValue)/elementYValue*yScale);
                            }
                            
//                            CGContextMoveToPoint(context, X, bottom - (line.pointA.y - theLowValue)/elementYValue*yScale);
//                        
//                            CGContextAddLineToPoint(context, X2, bottom - (line.pointB.y - theLowValue)/elementYValue*yScale);
                        
                        }
                        CGContextStrokePath(context);
                    }
                    
                
                }else{
                    [self.drawLinePoints addObjectsFromArray:trendLineAngleArray];
                    [trendLineAngleArray removeAllObjects];
                }

            }
            break;
        }
#pragma mark 黃金扇
        case FibonacciFanLine:{
            if (drawAndScrollController.penBtn.selected==YES || drawAndScrollController.eraserBtn.selected==YES) {
                if (ac == KMoveAction && _drawEnd==NO) {
                    UIBezierPath *additionPolygon = [UIBezierPath bezierPath];
                    if (drawAndScrollController.eraserBtn.selected) {
                        [[UIColor clearColor] setStroke];
                    }
                    CGFloat dashPattern[] = {2,2,2,2};
                    [additionPolygon moveToPoint:_firstTouch];
                    [additionPolygon addLineToPoint:_lastTouch];
                    [additionPolygon setLineWidth:1.0f];
                    [additionPolygon setLineDash:dashPattern count:10 phase:1];
                    [additionPolygon stroke];
                }
                
                if (drawAndScrollController.penBtn.selected==YES){
                    if (_drawEnd){
                        float lastPrice = (viewBottom-_lastTouch.y)/yScale * elementYValue +theLowValue;
                        float firstPrice = (viewBottom-_firstTouch.y)/yScale * elementYValue +theLowValue;
                        
                        if (lastPrice != firstPrice) {
                            float price = MAX(lastPrice, firstPrice)-MIN(lastPrice, firstPrice);
                            int d = (_lastTouch.x-offsetXvalue)/xScale;
                            int firstD = (_firstTouch.x-offsetXvalue)/xScale;
                            //中間三條
                            Line *line1 = [[Line alloc] init];
                            line1.pointA = CGPointMake(firstD, firstPrice);
                            line1.pointB = CGPointMake(d, MIN(lastPrice, firstPrice)+price*0.382);
                            line1.lineType = FibonacciFanLine;
                            line1.lineNum = 2;
                            [self.drawLinePoints addObject:line1];
                            
                            Line *line2 = [[Line alloc] init];
                            line2.pointA = CGPointMake(firstD, firstPrice);
                            line2.pointB = CGPointMake(d, MIN(lastPrice, firstPrice)+price*0.5);
                            line2.lineType = FibonacciFanLine;
                            line2.lineNum = 3;
                            [self.drawLinePoints addObject:line2];
                            
                            Line *line3 = [[Line alloc] init];
                            line3.pointA = CGPointMake(firstD, firstPrice);
                            line3.pointB = CGPointMake(d, MIN(lastPrice, firstPrice)+price*0.618);
                            line3.lineType = FibonacciFanLine;
                            line3.lineNum = 4;
                            [self.drawLinePoints addObject:line3];
                        }
                    }
                }
            }
            break;
        }
#pragma mark 阻速線
        case SpeedResistanceLine:{
            if (drawAndScrollController.penBtn.selected==YES || drawAndScrollController.eraserBtn.selected==YES) {
                if (ac == KMoveAction && _drawEnd==NO) {
                    UIBezierPath *additionPolygon = [UIBezierPath bezierPath];
                    if (drawAndScrollController.eraserBtn.selected) {
                        [[UIColor clearColor] setStroke];
                    }
                    [additionPolygon moveToPoint:_firstTouch];
                    [additionPolygon addLineToPoint:_lastTouch];
                    [additionPolygon setLineWidth:1.0f];
                    [additionPolygon stroke];
                }
                
                if (drawAndScrollController.penBtn.selected==YES){
                    if (_drawEnd){
                        float lastPrice = (viewBottom-_lastTouch.y)/yScale * elementYValue +theLowValue;
                        float firstPrice = (viewBottom-_firstTouch.y)/yScale * elementYValue +theLowValue;
                        
                        if (lastPrice != firstPrice) {
                            float price = MAX(lastPrice, firstPrice)-MIN(lastPrice, firstPrice);
                            int d = (_lastTouch.x-offsetXvalue)/xScale;
                            int firstD = (_firstTouch.x-offsetXvalue)/xScale;
                            
                            Line *line1 = [[Line alloc] init];
                            line1.pointA = CGPointMake(firstD, firstPrice);
                            line1.pointB = CGPointMake(d, MIN(lastPrice, firstPrice)+price/3);
                            line1.lineType = SpeedResistanceLine;
                            line1.lineNum = 2;
                            [self.drawLinePoints addObject:line1];
                            
                            Line *line2 = [[Line alloc] init];
                            line2.pointA = CGPointMake(firstD, firstPrice);
                            line2.pointB = CGPointMake(d, MIN(lastPrice, firstPrice)+price*2/3);
                            line2.lineType = SpeedResistanceLine;
                            line2.lineNum = 3;
                            [self.drawLinePoints addObject:line2];
                            

                        }
                    }
                }
            }
            break;
        }
#pragma mark 黃金弧
        case FibonacciArc:{
            if (drawAndScrollController.penBtn.selected==YES || drawAndScrollController.eraserBtn.selected==YES) {
                if (ac == KMoveAction && _drawEnd==NO) {
                    UIBezierPath *additionPolygon = [UIBezierPath bezierPath];
                    if (drawAndScrollController.eraserBtn.selected) {
                        [[UIColor clearColor] setStroke];
                    }
                    CGFloat dashPattern[] = {2,2,2,2};
                    [additionPolygon moveToPoint:_firstTouch];
                    [additionPolygon addLineToPoint:_lastTouch];
                    [additionPolygon setLineWidth:1.0f];
                    [additionPolygon setLineDash:dashPattern count:10 phase:1];
                    [additionPolygon stroke];
                }
                
                if (drawAndScrollController.penBtn.selected==YES){
                    if (_drawEnd){
                        float lastPrice = (viewBottom-_lastTouch.y)/yScale * elementYValue +theLowValue;
                        float firstPrice = (viewBottom-_firstTouch.y)/yScale * elementYValue +theLowValue;

                        if (lastPrice != firstPrice) {
                            int d1 = (_firstTouch.x-offsetXvalue)/xScale;
                            int d2 = (_lastTouch.x-offsetXvalue)/xScale;
                            
                            //中間三條
                            
                            Line *line1 = [[Line alloc] init];
                            line1.pointA = CGPointMake(d1, firstPrice);
                            line1.pointB = CGPointMake(d2,lastPrice);
                            line1.lineType = FibonacciArc;
                            line1.lineNum = 2;
                            [self.drawLinePoints addObject:line1];
                            
                            Line *line2 = [[Line alloc] init];
                            line2.pointA = CGPointMake(d1, firstPrice);
                            line2.pointB = CGPointMake(d2,lastPrice);
                            line2.lineType = FibonacciArc;
                            line2.lineNum = 3;
                            [self.drawLinePoints addObject:line2];
                            
                            Line *line3 = [[Line alloc] init];
                            line3.pointA = CGPointMake(d1, firstPrice);
                            line3.pointB = CGPointMake(d2,lastPrice);
                            line3.lineType = FibonacciArc;
                            line3.lineNum = 4;
                            [self.drawLinePoints addObject:line3];
                        }
                    }
                }
            }

            break;
        }
#pragma mark 費波南希轉折
        case FibonacciRetracement:{
            if (drawAndScrollController.penBtn.selected==YES || drawAndScrollController.eraserBtn.selected==YES) {
                if (_drawEnd==NO) {
                    if (ac != KPainAction) {
                        UIBezierPath *additionPolygon = [UIBezierPath bezierPath];
                        if (drawAndScrollController.eraserBtn.selected) {
                            [[UIColor clearColor] setStroke];
                        }
                        [additionPolygon moveToPoint:CGPointMake(_lastTouch.x, 0)];
                        [additionPolygon addLineToPoint:CGPointMake(_lastTouch.x, bottom)];
                        [additionPolygon setLineWidth:1.0f];
                        [additionPolygon stroke];
                    }
                    
                }else{
                    if (drawAndScrollController.penBtn.selected==YES){
                        float lastPrice = (viewBottom-_lastTouch.y)/yScale * elementYValue +theLowValue;
                        int d = (_lastTouch.x-offsetXvalue)/xScale;
                        Line *line = [[Line alloc] init];
                        line.pointA = CGPointMake(d, lastPrice);
                        line.pointB = CGPointMake(d,lastPrice);
                        line.lineType = FibonacciRetracement;
                        line.lineNum = 1;
                        [self.drawLinePoints addObject:line];
                        
                        for (int i=0; i<[FibonacciRetracementArray count]; i++) {
                            int newD = d + [(NSNumber *)[FibonacciRetracementArray objectAtIndex:i]intValue]-1;
                            Line *newLine = [[Line alloc] init];
                            newLine.pointA = CGPointMake(newD, lastPrice);
                            newLine.pointB = CGPointMake(newD,lastPrice);
                            newLine.lineType = FibonacciRetracement;
                            newLine.lineNum = i+2;
                            [self.drawLinePoints addObject:newLine];
                        }
                    }
                    
                }
            }
            break;
        }
    }
    
    [[UIColor blackColor] setStroke];
    for (Line *line in self.drawLinePoints) {
        if (line.lineType == FibonacciFanLine || line.lineType == SpeedResistanceLine || line.lineType == TrendlineAngle){
            if (line.lineNum==1 && line.lineType == FibonacciFanLine) {
                if (line.pointB.x != line.pointA.x){
                    CGFloat length[]={2,1};
                    CGContextSetLineDash(context, 0, length, 1);
                    X = line.pointA.x * xScale + offsetXvalue;
                    
                    CGContextMoveToPoint(context, X, bottom - ( line.pointA.y - theLowValue)/elementYValue*yScale);
                    
                    X = line.pointB.x * xScale + offsetXvalue;
                    CGContextAddLineToPoint(context, X, bottom - (line.pointB.y - theLowValue)/elementYValue*yScale);
                    CGContextStrokePath(context);
                    CGContextSetLineDash(context, 0, NULL, 0);
                }
            }else{
                if (line.pointB.x == line.pointA.x) {
                    X = line.pointA.x * xScale + offsetXvalue;
                    if (line.pointA.y>line.pointB.y) {
                        //往下畫
                        CGContextMoveToPoint(context, X, bottom - (line.pointA.y - theLowValue)/elementYValue*yScale);
                        CGContextAddLineToPoint(context, X, bottom);
                    }else{
                        //往上畫
                        CGContextMoveToPoint(context, X, 0);
                        CGContextAddLineToPoint(context, X, bottom - (line.pointA.y - theLowValue)/elementYValue*yScale);
                    }
                    
                    
                    CGContextStrokePath(context);
                }else{
                    if (line.pointB.x > line.pointA.x) {
                        for (int i = line.pointA.x; i < dataEndIndex+50; i++)
                        {
                            
                            X = i * xScale + offsetXvalue;
                            
                            double m = (line.pointB.y - line.pointA.y) / (line.pointB.x - line.pointA.x);
                            double c = line.pointB.y - m*line.pointB.x;
                            Y = m * i + c;
                            CGContextSetLineWidth(context, drawAndScrollController.ChartLineWidth);
                            
                            
                            if (i==line.pointA.x) {
                                CGContextMoveToPoint(context, X, bottom - (Y - theLowValue)/elementYValue*yScale);
                            }else{
                                CGContextAddLineToPoint(context, X, bottom - (Y - theLowValue)/elementYValue*yScale);
                            }
                        }
                        CGContextStrokePath(context);
                    }else{
                        for (NSUInteger i =dataStartIndex ; i < line.pointA.x; i++)
                        {
                            
                            X = i * xScale + offsetXvalue;
                            
                            double m = (line.pointB.y - line.pointA.y) / (line.pointB.x - line.pointA.x);
                            double c = line.pointB.y - m*line.pointB.x;
                            Y = m * i + c;
                            CGContextSetLineWidth(context, drawAndScrollController.ChartLineWidth);
                            
                            
                            if (i==dataStartIndex) {
                                CGContextMoveToPoint(context, X, bottom - (Y - theLowValue)/elementYValue*yScale);
                            }else{
                                CGContextAddLineToPoint(context, X, bottom - (Y - theLowValue)/elementYValue*yScale);
                            }
                        }
                        CGContextStrokePath(context);
                    }
                }
            }
            
        }else if (line.lineType == FibonacciArc){
            if (line.lineNum==1) {
                    CGFloat length[]={2,1};
                    CGContextSetLineDash(context, 0, length, 1);
                    X = line.pointA.x * xScale + offsetXvalue;
                    
                    CGContextMoveToPoint(context, X, bottom - ( line.pointA.y - theLowValue)/elementYValue*yScale);
                    
                    X = line.pointB.x * xScale + offsetXvalue;
                    CGContextAddLineToPoint(context, X, bottom - (line.pointB.y - theLowValue)/elementYValue*yScale);
                    CGContextStrokePath(context);
                    CGContextSetLineDash(context, 0, NULL, 0);
            }else{
                //畫弧線
                //圓心x
                int pointBx = line.pointB.x * xScale + offsetXvalue;
                 //圓心y
                float pointBy =bottom - (line.pointB.y - theLowValue)/elementYValue*yScale;
                
                int pointAx = line.pointA.x * xScale + offsetXvalue;
                float pointAy =bottom - (line.pointA.y - theLowValue)/elementYValue*yScale;
                
                
                float lineLength = sqrtf(powf((pointAx-pointBx), 2)+powf(((pointAy-pointBy)), 2));
                
               //半徑
                float radius;
                
                if (line.lineNum==2) {
                    radius = lineLength *0.382;
                }else if (line.lineNum==3){
                    radius = lineLength *0.5;
                }else{
                    radius = lineLength *0.618;
                }
                
                
                int upDown;
                
                if (pointBy>pointAy) {
                    upDown = 1;
                }else{
                    upDown = 0;
                }
                    
                CGContextAddArc(context, pointBx, pointBy, radius, 0, M_PI, upDown);
                CGContextStrokePath(context);

  
            }
        }else if (line.lineType == FibonacciRetracement){
            X = line.pointA.x * xScale + offsetXvalue;
            CGContextMoveToPoint(context, X, 0);
            CGContextAddLineToPoint(context, X, bottom);
            CGContextStrokePath(context);
        
        }else{
            if (line.pointB.x == line.pointA.x) {
                X = line.pointA.x * xScale + offsetXvalue;
                CGContextMoveToPoint(context, X, 0);
                CGContextAddLineToPoint(context, X, bottom);
                CGContextStrokePath(context);
            }else{
                for (NSUInteger i = dataStartIndex; i < dataEndIndex+50; i++)
                {
                    
                    X = i * xScale + offsetXvalue;
                    
                    double m = (line.pointB.y - line.pointA.y) / (line.pointB.x - line.pointA.x);
                    double c = line.pointB.y - m*line.pointB.x;
                    Y = m * i + c;
                    CGContextSetLineWidth(context, drawAndScrollController.ChartLineWidth);
                    
                    
                    if (i==dataStartIndex) {
                        CGContextMoveToPoint(context, X, bottom - (Y - theLowValue)/elementYValue*yScale);
                    }else{
                        CGContextAddLineToPoint(context, X, bottom - (Y - theLowValue)/elementYValue*yScale);
                    }
                }
                CGContextStrokePath(context);
            }

        }
    }
    
}

- (void)drawTwoLineFrom:(int)startIndex to:(int)endIndex
{
    [self.pointDictionary removeAllObjects];
    [_compVolumeDictionary removeAllObjects];
    [_compDictionary removeAllObjects];
    [_compArray removeAllObjects];
    float compFirstClose;
    UInt8 type = self.drawAndScrollController.historicType;
    DecompressedHistoricData * firstHist;
    if (startIndex>0) {
        firstHist = [historicData copyHistoricTick:type sequenceNo:startIndex-1];
    }else{
        firstHist = [historicData copyHistoricTick:type sequenceNo:0];
    }
    
    int count = [_comparedHistoricData tickCount:type];
    DecompressedHistoricData * compFirstHist = [_comparedHistoricData copyHistoricTick:type sequenceNo:0];
    compFirstClose = compFirstHist.close;
    for (int i=0; i<count; i++) {
        DecompressedHistoricData * compFirstHist = [_comparedHistoricData copyHistoricTick:type sequenceNo:i];
        if (firstHist.date == compFirstHist.date) {
            compFirstClose = compFirstHist.close;
            break;
        }
    }
    
    for (int i=startIndex; i<=endIndex; i++) {
        DecompressedHistoricData *hist= [historicData copyHistoricTick:type sequenceNo:i];
        DecompressedHistoric5Minute * hisMin = [historicData copyHistoricTick:type sequenceNo:i];
        for (int j=0; j<count; j++) {
            DecompressedHistoricData * compHist = [_comparedHistoricData copyHistoricTick:type sequenceNo:j];
            DecompressedHistoric5Minute * compHistMin = [_comparedHistoricData copyHistoricTick:type sequenceNo:j];
            if (drawAndScrollController.analysisPeriod<3) {
                if (hist.date == compHist.date) {
                    float vol = compHist.volume * pow(1000,compHist.volumeUnit);
                    [_compArray addObject:[NSNumber numberWithFloat:compHist.close]];
                    [_compDictionary setObject:[NSNumber numberWithFloat:compHist.close] forKey:[NSNumber numberWithInt:i]];
                    [_compVolumeDictionary setObject:[NSNumber numberWithFloat:vol] forKey:[NSNumber numberWithInt:i]];
                    if (i==startIndex) {
                        DecompressedHistoricData * compHist = [_comparedHistoricData copyHistoricTick:type sequenceNo:j-1];
                        [_compDictionary setObject:[NSNumber numberWithFloat:compHist.close] forKey:[NSNumber numberWithInt:i-1]];
                    }
                    break;
                }
            }else{
                if (hisMin.date == compHistMin.date && hisMin.time == compHistMin.time) {
                    float vol = compHistMin.volume * pow(1000,compHistMin.volumeUnit);
                    [_compArray addObject:[NSNumber numberWithFloat:compHistMin.close]];
                    [_compDictionary setObject:[NSNumber numberWithFloat:compHistMin.close] forKey:[NSNumber numberWithInt:i]];
                    [_compVolumeDictionary setObject:[NSNumber numberWithFloat:vol] forKey:[NSNumber numberWithInt:i]];
                    if (i==startIndex) {
                        DecompressedHistoricData * compHist = [_comparedHistoricData copyHistoricTick:type sequenceNo:j-1];
                        [_compDictionary setObject:[NSNumber numberWithFloat:compHist.close] forKey:[NSNumber numberWithInt:i-1]];
                    }
                    break;
                }
            }
            
        }
    }
    
    
    float maxValue = -MAXFLOAT;
    float minValue = MAXFLOAT;
    
    _twoStockHighValue = -MAXFLOAT;
    _twoStockLowValue = MAXFLOAT;
    
    for (int i = startIndex; i <= endIndex; i++) {
        DecompressedHistoricData *hist= [historicData copyHistoricTick:type sequenceNo:i];
        float v =(hist.close-firstHist.close)/firstHist.close;
        if (maxValue < v) maxValue = v;
        if (minValue > v) minValue = v;
        if (_twoStockHighValue<hist.close) _twoStockHighValue = hist.close;
        if (_twoStockLowValue>hist.close) _twoStockLowValue = hist.close;
    }
    
    for (int i = 0; i <[_compArray count]; i++) {
        float v =([[_compArray objectAtIndex:i]floatValue]-compFirstClose)/compFirstClose;
        if (maxValue < v) maxValue = v;
        if (minValue > v) minValue = v;
    }
    
    
    
    highestValue = maxValue;
    lowestValue = minValue;
	
    DecompressedHistoricData *hist;
	
	float winLocationX;
	if(xSize<273)
		winLocationX = 0;
	else
		winLocationX = self.frame.origin.x;
    float xOffset = offsetX + drawAndScrollController.chartBarWidth / 2 - winLocationX;
    float bottom = offsetY + ySize;
    float x, y,y2, sum,sum2;
    int i;
	float xScale = drawAndScrollController.barDateWidth;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, drawAndScrollController.lineWidth);
	CGMutablePathRef path = CGPathCreateMutable();
    CGMutablePathRef path2 = CGPathCreateMutable();
	
    float levelHigh = highestValue;
    float levelLow = lowestValue;
    float diff = levelHigh - levelLow;
	BOOL first = YES;
    BOOL secFirst = YES;
    sum = 0;
    sum2 = 0;
   
    
    
    for (i = startIndex; i <= endIndex; i++)
	{
        
        hist = [historicData copyHistoricTick:type sequenceNo:i];
        sum = (hist.close-firstHist.close)/firstHist.close;
        
		x = i * xScale + xOffset;
        //TODO： diff 有時候會是空值或是nan，進而造成除以零的crash
        if(diff == 0)continue;
//          diff += 1;
        
		y = bottom - (sum - levelLow) * ySize / diff;
        
        if (hist!=nil && y > 0){

            [_pointDictionary setObject:[NSNumber numberWithFloat:y] forKey:[NSNumber numberWithFloat:i]];
        
            if (first)
            {
                first = NO;
                CGPathMoveToPoint(path, NULL, x, y);
            }
            else{
                CGPathAddLineToPoint(path, NULL, x, y);
            }
        }
        
        float hist2;
        if ([_compDictionary objectForKey:[NSNumber numberWithInt:i]] == nil) {
            hist2 = -1;
        }else{
            hist2 = [(NSNumber *)[_compDictionary objectForKey:[NSNumber numberWithInt:i]]floatValue];
        }
        
        //TODO： diff 有時候會是空值或是nan，進而造成除以零的crash
        if(diff == 0)continue;
//                diff += 1;
        
        sum2 = (hist2-compFirstClose)/compFirstClose;
        y2 =bottom - (sum2 - levelLow) * ySize / diff;
        if (hist2>-1  && !isnan(y2)) {
            //float hist2 = [[_compArray objectAtIndex:i]floatValue];
            if (secFirst)
            {
                secFirst = NO;
                CGPathMoveToPoint(path2, NULL, x, y2);
            }
            else{
                CGPathAddLineToPoint(path2, NULL, x, y2);
            }
        }
    }
        
	CGContextAddPath(context, path);
    [[UIColor blueColor] set];
    CGContextStrokePath(context);
    CGPathRelease(path);
    
	CGContextAddPath(context, path2);
     [[UIColor brownColor] set];
    CGContextStrokePath(context);
    CGPathRelease(path2);

}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	targetView = [super hitTest:point withEvent:event];
	
	if([targetView isKindOfClass:[UIButton class]])
	{
		int labelIndex = (int)[(UIButton *)targetView tag];
		
		if(labelIndex == -1)
			return [super hitTest:point withEvent:event];
		
		NSMutableDictionary *dateDict = [dateLabelInfoDict objectForKey:[NSNumber numberWithInt:labelIndex]];
		if(dateDict)
		{
			
			UInt16 startDate = [(NSNumber *)[dateDict objectForKey:@"startDate"]intValue];
			UInt16 endDate = [(NSNumber *)[dateDict objectForKey:@"endDate"]intValue];
			
			if(startDate == 0 || endDate == 0)
				return [super hitTest:point withEvent:event];
			
			[drawAndScrollController openInformationNewsTitleViewControllerByStartDate:startDate endDate:endDate];	
			
			
		}
		
	}
	
	return [super hitTest:point withEvent:event];
	
}

-(void)handLongPress:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
            [drawAndScrollController doTouchesBegan:_touches withEvent:_event];
    }else if (sender.state == UIGestureRecognizerStateChanged){
            [drawAndScrollController doTouchesMoved:_touches withEvent:_event];
    }else if (sender.state == UIGestureRecognizerStateEnded){
            [drawAndScrollController doTouchesEnded:_touches withEvent:_event];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    ac = KprepareAction;
    _drawEnd = NO;
    UITouch *touch = [[touches allObjects] lastObject];
    
    if (drawAndScrollController.crossVisible && drawAndScrollController.penBtn.selected==NO && drawAndScrollController.eraserBtn.selected == NO){
        [drawAndScrollController doTouchesBegan:touches withEvent:event];
    }
    self.touches = [[NSSet alloc]initWithSet:touches];
    self.event = event;
    if (drawAndScrollController.penBtn.selected==YES || drawAndScrollController.eraserBtn.selected == YES){
        _firstTouch = [touch locationInView:self];
        if (drawAndScrollController.lineType==TrendlineAngle || drawAndScrollController.lineType==FibonacciRetracement){
            _lastTouch = _firstTouch;
        }
        float winLocationX;
        if(xSize<273)
            winLocationX = 0;
        else
            winLocationX = self.frame.origin.x;
        NSInteger offsetXvalue = offsetX - winLocationX ;
        float xScale = drawAndScrollController.barDateWidth;
        float yScale = ySize / yLines;
        float theHighValue = highestValue;
        float theLowValue = lowestValue;
        float theHighLowSectionValue = theHighValue - theLowValue;
        float elementYValue = theHighLowSectionValue / yLines;
        
        if (drawAndScrollController.lineType==FibonacciLine && drawAndScrollController.penBtn.selected ==YES) {
            int d = (_firstTouch.x-offsetXvalue)/xScale;
            float p = (viewBottom-_firstTouch.y)/yScale * elementYValue +theLowValue;

            Line *line = [[Line alloc] init];
            line.pointA = CGPointMake(d, p);
            line.pointB = CGPointMake(d+1, p);
            line.lineType = FibonacciLine;
            line.lineNum = 1;
            [self.drawLinePoints addObject:line];
        }
        
        
//        NSMutableArray *discardedItems = [NSMutableArray array];
        if (drawAndScrollController.eraserBtn.selected) {
            secParallelLine = NO;
//            for (Line *line in self.drawLinePoints) {
//                if (_lastTouch.x >= MIN(line.pointA.x, line.pointB.x) &&
//                    _lastTouch.x <= MAX(line.pointA.x, line.pointB.x) &&
//                    _lastTouch.y >= MIN(line.pointA.y, line.pointB.y) &&
//                    _lastTouch.y <= MAX(line.pointA.y, line.pointB.y)) {
//                    
//                    double m2 = (line.pointB.y - line.pointA.y) / (line.pointB.x - line.pointA.x);
//                    double b = line.pointB.y - m2 * line.pointB.x;
//                    
//                    // 斜率大於85 magic number
//                    if (abs(m2) > 85) {
//                        [discardedItems addObject:line];
//                        break;
//                    }
//                    if (abs(m2 * _lastTouch.x + b - _lastTouch.y) < 10) {
//                        [discardedItems addObject:line];
//                        break;
//                    }
//                }
//            }
//            
//            [self.drawLinePoints removeObjectsInArray:discardedItems];
            
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (drawAndScrollController.penBtn.selected==YES || drawAndScrollController.eraserBtn.selected == YES){
        ac = KMoveAction;
        UITouch *touch = [[touches allObjects] lastObject];
        _lastTouch = [touch locationInView:self];
        if (drawAndScrollController.lineType==ParallelLine && secParallelLine) {
            _firstTouch = _lastTouch;
        }
        NSMutableArray *discardedItems = [NSMutableArray array];
        if (drawAndScrollController.eraserBtn.selected) {
            for (Line *line in self.drawLinePoints) {
                float winLocationX;
                if(xSize<273)
                    winLocationX = 0;
                else
                    winLocationX = self.frame.origin.x;
                NSInteger offsetXvalue = offsetX - winLocationX ;
                float xScale = drawAndScrollController.barDateWidth;
                float yScale = ySize / yLines;
                float theHighValue = highestValue;
                float theLowValue = lowestValue;
                float theHighLowSectionValue = theHighValue - theLowValue;
                float elementYValue = theHighLowSectionValue / yLines;
                int d = (_lastTouch.x-offsetXvalue)/xScale;
                float p = (viewBottom-_lastTouch.y)/yScale * elementYValue +theLowValue;

                float m2 = (line.pointB.y - line.pointA.y) / (line.pointB.x - line.pointA.x);
                float b = line.pointB.y - m2 * line.pointB.x;
                
                // 斜率大於85 magic number
//                    if (abs(m2) > 85) {
//                        [discardedItems addObject:line];
//                        break;
//                    }
                float ans = m2 * d + b - p;
                
                BOOL touchLine = NO;
                
                if (line.pointB.x == line.pointA.x) {
                    if (line.pointA.x == d) {
                        touchLine = YES;
                    }
                }else{
                    if (fabs(ans) <= 0.5f) {
                        touchLine = YES;
                    }
                    
                }
                
                if (touchLine) {
                    NSLog(@"ans:%f",ans);
                    if (line.lineType==TrendLine) {
                        [discardedItems addObject:line];
                    }else if (line.lineType==ParallelLine){
                        int num = (int)[_drawLinePoints indexOfObject:line];
                        if (line.lineNum==1) {
                            [discardedItems addObject:line];
                            [discardedItems addObject:[_drawLinePoints objectAtIndex:num+1]];
                        }else{
                            [discardedItems addObject:line];
                            [discardedItems addObject:[_drawLinePoints objectAtIndex:num-1]];
                        }
                    }else if (line.lineType==FibonacciLine){
                        int num = (int)[_drawLinePoints indexOfObject:line];
                        if (line.lineNum!=1) {
                            num -= line.lineNum-1;
                        }
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+1]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+2]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+3]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+4]];

                        
                    }else if (line.lineType==FibonacciFanLine){
                        int num = (int)[_drawLinePoints indexOfObject:line];
                        if (line.lineNum!=1) {
                            num -= line.lineNum-1;
                        }
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+1]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+2]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+3]];
                        
                    }else if (line.lineType==SpeedResistanceLine){
                        int num = (int)[_drawLinePoints indexOfObject:line];
                        if (line.lineNum!=1) {
                            num -= line.lineNum-1;
                        }
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+1]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+2]];

                    }else if (line.lineType==TrendlineAngle){
                        int num = (int)[_drawLinePoints indexOfObject:line];;
                        if (line.lineNum!=1) {
                            num -= line.lineNum-1;
                        }
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+1]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+2]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+3]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+4]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+5]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+6]];
                    }else if (line.lineType==FibonacciArc){
                        int num = (int)[_drawLinePoints indexOfObject:line];
                        if (line.lineNum!=1) {
                            num -= line.lineNum-1;
                        }
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+1]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+2]];
                        [discardedItems addObject:[_drawLinePoints objectAtIndex:num+3]];
                        
                    }else if (line.lineType==FibonacciRetracement){
                        int num = (int)[_drawLinePoints indexOfObject:line];
                        if (line.lineNum!=1) {
                            num -= line.lineNum-1;
                        }
                        for (int i=0; i<=[FibonacciRetracementArray count]; i++) {
                            [discardedItems addObject:[_drawLinePoints objectAtIndex:num+i]];
                        }
                        
                    }
                    
                    break;
                }
            }
            
            [self.drawLinePoints removeObjectsInArray:discardedItems];
            
            if ([_drawLinePoints count]==0) {
                [drawAndScrollController allUserLineRemove];
            }
        }
        [self setNeedsDisplay];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    ac = KPainAction;
    if (drawAndScrollController.penBtn.selected==YES || drawAndScrollController.eraserBtn.selected == YES){
        float winLocationX;
        if(xSize<273)
            winLocationX = 0;
        else
            winLocationX = self.frame.origin.x;
        NSInteger offsetXvalue = offsetX - winLocationX ;
        float xScale = drawAndScrollController.barDateWidth;
        float yScale = ySize / yLines;
        float theHighValue = highestValue;
        float theLowValue = lowestValue;
        float theHighLowSectionValue = theHighValue - theLowValue;
        float elementYValue = theHighLowSectionValue / yLines;
        
        
        
        int d = (_firstTouch.x-offsetXvalue)/xScale;
        float p = (viewBottom-_firstTouch.y)/yScale * elementYValue +theLowValue;
        
        int d2 = (_lastTouch.x-offsetXvalue)/xScale;
        float p2 = (viewBottom-_lastTouch.y)/yScale * elementYValue +theLowValue;
        
        
        if ( !secParallelLine && drawAndScrollController.lineType!=FibonacciLine) {
            
            
            if (drawAndScrollController.eraserBtn.selected == NO && drawAndScrollController.penBtn.selected == YES) {
                Line *line = [[Line alloc] init];
                line.pointA = CGPointMake(d, p);
                line.pointB = CGPointMake(d2, p2);
                if (drawAndScrollController.lineType==TrendLine) {
                    line.lineType = TrendLine;
                    _firstTouch = CGPointMake(0, 0);
                    _lastTouch = CGPointMake(0, 0);
                }else if (drawAndScrollController.lineType==ParallelLine){
                    line.lineType = ParallelLine;
                    _firstTouch = CGPointMake(0, 0);
                    _lastTouch = CGPointMake(0, 0);
                }else if (drawAndScrollController.lineType==FibonacciFanLine){
                    line.lineType = FibonacciFanLine;
                }else if (drawAndScrollController.lineType==SpeedResistanceLine){
                    line.lineType = SpeedResistanceLine;
                }else if (drawAndScrollController.lineType==FibonacciArc){
                    line.lineType = FibonacciArc;
                }
                line.lineNum = 1;
                if(drawAndScrollController.lineType!=TrendlineAngle && drawAndScrollController.lineType!=FibonacciRetracement && drawAndScrollController.lineType!=PreviousLines){
                    [self.drawLinePoints addObject:line];
                }
                
//                double m2 = (line.pointB.y - line.pointA.y) / (line.pointB.x - line.pointA.x);
//                NSLog(@"m:%f",m2);
            }
        }
        
        
        [self setNeedsDisplay];
        _drawEnd = YES;
    }
    
}

//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	if (!drawAndScrollController.comparisonSettingController.comparing)
//		[drawAndScrollController doTouchesMoved:touches withEvent:event];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//	if (!drawAndScrollController.comparisonSettingController.comparing)    
//		[drawAndScrollController doTouchesEnded:touches withEvent:event];
//}


@end
