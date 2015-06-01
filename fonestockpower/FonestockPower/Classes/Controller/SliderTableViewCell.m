//
//  ScrollBarTableViewCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/27.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "SliderTableViewCell.h"

@implementation SliderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        constraints = [[NSMutableArray alloc]init];
        
        self.checkBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeCheckBox];
        _checkBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_checkBtn];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_titleLabel];
        
        self.valueLabel = [[UILabel alloc] init];
        _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_valueLabel];
        
        self.slider = [[NMRangeSlider alloc] init];
        _slider.maximumValue = 20;
        _slider.minimumValue = 15;
        _slider.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_slider];
        
        self.maxLabel = [[UILabel alloc] init];
        _maxLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_maxLabel];
        
        self.midLabel = [[UILabel alloc] init];
        _midLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_midLabel];
        
        self.minLabel = [[UILabel alloc] init];
        _minLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_minLabel];
        
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
    [self removeConstraints:constraints];
    [constraints removeAllObjects];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_checkBtn, _titleLabel, _valueLabel, _slider, _maxLabel, _midLabel, _minLabel);
    NSDictionary *widthDictionary = @{@"sliderWidth":@(self.frame.size.width-40)};
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_checkBtn(30)][_titleLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[_valueLabel]|" options:0 metrics:nil views:viewDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_slider(sliderWidth)]" options:0 metrics:widthDictionary views:viewDictionary]];
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_checkBtn(30)]" options:0 metrics:nil views:viewDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_checkBtn(30)][_valueLabel][_slider(31)]-20-|" options:0 metrics:nil views:viewDictionary]];
    
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_minLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_slider attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_minLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_slider attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_midLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_slider attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_midLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_slider attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_maxLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_slider attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_maxLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_slider attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    
    [self addConstraints:constraints];
}

- (void)prepareForReuse
{
	[super prepareForReuse];
    _valueLabel.text = nil;
}



@end
