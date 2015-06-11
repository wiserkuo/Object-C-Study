//
//  FSCDP.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/26.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSCDP.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "Snapshot.h"
#import "HistoricDataTypes.h"
static NSString *MainItemKVOIdentifier = @"MainItemKVOIdentifierCDP";


@interface FSCDP ()
@property (nonatomic, strong) CPTScatterPlot *ahPlot;
@property (nonatomic, strong) CPTScatterPlot *nhPlot;
@property (nonatomic, strong) CPTScatterPlot *cdpPlot;
@property (nonatomic, strong) CPTScatterPlot *alPlot;
@property (nonatomic, strong) CPTScatterPlot *nlPlot;

//@property (nonatomic, strong) CDPData *cdpData;
@property (nonatomic) BOOL isWatchingHistoricalData;

@property (nonatomic) float ah;
@property (nonatomic) float nh;
@property (nonatomic) float cdp;
@property (nonatomic) float al;
@property (nonatomic) float nl;

@property (nonatomic) UInt16 chartOpenTime;
@property (nonatomic) UInt16 chartCloseTime;
@property (nonatomic) UInt16 chartBreakTime;
@property (nonatomic) UInt16 chartReopenTime;

@end

@implementation FSCDP

- (id)init
{
    self = [super init];
    if (self) {
        [self configurePlot];
        dataLock = [[NSRecursiveLock alloc]init];
    }
    return self;
}

- (id)initWithPortfolioItem:(PortfolioItem*)aPortfolioItem
{
    self = [super init];
    if (self) {
        self.portfolioItem = aPortfolioItem;
        [self updateMarketTime];
        [self configurePlot];
        
    }
    return self;
}


-(void)dealloc{
    self.delegate = nil;
//    [self cancelObserveWatchedPortfolio];
}



- (void)configurePlot
{
    self.ahPlot = [[CPTScatterPlot alloc] init];
    _ahPlot.identifier = @"AHPlot";
    _ahPlot.dataSource = self;
    
    self.nhPlot = [[CPTScatterPlot alloc] init];
    _nhPlot.identifier = @"NHPlot";
    _nhPlot.dataSource = self;
    
    self.cdpPlot = [[CPTScatterPlot alloc] init];
    _cdpPlot.identifier = @"CDPPlot";
    _cdpPlot.dataSource = self;
    
    self.alPlot = [[CPTScatterPlot alloc] init];
    _alPlot.identifier = @"ALPlot";
    _alPlot.dataSource = self;
    
    self.nlPlot = [[CPTScatterPlot alloc] init];
    _nlPlot.identifier = @"NLPlot";
    _nlPlot.dataSource = self;
    
    
    /*
     總共有五條線，每一條線都是虛線，且顏色不一樣
     */
    CPTMutableLineStyle *lineStyle = [_ahPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 0.5;
    lineStyle.lineColor = [CPTColor redColor];
    lineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:3], [NSNumber numberWithInteger:1], nil];
    _ahPlot.dataLineStyle = lineStyle;
    
    lineStyle.lineColor = [CPTColor colorWithComponentRed:113.0f/255.0f green:114.0f/255.0f blue:60.0f/255.0f alpha:1.000];
    _nhPlot.dataLineStyle = lineStyle;
    
    lineStyle.lineColor = [CPTColor blueColor];
    _cdpPlot.dataLineStyle = lineStyle;
    
    lineStyle.lineColor = [CPTColor colorWithComponentRed:0 green:128.0f/255.0f blue:0 alpha:1.0f];
    _alPlot.dataLineStyle = lineStyle;
    
    lineStyle.lineColor =[CPTColor colorWithComponentRed:158.0f/255.0f green:73.0f/255.0f blue:40.0f/255.0f alpha:1.0f];
    _nlPlot.dataLineStyle = lineStyle;
}

#pragma mark - Data

- (void)startWatch
{
//#ifdef LPCB
    FSSnapshot *lpcbSnapshot = [[[FSDataModelProc sharedInstance]portfolioTickBank] getSnapshotBvalueFromIdentCodeSymbol:_portfolioItem.getIdentCodeSymbol];
    
    self.cdp = lpcbSnapshot.cdp.calcValue;
    self.ah = lpcbSnapshot.cdp_ah.calcValue;
    self.al = lpcbSnapshot.cdp_al.calcValue;
    self.nh = lpcbSnapshot.cdp_nh.calcValue;
    self.nl = lpcbSnapshot.cdp_nl.calcValue;
    
//
//#else
    if(_portfolioItem != nil && !_isWatchingHistoricalData)
    {
        _isWatchingHistoricalData = YES;
        PortfolioTick *tickBank = [[FSDataModelProc sharedInstance]historicTickBank];
        [tickBank watchTarget:self ForEquity:[_portfolioItem getIdentCodeSymbol] tickType:'D'];
    }
    if  (_portfolioItem != nil && _isWatchingHistoricalData){
        [self.delegate reloadCDP];
    }
//#endif
    
	
}

- (void)stopWatch
{
	if(_isWatchingHistoricalData)
	{
        
		PortfolioTick *tickBank = [[FSDataModelProc sharedInstance]historicTickBank];
		[tickBank stopWatch:self ForEquity:[_portfolioItem getIdentCodeSymbol]];
        _isWatchingHistoricalData = NO;
	}
}

- (void)clearData
{
    self.ah = 0;
    self.nh = 0;
    self.cdp = 0;
    self.al = 0;
    self.nl = 0;
}

- (BOOL)isDataEmpty
{
    return self.ah == 0 && self.nh == 0 && self.cdp == 0 && self.al == 0 && self.nl == 0;
}

- (void)notifyDataArrive:(NSObject <HistoricTickDataSourceProtocol> *)dataSource
{
    [dataLock lock];
    UInt8 type = 'D';
	if(![dataSource isLatestData:type])
		return;
//    UInt32 lastSeq = [dataSource tickCount:type]-1;
#ifdef LPCB
    FSSnapshot *lpcbSnapshot = [[[FSDataModelProc sharedInstance]portfolioTickBank] getSnapshotBvalueFromIdentCodeSymbol:_portfolioItem.getIdentCodeSymbol];
    
    if(lpcbSnapshot == nil){
        [dataLock unlock];
        return;
    }
    
//	DecompressedHistoricData *historic = [dataSource copyHistoricTick:type sequenceNo:lastSeq];
//	if(historic.date == lpcbSnapshot.trading_date.date16)
//	{
//		lastSeq--;
//		historic = [dataSource copyHistoricTick:type sequenceNo:lastSeq];
//	}
//    [self computationCDPWithHistoryData:historic];
#else
    EquitySnapshotDecompressed *snapshot = [[[FSDataModelProc sharedInstance]portfolioTickBank] getSnapshotFromIdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]];
    if(snapshot == nil){
        [dataLock unlock];
        return;
    }
    
	DecompressedHistoricData *historic = [dataSource copyHistoricTick:type sequenceNo:lastSeq];
	if(historic.date == snapshot.date)
	{
		lastSeq--;
		historic = [dataSource copyHistoricTick:type sequenceNo:lastSeq];
	}
    [self computationCDPWithHistoryData:historic];
#endif
	
    
	
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadCDP)])
    {
        [self.delegate reloadCDP];
    }
    [dataLock unlock];
}

- (void)reloadData
{
    [self.ahPlot reloadData];
    [self.nhPlot reloadData];
    [self.cdpPlot reloadData];
    [self.alPlot reloadData];
    [self.nlPlot reloadData];
}

#pragma mark - Computation

-(void)computationCDPWithHistoryData:(DecompressedHistoricData*)historic;
{
//		self.cdp = (historic.high + historic.low + 2*historic.close) / 4;
//		double pt = (historic.high - historic.low);
//		self.ah = _cdp + pt;
//		self.nh = 2*_cdp - historic.low;
//		self.nl = 2*_cdp - historic.high;
//		self.al = _cdp - pt;
}


//- (void)computeWith:(double) highestPrice lowestPrice:(double) lowestPrice openPrice:(double) openPrice closePrice:(double) closePrice
//{
//    self.highestPrice = highestPrice;
//    self.lowestPrice = lowestPrice;
//    self.openPrice = openPrice;
//    self.closePrice = closePrice;
//    self.pt = highestPrice - lowestPrice;
//    
//    /*
//     求出昨日行情的CDP值：
//     　　CDP = ( H + L + 2C ) / 4
//     */
//    self.cdp = (highestPrice + lowestPrice + 2*closePrice) / 4;
//    
//    /*
//     再分別計算昨天行情得最高值(AH)、近高值(NH)、近低值(NL)及最低值(AL)
//     */
//    
//    //AH = CDP + Pt
//    self.ah = _cdp + _pt;
//    
//    //NH = 2CDP - L
//    self.nh = 2*_cdp - _lowestPrice;
//    
//    //NL = 2CDP – H
//    self.nl = 2*_cdp - _highestPrice;
//    
//    //AL = CDP – Pt
//    self.al = _cdp - _pt;

//    [self.ahPlot reloadData];
//    [self.nhPlot reloadData];
//    [self.cdpPlot reloadData];
//    [self.alPlot reloadData];
//    [self.nlPlot reloadData];
//}

#pragma mark - CPTPlotDataSource

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if (self.ah == 0 && self.nh == 0 && self.cdp == 0 && self.al == 0 && self.nl == 0) {
        return 0;
    }else{
        return 2;
    }
    return 0;
}


- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    NSNumber *num = nil;
    if ([(NSString *)plot.identifier isEqualToString:@"AHPlot"]) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            num = [self xValueWithIndex:index];
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
            num = [NSNumber numberWithFloat:self.ah];
        }
    }
    else if([(NSString *)plot.identifier isEqualToString:@"NHPlot"]) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            num = [self xValueWithIndex:index];
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
            num = [NSNumber numberWithFloat:self.nh];
        }
    }
    else if([(NSString *)plot.identifier isEqualToString:@"CDPPlot"]) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            num = [self xValueWithIndex:index];
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
            num = [NSNumber numberWithFloat:self.cdp];
        }
    }
    else if([(NSString *)plot.identifier isEqualToString:@"ALPlot"]) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            num = [self xValueWithIndex:index];
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
            num = [NSNumber numberWithFloat:self.al];
        }
    }
    else if([(NSString *)plot.identifier isEqualToString:@"NLPlot"]) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            num = [self xValueWithIndex:index];
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
            num = [NSNumber numberWithFloat:self.nl];
        }
    }
    
    return num;
}

- (NSNumber *)xValueWithIndex:(NSUInteger) index
{
    return index == 0 ? @0 : @(_chartCloseTime);
}

#pragma mark - Market Time

- (void)updateMarketTime {
	
    UInt8 marketId = _portfolioItem != nil ? _portfolioItem->market_id : 1;
	
    MarketInfoItem *market = [[[FSDataModelProc sharedInstance]marketInfo] getMarketInfo:marketId];
    if (market == nil) return;
	
    _chartOpenTime = market->startTime_1;
	
    if (market->startTime_2 == 0 && market->endTime_2 == 0) {
        _chartBreakTime = 0;
        _chartReopenTime = 0;
        _chartCloseTime = market->endTime_1;
    }
    else {
        _chartBreakTime = market->endTime_1;
        _chartReopenTime = market->startTime_2;
        _chartCloseTime = market->endTime_2;
    }
    
}

@end
