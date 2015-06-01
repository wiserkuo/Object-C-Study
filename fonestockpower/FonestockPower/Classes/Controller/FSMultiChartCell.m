//
//  FSMultiChartCell.m
//  Bullseye
//
//  Created by Shen Kevin on 13/8/5.
//
//

#import "FSMultiChartCell.h"
#import "Snapshot.h"

@implementation FSMultiChartCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self drawCellBorder];
        [self addPortfolioNameLabel];
        [self addCurrentPriceLabel];
        [self addRateOfChangelabel];
        [self addChartImageView];
        [self setAutoLayout];
//        [self configureHost];
//        [self configureGraph];
//        [self configureAxes];
//        [self.contentView setNeedsUpdateConstraints];
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

#pragma mark UIView

- (void)drawCellBorder
{
    self.layer.borderColor = [[UIColor blueColor] CGColor];
    self.layer.borderWidth = 1.0;
}

- (void)addPortfolioNameLabel
{
    self.portfolioNameLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _portfolioNameLabel.backgroundColor = [UIColor whiteColor];
    _portfolioNameLabel.textColor = [UIColor blackColor];
    _portfolioNameLabel.textAlignment = NSTextAlignmentLeft;
    _portfolioNameLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_portfolioNameLabel];
}

- (void)addCurrentPriceLabel
{
    self.currentPriceLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _currentPriceLabel.backgroundColor = [UIColor whiteColor];
    _currentPriceLabel.textColor = [UIColor blueColor];
    _currentPriceLabel.textAlignment = NSTextAlignmentLeft;
    _currentPriceLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_currentPriceLabel];
}

- (void)addRateOfChangelabel
{
    self.rateOfChangeLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _rateOfChangeLabel.backgroundColor = [UIColor whiteColor];
    _rateOfChangeLabel.textAlignment = NSTextAlignmentRight;
    _rateOfChangeLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_rateOfChangeLabel];
}

- (void)addChartImageView
{
    self.chartImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_chartImageView];
}

#pragma mark Layout

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    CGRect portfolioNameLabelArea, remainerArea;
//    CGRectDivide(self.contentView.bounds, &portfolioNameLabelArea, &remainerArea, 20, CGRectMinYEdge);
//    _portfolioNameLabel.frame = portfolioNameLabelArea;
//    
//    CGRect priceAndChangeLabelArea, chartArea;
//    CGRectDivide(remainerArea, &priceAndChangeLabelArea, &chartArea, 20, CGRectMinYEdge);
//    
//    CGRect priceLabelArea, changeLabelArea;
//    CGRectDivide(priceAndChangeLabelArea, &priceLabelArea, &changeLabelArea, 48, CGRectMinXEdge);
//    _currentPriceLabel.frame = priceLabelArea;
//    _rateOfChangeLabel.frame = changeLabelArea;
//    
//    _chartImageView.frame = chartArea;
//}

//#pragma mark Core Plot
//
//-(void)configureHost {
//    self.hostView = [[CPTGraphHostingView alloc] initWithFrame:self.contentView.bounds];
//    self.hostView.allowPinchScaling = YES;
//    [self.contentView addSubview:_hostView];
//}
//
//-(void)configureGraph {
//    // 1 - Create the graph
//    self.hostView.hostedGraph = [[CPTXYGraph alloc] initWithFrame:self.contentView.bounds];
//    //套用白色背景
//    [self.hostView.hostedGraph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
//    //讓xy座標部分可以填滿整個hostView
//    self.hostView.hostedGraph.paddingTop = 0.0f;
//    self.hostView.hostedGraph.paddingBottom = 0.0f;
//    self.hostView.hostedGraph.paddingLeft = 0.0f;
//    self.hostView.hostedGraph.paddingRight = 0.0f;
//    
//    // 2 - Set graph title
//    //    NSString *title = @"Portfolio Prices: April 2012";
//    //    graph.title = title;
//    
//    // 3 - Create and set text style
//    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
//    titleStyle.color = [CPTColor blackColor];
//    titleStyle.fontName = @"Helvetica-Bold";
//    titleStyle.fontSize = 16.0f;
//    self.hostView.hostedGraph.titleTextStyle = titleStyle;
//    self.hostView.hostedGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
//    self.hostView.hostedGraph.titleDisplacement = CGPointMake(0.0f, 10.0f);
//    
//    // 4 - Set padding for plot area
//    [self.hostView.hostedGraph.plotAreaFrame setPaddingLeft:0.0f];
//    [self.hostView.hostedGraph.plotAreaFrame setPaddingRight:0.0f];
//    [self.hostView.hostedGraph.plotAreaFrame setPaddingTop:0.0f];
//    [self.hostView.hostedGraph.plotAreaFrame setPaddingBottom:0.0f];
//    [[self.hostView.hostedGraph plotAreaFrame] setBorderLineStyle:nil];
//    
//    
//    // 5 - Enable user interactions for plot space
//    //    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
//    //    plotSpace.allowsUserInteraction = YES;
//}
//
//-(void)configureAxes {
//    /*
//     讓Core Plot不去計算坐標軸數字，提高效能
//     */
//    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
//    
//    CPTAxis *xAxis = axisSet.xAxis;
//    xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
//    CPTAxis *yAxis = axisSet.yAxis;
//    yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
//}
//
//- (void)custmizeGraphColor:(EquitySnapshotDecompressed *) snapshot
//{
//    CPTGraph *graph = self.hostView.hostedGraph;
//    if (graph != nil) {
//        CPTScatterPlot *plot = (CPTScatterPlot *)[graph plotWithIdentifier:@"CPDTickerSymbolPortfolio"];
//        CPTMutableLineStyle *portfolioLineStyle = [plot.dataLineStyle mutableCopy];
//        //拿到漲幅的數字
//        double percentageOfChange = [self getRateOfChageFromSnapshot:snapshot];
//        
//        //設定線的顏色： 漲:red 跌:green 平:blue
//        if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
//        {
//            portfolioLineStyle.lineColor = [self colorWithPercentageOfChange:percentageOfChange];
//        }
//        else
//        {
//            portfolioLineStyle.lineColor = [CPTColor colorWithCGColor:[UIColor blackColor].CGColor];
//        }
//        [plot setDataLineStyle:portfolioLineStyle];
//        
//        //設置漸層
//        plot.areaFill = [self gradientFillWithPercentageOfChange:percentageOfChange];
//        //漸層的起點位置，設了漸層才會出來
//        plot.areaBaseValue= CPTDecimalFromString(@"1.75");
//    }
//}
//
///**
// *  根據百分比決定回傳的「線」顏色，漲:red 跌:green 平:blue
// *
// *  @param percentageOfChange 漲幅百分比
// *
// *  @return Core Plot的顏色物件
// */
//- (CPTColor *)colorWithPercentageOfChange:(double) percentageOfChange
//{
//    if (percentageOfChange < 0) return [CPTColor colorWithCGColor:[StockConstant PriceDownColor].CGColor];
//    else if (percentageOfChange > 0) return [CPTColor colorWithCGColor:[StockConstant PriceUpColor].CGColor];
//    else    return [CPTColor colorWithCGColor:[UIColor blueColor].CGColor];
//}
//
///**
// *  根據百分比決定回傳的「漸層」顏色，漲:red 跌:green 平:blue
// *
// *  @param percentageOfChange 漲幅百分比
// *
// *  @return Core Plot的顏色填充物件
// */
//- (CPTFill *)gradientFillWithPercentageOfChange:(double) percentageOfChange
//{
//    CPTColor *topColor = nil;
//    CPTColor *bottomColor = nil;
//    if (percentageOfChange < 0) {
//        topColor = [CPTColor colorWithComponentRed:35.0/255.0 green:202.0/255.0 blue:44.0/255.0 alpha:1];
//        bottomColor = [CPTColor colorWithComponentRed:182.0/255.0 green:234.0/255.0 blue:180.0/255.0 alpha:1];
//    }
//    else if(percentageOfChange > 0) {
//        topColor = [CPTColor colorWithComponentRed:214.0/255.0 green:124.0/255.0 blue:124.0/255.0 alpha:1];
//        bottomColor = [CPTColor colorWithComponentRed:212.0/255.0 green:26.0/255.0 blue:23.0/255.0 alpha:1];
//    }
//    else {
//        topColor = [CPTColor colorWithComponentRed:181.0/255.0 green:131.0/255.0 blue:221.0/255.0 alpha:1];
//        bottomColor = [CPTColor colorWithComponentRed:17.0/255.0 green:44.0/255.0 blue:234.0/255.0 alpha:1];
//    }
//    
//    CPTGradient * areaGradient = [CPTGradient gradientWithBeginningColor:topColor
//                                                             endingColor:bottomColor];
//    areaGradient.angle = 0.0f;
//    return [CPTFill fillWithGradient:areaGradient];
//}
//
//- (void)reloadGraph
//{
//    if (_hostView.hostedGraph != nil) {
//        [_hostView.hostedGraph reloadDataIfNeeded];
//        [_hostView.hostedGraph.defaultPlotSpace scaleToFitPlots:[_hostView.hostedGraph allPlots]];
//    }
//}

#pragma mark Customize

- (void)custmizeCellAccordingToPorfolioItem:(PortfolioItem *) portfolioItem
{
    if (portfolioItem) {
        
        //顯示商品名稱
        _portfolioNameLabel.text = [portfolioItem getNamedAccordingToMarket];
        
        EquitySnapshotDecompressed *snapshot = [[[FSDataModelProc sharedInstance]portfolioTickBank] getSnapshot:portfolioItem->commodityNo];	// return equitySnapshotDecompressed or return indexSnapshotDecompressed;
        if (snapshot) {
            //顯示last price
            [self custmizeCurrentPriceLabel:snapshot portfolioItem:portfolioItem];
            //顯示漲幅
            [self custmizeRateOfChangeLabel:snapshot];
            //依據漲跌幅來調整圖的顏色
//            [self custmizeGraphColor:snapshot];
        }
    }
}

- (void)custmizeCurrentPriceLabel:(EquitySnapshotDecompressed *) snapshot portfolioItem:(PortfolioItem *) portfolioItem
{
    if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
    {
        _currentPriceLabel.textColor = [UIColor blueColor]; //[ValueUtil colorOfPrice:snapshot.currentPrice refPrice:snapshot.referencePrice baseColor:[UIColor blackColor]];
        _currentPriceLabel.text = [CodingUtil ConvertPriceValueToString:snapshot.currentPrice withIdSymbol:[portfolioItem getIdentCodeSymbol]];
        _currentPriceLabel.backgroundColor = [self setPriceLabelBackGroundColorWithPrice:snapshot.currentPrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice];
        
    }
    else if (snapshot.currentPrice == 0 && snapshot.referencePrice != 0)
    {
        _currentPriceLabel.textColor = [UIColor blueColor];
        _currentPriceLabel.text = [CodingUtil ConvertPriceValueToString:snapshot.referencePrice withIdSymbol:[portfolioItem getIdentCodeSymbol]];
        _currentPriceLabel.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        _currentPriceLabel.textColor = [UIColor blackColor];
        _currentPriceLabel.text = @"----";
        _currentPriceLabel.backgroundColor = [UIColor whiteColor];
    }
}

/**
 *  (現價 - 參考價) / 參考價 * 100 = 漲幅
 *
 *  @param snapshot 從server抓下來的snapshot
 *
 *  @return 漲幅百分比數字double
 */
- (double)getRateOfChageFromSnapshot:(EquitySnapshotDecompressed *) snapshot
{
    return (snapshot.currentPrice - snapshot.referencePrice)/snapshot.referencePrice*100;
}

- (void)custmizeRateOfChangeLabel:(EquitySnapshotDecompressed *) snapshot
{
    if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
    {
        double percentageOfChange = [self getRateOfChageFromSnapshot:snapshot];
        
        if (percentageOfChange < 0){
            _rateOfChangeLabel.textColor = [StockConstant PriceDownColor];
            _rateOfChangeLabel.text = [NSString stringWithFormat:@"%.2lf%%",percentageOfChange];
        }
        else if (percentageOfChange > 0){
            _rateOfChangeLabel.textColor = [StockConstant PriceUpColor];
            _rateOfChangeLabel.text = [NSString stringWithFormat:@"+%.2lf%%",percentageOfChange];
        }
        else
            _rateOfChangeLabel.textColor = [UIColor blackColor];
        
        
        _rateOfChangeLabel.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        _rateOfChangeLabel.textColor = [UIColor blackColor];
        _rateOfChangeLabel.text = @"----";
        _rateOfChangeLabel.backgroundColor = [UIColor whiteColor];
    }
}

- (UIColor *)setPriceLabelBackGroundColorWithPrice:(double)price ceilingPrice:(double)ceiling floorPrice:(double)floor {
	
	if (price == ceiling)
	{
		
        return [StockConstant PriceUpColor];
    }
    else if (price == floor) {
		
        return [StockConstant PriceDownColor];
    }
    else 
	{
		
        return [UIColor whiteColor];
    }
	
}

#pragma mark Autolayout

- (void)setAutoLayout
{
//    [super updateConstraints];
    _portfolioNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _currentPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _rateOfChangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _chartImageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_portfolioNameLabel, _currentPriceLabel, _rateOfChangeLabel, _chartImageView);
    
    [self.contentView removeConstraints:self.contentView.constraints];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_portfolioNameLabel(20)][_currentPriceLabel(20)][_chartImageView]|" options:0 metrics:nil views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_portfolioNameLabel]|" options:0 metrics:nil views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_currentPriceLabel(==_rateOfChangeLabel)][_rateOfChangeLabel]-2-|" options:0 metrics:nil views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_chartImageView]|" options:0 metrics:nil views:viewDictionary]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_currentPriceLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_rateOfChangeLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
}

@end
