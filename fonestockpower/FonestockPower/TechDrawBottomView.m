//
//  TechDrawBottomView.m
//  FonestockPower
//
//  Created by Kenny on 2014/12/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TechDrawBottomView.h"
#import "TechIn.h"
#define topHeight 17
//圓的直徑
#define radius 6
@implementation TechDrawBottomView

-(id)initWithType:(NSString *)type
{
    self = [super init];
    if(self){
        _drawType = type;
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    UIColor *upColor;
    UIColor *downColor;
    
    if([[[FSFonestock sharedInstance].appId substringToIndex:2] isEqualToString:@"us"]){
        upColor = [UIColor colorWithRed:82.0/255.0 green:186.0/255.0 blue:0 alpha:1];
        downColor = [UIColor redColor];
    }else{
        downColor = [UIColor colorWithRed:82.0/255.0 green:186.0/255.0 blue:0 alpha:1];
        upColor = [UIColor redColor];
    }
    
    if([_dataArray count]==0){
        return;
    }
    CGMutablePathRef pathHLine = CGPathCreateMutable();
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor grayColor]set];
    CGContextSetLineWidth(context, 0.5);
    
    
    CGFloat length[] = {1,1};
    CGContextSetLineDash(context, 0, length, 1);
    
    double dashHeight = (self.frame.size.height - topHeight ) / 4;
    
    for(int i = 0; i <=4; i++){
        CGContextMoveToPoint(context, 0,  i * dashHeight + topHeight);
        CGContextAddLineToPoint(context, self.frame.size.width,  i * dashHeight + topHeight);
    }
    CGContextStrokePath(context);
    
    
    highValue = -MAXFLOAT;
    lowValue = MAXFLOAT;
    _startCount = _xPoint / _widthRange - 1 ;
    int endCount = _viewWidth / _widthRange + _startCount + 2;
    if(_startCount < 0){
        _startCount = 0;
    }
    if(endCount > [_dataArray count]){
        endCount = (int)[_dataArray count];
    }
    
    NSDateFormatter *formatterMonth = [[NSDateFormatter alloc] init];
    [formatterMonth setDateFormat:@"MM"];
    
    TechObject *firstObject = [_dataArray objectAtIndex:0];
    int detailMonth = [[formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:firstObject.date]uint16ToDate]]intValue];
    
    for(int i = _startCount; i<endCount; i++){
        TechObject *obj = [_dataArray objectAtIndex:i];
        int month = [[formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:obj.date]uint16ToDate]]intValue];
        if(month != detailMonth){
            detailMonth = month;
            CGContextMoveToPoint(context, i * _widthRange - 1.5 +_widthRange, topHeight);
            CGContextAddLineToPoint(context, i * _widthRange - 1.5 +_widthRange, self.frame.size.height);
            CGContextStrokePath(context);
        }
    }
    
    
    CGContextSetLineDash(context, 0, length, 0);
    
    int circleInViewCount = 0;
    
    //單量-----------------------------------
    if([_drawType isEqualToString:@"Vol"]){
        BOOL trendFlag = NO;
        BOOL trendFlag2 = NO;
        double x1;
        double x2;
        double y1_h;
        double y2_h;
       
        
        
        
        
        for(int i = _startCount; i <endCount && i !=[_dataArray count]; i ++){
            TechObject *obj = [_dataArray objectAtIndex:i];
            double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
            double v2Value = [(NSNumber *)[model.tech.v2Array objectAtIndex:i]doubleValue];
            if(isnan(v1Value) || isnan(v2Value)){
                highValue = MAX(highValue, obj.volume);
            }else{
                highValue = MAX(highValue, obj.volume);
                highValue = MAX(highValue, v1Value);
                highValue = MAX(highValue, v2Value);
            }
            //趨勢線
            if(_m==0 && _b==0){
                if(obj.date == _startDate){
                    x1 = i;
                    y1_h = obj.volume;
                    trendFlag = YES;
                }
                if(obj.date == _endDate){
                    x2 = i;
                    y2_h = obj.volume;
                    trendFlag2 = YES;
                }
            }
        }
        lowValue = 0;
        heightRate = (self.frame.size.height - topHeight) / (highValue - lowValue);
        
        //圓點
        [[UIColor blackColor]set];
        if((_startCount <= _circleStart && endCount >= _circleStart) || (_startCount <= _circleEnd && endCount >= _circleEnd) || _circleStart == 0 || _circleEnd == 0){
            for(int i = _startCount; i<endCount; i++){
                TechObject *obj = [_dataArray objectAtIndex:i];
                if(obj.date == _startDate){
                    
                    circleInViewCount++;
                    
                    _circleStart = i;
                    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height) - (obj.volume - lowValue) * heightRate, (radius + _obj.pinchValue), 0, 2*M_PI, 0);
                    CGContextDrawPath(context,kCGPathFillStroke);
                    _circleTouchX_Start = i * _widthRange + _widthRange;
                    _circleTouchY_Start = (self.frame.size.height) - (obj.volume - lowValue) * heightRate;
                }
                if(obj.date == _endDate){
                    
                    circleInViewCount++;
                    
                    _circleEnd = i;
                    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height) - (obj.volume - lowValue) * heightRate, (radius + _obj.pinchValue), 0, 2*M_PI, 0);
                    CGContextDrawPath(context,kCGPathFillStroke);
                    _circleTouchX_End = i * _widthRange + _widthRange;
                    _circleTouchY_End = (self.frame.size.height) - (obj.volume - lowValue) * heightRate;
                }
            }
        }
        
        [[UIColor purpleColor]set];
        CGContextSetLineWidth(context, 1);
        BOOL firstFlag = NO;
        for(int i = _startCount; i<endCount; i ++){
            double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
            if(!isnan(v1Value)){
                if(!firstFlag){
                    CGContextMoveToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v1Value - lowValue) * heightRate);
                    firstFlag = YES;
                }else if(i > model.tech.valueNum1){
                    CGContextAddLineToPoint(context, i * _widthRange + _widthRange , (self.frame.size.height) - (v1Value - lowValue) * heightRate);
                }
            }
        }
        CGContextStrokePath(context);
        
        [[UIColor blueColor]set];
        firstFlag = NO;
        for(int i = _startCount; i<endCount; i ++){
            double v2Value = [(NSNumber *)[model.tech.v2Array objectAtIndex:i]doubleValue];
            if(!isnan(v2Value)){
                if(!firstFlag){
                    CGContextMoveToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v2Value - lowValue) * heightRate);
                    firstFlag = YES;
                }else if(i > model.tech.valueNum2){
                    CGContextAddLineToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v2Value - lowValue) * heightRate);
                }
            }
        }
        CGContextStrokePath(context);
        

        
        
        BOOL hLineFirstFlag = NO;
        CGContextSetLineWidth(context, 4 + _obj.pinchValue);
        for(int i = _startCount; i <endCount; i ++){
            
            if (circleInViewCount >= 1) {
            
                
                
                if(trendFlag && trendFlag2){
                    _m = (y2_h - y1_h)/(x2 - x1);
                    _b = -(_m * x1 - y1_h);
                }
                if(!(_m==0 && _b==0)){
                    double y = _m * i + _b;
                    if(!hLineFirstFlag){
                        if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                            CGPathMoveToPoint(pathHLine, NULL, i * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                            hLineFirstFlag = YES;
                        }
                    }else{
                        if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                            CGPathAddLineToPoint(pathHLine, NULL, i * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                        }
                    }
                    if(endCount == [_dataArray count]){
                        int lastCount = endCount + 1;
                        double y = _m * lastCount + _b;
                        if(!hLineFirstFlag){
                            if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                                CGPathMoveToPoint(pathHLine, NULL, lastCount * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                                hLineFirstFlag = YES;
                            }
                        }else{
                            if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                                CGPathAddLineToPoint(pathHLine, NULL, lastCount * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                            }
                        }
                    }
                }
                
                
                
            
            }
            //量的柱狀圖
            TechObject *obj = [_dataArray objectAtIndex:i];
            if(obj.open > obj.last){
                [downColor set];
            }else if(obj.open < obj.last){
                [upColor set];
            }else{
                [[UIColor blueColor]set];
            }
            CGContextMoveToPoint(context, i * _widthRange+_widthRange, self.frame.size.height);
            CGContextAddLineToPoint(context, i * _widthRange+_widthRange, (self.frame.size.height) - (obj.volume - lowValue) * heightRate);
            CGContextStrokePath(context);
        }
        CGContextSetLineWidth(context, 3);
        CGContextAddPath(context,pathHLine);
        [[UIColor blackColor] set];
        CGPathRelease(pathHLine);
        CGContextStrokePath(context);
        
        
    //KD------------------------------------------------
    }else if([_drawType isEqualToString:@"KD"]){
        highValue = 100;
        lowValue = 0;
        heightRate = (self.frame.size.height-dashHeight) / (highValue - lowValue);
        
        
        CGContextSetLineWidth(context, 1);
        BOOL firstFlag = NO;
        BOOL trendFlag = NO;
        BOOL trendFlag2 = NO;
        double x1;
        double x2;
        double y1_h;
        double y2_h;
        BOOL hLineFirstFlag = NO;
        for(int i = _startCount; i<endCount; i ++){
            double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
            TechObject *obj = [_dataArray objectAtIndex:i];
            //趨勢線
            if(_m==0 && _b==0){
                if(obj.date == _startDate){
                    x1 = i;
                    y1_h = v1Value;
                    trendFlag = YES;
                }
                if(obj.date == _endDate){
                    x2 = i;
                    y2_h = v1Value;
                    trendFlag2 = YES;
                }
            }
        }
        [[UIColor blackColor]set];
        if((_startCount <= _circleStart && endCount >= _circleStart) || (_startCount <= _circleEnd && endCount >= _circleEnd) || _circleStart == 0 || _circleEnd == 0){
            for(int i =_startCount; i<endCount; i++){
                TechObject *obj = [_dataArray objectAtIndex:i];
                double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
                //圓點
                if(obj.date == _startDate){
                    
                    circleInViewCount++;
                    
                    _circleStart = i;
                    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v1Value - lowValue) * heightRate, (radius + _obj.pinchValue), 0, 2*M_PI, 0);
                    CGContextDrawPath(context,kCGPathFillStroke);
                    _circleTouchX_Start = i * _widthRange + _widthRange;
                    _circleTouchY_Start = (self.frame.size.height) - (v1Value - lowValue) * heightRate;
                }
                if(obj.date == _endDate){
                    
                    circleInViewCount++;
                    
                    _circleEnd = i;
                    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v1Value - lowValue) * heightRate, (radius + _obj.pinchValue), 0, 2*M_PI, 0);
                    CGContextDrawPath(context,kCGPathFillStroke);
                    _circleTouchX_End = i * _widthRange + _widthRange;
                    _circleTouchY_End = (self.frame.size.height) - (v1Value - lowValue) * heightRate;
                }
            }
        }
        [[UIColor purpleColor]set];
        for(int i = _startCount; i<endCount; i ++){
            
            if (circleInViewCount >= 1) {
                
                if(trendFlag && trendFlag2){
                    _m = (y2_h - y1_h)/(x2 - x1);
                    _b = -(_m * x1 - y1_h);
                }
                if(!(_m==0 && _b==0)){
                    double y = _m * i + _b;
                    if(!hLineFirstFlag){
                        if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                            CGPathMoveToPoint(pathHLine, NULL, i * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                            hLineFirstFlag = YES;
                        }
                    }else{
                        if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                            CGPathAddLineToPoint(pathHLine, NULL, i * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                        }
                    }
                    if(endCount == [_dataArray count]){
                        int lastCount = endCount + 1;
                        double y = _m * lastCount + _b;
                        if(!hLineFirstFlag){
                            if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                                CGPathMoveToPoint(pathHLine, NULL, lastCount * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                                hLineFirstFlag = YES;
                            }
                        }else{
                            if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                                CGPathAddLineToPoint(pathHLine, NULL, lastCount * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                            }
                        }
                    }
                }
                
            }
            double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
            if(!isnan(v1Value)){
                if(!firstFlag){
                    CGContextMoveToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v1Value - lowValue) * heightRate);
                    firstFlag = YES;
                }else if(i > model.tech.kNum){
                    CGContextAddLineToPoint(context, i * _widthRange + _widthRange , (self.frame.size.height) - (v1Value - lowValue) * heightRate);
                }
            }
        }
        CGContextStrokePath(context);
        CGContextSetLineWidth(context, 3);
        CGContextAddPath(context,pathHLine);
        [[UIColor blackColor] set];
        CGPathRelease(pathHLine);
        CGContextStrokePath(context);
        
        CGContextSetLineWidth(context, 1);
        [[UIColor blueColor]set];
        firstFlag = NO;
        for(int i = _startCount; i<endCount; i ++){
            double v2Value = [(NSNumber *)[model.tech.v2Array objectAtIndex:i]doubleValue];
            if(!isnan(v2Value)){
                if(!firstFlag){
                    CGContextMoveToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v2Value - lowValue) * heightRate);
                    firstFlag = YES;
                }else if(i > model.tech.dNum){
                    CGContextAddLineToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v2Value - lowValue) * heightRate);
                }
            }
        }
        CGContextStrokePath(context);

    }else if([_drawType isEqualToString:@"RSI"]){
        highValue = 100;
        lowValue = 0;
        heightRate = (self.frame.size.height-dashHeight) / (highValue - lowValue);
        
        
        CGContextSetLineWidth(context, 1);
        BOOL firstFlag = NO;
        BOOL trendFlag = NO;
        BOOL trendFlag2 = NO;
        double x1;
        double x2;
        double y1_h;
        double y2_h;
        BOOL hLineFirstFlag = NO;
        for(int i = _startCount; i<endCount; i ++){
            double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
            TechObject *obj = [_dataArray objectAtIndex:i];
            //趨勢線
            if(_m==0 && _b==0){
                if(obj.date == _startDate){
                    x1 = i;
                    y1_h = v1Value;
                    trendFlag = YES;
                }
                if(obj.date == _endDate){
                    x2 = i;
                    y2_h = v1Value;
                    trendFlag2 = YES;
                }
            }
        }
        [[UIColor blackColor]set];
        if((_startCount <= _circleStart && endCount >= _circleStart) || (_startCount <= _circleEnd && endCount >= _circleEnd) || _circleStart == 0 || _circleEnd == 0){
            for(int i = _startCount; i<endCount; i++){
                TechObject *obj = [_dataArray objectAtIndex:i];
                double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
                //圓點
                if(obj.date == _startDate){
                    
                    circleInViewCount++;
                    
                    
                    _circleStart = i;
                    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v1Value - lowValue) * heightRate, (radius + _obj.pinchValue), 0, 2*M_PI, 0);
                    CGContextDrawPath(context,kCGPathFillStroke);
                    _circleTouchX_Start = i * _widthRange + _widthRange;
                    _circleTouchY_Start = (self.frame.size.height) - (v1Value - lowValue) * heightRate;
                }
                if(obj.date == _endDate){
                    
                    circleInViewCount++;
                    
                    
                    _circleEnd = i;
                    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v1Value - lowValue) * heightRate, (radius + _obj.pinchValue), 0, 2*M_PI, 0);
                    CGContextDrawPath(context,kCGPathFillStroke);
                    _circleTouchX_End = i * _widthRange + _widthRange;
                    _circleTouchY_End = (self.frame.size.height) - (v1Value - lowValue) * heightRate;
                }
            }
        }
        
        [[UIColor purpleColor]set];
        for(int i = _startCount; i<endCount; i ++){
            
            if (circleInViewCount >= 1) {
                
                
                if(trendFlag && trendFlag2){
                    _m = (y2_h - y1_h)/(x2 - x1);
                    _b = -(_m * x1 - y1_h);
                }
                if(!(_m==0 && _b==0)){
                    double y = _m * i + _b;
                    if(!hLineFirstFlag){
                        if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                            CGPathMoveToPoint(pathHLine, NULL, i * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                            hLineFirstFlag = YES;
                        }
                    }else{
                        if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                            CGPathAddLineToPoint(pathHLine, NULL, i * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                        }
                    }
                    if(endCount == [_dataArray count]){
                        int lastCount = endCount + 1;
                        double y = _m * lastCount + _b;
                        if(!hLineFirstFlag){
                            if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                                CGPathMoveToPoint(pathHLine, NULL, lastCount * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                                hLineFirstFlag = YES;
                            }
                        }else{
                            if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                                CGPathAddLineToPoint(pathHLine, NULL, lastCount * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                            }
                        }
                    }
                }
                
            }
            double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
            if(!isnan(v1Value)){
                if(!firstFlag){
                    CGContextMoveToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v1Value - lowValue) * heightRate);
                    firstFlag = YES;
                }else if(i > model.tech.rsiNum1){
                    CGContextAddLineToPoint(context, i * _widthRange + _widthRange , (self.frame.size.height) - (v1Value - lowValue) * heightRate);
                }
            }
        }
        CGContextStrokePath(context);
        CGContextSetLineWidth(context, 3);
        CGContextAddPath(context,pathHLine);
        [[UIColor blackColor] set];
        CGPathRelease(pathHLine);
        CGContextStrokePath(context);
        
        CGContextSetLineWidth(context, 1);
        [[UIColor blueColor]set];
        firstFlag = NO;
        for(int i = _startCount; i<endCount; i ++){
            double v2Value = [(NSNumber *)[model.tech.v2Array objectAtIndex:i]doubleValue];
            if(!isnan(v2Value)){
                if(!firstFlag){
                    CGContextMoveToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v2Value - lowValue) * heightRate);
                    firstFlag = YES;
                }else if(i > model.tech.rsiNum2){
                    CGContextAddLineToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height) - (v2Value - lowValue) * heightRate);
                }
            }
        }
        CGContextStrokePath(context);
    }else if([_drawType isEqualToString:@"MACD"]){
        BOOL trendFlag = NO;
        BOOL trendFlag2 = NO;
        double x1;
        double x2;
        double y1_h;
        double y2_h;

        for(int i = _startCount; i <endCount; i ++){
            TechObject *obj = [_dataArray objectAtIndex:i];
            double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
            double v2Value = [(NSNumber *)[model.tech.v2Array objectAtIndex:i]doubleValue];
            if(!(isnan(v1Value) || isnan(v2Value))){
                highValue = MAX(highValue, v1Value);
                highValue = MAX(highValue, v2Value);
                lowValue = MIN(lowValue, v1Value);
                lowValue = MIN((lowValue), v2Value);
            }
            //趨勢線
            if(_m==0 && _b==0){
                if(obj.date == _startDate){
                    x1 = i;
                    y1_h = v2Value;
                    trendFlag = YES;
                }
                if(obj.date == _endDate){
                    x2 = i;
                    y2_h = v2Value;
                    trendFlag2 = YES;
                }
            }
        }
        double macdValue = 0;
        if(highValue > fabs(lowValue)){
            macdValue = highValue;
        }else{
            macdValue = fabs(lowValue);
        }
        
        highValue = macdValue;
        lowValue = -macdValue;

        heightRate = (self.frame.size.height-dashHeight) / (highValue * 2 );
        
        [[UIColor blackColor]set];
        if((_startCount <= _circleStart && endCount >= _circleStart) || (_startCount <= _circleEnd && endCount >= _circleEnd) || _circleStart == 0 || _circleEnd == 0){
            for(int i = _startCount; i<endCount; i++){
                TechObject *obj = [_dataArray objectAtIndex:i];
                double v2Value = [(NSNumber *)[model.tech.v2Array objectAtIndex:i]doubleValue];
                //圓點
                if(obj.date == _startDate){
                    
                    circleInViewCount++;
                    
                    
                    _circleStart = i;
                    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height+dashHeight) / 2 - v2Value * heightRate, (radius + _obj.pinchValue), 0, 2*M_PI, 0);
                    CGContextDrawPath(context,kCGPathFillStroke);
                    _circleTouchX_Start = i * _widthRange + _widthRange;
                    _circleTouchY_Start = (self.frame.size.height+dashHeight) / 2 - v2Value * heightRate;
                }
                if(obj.date == _endDate){
                    
                    circleInViewCount++;
                    
                    
                    _circleEnd = i;
                    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height+dashHeight) / 2 - v2Value * heightRate, (radius + _obj.pinchValue), 0, 2*M_PI, 0);
                    CGContextDrawPath(context,kCGPathFillStroke);
                    _circleTouchX_End = i * _widthRange + _widthRange;
                    _circleTouchY_End = (self.frame.size.height+dashHeight) / 2 - v2Value * heightRate;
                }
            }
        }
        
        
        [[UIColor purpleColor]set];
        CGContextSetLineWidth(context, 1);
        BOOL firstFlag = NO;
        for(int i = _startCount; i<endCount; i ++){
            double v1Value = [[model.tech.v1Array objectAtIndex:i]doubleValue];
            if(!isnan(v1Value)){
                if(!firstFlag){
                    CGContextMoveToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height+dashHeight) / 2 - v1Value * heightRate);
                    firstFlag = YES;
                }else if(i > model.tech.macdNum){
                    CGContextAddLineToPoint(context, i * _widthRange + _widthRange , (self.frame.size.height+dashHeight) / 2 - v1Value * heightRate);
                }
            }
        }
        CGContextStrokePath(context);
        
        CGContextSetLineWidth(context, 4 + _obj.pinchValue);
        for(int i = _startCount; i<endCount; i++){
            double v3Value = [(NSNumber *)[model.tech.v3Array objectAtIndex:i]doubleValue];
            if(!isnan(v3Value)){
                if(v3Value >= 0){
                    [[UIColor brownColor]set];
                }else{
                    [[UIColor grayColor]set];
                }
                CGContextMoveToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height+dashHeight)/2);
                CGContextAddLineToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height+dashHeight) / 2 - v3Value * heightRate);
                CGContextStrokePath(context);
            }
        }
        
        CGContextSetLineWidth(context, 1);
        [[UIColor blueColor]set];
        firstFlag = NO;
        BOOL hLineFirstFlag = NO;
        for(int i = _startCount; i<endCount; i ++){
            
            if (circleInViewCount >= 1) {
                
                
                if(trendFlag && trendFlag2){
                    _m = (y2_h - y1_h)/(x2 - x1);
                    _b = -(_m * x1 - y1_h);
                }
                if(!(_m==0 && _b==0)){
                    double y = _m * i + _b;
                    if(!hLineFirstFlag){
                        if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                            CGPathMoveToPoint(pathHLine, NULL, i * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                            hLineFirstFlag = YES;
                        }
                    }else{
                        if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                            CGPathAddLineToPoint(pathHLine, NULL, i * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                        }
                    }
                    if(endCount == [_dataArray count]){
                        int lastCount = endCount + 1;
                        double y = _m * lastCount + _b;
                        if(!hLineFirstFlag){
                            if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                                CGPathMoveToPoint(pathHLine, NULL, lastCount * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                                hLineFirstFlag = YES;
                            }
                        }else{
                            if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                                CGPathAddLineToPoint(pathHLine, NULL, lastCount * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                            }
                        }
                    }
                }
                
            }
            
            double v2Value = [(NSNumber *)[model.tech.v2Array objectAtIndex:i]doubleValue];
            if(!isnan(v2Value)){
                if(!firstFlag){
                    CGContextMoveToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height+dashHeight) / 2 - v2Value * heightRate);
                    firstFlag = YES;
                }else if(i > model.tech.emaNum2){
                    CGContextAddLineToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height+dashHeight) / 2 - v2Value * heightRate);
                }
                
                
            }
        }
        CGContextStrokePath(context);
        CGContextSetLineWidth(context, 3);
        CGContextAddPath(context,pathHLine);
        [[UIColor blackColor] set];
        CGPathRelease(pathHLine);
        CGContextStrokePath(context);
        
        
        
    }else if([_drawType isEqualToString:@"OBV"]){

        for(int i = _startCount; i <endCount; i ++){
            double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
            if(!isnan(v1Value)){
                highValue = MAX(highValue, v1Value);
                lowValue = MIN(lowValue, v1Value);
            }
        }
        double obvValue = 0;
        if(highValue > fabs(lowValue)){
            obvValue = highValue;
        }else{
            obvValue = fabs(lowValue);
        }
        
        highValue = obvValue;
        lowValue = -obvValue;
        
        heightRate = (self.frame.size.height-dashHeight) / (highValue * 2 );
        
        CGContextSetLineWidth(context, 1);
        
        BOOL firstFlag = NO;
        BOOL trendFlag = NO;
        BOOL trendFlag2 = NO;
        double x1;
        double x2;
        double y1_h;
        double y2_h;
        BOOL hLineFirstFlag = NO;
        for(int i = _startCount; i<endCount; i ++){
            double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
            TechObject *obj = [_dataArray objectAtIndex:i];
            //趨勢線
            if(_m==0 && _b==0){
                if(obj.date == _startDate){
                    x1 = i;
                    y1_h = v1Value;
                    trendFlag = YES;
                }
                if(obj.date == _endDate){
                    x2 = i;
                    y2_h = v1Value;
                    trendFlag2 = YES;
                }
            }
        }
        [[UIColor blackColor]set];
        if((_startCount <= _circleStart && endCount >= _circleStart) || (_startCount <= _circleEnd && endCount >= _circleEnd) || _circleStart == 0 || _circleEnd == 0){
            for(int i = _startCount; i<endCount; i++){
                TechObject *obj = [_dataArray objectAtIndex:i];
                double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
                //圓點
                if(obj.date == _startDate){
                    
                    circleInViewCount++;
                    
                    
                    _circleStart = i;
                    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height+dashHeight) / 2 - v1Value * heightRate, (radius+ _obj.pinchValue), 0, 2*M_PI, 0);
                    CGContextDrawPath(context,kCGPathFillStroke);
                    _circleTouchX_Start = i * _widthRange + _widthRange;
                    _circleTouchY_Start = (self.frame.size.height+dashHeight) / 2 - v1Value * heightRate;
                }
                if(obj.date == _endDate){
                    
                    circleInViewCount++;
                    
                    
                    _circleEnd = i;
                    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height+dashHeight) / 2 - v1Value * heightRate, (radius+ _obj.pinchValue), 0, 2*M_PI, 0);
                    CGContextDrawPath(context,kCGPathFillStroke);
                    _circleTouchX_End = i * _widthRange + _widthRange;
                    _circleTouchY_End = (self.frame.size.height+dashHeight) / 2 - v1Value * heightRate;
                }
            }
        }
        
        [[UIColor brownColor]set];
        for(int i = _startCount; i<endCount; i ++){
            
            if (circleInViewCount >= 1) {
                if(trendFlag && trendFlag2){
                    _m = (y2_h - y1_h)/(x2 - x1);
                    _b = -(_m * x1 - y1_h);
                }
                if(!(_m==0 && _b==0)){
                    double y = _m * i + _b;
                    if(!hLineFirstFlag){
                        if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                            CGPathMoveToPoint(pathHLine, NULL, i * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                            hLineFirstFlag = YES;
                        }
                    }else{
                        if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                            CGPathAddLineToPoint(pathHLine, NULL, i * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                        }
                    }
                    if(endCount == [_dataArray count]){
                        int lastCount = endCount + 1;
                        double y = _m * lastCount + _b;
                        if(!hLineFirstFlag){
                            if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                                CGPathMoveToPoint(pathHLine, NULL, lastCount * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                                hLineFirstFlag = YES;
                            }
                        }else{
                            if((self.frame.size.height) - (y - lowValue) * heightRate > topHeight){
                                CGPathAddLineToPoint(pathHLine, NULL, lastCount * _widthRange + _widthRange, (self.frame.size.height) - (y - lowValue) * heightRate);
                            }
                        }
                    }
                }
            }
            double v1Value = [(NSNumber *)[model.tech.v1Array objectAtIndex:i]doubleValue];
            if(!isnan(v1Value)){
                if(!firstFlag){
                    CGContextMoveToPoint(context, i * _widthRange + _widthRange, (self.frame.size.height+dashHeight) / 2 - v1Value * heightRate);
                    firstFlag = YES;
                }else if(i > model.tech.obvNum){
                    CGContextAddLineToPoint(context, i * _widthRange + _widthRange , (self.frame.size.height+dashHeight) / 2 - v1Value * heightRate);
                }
            }
        }
        CGContextStrokePath(context);
        CGContextSetLineWidth(context, 3);
        CGContextAddPath(context,pathHLine);
        [[UIColor blackColor] set];
        CGPathRelease(pathHLine);
        CGContextStrokePath(context);
    }

    [_obj setBRLabel];
    [_obj setBLabel:(_xPoint + _viewWidth - _widthRange) / _widthRange];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _obj.touch = touches;
    _obj.event = event;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if(touchPoint.x >= _circleTouchX_Start-(radius+ _obj.pinchValue) && touchPoint.x <= _circleTouchX_Start+(radius+ _obj.pinchValue) && touchPoint.y <= _circleTouchY_Start + (radius+ _obj.pinchValue) && touchPoint.y >= _circleTouchY_Start - (radius+ _obj.pinchValue)){
        [_obj theTranportation:TouchPointStart :touches];
    }
    if(touchPoint.x >= _circleTouchX_End-(radius+ _obj.pinchValue) && touchPoint.x <= _circleTouchX_End+(radius+ _obj.pinchValue) && touchPoint.y <= _circleTouchY_End + (radius+ _obj.pinchValue) && touchPoint.y >= _circleTouchY_End - (radius+ _obj.pinchValue)){
        [_obj theTranportation:TouchPointEnd :touches];
    }
}

@end
