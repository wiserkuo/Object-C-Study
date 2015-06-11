//
//  TQuotedView.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/10.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TQuotedView.h"

@implementation TQuotedView

- (id)initWithFrame:(CGRect)frame Type:(int)type
{
    self = [super initWithFrame:frame];
    if (self) {
        drawType = type;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor orangeColor] set];
    
    if(drawType == 1){
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, 0, 1);
        CGContextAddLineToPoint(context, self.frame.size.width - 10, 1);
        CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height/2);
        CGContextAddLineToPoint(context, self.frame.size.width - 10, self.frame.size.height-1);
        CGContextAddLineToPoint(context, 0, self.frame.size.height-1);
        CGContextAddLineToPoint(context, 10, self.frame.size.height/2);
        CGContextAddLineToPoint(context, 0, 1);
    }else{
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, 10, 1);
        CGContextAddLineToPoint(context, self.frame.size.width, 1);
        CGContextAddLineToPoint(context, self.frame.size.width-10, self.frame.size.height/2);
        CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height-1);
        CGContextAddLineToPoint(context, 10, self.frame.size.height-1);
        CGContextAddLineToPoint(context, 0, self.frame.size.height/2);
        CGContextAddLineToPoint(context, 10, 1);
    }
    CGContextStrokePath(context);
}


@end
