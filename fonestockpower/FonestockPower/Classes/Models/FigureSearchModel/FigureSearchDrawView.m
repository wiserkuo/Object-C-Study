//
//  FigureSearchDrawView.m
//  FonestockPower
//
//  Created by CooperLin on 2015/1/13.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FigureSearchDrawView.h"
#import "UIBezierPath+dqd_arrowhead.h"

@implementation FigureSearchDrawView

-(id)init
{
    self = [super init];
    if(self){
        _type = -1;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
//    //一般畫法
//    double initPointX = self.frame.size.width / 2;
//    double initPointY = self.frame.size.height / 2;
//    double widthRate = self.frame.size.width / 2;
//    [[UIColor redColor] set];
//    CGContextSetLineWidth(context, self.frame.size.height);
//    CGContextMoveToPoint(context, initPointX + 0.5, initPointY);
//    CGContextAddLineToPoint(context, initPointX + 0.5 + self.concentrationBuy * widthRate, initPointY);
//    CGContextStrokePath(context);
    
    if(_type == -1)return ;
    if(_type == FSDrawTypePlainLine){
        CGContextRef context = UIGraphicsGetCurrentContext();

        [[UIColor blackColor] set];
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, [[_upLineArray objectAtIndex:0] CGPointValue].x, [[_upLineArray objectAtIndex:0] CGPointValue].y);
        CGContextAddLineToPoint(context, [[_upLineArray objectAtIndex:1] CGPointValue].x, [[_upLineArray objectAtIndex:1] CGPointValue].y);
        CGContextStrokePath(context);
        
        CGContextMoveToPoint(context, [[_mainBodyArray objectAtIndex:0] CGPointValue].x, [[_mainBodyArray objectAtIndex:0] CGPointValue].y);
        CGContextAddLineToPoint(context, [[_mainBodyArray objectAtIndex:1] CGPointValue].x, [[_mainBodyArray objectAtIndex:1] CGPointValue].y);
        CGContextStrokePath(context);
        
        CGContextMoveToPoint(context, [[_upDownArray objectAtIndex:0] CGPointValue].x, [[_upDownArray objectAtIndex:0] CGPointValue].y);
        CGContextAddLineToPoint(context, [[_upDownArray objectAtIndex:1]CGPointValue].x, [[_upDownArray objectAtIndex:1] CGPointValue].y);
        CGContextStrokePath(context);
        
        CGContextMoveToPoint(context, [[_downLineArray objectAtIndex:0] CGPointValue].x, [[_downLineArray objectAtIndex:0] CGPointValue].y);
        CGContextAddLineToPoint(context, [[_downLineArray objectAtIndex:1] CGPointValue].x, [[_downLineArray objectAtIndex:1] CGPointValue].y);
        CGContextStrokePath(context);
    }else if(_type == FSDrawTypeArrowHead){
        if(_isRedColor){
            [[StockConstant PriceUpColor] set];
        }else{
            [[StockConstant PriceDownColor] set];
        }
        //strok是指畫邊框 setStroke是給邊框的顏色，而fill則是填滿內容 set是填滿的顏色
        _path = [UIBezierPath dqd_bezierPathWithArrowFromPoint:[[_mainBodyArray objectAtIndex:0] CGPointValue] toPoint:[[_mainBodyArray objectAtIndex:1] CGPointValue] tailWidth:1 headWidth:5 headLength:5];
        [_path setLineWidth:0.5];
        [_path fill];
        
        [[UIColor blueColor] set];
        _path = [UIBezierPath dqd_bezierPathWithArrowFromPoint:[[_upLineArray objectAtIndex:0] CGPointValue] toPoint:[[_upLineArray objectAtIndex:1] CGPointValue] tailWidth:1 headWidth:5 headLength:5];
        [_path setLineWidth:0.5];
        [_path fill];
        
        _path = [UIBezierPath dqd_bezierPathWithArrowFromPoint:[[_upDownArray objectAtIndex:0] CGPointValue] toPoint:[[_upDownArray objectAtIndex:1] CGPointValue] tailWidth:1 headWidth:5 headLength:5];
        [_path setLineWidth:0.5];
        [_path fill];
        
        _path = [UIBezierPath dqd_bezierPathWithArrowFromPoint:[[_downLineArray objectAtIndex:0] CGPointValue] toPoint:[[_downLineArray objectAtIndex:1] CGPointValue] tailWidth:1 headWidth:5 headLength:5];
        [_path setLineWidth:0.5];
        [_path fill];
    }
}


@end
