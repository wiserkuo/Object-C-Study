//
//  UpperView.m
//  BullsEyeAlpha
//
//  Created by Ming-Zhe Wu on 2008/10/29.
//  Copyright 2008 NHCUE. All rights reserved.
//

#import "UpperView.h"
#define mainChartNumberOfTables 2

#define indicatorNumberOfTables 3

#define IS_IPAD [[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound
@interface UpperView(){
    NSInteger currentStatus;
    NSInteger lastStatus;
}
@end

@implementation UpperView

@synthesize drawAndScrollController;


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		
		parmValue1 = -1;
		parmValue2 = -1;
		parmValue3 = -1;
        parmValue4 = -1;
		parmValue5 = -1;
		parmValue6 = -1;
        
		
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
    CGRect r = drawAndScrollController.indexScrollView.frame;
    float x = r.size.width + 1;
    int screenWidth;
    if (UIInterfaceOrientationIsPortrait(drawAndScrollController.interfaceOrientation)){
        screenWidth = drawAndScrollController.view.bounds.size.width;
        currentStatus = 1;
    }else{
        screenWidth = drawAndScrollController.view.bounds.size.width *0.91-1;
        currentStatus = 2;
    }
    
    float w = screenWidth - x;
    float titleLabelWidth;
    if(IS_IPAD)
        titleLabelWidth = UIInterfaceOrientationIsPortrait(drawAndScrollController.interfaceOrientation)?45 : 38;//w;//45;
    else{
        if(w < 0)
            titleLabelWidth = 45;
        else
            titleLabelWidth = w;
    }
    float titleLabelOffsetDown = 1;
    
    if(currentStatus == lastStatus){
        [titleLabel setFrame:CGRectMake(x - 0.5, titleLabelOffsetDown, titleLabelWidth, 13)];
    }else{
        [titleLabel removeFromSuperview];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x - 0.5, titleLabelOffsetDown, titleLabelWidth, 13)];
        titleLabel.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:140.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:10.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
    }
    lastStatus = currentStatus;
    
    if (drawAndScrollController.twoLine) {
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.text =NSLocalizedStringFromTable(@"DBL stk", @"Draw", @"");
    }else{
        if (drawAndScrollController.upperViewMainChar == UpperViewCandleChar) {
            titleLabel.text = NSLocalizedStringFromTable(@"Candle", @"Draw", @"");
        }else if (drawAndScrollController.upperViewMainChar == UpperViewOHLCChar){
            titleLabel.text = NSLocalizedStringFromTable(@"OHLC", @"Draw", @"");
        }
    }
    
    //畫外框虛線
    CGContextRef context1 = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context1, 1);
    CGFloat length[]={2,1};
    CGContextSetLineDash(context1, 0, length, 1);
	[[UIColor lightGrayColor] set];
    
    UIRectFrame(CGRectMake(-1, r.origin.y-1, r.origin.x+r.size.width+2, r.size.height+2));
    
    CGContextSetLineDash(context1, 0, NULL, 0);
    //畫外框
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 1);
	[[UIColor blackColor] set];
    
	UIRectFrame(CGRectMake(self.bounds.origin.x-1,self.bounds.origin.y,self.bounds.size.width-0.5,self.bounds.size.height));
	
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	
	//顯示週期名稱:
	UIFont *font = [UIFont fontWithName:@"Arial" size:11];
	[[UIColor colorWithRed:0.78 green:0.76 blue:0.45 alpha:1] set];
//	NSString *title = [self titleForAnalysisPeriod:drawAndScrollController.analysisPeriod];
	//[title drawAtPoint:CGPointMake(3, 1) withFont:font];
    
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
    
    float title1Location;
    float title2Location;
    float title2_2Location;
    float title3Location;
    
    if (self.frame.size.width<=320) {
        title1Location = 3;
        title2Location = 110;
        title2_2Location = 100;
        title3Location = 190;
    }else{
        
        title1Location = 3;
        title2Location = 210;
        title2_2Location = 140;
        title3Location = 280;
        
    }
    float value1Location;
    float value1_2Location;
    float value2Location;
    float value2_2Location;
    float value3Location;
    float BBvalue1;
    float BBvalue2;
    
    if (self.frame.size.width <=320) {
        value1Location = 50;
        value1_2Location = 35;
        value2Location = 200;
        value2_2Location = 130;
        value3Location = 220;
        BBvalue1 = 150;
        BBvalue2 = 220;
    }else{
        value1Location = 100;
        value1_2Location = 35;
        value2Location = 340;
        value2_2Location = 170;
        value3Location = 310;
        BBvalue1 = 260;
        BBvalue2 = 330;
    }

	
    NSDictionary *attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
	
	if (drawAndScrollController.twoLine)
	{
        
        NSString *movingAverage1;
        movingAverage1 = @"CLOSE:";
//        [movingAverage1 drawAtPoint:CGPointMake(0, 2) withFont:font];
        [movingAverage1 drawAtPoint:CGPointMake(title1Location, 2) withAttributes:attributes];
        
        if(parmValue1 > 0 && parmValue1 != INFINITY){ //十字線定位取值畫value
            if(parmValue1>parmValue3){
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                movingAverage1 = [NSString stringWithFormat:@"%0.2f↑",parmValue1];
            }else if (parmValue3>parmValue1){
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                movingAverage1 = [NSString stringWithFormat:@"%0.2f↓",parmValue1];
            }else{
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                movingAverage1 = [NSString stringWithFormat:@"%0.2f",parmValue1];
            }
            [movingAverage1 drawAtPoint:CGPointMake(value1Location, 2) withAttributes:attributes];
        }
        
        
        
        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor brownColor]};
        
        NSString *bollinger;
        bollinger = @"CLOSE:";
        [bollinger drawAtPoint:CGPointMake(title2Location, 2) withAttributes:attributes];
        
        if(parmValue2 > 0 && parmValue2 != INFINITY){ //十字線定位取值畫value
            
            if(parmValue2>parmValue4){
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                bollinger = [NSString stringWithFormat:@"%0.2f↑",parmValue2];
            }else if (parmValue4>parmValue2){
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                bollinger = [NSString stringWithFormat:@"%0.2f↓",parmValue2];
            }else{
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                bollinger = [NSString stringWithFormat:@"%0.2f",parmValue2];
            }
            [bollinger drawAtPoint:CGPointMake(value2Location, 2) withAttributes:attributes];
        }

	}
	
	else
	{
		if( drawAndScrollController.upperViewIndicator == UpperViewMAIndicator)
		{
            
			//移動平均線1～6 是畫圖區上方Mxxx 的地方
			//顯示移動平均線1資訊 (MA1)
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:(float)192/255 green:(float)16/255 blue:(float)192/255 alpha:1]};
			
//			NSMutableDictionary *parameterDictionary1 = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeShortMA];
			int parm1 = [dataModal.indicator getValueInNewIndicatorByParameter:@"MA1" Period:period];
			
			NSString *movingAverage1;
			movingAverage1 = [NSString stringWithFormat:@"M%02d:",parm1];
            [movingAverage1 drawAtPoint:CGPointMake(title1Location, 2) withAttributes:attributes];
                
            if(parmValue1 > 0 && parmValue1 != INFINITY){ //十字線定位取值畫value
                
                if(parmValue1>parmValue4){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                    movingAverage1 = [NSString stringWithFormat:@"%0.2f↑",parmValue1];
                }else if (parmValue4>parmValue1){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                    movingAverage1 = [NSString stringWithFormat:@"%0.2f↓",parmValue1];
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    movingAverage1 = [NSString stringWithFormat:@"%0.2f",parmValue1];
                }
                [movingAverage1 drawAtPoint:CGPointMake(value1_2Location, 2) withAttributes:attributes];
            }
			
			
			//顯示移動平均線2資訊 (MA2)
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:(float)197/255 green:(float)128/255 blue:(float)32/255 alpha:1]};
			
//			NSMutableDictionary *parameterDictionary2 = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeMiddleMA];
			int parm2 = [dataModal.indicator getValueInNewIndicatorByParameter:@"MA2" Period:period];
			
			NSString *movingAverage2;
			movingAverage2 = [NSString stringWithFormat:@"M%02d:",parm2];
            [movingAverage2 drawAtPoint:CGPointMake(title2_2Location, 2) withAttributes:attributes];

            if(parmValue2 > 0 && parmValue2 != INFINITY){ //十字線定位取值畫value
                if(parmValue2>parmValue5){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                    movingAverage2 = [NSString stringWithFormat:@"%0.2f↑",parmValue2];
                }else if (parmValue5>parmValue2){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                    movingAverage2 = [NSString stringWithFormat:@"%0.2f↓",parmValue2];
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    movingAverage2 = [NSString stringWithFormat:@"%0.2f",parmValue2];
                }
                [movingAverage2 drawAtPoint:CGPointMake(value2_2Location, 2) withAttributes:attributes];
            }
				
			
			//顯示移動平均線2資訊 (MA3)
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:(float)102/255 green:(float)128/255 blue:(float)200/255 alpha:1]};
			
//			NSMutableDictionary *parameterDictionary3 = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeLongMA];
			int parm3 = [dataModal.indicator getValueInNewIndicatorByParameter:@"MA3" Period:period];
//			[parameterDictionary3 release];
			
			NSString *movingAverage3;
			movingAverage3 = [NSString stringWithFormat:@"M%02d:",parm3];
            [movingAverage3 drawAtPoint:CGPointMake(title3Location, 2) withAttributes:attributes];
            
            if(parmValue3 > 0 && parmValue3 != INFINITY){ //十字線定位取值畫value
                if(parmValue3>parmValue6){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                    movingAverage3 = [NSString stringWithFormat:@"%0.2f↑",parmValue3];
                }else if (parmValue6>parmValue3){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                    movingAverage3 = [NSString stringWithFormat:@"%0.2f↓",parmValue3];
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    movingAverage3 = [NSString stringWithFormat:@"%0.2f",parmValue3];
                }
                [movingAverage3 drawAtPoint:CGPointMake(value3Location, 2) withAttributes:attributes];
            }
            
            if ((drawAndScrollController.autoLayoutIndex%3)==2) {
                //顯示移動平均線4資訊 (MA4)
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:(float)140/255 green:(float)180/255 blue:(float)99/255 alpha:1]};
                
//                NSMutableDictionary *parameterDictionary4 = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeShortMA];
                int parm4 = [dataModal.indicator getValueInNewIndicatorByParameter:@"MA4" Period:period];
                
                NSString *movingAverage4;
                movingAverage4 = [NSString stringWithFormat:@"M%02d:",parm4];
                [movingAverage4 drawAtPoint:CGPointMake(title1Location, 15) withAttributes:attributes];
                    
                if(ma4Param > 0 && ma4Param != INFINITY){ //十字線定位取值畫value
                    
                    if(ma4Param>ma4BeforeParam){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        movingAverage4 = [NSString stringWithFormat:@"%0.2f↑",ma4Param];
                    }else if (ma4BeforeParam>ma4Param){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        movingAverage4 = [NSString stringWithFormat:@"%0.2f↓",ma4Param];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        movingAverage4 = [NSString stringWithFormat:@"%0.2f",ma4Param];
                    }
                    [movingAverage4 drawAtPoint:CGPointMake(value1_2Location, 15) withAttributes:attributes];
                    
                }
                
                //顯示移動平均線5資訊 (MA5)
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:(float)255/255 green:(float)20/255 blue:(float)147/255 alpha:1]};
                
//                NSMutableDictionary *parameterDictionary5 = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeShortMA];
                int parm5 = [dataModal.indicator getValueInNewIndicatorByParameter:@"MA5" Period:period];
                
                NSString *movingAverage5;
                movingAverage5 = [NSString stringWithFormat:@"M%02d:",parm5];
                [movingAverage5 drawAtPoint:CGPointMake(title2_2Location, 15) withAttributes:attributes];
                    
                if(ma5Param > 0 && ma5Param != INFINITY){ //十字線定位取值畫value
                    
                    if(ma5Param>ma5BeforeParam){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        movingAverage5 = [NSString stringWithFormat:@"%0.2f↑",ma5Param];
                    }else if (ma5BeforeParam>ma5Param){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        movingAverage5 = [NSString stringWithFormat:@"%0.2f↓",ma5Param];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        movingAverage5 = [NSString stringWithFormat:@"%0.2f",ma5Param];
                    }
                    [movingAverage5 drawAtPoint:CGPointMake(value2_2Location, 15) withAttributes:attributes];
                    
                }
                
                //顯示移動平均線6資訊 (MA6)
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:(float)130/255 green:(float)190/255 blue:(float)210/255 alpha:1]};
                
//                NSMutableDictionary *parameterDictionary6 = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeShortMA];
                int parm6 = [dataModal.indicator getValueInNewIndicatorByParameter:@"MA6" Period:period];
                
                NSString *movingAverage6;
                movingAverage6 = [NSString stringWithFormat:@"M%02d:",parm6];
                [movingAverage6 drawAtPoint:CGPointMake(title3Location, 15) withAttributes:attributes];
                    
                if(ma6Param > 0 && ma6Param != INFINITY){ //十字線定位取值畫value
                    
                    if(ma6Param>ma6BeforeParam){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        movingAverage6 = [NSString stringWithFormat:@"%0.2f↑",ma6Param];
                    }else if (ma6BeforeParam>ma6Param){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        movingAverage6 = [NSString stringWithFormat:@"%0.2f↓",ma6Param];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        movingAverage6 = [NSString stringWithFormat:@"%0.2f",ma6Param];
                    }
                    [movingAverage6 drawAtPoint:CGPointMake(value3Location, 15) withAttributes:attributes];
                    
                }
            }
            
            
            
		}
		
		else if( drawAndScrollController.upperViewIndicator == UpperViewBBIndicator)
		{
			
			//NSMutableDictionary *parameterDictionary2 = [dataModal.indicator readIndicatorParameterByAnalysisType:AnalysisTypeBB];
			//int parm = [(NSNumber *)[parameterDictionary2 objectForKey:@"indicatorParameter1"]intValue];
            int parm = [dataModal.indicator getValueInNewIndicatorByParameter:@"BB" Period:period];
			//[parameterDictionary2 release];
			
			
			//顯示移動平均線1資訊 (短MA)
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:(float)197/255 green:(float)128/255 blue:(float)32/255 alpha:1]};
			
			NSString *movingAverage1;
            movingAverage1 = [NSString stringWithFormat:@"M%02d:",parm];
            [movingAverage1 drawAtPoint:CGPointMake(title1Location, 2) withAttributes:attributes];

            if(parmValue1 > 0 && parmValue1 != INFINITY){ //十字線定位取值畫value
                if(parmValue1>parmValue4){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                    movingAverage1 = [NSString stringWithFormat:@"%0.2f↑",parmValue1];
                }else if (parmValue4>parmValue1){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                    movingAverage1 = [NSString stringWithFormat:@"%0.2f↓",parmValue1];
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    movingAverage1 = [NSString stringWithFormat:@"%0.2f",parmValue1];
                }
                [movingAverage1 drawAtPoint:CGPointMake(value1Location, 2) withAttributes:attributes];
            }
			
			//顯示布林格通道資訊
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:(float)192/255 green:(float)16/255 blue:(float)192/255 alpha:1]};
            
            NSString *bollinger;
			bollinger = [NSString stringWithFormat:@"BB%02d:",parm];
            [bollinger drawAtPoint:CGPointMake(title2Location, 2) withAttributes:attributes];
			
            if(parmValue3 > 0 && parmValue3 != INFINITY){ //十字線定位取值畫value
                
                if(parmValue3>parmValue6){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                    bollinger = [NSString stringWithFormat:@"%0.2f↑",parmValue3];
                }else if (parmValue6>parmValue3){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                    bollinger = [NSString stringWithFormat:@"%0.2f↓",parmValue3];
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    bollinger = [NSString stringWithFormat:@"%0.2f",parmValue3];
                }
                [bollinger drawAtPoint:CGPointMake(BBvalue1, 2) withAttributes:attributes];
            }
			

            NSString *bollinger2;
			
            if(parmValue2 > 0 && parmValue2 != INFINITY){ //十字線定位取值畫value
                if(parmValue2>parmValue5){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                    bollinger2 = [NSString stringWithFormat:@"%0.2f↑",parmValue2];
                }else if (parmValue5>parmValue2){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                    bollinger2 = [NSString stringWithFormat:@"%0.2f↓",parmValue2];
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    bollinger2 = [NSString stringWithFormat:@"%0.2f",parmValue2];
                }
                [bollinger2 drawAtPoint:CGPointMake(BBvalue2, 2) withAttributes:attributes];
            }

        }else if (drawAndScrollController.upperViewIndicator == UpperViewSARIndicator){
            
            
            int parm = [dataModal.indicator getValueInNewIndicatorByParameter:@"SAR" Period:period];
			
			
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:(float)197/255 green:(float)128/255 blue:(float)32/255 alpha:1]};
			
			NSString *sar;
            sar = [NSString stringWithFormat:@"SAR%02d:",parm];
            [sar drawAtPoint:CGPointMake(title1Location, 2) withAttributes:attributes];
			
            if(parmValue1 > 0 && parmValue1 != INFINITY){ //十字線定位取值畫value
                if(parmValue1>parmValue2){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                    sar = [NSString stringWithFormat:@"%0.2f↑",parmValue1];
                }else if (parmValue2>parmValue1){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                    sar = [NSString stringWithFormat:@"%0.2f↓",parmValue1];
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    sar = [NSString stringWithFormat:@"%0.2f",parmValue1];
                }
                [sar drawAtPoint:CGPointMake(value2_2Location, 2) withAttributes:attributes];
            }
        }
	}
}

- (NSString *)titleForAnalysisPeriod:(AnalysisPeriod)period {
	
    switch (period) {
        case AnalysisPeriodDay: return NSLocalizedStringFromTable(@"Daily", @"Draw", @"The daily K-line navigation button");
        case AnalysisPeriodWeek: return NSLocalizedStringFromTable(@"Weekly", @"Draw", @"The weekly K-line navigation button");
        case AnalysisPeriodMonth: return NSLocalizedStringFromTable(@"Monthly", @"Draw", @"The monthly K-line navigation button");
        case AnalysisPeriod5Minute: return NSLocalizedStringFromTable(@"5Minutely", @"Draw", @"The 5-minutely K-line navigation button");
        case AnalysisPeriod15Minute: return NSLocalizedStringFromTable(@"15Minutely", @"Draw", @"The 15-minutely K-line navigation button");
        case AnalysisPeriod30Minute: return NSLocalizedStringFromTable(@"30Minutely", @"Draw", @"The 30-minutely K-line navigation button");
        case AnalysisPeriod60Minute: return NSLocalizedStringFromTable(@"60Minutely", @"Draw", @"The 60-minutely K-line navigation button");
        default: return nil;
    }
}
- (void)loadUpperViewIndicatorValueFor:(UpperViewIndicator)type withParmValue1:(double)value1 parmValue2:(double)value2 parmValue3:(double)value3 parmValue4:(double)value4 parmValue5:(double)value5 parmValue6:(double)value6{
	
	switch (type) {
		case UpperViewMAIndicator:
			parmValue1 = value1;
			parmValue2 = value2;	
			parmValue3 = value3;
            parmValue4 = value4;
			parmValue5 = value5;
			parmValue6 = value6;
			break;
		case UpperViewBBIndicator:
			parmValue1 = value1;
			parmValue2 = value2;	
			parmValue3 = value3;
            parmValue4 = value4;
			parmValue5 = value5;
			parmValue6 = value6;
			break;
        case UpperViewSARIndicator:
			parmValue1 = value1;
			parmValue2 = value2;
            break;
        case UpperViewTwoLine:
            parmValue1 = value1;
			parmValue2 = value2;
			parmValue3 = value3;
            parmValue4 = value4;
            break;
		default:
			parmValue1 = -1;
			parmValue2 = -1;
			parmValue3 = -1;
            parmValue4 = -1;
			parmValue5 = -1;
			parmValue6 = -1;
			break;
	}

}

- (void)loadMAValueFor:(UpperViewIndicator)type withMa4Param:(double)value1 Ma5Param:(double)value2 Ma6Param:(double)value3 Ma4BeforeParam:(double)value4 Ma5BeforeParam:(double)value5 Ma6BeforeParam:(double)value6{
    switch (type) {
		case UpperViewMAIndicator:
			ma4Param = value1;
			ma5Param = value2;
			ma6Param = value3;
            ma4BeforeParam = value4;
			ma5BeforeParam = value5;
			ma6BeforeParam = value6;
			break;
        default:
			ma4Param = -1;
			ma5Param = -1;
			ma6Param = -1;
            ma4BeforeParam = -1;
			ma5BeforeParam = -1;
			ma6BeforeParam = -1;
			break;
    }
}

- (void)refleshPeriodTitleAndIndicatorValue{
	
//	parmValue1 = -1;
//	parmValue2 = -1;
//	parmValue3 = -1;
//    parmValue4 = -1;
//	parmValue5 = -1;
//	parmValue6 = -1;
	[self setNeedsDisplay];
	
}

- (NSString *)upperViewIndicatorNameWithIndex:(int)index{
	
	NSString *name;
	
	switch (index) {
		case 1:
			name = NSLocalizedStringFromTable(@"Moving Average", @"Draw", @"");
			break;
		case 2:
			name = NSLocalizedStringFromTable(@"Bollinger Bands", @"Draw", @"");
			break;
        case 3:
            name = NSLocalizedStringFromTable(@"SAR", @"Draw", @"");
			break;
		default:
			break;
	}

	return name;

}

- (NSString *)upperViewMainCharNameWithIndex:(int)index{
	
	NSString *name;
	
	switch (index) {
		case 1:
			name = NSLocalizedStringFromTable(@"Candle", @"Draw", @"");
			break;
		case 2:
			name = NSLocalizedStringFromTable(@"OHLC", @"Draw", @"");
			break;
		default:
			break;
	}
    
	return name;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //[self openUpperIndicatorPicker];
}


#pragma mark PickerList

- (void)openUpperIndicatorPicker{
    mainCharShow = NO;
    indicatorShow = NO;
    section1CellNumber = 1;
    section2CellNumber = 1;
    self.ShowIndex = [[NSMutableArray alloc]init];
    
    cxAlertView = [[CustomIOS7AlertView alloc]init];
    float viewH,viewW;
    if (UIInterfaceOrientationIsPortrait(drawAndScrollController.interfaceOrientation)){
        viewH = 350;
        viewW = self.frame.size.width-30;
    }else{
        viewH = 190;
        viewW = 300;
    }
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 40,viewW , viewH)];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 5,viewW, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedStringFromTable(@"UpperIndicatorSheetTitle", @"Draw", @"The title of the picker list for selecting indicators");
    [cxAlertView setTitleLabel:label];
    [cxAlertView setContainerView:view];
    cxAlertView.delegate = self;
    [cxAlertView setButtonTitles:@[NSLocalizedStringFromTable(@"Cancel", @"Draw", nil)]];
    
    tableview=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) style:UITableViewStylePlain];
    tableview.delegate=self;
    tableview.dataSource=self;
    tableview.bounces = NO;
    tableview.backgroundView=nil;
    [view addSubview:tableview];
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:NSLocalizedStringFromTable(@"完成", @"setting", @"Done")]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 5.0f, 50.0f, 28.0f);
//    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    //closeButton.tintColor = [UIColor blueColor];
    [closeButton addTarget:self action:@selector(dismissActionSheet) forControlEvents:UIControlEventValueChanged];
		
	selectIndicatorIndex = drawAndScrollController.upperViewIndicator;
    selectMainChartIndex = drawAndScrollController.upperViewMainChar;
    
    [cxAlertView show];
}

-(void)closeUpperIndicatorPicker{
    [cxAlertView close];
}

-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [cxAlertView close];
    drawAndScrollController.upperViewPicker = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger cellNumber;
    if (section ==0) {
        cellNumber = section1CellNumber;
    }else{
        cellNumber = section2CellNumber;
    }
    return cellNumber;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==0 ) {
        
        NSString *CELLID=[NSString stringWithFormat:@"cellid%d",(int)indexPath.row];
        
        UITableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:CELLID];
        if (cell==nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELLID];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
        }
        cell.tag=indexPath.row;
        cell.textLabel.font=[UIFont systemFontOfSize:15];
        if (indexPath.section==0) {
            cell.textLabel.text=NSLocalizedStringFromTable(@"Main Chart", @"Draw", @"");
        }else{
            cell.textLabel.text=NSLocalizedStringFromTable(@"Tech Indicator", @"Draw", @"");
        }
        
        return cell;
        
    }
    else{
        
        static NSString *Cellid=@"cellid000";
        
        FSUITableViewCell *cell1=[tableview dequeueReusableCellWithIdentifier:Cellid];
        if (cell1==nil) {
            cell1=[[FSUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellid];
            cell1.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        cell1.tag=indexPath.row;
        cell1.textLabel.font=[UIFont systemFontOfSize:15];
        if (indexPath.section==0) {
            cell1.textLabel.text=[NSString stringWithFormat:@"         %@",[self upperViewMainCharNameWithIndex:(int)indexPath.row]];
        }else {
            cell1.textLabel.text=[NSString stringWithFormat:@"         %@",[self upperViewIndicatorNameWithIndex:(int)indexPath.row]];
        }
        
        
        return cell1;
        
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!mainCharShow && indexPath.row ==0 && indexPath.section==0) {
        if (indicatorShow) {
            [self deleteRow:indexPath Section:1];
        }
        [self insertRow:indexPath Section:0];
    }
    else if(mainCharShow && indexPath.row ==0 && indexPath.section==0){
        
        [self deleteRow:indexPath Section:0];
        
    }else if (!indicatorShow && indexPath.row ==0 && indexPath.section==1) {
        if (mainCharShow) {
            [self deleteRow:indexPath Section:0];
        }
        [self insertRow:indexPath Section:1];
    }
    else if(indicatorShow && indexPath.row ==0 && indexPath.section==1){
        
        [self deleteRow:indexPath Section:1];
        
    }
    else {
        if (indexPath.section==0) {
            selectMainChartIndex = (int)indexPath.row-1;
        }else if (indexPath.section==1){
            selectIndicatorIndex = (int)indexPath.row-1;
        }
        
        if (mainCharShow) {
            [self deleteRow:indexPath Section:0];
        }else if (indicatorShow) {
            [self deleteRow:indexPath Section:1];
        }
        
        [self dismissActionSheet];
        
    }
}

- (void)insertRow:(NSIndexPath *)indexPath Section:(NSInteger)section
{
    [_ShowIndex removeAllObjects];
    NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
    
    if (section==0) {
        mainCharShow=YES;
        
        for (int i=1; i<=mainChartNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row+i) inSection:0];
            [_ShowIndex addObject:indexPathToInsert];
            
            [rowToInsert addObject:indexPathToInsert];
        }
        
        section1CellNumber=mainChartNumberOfTables+1;
    }else if(section==1){
        indicatorShow=YES;
        
        for (int i=1; i<=indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row+i) inSection:1];
            [_ShowIndex addObject:indexPathToInsert];
            
            [rowToInsert addObject:indexPathToInsert];
        }
        
        section2CellNumber=indicatorNumberOfTables+1;
    }
    
    [tableview beginUpdates];
    
    [tableview insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationLeft];
    [tableview endUpdates];
    
}

//pickerView消失；

- (void)deleteRow:(NSIndexPath *)RowtoDelete Section:(NSInteger)section
{
    
    if (section==0) {
        mainCharShow=NO;
        section1CellNumber=1;
    }else if (section==1){
        indicatorShow=NO;
        section2CellNumber=1;
    }
    NSMutableArray* rowToDelete = [[NSMutableArray alloc] init];
    for (int i=0; i<[_ShowIndex count]; i++) {
        NSIndexPath* indexPathToDelete = [_ShowIndex objectAtIndex:i];
        [rowToDelete addObject:indexPathToDelete];
    }
    
    [tableview beginUpdates];
    [tableview deleteRowsAtIndexPaths:rowToDelete withRowAnimation:UITableViewRowAnimationLeft];
    [tableview endUpdates];
    
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	
	NSInteger componentCount = 1;
	
	return componentCount;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	
	// upperView indicators count	
	return 2;	
    
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	
	float componentWidth = 240;
		
	return componentWidth;
    
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	
		if (view == nil) {
			
			CGSize size = [pickerView rowSizeForComponent:0];
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
			
			label.backgroundColor = [UIColor clearColor];
			label.textAlignment = NSTextAlignmentCenter;
			label.font = [label.font fontWithSize:24];			
			view = label;
		}
		
		((UILabel *)view).text = [self upperViewIndicatorNameWithIndex:(int)row];
		
    return view;
}


- (void)dismissActionSheet
{
    
    FSDataModelProc * dataModal = [FSDataModelProc sharedInstance];
	switch (selectIndicatorIndex)
	{
		case 0:
			drawAndScrollController.upperViewIndicator = UpperViewMAIndicator;			
			break;
		case 1:
			drawAndScrollController.upperViewIndicator = UpperViewBBIndicator;
			break;
        case 2:
            drawAndScrollController.upperViewIndicator = UpperViewSARIndicator;
            break;
		default:
			break;
	}
    
    switch (selectMainChartIndex) {
        case 0:
            drawAndScrollController.upperViewMainChar = UpperViewCandleChar;
            break;
        case 1:
            drawAndScrollController.upperViewMainChar = UpperViewOHLCChar;
            break;
        default:
            break;
    }
    [dataModal.indicator setUpperViewDefaultMainChart:drawAndScrollController.upperViewMainChar IndicatorType:drawAndScrollController.upperViewIndicator PeriodType:drawAndScrollController.analysisPeriod];
	
    [cxAlertView close];
    drawAndScrollController.upperViewPicker = NO;
	[drawAndScrollController.indexView prepareDataToDraw];
	[drawAndScrollController.indexView setNeedsDisplay];
    [drawAndScrollController.indexScaleView getHigestAndLowest];
	[drawAndScrollController.indexScaleView setNeedsDisplay];
	[self setNeedsDisplay];
}


-(void)selectUpperViewType{
    FSDataModelProc * dataModal = [FSDataModelProc sharedInstance];
    if(drawAndScrollController.analysisPeriod==AnalysisPeriodDay){
        drawAndScrollController.upperViewIndicator = dataModal.indicator.UpperViewDayIndicator;
        drawAndScrollController.upperViewMainChar = dataModal.indicator.upperViewDayMainChart;
    }else if (drawAndScrollController.analysisPeriod==AnalysisPeriodWeek){
        drawAndScrollController.upperViewIndicator = dataModal.indicator.UpperViewWeekIndicator;
        drawAndScrollController.upperViewMainChar = dataModal.indicator.upperViewWeekMainChart;
    }else if (drawAndScrollController.analysisPeriod==AnalysisPeriodMonth){
        drawAndScrollController.upperViewIndicator = dataModal.indicator.UpperViewMonIndicator;
        drawAndScrollController.upperViewMainChar = dataModal.indicator.upperViewMonMainChart;
    }else{
        drawAndScrollController.upperViewIndicator = dataModal.indicator.UpperViewMinIndicator;
        drawAndScrollController.upperViewMainChar = dataModal.indicator.upperViewMinMainChart;
    }
    
//    [cxAlertView close];
    drawAndScrollController.upperViewPicker = NO;
	[drawAndScrollController.indexView prepareDataToDraw];
	[drawAndScrollController.indexView setNeedsDisplay];
    [drawAndScrollController.indexScaleView getHigestAndLowest];
	[drawAndScrollController.indexScaleView setNeedsDisplay];
	[self setNeedsDisplay];
}


@end
