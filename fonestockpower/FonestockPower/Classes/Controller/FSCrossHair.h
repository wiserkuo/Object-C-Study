//
//  FSCrossPlot.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/20.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSCrossHair : NSObject <CPTPlotDataSource>

@property (nonatomic, assign) CGFloat verticalLineMaxY;
@property (nonatomic, assign) CGFloat horizonalLineMaxX;

@property (nonatomic, readonly) CPTScatterPlot *verticalLine;
@property (nonatomic, readonly) CPTScatterPlot *horizonalLine;

@property (nonatomic, strong) CPTColor *verticalLineColor;
@property (nonatomic, strong) CPTColor *horizonalLineColor;

- (id)initWithVerticalLineMaxY:(CGFloat)aVerticalLineMaxY horizonalLineMaxX:(CGFloat)anHorizonalLineMaxX;

/**
 *  移動垂直線到指定的x，介於0與horizonalLineMaxX之間
 *
 *  @param x
 */
- (void)moveVerticalLineToX:(CGFloat) x;
/**
 *  移動水平線到指定的y，介於0與verticalLineMaxY之間
 *
 *  @param y
 */
- (void)moveHorizonalLineToY:(CGFloat) y;

@end
