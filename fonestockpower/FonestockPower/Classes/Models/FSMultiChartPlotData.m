//
//  FSMultiChartCellDataSource.m
//  Bullseye
//
//  Created by Shen Kevin on 13/8/9.
//
//

#import "FSMultiChartPlotData.h"
#import "MarketInfo.h"
#import "Snapshot.h"

@interface FSMultiChartPlotData ()

@property (nonatomic) UInt16 chartOpenTime;
@property (nonatomic) UInt16 chartCloseTime;
@property (nonatomic) UInt16 chartBreakTime;
@property (nonatomic) UInt16 chartReopenTime;
@property (nonatomic) UInt16 totalTime;
@property (nonatomic, assign) BOOL isWatchingData;
@property (nonatomic, assign) BOOL isReferencePriceLineDrawn;
@property (nonatomic, strong) NSOperationQueue *tickHandlerQueue;
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) NSMutableArray *cachedTickNoBox;

@end

@implementation FSMultiChartPlotData


- (id)init
{
    self = [super init];
    if (self) {
        self.tickHandlerQueue = [[NSOperationQueue alloc] init];
        [self configureHost];
        [self configureGraph];
        [self configurePlots];
        [self configureAxes];
        [self reloadGraph];
        self.cachedTickNoBox = [NSMutableArray array];
    }
    return self;
}

- (id)initWithPortfolioItem:(PortfolioItem*)aPortfolioItem {
    if ((self = [super init])) {
        _portfolioItem = aPortfolioItem;
        self.tickHandlerQueue = [[NSOperationQueue alloc] init];
        [self configureHost];
        [self configureGraph];
        [self configurePlots];
        [self configureAxes];
        [self reloadGraph];
        self.cachedTickNoBox = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
}

#pragma mark - Notification

- (BOOL)startWatch
{
    if (_portfolioItem != nil && _isWatchingData == NO) {
        NSString *equity = [_portfolioItem getIdentCodeSymbol];
		if(equity) {
            //如果不是自選股就要加入watchlist
            if ([[[FSDataModelProc sharedInstance]portfolioData] findItemByIdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]] == nil) {
                [[[FSDataModelProc sharedInstance]portfolioTickBank] watchTarget:self ForEquity:equity GetDiscreteTick:YES];

            }
            else {
                [[[FSDataModelProc sharedInstance]portfolioTickBank] watchTarget:self ForEquity:equity GetDiscreteTick:YES];
            }
            
            _isWatchingData = YES;
        }
        return YES;
    }
    
    return NO;
}

- (void)stopWatch
{
    if (_isWatchingData) {
        if ([[[FSDataModelProc sharedInstance]portfolioData] findItemByIdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]] == nil) {
            [[[FSDataModelProc sharedInstance]portfolioTickBank] stopWatch:self ForEquity:[_portfolioItem getIdentCodeSymbol] discreteTick:YES];
//            [[[FSDataModelProc sharedInstance]portfolioData] removeWatchListItemByIdentSymbolArray];
        }
        else {
            [[[FSDataModelProc sharedInstance]portfolioTickBank] stopWatch:self ForEquity:[_portfolioItem getIdentCodeSymbol]];
        }
        _isWatchingData = NO;
    }
}


- (void) notifyDataArrive:(NSObject <TickDataSourceProtocol> *)dataSource {
	if([dataSource isKindOfClass:[EquityTick class]]) {
        if ([[dataSource getIdenCodeSymbol] isEqualToString:[_portfolioItem getIdentCodeSymbol]]) {
            self.dataSource = dataSource;
           // [dataSource lock];
            [self updateMarketTime];
            if ([dataSource.tickNoBox count] > 0) {
                
                //調整X軸可視範圍
                [self configureXRange:_hostView.hostedGraph.defaultPlotSpace];
                //調整Y軸可視範圍
                //            [self configureYRange:_hostView.hostedGraph.defaultPlotSpace];
                [self scalePriceGraphToFitPrice:((EquityTick *)dataSource).snapshot];
//                [self reloadGraph];
            }

            
            if (_portfolioItem != nil) {
                EquitySnapshotDecompressed *snapshot = [[[FSDataModelProc sharedInstance]portfolioTickBank] getSnapshot:_portfolioItem->commodityNo];	// return equitySnapshotDecompressed or return indexSnapshotDecompressed;
                if (snapshot) {
                    [self custmizeGraphColor:snapshot];
                }
                if (!_isReferencePriceLineDrawn) {
                    _isReferencePriceLineDrawn = YES;
                    [[_hostView.hostedGraph plotWithIdentifier:@"CPDTickerReferencePrice"] reloadData];
                }
                [[_hostView.hostedGraph plotWithIdentifier:@"CPDTickerSymbolPortfolio"] reloadData];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(multiChartPlotData:dataSource:)])
            {
                [self.delegate multiChartPlotData:self dataSource:dataSource];
            }
           // [dataSource unlock];
        }
    }
}

//#pragma mark - Tick

//- (void)insertNewTickIntoPlot:(NSObject <TickDataSourceProtocol> *) dataSource {
////    //如果沒有開盤第一支tick，自己加進去
////    NSPredicate *openTickPredicate = [NSPredicate predicateWithBlock:^BOOL(NSNumber *evaluatedObject, NSDictionary *bindings) {
////        if([evaluatedObject compare:@(0)] == NSOrderedSame)
////        {
////            return YES;
////        }
////        else {
////            return NO;
////        }
////    }];
////    NSArray *filteredArray = [dataSource.tickNoBox filteredArrayUsingPredicate:openTickPredicate];
////    if ([filteredArray count] == 0) {
////        [[_hostView.hostedGraph plotWithIdentifier:@"CPDTickerSymbolPortfolio"] insertDataAtIndex:0 numberOfRecords:1];
////    }
////    
////    if ([self isMarketClosed:((EquityTick*)_dataSource).snapshot.timeOfLastTick marketId:_portfolioItem->market_id]) {
////        [[_hostView.hostedGraph plotWithIdentifier:@"CPDTickerSymbolPortfolio"] insertDataAtIndex:[self numberOfRecordsForPlot:[_hostView.hostedGraph plotWithIdentifier:@"CPDTickerSymbolPortfolio"]]-1 numberOfRecords:1];
////    }
//   
//    //tickNoBox減掉cachedTickNoBox就是多出來的tick，insert到plot中
//    NSMutableArray *copiedTickNoBox = [dataSource.tickNoBox mutableCopy];
//    [copiedTickNoBox removeObjectsInArray:_cachedTickNoBox];
//    self.cachedTickNoBox = dataSource.tickNoBox;
//    for (NSUInteger counter=0; counter < [copiedTickNoBox count] ; counter++) {
//        [[_hostView.hostedGraph plotWithIdentifier:@"CPDTickerSymbolPortfolio"] insertDataAtIndex:counter numberOfRecords:1];
//
////        [[_hostView.hostedGraph plotWithIdentifier:@"CPDTickerSymbolPortfolio"] insertDataAtIndex:[_hostView.hostedGraph plotWithIdentifier:@"CPDTickerSymbolPortfolio"].cachedDataCount numberOfRecords:1];
//    }
//}

#pragma mark - Market Time Related

- (BOOL)isBreakTime:(UInt16)time
{
    if (_chartBreakTime == 0)
        return FALSE;
    else
        return time > _chartBreakTime && time < _chartReopenTime;
}

- (void)updateMarketTime {
	
    UInt8 marketId = _portfolioItem != nil ? _portfolioItem->market_id : 1;
	
    MarketInfoItem *market = [[[FSDataModelProc sharedInstance]marketInfo] getMarketInfo:marketId];
    if (market == nil) return;
	
    _chartOpenTime = market->startTime_1;
	
    if (market->startTime_2 == 0 && market->endTime_2 == 0) {
        _chartBreakTime = 0;
        _chartReopenTime = 0;
        _chartCloseTime = market->endTime_1;
        self.totalTime = _chartCloseTime - _chartOpenTime + 1;
    }
    else {
        _chartBreakTime = market->endTime_1;
        _chartReopenTime = market->startTime_2;
        _chartCloseTime = market->endTime_2;
        self.totalTime = (_chartBreakTime - _chartOpenTime + 1) + (_chartCloseTime - _chartReopenTime + 1);
    }

}

- (BOOL)isMarketClosed:(UInt16) time marketId:(UInt16) marketId
{
    return [[[FSDataModelProc sharedInstance]marketInfo] isTickTime:time EqualToMarketClosedTime:marketId];
}

#pragma mark - CPTPlotDataSource methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    //參考價只有兩個點，一個開頭一個結束，Y軸的值都是參考價
    if ([(NSString *)plot.identifier isEqualToString:@"CPDTickerReferencePrice"]) {
        return 2;
    }
    else if ([(NSString *)plot.identifier isEqualToString:@"CPDTickerSymbolPortfolio"]) {
        return [_dataSource.tickNoBox count]+1;
    }

    return 0;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    NSNumber *num = nil;
    if ([(NSString *)plot.identifier isEqualToString:@"CPDTickerReferencePrice"]) {
        EquityTick *watchedEquity = (EquityTick*)_dataSource;
        if (fieldEnum == CPTScatterPlotFieldX) {
            num = [NSNumber numberWithUnsignedInteger:index==0 ? index : _totalTime];
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
            num = [NSNumber numberWithDouble:watchedEquity.snapshot.referencePrice];
        }
    }
    else if ([(NSString *)plot.identifier isEqualToString:@"CPDTickerSymbolPortfolio"]) {
        UInt16 tTime = -1;
        double tPrice = -1;
        if (index==0) {
            EquityTick *watchedEquity = (EquityTick*)_dataSource;
            if (fieldEnum == CPTScatterPlotFieldX) {
                num = [NSNumber numberWithUnsignedInt:2];
            }
            else if (fieldEnum == CPTScatterPlotFieldY) {
                num = [NSNumber numberWithDouble:watchedEquity.snapshot.referencePrice];
                
            }
        }else{
            [_dataSource getTimePrice:&tTime Price:&tPrice Sequence:(UInt32)[_dataSource.tickNoBox[index-1] unsignedIntValue]];
            if (fieldEnum == CPTScatterPlotFieldX) {
                if (_chartBreakTime!=0 && tTime>=(_chartReopenTime-_chartOpenTime)) {
                    num = [NSNumber numberWithUnsignedInt:tTime+2-(_chartReopenTime-_chartBreakTime)];
                }else{
                    num = [NSNumber numberWithUnsignedInt:tTime+2];
                }
            }
            else if (fieldEnum == CPTScatterPlotFieldY) {
                num = [NSNumber numberWithDouble:tPrice];
                
            }
        }
        
        
    }
 
    return num;
}

#pragma mark Core Plot

-(void)configureHost {
    self.hostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, 100, 130)];
    self.hostView.allowPinchScaling = YES;
}

-(void)configureGraph {
    // 1 - Create the graph
    self.hostView.hostedGraph = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, 100, 130)];
    //套用白色背景
    [self.hostView.hostedGraph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    //讓xy座標部分可以填滿整個hostView
    self.hostView.hostedGraph.paddingTop = 0.0f;
    self.hostView.hostedGraph.paddingBottom = 0.0f;
    self.hostView.hostedGraph.paddingLeft = 0.0f;
    self.hostView.hostedGraph.paddingRight = 0.0f;
    
    // 2 - Set graph title
    //    NSString *title = @"Portfolio Prices: April 2012";
    //    graph.title = title;
    
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor blackColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    self.hostView.hostedGraph.titleTextStyle = titleStyle;
    self.hostView.hostedGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    self.hostView.hostedGraph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    
    // 4 - Set padding for plot area
    [self.hostView.hostedGraph.plotAreaFrame setPaddingLeft:0.0f];
    [self.hostView.hostedGraph.plotAreaFrame setPaddingRight:0.0f];
    [self.hostView.hostedGraph.plotAreaFrame setPaddingTop:0.0f];
    [self.hostView.hostedGraph.plotAreaFrame setPaddingBottom:0.0f];
    [[self.hostView.hostedGraph plotAreaFrame] setBorderLineStyle:nil];
    
    
    // 5 - Enable user interactions for plot space
    //    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    //    plotSpace.allowsUserInteraction = YES;
}

-(void)configureAxes {
    /*
     讓Core Plot不去計算坐標軸數字，提高效能
     */
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    CPTAxis *xAxis = axisSet.xAxis;
    xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    CPTAxis *yAxis = axisSet.yAxis;
    yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
}

- (void)configureXRange:(CPTPlotSpace *) plotSpace {
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) plotSpace;
    //從0開始到整個市場交易的時間
    xyPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(_totalTime+3)];
}

- (void)configureYRange:(CPTPlotSpace *) plotSpace {
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) plotSpace;
    EquityTick *watchedEquity = (EquityTick*)_dataSource;
    //有參考價，可以設定y軸的上下RANGE
    if (watchedEquity.snapshot.referencePrice > 0) {
        //漲停，指數商品的ceilingPrice跟floorPrice都是0，所以自己算
        double limitUp = watchedEquity.snapshot.ceilingPrice != 0 ? watchedEquity.snapshot.ceilingPrice : watchedEquity.snapshot.referencePrice*1.07;
        //跌停，指數商品的ceilingPrice跟floorPrice都是0，所以自己算
        double limitDown = watchedEquity.snapshot.floorPrice != 0 ? watchedEquity.snapshot.floorPrice : watchedEquity.snapshot.referencePrice*0.93;
        xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(limitDown) length:CPTDecimalFromFloat(limitUp-limitDown)];
        
        /*新上市股票沒有漲跌停限制*/
        //處理超過跌停
        if (watchedEquity.snapshot.currentPrice < limitDown) {
            xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(watchedEquity.snapshot.currentPrice) length:CPTDecimalFromFloat(limitUp-watchedEquity.snapshot.currentPrice)];
        }
        //處理超過漲停
        if (watchedEquity.snapshot.currentPrice > limitUp) {
            xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(limitDown) length:CPTDecimalFromFloat(watchedEquity.snapshot.currentPrice-limitDown)];
        }
    }
}

- (void)scalePriceGraphToFitPrice:(EquitySnapshotDecompressed *) snapshot
{
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    xyPlotSpace.globalYRange = nil;
    
    //有參考價，可以設定y軸的上下RANGE
    if (snapshot.referencePrice > 0) {
        
        //算出最高最低價格與參考價相差的比率
        double increasePercentage = fabs((snapshot.highestPrice - snapshot.referencePrice)/snapshot.referencePrice);
        double decreasePercentage = fabs((snapshot.lowestPrice - snapshot.referencePrice)/snapshot.referencePrice);
        
        CPTMutableTextStyle *normalStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        normalStyle.color = [CPTColor blueColor];
        
        /**
         *  區間預設先以上下各1%來看，如果漲幅或跌幅超過1%，就要scale到該大小。而相對應的另一方向，也要scale到相同大小。例如漲幅5%，那麼上下就各5%的空間。
         在價格圖裡要顯示五個價格標示：
         */
        double minY = 0;
        double maxY = 0;
        
        if (increasePercentage >= decreasePercentage && increasePercentage > 0.01) {
            minY = snapshot.referencePrice*(1-increasePercentage);
            maxY = snapshot.highestPrice;
        }
        else if (increasePercentage < decreasePercentage && decreasePercentage > 0.01) {
            minY = snapshot.lowestPrice;
            maxY = snapshot.referencePrice*(1+decreasePercentage);
        }
        else {
            minY = snapshot.referencePrice*0.99;
            maxY = snapshot.referencePrice*1.01;
        }
        /*
         設定價圖表的上下區間
         記得先改globalRange再改yRange，因為CorePlot會把新設定的yRange限制在globalRange內
         */
        xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minY) length:CPTDecimalFromFloat(maxY - minY)];
        //把globalYRange設為yRange可以防止scroll
        //設置y軸座標的可視範圍
        CPTMutablePlotRange *yRange = [xyPlotSpace.yRange mutableCopy];
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
        xyPlotSpace.yRange = yRange;
        xyPlotSpace.globalYRange = xyPlotSpace.yRange;
    }
}

- (void)custmizeGraphColor:(EquitySnapshotDecompressed *) snapshot
{
    if (snapshot == nil) {
        return;
    }
    NSAssert([snapshot isKindOfClass:[EquitySnapshotDecompressed class]], @"Instance type is not EquitySnapshotDecompressed");
    
    CPTGraph *graph = self.hostView.hostedGraph;
    if (graph != nil) {
        CPTScatterPlot *plot = (CPTScatterPlot *)[graph plotWithIdentifier:@"CPDTickerSymbolPortfolio"];
        CPTMutableLineStyle *portfolioLineStyle = [plot.dataLineStyle mutableCopy];
        //拿到漲幅的數字
        double percentageOfChange = [self getRateOfChageFromSnapshot:snapshot];
        
        //設定線的顏色： 漲:red 跌:green 平:blue
        if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
        {
            portfolioLineStyle.lineColor = [self colorWithPercentageOfChange:percentageOfChange];
        }
        else
        {
            portfolioLineStyle.lineColor = [CPTColor colorWithCGColor:[UIColor blackColor].CGColor];
        }
        [plot setDataLineStyle:portfolioLineStyle];
        
        //設置漸層
        plot.areaFill = [self gradientFillWithPercentageOfChange:percentageOfChange];
        //漸層的起點位置，設了漸層才會出來，通常是從yRange的起點開始畫就好
        CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
        plot.areaBaseValue = xyPlotSpace.yRange.location;
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

/**
 *  根據百分比決定回傳的「線」顏色，漲:red 跌:green 平:blue
 *
 *  @param percentageOfChange 漲幅百分比
 *
 *  @return Core Plot的顏色物件
 */
- (CPTColor *)colorWithPercentageOfChange:(double) percentageOfChange
{
    if (percentageOfChange < 0) return [CPTColor colorWithCGColor:[StockConstant PriceDownColor].CGColor];
    else if (percentageOfChange > 0) return [CPTColor colorWithCGColor:[StockConstant PriceUpColor].CGColor];
    else    return [CPTColor colorWithCGColor:[UIColor blueColor].CGColor];
}

/**
 *  根據百分比決定回傳的「漸層」顏色，漲:red 跌:green 平:blue
 *
 *  @param percentageOfChange 漲幅百分比
 *
 *  @return Core Plot的顏色填充物件
 */
- (CPTFill *)gradientFillWithPercentageOfChange:(double) percentageOfChange
{
    CPTColor *topColor = nil;
    CPTColor *bottomColor = nil;
    
    if (percentageOfChange < 0) {
        topColor = [StockConstant priceDownGradientTopColor];
        bottomColor = [StockConstant priceDownGradientBottomColor];
    }
    else if(percentageOfChange > 0) {
        topColor = [StockConstant priceUpGradientTopColor];
        bottomColor = [StockConstant priceUpGradientBottomColor];
    }
    else {
        topColor = [CPTColor colorWithComponentRed:181.0/255.0 green:131.0/255.0 blue:221.0/255.0 alpha:1];
        bottomColor = [CPTColor colorWithComponentRed:17.0/255.0 green:44.0/255.0 blue:234.0/255.0 alpha:1];
    }
    
    CPTGradient * areaGradient = [CPTGradient gradientWithBeginningColor:topColor
                                                             endingColor:bottomColor];
    areaGradient.angle = -90.0f;
    return [CPTFill fillWithGradient:areaGradient];
}

- (void)reloadGraph
{
    if (_hostView.hostedGraph != nil) {
        [_hostView.hostedGraph reloadData];
//        [_hostView.hostedGraph.defaultPlotSpace scaleToFitPlots:[_hostView.hostedGraph allPlots]];
    }
}


-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // 2 - Create the plot
    //走勢的線
    CPTScatterPlot *portfolioPlot = [[CPTScatterPlot alloc] init];
    portfolioPlot.identifier = @"CPDTickerSymbolPortfolio";
    CPTColor *portfolioColor = [CPTColor redColor];
    portfolioPlot.dataSource = self;
    [graph addPlot:portfolioPlot toPlotSpace:plotSpace];
    
    //參考價的線，就是一條直線固定在參考價上
    CPTScatterPlot *referencePricePlot = [[CPTScatterPlot alloc] init];
    referencePricePlot.identifier = @"CPDTickerReferencePrice";
    CPTColor *referencePriceColor = [CPTColor colorWithComponentRed:0.0 green:0.0 blue:1.0 alpha:1.0f];
    referencePricePlot.dataSource = self;
    [graph addPlot:referencePricePlot toPlotSpace:plotSpace];
    
    // 3 - Set up plot space
//    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:portfolioPlot, nil]];
    //設置x軸座標的可視範圍
//    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
//    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
//    plotSpace.xRange = xRange;
    //設置y軸座標的可視範圍
//    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
//    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
//    plotSpace.yRange = yRange;
    
    // 4 - Create styles and symbols
    //走勢的線樣式
    CPTMutableLineStyle *portfolioLineStyle = [portfolioPlot.dataLineStyle mutableCopy];
    portfolioLineStyle.lineWidth = 1.5f;
    portfolioLineStyle.lineColor = portfolioColor;
    portfolioPlot.dataLineStyle = portfolioLineStyle;
    CPTMutableLineStyle *portfolioSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    portfolioSymbolLineStyle.lineColor = portfolioColor;
    
    ////參考價的線樣式
    CPTMutableLineStyle *referencePriceLineStyle = [referencePricePlot.dataLineStyle mutableCopy];
    referencePriceLineStyle.lineWidth = 0.5f;
    referencePriceLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:1], nil];
    referencePriceLineStyle.lineColor = referencePriceColor;
    referencePricePlot.dataLineStyle = referencePriceLineStyle;
    CPTMutableLineStyle *referencePriceSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    referencePriceSymbolLineStyle.lineColor = referencePriceColor;

    
//    CPTPlotSymbol *portfolioSymbol = [CPTPlotSymbol ellipsePlotSymbol];
//    portfolioSymbol.fill = [CPTFill fillWithColor:portfolioColor];
//    portfolioSymbol.lineStyle = portfolioSymbolLineStyle;
//    portfolioSymbol.size = CGSizeMake(6.0f, 6.0f);
//    portfolioPlot.plotSymbol = portfolioSymbol;
}

- (UIImage *)imageOfChart:(CGRect) frame
{
    [self.hostView setFrame:frame];
//    [self.hostView.hostedGraph setFrame:frame];
    return [self.hostView.hostedGraph imageOfLayer];
}

@end
