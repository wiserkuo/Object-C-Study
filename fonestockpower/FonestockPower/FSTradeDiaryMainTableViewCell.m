//
//  FSTradeDiaryMainTableViewCell.m
//  FonestockPower
//
//  Created by Derek on 2014/11/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSTradeDiaryMainTableViewCell.h"

@implementation FSTradeDiaryMainTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 100, 30)];
        _qtyLabel.textColor = [UIColor blueColor];
        _qtyLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_qtyLabel];
        
        _avgSellLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 100, 30)];
        _avgSellLabel.textColor = [UIColor blueColor];
        _avgSellLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_avgSellLabel];
        
        _sellAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 30, 100, 30)];
        _sellAmountLabel.textColor = [UIColor blueColor];
        _sellAmountLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_sellAmountLabel];
        
        _gainLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 100, 30)];
        _gainLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_gainLabel];
        
        _gainPercentLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 30, 100, 30)];
        _gainPercentLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_gainPercentLabel];
        
        _avgCostLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 0, 100, 30)];
        _avgCostLabel.textColor = [UIColor blueColor];
        _avgCostLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_avgCostLabel];
        
        _costAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 30, 100, 30)];
        _costAmountLabel.textColor = [UIColor blueColor];
        _costAmountLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_costAmountLabel];
        
        _hBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeLightGreenButton];
        _hBtn.frame = CGRectMake(402, 5, 30, 50);
        [_hBtn setTitle:NSLocalizedStringFromTable(@"歷", @"Position", nil) forState:UIControlStateNormal];
        [self.contentView addSubview:_hBtn];
        
        _nBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenButton];
        _nBtn.frame = CGRectMake(435, 5, 30, 50);
        [_nBtn setTitle:NSLocalizedStringFromTable(@"記", @"Position", nil) forState:UIControlStateNormal];
        [self.contentView addSubview:_nBtn];
        
        _gBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypePurpleButton];
        _gBtn.frame = CGRectMake(468, 5, 30, 50);
        [_gBtn setTitle:NSLocalizedStringFromTable(@"報", @"Position", nil) forState:UIControlStateNormal];
        [self.contentView addSubview:_gBtn];
        
//        _removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(510, 8, 40, 40)];
//        [_removeBtn setImage:[UIImage imageNamed:@"RedDeleteButton"] forState:UIControlStateNormal];
//        [self.contentView addSubview:_removeBtn];
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
    _qtyLabel = nil;
    _avgSellLabel = nil;
    _sellAmountLabel = nil;
    _gainLabel  = nil;
    _gainPercentLabel = nil;
    _avgCostLabel = nil;
    _costAmountLabel = nil;
//    _removeBtn = nil;
}

@end
