//
//  MacroeconomicIndexDrawView.m
//  FonestockPower
//
//  Created by Kenny on 2014/7/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "MacroeconomicIndexDrawView.h"

@implementation MacroeconomicIndexDrawView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//    }
//    return self;
//}

- (id)initWithController:(MacroeconomicDrawViewController *)controller
{
    self = [super init];
    if (self) {
        _macroeconomicDrawViewController = controller;
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    _dayWidth = self.frame.size.width/36;
    float upperLineHeight = self.frame.size.height/8.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor lightGrayColor] set];
    
    CGContextSetLineWidth(context, 0.5);
    
    for( int i=1; i<8; i++){
        CGContextMoveToPoint(context, 0, i*upperLineHeight);
        CGContextAddLineToPoint(context, self.frame.size.width, i*upperLineHeight);
    }
    CGContextStrokePath(context);
    
    CGMutablePathRef pathK = CGPathCreateMutable();
    CGMutablePathRef pathD = CGPathCreateMutable();
    
    double maxValue = -MAXFLOAT;
    double minValue = MAXFLOAT;
    for(int i=0; i<=35 && i<[_firstValueArray count]; i++){
        maxValue = MAX([(NSNumber *)[_firstValueArray objectAtIndex:i]doubleValue], maxValue);
        minValue = MIN([(NSNumber *)[_firstValueArray objectAtIndex:i]doubleValue], minValue);
    }
    float heightRate;
    if((maxValue - minValue) ==0){
        heightRate = 0;
    }else{
        heightRate = self.frame.size.height/(maxValue - minValue);
    }
    float widthRate = self.frame.size.width/36;
    int totalNum = 35;
    
    
    int sameCount = 0;
    int yearDate1 =  [(NSNumber *)[[_date1Array objectAtIndex:0] substringToIndex:4]intValue];
    int yearDate2 =  [(NSNumber *)[[_date2Array objectAtIndex:0] substringToIndex:4]intValue];
    int monthDate1 = [(NSNumber *)[[_date1Array objectAtIndex:0] substringWithRange:NSMakeRange(5, 2)]intValue];
    int monthDate2 = [(NSNumber *)[[_date2Array objectAtIndex:0] substringWithRange:NSMakeRange(5, 2)]intValue];
    
    if(yearDate2 > yearDate1 || (yearDate2 == yearDate1 && monthDate2 > monthDate1)){
        for(int i = 0; i<[_date2Array count] && i<=35; i++){
            if([[_date1Array objectAtIndex:0] isEqualToString:[_date2Array objectAtIndex:i]]){
                sameCount = i;
            }
        }
    }else{
        for(int i = 0; i<=35 && i<[_firstValueArray count]; i++){
            if([[_date2Array objectAtIndex:0] isEqualToString:[_date1Array objectAtIndex:i]]){
                sameCount = i;
            }
        }
    }
    
    double maxValue2 = -MAXFLOAT;
    double minValue2 = MAXFLOAT;
    for(int i=sameCount; i<=35 + sameCount && i<[_secondValueArray count]; i++){
        maxValue2 = MAX([(NSNumber *)[_secondValueArray objectAtIndex:i]doubleValue], maxValue2);
        minValue2 = MIN([(NSNumber *)[_secondValueArray objectAtIndex:i]doubleValue], minValue2);
    }
    float heightRate2;
    if((maxValue2 - minValue2) == 0){
        heightRate2 = 0;
    }else{
        heightRate2 = self.frame.size.height/(maxValue2 - minValue2);
    }
    float widthRate2 = self.frame.size.width/36;
    int y = 0;
    
    if(!_drawType){
        CGContextSetLineWidth(context, 1);
        for(int i = 0; i<=35 && i<[_firstValueArray count]; i++){
            
            if(heightRate ==0){
                if(i == 0){
                    CGPathMoveToPoint(pathK, NULL, widthRate * totalNum, self.frame.size.height /2);
                }else{
                    CGPathAddLineToPoint(pathK, NULL, widthRate * totalNum, self.frame.size.height /2);
                }
            }else{
                if(i == 0){
                    CGPathMoveToPoint(pathK, NULL, widthRate * totalNum, self.frame.size.height - ([(NSNumber *)[_firstValueArray objectAtIndex:i]doubleValue]-minValue) * heightRate);
                }else{
                    CGPathAddLineToPoint(pathK, NULL, widthRate * totalNum, self.frame.size.height - ([(NSNumber *)[_firstValueArray objectAtIndex:i]doubleValue]-minValue) * heightRate);
                }
            }
            if(_secondFlag && !_draw2Type){
                for(int z = 0; z<[_date2Array count]; z++){
                    if([[_date1Array objectAtIndex:i] isEqualToString:[_date2Array objectAtIndex:z]]){
                        if(heightRate2 ==0){
                            if(y == 0){
                                CGPathMoveToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height/2);
                                y++;
                            }else{
                                CGPathAddLineToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height/2);
                            }
                        }else{
                            if(y == 0){
                                CGPathMoveToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height - ([(NSNumber *)[_secondValueArray objectAtIndex:z]doubleValue]-minValue2) * heightRate2);
                                y++;
                            }else{
                                CGPathAddLineToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height - ([(NSNumber *)[_secondValueArray objectAtIndex:z]doubleValue]-minValue2) * heightRate2);
                            }
                        }
                    }
                }
            }else if(_secondFlag && _draw2Type){
                for(int z = 0; z<[_date2Array count]; z++){
                    if([[_date1Array objectAtIndex:i] isEqualToString:[_date2Array objectAtIndex:z]]){
                        if(heightRate2==0){
                            CGPathMoveToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height);
                            CGPathAddLineToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height/2);
                        }else{
                            CGPathMoveToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height);
                            CGPathAddLineToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height - ([(NSNumber *)[_secondValueArray objectAtIndex:z]doubleValue]-minValue2) * heightRate2);
                        }
                        
                    }
                }
            }
            totalNum --;
        }
    }else{
        CGContextSetLineWidth(context, 2);
        for(int i = 0; i<=35 && i<[_firstValueArray count]; i++){
            if(heightRate==0){
                CGPathMoveToPoint(pathK, NULL, widthRate * totalNum, self.frame.size.height);
                CGPathAddLineToPoint(pathK, NULL, widthRate * totalNum, self.frame.size.height/2);
            }else{
                CGPathMoveToPoint(pathK, NULL, widthRate * totalNum, self.frame.size.height);
                CGPathAddLineToPoint(pathK, NULL, widthRate * totalNum, self.frame.size.height - ([(NSNumber *)[_firstValueArray objectAtIndex:i]doubleValue]-minValue) * heightRate);
            }
            if(_secondFlag && !_draw2Type){
                for(int z = 0; z<[_date2Array count]; z++){
                    if([[_date1Array objectAtIndex:i] isEqualToString:[_date2Array objectAtIndex:z]]){
                        if(heightRate2==0){
                            if(y == 0){
                                CGPathMoveToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height/2);
                                y++;
                            }else{
                                CGPathAddLineToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height/2);
                            }
                        }else{
                            if(y == 0){
                                CGPathMoveToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height - ([(NSNumber *)[_secondValueArray objectAtIndex:z]doubleValue]-minValue2) * heightRate2);
                                y++;
                            }else{
                                CGPathAddLineToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height - ([(NSNumber *)[_secondValueArray objectAtIndex:z]doubleValue]-minValue2) * heightRate2);
                            }
                        }
                    }
                }
            }else if(_secondFlag && _draw2Type){
                for(int z = 0; z<[_date2Array count]; z++){
                    if([[_date1Array objectAtIndex:i] isEqualToString:[_date2Array objectAtIndex:z]]){
                        if(heightRate2==0){
                            CGPathMoveToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height);
                            CGPathAddLineToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height/2);
                        }else{
                            CGPathMoveToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height);
                            CGPathAddLineToPoint(pathD, NULL, widthRate2 * totalNum, self.frame.size.height - ([(NSNumber *)[_secondValueArray objectAtIndex:z]doubleValue]-minValue2) * heightRate2);
                        }
                        
                    }
                }
            }
            totalNum --;
        }
    }
    
    
    
    [ [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0] set];
    CGContextAddPath(context,pathK);
     CGContextStrokePath(context);
    
    if(_draw2Type){
        CGContextSetLineWidth(context, 2);
    }else{
        CGContextSetLineWidth(context, 1);
    }
    [[UIColor redColor] set];
    CGContextAddPath(context,pathD);
    CGContextStrokePath(context);
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    int countNum = touchPoint.x/_dayWidth;
    int num = touchPoint.x/_dayWidth;
    if([_firstValueArray count]>=35){
        num = 35-num;
    }else{
        num = (int)[_firstValueArray count]-num;
    }
    CGPoint a = CGPointMake(countNum*_dayWidth, touchPoint.y);
    if(a.x==0){
        a = CGPointMake(1, touchPoint.y);
    }
    [_macroeconomicDrawViewController doTouchesWithPoint:a number:num];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    int countNum = touchPoint.x/_dayWidth;
    int num = touchPoint.x/_dayWidth;
    if([_firstValueArray count]>=35){
        num = 35-num;
    }else{
        num = (int)[_firstValueArray count]-num;
    }
    CGPoint a = CGPointMake(countNum*_dayWidth, touchPoint.y);
    if(a.x==0){
        a = CGPointMake(1, touchPoint.y);
    }
    [_macroeconomicDrawViewController doTouchesWithPoint:a number:num];
}
@end
