//
//  FSActionAlertFixedTableViewCell.m
//  FonestockPower
//
//  Created by Derek on 2014/10/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionAlertFixedTableViewCell.h"

@implementation FSActionAlertFixedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _symbolLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _symbolLabel.textAlignment = NSTextAlignmentCenter;
        _symbolLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_symbolLabel];

        _lastLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 100, 30)];
        _lastLabel.textAlignment = NSTextAlignmentCenter;
        _lastLabel.adjustsFontSizeToFitWidth = YES;
        _lastLabel.textColor = [StockConstant PriceDownColor];
        [self.contentView addSubview:_lastLabel];
        
        _tradeBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypePurpleButton];
        _tradeBtn.frame = CGRectMake(100, 4, 66, 40);
        [self.contentView addSubview:_tradeBtn];
        
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
    _lastLabel = nil;
}

@end
