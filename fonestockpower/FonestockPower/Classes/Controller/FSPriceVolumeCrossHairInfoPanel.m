//
//  FSPriceVolumeCrossInfoPanel.m
//  WirtsLeg
//
//  Created by KevinShen on 2014/2/11.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import "FSPriceVolumeCrossHairInfoPanel.h"
#import "FSPriceVolumeCrossHairInfo.h"

@interface FSPriceVolumeCrossHairInfoPanel ()
@property (nonatomic, strong) UIView *priceArea;
@property (nonatomic, strong) UIView *volArea;

@property (nonatomic, strong) UILabel *priceTitleLabel;
@property (nonatomic, strong) UILabel *volTitleLabel;

@property (nonatomic, strong) UILabel *singleDayPriceLabel;
@property (nonatomic, strong) UILabel *accumulationPriceLabel;

@property (nonatomic, strong) UILabel *singleDayVolLabel;
@property (nonatomic, strong) UILabel *accumulationVolLabel;


@property (nonatomic, strong) UILabel *volAreaSingleDayIdentifierLabel;
@property (nonatomic, strong) UILabel *volAreaAccumulationIdentifierLabel;

@end

@implementation FSPriceVolumeCrossHairInfoPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupPanelUI];
        [self addPriceTitleLabel];
        [self addVolTitleLabel];
        [self addSingleDayPriceLabel];
        [self addSingleDayVolLabel];
        [self addAccumulationPriceLabel];
        [self addAccumulationVolLabel];
        [self addVolAreaSingleDayIdentifierLabel];
        [self addVolAreaAccumulationIdentifierLabel];
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

- (void)setupPanelUI
{
    self.layer.borderWidth = 1.0f;
    self.backgroundColor = [UIColor whiteColor];
    self.priceArea = [[UIView alloc] init];
    _priceArea.translatesAutoresizingMaskIntoConstraints = NO;
    self.priceArea.layer.borderColor = [UIColor blackColor].CGColor;
    self.priceArea.layer.borderWidth = 0.5f;
    [self addSubview:_priceArea];
    self.volArea = [[UIView alloc] init];
    _volArea.translatesAutoresizingMaskIntoConstraints = NO;
    self.volArea.layer.borderColor = [UIColor blackColor].CGColor;
    self.volArea.layer.borderWidth = 0.5f;
    [self addSubview:_volArea];
}

- (void)addPriceTitleLabel
{
    self.priceTitleLabel = [[UILabel alloc] init];
    _priceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _priceTitleLabel.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:102.0f/255.0f blue:125.0f/255.0f alpha:1.000];
    _priceTitleLabel.textColor = [UIColor whiteColor];
    _priceTitleLabel.textAlignment = NSTextAlignmentCenter;
    _priceTitleLabel.text = NSLocalizedStringFromTable(@"Price", @"Equity", @"");
    [_priceArea addSubview:_priceTitleLabel];
}

- (void)addVolTitleLabel
{
    self.volTitleLabel = [[UILabel alloc] init];
    _volTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _volTitleLabel.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:102.0f/255.0f blue:125.0f/255.0f alpha:1.000];
    _volTitleLabel.textColor = [UIColor whiteColor];
    _volTitleLabel.textAlignment = NSTextAlignmentCenter;
    _volTitleLabel.text = NSLocalizedStringFromTable(@"量", @"Equity", @"Vols");
    [_volArea addSubview:_volTitleLabel];
}

- (void)addSingleDayPriceLabel
{
    self.singleDayPriceLabel = [[UILabel alloc] init];
    _singleDayPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _singleDayPriceLabel.adjustsFontSizeToFitWidth = YES;
    _singleDayPriceLabel.textAlignment = NSTextAlignmentCenter;
    [_priceArea addSubview:_singleDayPriceLabel];
}

- (void)addAccumulationPriceLabel
{
    self.accumulationPriceLabel = [[UILabel alloc] init];
    _accumulationPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _accumulationPriceLabel.adjustsFontSizeToFitWidth = YES;
    _accumulationPriceLabel.textAlignment = NSTextAlignmentCenter;
    [_priceArea addSubview:_accumulationPriceLabel];
}

- (void)addSingleDayVolLabel
{
    self.singleDayVolLabel = [[UILabel alloc] init];
    _singleDayVolLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _singleDayVolLabel.textColor = [UIColor colorWithRed:0.079 green:0.000 blue:0.949 alpha:1.000];
    _singleDayVolLabel.textAlignment = NSTextAlignmentRight;
    _singleDayVolLabel.adjustsFontSizeToFitWidth = YES;
    [_volArea addSubview:_singleDayVolLabel];
}

- (void)addAccumulationVolLabel
{
    self.accumulationVolLabel = [[UILabel alloc] init];
    _accumulationVolLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _accumulationVolLabel.textColor = [UIColor colorWithRed:0.079 green:0.000 blue:0.949 alpha:1.000];
    _accumulationVolLabel.textAlignment = NSTextAlignmentRight;
    _accumulationVolLabel.adjustsFontSizeToFitWidth = YES;
    [_volArea addSubview:_accumulationVolLabel];
}

- (void)addVolAreaSingleDayIdentifierLabel
{
    self.volAreaSingleDayIdentifierLabel = [[UILabel alloc] init];
    _volAreaSingleDayIdentifierLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _volAreaSingleDayIdentifierLabel.adjustsFontSizeToFitWidth = YES;
    _volAreaSingleDayIdentifierLabel.text = NSLocalizedStringFromTable(@"S", @"Equity", @"");
    [_volArea addSubview:_volAreaSingleDayIdentifierLabel];
}

- (void)addVolAreaAccumulationIdentifierLabel
{
    self.volAreaAccumulationIdentifierLabel = [[UILabel alloc] init];
    _volAreaAccumulationIdentifierLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _volAreaAccumulationIdentifierLabel.adjustsFontSizeToFitWidth = YES;
    _volAreaAccumulationIdentifierLabel.text = NSLocalizedStringFromTable(@"A", @"Equity", @"");
    [_volArea addSubview:_volAreaAccumulationIdentifierLabel];
    
}

#pragma mark - Action

- (void)updatePanelWithInfo:(FSPriceVolumeCrossHairInfo *) crossHairInfo referencePrice:(NSNumber *) referencePrice
{
    self.singleDayPriceLabel = [self updateContentLabel:_singleDayPriceLabel value:crossHairInfo.singleDayPrice referencePrice:referencePrice];
    self.accumulationPriceLabel = [self updateContentLabel:_accumulationPriceLabel value:crossHairInfo.accumulationPrice referencePrice:referencePrice];
    self.singleDayVolLabel = [self updateContentLabel:_singleDayVolLabel value:crossHairInfo.singleDayVol];
    self.accumulationVolLabel = [self updateContentLabel:_accumulationVolLabel value:crossHairInfo.accumulationVol];
}

/**
 *  更新量的label用
 *
 *  @param contentLabel 要更新的label
 *  @param value        值
 *
 *  @return 更新後的label
 */
- (UILabel *)updateContentLabel:(UILabel *) contentLabel value:(NSNumber *) value
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    contentLabel.textColor = [UIColor blueColor];
    if ([value isKindOfClass:[NSNull class]] || [value integerValue] == 0) {
        contentLabel.text = @"----";
    }
    else {
        contentLabel.text = [CodingUtil volumeRoundRownWithDouble:[value doubleValue]] ;
    }
    return contentLabel;
}

- (UILabel *)updateContentLabel:(UILabel *) contentLabel value:(NSNumber *) value referencePrice:(NSNumber *) referencePrice
{
    return [self updateContentLabel:contentLabel value:value referencePrice:referencePrice sign:NO];
}

//InfoPanel裡面的文字
- (UILabel *)updateContentLabel:(UILabel *) contentLabel value:(NSNumber *) value referencePrice:(NSNumber *) referencePrice sign:(BOOL) sign
{
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    if ([value doubleValue] >= 1000.00) {
//        [formatter setMaximumFractionDigits:1];
//        [formatter setMinimumFractionDigits:1];
//    }else{
//        [formatter setMaximumFractionDigits:2];
//        [formatter setMinimumFractionDigits:2];
//    }
//
//    if (sign) {
//        [formatter setPositiveFormat:@"+#,##0.00"];
//        [formatter setNegativeFormat:@"-#,##0.00"];
//    }
    
    if ([value isKindOfClass:[NSNull class]] || [value doubleValue] == 0.00) {
        contentLabel.text = @"----";
        contentLabel.textColor = [UIColor blueColor];
    }else {
//        contentLabel.text = [formatter stringFromNumber:value];
        contentLabel.text = [CodingUtil priceRoundRownWithDouble:[value doubleValue]];
        if (referencePrice != nil) {
//            if ([value compare:referencePrice] == NSOrderedDescending) {
            if ([value floatValue] > [referencePrice floatValue]) {
                contentLabel.textColor = [StockConstant PriceUpColor];
            }
//            else if([value compare:referencePrice] == NSOrderedAscending)  {
            else if ([value floatValue] < [referencePrice floatValue]) {
                contentLabel.textColor = [StockConstant PriceDownColor];
            }else{
                contentLabel.textColor = [UIColor blueColor];
            }
        }
        else {
            if ([value doubleValue] == 0.00) {
                contentLabel.textColor = [UIColor blueColor];
            }
            else if([value doubleValue] > 0.00) {
                contentLabel.textColor = [StockConstant PriceUpColor];
            }
            else {
                contentLabel.textColor = [StockConstant PriceDownColor];
            }
        }
    }
    
    return contentLabel;
}

#pragma mark - Layout

//- (void)viewWillLayoutSubviews
//{
//    CGRect leftArea, rightArea;
//    CGRectDivide(self.bounds, &leftArea, &rightArea, CGRectGetWidth(self.bounds), CGRectMinXEdge);
//    _priceArea.frame = leftArea;
//    _volArea.frame = rightArea;
//}

- (void)setIsSingleDayEnabled:(BOOL)isSingleDayEnabled
{
    _isSingleDayEnabled = isSingleDayEnabled;
    _singleDayPriceLabel.hidden = !isSingleDayEnabled;
    _singleDayVolLabel.hidden = !isSingleDayEnabled;
    _volAreaSingleDayIdentifierLabel.hidden = !isSingleDayEnabled;
}

- (void)setIsAccumulationEnabled:(BOOL)isAccumulationEnabled
{
    _isAccumulationEnabled = isAccumulationEnabled;
    _accumulationPriceLabel.hidden = !isAccumulationEnabled;
    _accumulationVolLabel.hidden = !isAccumulationEnabled;
    _volAreaAccumulationIdentifierLabel.hidden = !isAccumulationEnabled;
}

- (void)updateConstraints
{
    [super updateConstraints];
    [self removeConstraints:self.constraints];
    
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(_priceArea, _volArea, _priceTitleLabel, _volTitleLabel, _singleDayPriceLabel, _accumulationPriceLabel, _singleDayVolLabel, _accumulationVolLabel, _volAreaSingleDayIdentifierLabel, _volAreaAccumulationIdentifierLabel);
    NSDictionary *metrics = @{@"RowHeight":@(floor(CGRectGetHeight(self.bounds)/3))};
                              
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_priceArea(==_volArea)][_volArea]|" options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_priceArea]|" options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_volArea]|" options:0 metrics:nil views:viewDict]];
    
    //排左半邊
    [_priceArea removeConstraints:_priceArea.constraints];
    [_priceArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_priceTitleLabel]|" options:0 metrics:nil views:viewDict]];
    NSString *priceAreaVerticalConstraint = @"";
    if (_isSingleDayEnabled) {
        priceAreaVerticalConstraint = @"V:|[_priceTitleLabel(20)][_singleDayPriceLabel(20)]";
        [_priceArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_singleDayPriceLabel]|" options:0 metrics:nil views:viewDict]];
    }
    if (_isAccumulationEnabled) {
        priceAreaVerticalConstraint = @"V:|[_priceTitleLabel(20)][_accumulationPriceLabel(20)][_singleDayPriceLabel(20)]";
        [_priceArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_accumulationPriceLabel]|" options:0 metrics:nil views:viewDict]];
    }
//    [priceAreaVerticalConstraint appendString:@"|"];
    [_priceArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:priceAreaVerticalConstraint options:0 metrics:metrics views:viewDict]];
    
    
    //排右半邊
    [_volArea removeConstraints:_volArea.constraints];
    //title佔滿寬
    [_volArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_volTitleLabel]|" options:0 metrics:nil views:viewDict]];
    
    if (_isSingleDayEnabled && _isAccumulationEnabled) {
        [_volArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_volTitleLabel(20)][_accumulationVolLabel(20)][_singleDayVolLabel(20)]" options:0 metrics:nil views:viewDict]];
        [_volArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_volTitleLabel(20)][_volAreaAccumulationIdentifierLabel(20)][_volAreaSingleDayIdentifierLabel(20)]" options:0 metrics:nil views:viewDict]];
        [_volArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_volAreaSingleDayIdentifierLabel(15)][_singleDayVolLabel]-2-|" options:0 metrics:nil views:viewDict]];
        [_volArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_volAreaAccumulationIdentifierLabel(15)][_accumulationVolLabel]-2-|" options:0 metrics:nil views:viewDict]];
    }
    else if (_isSingleDayEnabled) {
        [_volArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_volTitleLabel(20)][_singleDayVolLabel(20)]" options:0 metrics:nil views:viewDict]];
        [_volArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_volTitleLabel(20)][_volAreaSingleDayIdentifierLabel(20)]" options:0 metrics:nil views:viewDict]];
        [_volArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_volAreaSingleDayIdentifierLabel(15)][_singleDayVolLabel]|" options:0 metrics:nil views:viewDict]];
    }
    else if (_isAccumulationEnabled) {
//        [volAreaVerticalConstraint appendString:@"[_accumulationVolLabel(20)]"];
        [_volArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_volTitleLabel(20)][_accumulationVolLabel(20)]" options:0 metrics:nil views:viewDict]];
        [_volArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_volTitleLabel(20)][_volAreaAccumulationIdentifierLabel(20)]" options:0 metrics:nil views:viewDict]];
        [_volArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_volAreaAccumulationIdentifierLabel(15)][_accumulationVolLabel]|" options:0 metrics:nil views:viewDict]];
    }
    
//    [volAreaVerticalConstraint appendString:@"|"];
//    [_volArea addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:volAreaVerticalConstraint options:0 metrics:metrics views:viewDict]];
}

@end
