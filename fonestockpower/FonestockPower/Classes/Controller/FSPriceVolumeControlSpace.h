//
//  FSPriceVolumeControlSpace.h
//  WirtsLeg
//
//  Created by KevinShen on 2014/2/10.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSUIButton.h"

@interface FSPriceVolumeControlSpace : UIView
@property (nonatomic, strong) FSUIButton *singleCheckButton;
@property (nonatomic, strong) FSUIButton *accumulativeCheckButton;
@property (nonatomic, strong) UILabel *singleTitleLabel;
@property (nonatomic, strong) UILabel *accumulativeTitleLabel;
@property (nonatomic, strong) FSUIButton *singlePeriodSelectButton;
@property (nonatomic, strong) FSUIButton *accumulativePeriodSelectButton;
@property (nonatomic, strong) UILabel *singleDateLabel;
@property (nonatomic, strong) UILabel *accumulativeDateLabel;
@end
