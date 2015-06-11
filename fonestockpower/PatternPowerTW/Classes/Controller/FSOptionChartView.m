//
//  FSOptionChartView.m
//  FonestockPower
//
//  Created by Derek on 2014/10/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSOptionChartView.h"

@implementation FSOptionChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setChartViewType:(int)chartViewType{
    _chartViewType = chartViewType;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat width = self.frame.size.width;
    CGFloat hight = self.frame.size.height;
    
    // Drawing code
    //畫上邊線
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.frame.size.width, 0);
    CGContextStrokePath(context);
    
    //A.B.C.D點
    UIFont *font = [UIFont systemFontOfSize:18.0f];
    UIColor *colorRed = [UIColor redColor];
    UIColor *colorBlue = [UIColor blueColor];
    UIColor *colorCust = [UIColor colorWithRed:0 green:81.0f/255.0f blue:104.0f/255.0f alpha:1];
    NSDictionary *attributes = @{ NSFontAttributeName: font, NSForegroundColorAttributeName:colorRed};
    NSDictionary *attributes1 = @{ NSFontAttributeName: font, NSForegroundColorAttributeName:colorBlue};
    NSDictionary *attributes2 = @{ NSFontAttributeName: font, NSForegroundColorAttributeName:colorCust};

    [@"A點:" drawInRect:CGRectMake(10, 10, 40, 20) withAttributes:attributes];
    [@"B點:" drawInRect:CGRectMake(10, 30, 40, 20) withAttributes:attributes];
    
    [_pointA drawInRect:CGRectMake(50, 10, 80, 20) withAttributes:attributes1];
    [_pointB drawInRect:CGRectMake(50, 30, 80, 20) withAttributes:attributes1];
    if (_chartViewType > 3) {
        CGContextSetRGBFillColor (context, 1, 0, 0, 1.0);
        [@"C點:" drawInRect:CGRectMake(10, 50, 40, 20) withAttributes:attributes];
        
        CGContextSetRGBFillColor (context, 0, 0, 1, 1.0);
        [_pointC drawInRect:CGRectMake(50, 50, 80, 20) withAttributes:attributes1];
    }
    if (_chartViewType > 3 && _chartViewType < 6){
        CGContextSetRGBFillColor (context, 1, 0, 0, 1.0);
        [@"D點:" drawInRect:CGRectMake(10, 70, 40, 20) withAttributes:attributes];
        
        CGContextSetRGBFillColor (context, 0, 0, 1, 1.0);
        [_pointD drawInRect:CGRectMake(50, 70, 80, 20) withAttributes:attributes1];
    }
    
    //畫X.Y軸
    CGContextSetLineWidth(context, 0.5);
    CGContextMoveToPoint(context, width/3+20, hight/2);
    CGContextAddLineToPoint(context, width-10, hight/2);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, width/3+20, 10);
    CGContextAddLineToPoint(context, width/3+20, hight-10);
    CGContextStrokePath(context);
    
    [@"賺" drawInRect:CGRectMake(width/3, 0, 20, 20) withAttributes:attributes2];
    [@"賠" drawInRect:CGRectMake(width/3, hight-25, 20, 20) withAttributes:attributes2];
    [@"低" drawInRect:CGRectMake(width/3+20, hight/2, 20, 20) withAttributes:attributes2];
    [@"高" drawInRect:CGRectMake(width-20, hight/2, 20, 20) withAttributes:attributes2];
    
    [[UIColor colorWithRed:0 green:0 blue:1 alpha:1] set];
    if (_chartViewType == 0) { //看大漲
        [self makeLine:CGRectMake(width/3+30, hight-35, 0, 0) EndPoint:CGRectMake(width/3+125, hight-35, 0, 0)];
        [self makeLine:CGRectMake(width/3+125, hight-35, 0, 0) EndPoint:CGRectMake(width-10, hight-135, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+125, 10, 0, 0) EndPoint:CGRectMake(width/3+125, hight-10, 0, 0)];
        
        [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] set];
        [@"A" drawInRect:CGRectMake(width/3+110, hight/2-20, 20, 20) withAttributes:attributes];
        [@"B" drawInRect:CGRectMake(width/3+150, hight/2-20, 20, 20) withAttributes:attributes];
        
    }else if (_chartViewType == 1){ //看大跌
        [self makeLine:CGRectMake(width/3+30, hight-135, 0, 0) EndPoint:CGRectMake(width/3+105, hight-35, 0, 0)];
        [self makeLine:CGRectMake(width/3+105, hight-35, 0, 0) EndPoint:CGRectMake(width-10, hight-35, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+105, 10, 0, 0) EndPoint:CGRectMake(width/3+105, hight-10, 0, 0)];
        [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] set];
        [@"A" drawInRect:CGRectMake(width/3+65, hight/2-20, 20, 20) withAttributes:attributes];
        [@"B" drawInRect:CGRectMake(width/3+110, hight/2-20, 20, 20) withAttributes:attributes];
        
    }else if (_chartViewType == 2){ //看不漲
        [self makeLine:CGRectMake(width/3+30, 25, 0, 0) EndPoint:CGRectMake(width/3+125, 25, 0, 0)];
        [self makeLine:CGRectMake(width/3+125, 25, 0, 0) EndPoint:CGRectMake(width-10, hight-45, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+125, 10, 0, 0) EndPoint:CGRectMake(width/3+125, hight-10, 0, 0)];
        [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] set];
        [@"A" drawInRect:CGRectMake(width/3+110, hight/2, 20, 20) withAttributes:attributes];
        [@"B" drawInRect:CGRectMake(width/3+150, hight/2, 20, 20) withAttributes:attributes];
        
    }else if (_chartViewType == 3){ //看不跌
        [self makeLine:CGRectMake(width/3+30, hight-45, 0, 0) EndPoint:CGRectMake(width/3+105, 25, 0, 0)];
        [self makeLine:CGRectMake(width/3+105, 25, 0, 0) EndPoint:CGRectMake(width-10, 25, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+105, 10, 0, 0) EndPoint:CGRectMake(width/3+105, hight-10, 0, 0)];
        [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] set];
        [@"A" drawInRect:CGRectMake(width/3+65, hight/2, 20, 20) withAttributes:attributes];
        [@"B" drawInRect:CGRectMake(width/3+105, hight/2, 20, 20) withAttributes:attributes];
        
    }else if (_chartViewType == 4){ //看變盤
        [self makeLine:CGRectMake(width/3+30, hight-135, 0, 0) EndPoint:CGRectMake(width/3+95, hight-35, 0, 0)];
        [self makeLine:CGRectMake(width/3+95, hight-35, 0, 0) EndPoint:CGRectMake(width/3+135, hight-35, 0, 0)];
        [self makeLine:CGRectMake(width/3+135, hight-35, 0, 0) EndPoint:CGRectMake(width-10, hight-135, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+95, 10, 0, 0) EndPoint:CGRectMake(width/3+95, hight-10, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+135, 10, 0, 0) EndPoint:CGRectMake(width/3+135, hight-10, 0, 0)];
        [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] set];
        [@"A" drawInRect:CGRectMake(width/3+60, hight/2-20, 20, 20) withAttributes:attributes];
        [@"B" drawInRect:CGRectMake(width/3+95, hight/2-20, 20, 20) withAttributes:attributes];
        [@"C" drawInRect:CGRectMake(width/3+120, hight/2-20, 20, 20) withAttributes:attributes];
        [@"D" drawInRect:CGRectMake(width/3+155, hight/2-20, 20, 20) withAttributes:attributes];
        
    }else if (_chartViewType == 5){ //看盤整
        [self makeLine:CGRectMake(width/3+30, hight-45, 0, 0) EndPoint:CGRectMake(width/3+95, 25, 0, 0)];
        [self makeLine:CGRectMake(width/3+95, 25, 0, 0) EndPoint:CGRectMake(width/3+135, 25, 0, 0)];
        [self makeLine:CGRectMake(width/3+135, 25, 0, 0) EndPoint:CGRectMake(width-10, hight-45, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+95, 10, 0, 0) EndPoint:CGRectMake(width/3+95, hight-10, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+135, 10, 0, 0) EndPoint:CGRectMake(width/3+135, hight-10, 0, 0)];
        [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] set];
        [@"A" drawInRect:CGRectMake(width/3+60, hight/2, 20, 20) withAttributes:attributes];
        [@"B" drawInRect:CGRectMake(width/3+95, hight/2, 20, 20) withAttributes:attributes];
        [@"C" drawInRect:CGRectMake(width/3+120, hight/2, 20, 20) withAttributes:attributes];
        [@"D" drawInRect:CGRectMake(width/3+155, hight/2, 20, 20) withAttributes:attributes];
        
    }else if (_chartViewType == 6){ //看小漲
        [self makeLine:CGRectMake(width/3+30, hight-35, 0, 0) EndPoint:CGRectMake(width/3+95, hight-35, 0, 0)];
        [self makeLine:CGRectMake(width/3+95, hight-35, 0, 0) EndPoint:CGRectMake(width/3+135, 35, 0, 0)];
        [self makeLine:CGRectMake(width/3+135, 35, 0, 0) EndPoint:CGRectMake(width-10, 35, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+95, 10, 0, 0) EndPoint:CGRectMake(width/3+95, hight-10, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+135, 10, 0, 0) EndPoint:CGRectMake(width/3+135, hight-10, 0, 0)];
        [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] set];
        [@"A" drawInRect:CGRectMake(width/3+80, hight/2-20, 20, 20) withAttributes:attributes];
        [@"B" drawInRect:CGRectMake(width/3+115, hight/2, 20, 20) withAttributes:attributes];
        [@"C" drawInRect:CGRectMake(width/3+140, hight/2, 20, 20) withAttributes:attributes];
        
    }else if (_chartViewType == 7){ //小漲作莊
        [self makeLine:CGRectMake(width/3+30, hight-35, 0, 0) EndPoint:CGRectMake(width/3+95, hight-35, 0, 0)];
        [self makeLine:CGRectMake(width/3+95, hight-35, 0, 0) EndPoint:CGRectMake(width/3+135, 35, 0, 0)];
        [self makeLine:CGRectMake(width/3+135, 35, 0, 0) EndPoint:CGRectMake(width-10, 35, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+95, 10, 0, 0) EndPoint:CGRectMake(width/3+95, hight-10, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+135, 10, 0, 0) EndPoint:CGRectMake(width/3+135, hight-10, 0, 0)];
        [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] set];
        [@"A" drawInRect:CGRectMake(width/3+80, hight/2-20, 20, 20) withAttributes:attributes];
        [@"B" drawInRect:CGRectMake(width/3+115, hight/2, 20, 20) withAttributes:attributes];
        [@"C" drawInRect:CGRectMake(width/3+140, hight/2, 20, 20) withAttributes:attributes];
        
    }else if (_chartViewType == 8){ //看小跌
        [self makeLine:CGRectMake(width/3+30, 35, 0, 0) EndPoint:CGRectMake(width/3+95, 35, 0, 0)];
        [self makeLine:CGRectMake(width/3+95, 35, 0, 0) EndPoint:CGRectMake(width/3+135, hight-35, 0, 0)];
        [self makeLine:CGRectMake(width/3+135, hight-35, 0, 0) EndPoint:CGRectMake(width-10, hight-35, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+95, 10, 0, 0) EndPoint:CGRectMake(width/3+95, hight-10, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+135, 10, 0, 0) EndPoint:CGRectMake(width/3+135, hight-10, 0, 0)];
        [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] set];
        [@"A" drawInRect:CGRectMake(width/3+80, hight/2, 20, 20) withAttributes:attributes];
        [@"B" drawInRect:CGRectMake(width/3+115, hight/2-20, 20, 20) withAttributes:attributes];
        [@"C" drawInRect:CGRectMake(width/3+140, hight/2-20, 20, 20) withAttributes:attributes];
        
    }else if (_chartViewType == 9){ //小跌作莊
        [self makeLine:CGRectMake(width/3+30, 35, 0, 0) EndPoint:CGRectMake(width/3+95, 35, 0, 0)];
        [self makeLine:CGRectMake(width/3+95, 35, 0, 0) EndPoint:CGRectMake(width/3+135, hight-35, 0, 0)];
        [self makeLine:CGRectMake(width/3+135, hight-35, 0, 0) EndPoint:CGRectMake(width-10, hight-35, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+95, 10, 0, 0) EndPoint:CGRectMake(width/3+95, hight-10, 0, 0)];
        [self makeDashLineStartPoint:CGRectMake(width/3+135, 10, 0, 0) EndPoint:CGRectMake(width/3+135, hight-10, 0, 0)];
        [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] set];
        [@"A" drawInRect:CGRectMake(width/3+80, hight/2, 20, 20) withAttributes:attributes];
        [@"B" drawInRect:CGRectMake(width/3+115, hight/2-20, 20, 20) withAttributes:attributes];
        [@"C" drawInRect:CGRectMake(width/3+140, hight/2-20, 20, 20) withAttributes:attributes];
    }
}

- (void) makeLine:(CGRect)p1 EndPoint:(CGRect)p2{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context,p1.origin.x,p1.origin.y);
    CGContextAddLineToPoint(context,p2.origin.x,p2.origin.y);
    CGContextSetLineWidth(context, 0.5);
    CGContextStrokePath(context);
}

- (void) makeDashLineStartPoint:(CGRect)p1 EndPoint:(CGRect)p2;
{
    CGFloat dash[] = { 1.5 };  //畫虛線
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor lightGrayColor] set];
    //一條線
    CGContextMoveToPoint(context, p1.origin.x, p1.origin.y);
    CGContextAddLineToPoint(context, p2.origin.x, p2.origin.y);
    CGContextSetLineDash(context, 2, dash, 1);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
}

@end
