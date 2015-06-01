//
//  FSUIButton.m
//  FonestockPower
//
//  Created by Connor on 14/3/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "MarqueeLabel.h"

@implementation FSUIButton

- (instancetype)initWithButtonType:(FSUIButtonType)buttonType
{
    if (self = [super init]) {
        UIImage *redButton;
        UIImage *yellowButton;
        UIImage *blackArrowLeftButton;
        UIImage *checkboxTrueButton;
        UIImage *checkboxFalseButton;
        UIImage *stretchableGreenButton;
        UIImage *stretchableYellowButton;
        UIImage *yellowDetailButton;
        UIImage *stretchableYellowDetailButton;
        UIImage *stretchableBlueButton;
        UIImage *stretchableLightBlueButton;
        UIImage *actionPlanGreenButton;
        UIImage *actionPlanRedButton;
        UIImage *radioButtonYes;
        UIImage *radioButtonNo;
        UIImage *grayButton;
        UIImage *blueDetail;
        UIImage * focusButton;
        switch (buttonType) {
            case FSUIButtonTypeFocusButton:
                focusButton = [[UIImage imageNamed:@"發亮橘色按鍵-88"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                [self setBackgroundImage:focusButton forState:UIControlStateNormal];
                [self setBackgroundImage:focusButton forState:UIControlStateSelected];
                [self setBackgroundImage:focusButton forState:UIControlStateDisabled];
                break;
                
            case FSUIButtonTypeNormalRed:
                redButton = [[UIImage imageNamed:@"redButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                yellowButton = [[UIImage imageNamed:@"發亮橘色按鍵-88"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                [self setBackgroundImage:redButton forState:UIControlStateNormal];
                [self setBackgroundImage:yellowButton forState:UIControlStateHighlighted];
                [self setBackgroundImage:yellowButton forState:UIControlStateSelected];
                break;
            case FSUIButtonTypeNormalBlue:
                stretchableBlueButton = [[UIImage imageNamed:@"blueButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                stretchableLightBlueButton = [[UIImage imageNamed:@"發亮藍色按鍵-88"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                [self setBackgroundImage:stretchableBlueButton forState:UIControlStateNormal];
                [self setBackgroundImage:stretchableLightBlueButton forState:UIControlStateHighlighted];
                [self setBackgroundImage:stretchableLightBlueButton forState:UIControlStateSelected];
                break;
            case FSUIButtonTypeBlackLeftArrow:
                blackArrowLeftButton = [UIImage imageNamed:@"BackButton"];
                [self setBackgroundImage:blackArrowLeftButton forState:UIControlStateNormal];
                break;
            case FSUIButtonTypeCheckBox:
                checkboxTrueButton = [UIImage imageNamed:@"check_bg_false"];
                checkboxFalseButton = [UIImage imageNamed:@"check_bg_true"];
                [self setBackgroundImage:checkboxTrueButton forState:UIControlStateNormal];
                [self setBackgroundImage:checkboxFalseButton forState:UIControlStateSelected];
                break;
            case FSUIButtonTypeNormalGreen:
                stretchableGreenButton = [[UIImage imageNamed:@"green_Button"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                stretchableYellowButton = [[UIImage imageNamed:@"yellowButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                [self setBackgroundImage:stretchableGreenButton forState:UIControlStateNormal];
                [self setBackgroundImage:stretchableYellowButton forState:UIControlStateHighlighted];
                [self setBackgroundImage:stretchableYellowButton forState:UIControlStateSelected];
                break;
            case FSUIButtonTypeMarquee:
                stretchableGreenButton = [[UIImage imageNamed:@"green_Button"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                stretchableYellowButton = [[UIImage imageNamed:@"yellowButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                [self setBackgroundImage:stretchableGreenButton forState:UIControlStateNormal];
                [self setBackgroundImage:stretchableYellowButton forState:UIControlStateHighlighted];
                [self setBackgroundImage:stretchableYellowButton forState:UIControlStateSelected];
                [self addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
                self.btnLabel = [[MarqueeLabel alloc]initWithFrame:CGRectMake(0, 0, 300, 30) duration:6.0 andFadeLength:0.0f];
                self.btnLabel.font = [UIFont boldSystemFontOfSize:17.0];
                self.btnLabel.marqueeType = 4;
                self.btnLabel.continuousMarqueeExtraBuffer = 30.0f;
                [self.btnLabel setLabelize:YES];
                self.btnLabel.userInteractionEnabled = NO;
                [self addSubview:_btnLabel];
                break;
            case FSUIButtonTypeDetailYellow:
                yellowDetailButton = [UIImage imageNamed:@"yellowDetailButton"];
                stretchableYellowDetailButton = [yellowDetailButton resizableImageWithCapInsets:UIEdgeInsetsMake(10, 23, 18, 23)];
                [self setBackgroundImage:stretchableYellowDetailButton forState:UIControlStateNormal];
                [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                break;
            case FSUIButtonTypeShortDetailYellow:{
                yellowDetailButton = [UIImage imageNamed:@"yellowDetailButton"];
                stretchableYellowDetailButton = [yellowDetailButton resizableImageWithCapInsets:UIEdgeInsetsMake(10, 23, 18, 23)];
                [self setBackgroundImage:stretchableYellowDetailButton forState:UIControlStateNormal];
//                [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                _label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 80, 30)];
                _label.backgroundColor = [UIColor clearColor];
                _label.font = [UIFont boldSystemFontOfSize:14.0];
                _label.textColor =[UIColor redColor];
                [self addSubview:_label];
                break;
            }
            case FSUIButtonTypeActionPlanGreen:
                actionPlanGreenButton = [[UIImage imageNamed:@"綠按鍵"] resizableImageWithCapInsets:UIEdgeInsetsMake(52, 83, 52, 83)];
                [self setBackgroundImage:actionPlanGreenButton forState:UIControlStateNormal];
                break;
            case FSUIButtonTypeActionPlanRed:
                actionPlanRedButton = [[UIImage imageNamed:@"紅按鍵"] resizableImageWithCapInsets:UIEdgeInsetsMake(52, 83, 52, 83)];
                [self setBackgroundImage:actionPlanRedButton forState:UIControlStateNormal];
                break;
            case FSUIButtonTypeRadio:
                radioButtonYes = [UIImage imageNamed:@"RadioButtonYES"];
                radioButtonNo = [UIImage imageNamed:@"RadioButtonNO"];
                [self setBackgroundImage:radioButtonNo forState:UIControlStateNormal];
                [self setBackgroundImage:radioButtonYes forState:UIControlStateSelected];
                break;
            case FSUIButtonTypeGrayButton:
                grayButton = [UIImage imageNamed:@"grayButton"];
                [self setBackgroundImage:grayButton forState:UIControlStateNormal];
                [self setBackgroundImage:grayButton forState:UIControlStateSelected];
                break;
            case FSUIButtonTypeBlueDetailButton:
                blueDetail = [UIImage imageNamed:@"blueDetailButton"];
                [self setBackgroundImage:blueDetail forState:UIControlStateNormal];
                [self setBackgroundImage:blueDetail forState:UIControlStateSelected];
                break;
            case FSUIButtonTypeFlagButton:{
                redButton = [[UIImage imageNamed:@"redButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                yellowButton = [[UIImage imageNamed:@"發亮橘色按鍵-88"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                [self setBackgroundImage:redButton forState:UIControlStateNormal];
                [self setBackgroundImage:yellowButton forState:UIControlStateHighlighted];
                [self setBackgroundImage:yellowButton forState:UIControlStateSelected];
                _flagImg = [[UIImageView alloc]init];
                _flagImg.translatesAutoresizingMaskIntoConstraints = NO;
                [self addSubview:_flagImg];
                self.textLabel = [[UILabel alloc] init];
                _textLabel.textAlignment = NSTextAlignmentCenter;
                _textLabel.textColor = [UIColor whiteColor];
                _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
                [self addSubview:_textLabel];
                
                [self removeConstraints:self.constraints];
                NSDictionary *dict = NSDictionaryOfVariableBindings(_flagImg, _textLabel);
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_flagImg(19)][_textLabel(20)]-3-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:dict]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-27-[_flagImg]-27-|" options:0 metrics:nil views:dict]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textLabel]|" options:0 metrics:nil views:dict]];
                
                break;
            }
                
            case FSUIButtonTypeChangeBullOrBear: {
                
                
                
                stretchableGreenButton = [[UIImage imageNamed:@"草綠色按鈕"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                stretchableYellowButton = [[UIImage imageNamed:@"紫色按鈕"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                [self setBackgroundImage:stretchableYellowButton forState:UIControlStateNormal];
                [self setBackgroundImage:stretchableGreenButton forState:UIControlStateHighlighted];
                [self setBackgroundImage:stretchableGreenButton forState:UIControlStateSelected];
                
                break;
                
            }
                
            
            case FSUIButtonTypeLightGreenButton:{
            
                stretchableBlueButton = [[UIImage imageNamed:@"草綠色按鈕"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                [self setBackgroundImage:stretchableBlueButton forState:UIControlStateNormal];
                break;
            }
            case FSUIButtonTypePurpleButton:{
                
                stretchableBlueButton = [[UIImage imageNamed:@"紫色按鈕"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                [self setBackgroundImage:stretchableBlueButton forState:UIControlStateNormal];
                break;
            }
            case FSUIButtonTypeBlueGreenButton:{
                
                stretchableBlueButton = [[UIImage imageNamed:@"藍綠色按鈕"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
                [self setBackgroundImage:stretchableBlueButton forState:UIControlStateNormal];
                break;
            }
            case FSUIButtonTypeBlueGreenDetailButton:{
                
                stretchableBlueButton = [[UIImage imageNamed:@"藍綠色選單按鈕"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 15, 33, 15)];
                [self setBackgroundImage:stretchableBlueButton forState:UIControlStateNormal];
                [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                break;
            }
                
            case FSUIButtonTypeBlueGreenDetail2Button:{
                
                stretchableBlueButton = [[UIImage imageNamed:@"藍綠色選單按鈕(黑)"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 32, 33, 32)];
                [self setBackgroundImage:stretchableBlueButton forState:UIControlStateNormal];
                [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                break;
            }

            default:
                break;
        }
    }
    return self;
}

- (UIImage *)resizeWithImage:(UIImage *)image capInsets:(UIEdgeInsets)capInsets {
    CGFloat systemVersion = [(NSNumber *)[[UIDevice currentDevice] systemVersion] floatValue];
    UIImage *img = nil;
    if (systemVersion >= 5.0) {
        // ios 5.0後作法
        img = [image resizableImageWithCapInsets:capInsets];
        return img;
    }
    // ios 5.0以前作法
    img = [image stretchableImageWithLeftCapWidth:capInsets.left topCapHeight:capInsets.top];
    return img;
}

- (void)btnHandler:(UIButton *)sender{
    [self.btnLabel setLabelize:NO];
}

@end
