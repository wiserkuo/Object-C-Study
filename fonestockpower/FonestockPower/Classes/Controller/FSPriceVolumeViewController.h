//
//  FSPriceVolumeViewController.h
//  WirtsLeg
//
//  Created by Shen Kevin on 13/7/5.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataArriveProtocol.h"
#import "FSPriceVolumeViewControllerDelegate.h"

@class PortfolioItem;

enum CrossHairInfoPanelPositionUpDown {
    Upside = 0,
    Downside = 1
};

@interface FSPriceVolumeViewController : FSUIViewController <FSPriceVolumeViewControllerDelegate, UIActionSheetDelegate,CPTPlotSpaceDelegate>

@property (nonatomic, strong) PortfolioItem *portfolioItem;
@property (nonatomic, assign) double singleDayDataMaxVolume;
@property (nonatomic, assign) double accumulativeDataMaxVolume;
- (void)reloadGraph;
- (void)updateSingleDateLabelText:(NSString *) dateString;
- (void)updateAccumulativeDateLabelText:(NSString *) dateString;
@end
