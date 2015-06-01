//
//  StockHolderMeetingCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "StockHolderMeetingCell.h"

@implementation StockHolderMeetingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initLabel];
        [self processLayout];
    }
    return self;
}

-(void)initLabel
{
    
    self.leftLabel = [[UILabel alloc] init];
    _leftLabel.backgroundColor = [UIColor colorWithRed:254.0f/255.0f green:230.0f/255.0f blue:144.0f/255.0f alpha:1];
    _leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_leftLabel];
    
    self.rightLabel = [[UILabel alloc] init];
    [_rightLabel setTextColor:[UIColor blueColor]];
    _rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_rightLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_leftLabel, _rightLabel);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftLabel(170)][_rightLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftLabel]|" options:0 metrics:nil views:viewController]];
}

@end

