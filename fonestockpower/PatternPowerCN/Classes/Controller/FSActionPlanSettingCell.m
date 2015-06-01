//
//  FSActionPlanSettingCell.m
//  FonestockPower
//
//  Created by Derek on 2014/5/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionPlanSettingCell.h"

@implementation FSActionPlanSettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        _symbolLabel = [self newLabel];
        _addLabel = [self newLabel];
        _moveLabel = [self newLabel];
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
    _symbolLabel.text = nil;
    _addLabel.text = nil;
    _moveLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.bounds;
    CGFloat cellWidth = self.contentView.bounds.size.width / 3;
    
    _symbolLabel.frame = CGRectMake(0, 0, cellWidth - 10, contentRect.size.height);
    _addLabel.frame = CGRectMake(cellWidth - 10, 0, cellWidth + 65, contentRect.size.height);
    _moveLabel.frame = CGRectMake(cellWidth * 2 + 55, 0, cellWidth - 55, contentRect.size.height);

}

- (UILabel *)newLabel {
    UILabel *result = [[UILabel alloc] init];
    result.backgroundColor = [UIColor clearColor];
    result.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:result];
    return result;
}

@end
