//
//  EDOTargetTableViewCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/5/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "EODTargetTableViewCell.h"

@implementation EODTargetTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imgView = [[UIImageView alloc] init];
        _imgView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_imgView];
        
        self.verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = [UIColor grayColor];
        _verticalLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_verticalLine];
        
        self.imageTitle = [[UILabel alloc] init];
        _imageTitle.textAlignment = NSTextAlignmentCenter;
        _imageTitle.font = [UIFont boldSystemFontOfSize:17.0f];
        _imageTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_imageTitle];
        
        self.countNum = [[UILabel alloc] init];
        _countNum.font = [UIFont boldSystemFontOfSize:25.0f];
        _countNum.textAlignment = NSTextAlignmentRight;
        _countNum.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_countNum];
        
        self.candidatesLabel = [[UILabel alloc] init];
        _candidatesLabel.text = NSLocalizedStringFromTable(@"candidates", @"FigureSearch", nil);
        _candidatesLabel.textAlignment = NSTextAlignmentRight;
        _candidatesLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_candidatesLabel];
        
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
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_imgView, _imageTitle, _verticalLine, _countNum, _candidatesLabel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_imgView(80)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewController]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_verticalLine(95)]" options:0 metrics:nil views:viewController]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[_countNum(50)]" options:0 metrics:nil views:viewController]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[_candidatesLabel(50)]" options:0 metrics:nil views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_imgView(80)]-5-[_verticalLine(2)]-5-[_imageTitle]" options:0 metrics:nil views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageTitle]" options:0 metrics:nil views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-112-[_countNum(100)]-10-[_candidatesLabel]|" options:0 metrics:nil views:viewController]];
}
@end
