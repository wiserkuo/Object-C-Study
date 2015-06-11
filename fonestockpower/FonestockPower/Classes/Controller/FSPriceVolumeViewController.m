//  支壓圖
//  FSPriceVolumeViewController.m
//  WirtsLeg
//
//  Created by Shen Kevin on 13/7/5.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSPriceVolumeViewController.h"
#import "Portfolio.h"
#import "FSPriceVolumeChartDelegate.h"
#import "FSPriceVolumeChartDataSource.h"
#import "FSPriceVolumeControlSpace.h"
#import "FSCrossHair.h"
#import "FSPriceVolumeCrossHairInfoPanel.h"
#import "FSPriceVolumeCrossHairInfo.h"
#import "TradeDistributeIn.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "Snapshot.h"

@interface FSPriceVolumeViewController (){
    NSTimer *timer;
}
@property (strong, nonatomic) FSInstantInfoWatchedPortfolio * warchPortfolio;
@property (nonatomic, strong) FSPriceVolumeControlSpace *controlSpace;
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) FSDataModelProc *dataModal;
@property (nonatomic, strong) PortfolioTick *tickBank;
@property (nonatomic, strong) FSPriceVolumeChartDelegate *delegate;
@property (nonatomic, strong) FSPriceVolumeChartDataSource *dataSource;
@property (nonatomic, strong) UIActionSheet *singleDayActionSheet;
@property (nonatomic, strong) UIActionSheet *accumulativeActionSheet;
@property (nonatomic, strong) FSCrossHair *crossHair;
@property (nonatomic, strong) FSPriceVolumeCrossHairInfoPanel *crossInfoPanel;
@property (nonatomic, assign) NSUInteger crossHairInfoPanelPosition;
@property (nonatomic, strong) NSMutableDictionary * mainDict;
@property (nonatomic, strong) NSMutableArray * accumulativeArray;
@property (nonatomic) BOOL firstTimeIn;
@property (nonatomic) int infoPanelHigh;

@end

@implementation FSPriceVolumeViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.dataModal = [FSDataModelProc sharedInstance];
    self.warchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    [self setBtnArray];
    [self setupTickBank];
    [self setupDataSource];
    [self setupDelegate];
    [self configureHost];
    [self configureGraph];
    [self configureAxes];
    [self configurePlots];
    [self addControlSpace];
    [self addInfoPanel];
    [self addCrossHair];
    [self readFromFile];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

-(void)timerHideHud:(NSTimer *)incomingTimer{
    [self.view hideHUD];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setSingleDayPlotVisible:NO];
    [self setAccumulationPlotVisible:NO];
    if (![[FSFonestock sharedInstance] checkPermission:FSPermissionTypePressSupport showAlertViewToShopping:YES]) {
        UIView * noSupperView = [[UIView alloc]initWithFrame:self.view.bounds];
        noSupperView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
        [self.view addSubview:noSupperView];
    }
    [_dataModal.tradeDistribute SetTarget:_dataSource];

    if (_warchPortfolio.portfolioItem != nil) {
        _dataSource.portfolioItem = _warchPortfolio.portfolioItem;
        [_dataSource startWatch];
        if (_dataSource.singleDay) {
            [_dataSource sendSingleDayRequest:_dataSource.singleDayIndex];
        }
        if (_dataSource.periodDay) {
            [_dataSource sendPeriodRequest:_dataSource.periodIndex];
        }
    //        [self reloadGraph];

    }
    [self registerLoginNotificationCallBack:self seletor:@selector(reloadGraph)];
    [self updateXAxisLabel];
    [self updateYAxisLabel];
    
    [self.view showHUDWithTitle:@""];

    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerHideHud:) userInfo:nil repeats:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterLoginNotificationCallBack:self];
    [self hideCrossInfoPanel];
    [self saveToFile];
    [timer invalidate];
    [_dataModal.tradeDistribute SetTarget:nil];
    if (_warchPortfolio.portfolioItem != nil) {
        [_dataSource stopWatch];
    }

}

-(void)setBtnArray{
    self.accumulativeArray = [[NSMutableArray alloc]initWithObjects:NSLocalizedStringFromTable(@"5日", @"Equity", @""), NSLocalizedStringFromTable(@"10日", @"Equity", @""), NSLocalizedStringFromTable(@"15日", @"Equity", @""), nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        self.view = nil;
    }
}

#pragma mark Core Plot

- (void)setupDelegate
{
    self.delegate = [[FSPriceVolumeChartDelegate alloc] init];
    self.hostView.hostedGraph.delegate = self.delegate;
}

- (void)setupDataSource
{
    self.dataSource = [[FSPriceVolumeChartDataSource alloc] init];
    _dataSource.priceVolumeViewController = self;
}

- (void)reloadGraph
{

    if (_hostView.hostedGraph != nil) {
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) _hostView.hostedGraph.defaultPlotSpace;
        plotSpace.globalXRange = nil;
        plotSpace.globalYRange = nil;

        [_hostView.hostedGraph reloadData];
        NSMutableArray *plots = [[NSMutableArray alloc]init];
        if (_controlSpace.singleCheckButton.selected) {
            [plots addObject:[_hostView.hostedGraph plotWithIdentifier:@"CPDSingleDayVolume"]];
            [plots addObject:[_hostView.hostedGraph plotWithIdentifier:@"CPDSingleDayVolumeDashLine"]];
        }
        if (_controlSpace.accumulativeCheckButton.selected) {
            if (![_dataModal.tradeDistribute.period.arrayData count] == 0) {
                [plots addObject:[_hostView.hostedGraph plotWithIdentifier:@"CPDPeriodVolume"]];
            }
        }
        [_hostView.hostedGraph.defaultPlotSpace scaleToFitPlots:plots];
        
        //設置x軸座標的可視範圍
        if (_controlSpace.singleCheckButton.selected && _controlSpace.accumulativeCheckButton.selected) {
//            if([_dataModal.tradeDistribute.period.arrayData count] == 0){
//                plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(_singleDayDataMaxVolume * 1.1f)];
//            }else{
                plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat (MAX((_singleDayDataMaxVolume * 1.1f), (_accumulativeDataMaxVolume *1.1f)))];

//            }
//            [self setSingleDayPlotVisible:YES];
//            [self setAccumulationPlotVisible:YES];
            
        }else if (_controlSpace.singleCheckButton.selected){
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(_singleDayDataMaxVolume *1.1f)];
//            [self setSingleDayPlotVisible:YES];
        }else{
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(_accumulativeDataMaxVolume *1.1f)];
//            [self setAccumulationPlotVisible:YES];
        }
        plotSpace.globalXRange = plotSpace.xRange;
        //設置y軸座標的可視範圍
        CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.06f)];
        plotSpace.yRange = yRange;
        plotSpace.globalYRange = plotSpace.yRange;
        
        //更新X軸量的標示
        [self updateCrossHairVerticalLinePosition];
        [self updateXAxisLabel];
        [self updateYAxisLabel];
    }
    [self.view hideHUD];
}

-(void)configureHost {
    self.hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    self.hostView.allowPinchScaling = YES;
    self.hostView.layer.borderColor = [UIColor blackColor].CGColor;
    self.hostView.layer.borderWidth = 0.5f;
    [self.view addSubview:_hostView];
}

-(void)configureGraph {
    // 1 - Create the graph
    self.hostView.hostedGraph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
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
    self.hostView.hostedGraph.titleDisplacement = CGPointMake(0.0f, 0.0f);
    
    // 4 - Set padding for plot area
    [self.hostView.hostedGraph.plotAreaFrame setPaddingLeft:75.0f];
    [self.hostView.hostedGraph.plotAreaFrame setPaddingRight:0.0f];
    [self.hostView.hostedGraph.plotAreaFrame setPaddingTop:0.0f];
    [self.hostView.hostedGraph.plotAreaFrame setPaddingBottom:15.0f];
    [[self.hostView.hostedGraph plotAreaFrame] setBorderLineStyle:nil];
    
    
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    plotSpace.delegate = self;
}

-(void)configureAxes {
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    CPTAxis *xAxis = axisSet.xAxis;
    xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    CPTAxis *yAxis = axisSet.yAxis;
    yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
}

- (void)scalePriceGraphToFitPrice:(EquitySnapshotDecompressed *) snapshot
{
//    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
//    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
//    xyPlotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minY) length:CPTDecimalFromFloat(maxY - minY)];
//    xyPlotSpace.yRange = xyPlotSpace.globalYRange;
}

-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // 2 - Create the plot
    //累計量的長條圖
    CPTBarPlot *periodVolumeBarPlot = [[CPTBarPlot alloc] init];//[CPTBarPlot tubularBarPlotWithColor:[CPTColor colorWithComponentRed:0.449 green:0.526 blue:0.959 alpha:1.000] horizontalBars:YES];
    periodVolumeBarPlot.barsAreHorizontal = YES;
    periodVolumeBarPlot.identifier = @"CPDPeriodVolume";
//    CPTColor *periodVolumeBarPlotColor = [CPTColor blueColor];
    periodVolumeBarPlot.dataSource = self.dataSource;
    CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithComponentRed:141.0f/255.0f green:161.0f/255.0f blue:246.0f/255.0f alpha:1.0f] endingColor:[CPTColor colorWithComponentRed:74.0f/255.0f green:90.0f/255.0f blue:119.0f/255.0f alpha:1.0f]];
    fillGradient.angle = -90.0;
    periodVolumeBarPlot.fill = [CPTFill fillWithGradient:fillGradient];
    periodVolumeBarPlot.barWidth = CPTDecimalFromDouble(0.0f);
    [graph addPlot:periodVolumeBarPlot toPlotSpace:plotSpace];
    
    //設定長條圖柱狀的border
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = [CPTColor blackColor];
    barLineStyle.lineWidth = 0.0f;
    
    periodVolumeBarPlot.lineStyle = barLineStyle;
    
    //走勢的線
    CPTScatterPlot *singleDayVolumePlot = [[CPTScatterPlot alloc] init];
    singleDayVolumePlot.identifier = @"CPDSingleDayVolume";
    CPTColor *singleDayVolumePlotColor = [CPTColor colorWithComponentRed:0.980 green:0.000 blue:0.955 alpha:1.000];
    singleDayVolumePlot.dataSource = self.dataSource;
    [graph addPlot:singleDayVolumePlot toPlotSpace:plotSpace];
    
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
    
    //單日量線的顏色
    CPTMutableLineStyle *singleDayVolumePlotLineStyle = [singleDayVolumePlot.dataLineStyle mutableCopy];
    singleDayVolumePlotLineStyle.lineWidth = 1;
    singleDayVolumePlotLineStyle.lineColor = singleDayVolumePlotColor;
    singleDayVolumePlot.dataLineStyle = singleDayVolumePlotLineStyle;
    
    
    //單日量虛線
    
    CPTBarPlot *dayVolumeBarPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor colorWithComponentRed:1 green:0 blue:0 alpha:1.000] horizontalBars:YES];
    dayVolumeBarPlot.identifier = @"CPDSingleDayVolumeDashLine";
    dayVolumeBarPlot.dataSource = self.dataSource;
    dayVolumeBarPlot.barWidth = CPTDecimalFromDouble(0.0f);
    [graph addPlot:dayVolumeBarPlot toPlotSpace:plotSpace];
    
    CPTMutableLineStyle *dayVolumeLineStyle = [CPTMutableLineStyle lineStyle];
    dayVolumeLineStyle.lineColor = [CPTColor redColor];
    dayVolumeLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:2], [NSNumber numberWithInteger:3], nil];
    dayVolumeLineStyle.lineWidth = 1.0f;
    
    dayVolumeBarPlot.lineStyle = dayVolumeLineStyle;
}

-(void)configurePlotsPeriodVolumeBarWidth:(float)width{
    CPTBarPlot *periodVolumeBarPlot = (CPTBarPlot *)[_hostView.hostedGraph plotWithIdentifier:@"CPDPeriodVolume"];
    periodVolumeBarPlot.barWidth =CPTDecimalFromFloat(width);
}

- (void)updateXAxisLabel
{
    NSNumber *maxVolume = nil;
    //只有單日被選取且累積沒被選取時，才使用單日的最大量去計算
    
    //_singleDayDataMaxVolume和_accumulativeDataMaxVolume是從dataSource去assign
    if (_controlSpace.singleCheckButton.isSelected && _controlSpace.accumulativeCheckButton.isSelected) {
        maxVolume = @(MAX((_singleDayDataMaxVolume), (_accumulativeDataMaxVolume)));
    }else if(_controlSpace.singleCheckButton.isSelected){
        maxVolume = @(_singleDayDataMaxVolume);
    }else{
        maxVolume = @(_accumulativeDataMaxVolume);
    }
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    CPTAxis *xAxis = axisSet.xAxis;
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:5];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:5];
    
    NSInteger baseUnit = floor([maxVolume doubleValue] * 0.9 / 3);
    if (baseUnit < 3) {
        baseUnit = 1;
    }
    if ([maxVolume integerValue] != 0) {
        for (NSInteger counter = baseUnit; counter < [maxVolume integerValue] ; counter += baseUnit) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[CodingUtil stringWithVolumeByValue2:counter] textStyle:xAxis.labelTextStyle];
            label.alignment = CPTAlignmentCenter;
            CGFloat location = counter;
            label.tickLocation = CPTDecimalFromCGFloat(location);
            label.offset = -1.0f;//xAxis.majorTickLength;
            if (label) {
                [xLabels addObject:label];
                [xLocations addObject:[NSNumber numberWithFloat:location]];
            }
        }
    }
    xAxis.axisLabels = xLabels;
    xAxis.majorTickLocations = xLocations;
    /*
     X軸分隔虛線樣式
     */
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor grayColor];
    gridLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:3], [NSNumber numberWithInteger:1], nil];
    gridLineStyle.lineWidth = 0.3f;
    
    xAxis.majorTickLength = 0.0f;
    xAxis.majorGridLineStyle = gridLineStyle;//畫格線
}

- (void)updateYAxisLabel
{
    float oldPrice = 0;
    //標示價格
    //先畫出三個特殊價格 ＊:開盤價, ＃:收盤價, ＝:開收等價
	PortfolioTick* tickBank = _dataModal.portfolioTickBank;
    EquitySnapshotDecompressed *snapshot;
#ifdef LPCB
    FSSnapshot *lpcbSnapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:_warchPortfolio.portfolioItem.getIdentCodeSymbol];
    
    snapshot = [[EquitySnapshotDecompressed alloc] init];
    snapshot.openPrice = lpcbSnapshot.open_price.calcValue;
    snapshot.highestPrice = lpcbSnapshot.high_price.calcValue;
    snapshot.lowestPrice = lpcbSnapshot.low_price.calcValue;
    snapshot.volume = lpcbSnapshot.volume.calcValue;
    snapshot.previousVolume = lpcbSnapshot.previous_volume.calcValue;
    snapshot.currentPrice = lpcbSnapshot.last_price.calcValue;
    snapshot.referencePrice = lpcbSnapshot.reference_price.calcValue;
    snapshot.ceilingPrice = lpcbSnapshot.top_price.calcValue;
    snapshot.floorPrice = lpcbSnapshot.bottom_price.calcValue;
    
#else
    snapshot = [tickBank getSnapshotFromIdentCodeSymbol:[_warchPortfolio.portfolioItem getIdentCodeSymbol]];
#endif
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    CPTAxis *yAxis = axisSet.yAxis;
    NSMutableSet *yLabels = [NSMutableSet setWithCapacity:5];
    NSMutableSet *yLocations = [NSMutableSet setWithCapacity:5];
    CPTMutableTextStyle *newStyle = [yAxis.labelTextStyle mutableCopy];
    newStyle.color = [CPTColor grayColor];
    newStyle.textAlignment = CPTTextAlignmentRight;
    newStyle.fontSize = 14.0f;
    TradeDistribute* tradeDistribute = _dataModal.tradeDistribute;
    if (_controlSpace.singleCheckButton.selected && _controlSpace.accumulativeCheckButton.selected) {
        //兩個都開啟
        //今日的線圖
        float openPrice;
        float lastPrice;
        if (_dataSource.singleDayIndex == 0) {
            //已經收盤
            float maxHigh = [(NSNumber *)[[self getMaxAndMinVolume:tradeDistribute] objectForKey:@"maxHigh"] floatValue];
            float minLow = [(NSNumber *)[[self getMaxAndMinVolume:tradeDistribute] objectForKey:@"minLow"] floatValue];
            double priceBlock = [(NSNumber *)[[self findBlockCount:snapshot MaxHigh:maxHigh MinLow:minLow]objectForKey:@"priceBlock"]floatValue];
            NSInteger blockCount = [(NSNumber *)[[self findBlockCount:snapshot MaxHigh:maxHigh MinLow:minLow]objectForKey:@"blockCount"]integerValue];
            NSInteger block = [_dataSource findBlock:blockCount];
                //如果開收等價，只標一個價格
                if (snapshot.openPrice > 0.0 && (snapshot.openPrice == snapshot.currentPrice)) {
                    float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.currentPrice inSingleDayData:YES inAccumulationData:YES];
                    CPTAxisLabel *label = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    if (label) {
                        [yLabels addObject:label];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        openPrice = lastPrice = nearestPrice;
                    }
                    CPTAxisLabel *sameMarkLabel = [[CPTAxisLabel alloc] initWithText:@"=" textStyle:newStyle];
                    sameMarkLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                    sameMarkLabel.offset = 1.0f;
                    
                    if (sameMarkLabel) {
                        [yLabels addObject:sameMarkLabel];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                    }
                }
                else if (snapshot.openPrice > 0.0 && (snapshot.openPrice != snapshot.currentPrice)) {
                    //標上收盤價格label
                    float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.currentPrice inSingleDayData:YES inAccumulationData:YES];
                    CPTAxisLabel *closePriceLabel = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    if (closePriceLabel) {
                        [yLabels addObject:closePriceLabel];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        lastPrice = nearestPrice;
                    }
                    CPTAxisLabel *closeMarkLabel = [[CPTAxisLabel alloc] initWithText:@"#" textStyle:newStyle];
                    closeMarkLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                    closeMarkLabel.offset = 1.0f;
                    if (closeMarkLabel) {
                        [yLabels addObject:closeMarkLabel];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                    }
                    //標上開盤價格label
                    nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.openPrice inSingleDayData:YES inAccumulationData:YES];
                    CPTAxisLabel *label = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    if (label) {
                        if (!(nearestPrice>lastPrice-priceBlock * block && nearestPrice<lastPrice+priceBlock * block)) {
                            [yLabels addObject:label];
                            [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        }
                        openPrice = nearestPrice;
                    }
                    CPTAxisLabel *markLabel = [[CPTAxisLabel alloc] initWithText:@"*" textStyle:newStyle];
                    markLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                    markLabel.offset = 1.0f;
                    if (markLabel) {
                        if (!(nearestPrice>lastPrice-priceBlock * block && nearestPrice<lastPrice+priceBlock * block)) {
                            [yLabels addObject:markLabel];
                            [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        }
                    }
                }
            oldPrice = 0;
            
            if (blockCount != 0) {
                for (int i = 0; i <= blockCount; i ++) {
                    double price = minLow + priceBlock * i;
                    float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:price inSingleDayData:YES inAccumulationData:YES];
                    CPTAxisLabel *blockPriceLabel = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    if (blockPriceLabel) {
                        if (!(nearestPrice > openPrice - priceBlock * block && nearestPrice <openPrice + priceBlock * block)) {
                            if (!(nearestPrice > lastPrice - priceBlock * block && nearestPrice <lastPrice + priceBlock * block)) {
                                if (!(nearestPrice > oldPrice - priceBlock * block && nearestPrice < oldPrice + priceBlock * block)) {
                                    oldPrice = nearestPrice;
                                    [yLabels addObject:blockPriceLabel];
                                    [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                                }
                            }
                        }
                    }
                }
            }
        }else{
            float maxHigh = [(NSNumber *)[[self getMaxAndMinVolume:tradeDistribute] objectForKey:@"maxHigh"] floatValue];
            float minLow = [(NSNumber *)[[self getMaxAndMinVolume:tradeDistribute] objectForKey:@"minLow"] floatValue];
            
            float priceBlock = [(NSNumber *)[[self findBlockCount:snapshot MaxHigh:maxHigh MinLow:minLow]objectForKey:@"priceBlock"]floatValue];
            NSInteger blockCount = [(NSNumber *)[[self findBlockCount:snapshot MaxHigh:maxHigh MinLow:minLow]objectForKey:@"blockCount"]integerValue];
            NSInteger block = [_dataSource findBlock:blockCount];
                //如果開收等價，只標一個價格
                if (snapshot.openPrice > 0.0 && (snapshot.openPrice == snapshot.currentPrice)) {
                    float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.currentPrice inSingleDayData:YES inAccumulationData:YES];
                    CPTAxisLabel *label = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    if (label) {
                        [yLabels addObject:label];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        openPrice = lastPrice = nearestPrice;
                    }
                    CPTAxisLabel *sameMarkLabel = [[CPTAxisLabel alloc] initWithText:@"=" textStyle:newStyle];
                    sameMarkLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                    sameMarkLabel.offset = 1.0f;
                    if (sameMarkLabel) {
                        [yLabels addObject:sameMarkLabel];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                    }
                }
                else if (snapshot.openPrice > 0.0 && (snapshot.openPrice != snapshot.currentPrice)) {
                    if (snapshot.currentPrice>=tradeDistribute.oneDay.lowPrice && snapshot.currentPrice<=tradeDistribute.oneDay.hightPrice) {
                        //標上收盤價格label
                        float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.currentPrice inSingleDayData:YES inAccumulationData:YES];
                        CPTAxisLabel *closePriceLabel = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                        if (closePriceLabel) {
                            [yLabels addObject:closePriceLabel];
                            [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                            lastPrice = nearestPrice;
                        }
                        CPTAxisLabel *closeMarkLabel = [[CPTAxisLabel alloc] initWithText:@"#" textStyle:newStyle];
                        closeMarkLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                        closeMarkLabel.offset = 1.0f;
                        if (closeMarkLabel) {
                            [yLabels addObject:closeMarkLabel];
                            [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        }
                    }
                    //標上開盤價格label
                    if (snapshot.openPrice>=tradeDistribute.oneDay.lowPrice && snapshot.openPrice<=tradeDistribute.oneDay.hightPrice) {
                        float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.openPrice inSingleDayData:YES inAccumulationData:YES];
                        CPTAxisLabel *label = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                        CPTAxisLabel *markLabel = [[CPTAxisLabel alloc] initWithText:@"*" textStyle:newStyle];
                        
                        if (label) {
                            if (!(nearestPrice>lastPrice-priceBlock * block && nearestPrice<lastPrice+priceBlock * block)) {
                                [yLabels addObject:label];
                                [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                            }
                            openPrice = nearestPrice;
                        }
                        
                        markLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                        markLabel.offset = 1.0f;
                        
                        if (markLabel) {
                            if (!(nearestPrice>lastPrice-priceBlock * block && nearestPrice<lastPrice+priceBlock * block)) {
                                [yLabels addObject:markLabel];
                                [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                            }
                        }
                    }
                }
            oldPrice = 0;
            if (blockCount != 1) {
                for (int i = 0; i <= blockCount; i ++) {
                    double price = minLow + priceBlock * i;
                    float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:price inSingleDayData:YES inAccumulationData:YES];
                    CPTAxisLabel *lowestPriceLabel = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    if (lowestPriceLabel) {
                        if (!(nearestPrice > openPrice - priceBlock * block && nearestPrice <openPrice + priceBlock * block)) {
                            if (!(nearestPrice > lastPrice - priceBlock * block && nearestPrice <lastPrice + priceBlock * block)) {
                                if (!(nearestPrice > oldPrice - priceBlock * block && nearestPrice < oldPrice + priceBlock * block)) {
                                    oldPrice = nearestPrice;
                                    [yLabels addObject:lowestPriceLabel];
                                    [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                                }
                            }
                        }
                    }
                }
            }
        }
    }else if(_controlSpace.singleCheckButton.selected){
        //今日的線圖
        float openPrice;
        float lastPrice;
        if (_dataSource.singleDayIndex == 0) {
            //已經收盤
            
            float priceBlock = [(NSNumber *)[[self findBlockCount:snapshot MaxHigh:tradeDistribute.oneDay.hightPrice MinLow:tradeDistribute.oneDay.lowPrice]objectForKey:@"priceBlock"]floatValue];
            NSInteger blockCount = [(NSNumber *)[[self findBlockCount:snapshot MaxHigh:tradeDistribute.oneDay.hightPrice MinLow:tradeDistribute.oneDay.lowPrice]objectForKey:@"blockCount"]floatValue];
           
            NSInteger block = [_dataSource findBlock:blockCount];
                //如果開收等價，只標一個價格
                if (snapshot.openPrice > 0.0 && (snapshot.openPrice == snapshot.currentPrice)) {
                    float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.currentPrice inSingleDayData:YES inAccumulationData:NO];
                    CPTAxisLabel *label = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    if (label) {
                        [yLabels addObject:label];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        openPrice = lastPrice = nearestPrice;
                    }
                    CPTAxisLabel *sameMarkLabel = [[CPTAxisLabel alloc] initWithText:@"=" textStyle:newStyle];
                    sameMarkLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                    sameMarkLabel.offset = 1.0f;
                    if (sameMarkLabel) {
                        [yLabels addObject:sameMarkLabel];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                    }
                }
                else if (snapshot.openPrice > 0.0 && (snapshot.openPrice != snapshot.currentPrice)) {
                    //標上收盤價格label
                    float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.currentPrice inSingleDayData:YES inAccumulationData:NO];
                    CPTAxisLabel *closePriceLabel = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    if (closePriceLabel) {
                        [yLabels addObject:closePriceLabel];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        lastPrice = nearestPrice;
                    }
                    CPTAxisLabel *closeMarkLabel = [[CPTAxisLabel alloc] initWithText:@"#" textStyle:newStyle];
                    closeMarkLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                    closeMarkLabel.offset = 1.0f;
                    if (closeMarkLabel) {
                        [yLabels addObject:closeMarkLabel];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                    }
                    //標上開盤價格label
                    nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.openPrice inSingleDayData:YES inAccumulationData:NO];
                    CPTAxisLabel *label = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    CPTAxisLabel *markLabel = [[CPTAxisLabel alloc] initWithText:@"*" textStyle:newStyle];
                    if (label) {
                        if (!(nearestPrice>lastPrice-priceBlock * block && nearestPrice<lastPrice+priceBlock * block)) {
                            [yLabels addObject:label];
                            [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        }
                        openPrice = nearestPrice;
                    }
                    markLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                    markLabel.offset = 1.0f;
                    
                    if (markLabel) {
                        if (!(nearestPrice>lastPrice-priceBlock * block && nearestPrice<lastPrice+priceBlock * block)) {
                            [yLabels addObject:markLabel];
                            [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        }
                    }
                }
            oldPrice = 0;
            if (blockCount != 0) {
                for (int i = 0; i <= blockCount; i ++) {
                    double price = tradeDistribute.oneDay.lowPrice + priceBlock * i;
                    float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:price inSingleDayData:YES inAccumulationData:NO];
                    CPTAxisLabel *blockPriceLabel = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    if (blockPriceLabel) {
                        if (!(nearestPrice > openPrice - priceBlock * block && nearestPrice <openPrice + priceBlock * block)) {
                            if (!(nearestPrice > lastPrice - priceBlock * block && nearestPrice <lastPrice + priceBlock * block)) {
                                if (!(nearestPrice > oldPrice - priceBlock * block && nearestPrice < oldPrice + priceBlock * block)) {                                oldPrice = nearestPrice;
                                    [yLabels addObject:blockPriceLabel];
                                    [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                                }
                            }
                        }
                    }
                }
            }
        }else{
            float priceBlock = [(NSNumber *)[[self findBlockCount:snapshot MaxHigh:tradeDistribute.oneDay.hightPrice MinLow:tradeDistribute.oneDay.lowPrice]objectForKey:@"priceBlock"] floatValue];
            NSInteger blockCount = [(NSNumber *)[[self findBlockCount:snapshot MaxHigh:tradeDistribute.oneDay.hightPrice MinLow:tradeDistribute.oneDay.lowPrice]objectForKey:@"blockCount"] integerValue];
            NSInteger block = [_dataSource findBlock:blockCount];
                //如果開收等價，只標一個價格
                if (snapshot.openPrice > 0.0 && (snapshot.openPrice == snapshot.currentPrice)) {
                    float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.currentPrice inSingleDayData:YES inAccumulationData:NO];
                    CPTAxisLabel *label = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    if (label) {
                        [yLabels addObject:label];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        openPrice = lastPrice = nearestPrice;
                    }
                    CPTAxisLabel *sameMarkLabel = [[CPTAxisLabel alloc] initWithText:@"=" textStyle:newStyle];
                    sameMarkLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                    sameMarkLabel.offset = 1.0f;
                    if (sameMarkLabel) {
                        [yLabels addObject:sameMarkLabel];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                    }
                }
                else if (snapshot.openPrice > 0.0 && (snapshot.openPrice != snapshot.currentPrice)) {
                    if (snapshot.currentPrice >= tradeDistribute.oneDay.lowPrice && snapshot.currentPrice <= tradeDistribute.oneDay.hightPrice) {
                    //標上收盤價格label
                        float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.currentPrice inSingleDayData:YES inAccumulationData:NO];
                        CPTAxisLabel *closePriceLabel = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                        if (closePriceLabel) {
                            [yLabels addObject:closePriceLabel];
                            [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                            lastPrice = nearestPrice;
                        }
                        CPTAxisLabel *closeMarkLabel = [[CPTAxisLabel alloc] initWithText:@"#" textStyle:newStyle];
                        closeMarkLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                        closeMarkLabel.offset = 1.0f;
                        if (closeMarkLabel) {
                            [yLabels addObject:closeMarkLabel];
                            [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        }
                    }
                    //標上開盤價格label
                    if (snapshot.openPrice>=tradeDistribute.oneDay.lowPrice && snapshot.openPrice <=tradeDistribute.oneDay.hightPrice) {
                        float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.openPrice inSingleDayData:YES inAccumulationData:NO];
                        CPTAxisLabel *label = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                        CPTAxisLabel *markLabel = [[CPTAxisLabel alloc] initWithText:@"*" textStyle:newStyle];
                        if (label) {
                            if (!(nearestPrice>lastPrice-priceBlock * block && nearestPrice<lastPrice+priceBlock * block)) {
                                [yLabels addObject:label];
                                [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                            }
                            openPrice = nearestPrice;
                        }
                        markLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                        markLabel.offset = 1.0f;
                        
                        if (markLabel) {
                            if (!(nearestPrice>lastPrice-priceBlock * block && nearestPrice<lastPrice+priceBlock * block)) {
                                [yLabels addObject:markLabel];
                                [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                            }
                        }
                    }
                }
            oldPrice = 0;
            if (blockCount != 0) {
                for (int i = 0; i <= blockCount; i ++) {
                    double price = tradeDistribute.oneDay.lowPrice + priceBlock * i;
                    float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:price inSingleDayData:YES inAccumulationData:NO];
                    CPTAxisLabel *lowestPriceLabel = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    if (lowestPriceLabel) {
                        if (!(nearestPrice > openPrice - priceBlock * block && nearestPrice <openPrice + priceBlock * block)) {
                            if (!(nearestPrice > lastPrice - priceBlock * block && nearestPrice <lastPrice + priceBlock * block)) {
                                if (!(nearestPrice > oldPrice - priceBlock * block && nearestPrice < oldPrice + priceBlock * block)) {
                                    oldPrice = nearestPrice;
                                    [yLabels addObject:lowestPriceLabel];
                                    [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                                }
                            }
                        }
                    }
                }
            }
        }
    }else if (_controlSpace.accumulativeCheckButton.selected){
        float openPrice;
        float lastPrice;
        float priceBlock = [(NSNumber *)[[self findBlockCount:snapshot MaxHigh:tradeDistribute.period.hightPrice MinLow:tradeDistribute.period.lowPrice]objectForKey:@"priceBlock"] floatValue];
        NSInteger blockCount = [(NSNumber *)[[self findBlockCount:snapshot MaxHigh:tradeDistribute.period.hightPrice MinLow:tradeDistribute.period.lowPrice]objectForKey:@"blockCount"] integerValue];
        NSInteger block = [_dataSource findBlock:blockCount];
            //如果開收等價，只標一個價格
            if (snapshot.openPrice > 0.0 && (snapshot.openPrice == snapshot.currentPrice)) {
                float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.currentPrice inSingleDayData:NO inAccumulationData:YES];
                CPTAxisLabel *label = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                if (label) {
                    [yLabels addObject:label];
                    [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                    openPrice = lastPrice = nearestPrice;
                }
                CPTAxisLabel *sameMarkLabel = [[CPTAxisLabel alloc] initWithText:@"=" textStyle:newStyle];
                sameMarkLabel.tickLocation = CPTDecimalFromDouble(nearestPrice - priceBlock / 10);
                sameMarkLabel.offset = 1.0f;
                if (sameMarkLabel) {
                    [yLabels addObject:sameMarkLabel];
                    [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                }
            }
            else if (snapshot.openPrice > 0.0 && (snapshot.openPrice != snapshot.currentPrice)) {
                if (snapshot.currentPrice>=tradeDistribute.period.lowPrice && snapshot.currentPrice<=tradeDistribute.period.hightPrice) {
                    //標上收盤價格label
                    float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.currentPrice inSingleDayData:NO inAccumulationData:YES];
                    CPTAxisLabel *closePriceLabel = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    if (closePriceLabel) {
                        [yLabels addObject:closePriceLabel];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        lastPrice = nearestPrice;
                    }
                    CPTAxisLabel *closeMarkLabel = [[CPTAxisLabel alloc] initWithText:@"#" textStyle:newStyle];
                    closeMarkLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                    closeMarkLabel.offset = 1.0f;
                    if (closeMarkLabel) {
                        [yLabels addObject:closeMarkLabel];
                        [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                    }
                }
                //標上開盤價格label
                if (snapshot.openPrice>=tradeDistribute.period.lowPrice && snapshot.openPrice<=tradeDistribute.period.hightPrice) {
                    float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:snapshot.openPrice inSingleDayData:NO inAccumulationData:YES];
                    CPTAxisLabel *label = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                    CPTAxisLabel *markLabel = [[CPTAxisLabel alloc] initWithText:@"*" textStyle:newStyle];
                    if (label) {
                        if (!(nearestPrice>lastPrice-priceBlock * block && nearestPrice<lastPrice+priceBlock * block)) {
                            [yLabels addObject:label];
                            [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        }
                        openPrice = nearestPrice;
                    }
                    markLabel.tickLocation = CPTDecimalFromDouble(nearestPrice-priceBlock/10);
                    markLabel.offset = 1.0f;
                    
                    if (markLabel) {
                        if (!(nearestPrice>lastPrice-priceBlock * block && nearestPrice<lastPrice+priceBlock * block)) {
                            [yLabels addObject:markLabel];
                            [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                        }
                    }
                }
            }
        oldPrice = 0;
        if (blockCount != 0) {
            for (int i = 0; i <= blockCount; i ++) {
                double price = tradeDistribute.period.lowPrice + priceBlock * i;
                float nearestPrice = [_dataSource findNearestPriceVolumeByPrice:price inSingleDayData:NO inAccumulationData:YES];
                CPTAxisLabel *blockPriceLabel = [self axisLabelWithPrice:nearestPrice snapshot:snapshot majorTickLength:yAxis.majorTickLength textStyle:yAxis.labelTextStyle];
                if (blockPriceLabel) {
                    if (!(nearestPrice > openPrice - priceBlock * block && nearestPrice <openPrice + priceBlock * block)) {
                        if (!(nearestPrice > lastPrice - priceBlock * block && nearestPrice <lastPrice + priceBlock * block)) {
                            if (!(nearestPrice > oldPrice - priceBlock * block && nearestPrice < oldPrice + priceBlock * block)) {
                                oldPrice = nearestPrice;
                                [yLabels addObject:blockPriceLabel];
                                [yLocations addObject:[NSNumber numberWithDouble:nearestPrice]];
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*
     Y軸分隔虛線樣式
     */
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor grayColor];
    gridLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:3], [NSNumber numberWithInteger:1], nil];
    gridLineStyle.lineWidth = 0.3f;
    
    yAxis.majorGridLineStyle = gridLineStyle;//畫格線
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];

    yAxis.axisLabels = yLabels;
    yAxis.majorTickLineStyle = axisLineStyle;
    yAxis.majorTickLocations = yLocations;
    yAxis.majorTickLength = 2.0f;
    yAxis.tickDirection = CPTSignNegative;
    
    [self whichPlotShouldShow];
}
//走勢左邊的價格
- (CPTAxisLabel *)axisLabelWithPrice:(double) price snapshot:(EquitySnapshotDecompressed *) snapshot majorTickLength:(CGFloat) majorTickLength textStyle:(CPTTextStyle *) textStyle
{

    NSMutableString *text;
    CPTMutableTextStyle *newStyle = [textStyle mutableCopy];
    if (price >= 1000) {
        text = [NSMutableString stringWithFormat:@"%.1lf", price];
        newStyle.fontSize = 18.0f;
    }else{
        text = [NSMutableString stringWithFormat:@"%.2lf", price];
        newStyle.fontSize = 19.0f;
    }
    if (fabs(price-snapshot.referencePrice) < 0.0001) {
        
        newStyle.color = [CPTColor colorWithCGColor:[UIColor blueColor].CGColor];
    }else if (price > snapshot.referencePrice) {
        newStyle.color = [CPTColor colorWithCGColor:[StockConstant PriceUpColor].CGColor];
    }
    else{
        newStyle.color = [CPTColor colorWithCGColor:[StockConstant PriceDownColor].CGColor];
    }

    CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:text textStyle:newStyle];
    label.alignment = CPTAlignmentCenter;
    label.tickLocation = CPTDecimalFromDouble(price);
    label.offset = 7.0f;
    
    
    return label;
}

- (BOOL)isMarketClosed:(UInt16) time marketId:(UInt16) marketId
{
    return [_dataModal.marketInfo isTickTime:time EqualToMarketClosedTime:marketId];
}

#pragma mark - Core plot touch event

/*
 在走勢上面touch會進入這個事件
 */
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    [self showInfoWithSpace:space Event:event atPoint:point];
    
    return YES;
}

/*
 在走勢上面touch或drag會進入這個事件
 */
- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)point
{
    [self showInfoWithSpace:space Event:event atPoint:point];
 
    return YES;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    //    [self hideCrossHair];
    //    [self hideCrossInfoPanel];
    return YES;
}


-(void)showInfoWithSpace:(CPTPlotSpace *)space Event:(id)event atPoint:(CGPoint)point{
    
    //圖表hostView有設位移，所以要把位移減回來，才是正確的point座標
    point.x = point.x - self.hostView.hostedGraph.plotAreaFrame.paddingLeft;
    point.y = point.y - self.hostView.hostedGraph.plotAreaFrame.paddingBottom;
    NSDecimal newPoint[2];
    //把原本的座標轉換成dataPoint，即真正的資料座標，這樣才能得到真正的時間和價格
    [space.graph.defaultPlotSpace plotPoint:newPoint numberOfCoordinates:space.graph.defaultPlotSpace.numberOfCoordinates forPlotAreaViewPoint:point];
    
    if (_dataSource != nil) {
        //找出最接近的整數值
        //        int y = [[NSDecimalNumber decimalNumberWithDecimal:newPoint[1]] intValue];
        
        if (point.x >= 0) {
            //用yindex找出y最接近的價量Dictionary
            NSDictionary *priceVolumeInfo = [_dataSource findNearestPriceVolumeByYAxisIndex:[NSDecimalNumber decimalNumberWithDecimal:newPoint[1]] inSingleDayData:self.controlSpace.singleCheckButton.selected inAccumulationData:self.controlSpace.accumulativeCheckButton.selected];
            if (![priceVolumeInfo[@"SingleDayPrice"] isKindOfClass:[NSNull class]] ||![priceVolumeInfo[@"PeriodPrice"] isKindOfClass:[NSNull class]]) {
                [self showCrossHair];
                [self showCrossInfoPanel];
            }
            if (![priceVolumeInfo[@"SingleDayPrice"] isKindOfClass:[NSNull class]]) {
                [_crossHair moveHorizonalLineToY:[(NSNumber *)priceVolumeInfo[@"SingleDayPrice"] floatValue]];
                //先把觸控的位置轉換成以self.view座標為基準的值
                NSSet *allTouches = [event allTouches];
                if ([allTouches count] >0 ) {
                    UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
                    if (touch1){
                        [self setIfNeedUpdateInfoPanelPosition:[touch1 locationInView:self.view]];
                        [self updatePanel:priceVolumeInfo];
                    }
                }
            }
            if (![priceVolumeInfo[@"PeriodPrice"] isKindOfClass:[NSNull class]]) {
                [_crossHair moveHorizonalLineToY:[(NSNumber *)priceVolumeInfo[@"PeriodPrice"] floatValue]];
                //先把觸控的位置轉換成以self.view座標為基準的值
                NSSet *allTouches = [event allTouches];
                if ([allTouches count] >0 ) {
                    UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
                    if (touch1){
                        [self setIfNeedUpdateInfoPanelPosition:[touch1 locationInView:self.view]];
                        [self updatePanel:priceVolumeInfo];
                    }
                }
            }
            [self.view setNeedsUpdateConstraints];
        }
    }
}

/**
 *  檢查資訊面板是否擋到十字線
 *
 *  @return YES就是有檔到，NO就是沒有檔到
 */
- (void)setIfNeedUpdateInfoPanelPosition:(CGPoint) point
{
    if (_controlSpace.singleCheckButton.selected && _controlSpace.accumulativeCheckButton.selected) {
        _infoPanelHigh = 60;
    }else{
        _infoPanelHigh = 40;
    }
    switch (_crossHairInfoPanelPosition) {
            //目前panel在畫面上邊
        case Upside:
            if (point.y < 250) {
                _crossHairInfoPanelPosition = Downside;
                [self.view setNeedsUpdateConstraints];
            }
            break;
            //目前panel在畫面下邊
        case Downside:
            if (point.y > 250) {
                _crossHairInfoPanelPosition = Upside;
                [self.view setNeedsUpdateConstraints];
            }
            break;
        default:
            _crossHairInfoPanelPosition = Downside;
            [self.view setNeedsUpdateConstraints];
            break;
    }
}

#pragma mark helper method

-(void)setupTickBank
{
    self.tickBank = _dataModal.portfolioTickBank;
}

#pragma mark - ControlSpace

- (void)addControlSpace
{
    self.controlSpace = [[FSPriceVolumeControlSpace alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

    [self.view addSubview:_controlSpace];
    
    [_controlSpace.singleCheckButton addTarget:self action:@selector(singleCheckButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_controlSpace.accumulativeCheckButton addTarget:self action:@selector(accumulativeCheckButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_controlSpace.singlePeriodSelectButton addTarget:self action:@selector(addSingleDayActionSheet) forControlEvents:UIControlEventTouchUpInside];
    
    [_controlSpace.accumulativePeriodSelectButton addTarget:self action:@selector(addPeriodActionSheet) forControlEvents:UIControlEventTouchUpInside];
}

-(void)whichPlotShouldShow{
    if (self.controlSpace.singleCheckButton.selected && self.controlSpace.accumulativeCheckButton.selected) {
        [self setSingleDayPlotVisible:YES];
        [self setAccumulationPlotVisible:YES];
    }else if (self.controlSpace.singleCheckButton.selected){
        [self setSingleDayPlotVisible:YES];
        [self setAccumulationPlotVisible:NO];
    }else{
        [self setSingleDayPlotVisible:NO];
        [self setAccumulationPlotVisible:YES];
    }
}
-(void)singleCheckButtonClick{
    self.controlSpace.singleCheckButton.selected = !self.controlSpace.singleCheckButton.selected;
    [self setSingleDayPlotVisible:NO];
    [self setAccumulationPlotVisible:NO];
    if (self.controlSpace.singleCheckButton.selected && self.controlSpace.accumulativeCheckButton.selected) {
        [self enableSingleFeature];
        [self enableAccumulativeFeature];
        
        [self.dataSource sendSingleDayRequest:self.dataSource.singleDayIndex];
        [self.dataSource sendPeriodRequest:self.dataSource.periodIndex];
    }else if (self.controlSpace.singleCheckButton.selected){
        [self disableAccumulativeFeature];
        [self enableSingleFeature];
        
        [self.dataSource sendSingleDayRequest:self.dataSource.singleDayIndex];
    }else{
        [self disableSingleFeature];
        [self enableAccumulativeFeature];

        [self.dataSource sendPeriodRequest:self.dataSource.periodIndex];
    }
    
//    [self reloadGraph];
    [self hideCrossInfoPanel];
    [self hideCrossHair];
    [self.crossInfoPanel updateConstraints];
    [self.view showHUDWithTitle:@""];
}

-(void)accumulativeCheckButtonClick{
    self.controlSpace.accumulativeCheckButton.selected = !self.controlSpace.accumulativeCheckButton.selected;
    [self setSingleDayPlotVisible:NO];
    [self setAccumulationPlotVisible:NO];
    if (self.controlSpace.singleCheckButton.selected && self.controlSpace.accumulativeCheckButton.selected) {
        
        [self enableSingleFeature];
        [self enableAccumulativeFeature];
        
        [self.dataSource sendSingleDayRequest:self.dataSource.singleDayIndex];
        [self.dataSource sendPeriodRequest:self.dataSource.periodIndex];
    }else if (self.controlSpace.accumulativeCheckButton.selected){
        [self disableSingleFeature];
        [self enableAccumulativeFeature];
        
        [self.dataSource sendPeriodRequest:self.dataSource.periodIndex];
    }else{
        [self disableAccumulativeFeature];
        [self enableSingleFeature];
//        [self setAccumulationPlotVisible:NO];
        
        [self.dataSource sendSingleDayRequest:self.dataSource.singleDayIndex];
    }
    //更新X軸量的標示
    [self hideCrossInfoPanel];
    [self hideCrossHair];
    [self.crossInfoPanel updateConstraints];
    [self.view showHUDWithTitle:@""];
}

- (void)addSingleDayActionSheet
{
    self.singleDayActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"Draw", @"cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"今日", @"Equity", @"Today"), NSLocalizedStringFromTable(@"前1日", @"Equity", @"T-1"), NSLocalizedStringFromTable(@"前2日", @"Equity", @""), NSLocalizedStringFromTable(@"前3日", @"Equity", @""), NSLocalizedStringFromTable(@"前4日", @"Equity", @""),NSLocalizedStringFromTable(@"前5日", @"Equity", @""), nil];
    
    [self showActionSheet:_singleDayActionSheet];
}

- (void)addPeriodActionSheet
{
    self.accumulativeActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"Draw", @"cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"5日", @"Equity", @""), NSLocalizedStringFromTable(@"10日", @"Equity", @""), NSLocalizedStringFromTable(@"15日", @"Equity", @""), nil];
    
    [self showActionSheet:_accumulativeActionSheet];
}

- (void)enableSingleFeature
{
    _controlSpace.singleCheckButton.selected = YES;
    _controlSpace.singlePeriodSelectButton.enabled = YES;
    _controlSpace.singleDateLabel.hidden = NO;
    _crossInfoPanel.isSingleDayEnabled = YES;
}

- (void)disableSingleFeature
{
    _controlSpace.singleCheckButton.selected = NO;
    _controlSpace.singlePeriodSelectButton.enabled = NO;
    _controlSpace.singleDateLabel.hidden = YES;
    _crossInfoPanel.isSingleDayEnabled = NO;
}

- (void)enableAccumulativeFeature
{
    _controlSpace.accumulativeCheckButton.selected = YES;
    _controlSpace.accumulativePeriodSelectButton.enabled = YES;
    _controlSpace.accumulativeDateLabel.hidden = NO;
    _crossInfoPanel.isAccumulationEnabled = YES;
}

- (void)disableAccumulativeFeature
{
    _controlSpace.accumulativeCheckButton.selected = NO;
    _controlSpace.accumulativePeriodSelectButton.enabled = NO;
    _controlSpace.accumulativeDateLabel.hidden = YES;
    _crossInfoPanel.isAccumulationEnabled = NO;
}

- (void)setSingleDayPlotVisible:(BOOL) enabled
{
    [_hostView.hostedGraph plotWithIdentifier:@"CPDSingleDayVolume"].hidden = !enabled;
    [_hostView.hostedGraph plotWithIdentifier:@"CPDSingleDayVolumeDashLine"].hidden = !enabled;
}

- (void)setAccumulationPlotVisible:(BOOL) enabled
{
    [_hostView.hostedGraph plotWithIdentifier:@"CPDPeriodVolume"].hidden = !enabled;
}

-(void)setSingleDayDataMaxVolume:(double)volume{
    _singleDayDataMaxVolume = volume;
}

/**
 *  更新單日日期選擇按鈕的文字
 *
 *  @param index 在actionSheet裡所選的index
 */
- (void)updateSinglePeriodSelectButtonTitleBySelectedIndex:(NSUInteger) index
{
    [_controlSpace.singlePeriodSelectButton setTitle:[_singleDayActionSheet buttonTitleAtIndex:index] forState:UIControlStateNormal];
}

/**
 *  更新累積日期選擇按鈕的文字
 *
 *  @param index 在actionSheet裡所選的index
 */
- (void)updateAccumulativePeriodSelectButtonTitleBySelectedIndex:(NSUInteger) index
{
//    NSLog(@"%@",[_accumulativeActionSheet buttonTitleAtIndex:index]);
    [_controlSpace.accumulativePeriodSelectButton setTitle:[_accumulativeArray objectAtIndex:index] forState:UIControlStateNormal];
}

/**
 *  更新單日日期label的文字
 *
 *  @param dateString 日期的string
 */
- (void)updateSingleDateLabelText:(NSString *) dateString
{
    _controlSpace.singleDateLabel.text = dateString;
}

/**
 *  更新累積日期label的文字
 *
 *  @param dateString 日期的string
 */
- (void)updateAccumulativeDateLabelText:(NSString *) dateString
{
    _controlSpace.accumulativeDateLabel.text = dateString;
}


#pragma mark - CrossHair

/**
 *  加入十字線元件的水平線
 */
- (void)addCrossHair
{
    if (_crossHair == nil) {
        self.crossHair = [[FSCrossHair alloc] init];
        [_hostView.hostedGraph addPlot:_crossHair.horizonalLine];
        _crossHair.horizonalLineColor = [CPTColor blackColor];
        //設定十字線的寬度
        _crossHair.horizonalLineMaxX = 100000000.0;
    }
}

- (void)showCrossHair
{
//    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeInAnimation.duration = 0.33f;
//    fadeInAnimation.removedOnCompletion = NO;
//    fadeInAnimation.fillMode = kCAFillModeForwards;
//    fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
//    [_crossHair.verticalLine addAnimation:fadeInAnimation forKey:@"animateOpacity"];
//    [_crossHair.horizonalLine addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    _crossHair.horizonalLine.hidden = NO;
    //    [UIView animateWithDuration:0.33 animations:^() {
    //
    //    }];
    //    _crossHair.verticalLine.hidden = NO;
    //    _crossHair.horizonalLine.hidden = NO;
}

- (void)hideCrossHair
{
//    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeOutAnimation.duration = 0.33f;
//    fadeOutAnimation.removedOnCompletion = NO;
//    fadeOutAnimation.fillMode = kCAFillModeForwards;
//    fadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0];
//    [_crossHair.verticalLine addAnimation:fadeOutAnimation forKey:@"animateOpacity"];
//    [_crossHair.horizonalLine addAnimation:fadeOutAnimation forKey:@"animateOpacity"];
    _crossHair.horizonalLine.hidden = YES;
    //    _crossHair.verticalLine.hidden = YES;
    //    _crossHair.horizonalLine.hidden = YES;
}
/**
 *  //設定十字線的高度
 */
- (void)updateCrossHairVerticalLinePosition
{
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    _crossHair.verticalLineMaxY = xyPlotSpace.yRange.locationDouble + xyPlotSpace.yRange.lengthDouble;
}

#pragma mark - CrossHairPanel

- (void)addInfoPanel
{
    if (_crossInfoPanel == nil) {
        self.crossInfoPanel = [[FSPriceVolumeCrossHairInfoPanel alloc] init];
        _crossInfoPanel.translatesAutoresizingMaskIntoConstraints = NO;
        _crossHairInfoPanelPosition = Downside;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(crossInfoTap)];
        
        [_crossInfoPanel addGestureRecognizer:tapGestureRecognizer];
        //一開始是隱藏的
        _crossInfoPanel.hidden = YES;
        _crossInfoPanel.isSingleDayEnabled = _controlSpace.singleCheckButton.selected;
        _crossInfoPanel.isAccumulationEnabled = _controlSpace.accumulativeCheckButton.selected;
    }
    
    [self.view addSubview:_crossInfoPanel];
}

-(void)crossInfoTap{
    [self hideCrossInfoPanel];
    [self hideCrossHair];
}

- (void)updatePanel:(NSDictionary *) priceVolumeInfo
{
	PortfolioTick* tickBank = _dataModal.portfolioTickBank;
    float referencePrice;
#ifdef LPCB
    FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:[_warchPortfolio.portfolioItem getIdentCodeSymbol]];
    referencePrice = snapshot.reference_price.calcValue;
#else
    EquitySnapshotDecompressed *snapshot = [tickBank getSnapshotFromIdentCodeSymbol:[_warchPortfolio.portfolioItem getIdentCodeSymbol]];
    referencePrice = snapshot.referencePrice;
#endif
	
    FSPriceVolumeCrossHairInfo *info = [[FSPriceVolumeCrossHairInfo alloc] init];
    info.singleDayPrice = priceVolumeInfo[@"SingleDayPrice"];
    info.accumulationPrice = priceVolumeInfo[@"PeriodPrice"];
    info.singleDayVol = priceVolumeInfo[@"SingleDayVolume"];
    info.accumulationVol = priceVolumeInfo[@"PeriodVolume"];
    if (_controlSpace.singleCheckButton && _controlSpace.accumulativeCheckButton) {
        if ([priceVolumeInfo[@"SingleDayPrice"] isKindOfClass:[NSNull class]]) {
            info.singleDayPrice = priceVolumeInfo[@"PeriodPrice"];
        }
        if ([priceVolumeInfo[@"PeriodPrice"] isKindOfClass:[NSNull class]]) {
            info.accumulationPrice = priceVolumeInfo[@"SingleDayPrice"];
        }
    }
    [_crossInfoPanel updatePanelWithInfo:info referencePrice:@(referencePrice)];
}

/**
 *  十字線出現後，接著顯示資訊面板
 */
- (void)showCrossInfoPanel
{
    _crossInfoPanel.hidden = NO;
//    [UIView animateWithDuration:0.33 animations:^() {
//        _crossInfoPanel.alpha = 1.0;
//    }];
}

- (void)hideCrossInfoPanel
{
    _crossInfoPanel.hidden = YES;
//    [UIView animateWithDuration:0.33 animations:^() {
//        _crossInfoPanel.alpha = 0.0;
//    }];

}

#pragma mark - Action

#pragma mark - UIActionSheetDelegate

/**
 *  按下actionSheet之後，依照index發送不同的resquest
 *
 *  @param actionSheet 單日或累積的actionSheet
 *  @param buttonIndex 所選的index
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex
{
    if ([actionSheet isEqual:_singleDayActionSheet]) {
        if (buttonIndex != _singleDayActionSheet.cancelButtonIndex) {
            [self updateSinglePeriodSelectButtonTitleBySelectedIndex:buttonIndex];
            [_dataSource sendSingleDayRequest:buttonIndex];
            [self hideCrossHair];
            [self hideCrossInfoPanel];
        }
    }
    else {
        if (buttonIndex != _accumulativeActionSheet.cancelButtonIndex) {
            [self updateAccumulativePeriodSelectButtonTitleBySelectedIndex:buttonIndex];
            [_dataSource sendPeriodRequest:buttonIndex];
            [self hideCrossHair];
            [self hideCrossInfoPanel];
        }
    }
}

#pragma mark - plist File

-(void)saveToFile{
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"PSMemory.plist"]];
    self.mainDict = [[NSMutableDictionary alloc] init];
    [self.mainDict setObject:[NSNumber numberWithInt:_controlSpace.singleCheckButton.selected] forKey:@"SingleDay"];
    [self.mainDict setObject:[NSNumber numberWithInt:_controlSpace.accumulativeCheckButton.selected] forKey:@"AccDay"];
    [self.mainDict setObject:[NSNumber numberWithInteger:_dataSource.periodIndex] forKey:@"AccDayNumber"];
    [self.mainDict writeToFile:path atomically:YES];
}

-(void)readFromFile{
    NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *fileName = @"PSMemory.plist";
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
	
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    if(_mainDict){
        _dataSource.singleDay = [[_mainDict objectForKey:@"SingleDay"] boolValue];
        _dataSource.periodDay = [[_mainDict objectForKey:@"AccDay"] boolValue];
        _dataSource.periodIndex = [(NSNumber *)[_mainDict objectForKey:@"AccDayNumber"] intValue];

    }else{
        _dataSource.singleDay = YES;
        _dataSource.periodDay = YES;
        _dataSource.periodIndex = 0;

    }
    [self updateAccumulativePeriodSelectButtonTitleBySelectedIndex:_dataSource.periodIndex];
    if (!_dataSource.singleDay) {
        [self setSingleDayPlotVisible:NO];
        [self disableSingleFeature];
    }
    
    if (!_dataSource.periodDay) {
        [self setAccumulationPlotVisible:NO];
        [self disableAccumulativeFeature];
    }
}

#pragma mark - UI setting

- (NSString *)accumulativeDateLabelTextByPeriod:(NSUInteger) days
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSString *todayDateString = [dateFormatter stringFromDate:today];
    
    NSString *dateString = nil;
    NSDateComponents *components = [[NSDateComponents alloc]init];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    switch(days) {
        case 5:
            [components setDay:-5];
            break;
        case 10:
            [components setDay:-10];
            break;
        case 15:
            [components setDay:-15];
            break;
    }
    
    NSDate *pastDate = [gregorian dateByAddingComponents:components toDate:today options:0];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *pastDateString = [dateFormatter stringFromDate:pastDate];
    dateString = [NSString stringWithFormat:@"%@~%@", pastDateString, todayDateString];
    
    return dateString;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    CGRect controlArea, graphArea;
    CGRectDivide(self.view.bounds, &controlArea, &graphArea, 95, CGRectMinYEdge);
    _controlSpace.frame = controlArea;
    _hostView.frame = graphArea;
}

- (void)viewDidLayoutSubviews
{
    //把X軸移到最低數字處，而不是在0。constraintWithUpperOffset是從plotFrame最上方開始算
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
//    NSLog(@"%f", _hostView.bounds.size.height);
//    NSLog(@"%f", self.hostView.hostedGraph.plotAreaFrame.paddingBottom);
    axisSet.xAxis.axisConstraints = [CPTConstraints constraintWithUpperOffset:CGRectGetHeight(_hostView.bounds)-self.hostView.hostedGraph.plotAreaFrame.paddingBottom];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_crossInfoPanel);
    NSDictionary *metrics = @{@"HostGraphBottomPadding":@(self.hostView.hostedGraph.plotAreaFrame.paddingBottom+50),
                              @"ControlSpaceHeight": @(CGRectGetHeight(_controlSpace.bounds)+50),
                              @"PanelWidth": @(CGRectGetWidth(_hostView.bounds)/3*1.5),
                              @"PanelHeight": @(_infoPanelHigh)
                              };
    /**
     *  排十字線資訊面板
     */
    
    switch (_crossHairInfoPanelPosition) {
        case Upside:
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-ControlSpaceHeight-[_crossInfoPanel(PanelHeight)]" options:0 metrics:metrics views:viewsDictionary]];
            break;
        case Downside:
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_crossInfoPanel(PanelHeight)]-HostGraphBottomPadding-|" options:0 metrics:metrics views:viewsDictionary]];
            break;
            
        default:
            break;
    }
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_crossInfoPanel(PanelWidth)]-10-|" options:0 metrics:metrics views:viewsDictionary]];
    
    [self replaceCustomizeConstraints:constraints];
}
-(NSDictionary *)getMaxAndMinVolume:(TradeDistribute *)tradeDistribute{
    float maxHigh;
    float minLow;
    if (tradeDistribute.oneDay.hightPrice !=0 && tradeDistribute.period.hightPrice != 0 && tradeDistribute.period.hightVolume != 0){
        maxHigh = MAX(tradeDistribute.oneDay.hightPrice, tradeDistribute.period.hightPrice);
    }else{
        if (tradeDistribute.oneDay.hightPrice == 0) {
            maxHigh = tradeDistribute.period.hightPrice;
        }else{
            maxHigh = tradeDistribute.oneDay.hightPrice;
        }
    }
    if (tradeDistribute.oneDay.lowPrice !=0 && tradeDistribute.period.lowPrice != 0 && tradeDistribute.period.hightVolume != 0 && tradeDistribute.oneDay.lowVolume != 0){
        minLow = MIN(tradeDistribute.oneDay.lowPrice, tradeDistribute.period.lowPrice);
    }else{
        if (tradeDistribute.oneDay.lowPrice == 0) {
            minLow = tradeDistribute.period.lowPrice;
        }else{
            minLow = tradeDistribute.oneDay.lowPrice;
        }
    }
    NSDictionary *maxAndMinDic = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:maxHigh], @"maxHigh", [NSNumber numberWithFloat:minLow], @"minLow", nil];
    return maxAndMinDic;
}

-(NSDictionary *)findBlockCount:(EquitySnapshotDecompressed *)snapshot MaxHigh:(float)maxHigh MinLow:(float)minLow{
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    
    double priceBlock;
    NSInteger blockCount;
    
    if ([group isEqualToString:@"us"]) {
        priceBlock = (maxHigh - minLow) / 6;
        blockCount = 5;
        
    }else{
        if (snapshot.referencePrice >= 1000) {
            priceBlock = 5;
        }else if (snapshot.referencePrice >= 500){
            priceBlock = 1;
        }else if (snapshot.referencePrice >= 100){
            priceBlock = 0.5;
        }else if (snapshot.referencePrice >= 50){
            priceBlock = 0.1;
        }else if (snapshot.referencePrice >= 10){
            priceBlock = 0.05;
        }else if (snapshot.referencePrice >= 5){
            priceBlock = 0.01;
        }else{
            priceBlock = 0.005;
        }
        blockCount = round((maxHigh - minLow) / priceBlock);
    }
    
    if (!minLow || !maxHigh) {
        blockCount = 0;
    }
    NSDictionary *dataDic = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithDouble:priceBlock], @"priceBlock", [NSNumber numberWithInteger:blockCount], @"blockCount", nil];
    return dataDic;
}
@end
