//
//  FSPositionMainTableViewCell.m
//  FonestockPower
//
//  Created by Derek on 2014/11/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSPositionMainTableViewCell.h"

@implementation FSPositionMainTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 100, 30)];
        _qtyLabel.textAlignment = NSTextAlignmentRight;
        _qtyLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_qtyLabel];
        
        _avgCostLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 100, 30)];
        _avgCostLabel.textAlignment = NSTextAlignmentRight;
        _avgCostLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_avgCostLabel];
        
        _totalCostLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 30, 100, 30)];
        _totalCostLabel.textAlignment = NSTextAlignmentRight;
        _totalCostLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_totalCostLabel];
        
        _lastLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 100, 30)];
        _lastLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_lastLabel];
        
        _totalValLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 30, 100, 30)];
        _totalValLabel.textAlignment = NSTextAlignmentRight;
        _totalValLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_totalValLabel];
        
        _gainLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 0, 100, 30)];
        _gainLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_gainLabel];
        
        _gainPercentLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 30, 100, 30)];
        _gainPercentLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_gainPercentLabel];
        
        _riskLabel = [[UILabel alloc] initWithFrame:CGRectMake(400, 0, 100, 30)];
        _riskLabel.textAlignment = NSTextAlignmentRight;
        _riskLabel.text = @"9999";
        _riskLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_riskLabel];
        
        _riskPercentLabel = [[UILabel alloc] initWithFrame:CGRectMake(400, 30, 100, 30)];
        _riskPercentLabel.textAlignment = NSTextAlignmentRight;
        _riskPercentLabel.text = @"99.99%";
        _riskPercentLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_riskPercentLabel];
        
        _hBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeLightGreenButton];
        _hBtn.frame = CGRectMake(502, 5, 30, 50);
        [_hBtn setTitle:NSLocalizedStringFromTable(@"歷", @"Position", nil) forState:UIControlStateNormal];
        [self.contentView addSubview:_hBtn];
        
        _nBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenButton];
        _nBtn.frame = CGRectMake(535, 5, 30, 50);
        [_nBtn setTitle:NSLocalizedStringFromTable(@"記", @"Position", nil) forState:UIControlStateNormal];
        [self.contentView addSubview:_nBtn];
        
        _gBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypePurpleButton];
        _gBtn.frame = CGRectMake(568, 5, 30, 50);
        [_gBtn setTitle:NSLocalizedStringFromTable(@"報", @"Position", nil) forState:UIControlStateNormal];
        [self.contentView addSubview:_gBtn];
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _qtyLabel = nil;
    _avgCostLabel = nil;
    _totalCostLabel = nil;
    _gainLabel = nil;
    _gainPercentLabel = nil;
    _riskLabel = nil;
    _riskPercentLabel = nil;
}

@end
