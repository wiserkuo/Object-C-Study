//
//  FSUIButton.h
//  FonestockPower
//
//  Created by Connor on 14/3/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MarqueeLabel;

typedef NS_ENUM(NSUInteger, FSUIButtonType) {
    FSUIButtonTypeNormalRed,
    FSUIButtonTypeNormalBlue,
    FSUIButtonTypeNormalGreen,
    FSUIButtonTypeMarquee,
    FSUIButtonTypeDetailYellow,
    FSUIButtonTypeShortDetailYellow,
    FSUIButtonTypeBlackLeftArrow,
    FSUIButtonTypeCheckBox,
    FSUIButtonTypeActionPlanGreen,
    FSUIButtonTypeActionPlanRed,
    FSUIButtonTypeRadio,
    FSUIButtonTypeGrayButton,
    FSUIButtonTypeBlueDetailButton,
    FSUIButtonTypeFlagButton,
    
    FSUIButtonTypeLightGreenButton,
    FSUIButtonTypePurpleButton,
    FSUIButtonTypeBlueGreenButton,
    FSUIButtonTypeBlueGreenDetailButton,
    
    FSUIButtonTypeFocusButton,
    FSUIButtonTypeBlueGreenDetail2Button,
    
    FSUIButtonTypeChangeBullOrBear
};

@interface FSUIButton : UIButton
@property (strong,nonatomic) MarqueeLabel *btnLabel;
@property (strong,nonatomic) UILabel *label;
@property (nonatomic, strong) UIImageView *flagImg;
@property (nonatomic, strong) UILabel *textLabel;
- (instancetype)initWithButtonType:(FSUIButtonType)buttonType;

@end