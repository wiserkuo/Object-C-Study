//
//  RadioTableViewCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/7/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "RadioTableViewCell.h"

@implementation RadioTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.checkBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeRadio];
//        _checkBtn.userInteractionEnabled = NO;
//        _checkBtn.translatesAutoresizingMaskIntoConstraints = NO;
//        [self addSubview:_checkBtn];
        
        self.titleLabel = [[UILabel alloc] init];
        
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_titleLabel];
        
        [self processLayout];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_titleLabel);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]" options:0 metrics:nil views:viewController]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel(240)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_checkBtn(35)]" options:0 metrics:nil views:viewController]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel(240)][_checkBtn(35)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];

}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.titleLabel = nil;
//    self.checkBtn = nil;
}
@end
