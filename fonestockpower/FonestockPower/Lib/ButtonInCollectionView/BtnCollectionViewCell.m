//
//  BtnCollectionViewCell.m
//  WirtsLeg
//
//  Created by Neil on 13/10/8.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "BtnCollectionViewCell.h"

@interface BtnCollectionViewCell()


@end


@implementation BtnCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.pan = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.button = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalGreen];

    
        [_button addGestureRecognizer:_pan];
        _button.userInteractionEnabled = YES;
        _button.selected = NO;
        [_button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        _button.frame = CGRectInset(CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)), 0, 0);
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        _button.titleLabel.lineBreakMode = NSLineBreakByClipping;
        
        
        [self.contentView addSubview:_button];
    }
    return self;
}

-(void)handlePan:(UILongPressGestureRecognizer *)sender{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(buttonPan:)]) {
        [_delegate buttonPan:sender];
    }
}

-(void)click:(FSUIButton *)btn{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(titleButtonClick:)]) {
        [_delegate titleButtonClick:btn];
    }
}

-(void)prepareForReuse{
    _button.selected = NO;

}


-(void)setButtonText:(NSString *)button
{
    [_button setTitle:button forState:UIControlStateNormal];
}
-(void)setButtonTextColor:(UIColor *)color{
    
    [_button setTitleColor:color forState:UIControlStateNormal];
}

-(void)setButtonTag:(int)tag{
    [_button setTag:tag];
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
