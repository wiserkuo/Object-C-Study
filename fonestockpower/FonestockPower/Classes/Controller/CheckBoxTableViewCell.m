//
//  CheckBoxTableViewCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "CheckBoxTableViewCell.h"

@implementation CheckBoxTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.checkBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeCheckBox];
        _checkBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_checkBtn];
        
        self.titleLabel = [[UILabel alloc] init];
        
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_titleLabel];
        
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
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_checkBtn, _titleLabel);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]" options:0 metrics:nil views:viewController]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_checkBtn(30)]" options:0 metrics:nil views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_checkBtn(30)][_titleLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [super updateConstraints];
}


@end
