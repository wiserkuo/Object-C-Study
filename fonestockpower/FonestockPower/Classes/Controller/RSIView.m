//
//  RSIView.m
//  BullsEyeAlpha
//
//  Created by Ming-Zhe Wu on 2008/10/13.
//  Copyright 2008 NHCUE. All rights reserved.
//

#import "RSIView.h"
#import "DrawAndScrollController.h"


//#define rsiParameter 14

static float xSize;
static float ySize;

static NSArray *viewColorList = nil;





@implementation RSIView

@synthesize drawAndScrollController;
@synthesize bottonView;

@synthesize historicData;

@synthesize chartFrame;
@synthesize chartFrameOffset; 

@synthesize xLines,yLines;
@synthesize xScale,yScale;
@synthesize currentTouchPosition;

@synthesize zoomTransform;



- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset{
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		
		chartFrame = frame;
		chartFrameOffset = offset;
		
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
//	NSMutableDictionary *parmDict = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeRSI];
	NSMutableDictionary *parmDict1 = [dataModal.indicator readNewIndicatorParameterByPeriod:period];
	rsiParameter = [(NSNumber *)[parmDict1 objectForKey:@"RSI1parameter"]intValue];
    rsi2Parameter = [(NSNumber *)[parmDict1 objectForKey:@"RSI2parameter"]intValue];

    xSize = chartFrame.size.width;
    ySize = chartFrame.size.height;

    //畫chart frame邊框
    [drawAndScrollController drawBottomChartFrameWithOffset:chartFrameOffset frameWidth:xSize frameHeight:ySize];

    UInt8 type = drawAndScrollController.historicType;
    UInt32 dataCount = [historicData tickCount:type];
    if (dataCount == 0) return;

    BOOL isDayLine = drawAndScrollController.analysisPeriod == AnalysisPeriodDay;
	

    NSInteger offsetXvalue = chartFrameOffset.x;
    NSInteger offsetYvalue = chartFrameOffset.y;

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

#pragma mark ---------------------------------------------------------------- call rsi function

    NSMutableArray *valueRSI = [self rsiValueWithDayParameter:rsiParameter];
    NSMutableArray *valueRSI2 = [self rsiValueWithDayParameter:rsi2Parameter];

#pragma mark ---------------------------------------------------------------- 畫門檻線 30/70 or 20/80

    CGContextRef context = UIGraphicsGetCurrentContext();
//
    float upperPercentLine = 0.7;
    float upperThresholdLine = (float)ySize - upperPercentLine*ySize;
//    if (valueRSI.count >= rsiParameter)
//        [self drawPercentLineWithThresholdLine:upperThresholdLine withColorIndex:1 chartFrameOffset:chartFrameOffset];
//
    float bottomPercentLine = 0.3;
    float bottomThresholdLine = (float)ySize - bottomPercentLine*ySize;
//    if (valueRSI.count >= rsiParameter)
//        [self drawPercentLineWithThresholdLine:bottomThresholdLine withColorIndex:1 chartFrameOffset:chartFrameOffset];

#pragma mark ---------------------------------------------------------------- 畫RSI data線
    
    float xSize;
    if (drawAndScrollController.penBtn.selected == YES) {
        xSize = drawAndScrollController.indexScaleView.frame.size.width;
    }else{
        xSize = drawAndScrollController.indexScaleView.frame.size.width-offsetXvalue;
    }    float winLocationX;
    if(xSize<273)
        winLocationX = 0;
    else
        winLocationX = drawAndScrollController.indexScaleView.frame.origin.x;
    
    
    NSInteger dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
    NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];

    

    int fontSLIindex;
    int rearSLIindex;
    int seq;

	fontSLIindex = 0;
	rearSLIindex = dataCount - 1;


    CGMutablePathRef path = CGPathCreateMutable();
    
    CGContextBeginPath (context);

    float v;
    float xValue = 0, yValue = 0;
    BOOL first = TRUE;

    upperThresholdLine += offsetYvalue;
    bottomThresholdLine += offsetYvalue;

 	CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor magentaColor] set];

    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {

        seq = (int)i;

        if (seq >= rsiParameter) {
            //TODO： v 有時候會是空值或是nan
            v = [(NSNumber *)[valueRSI objectAtIndex:seq] floatValue];
            if(isnan(v)) continue;
//                v = 1;
            // x軸座標值：
            xValue = offsetXvalue + i * xScale;
			
			// y軸座標值：
            yValue = offsetYvalue + ySize - v * ySize / 100;

            if (first) {
                if (yValue < upperThresholdLine) { // > upperThresholdLine EX:>70
                    CGPathMoveToPoint(path, NULL, xValue, yValue);
                }
                else if (yValue > bottomThresholdLine) { // < bottomThresholdLine EX:<30
                    CGPathMoveToPoint(path, NULL, xValue, yValue);
                }
                else { // 30 ~ 70
                    CGPathMoveToPoint(path, NULL, xValue, yValue);
                }
                first = FALSE;
            }else{
                CGPathAddLineToPoint(path, NULL, xValue, yValue);
            }
            
            CGContextStrokePath(context);
        }

        seq++;
    }

    // 為了填色必須 將path 連至 70% line (upperThresholdLine) 或 30% line (bottomThresholdLine) 以讓整條path有close loop存在
//    if (xValue > 0 && yValue > 0) {
//
//        if (yValue > bottomThresholdLine) {
//            CGPathAddLineToPoint(path, NULL, xValue, bottomThresholdLine);
//            CGContextStrokePath(context);
//        }
//        if (yValue < upperThresholdLine) {
//            CGPathAddLineToPoint(path, NULL, xValue, upperThresholdLine);
//            CGContextStrokePath(context);
//        }
//    }


    CGContextAddPath(context,path);

    CGContextStrokePath(context);
    
    
   //path2
    
    fontSLIindex = 0;
	rearSLIindex = dataCount - 1;
    
    
    CGMutablePathRef path2 = CGPathCreateMutable();
    
    CGContextBeginPath (context);
    
    xValue = 0;
    yValue = 0;
    first = TRUE;
    
    upperThresholdLine += offsetYvalue;
    bottomThresholdLine += offsetYvalue;
    
 	CGContextSetLineWidth(context, drawAndScrollController.bottomChartLineWidth);
    [[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1.0f] set];
    
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {
        
        seq = (int)i;
        
        if (seq >= rsi2Parameter) {
            //TODO： v 有時候會是空值或是nan
            v = [(NSNumber *)[valueRSI2 objectAtIndex:seq] floatValue];
            if(isnan(v)) continue;
                //                v = 1;
            // x軸座標值：
            xValue = offsetXvalue + i * xScale;
			
			// y軸座標值：
            yValue = offsetYvalue + ySize - v * ySize / 100;
            
            if (first) {
                if (yValue < upperThresholdLine) { // > upperThresholdLine EX:>70
                    CGPathMoveToPoint(path2, NULL, xValue, yValue);
                }
                else if (yValue > bottomThresholdLine) { // < bottomThresholdLine EX:<30
                    CGPathMoveToPoint(path2, NULL, xValue, yValue);
                }
                else { // 30 ~ 70
                    CGPathMoveToPoint(path2, NULL, xValue, yValue);
                }
                first = FALSE;
            }else{
                CGPathAddLineToPoint(path2, NULL, xValue, yValue);
            }
            
            
            CGContextStrokePath(context);
        }
        
        seq++;
    }
    
    
    CGContextAddPath(context,path2);
    
    CGContextStrokePath(context);

#pragma mark ---------------------------------------------------------------- fill path

//    if (xValue > 0 && yValue > 0) { // 有畫出線圖
//
//    // 填滿path位於70%以上區域
//        CGContextSaveGState(context);
//        CGContextBeginPath(context);
//
//        CGRect rectSeventy = {{ offsetXvalue, offsetYvalue }, { chartFrame.size.width, chartFrame.size.height*0.3 }};
//        CGMutablePathRef shapeSeventy = CGPathCreateMutable();
//        CGPathAddRect(shapeSeventy, NULL, rectSeventy);
//        CGContextAddPath(context, shapeSeventy);
//        CGContextClip(context);
//
//        CGContextAddPath(context, path);
//        [[UIColor lightGrayColor] set];
//        CGContextDrawPath(context, kCGPathFillStroke);
//        CGContextRestoreGState(context);
//        CGPathRelease(shapeSeventy);
//
//    // 填滿path位於30%以上區域
//        CGContextRef context2 = UIGraphicsGetCurrentContext();
//        CGContextSaveGState(context2);
//        CGContextBeginPath(context2);
//
//        CGRect rectThirty = {{ offsetXvalue, offsetYvalue + chartFrame.size.height*0.7 }, { chartFrame.size.width, chartFrame.size.height*0.3 }};
//        CGMutablePathRef shapeThirty = CGPathCreateMutable();
//        CGPathAddRect(shapeThirty, NULL, rectThirty);
//        CGContextAddPath(context2, shapeThirty);
//        //CGContextEOClip (context2);
//        CGContextClip(context2);
//
//        CGContextAddPath(context2, path);
//        CGContextClip(context2);
//
//        CGContextAddPath(context2, shapeThirty);
//        [[UIColor lightGrayColor] set];
//        CGContextDrawPath(context2, kCGPathFillStroke);
//        CGContextRestoreGState(context2);
//        CGPathRelease(shapeThirty);
//    }

    CGPathRelease(path);

    if (!CGAffineTransformIsIdentity(zoomTransform)) {
        self.transform = zoomTransform;
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        zoomTransform = CGAffineTransformIdentity;
    }
    
    //設定預設數值
    [drawAndScrollController setDefaultValue];
}


// (1)data (2)parameters:(days)

//計算每一時間刻度點的RSI值
- (NSMutableArray *)rsiValueWithDayParameter:(int)ndays {
#pragma mark ---------------------------------------------------------------- RSI function	

    /*
	//所有資料數 找最大的index
	int largestIndex = [dataList count]-1;
	
    int rearIndex = largestIndex;	

	//最大index 減去 days區間 算區間頭在 dataList中的index
	int fontIndex = largestIndex - totalDayCnt + 1;//  這邊必須保證 largestIndex > days !!!!!!

    int firstRsiIndex; // 計算rsi第一筆資料的index
	if(fontIndex<ndays){
		firstRsiIndex = ndays; // 第一筆從 ndays開始 ＥＸ： ndays=5 則算 (5-4) (4-3) (3-2) (2-1) (1-0)分別的高低的收盤價差 共五筆 
	}
	else{
		firstRsiIndex = fontIndex;	
	}
    */

	NSMutableArray *rsiValueArray= [[NSMutableArray alloc]init];
	
 
	int cntValue;

	//取某一天
 	float rsiValue;
	float avgUp = 0;
	float avgDown = 0;

    UInt8 type = drawAndScrollController.historicType;
    UInt32 count = [historicData tickCount:type];
    DecompressedHistoricData *historic;

    for (int i = 0; i < count; i++) {

		if(i < ndays){     // 假設 ndays = 5 以符合下面兩case
			
			cntValue = 0;      // case1: 3-5=-2<0 取4天 (3 2 1 0) ; 2-5=-3<0 取3天 (2 1 0) ; 1-5<0 取2天 (1 0)
		}
		else{
			
			//cntValue = i - ndays + 1;  // case2 : 10-5=5>=0 cntValue=5 取5天(取 10 9 8 7 6) ; 5-5=0>=0 cntValue=0 (取 5 4 3 2 1) ; 8-5=3 cntValue=3 (取 8 7 6 5 4)
			cntValue = i - ndays;			
		}
		
		

 		if(i<ndays){ //沒有資料
 		
			rsiValue = -0.0;
 		}
		
 		else{ // i >= ndays 可以計算rsi的資料

				//判斷是否為第一筆
				//if(i == firstRsiIndex){ 
				if (i == ndays) {

					//第一筆 avgUp avgDown 與 rsi值        
					int cnt = 0; //計數下面迴圈做了幾次 
					//for(int j=firstRsiIndex;j>cntValue;j--){ //遞減 做 ndays次           
					for (int j = ndays; j > cntValue; j--) { //遞減 做 ndays次

						// if j=i=1 , j>0 則： (1)j=1 int subValue = 第1筆 減去 第0筆
						
						// if j=2 , j>0 則： (1)j=2 int subValue = 第2筆 減去 第1筆
						//                  (2)j=1 int subValue = 第1筆 減去 第0筆				
						
						// 第Ｎ天收盤價 減去 第Ｎ-1天的收盤價
						
						//int subValue = [(NSNumber *)[[dataList objectAtIndex:j]valueForKey:@"dataClose"]intValue] - [(NSNumber *)[[dataList objectAtIndex:j-1]valueForKey:@"dataClose"]intValue];

                        historic = [historicData copyHistoricTick:type sequenceNo:j];
                        float subValue = historic.close;

                        historic = [historicData copyHistoricTick:type sequenceNo:j-1];
                        subValue -= historic.close;

						if(subValue>0){ //正數=漲
							avgUp += subValue;
						}
						else if(subValue<0){ //負數=跌
							//avgDown += abs(subValue);	
							avgDown += fabs(subValue);	
						}		
						
						cnt = cnt+1;
						
					} // end for(int j=i;j>cntValue;j--)     //case j=i1 : cntValue=0
					
					avgUp = avgUp/(cnt);		// cnt必須等於 nday
					avgDown = avgDown/(cnt);
					rsiValue = 100 * avgUp/(avgUp + avgDown);					
                }
				
			    else{ //第二筆
					


                    //int subValue = [(NSNumber *)[[dataList objectAtIndex:i]valueForKey:@"dataClose"]intValue] - [(NSNumber *)[[dataList objectAtIndex:i-1]valueForKey:@"dataClose"]intValue];

                    historic = [historicData copyHistoricTick:type sequenceNo:i];
                    float subValue = historic.close;

                    historic = [historicData copyHistoricTick:type sequenceNo:i-1];
                    subValue -= historic.close;

					if(subValue>0){ //正數=漲
						avgUp = (avgUp*(ndays-1) + subValue) / ndays;
						avgDown = (avgDown*(ndays-1)) / ndays;	
					    rsiValue = 100 * avgUp/(avgUp + avgDown);						
					}
					else if(subValue<0){ //負數=跌
						avgUp = (avgUp*(ndays-1)) / ndays;
						//avgDown = (avgDown*(ndays-1) +abs(subValue)) / ndays;													
						avgDown = (avgDown*(ndays-1) + fabsf(subValue)) / ndays;
					    rsiValue = 100 * avgUp/(avgUp + avgDown);												
					}
					else{ //不漲 不跌
					    rsiValue = 100 * avgUp/(avgUp + avgDown);					
					}
					

				}

			//}
			
		} 


		[rsiValueArray addObject:[NSNumber numberWithFloat:rsiValue]];


	} // end for(int i=fontIndex;i<totalDaysDataCount;i++)
	
 
	return rsiValueArray;
	
	
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
	
	CGPoint thresholdPoint[] =
	{
		CGPointMake(0,thresholdLine),
		CGPointMake(chartFrame.size.width,thresholdLine),
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

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3 Value4:(double*)value4;
{
    NSMutableArray *valueRSI = [self rsiValueWithDayParameter:rsiParameter];
    NSMutableArray *valueRSI2 = [self rsiValueWithDayParameter:rsi2Parameter];
	double rsiValue = -0, rsi2Value=-0,beforeRSI1=-0,beforeRSI2 = -0;
	if(index < [valueRSI count] && index >= rsiParameter-1){
		rsiValue = [(NSNumber *)[valueRSI objectAtIndex:index] floatValue];
        beforeRSI1 =[(NSNumber *)[valueRSI objectAtIndex:index-1] floatValue];
    }
    if(index < [valueRSI2 count] && index >= rsi2Parameter-1){
		rsi2Value = [(NSNumber *)[valueRSI2 objectAtIndex:index] floatValue];
        beforeRSI2 =[(NSNumber *)[valueRSI2 objectAtIndex:index-1] floatValue];
    }
	*value1 = rsiValue;
	*value2 = beforeRSI1;
	*value3 = rsi2Value;
    *value4 = beforeRSI2;
}

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3{
    
}

@end
