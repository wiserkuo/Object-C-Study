//
//  EODTrackPatternsTableViewCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TrackPatternsTableViewCell.h"

@implementation TrackPatternsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.leftImage = [[UIImageView alloc] init];
        _leftImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_leftImage];
        
        self.imageName = [[UILabel alloc] init];
        _imageName.font = [UIFont systemFontOfSize:13.0f];
        _imageName.lineBreakMode = NSLineBreakByWordWrapping;
        _imageName.numberOfLines = 2;
        _imageName.textAlignment = NSTextAlignmentCenter;
        _imageName.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_imageName];
        
        self.topView = [[UIView alloc] init];
        _topView.layer.borderWidth = 0.5f;
        _topView.layer.borderColor = [UIColor grayColor].CGColor;
        _topView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_topView];
        
        self.centerView = [[UIView alloc] init];
        _centerView.layer.borderWidth = 0.5f;
        _centerView.layer.borderColor = [UIColor grayColor].CGColor;
        _centerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_centerView];
        
        self.bottomView = [[UIView alloc] init];
        _bottomView.layer.borderWidth = 0.5f;
        _bottomView.layer.borderColor = [UIColor grayColor].CGColor;
        _bottomView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_bottomView];
        
        self.verticalLine1 = [[UILabel alloc] init];
        _verticalLine1.backgroundColor = [UIColor grayColor];
        _verticalLine1.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_verticalLine1];
        
        self.topViewVerticalLine = [[UILabel alloc] init];
        _topViewVerticalLine.backgroundColor = [UIColor grayColor];
        _topViewVerticalLine.translatesAutoresizingMaskIntoConstraints = NO;
        [_topView addSubview:_topViewVerticalLine];
        
        self.centerViewVerticalLine = [[UILabel alloc] init];
        _centerViewVerticalLine.backgroundColor = [UIColor grayColor];
        _centerViewVerticalLine.translatesAutoresizingMaskIntoConstraints = NO;
        [_centerView addSubview:_centerViewVerticalLine];
        
        self.bottomViewVerticalLine = [[UILabel alloc] init];
        _bottomViewVerticalLine.backgroundColor = [UIColor grayColor];
        _bottomViewVerticalLine.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomView addSubview:_bottomViewVerticalLine];
        
        self.horizonLine1 = [[UILabel alloc] init];
        _horizonLine1.backgroundColor = [UIColor grayColor];
        _horizonLine1.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_horizonLine1];
        
        self.horizonLine2 = [[UILabel alloc] init];
        _horizonLine2.backgroundColor = [UIColor grayColor];
        _horizonLine2.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_horizonLine2];
        
        self.dayLabel = [[UILabel alloc] init];
        _dayLabel.text = NSLocalizedStringFromTable(@"日線", @"FigureSearch", nil);
        _dayLabel.adjustsFontSizeToFitWidth = YES;
        _dayLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.topView addSubview:_dayLabel];
        
        self.weekLabel = [[UILabel alloc] init];
        _weekLabel.text = NSLocalizedStringFromTable(@"週線", @"FigureSearch", nil);
        _weekLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _weekLabel.adjustsFontSizeToFitWidth = YES;
        [self.centerView addSubview:_weekLabel];
        
        self.monthLabel = [[UILabel alloc] init];
        _monthLabel.text = NSLocalizedStringFromTable(@"月線", @"FigureSearch", nil);
        _monthLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _monthLabel.adjustsFontSizeToFitWidth = YES;
        [self.bottomView addSubview:_monthLabel];
        
        self.dayContentLabel = [[UILabel alloc] init];
        _dayContentLabel.textAlignment = NSTextAlignmentRight;
        _dayContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.topView addSubview:_dayContentLabel];
        
        self.weekContentLabel = [[UILabel alloc] init];
        _weekContentLabel.textAlignment = NSTextAlignmentRight;
        _weekContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.centerView addSubview:_weekContentLabel];
        
        self.monthContentLabel = [[UILabel alloc] init];
        _monthContentLabel.textAlignment = NSTextAlignmentRight;
        _monthContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.bottomView addSubview:_monthContentLabel];
        
        self.topBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_topBtn addTarget:self action:@selector(tapHandler:) forControlEvents:UIControlEventTouchUpInside];
        _topBtn.backgroundColor = [UIColor clearColor];
        _topBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_topBtn];
        
        self.centerBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_centerBtn addTarget:self action:@selector(tapHandler:) forControlEvents:UIControlEventTouchUpInside];
        _centerBtn.backgroundColor = [UIColor clearColor];
        _centerBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_centerBtn];
        
        self.bottomBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_bottomBtn addTarget:self action:@selector(tapHandler:) forControlEvents:UIControlEventTouchUpInside];
        _bottomBtn.backgroundColor = [UIColor clearColor];
        _bottomBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_bottomBtn];
        
        [self updateConstraintsIfNeeded];
        
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
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_leftImage, _verticalLine1, _topViewVerticalLine, _centerViewVerticalLine, _bottomViewVerticalLine, _horizonLine1, _horizonLine2, _dayLabel, _weekLabel, _monthLabel, _dayContentLabel, _weekContentLabel, _monthContentLabel, _topView, _centerView, _bottomView, _imageName, _topBtn, _centerBtn, _bottomBtn);
    
    NSDictionary *metrics = @{@"contentWidth":@(self.frame.size.width - 100)
                              };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_leftImage(80)][_imageName]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_verticalLine1(120)]" options:0 metrics:nil views:viewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topView(40)][_centerView(40)][_bottomView(40)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_imageName(90)]" options:0 metrics:nil views:viewDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_leftImage(80)]-10-[_verticalLine1(1)][_topView(contentWidth)]" options:0 metrics:metrics views:viewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_leftImage(80)]-10-[_verticalLine1(1)][_centerView(contentWidth)]" options:0 metrics:metrics views:viewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_leftImage(80)]-10-[_verticalLine1(1)][_bottomView(contentWidth)]" options:0 metrics:metrics views:viewDictionary]];
    
    [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_dayLabel]|" options:0 metrics:nil views:viewDictionary]];
    [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topViewVerticalLine]|" options:0 metrics:nil views:viewDictionary]];
    [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_dayContentLabel]|" options:0 metrics:nil views:viewDictionary]];
    [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_dayLabel(40)]-10-[_topViewVerticalLine(1)]-10-[_dayContentLabel]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    
    [_centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_weekLabel]|" options:0 metrics:nil views:viewDictionary]];
    [_centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_centerViewVerticalLine]|" options:0 metrics:nil views:viewDictionary]];
    [_centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_weekContentLabel]|" options:0 metrics:nil views:viewDictionary]];
    [_centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_weekLabel(40)]-10-[_centerViewVerticalLine(1)]-10-[_weekContentLabel]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_monthLabel]|" options:0 metrics:nil views:viewDictionary]];
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_bottomViewVerticalLine]|" options:0 metrics:nil views:viewDictionary]];
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_monthContentLabel]|" options:0 metrics:nil views:viewDictionary]];
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_monthLabel(40)]-10-[_bottomViewVerticalLine(1)]-10-[_monthContentLabel]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_topView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_topView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_topView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_topView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_centerBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_centerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_centerBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_centerView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_centerBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_centerView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_centerBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_centerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
}

-(void)tapHandler:(FSUIButton *)sender
{
    [_delegate trackBeClick:self Btn:sender Row:self.tag];
}


@end
