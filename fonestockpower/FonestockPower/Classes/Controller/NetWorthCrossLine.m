//
//  NetWorthCrossLine.m
//  FonestockPower
//
//  Created by Neil on 14/6/11.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "NetWorthCrossLine.h"

@implementation NetWorthCrossLine

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextSetLineWidth(context, 0.5);
    CGContextMoveToPoint(context, _crossPoint.x, 0);
    CGContextAddLineToPoint(context, _crossPoint.x, self.frame.size.height);
    CGContextStrokePath(context);
}


@end
