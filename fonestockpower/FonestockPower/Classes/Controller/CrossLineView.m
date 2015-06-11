//
//  CrossLineView.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/1/12.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "CrossLineView.h"


@implementation CrossLineView

@synthesize crossPoint;
@synthesize lineColor;
@synthesize horizontalHidden;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        //self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        lineColor = [UIColor blackColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {

    if (CGPointEqualToPoint(crossPoint, CGPointZero))
        return;

    CGContextRef context = UIGraphicsGetCurrentContext();
    [lineColor set];
    CGContextSetLineWidth(context, 0.5);

//	NSLog(@"橫線 from:%.1f to:%.1f",rect.origin.y,rect.size.height);
    CGContextMoveToPoint(context, crossPoint.x, rect.origin.y);
    CGContextAddLineToPoint(context, crossPoint.x, rect.origin.y+rect.size.height);
    CGContextStrokePath(context);

    if (!horizontalHidden) 
	{
        CGContextMoveToPoint(context, rect.origin.x, crossPoint.y);
        CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, crossPoint.y);
        CGContextStrokePath(context);
    }
}

@end
