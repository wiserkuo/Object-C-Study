//
//  FSEquityDrawButtonSection.m
//  WirtsLeg
//
//  Created by KevinShen on 2014/2/5.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import "FSEquityDrawButtonSection.h"
#import "FSInstantInfoWatchedPortfolio.h"


@interface FSEquityDrawButtonSection (){
    NSMutableArray *layoutConstraints;
}
@end

@implementation FSEquityDrawButtonSection

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        layoutConstraints = [[NSMutableArray alloc]init];
        self.dataIdArray = [[NSMutableArray alloc]init];
        self.categoryArray = [[NSMutableArray alloc]init];
        [self addCompareOtherPortfoioButton];
        [self addSelectComparePortfoioButton];
        [self addFitPriceGraphScopeButton];
        [self addDrawCDPButton];
        [self addDrawAverageValueLineButton];
        [self addAddUserStockButton];
//        [self setLayout];
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

- (void)addCompareOtherPortfoioButton
{
    self.compareOtherPortfoioButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    [self addSubview:_compareOtherPortfoioButton];
    _compareOtherPortfoioButton.frame = CGRectMake(0, 0, 44, 44);
    _compareOtherPortfoioButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_compareOtherPortfoioButton setContentMode:UIViewContentModeScaleAspectFit];
    [_compareOtherPortfoioButton setImage:[UIImage imageNamed:@"tachart_doubleline"] forState:UIControlStateNormal];
    [_compareOtherPortfoioButton addTarget:self action:@selector(compareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)compareBtnClick{
    self.selectComparePortfoioButton.hidden = !self.selectComparePortfoioButton.hidden;
//    [self setLayout];
    [self setNeedsUpdateConstraints];
    [self hideCrossInfoPanel];
    self.compareOtherPortfoioButton.selected = !self.compareOtherPortfoioButton.selected;
    self.fitPriceGraphScopeButton.enabled = !self.compareOtherPortfoioButton.selected;

    _fitPriceGraphScopeButton.selected = NO;
    if ([self.delegate isComparedPortfolioPlotVisible] /*&& ![self.delegate isCDPVisible]*/) {
//        _fitPriceGraphScopeButton.enabled = NO;
        [self.delegate hideComparedPortfolioPlot];
    }
    else {
//        _fitPriceGraphScopeButton.enabled = YES;
        [self.delegate showComparedPortfolioPlot];
        self.drawCDPButton.enabled = YES;
    }
    [self.delegate addComparedPortfolioPlot];
    [self.delegate FitPriceGraphScope];



}
-(void)delayPointFiveSecondToCallLabelize{
    [_selectComparePortfoioLabel setLabelize: NO];
    
}
- (void)addSelectComparePortfoioButton
{
    self.selectComparePortfoioButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    self.selectComparePortfoioLabel = [[MarqueeLabel alloc]initWithFrame:CGRectZero duration:6.0 andFadeLength:0.0f];
    _selectComparePortfoioLabel.marqueeType = 4;
    _selectComparePortfoioLabel.continuousMarqueeExtraBuffer = 30.0f;
    [_selectComparePortfoioLabel setLabelize:YES];
    _selectComparePortfoioLabel.lineBreakMode = NSLineBreakByClipping;
    _selectComparePortfoioLabel.userInteractionEnabled = NO;
    _selectComparePortfoioLabel.textColor = [UIColor whiteColor];
    _selectComparePortfoioLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    _selectComparePortfoioLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    _selectComparePortfoioButton.translatesAutoresizingMaskIntoConstraints = NO;
    _selectComparePortfoioButton.hidden = YES;
    [_selectComparePortfoioButton addTarget:self action:@selector(changeStockBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_selectComparePortfoioButton addSubview:_selectComparePortfoioLabel];
    [self addSubview:_selectComparePortfoioButton];
}

-(void)changeStockBtnClick{
    [self.delegate changeStock];
}

- (void)addFitPriceGraphScopeButton
{
    self.fitPriceGraphScopeButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    _fitPriceGraphScopeButton.translatesAutoresizingMaskIntoConstraints = NO;
    _fitPriceGraphScopeButton.hidden = YES;
    [_fitPriceGraphScopeButton addTarget:self action:@selector(FitPriceGraphScopeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_fitPriceGraphScopeButton setImage:[UIImage imageNamed:@"上下箭頭"] forState:UIControlStateNormal];
    [self addSubview:_fitPriceGraphScopeButton];
}

-(void)FitPriceGraphScopeBtnClick{
    _fitPriceGraphScopeButton.selected = !_fitPriceGraphScopeButton.selected;
    if (_fitPriceGraphScopeButton.selected) {
        _drawCDPButton.enabled = NO;
    }else{
        _drawCDPButton.enabled = YES;
    }

    [self.delegate FitPriceGraphScope];
}


- (void)addDrawCDPButton
{
    self.drawCDPButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    _drawCDPButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_drawCDPButton setTitle:@"CDP" forState:UIControlStateNormal];
    [_drawCDPButton addTarget:self action:@selector(cdpBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_drawCDPButton];
}

-(void)cdpBtnClick{
    self.drawCDPButton.selected = !self.drawCDPButton.selected;
    [self hideCrossInfoPanel];
    if (self.delegate.isCDPVisible) {
        [self.delegate hideCDP];
        _fitPriceGraphScopeButton.enabled = YES;
    }
    else {
        [self.delegate showCDP];
        _fitPriceGraphScopeButton.enabled = NO;
    }
    if (_compareOtherPortfoioButton.selected == YES) {
        _fitPriceGraphScopeButton.enabled = NO;
    }

}

- (void)addDrawAverageValueLineButton
{
    self.drawAverageLineButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    _drawAverageLineButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_drawAverageLineButton setTitle:NSLocalizedStringFromTable(@"均價線", @"Equity", @"") forState:UIControlStateNormal];
    [_drawAverageLineButton addTarget:self action:@selector(AVGLineBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_drawAverageLineButton];
}

-(void)AVGLineBtnClick{
    //如果均線還沒初始化，就初始化並加入
    [self.delegate addAverageValueLine];
    [self hideCrossInfoPanel];
    self.drawAverageLineButton.selected = !self.drawAverageLineButton.selected;
    if (self.delegate.isAverageValueLinesVisible) {
        [self.delegate hideAverageValueLine];
    }
    else {
        [self.delegate showAverageValueLine];
    }
}


-(void)addAddUserStockButton{
    self.addUserStockButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addUserStockButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_addUserStockButton setImage:[UIImage imageNamed:@"BluePlusButton"] forState:UIControlStateNormal];
    
    [_addUserStockButton addTarget:self action:@selector(addStockBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_addUserStockButton];
    _addUserStockButton.hidden = YES;
    
    
}
                                                                  
-(void)addStockBtnClick{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(addStockInUserStock)]) {
        [self.delegate addStockInUserStock];
    }
}
                                                                  


-(void)hideAddUserStockBtn{
    FSInstantInfoWatchedPortfolio * watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    if ([self btnHide:watchPortfolio.portfolioItem->symbol]) {
        _addUserStockButton.hidden = YES;
    }else{
        _addUserStockButton.hidden = NO;
    }
}

-(BOOL)btnHide:(NSString *)symbol{
    for (int i=0; i<[_dataIdArray count]; i++) {
        if ([[_dataIdArray objectAtIndex:i] isEqual:symbol]) {
            return YES;
        }
    }
    return NO;
}

-(void)notifyDataArrive:(NSMutableArray *)array{
    _dataIdArray = [array objectAtIndex:1];
    
}

-(void)updateConstraints
{
    [super updateConstraints];
    [self removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
    
    [_selectComparePortfoioLabel setLabelize:YES];
    NSDictionary *scrollViewDictionary = NSDictionaryOfVariableBindings(_compareOtherPortfoioButton, _selectComparePortfoioButton, _drawCDPButton, _drawAverageLineButton,_addUserStockButton,_fitPriceGraphScopeButton);
    
    /**
     *  排按鈕
     */
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_compareOtherPortfoioButton(44)]" options:0 metrics:nil views:scrollViewDictionary]];
    
    NSMutableString *format = [NSMutableString stringWithFormat:@"H:|[_compareOtherPortfoioButton(44)]"];
    if (!_selectComparePortfoioButton.hidden) {
        [format appendString:@"[_selectComparePortfoioButton(100)]"];
        
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_selectComparePortfoioLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_selectComparePortfoioButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:3]];
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_selectComparePortfoioLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_selectComparePortfoioButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_selectComparePortfoioLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_selectComparePortfoioButton attribute:NSLayoutAttributeWidth multiplier:1 constant:-10]];
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_selectComparePortfoioLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_selectComparePortfoioButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3]];
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_selectComparePortfoioLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_selectComparePortfoioButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        
    }
    PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    if (portfolioItem->identCode[0] == 'T' && portfolioItem->identCode[1] == 'W') {
        _fitPriceGraphScopeButton.hidden = NO;
        [format appendString:@"[_fitPriceGraphScopeButton(44)][_drawCDPButton(50)][_drawAverageLineButton(60)][_addUserStockButton(50)]|"];
    }else{
        [format appendString:@"[_drawCDPButton(50)][_drawAverageLineButton(60)][_addUserStockButton(50)]|"];
    }
    
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatAlignAllCenterY metrics:nil views:scrollViewDictionary]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_selectComparePortfoioButton(44)]" options:0 metrics:nil views:scrollViewDictionary]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_fitPriceGraphScopeButton(44)]" options:0 metrics:nil views:scrollViewDictionary]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_drawCDPButton(44)]" options:0 metrics:nil views:scrollViewDictionary]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_drawAverageLineButton(44)]" options:0 metrics:nil views:scrollViewDictionary]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_addUserStockButton(44)]" options:0 metrics:nil views:scrollViewDictionary]];

//    for (NSString *key in scrollViewDictionary) {
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[%@(44)]", key] options:0 metrics:nil views:scrollViewDictionary]];
//    }

    if (!_selectComparePortfoioButton.hidden) {
        [self performSelector:@selector(delayPointFiveSecondToCallLabelize) withObject:nil afterDelay:0.5];
    }
    [self addConstraints:layoutConstraints];

}
-(void)hideCrossInfoPanel{
    [self.delegate hideCrossHair];
    [self.delegate hideCrossInfoPanel];
}
@end
