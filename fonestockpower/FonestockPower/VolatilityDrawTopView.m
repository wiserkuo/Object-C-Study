//
//  VolatilityDrawTopView.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "VolatilityDrawTopView.h"

@implementation VolatilityDrawTopView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    
    //虛線
    CGContextSetLineWidth(context, 0.5);
    CGFloat lengths[] = {1,1};
    CGContextSetLineDash(context, 0, lengths, 2);
    
    float dashHeightRate = (self.frame.size.height - 40)/6;
    
    if([self.dataArray count] * 4 > self.frame.size.width){
        for(int i = 0; i < 7; i++){
            CGContextMoveToPoint(context, 0, 20+dashHeightRate*i);
            CGContextAddLineToPoint(context, [self.dataArray count]*4, 20+dashHeightRate*i);
        }
    }else{
        for(int i = 0; i < 7; i++){
            CGContextMoveToPoint(context, 0, 20+dashHeightRate*i);
            CGContextAddLineToPoint(context, self.frame.size.width, 20+dashHeightRate*i);
        }
    }
    
    CGContextStrokePath(context);
    
    
    CGContextSetLineDash(context, 0, 0, 0);
    CGContextSetLineWidth(context, 1);
    
    double maxValue = -MAXFLOAT;
    double minValue = MAXFLOAT;
    for(int i =0; i<[_dataArray count]; i++){
        HistoryObject *obj = [_dataArray objectAtIndex:i];
        
        if(_hvFlag){
            if(_hv30Flag){
                maxValue = MAX(maxValue, obj.hv_30);
                minValue = MIN(minValue, obj.hv_30);
            }
            if(_hv60Flag){
                maxValue = MAX(maxValue, obj.hv_60);
                minValue = MIN(minValue, obj.hv_60);
            }
            if(_hv90Flag){
                maxValue = MAX(maxValue, obj.hv_90);
                minValue = MIN(minValue, obj.hv_90);
            }
            if(_hv120Flag){
                maxValue = MAX(maxValue, obj.hv_120);
                minValue = MIN(minValue, obj.hv_120);
            }
        }
        if(_ivFlag){
            maxValue = MAX(maxValue, obj.iv);
            minValue = MIN(minValue, obj.iv);
        }
        if(_sivFlag){
            maxValue = MAX(maxValue, obj.siv);
            minValue = MIN(minValue, obj.siv);
        }
        if(_bivFlag){
            maxValue = MAX(maxValue, obj.biv);
            minValue = MIN(minValue, obj.biv);
        }
    }
   
    double drawHeightRate = (self.frame.size.height - 40) / (maxValue - minValue);
    
    if(_hvFlag){
        //HV 30
        if(_hv30Flag){
            [[UIColor brownColor] set];
            int widthNum = 0;
            for(NSInteger i = [_dataArray count]-1; i>=0; i--){
                HistoryObject *obj = [_dataArray objectAtIndex:i];
                if(i==[_dataArray count]-1){
                    CGContextMoveToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.hv_30 - minValue)*drawHeightRate);
                }else{
                    CGContextAddLineToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.hv_30 - minValue)*drawHeightRate);
                }
                widthNum ++;
            }
            CGContextStrokePath(context);
        }
        
        //HV 60
        if(_hv60Flag){
            [[UIColor colorWithRed:122.0/255.0 green:193.0/255.0 blue:254.0/255.0 alpha:1]set];
            int widthNum = 0;
            for(NSInteger i = [_dataArray count]-1; i>=0; i--){
                HistoryObject *obj = [_dataArray objectAtIndex:i];
                if(i==[_dataArray count]-1){
                    CGContextMoveToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.hv_60 - minValue)*drawHeightRate);
                }else{
                    CGContextAddLineToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.hv_60 - minValue)*drawHeightRate);
                }
                widthNum ++;
            }
            CGContextStrokePath(context);
        }
        
        //HV90
        if(_hv90Flag){
            [[UIColor colorWithRed:125.0/255.0 green:1 blue:0 alpha:1]set];
            int widthNum = 0;
            for(NSInteger i = [_dataArray count]-1; i>=0; i--){
                HistoryObject *obj = [_dataArray objectAtIndex:i];
                if(i==[_dataArray count]-1){
                    CGContextMoveToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.hv_90 - minValue)*drawHeightRate);
                }else{
                    CGContextAddLineToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.hv_90 - minValue)*drawHeightRate);
                }
                widthNum ++;
            }
            CGContextStrokePath(context);
        }
        
        if(_hv120Flag){
            [[UIColor colorWithRed:65.0/255.0 green:200.0/255.0 blue:0 alpha:1]set];
            int widthNum = 0;
            for(NSInteger i = [_dataArray count]-1; i>=0; i--){
                HistoryObject *obj = [_dataArray objectAtIndex:i];
                if(i==[_dataArray count]-1){
                    CGContextMoveToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.hv_120 - minValue)*drawHeightRate);
                }else{
                    CGContextAddLineToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.hv_120 - minValue)*drawHeightRate);
                }
                widthNum ++;
            }
            CGContextStrokePath(context);
        }
    }
    
    //IV
    if(_ivFlag){
        [[UIColor colorWithRed:253.0/255.0 green:210.0/255.0 blue:0 alpha:1]set];
        int widthNum = 0;
        for(NSInteger i = [_dataArray count]-1; i>=0; i--){
            HistoryObject *obj = [_dataArray objectAtIndex:i];
            if(i==[_dataArray count]-1){
                CGContextMoveToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.iv - minValue)*drawHeightRate);
            }else{
                CGContextAddLineToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.iv - minValue)*drawHeightRate);
            }
            widthNum ++;
        }
        CGContextStrokePath(context);
    }
    
    //SIV
    if(_sivFlag){
        [[UIColor redColor]set];
        int widthNum = 0;
        for(NSInteger i = [_dataArray count]-1; i>=0; i--){
            HistoryObject *obj = [_dataArray objectAtIndex:i];
            if(i==[_dataArray count]-1){
                CGContextMoveToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.siv - minValue)*drawHeightRate);
            }else{
                CGContextAddLineToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.siv - minValue)*drawHeightRate);
            }
            widthNum ++;
        }
        CGContextStrokePath(context);
    }
    
    //BIV
    if(_bivFlag){
        [[UIColor colorWithRed:242.0/255.0 green:0 blue:1 alpha:1]set];
        int widthNum = 0;
        for(NSInteger i = [_dataArray count]-1; i>=0; i--){
            HistoryObject *obj = [_dataArray objectAtIndex:i];
            if(i==[_dataArray count]-1){
                CGContextMoveToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.biv - minValue)*drawHeightRate);
            }else{
                CGContextAddLineToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height -20 - (obj.biv - minValue)*drawHeightRate);
            }
            widthNum ++;
        }
        CGContextStrokePath(context);
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributesText = @{ NSFontAttributeName: [UIFont systemFontOfSize:10.0f],
                                      NSParagraphStyleAttributeName: paragraphStyle,
                                      NSForegroundColorAttributeName: [UIColor blackColor]};

    NSDateFormatter *formatterMonth = [[NSDateFormatter alloc] init];
    [formatterMonth setDateFormat:@"MM"];
    
    int timeWidthNum = 0;
    HistoryObject *lastObject = [_dataArray lastObject];
    int detailMonth = [[formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:lastObject.dataDate]uint16ToDate]]intValue];
    CGContextSetLineWidth(context, 0.5);
    CGContextSetLineDash(context, 0, lengths, 2);
    for(NSInteger i = [_dataArray count] - 1; i>=0; i--){
        HistoryObject *obj = [_dataArray objectAtIndex:i];
        int month = [[formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:obj.dataDate]uint16ToDate]]intValue];
        if(month != detailMonth){
            NSString * timeLabel = [NSString stringWithFormat:@"%d", detailMonth];
            [timeLabel drawInRect:CGRectMake(self.frame.size.width - timeWidthNum*4, self.frame.size.height-15, 20, 20) withAttributes:attributesText];
            detailMonth = month;
            
            CGContextMoveToPoint(context, self.frame.size.width - timeWidthNum*4, 20);
            CGContextAddLineToPoint(context, self.frame.size.width - timeWidthNum*4, self.frame.size.height -20);
            CGContextStrokePath(context);
        }
        timeWidthNum ++;
    }
}


@end
