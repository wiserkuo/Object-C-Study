//
//  WarrantDrawView.m
//  FonestockPower
//
//  Created by Kenny on 2014/9/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantDrawView.h"

@implementation WarrantDrawView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.backgroundColor = [UIColor clearColor];
//        self.priceArray = [[NSMutableArray alloc] init];
//    }
//    return self;
//}

- (id)initWithController:(WarrantChartViewController*)controller
{
    self = [super init];
    if (self) {
        self.controller = controller;
        self.backgroundColor = [UIColor clearColor];
        self.priceArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    
    float viewHeight = self.frame.size.height;
    
    //價與量的分界線
    float dividingLine = viewHeight / 3 * 2;
    //垂直虛線
    float verticalDashLine = self.frame.size.width / 9;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //分界線
    [[UIColor blackColor] set];
    
    CGContextSetLineWidth(context, 1);
    
    CGContextMoveToPoint(context, 0, dividingLine);
    CGContextAddLineToPoint(context, self.frame.size.width, dividingLine);
    
    CGContextStrokePath(context);
    
    
    //價的水平虛線
    [[UIColor lightGrayColor] set];
    
    CGContextSetLineWidth(context, 0.5);
    CGFloat lengths[] = {1,1};
    CGContextSetLineDash(context, 0, lengths, 2);
    
    CGContextMoveToPoint(context, 0, dividingLine/2);
    CGContextAddLineToPoint(context, self.frame.size.width, dividingLine/2);
    
    //垂直虛線
    for(int i = 1 ; i < 9 ; i ++){
        CGContextMoveToPoint(context, verticalDashLine * i, 0);
        CGContextAddLineToPoint(context, verticalDashLine * i, self.frame.size.height);
    }
    
    
   
    //量的水平虛線
    float volumeVerticalDashLine = viewHeight / 3 / 4;
    for(int i = 1 ; i< 5 ; i ++){
        CGContextMoveToPoint(context, 0, dividingLine + volumeVerticalDashLine * i );
        CGContextAddLineToPoint(context, self.frame.size.width, dividingLine + volumeVerticalDashLine * i);
    }
    
    CGContextStrokePath(context);
    
    CGContextSetLineDash(context, 0, NULL, 0);
    
    //CGMutablePathRef pathK = CGPathCreateMutable();
    //CGMutablePathRef pathD = CGPathCreateMutable();
    [[UIColor blueColor] set];
    
    
    
    if(self.timeArray == nil){
        return;
    }
    CGContextSetLineWidth(context, 0.5);
    
    float heightRate;
    if(self.ceilingPrice == self.floorPrice){
        heightRate = 0;
    }else{
        heightRate = dividingLine / (self.ceilingPrice - self.floorPrice);
    }
    float widthRate = self.frame.size.width / 271;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:10.0f],
                                  NSParagraphStyleAttributeName: paragraphStyle };
    //時間
    for(int i =0 ; i < 270; i++){
        if(self.startTime % 60 == 0){
            NSString *timeText = [NSString stringWithFormat:@"%d", _startTime / 60];
            [timeText drawInRect:CGRectMake(widthRate * i+3,dividingLine-12, 13, 10) withAttributes:attributes];
        }
        self.startTime+=1;
    }
    
    
    
    int widthNum = 0;
    int timeNum = 0;
    for(int i = 0 ; i < [self.timeArray count]; i++){
        if(i == 0){
            CGContextMoveToPoint(context, widthRate * [(NSNumber *)[self.timeArray objectAtIndex:i]intValue], dividingLine - ([(NSNumber *)[self.priceArray objectAtIndex:i]doubleValue] - self.floorPrice) * heightRate);
        }else{
            CGContextAddLineToPoint(context, widthRate * [(NSNumber *)[self.timeArray objectAtIndex:i]intValue], dividingLine - ([(NSNumber *)[self.priceArray objectAtIndex:i]doubleValue] - self.floorPrice) * heightRate);
        }
    }
    CGContextStrokePath(context);
    //量
    CGContextSetLineWidth(context, 0.1);
    int highVolume = -MAXFLOAT;
    widthNum = 0;
    timeNum = 0;
    for(int i = 0; i<[self.volumeArray count]; i++){
        highVolume = MAX(highVolume, [(NSNumber *)[self.volumeArray objectAtIndex:i]intValue]);
    }
    float volumeHeightRate = viewHeight / 3 / highVolume;
    
    for(int i = 0 ; i < [self.volumeArray count]; i++){
        CGRect longRect = CGRectMake(widthRate * i, viewHeight - [(NSNumber *)[self.volumeArray objectAtIndex:i]doubleValue] * volumeHeightRate, 1, [(NSNumber *)[self.volumeArray objectAtIndex:i]doubleValue] * volumeHeightRate);
        CGContextAddRect(context, longRect);
        CGContextFillPath(context);
    }
    CGContextStrokePath(context);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    double _timeWidth = self.frame.size.width / 271;
    int countNum = touchPoint.x/_timeWidth;
    int num = touchPoint.x/_timeWidth;
    CGPoint a = CGPointMake(countNum*_timeWidth, touchPoint.y);
    if(a.x==0){
        a = CGPointMake(1, touchPoint.y);
    }
    a.x = a.x + 50;
    [_controller doTouchesWithPoint:a number:num];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    double _timeWidth = self.frame.size.width / 271;
    int countNum = touchPoint.x/_timeWidth;
    int num = touchPoint.x/_timeWidth;
    CGPoint a = CGPointMake(countNum*_timeWidth, touchPoint.y);
    if(a.x==0){
        a = CGPointMake(1, touchPoint.y);
    }
    a.x = a.x + 50;
    [_controller doTouchesWithPoint:a number:num];
}


@end
