//
//  FSBrokerChoiceCollectionViewCell.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBrokerChoiceCollectionViewCell.h"

@implementation FSBrokerChoiceCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc]initWithFrame:self.bounds];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:20.0f];
        [self addSubview:self.label];
    }
    return self;
}

@end

@implementation FStrackCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalGreen];
        self.btn.userInteractionEnabled = NO;
        self.btn.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        self.btn.frame = CGRectMake(5, 0, 140, 42);
        self.btn.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:self.btn];
    }
    return self;
}

@end

@implementation FSheadOfficeCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalGreen];
        self.btn.userInteractionEnabled = NO;
        self.btn.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        self.btn.frame = CGRectMake(5, 0, 95, 42);
        self.btn.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:self.btn];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.btn.selected = NO;
    [self.btn setTitle:@"" forState:UIControlStateNormal];
    [self.btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
}
@end

@implementation FSbranchOfficeCollectionViewCell


@end
