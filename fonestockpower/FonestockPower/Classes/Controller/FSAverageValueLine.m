//
//  FSAverageLine.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/22.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSAverageValueLine.h"


@interface FSAverageValueLine ()
@property (nonatomic, strong) CPTScatterPlot *averageLinePlot;
@end

@implementation FSAverageValueLine

- (id)init
{
    self = [super init];
    if (self) {
        [self configurePlot];
    }
    return self;
}

- (void)configurePlot
{
    //垂直線
    self.averageLinePlot = [[CPTScatterPlot alloc] init];
    _averageLinePlot.identifier = @"AverageLinePlot";

    
    CPTMutableLineStyle *lineStyle = [_averageLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 1;
    lineStyle.lineColor = [CPTColor purpleColor];
    _averageLinePlot.dataLineStyle = lineStyle;
}

@end
