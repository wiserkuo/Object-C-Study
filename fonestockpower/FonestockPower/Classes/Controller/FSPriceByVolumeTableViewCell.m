//
//  FSPriceByVolumeTableViewCell.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/7.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSPriceByVolumeTableViewCell.h"

@implementation FSPriceByVolumeTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addPriceLabel];
        [self addVolumeLabel];
        [self addPercentageLabel];
        [self addInnerLabel];
        [self addOuterLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addPriceLabel
{
    self.priceLabel = [[UILabel alloc] init];
    _priceLabel.textAlignment = NSTextAlignmentLeft;
    _priceLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_priceLabel];
}

- (void)addVolumeLabel
{
    self.volumeLabel = [[UILabel alloc] init];
    _volumeLabel.textColor = [UIColor blueColor];
    _volumeLabel.textAlignment = NSTextAlignmentRight;
    _volumeLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_volumeLabel];
}

- (void)addPercentageLabel
{
    self.percentageLabel = [[UILabel alloc] init];
    _percentageLabel.textColor = [UIColor colorWithRed:0.657 green:0.525 blue:0.287 alpha:1.000];
    _percentageLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_percentageLabel];
}

- (void)addInnerLabel
{
    self.innerLabel = [[UILabel alloc] init];
    _innerLabel.textColor = [UIColor darkGrayColor];
    _innerLabel.textAlignment = NSTextAlignmentRight;
    _innerLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_innerLabel];
}

- (void)addOuterLabel
{
    self.outerLabel = [[UILabel alloc] init];
    _outerLabel.textColor = [UIColor orangeColor];
    _outerLabel.textAlignment = NSTextAlignmentRight;
    _outerLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_outerLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_hasPlat) {
        CGFloat offset = self.contentView.bounds.size.width/5;
        CGFloat cellHeight = self.bounds.size.height;
        _priceLabel.frame = CGRectMake(0, 0, offset, cellHeight);
        _volumeLabel.frame = CGRectMake(offset*1, 0, offset, cellHeight);
        _percentageLabel.frame = CGRectMake(offset*2, 0, offset, cellHeight);
        _innerLabel.frame = CGRectMake(offset*3, 0, offset, cellHeight);
        _outerLabel.frame = CGRectMake(offset*4, 0, offset, cellHeight);
    }else{
        CGFloat offset = self.contentView.bounds.size.width / 3;
        CGFloat cellHeight = self.contentView.bounds.size.height;
        _priceLabel.frame = CGRectMake(30, 0, offset, cellHeight);
        _volumeLabel.frame = CGRectMake(70, 0, offset, cellHeight);
        _percentageLabel.frame = CGRectMake(185, 0, offset, cellHeight);
    }
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.priceLabel.textColor = [UIColor blackColor];
    
}

@end
