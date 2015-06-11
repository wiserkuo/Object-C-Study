//
//  FSCrossPlot.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/20.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSCrossHair.h"

@interface FSCrossHair ()
/**
 *  垂直線的最高點
 */
@property (nonatomic, assign) CGPoint verticalLineTopPoint;
/**
 *  垂直線的最低點
 */
@property (nonatomic, assign) CGPoint verticalLineBottomPoint;

/**
 *  水平線的最左點
 */

@property (nonatomic, assign) CGPoint horizonalLineLeftPoint;
/**
 *  水平線的最右點
 */
@property (nonatomic, assign) CGPoint horizonalLineRightPoint;

@property (nonatomic, strong) CPTScatterPlot *verticalLine;
@property (nonatomic, strong) CPTScatterPlot *horizonalLine;
@end

@implementation FSCrossHair

- (id)init
{
    self = [super init];
    if (self) {
        _verticalLineTopPoint = CGPointMake(0, 0);
        _verticalLineBottomPoint = CGPointMake(0, 0);
        _horizonalLineLeftPoint = CGPointMake(0, 0);
        _horizonalLineRightPoint = CGPointMake(0, 0);
        [self configurePlot];
    }
    return self;
}

- (id)initWithVerticalLineMaxY:(CGFloat)aVerticalLineMaxY horizonalLineMaxX:(CGFloat)anHorizonalLineMaxX
{
    self = [super init];
    if (self) {
        //一開始預設垂直線在Y軸上，水平線在X軸上
        _verticalLineTopPoint = CGPointMake(0, aVerticalLineMaxY);
        _verticalLineBottomPoint = CGPointMake(0, 0);
        _horizonalLineLeftPoint = CGPointMake(0, 0);
        _horizonalLineRightPoint = CGPointMake(anHorizonalLineMaxX, 0);
        [self configurePlot];
        _verticalLineMaxY = aVerticalLineMaxY;
        _horizonalLineMaxX = anHorizonalLineMaxX;
    }
    return self;
}

- (void)setVerticalLineMaxY:(CGFloat)verticalLineMaxY
{
    _verticalLineMaxY = verticalLineMaxY;
    _verticalLineTopPoint.y = verticalLineMaxY;
}

- (void)setHorizonalLineMaxX:(CGFloat)horizonalLineMaxX
{
    _horizonalLineMaxX = horizonalLineMaxX;
    _horizonalLineRightPoint.x = horizonalLineMaxX;
}

/**
 *  這裡要做一個十字線讓線圖使用
 */
- (void)configurePlot
{
    //垂直線
    self.verticalLine = [[CPTScatterPlot alloc] init];
    _verticalLine.identifier = @"CrossVerticalPlot";
    _verticalLine.dataSource = self;
    
    //水平線
    self.horizonalLine = [[CPTScatterPlot alloc] init];
    _horizonalLine.identifier = @"CrossHorizonalPlot";
    _horizonalLine.dataSource = self;
    
    CPTMutableLineStyle *lineStyle = [_verticalLine.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 0.7;
    lineStyle.lineColor = [CPTColor blackColor];
    _verticalLine.dataLineStyle = lineStyle;
    _horizonalLine.dataLineStyle = lineStyle;
}


#pragma mark - CPTPlotDataSource

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return 2;
}


- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    NSNumber *num = nil;
    if ([(NSString *)plot.identifier isEqualToString:@"CrossVerticalPlot"]) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            num = [NSNumber numberWithFloat:_verticalLineTopPoint.x];
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
            //Core Plot會從左邊畫到右邊，從上面畫到下面，所以index0是verticalLineTopPoint
            switch (index) {
                case 0:
                    num = [NSNumber numberWithFloat:_verticalLineTopPoint.y];
                    break;
                case 1:
                    num = [NSNumber numberWithFloat:_verticalLineBottomPoint.y];
                    break;
                    
                default:
                    num = [NSNumber numberWithDouble:0.0f];
                    break;
            }
        }
        
    }
    else if([(NSString *)plot.identifier isEqualToString:@"CrossHorizonalPlot"]) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            switch (index) {
                case 0:
                    num = [NSNumber numberWithFloat:_horizonalLineLeftPoint.x];
                    break;
                case 1:
                    num = [NSNumber numberWithFloat:_horizonalLineRightPoint.x];
                    break;
                    
                default:
                    num = [NSNumber numberWithDouble:0.0f];
                    break;
            }
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
            num = [NSNumber numberWithFloat:_horizonalLineLeftPoint.y];
        }
    }
    
    return num;
}

#pragma mark - Action

- (void)moveVerticalLineToX:(CGFloat) x
{
    if (x > _horizonalLineMaxX) {
        _verticalLineBottomPoint.x = _horizonalLineMaxX;
        _verticalLineTopPoint.x = _horizonalLineMaxX;
    }
    else if(x < 0) {
        _verticalLineBottomPoint.x = 0;
        _verticalLineTopPoint.x = 0;
    }
    else {
        _verticalLineBottomPoint.x = x;
        _verticalLineTopPoint.x = x;
    }
    
    [_verticalLine reloadData];
}

- (void)moveHorizonalLineToY:(CGFloat) y
{
    if (y > _verticalLineMaxY) {
        _horizonalLineLeftPoint.y = _verticalLineMaxY;
        _horizonalLineRightPoint.y = _verticalLineMaxY;
    }
    else if (y < 0) {
        _horizonalLineLeftPoint.y = 0;
        _horizonalLineRightPoint.y = 0;
    }
    else {
        _horizonalLineLeftPoint.y = y;
        _horizonalLineRightPoint.y = y;
    }
    [_horizonalLine reloadData];
}

#pragma mark - Appearance

/**
 *  設定垂直線的顏色
 *
 *  @param verticalLineColor 顏色
 */
- (void)setVerticalLineColor:(CPTColor *)verticalLineColor
{
    CPTMutableLineStyle *lineStyle = [_verticalLine.dataLineStyle mutableCopy];
    lineStyle.lineColor = verticalLineColor;
    _verticalLine.dataLineStyle = lineStyle;
}

/**
 *  設定水平線的顏色
 *
 *  @param horizonalLineColor 顏色
 */
- (void)setHorizonalLineColor:(CPTColor *)horizonalLineColor
{
    CPTMutableLineStyle *lineStyle = [_horizonalLine.dataLineStyle mutableCopy];
    lineStyle.lineColor = horizonalLineColor;
    _horizonalLine.dataLineStyle = lineStyle;
}

@end
