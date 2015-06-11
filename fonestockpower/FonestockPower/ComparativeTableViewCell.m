//
//  ComparativeTableViewCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "ComparativeTableViewCell.h"

@implementation ComparativeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.leftLabel = [[UILabel alloc] init];
        _leftLabel.textColor = [UIColor colorWithRed:217.0/255.0 green:81.0/255.0 blue:0 alpha:1];
        _leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_leftLabel];
        
        self.rightLabel = [[UILabel alloc] init];
        _rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_rightLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateConstraints
{
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_leftLabel, _rightLabel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftLabel]" options:0 metrics:nil views:viewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_leftLabel]-5-[_rightLabel(20)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [super updateConstraints];
    
}

@end
