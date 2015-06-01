//
//  RealtimeListCell.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/16.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "RealtimeListCell.h"

@implementation RealtimeListCell

- (id)initWithStyle:(UITableViewCellStyle)style HasBidAsk:(BOOL)bidAsk
{
    self = [super init];
    if (self) {
        hasBidAsk = bidAsk;
        [self addAllLabel];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addAllLabel];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addAllLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addAllLabel
{
    self.timeLabel = [[UILabel alloc] init];
    self.tradeLabel = [[UILabel alloc] init];
    self.chgLabel = [[UILabel alloc] init];
    self.volLabel = [[UILabel alloc] init];
    
    self.bidLabel = [[UILabel alloc] init];
    self.askLabel = [[UILabel alloc] init];
    
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _tradeLabel.textAlignment = NSTextAlignmentCenter;
    _chgLabel.textAlignment = NSTextAlignmentCenter;
    _volLabel.textAlignment = NSTextAlignmentRight;
    
    _bidLabel.textAlignment = NSTextAlignmentCenter;
    _askLabel.textAlignment = NSTextAlignmentCenter;
    
    _timeLabel.backgroundColor = [UIColor clearColor];
    _tradeLabel.backgroundColor = [UIColor clearColor];
    _chgLabel.backgroundColor = [UIColor clearColor];
    _volLabel.backgroundColor = [UIColor clearColor];
    
    _bidLabel.backgroundColor = [UIColor clearColor];
    _askLabel.backgroundColor = [UIColor clearColor];
    
    _timeLabel.adjustsFontSizeToFitWidth = YES;
    _tradeLabel.adjustsFontSizeToFitWidth = YES;
    _chgLabel.adjustsFontSizeToFitWidth = YES;
    _volLabel.adjustsFontSizeToFitWidth = YES;
    
    _bidLabel.adjustsFontSizeToFitWidth = YES;
    _askLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.contentView addSubview:_timeLabel];
    [self.contentView addSubview:_tradeLabel];
    [self.contentView addSubview:_chgLabel];
    [self.contentView addSubview:_volLabel];
    
    if(hasBidAsk){
        _bidLabel.font = [UIFont systemFontOfSize:14];
        _askLabel.font = [UIFont systemFontOfSize:14];
        _tradeLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_bidLabel];
        [self.contentView addSubview:_askLabel];
    }
    
    UIFont *defaultFont = [UIFont systemFontOfSize:15];
    
    _timeLabel.font = defaultFont;
    _askLabel.font = defaultFont;
    _bidLabel.font = defaultFont;
    _tradeLabel.font = defaultFont;
    _chgLabel.font = defaultFont;
    _volLabel.font = defaultFont;
        
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat cellWidth = CGRectGetWidth(self.bounds);
    
    if (hasBidAsk) {
        CGFloat offset = cellWidth/6;
        
        _timeLabel.frame = CGRectMake(0, 0, offset, self.bounds.size.height);
        _bidLabel.frame = CGRectMake(offset, 0, offset, self.bounds.size.height);
        _askLabel.frame = CGRectMake(offset*2, 0, offset, self.bounds.size.height);
        _tradeLabel.frame = CGRectMake(offset*3, 0, offset, self.bounds.size.height);
        _chgLabel.frame = CGRectMake(offset*4, 0, offset, self.bounds.size.height);
        _volLabel.frame = CGRectMake(offset*5, 0, offset-2, self.bounds.size.height);

    }else{
        CGFloat offset = cellWidth/4;
        
        _timeLabel.frame = CGRectMake(0, 0, offset, self.bounds.size.height);
        _tradeLabel.frame = CGRectMake(offset, 0, offset, self.bounds.size.height);
        _chgLabel.frame = CGRectMake(offset*2, 0, offset, self.bounds.size.height);
        _volLabel.frame = CGRectMake(offset*3-10, 0, offset, self.bounds.size.height);

    }
    
}

@end
