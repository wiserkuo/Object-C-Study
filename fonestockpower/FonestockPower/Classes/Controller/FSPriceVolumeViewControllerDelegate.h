//
//  FSPriceVolumeViewControllerDelegate.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/12.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSPriceVolumeViewControllerDelegate <NSObject>
@property (nonatomic, assign) double singleDayDataMaxVolume;
@property (nonatomic, assign) double accumulativeDataMaxVolume;
- (void)reloadGraph;
- (void)updateSingleDateLabelText:(NSString *) dateString;
- (void)updateAccumulativeDateLabelText:(NSString *) dateString;

-(void)configurePlotsPeriodVolumeBarWidth:(float)width;

@optional
- (void)firstInLoadPeriodRequest;
@end
