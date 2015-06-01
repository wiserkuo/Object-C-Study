//
//  WarrantBasicTableViewCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantBasicTableViewCell.h"

@implementation WarrantBasicTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.leftText = [[UILabel alloc] init];
        _leftText.font = [UIFont boldSystemFontOfSize:20.0f];
        _leftText.backgroundColor = [UIColor colorWithRed:254.0/255.0 green:230.0/255.0 blue:144.0/255.0 alpha:1];
        _leftText.textAlignment = NSTextAlignmentCenter;
        _leftText.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_leftText];
        
        self.rightText = [[UILabel alloc] init];
        _rightText.font = [UIFont systemFontOfSize:18.0f];
        _rightText.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_rightText];
        
        [self setNeedsUpdateConstraints];
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
    [super updateConstraints];
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_leftText, _rightText);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftText(140)][_rightText]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftText(40)]" options:0 metrics:nil views:viewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightText(40)]" options:0 metrics:nil views:viewDictionary]];
}

-(void)prepareForReuse
{
    _rightText.backgroundColor = [UIColor clearColor];
    _rightText.font = [UIFont systemFontOfSize:18.0f];
    _leftText.text = nil;
    _rightText.text = nil;
    
}
@end
