//
//  FSInvestedCell.m
//  FonestockPower
//
//  Created by Derek on 2014/4/23.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSInvestedCell.h"

@implementation FSInvestedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _dateLabel = [self newLabel];
        _remitLabel = [self newLabel];
        _amountLabel = [self newLabel];
        _totalAmountLabel = [self newLabel];
        _removeBtn = [[UIButton alloc] init];
        [self.contentView addSubview:_removeBtn];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
	[super prepareForReuse];
    _dateLabel.text = nil;
    _remitLabel.text = nil;
    _amountLabel.text = nil;
    _totalAmountLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.bounds;
    CGFloat cellWidth = self.contentView.bounds.size.width / 5;
    
    _dateLabel.frame = CGRectMake(0, 0, cellWidth, contentRect.size.height);
    _remitLabel.frame = CGRectMake(cellWidth, 0, cellWidth, contentRect.size.height);
    _amountLabel.frame = CGRectMake(cellWidth * 2, 0, cellWidth + 20, contentRect.size.height);
    _totalAmountLabel.frame = CGRectMake(cellWidth * 3 + 20, 0, cellWidth + 20, contentRect.size.height);
    _removeBtn.frame = CGRectMake(cellWidth * 4 + 70, 0, 44, 44);
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    _remitLabel.textAlignment = NSTextAlignmentCenter;
    _amountLabel.textAlignment = NSTextAlignmentRight;
    _totalAmountLabel.textAlignment = NSTextAlignmentRight;
}

- (UILabel *)newLabel {
    UILabel *result = [[UILabel alloc] init];
    result.backgroundColor = [UIColor clearColor];
    result.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:result];
    return result;
}

@end
