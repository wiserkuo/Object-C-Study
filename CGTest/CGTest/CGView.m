//
//  CGView.m
//  CGTest
//
//  Created by Wiser on 2015/5/20.
//  Copyright (c) 2015年 Wiser. All rights reserved.
//

#import "CGView.h"

@implementation CGView

- (void)drawRect:(CGRect)rect {
    //建立畫布
    CGContextRef context = UIGraphicsGetCurrentContext();

    //設定畫筆顏色
    [[UIColor blackColor]set];
    
    //設定畫筆寬度
    CGContextSetLineWidth(context, 0.5);
    
    CGFloat length[] = {2,3};
    //設定畫虛線
    CGContextSetLineDash(context, 0, length, 1);
    
    //設定顏色
    [[UIColor purpleColor] set];
    
    //畫直線
    CGContextMoveToPoint(context, 0 , 50);
    CGContextAddLineToPoint(context, self.frame.size.width, 50);
    
    //畫出來
    CGContextStrokePath(context);
    
    //取消畫虛線
    CGContextSetLineDash(context, 0, length, 0);
    
    //設定顏色
    [[UIColor greenColor] set];
    
    //設定畫筆寬度
    CGContextSetLineWidth(context, 3.0);
    
    
    //畫直線
    CGContextMoveToPoint(context, 0 , 100);
    CGContextAddLineToPoint(context, self.frame.size.width, 100);
    
    //畫出來
    CGContextStrokePath(context);
    
    //設定填滿顏色
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
    
    
    //畫圓
    CGContextAddArc(context, 200, 200, 30, 0, 2*M_PI, 0);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextDrawPath(context,kCGPathFillStroke);
    
    
    //畫出來
    CGContextStrokePath(context);
    

    
}
@end
