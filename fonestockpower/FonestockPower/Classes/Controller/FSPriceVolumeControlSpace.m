//
//  FSPriceVolumeControlSpace.m
//  WirtsLeg
//
//  Created by KevinShen on 2014/2/10.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import "FSPriceVolumeControlSpace.h"

@interface FSPriceVolumeControlSpace ()

@end

@implementation FSPriceVolumeControlSpace{
    NSMutableArray *constraints;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        constraints = [[NSMutableArray alloc] init];
        [self addSingleCheckButton];
        [self addAccumulativeCheckButton];
        [self addSingleTitleLabel];
        [self addAccumulativeTitleLabel];
        [self addSinglePeriodSelectButton];
        [self addAccumulativePeriodSelectButton];
        [self addSingleDateLabel];
        [self addAccumulativeDateLabel];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - UI Component

- (void)addSingleCheckButton
{
    self.singleCheckButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeCheckBox];
    _singleCheckButton.translatesAutoresizingMaskIntoConstraints = NO;
    _singleCheckButton.selected = YES;
    [self addSubview:_singleCheckButton];
}

- (void)addAccumulativeCheckButton
{
    self.accumulativeCheckButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeCheckBox];
    _accumulativeCheckButton.translatesAutoresizingMaskIntoConstraints = NO;
    _accumulativeCheckButton.selected = YES;
    [self addSubview:_accumulativeCheckButton];
}

- (void)addSingleTitleLabel
{
    self.singleTitleLabel = [[UILabel alloc] init];
    _singleTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _singleTitleLabel.text = NSLocalizedStringFromTable(@"單日", @"Equity", @"Single");
    [self addSubview:_singleTitleLabel];
}

- (void)addAccumulativeTitleLabel
{
    self.accumulativeTitleLabel = [[UILabel alloc] init];
    _accumulativeTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _accumulativeTitleLabel.text = NSLocalizedStringFromTable(@"累積", @"Equity", @"Acc");
    [self addSubview:_accumulativeTitleLabel];
}

- (void)addSinglePeriodSelectButton
{
    self.singlePeriodSelectButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    _singlePeriodSelectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_singlePeriodSelectButton setTitle:NSLocalizedStringFromTable(@"今日", @"Equity", @"Today") forState:UIControlStateNormal];
    [self addSubview:_singlePeriodSelectButton];
}

- (void)addAccumulativePeriodSelectButton
{
    self.accumulativePeriodSelectButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    _accumulativePeriodSelectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_accumulativePeriodSelectButton setTitle:NSLocalizedStringFromTable(@"5日", @"Equity", @"5days") forState:UIControlStateNormal];
    [self addSubview:_accumulativePeriodSelectButton];
}

- (void)addSingleDateLabel
{
    self.singleDateLabel = [[UILabel alloc] init];
    _singleDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        _singleDateLabel.text = [dateFormatter stringFromDate:today];
    } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        _singleDateLabel.text = [dateFormatter stringFromDate:today];
    }else{
        [dateFormatter setDateFormat:@"yyy/MM/dd"];
        _singleDateLabel.text = [dateFormatter stringFromDate:[today yearOffset:-1911]];
    }

    
    _singleDateLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_singleDateLabel];
}

- (void)addAccumulativeDateLabel
{
    self.accumulativeDateLabel = [[UILabel alloc] init];
    _accumulativeDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _accumulativeDateLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_accumulativeDateLabel];
}

#pragma mark - Autolayout

- (void)updateConstraints
{
    [super updateConstraints];
    [self removeConstraints:constraints];
    [constraints removeAllObjects];
    
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(_singleCheckButton, _accumulativeCheckButton, _singleTitleLabel, _accumulativeTitleLabel, _singlePeriodSelectButton, _accumulativePeriodSelectButton, _singleDateLabel, _accumulativeDateLabel);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_singleCheckButton(44)][_singleTitleLabel(50)][_singlePeriodSelectButton(70)]-[_singleDateLabel(>=120)]" options:0 metrics:nil views:viewDict]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_accumulativeCheckButton(44)][_accumulativeTitleLabel(50)][_accumulativePeriodSelectButton(70)]-[_accumulativeDateLabel(>=120)]" options:0 metrics:nil views:viewDict]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_singleCheckButton(44)]-5-[_accumulativeCheckButton(44)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewDict]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_singleTitleLabel(44)]-5-[_accumulativeTitleLabel(44)]" options:0 metrics:nil views:viewDict]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_singlePeriodSelectButton(44)]-5-[_accumulativePeriodSelectButton(44)]" options:0 metrics:nil views:viewDict]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_singleDateLabel(44)]-5-[_accumulativeDateLabel(44)]" options:0 metrics:nil views:viewDict]];
    
    [self addConstraints:constraints];
}

@end
