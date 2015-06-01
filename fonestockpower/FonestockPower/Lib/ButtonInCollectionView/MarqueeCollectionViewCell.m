//
//  MarqueeCollectionViewCell.m
//  WirtsLeg
//
//  Created by Kenny on 2014/3/4.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import "MarqueeCollectionViewCell.h"
#import "MarqueeLabel.h"

@interface MarqueeCollectionViewCell()

@end
@implementation MarqueeCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.button = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeMarquee];

        
        [self.button addGestureRecognizer:self.pan];
        self.button.userInteractionEnabled = YES;
        self.button.selected = NO;
        self.button.frame = CGRectInset(CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)), 0, 0);
        [self.button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        self.button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.button.btnLabel.lineBreakMode = NSLineBreakByClipping;

        [self.contentView addSubview:self.button];
    }
    return self;
}



-(void)setButtonText:(NSString *)button
{
    [self.button.btnLabel setText:button];
}

- (void)prepareForReuse {
	[super prepareForReuse];
    [self.button.btnLabel setLabelize:YES];
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
