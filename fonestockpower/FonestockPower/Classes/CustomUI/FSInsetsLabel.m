//
//  FSInsetsLabel.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/6/17.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSInsetsLabel.h"

@implementation FSInsetsLabel
@synthesize topInset, leftInset, bottomInset, rightInset;


- (void)drawTextInRect:(CGRect)rect{
    UIEdgeInsets insets = {self.topInset, self.leftInset,
        self.bottomInset, self.rightInset};
    
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
