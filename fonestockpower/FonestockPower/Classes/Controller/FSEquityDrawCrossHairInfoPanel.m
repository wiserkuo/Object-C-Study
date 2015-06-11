//
//  FSEquityDrawCrossHairInfoPanel.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/21.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSEquityDrawCrossHairInfoPanel.h"
#import "FSEquityDrawCrossHairInfo.h"

@interface FSEquityDrawCrossHairInfoPanel ()
@property (nonatomic, strong) NSMutableDictionary *attributeTitleLabelDict;
@property (nonatomic, strong) NSMutableDictionary *attributeContentLabelDict;
@property (nonatomic, strong) UIFont *font;
@end

@implementation FSEquityDrawCrossHairInfoPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0;
        
        self.font = [UIFont systemFontOfSize:15.0f];
        
        [self addTimePairLabel];
        [self addBidPairLabel];
        [self addAskPairLabel];
        [self addChangePairLabel];
        [self addLastPairLabel];
        [self addVolPairLabel];
        [self addNewsPairLabel];
        [self addComparedPricePairLabel];
        [self addComparedVolPairLabel];
        [self setLayout];
        
    }
    return self;
}

- (id)initWithFrameByWarrant:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.warrantFlag = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0;
        
        if(self.warrantFlag){
            self.font = [UIFont systemFontOfSize:12.0f];
        }else{
            self.font = [UIFont systemFontOfSize:15.0f];
        }
        
        [self addTimePairLabel];
        [self addBidPairLabel];
        [self addAskPairLabel];
        [self addChangePairLabel];
        [self addLastPairLabel];
        [self addVolPairLabel];
        [self addNewsPairLabel];
        [self addComparedPricePairLabel];
        [self addComparedVolPairLabel];
        [self setLayout];
        
    }
    return self;
}


- (void)addTimePairLabel
{
    if(self.warrantFlag){
        self.timeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 0, 40, 20)];
        self.timeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 0, 29, 20)];
    }else{
        self.timeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 0, 39, 20)];
        self.timeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 59, 20)];
    }
    
//    _timeTitleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedStringFromTable(@"時間", @"FigureSearch", nil)];
//    _timeTitleLabel.textColor = [UIColor whiteColor];
    _timeTitleLabel.backgroundColor = [UIColor colorWithRed:0.041 green:0.330 blue:0.426 alpha:1.000];
    //    _timeTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeTitleLabel.font = _font;
    [self addSubview:_timeTitleLabel];
    
    _timeContentLabel.textColor = [UIColor whiteColor];
    _timeContentLabel.backgroundColor = [UIColor colorWithRed:0.041 green:0.330 blue:0.426 alpha:1.000];
    //    _timeContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _timeContentLabel.font = _font;
    _timeContentLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_timeContentLabel];
}

- (void)addBidPairLabel
{
    if(self.warrantFlag){
        self.bidTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 20, 30, 12)];
        self.bidContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 20, 29, 12)];
    }else{
        self.bidTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 22, 39, 20)];
        self.bidContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 59, 20)];
    }
    
    _bidTitleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedStringFromTable(@"買", @"Equity", nil)];
    _bidTitleLabel.textAlignment = NSTextAlignmentLeft;
    //    _bidTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _bidTitleLabel.font = _font;
    [self addSubview:_bidTitleLabel];
    
    _bidContentLabel.textAlignment = NSTextAlignmentRight;
    //    _bidContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _bidContentLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_bidContentLabel];
}

- (void)addAskPairLabel
{
    if(self.warrantFlag){
        self.askTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 32, 30, 12)];
        self.askContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 32, 29, 12)];
    }else{
        self.askTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 44, 39, 20)];
        self.askContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 44, 59, 20)];
    }
    
    _askTitleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedStringFromTable(@"賣", @"Equity", nil)];
    _askTitleLabel.textAlignment = NSTextAlignmentLeft;
    //    _askTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _askTitleLabel.font = _font;
    [self addSubview:_askTitleLabel];
    
    _askContentLabel.textAlignment = NSTextAlignmentRight;
    //    _askContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _askContentLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_askContentLabel];
}

- (void)addLastPairLabel
{
    
    if(self.warrantFlag){
        self.lastPriceTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 44, 30, 12)];
        self.lastPriceContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 44, 29, 12)];
    }else{
        self.lastPriceTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 66, 39, 20)];
        self.lastPriceContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 66, 59, 20)];
    }
    
    _lastPriceTitleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedStringFromTable(@"成", @"Equity", nil)];
    _lastPriceTitleLabel.textAlignment = NSTextAlignmentLeft;
    
    //    _lastPriceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _lastPriceTitleLabel.font = _font;
    [self addSubview:_lastPriceTitleLabel];
    
    _lastPriceContentLabel.textAlignment = NSTextAlignmentRight;
    //    _lastPriceContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _lastPriceContentLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_lastPriceContentLabel];
}

- (void)addChangePairLabel
{
    
    if(self.warrantFlag){
        self.changeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 56, 30, 12)];
        self.changeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 56, 29, 12)];
    }else{
        self.changeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 88, 39, 20)];
        self.changeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 88, 59, 20)];
    }
    
    _changeTitleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedStringFromTable(@"差", @"Equity", nil)];
    _changeTitleLabel.textAlignment = NSTextAlignmentLeft;
    //    _changeTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _changeTitleLabel.font = _font;
    [self addSubview:_changeTitleLabel];
    
    _changeContentLabel.textAlignment = NSTextAlignmentRight;
    //    _changeContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _changeContentLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_changeContentLabel];
}

- (void)addVolPairLabel
{
    if(self.warrantFlag){
        self.volTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 68, 30, 12)];
        self.volContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 68, 29, 12)];
    }else{
        self.volTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 110, 39, 20)];
        self.volContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 110, 59, 20)];
    }
    
    
    _volTitleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedStringFromTable(@"量", @"Equity", nil)];
    _volTitleLabel.textAlignment = NSTextAlignmentLeft;
    //    _volTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _volTitleLabel.font = _font;
    [self addSubview:_volTitleLabel];
    
    _volContentLabel.textAlignment = NSTextAlignmentRight;
    //    _volContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _volContentLabel.textColor = [UIColor blueColor];
    _volContentLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_volContentLabel];
}

- (void)addComparedPricePairLabel
{
    self.comparedPriceTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 66, 39, 20)];
    _comparedPriceTitleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedStringFromTable(@"成", @"Equity", nil)];
    _comparedPriceTitleLabel.textColor = [UIColor colorWithRed:224.0f/255.0f green:100.0f/255.0f blue:16.0f/255.0f alpha:1.000];
    _comparedPriceTitleLabel.textAlignment = NSTextAlignmentLeft;
    //    _comparedPriceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _comparedPriceTitleLabel.font = _font;
    _comparedPriceTitleLabel.hidden = YES;
    [self addSubview:_comparedPriceTitleLabel];
    
    self.comparedPriceContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 66, 59, 20)];
    _comparedPriceContentLabel.textAlignment = NSTextAlignmentRight;
    //    _comparedPriceContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _comparedPriceContentLabel.adjustsFontSizeToFitWidth = YES;
    _comparedPriceContentLabel.hidden = YES;
    [self addSubview:_comparedPriceContentLabel];
}

- (void)addComparedVolPairLabel
{
    self.comparedVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 88, 39, 20)];
    _comparedVolTitleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedStringFromTable(@"量", @"Equity", nil)];
    _comparedVolTitleLabel.textColor = [UIColor colorWithRed:224.0f/255.0f green:100.0f/255.0f blue:16.0f/255.0f alpha:1.000];
    _comparedVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    //    _comparedVolTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _comparedVolTitleLabel.font = _font;
    _comparedVolTitleLabel.hidden = YES;
    [self addSubview:_comparedVolTitleLabel];
    
    self.comparedVolContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 88, 59, 20)];
    _comparedVolContentLabel.textAlignment = NSTextAlignmentRight;
    //    _comparedVolContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _comparedVolContentLabel.adjustsFontSizeToFitWidth = YES;
    _comparedVolContentLabel.hidden = YES;
    [self addSubview:_comparedVolContentLabel];
}

- (void)addNewsPairLabel
{
    self.newsLabel = [[UILabel alloc] init];
    _newsLabel.text = NSLocalizedStringFromTable(@"相關新聞", @"CompanyProfile", @"個股相關新聞");
    _newsLabel.textColor = [UIColor redColor];
    _newsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //    [self addSubview:_newsLabel];
    ////////////////////////////////////////////////////////////////////////////////
    //先暫時把相關新聞藏起來
    _newsLabel.hidden = YES;
    
    ////////////////////////////////////////////////////////////////////////////////
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)setComparedMode:(BOOL)comparedMode
{
    _comparedMode = comparedMode;
    _comparedPriceTitleLabel.hidden = !comparedMode;
    _comparedPriceContentLabel.hidden = !comparedMode;
    _comparedVolTitleLabel.hidden = !comparedMode;
    _comparedVolContentLabel.hidden = !comparedMode;
    
    _bidTitleLabel.hidden = comparedMode;
    _bidContentLabel.hidden = comparedMode;
    _askTitleLabel.hidden = comparedMode;
    _askContentLabel.hidden = comparedMode;
    _changeTitleLabel.hidden = comparedMode;
    _changeContentLabel.hidden = comparedMode;
    if (comparedMode) {
        _lastPriceTitleLabel.textColor = [UIColor colorWithRed:60.0f/255.0f green:150.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        _volTitleLabel.textColor = [UIColor colorWithRed:60.0f/255.0f green:150.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        _volContentLabel.textColor = [UIColor redColor];
        _comparedVolContentLabel.textColor = [UIColor redColor];
    }else{
        _lastPriceTitleLabel.textColor = [UIColor blackColor];
        _volTitleLabel.textColor = [UIColor blackColor];
        _volContentLabel.textColor = [UIColor blueColor];
    }
}

#pragma mark - Autolayout

-(void)setLayout
{
    //雙走勢
    if(!self.warrantFlag){
        if (_comparedMode == YES) {
            [self.lastPriceTitleLabel setFrame:CGRectMake(1, 22, 39, 20)];
            [self.lastPriceContentLabel setFrame:CGRectMake(40, 22, 59, 20)];
            [self.volTitleLabel setFrame:CGRectMake(1, 44, 39, 20)];
            [self.volContentLabel setFrame:CGRectMake(40, 44, 59, 20)];
        }else{
            [self.lastPriceTitleLabel setFrame:CGRectMake(1, 66, 39, 20)];
            [self.lastPriceContentLabel setFrame:CGRectMake(40, 66, 59, 20)];
            [self.volTitleLabel setFrame:CGRectMake(1, 110, 39, 20)];
            [self.volContentLabel setFrame:CGRectMake(40, 110, 59, 20)];
        }
    }
}

#pragma mark - Action

- (void)updateTime:(UInt16) time openTime:(UInt16) openTime
{
    //把tick的分鐘數除以60得小時，餘數即為當下分鐘，例11:54
    NSString *timeString = [NSString stringWithFormat:@"%02d:%02d", (time+openTime)/60, (time+openTime)%60];
    _timeContentLabel.text = timeString;
    _timeContentLabel.textAlignment = NSTextAlignmentRight;
}

- (void)updateTimeNoTick
{
    NSString *timeString = @"----";
    _timeContentLabel.text = timeString;
    _timeContentLabel.textAlignment = NSTextAlignmentRight;
}

- (void)updatePanelWithInfo:(FSEquityDrawCrossHairInfo *) crossHairInfo referencePrice:(NSNumber *) referencePrice comparedReferencePriceNumber:(NSNumber *) comparedReferencePriceNumber
{
    self.bidContentLabel = [self updateContentLabel:_bidContentLabel value:crossHairInfo.bid referencePrice:referencePrice];
    self.askContentLabel = [self updateContentLabel:_askContentLabel value:crossHairInfo.ask referencePrice:referencePrice];
    self.lastPriceContentLabel = [self updateContentLabel:_lastPriceContentLabel value:crossHairInfo.last referencePrice:referencePrice];
    self.changeContentLabel = [self updateContentLabel:_changeContentLabel value:crossHairInfo.change sign:YES];
    self.volContentLabel = [self updateContentLabel:_volContentLabel value:crossHairInfo.vol];
    
    self.comparedPriceContentLabel = [self updateContentLabel:_comparedPriceContentLabel value:crossHairInfo.comparedLast referencePrice:comparedReferencePriceNumber];
    self.comparedVolContentLabel = [self updateContentLabel:_comparedVolContentLabel value:crossHairInfo.comparedVol];
}


- (void)updatePanelWithColorInfo:(FSEquityDrawCrossHairInfo *) crossHairInfo referencePrice:(NSNumber *) referencePrice comparedReferencePriceNumber:(NSNumber *) comparedReferencePriceNumber
{
    self.bidContentLabel = [self updateContentLabel:_bidContentLabel value:crossHairInfo.bid referencePrice:referencePrice];
    self.askContentLabel = [self updateContentLabel:_askContentLabel value:crossHairInfo.ask referencePrice:referencePrice];
    self.lastPriceContentLabel = [self updateContentLabel:_lastPriceContentLabel value:crossHairInfo.last referencePrice:referencePrice];
    self.changeContentLabel = [self updateContentLabel:_changeContentLabel value:crossHairInfo.change sign:YES];
    self.volContentLabel = [self updateContentWithColorLabel:_volContentLabel value:crossHairInfo.vol Color:_lastPriceContentLabel.textColor];
    // [self updateContentLabel:_volContentLabel value:crossHairInfo.vol];
    
    self.comparedPriceContentLabel = [self updateContentLabel:_comparedPriceContentLabel value:crossHairInfo.comparedLast referencePrice:comparedReferencePriceNumber];
    self.comparedVolContentLabel = [self updateContentWithColorLabel:_comparedVolContentLabel value:crossHairInfo.comparedVol Color:_comparedPriceContentLabel.textColor];
    //[self updateContentLabel:_comparedVolContentLabel value:crossHairInfo.comparedVol];
}

/**
 *  更新量的label用
 *
 *  @param contentLabel
 *  @param value
 *
 *  @return
 */
- (UILabel *)updateContentLabel:(UILabel *) contentLabel value:(NSNumber *) value
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    //contentLabel.textColor = [UIColor blueColor];
    if ([value integerValue] == -1) {
        contentLabel.text = @"----";
        contentLabel.textColor = [UIColor blueColor];
    }
    else {
        contentLabel.text = [CodingUtil volumeRoundRownWithDouble:[value doubleValue]];
    }
    return contentLabel;
}

- (UILabel *)updateContentWithColorLabel:(UILabel *) contentLabel value:(NSNumber *) value Color:(UIColor*)color
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    //contentLabel.textColor = [UIColor blueColor];
    if ([value integerValue] == -1) {
        contentLabel.text = @"----";
        contentLabel.textColor = [UIColor blueColor];
    }
    else {
        contentLabel.text = [CodingUtil volumeRoundRownWithDouble:[value doubleValue]];
        contentLabel.textColor = color;
    }
    return contentLabel;
}

/**
 *  更新Chg用
 *
 *  @param contentLabel
 *  @param value
 *  @param sign
 *
 *  @return
 */
- (UILabel *)updateContentLabel:(UILabel *) contentLabel value:(NSNumber *) value sign:(BOOL) sign
{
    return [self updateContentLabel:contentLabel value:value referencePrice:nil sign:YES];
}

/**
 *  更新Bid Ask用
 *
 *  @param contentLabel
 *  @param value
 *  @param referencePrice
 *
 *  @return
 */
- (UILabel *)updateContentLabel:(UILabel *) contentLabel value:(NSNumber *) value referencePrice:(NSNumber *) referencePrice
{
    return [self updateContentLabel:contentLabel value:value referencePrice:referencePrice sign:NO];
}

- (UILabel *)updateContentLabel:(UILabel *) contentLabel value:(NSNumber *) value referencePrice:(NSNumber *) referencePrice sign:(BOOL) sign
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMinimumIntegerDigits:1];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    if (sign) {
        [formatter setPositiveFormat:@"+#,##0.00"];
        [formatter setNegativeFormat:@"-#,##0.00"];
    }
    
    if ([value doubleValue] == 0.00 || value == nil) {
        contentLabel.text = @"----";
        contentLabel.textColor = [UIColor blueColor];
        if ([contentLabel isEqual:_changeContentLabel]) {
            contentLabel.text = @"0.00";
        }
    }
    else {
        contentLabel.text = [formatter stringFromNumber:value];
        if (referencePrice != nil) {
            if ([value compare:referencePrice] == NSOrderedDescending) {
                contentLabel.textColor = [StockConstant PriceUpColor];
            }
            else {
                contentLabel.textColor = [StockConstant PriceDownColor];
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
@end
