//
//  FSOptionStrategyCell.m
//  FonestockPower
//
//  Created by Derek on 2014/10/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSOptionStrategyCell.h"

@implementation FSOptionStrategyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _header1 = [self newLabel];
        _header2 = [self newLabel];
        _header3 = [self newLabel];
        _header4 = [self newLabel];
        
        _monthLabel = [self newLabel];
        _powerLabel = [self newLabel];
        _priceLabe = [self newLabel];
        
        _strikeBtn = [[UIButton alloc] init];
        [_strikeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:_strikeBtn];
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
    _header1.text = nil;
    _header2.text = nil;
    _header3.text = nil;
    _header4.text = nil;
    _monthLabel.text = nil;
    _powerLabel.text = nil;
    _priceLabe.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.bounds;
    CGFloat cellHeaderWidth = self.contentView.bounds.size.width / 4;
    
    _header1.frame = CGRectMake(0, 0, cellHeaderWidth, contentRect.size.height);
    _header2.frame = CGRectMake(cellHeaderWidth, 0, cellHeaderWidth-2, contentRect.size.height);
    _header3.frame = CGRectMake(cellHeaderWidth * 2, 0, cellHeaderWidth-2, contentRect.size.height);
    _header4.frame = CGRectMake(cellHeaderWidth * 3, 0, cellHeaderWidth-2, contentRect.size.height);
    
    _monthLabel.frame = CGRectMake(0, 0, cellHeaderWidth, contentRect.size.height);
    _strikeBtn.frame = CGRectMake(cellHeaderWidth, 4, cellHeaderWidth-2, contentRect.size.height-8);
    _powerLabel.frame = CGRectMake(cellHeaderWidth * 2, 0, cellHeaderWidth-2, contentRect.size.height);
    _priceLabe.frame = CGRectMake(cellHeaderWidth * 3, 0, cellHeaderWidth-2, contentRect.size.height);
}

- (UILabel *)newLabel {
    UILabel *result = [[UILabel alloc] init];
    result.backgroundColor = [UIColor clearColor];
    result.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:result];
    return result;
}


@end
