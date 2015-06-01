//
//  FSTradeHistoryMainTableViewCell.m
//  FonestockPower
//
//  Created by Derek on 2014/11/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSTradeHistoryMainTableViewCell.h"

@implementation FSTradeHistoryMainTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _symbolLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 100, 30)];
        _symbolLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_symbolLabel];
        
        _qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 15, 100, 30)];
        _qtyLabel.textAlignment = NSTextAlignmentRight;
        _qtyLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_qtyLabel];
        
        _buyDealLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 110, 30)];
        _buyDealLabel.textAlignment = NSTextAlignmentRight;
        _buyDealLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_buyDealLabel];
        
        _buyAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 30, 110, 30)];
        _buyAmountLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_buyAmountLabel];
        
        _sellDealLabel = [[UILabel alloc] initWithFrame:CGRectMake(310, 0, 110, 30)];
        _sellDealLabel.textAlignment = NSTextAlignmentRight;
        _sellDealLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_sellDealLabel];
        
        _sellAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(310, 30, 110, 30)];
        _sellAmountLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_sellAmountLabel];
        
        _removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(430, 8, 40, 40)];
        [_removeBtn setImage:[UIImage imageNamed:@"RedDeleteButton"] forState:UIControlStateNormal];
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
    _symbolLabel = nil;
    _qtyLabel = nil;
    _buyDealLabel = nil;
    _buyAmountLabel = nil;
    _sellDealLabel = nil;
    _sellAmountLabel = nil;
    _removeBtn = nil;
}
@end
