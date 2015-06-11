//
//  PatternsTipsCollectionCell.m
//  FonestockPower
//
//  Created by Kenny on 2015/1/15.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "PatternsTipsCollectionCell.h"

@implementation PatternsTipsCollectionCell
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        _btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalGreen];
        _btn.userInteractionEnabled = NO;
        [_btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
//        _btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        _btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        _btn.translatesAutoresizingMaskIntoConstraints = NO;
        [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:_btn];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_btn);

    [self.contentView removeConstraints:self.contentView.constraints];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_btn]|" options:0 metrics:nil views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_btn]|" options:0 metrics:nil views:viewDictionary]];

}

@end
