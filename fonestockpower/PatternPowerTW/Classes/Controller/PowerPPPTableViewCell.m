//
//  PowerPPPTableViewCell.m
//  FonestockPower
//
//  Created by CooperLin on 2014/11/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "PowerPPPTableViewCell.h"

@implementation PowerPPPTableViewCell

- (instancetype)initWithLStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 將cell分隔線設為完整, 不缺口
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        _mainLbl = [[UILabel alloc] init];
        _mainLbl.textColor = [UIColor blueColor];
        _mainLbl.translatesAutoresizingMaskIntoConstraints = NO;
        _mainLbl.adjustsFontSizeToFitWidth = YES;
        _subLbl = [[UILabel alloc] init];
        _subLbl.translatesAutoresizingMaskIntoConstraints = NO;
        _mainLbl.textAlignment = NSTextAlignmentLeft;
        _subLbl.textAlignment = NSTextAlignmentRight;
        _subLbl.textColor = [StockConstant PriceUpColor];
        [self addSubview:_mainLbl];
        [self addSubview:_subLbl];
        NSNumber *mainWidth = [[NSNumber alloc] initWithFloat:60];
        NSDictionary *metrics = @{@"mainWidth":mainWidth};
        NSDictionary *allObj = NSDictionaryOfVariableBindings(_mainLbl, _subLbl);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_mainLbl][_subLbl(mainWidth)]-2-|" options:0 metrics:metrics views:allObj]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainLbl]|" options:0 metrics:nil views:allObj]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_subLbl]|" options:0 metrics:nil views:allObj]];
        [super updateConstraints];
    }
    return self;
}

- (instancetype)initWithRStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 將cell分隔線設為完整, 不缺口
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        _mainLbl = [[UILabel alloc] init];
        _mainLbl.textColor = [UIColor blueColor];
        _mainLbl.translatesAutoresizingMaskIntoConstraints = NO;
        _mainLbl.adjustsFontSizeToFitWidth = YES;
        _subLbl = [[UILabel alloc] init];
        _subLbl.translatesAutoresizingMaskIntoConstraints = NO;
        _mainLbl.textAlignment = NSTextAlignmentRight;
        _subLbl.textAlignment = NSTextAlignmentLeft;
        _subLbl.textColor = [StockConstant PriceDownColor];
        [self addSubview:_mainLbl];
        [self addSubview:_subLbl];
        NSNumber *mainWidth = [[NSNumber alloc] initWithFloat:60];
        NSDictionary *metrics = @{@"mainWidth":mainWidth};
        NSDictionary *allObj = NSDictionaryOfVariableBindings(_mainLbl, _subLbl);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_subLbl(mainWidth)][_mainLbl]-2-|" options:0 metrics:metrics views:allObj]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainLbl]|" options:0 metrics:nil views:allObj]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_subLbl]|" options:0 metrics:nil views:allObj]];
        [super updateConstraints];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
