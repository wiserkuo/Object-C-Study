//
//  RecCollectionViewCell.m
//  EmergingRec
//
//  Created by Michael.Hsieh on 2014/10/15.
//  Copyright (c) 2014年 Michael. All rights reserved.
//

#import "FSEmergingRecCollectionViewCell.h"

@implementation FSEmergingRecCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.label = [[UILabel alloc]initWithFrame:self.bounds];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:20.0f];
        [self addSubview:self.label];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
