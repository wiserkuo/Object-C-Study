//
//  HistoryDrawMidView.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "HistoryDrawMidView.h"
#import "HistoryModel.h"

@implementation HistoryDrawMidView


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    
    //虛線
    CGContextSetLineWidth(context, 0.5);
    CGFloat lengths[] = {1,1};
    CGContextSetLineDash(context, 0, lengths, 2);
    
    float dashHeightRate = self.frame.size.height/5;
    
    if([self.dataArray count] * 4 > self.frame.size.width){
        for(int i = 1; i < 5; i++){
            CGContextMoveToPoint(context, 0, dashHeightRate*i);
            CGContextAddLineToPoint(context, self.frame.size.width, dashHeightRate*i);
        }
    }else{
        for(int i = 1; i < 5; i++){
            CGContextMoveToPoint(context, 0, dashHeightRate*i);
            CGContextAddLineToPoint(context, self.frame.size.width, dashHeightRate*i);
        }
    }
    
    CGContextStrokePath(context);
    
    NSDateFormatter *formatterMonth = [[NSDateFormatter alloc] init];
    [formatterMonth setDateFormat:@"MM"];
    
    int timeWidthNum = 0;
    HistoryDrawObject *firstObject = [_dataArray objectAtIndex:0];
    int detailMonth = [[formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:firstObject->date]uint16ToDate]]intValue];
    for(int i = 0; i<[_dataArray count]; i++){
        HistoryDrawObject *obj = [_dataArray objectAtIndex:i];
        int month = [[formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:obj->date]uint16ToDate]]intValue];
        if(month != detailMonth){
            detailMonth = month;
            CGContextMoveToPoint(context, self.frame.size.width - timeWidthNum*4, dashHeightRate);
            CGContextAddLineToPoint(context, self.frame.size.width - timeWidthNum*4, self.frame.size.height);
            CGContextStrokePath(context);
        }
        timeWidthNum ++;
    }
    
    CGContextSetLineDash(context, 0, 0, 0);
    
    CGContextSetLineWidth(context, 3);
    
    int maxVolume = -MAXFLOAT;
    
    for(int i = 0; i<[_dataArray count];i++){
        HistoryDrawObject *obj = [_dataArray objectAtIndex:i];
        maxVolume = MAX(maxVolume, obj->volume);
    }
    double height = (self.frame.size.height - self.frame.size.height/5) / maxVolume;
    int widthNum = 0;
    for(int i = 0; i<[_dataArray count]; i++){
        HistoryDrawObject *obj = [_dataArray objectAtIndex:i];
        if(i == [_dataArray count]-1){
            [[UIColor redColor]set];
        }else{
            HistoryDrawObject *beforeObj = [_dataArray objectAtIndex:i+1];
            if(obj->lastPrice < beforeObj->lastPrice){
                [[UIColor colorWithRed:81.0/255.0 green:184.0/255.0 blue:3.0/255.0 alpha:1]set];
            }else if(obj->lastPrice > beforeObj->lastPrice){
                [[UIColor redColor]set];
            }else{
                [[UIColor colorWithRed:29.0/255.0 green:135.0/255.0 blue:236/255.0 alpha:1]set];
            }
        }
        CGContextMoveToPoint(context, self.frame.size.width - widthNum*4-3, self.frame.size.height);
        CGContextAddLineToPoint(context, self.frame.size.width - widthNum*4-3, self.frame.size.height - obj->volume * height);
        widthNum++;
        CGContextStrokePath(context);
    }
    
    
}


@end
