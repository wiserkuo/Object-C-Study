//
//  VolatilityDrawBottomView.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "VolatilityDrawBottomView.h"

@implementation VolatilityDrawBottomView

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
    HistoryObject *lastObject = [_dataArray lastObject];
    int detailMonth = [[formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:lastObject.dataDate]uint16ToDate]]intValue];
    for(NSInteger i = [_dataArray count] - 1; i>=0; i--){
        HistoryObject *obj = [_dataArray objectAtIndex:i];
        int month = [[formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:obj.dataDate]uint16ToDate]]intValue];
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
        HistoryObject *obj = [_dataArray objectAtIndex:i];
        maxVolume = MAX(maxVolume, obj.volume);
    }
    [[UIColor colorWithRed:80.0/255.0 green:183.0/255.0 blue:5.0/255.0 alpha:1]set];
    double height = (self.frame.size.height - self.frame.size.height/5) / maxVolume;
    int widthNum = 0;
    for(NSInteger i = [_dataArray count]-1; i>=0; i--){
        HistoryObject *obj = [_dataArray objectAtIndex:i];
        CGContextMoveToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height);
        CGContextAddLineToPoint(context, self.frame.size.width - widthNum*4, self.frame.size.height - obj.volume * height);
        widthNum++;
        CGContextStrokePath(context);
    }
   
}


@end
