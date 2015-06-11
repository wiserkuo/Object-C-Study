//
//  ScrollBarTableViewCell.h
//  FonestockPower
//
//  Created by Kenny on 2014/10/27.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"
@interface SliderTableViewCell : FSUITableViewCell{
    NSMutableArray * constraints;
}
@property (nonatomic, strong) FSUIButton *checkBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *minLabel;
@property (nonatomic, strong) UILabel *midLabel;
@property (nonatomic, strong) UILabel *maxLabel;
@property (nonatomic, strong) NMRangeSlider *slider;
@property (nonatomic) double valueInt;
@property (nonatomic) double lastValue;
@property (nonatomic) double maxValue;
@property (nonatomic) double minValue;
@end


