//
//  MacroeconomicTableViewCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/7/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "MacroeconomicTableViewCell.h"
@implementation MacroeconomicTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.leftView = [[UIView alloc] init];
        _leftView.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:106.0/255.0 blue:0 alpha:1];
        _leftView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_leftView];
        
        self.rightView = [[UIView alloc] init];
        _rightView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_rightView];
        
        self.nameLabel = [[MarqueeLabel alloc] init];
        [_nameLabel setLabelize:YES];
        _nameLabel.marqueeType = 4;
        _nameLabel.continuousMarqueeExtraBuffer = 30.0f;
        _nameLabel.numberOfLines = 0;
        _nameLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap:)];
        [_nameLabel addGestureRecognizer:tapRecognizer];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_leftView addSubview:_nameLabel];
        
        self.nameDetailLabel = [[UILabel alloc] init];
        _nameDetailLabel.textAlignment = NSTextAlignmentLeft;
        _nameDetailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_leftView addSubview:_nameDetailLabel];
        
        self.valueLabel = [[UILabel alloc] init];
        _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_rightView addSubview:_valueLabel];
        
        self.dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [_dateLabel setTextColor:[UIColor lightGrayColor]];
        _dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_rightView addSubview:_dateLabel];
        
        self.arrowImage = [[UIImageView alloc] init];
        _arrowImage.translatesAutoresizingMaskIntoConstraints = NO;
        [_rightView addSubview:_arrowImage];
        
        [self processLayout];
        
    }
    return self;
}

- (void)labelTap:(UITapGestureRecognizer *)recognizer{
    [(MarqueeLabel *)recognizer.view setLabelize:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_leftView, _nameLabel, _nameDetailLabel, _valueLabel, _dateLabel, _arrowImage, _rightView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftView(54)]" options:0 metrics:nil views:viewController]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightView(54)]" options:0 metrics:nil views:viewController]];
    
    [_leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel][_nameDetailLabel]|" options:0 metrics:nil views:viewController]];
    
    [_leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nameLabel]|" options:0 metrics:nil views:viewController]];
    [_leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nameDetailLabel]|" options:0 metrics:nil views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_valueLabel][_dateLabel]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_arrowImage(30)]" options:0 metrics:nil views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftView(170)][_rightView(150)]" options:0 metrics:nil views:viewController]];
    
    [_rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_valueLabel(34)][_dateLabel(20)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewController]];
    
    [_rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_valueLabel][_arrowImage(20)]|" options:0 metrics:nil views:viewController]];
}

@end
