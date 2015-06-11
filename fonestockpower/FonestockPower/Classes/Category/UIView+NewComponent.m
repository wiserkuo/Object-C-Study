//
//  UIView+NewComponent.m
//  FonestockPower
//
//  Created by Connor on 14/4/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "UIView+NewComponent.h"

@implementation UIView (NewComponent)
- (FSUIButton *)newButton:(FSUIButtonType)buttonType {
    FSUIButton *result = [[FSUIButton alloc] initWithButtonType:buttonType];
    // [result setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [result.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    result.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:result];
    return result;
}
@end
