//
//  FSPriceVolumeCrossInfoPanel.h
//  WirtsLeg
//
//  Created by KevinShen on 2014/2/11.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPriceVolumeCrossHairInfo;

@interface FSPriceVolumeCrossHairInfoPanel : UIView

@property (nonatomic, assign) BOOL isSingleDayEnabled;
@property (nonatomic, assign) BOOL isAccumulationEnabled;
- (void)updatePanelWithInfo:(FSPriceVolumeCrossHairInfo *) crossHairInfo referencePrice:(NSNumber *) referencePrice;
@end
