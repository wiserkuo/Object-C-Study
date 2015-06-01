//
//  HistoryDrawTopView.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "HistoryDrawTopView.h"
#import "HistoryModel.h"

@implementation HistoryDrawTopView


- (void)drawRect:(CGRect)rect {
    
    if(_itemArray ==nil){
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    
    //虛線
    CGContextSetLineWidth(context, 0.5);
    CGFloat lengths[] = {1,1};
    CGContextSetLineDash(context, 0, lengths, 2);
    
    float dashHeightRate = (self.frame.size.height - 40)/6;
    
    if([self.itemArray count] * 4 > self.frame.size.width){
        for(int i = 0; i < 7; i++){
            CGContextMoveToPoint(context, 0, 20+dashHeightRate*i);
            CGContextAddLineToPoint(context, [self.itemArray count]*4, 20+dashHeightRate*i);
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
    
    int startCount = (self.contentSize - self.viewWidth - self.contentOffSet)/4;
    int endCount = startCount + (self.viewWidth / 4);
    
    if([self.itemArray count] * 4 > self.viewWidth){
        for(int i = startCount; i<=endCount; i++){
            HistoryDrawObject *lastObj = [_itemArray objectAtIndex:endCount-1];
            HistoryDrawObject *lastComparedObj = [_comparedItemArray objectAtIndex:endCount-1];
            
            HistoryDrawObject *obj = [_itemArray objectAtIndex:i];
            HistoryDrawObject *comparedObj = [_comparedItemArray objectAtIndex:i];
            
            maxValue = MAX(maxValue, (obj->lastPrice - lastObj->lastPrice) / obj->lastPrice);
            maxValue = MAX(maxValue, (comparedObj->lastPrice - lastComparedObj->lastPrice) / comparedObj->lastPrice);
            
            minValue = MIN(minValue, (obj->lastPrice - lastObj->lastPrice) / obj->lastPrice);
            minValue = MIN(minValue, (comparedObj->lastPrice - lastComparedObj->lastPrice) / comparedObj->lastPrice);
        }
    }else{
        for(int i =0; i<[_itemArray count]; i++){
            HistoryDrawObject *lastObj = [_itemArray lastObject];
            HistoryDrawObject *lastComparedObj = [_comparedItemArray lastObject];
            
            HistoryDrawObject *obj = [_itemArray objectAtIndex:i];
            HistoryDrawObject *comparedObj = [_comparedItemArray objectAtIndex:i];
        
            maxValue = MAX(maxValue, ((obj->lastPrice - lastObj->lastPrice) / obj->lastPrice));
            maxValue = MAX(maxValue, ((comparedObj->lastPrice - lastComparedObj->lastPrice) / comparedObj->lastPrice));
        
            minValue = MIN(minValue, ((obj->lastPrice - lastObj->lastPrice) / obj->lastPrice));
            minValue = MIN(minValue, ((comparedObj->lastPrice - lastComparedObj->lastPrice) / comparedObj->lastPrice));
        }
    }
    
    double drawHeightRate = (self.frame.size.height - 40) / (maxValue - minValue);
    
    [[UIColor brownColor] set];
    int itemWidthNum =0;
    for(int i = 0; i < [_itemArray count]; i++){
        HistoryDrawObject *lastObj;
        HistoryDrawObject *obj = [_itemArray objectAtIndex:i];
        if([self.itemArray count] * 4 > self.viewWidth){
            lastObj = [_itemArray objectAtIndex:endCount-1];
        }else{
            lastObj = [_itemArray lastObject];
        }
        if(i==0){
            CGContextMoveToPoint(context, self.frame.size.width - itemWidthNum*4, self.frame.size.height - 20 - ((obj->lastPrice - lastObj->lastPrice) / lastObj->lastPrice - minValue) * drawHeightRate);
        }else{
            CGContextAddLineToPoint(context, self.frame.size.width - itemWidthNum*4, self.frame.size.height - 20 - ((obj->lastPrice - lastObj->lastPrice) / lastObj->lastPrice -minValue) * drawHeightRate);
        }
        itemWidthNum ++;
    }
    CGContextStrokePath(context);
    
    [[UIColor blueColor] set];
    int comparedItemWidthNum =0;
    for(int i = 0; i < [_comparedItemArray count]; i++){
        HistoryDrawObject *lastComparedObj;
        HistoryDrawObject *comparedObj = [_comparedItemArray objectAtIndex:i];
        if([self.itemArray count] * 4 > self.viewWidth){
            lastComparedObj = [_comparedItemArray objectAtIndex:endCount-1];
        }else{
            lastComparedObj = [_comparedItemArray lastObject];
        }
        
        if(i==0){
            CGContextMoveToPoint(context, self.frame.size.width - comparedItemWidthNum*4, self.frame.size.height - 20 - ((comparedObj->lastPrice - lastComparedObj->lastPrice) / comparedObj->lastPrice - minValue) * drawHeightRate);
        }else{
            CGContextAddLineToPoint(context, self.frame.size.width - comparedItemWidthNum*4, self.frame.size.height - 20 - ((comparedObj->lastPrice - lastComparedObj->lastPrice) / comparedObj->lastPrice - minValue) * drawHeightRate);
        }
        comparedItemWidthNum ++;
    }
    CGContextStrokePath(context);
    
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributesText = @{ NSFontAttributeName: [UIFont systemFontOfSize:12.0f],
                                      NSParagraphStyleAttributeName: paragraphStyle,
                                      NSForegroundColorAttributeName: [UIColor blackColor]};
    
    NSDateFormatter *formatterMonth = [[NSDateFormatter alloc] init];
    [formatterMonth setDateFormat:@"MM"];
    
    int timeWidthNum = 0;
    HistoryDrawObject *firstObject = [_itemArray objectAtIndex:0];
    int detailMonth = [[formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:firstObject->date]uint16ToDate]]intValue];
    CGContextSetLineWidth(context, 0.5);
    CGContextSetLineDash(context, 0, lengths, 2);
    for(int i = 1; i<[_itemArray count]; i++){
        HistoryDrawObject *obj = [_itemArray objectAtIndex:i];
        int month = [[formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:obj->date]uint16ToDate]]intValue];
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
