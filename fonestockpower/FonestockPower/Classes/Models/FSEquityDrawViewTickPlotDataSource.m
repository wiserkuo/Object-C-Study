//
//  FSEquityDrawViewTickPlotDataSource.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/13.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSEquityDrawViewTickPlotDataSource.h"
#import "MarketInfo.h"
#import "ValueUtil.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "EquityTick.h"

extern const float valueUnitBase[];

static NSString *MainItemKVOIdentifier = @"MainItemKVOIdentifierDataSource";
static NSString *ComparedItemKVOIdentifier = @"ComparedItemKVOIdentifierDataSource";

@interface FSEquityDrawViewTickPlotDataSource ()
@property (nonatomic, assign) BOOL isWatchingData;
@property (nonatomic, assign) BOOL isWatchingComparedData;


@property (nonatomic, assign) NSUInteger mainDataSourceArrivedTickCount;
@property (nonatomic, assign) NSUInteger comparedDataSourceArrivedTickCount;

@property (nonatomic) UInt16 chartOpenTime;
@property (nonatomic) UInt16 chartCloseTime;
@property (nonatomic) UInt16 chartBreakTime;
@property (nonatomic) UInt16 chartReopenTime;
@property (nonatomic) UInt16 totalTime;
@property (nonatomic) double maxMainVolume;
@property (nonatomic) double maxComparedVolume;
@property (nonatomic, assign) double averagePrice;//紀錄累計金額，算均價線用

@property (nonatomic, strong) NSMutableArray *averagePrices;//裡面裝每分鐘的均價
@end

@implementation FSEquityDrawViewTickPlotDataSource

- (id)initWithPortfolioItem:(PortfolioItem*)aPortfolioItem
{
    self = [super init];
    if (self) {
        self.portfolioItem = aPortfolioItem;
        [self updateMarketTime];
        //[self observeWatchedPortfolio];
    }
    return self;
}

- (id)initWithPortfolioItem:(PortfolioItem*)aPortfolioItem comparedPortfolioItem:(PortfolioItem*)aComparedPortfolioItem
{
    self = [super init];
    if (self) {
        dataLock = [[NSRecursiveLock alloc]init];
        self.portfolioItem = aPortfolioItem;
        self.comparedPortfolioItem = aComparedPortfolioItem;
        [self updateMarketTime];
        //[self observeWatchedPortfolio];
        if (nil == _volumeStore) {
            self.volumeStore = [NSMutableArray array];
        }
        if (nil == _averagePrices) {
            self.averagePrices = [NSMutableArray array];
        }
        if (_volumeStoreInSameTime == nil) {
            self.volumeStoreInSameTime = [NSMutableArray array];
        }
        self.comparedVolumeStore = [NSMutableArray array];
        self.comparedVolumeStoreInSameTime = [NSMutableArray array];
        self.beforeFirstTickData = [NSMutableArray array];
        self.beforeFirstTickTimeData = [NSMutableArray array];
        self.comparedBeforeFirstTickData = [NSMutableArray array];
        self.comparedBeforeFirstTickTimeData = [NSMutableArray array];
        self.AVGBeforeFirstTickTimeData = [NSMutableArray array];
        self.AVGBeforeFirstTickData = [NSMutableArray array];
        self.tickStoreInSameTime = [NSMutableArray array];
        self.comparedTickStoreInSameTime = [NSMutableArray array];
        self.maxMainVolume = 0.0f;
        self.maxComparedVolume = 0.0f;
    }
    return self;
}

#pragma mark - Getter

- (NSArray *)allVolumes
{
    return [_volumeStore copy];
}


- (NSArray *)allComparedVolumes
{
    return [_comparedVolumeStore copy];
}

#pragma mark - Watch Equity

-(void)updateTickDataWithPortfolioItem:(PortfolioItem *)portfolio{
    [[[FSDataModelProc sharedInstance]portfolioTickBank] updateTickDataByIdentCodeSymbol:[portfolio getIdentCodeSymbol]];
    if ([_volumeStoreInSameTime count] > 0) {
        [_volumeStoreInSameTime removeAllObjects];
    }

    self.maxMainVolume = 4;
    _comparedDataSource = nil;
    [self.delegate hideVolumePlot];
}

- (BOOL)startWatch
{
    if (_portfolioItem != nil && _isWatchingData == NO) {
        _mainDataSourceArrivedTickCount = 0;
        [[[FSDataModelProc sharedInstance]portfolioTickBank] watchTarget:self ForEquity:[_portfolioItem getIdentCodeSymbol] GetTick:YES];
//        [[DataModalProc getDataModal].portfolioTickBank updateTickDataByIdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]];
        [self updateTickDataWithPortfolioItem:_portfolioItem];
        //如果不是自選股就要加入watchlist
//        if ([[DataModalProc getDataModal].portfolioData findItemByIdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]] == nil) {
//            [[DataModalProc getDataModal].portfolioData addWatchListItemByIdentSymbolArray:@[[_portfolioItem getIdentCodeSymbol]]];
//        };
        _isWatchingData = YES;
        return YES;
    }
    
    return NO;
}

- (void)stopWatch
{
    drawGridLine = NO;
    if (_isWatchingData) {
        
        [[[FSDataModelProc sharedInstance]portfolioTickBank] stopWatch:self ForEquity:[_portfolioItem getIdentCodeSymbol]];
//        if ([[DataModalProc getDataModal].portfolioData findItemByIdentCodeSymbol:[_portfolioItem getIdentCodeSymbol]] == nil) {
//            [[DataModalProc getDataModal].portfolioData removeWatchListItemByIdentSymbolArray];
//        };
        
        _isWatchingData = NO;
    }
//    if (_isWatchingComparedData) {
//        [[DataModalProc getDataModal].portfolioData addWatchListItemByIdentSymbolArray:@[[_comparedPortfolioItem getIdentCodeSymbol]]];
//    }
}


- (BOOL)startWatchComparedEquity
{
    NSMutableArray *equities = [NSMutableArray array];
    //如果現在正在看主要走勢，兩個要一起watch
    if (_isWatchingData == YES) {
        [equities addObject:[_portfolioItem getIdentCodeSymbol]];
    }
    if (_comparedPortfolioItem != nil && _isWatchingComparedData == NO) {
        _comparedDataSourceArrivedTickCount = 0;
        [equities addObject:[_comparedPortfolioItem getIdentCodeSymbol]];
        [[[FSDataModelProc sharedInstance]portfolioTickBank] watchTarget:self ForEquity:[_comparedPortfolioItem getIdentCodeSymbol] GetTick:YES];
//        [[DataModalProc getDataModal].portfolioTickBank updateTickDataByIdentCodeSymbol:[_comparedPortfolioItem getIdentCodeSymbol]];
        [self updateTickDataWithPortfolioItem:_comparedPortfolioItem];
        _isWatchingComparedData = YES;
    }
    if ([[[FSDataModelProc sharedInstance]portfolioData] findItemByIdentCodeSymbol:[_comparedPortfolioItem getIdentCodeSymbol]] == nil) {
        [[[FSDataModelProc sharedInstance]portfolioData] addWatchListItemByIdentSymbolArray:equities];
    };
    
    return YES;
}

- (void)stopWatchComparedEquity
{
    if (_isWatchingComparedData) {
        [[[FSDataModelProc sharedInstance]portfolioTickBank] stopWatch:self ForEquity:[_comparedPortfolioItem getIdentCodeSymbol]];
        _isWatchingComparedData = NO;
    }
//    if ([[[FSDataModelProc sharedInstance]portfolioData] findItemByIdentCodeSymbol:[_comparedPortfolioItem getIdentCodeSymbol]] == nil) {
//        [[[FSDataModelProc sharedInstance]portfolioData] removeWatchListItemByIdentSymbolArray];
//    }
    
    
//    if (_isWatchingData) {
//        [[DataModalProc getDataModal].portfolioData addWatchListItemByIdentSymbolArray:@[[_portfolioItem getIdentCodeSymbol]]];
//    }
}

#pragma mark - Delegate Method

- (void)clearCachedMainTickBox
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clearCachedMainTickBox)])
    {
        [self.delegate clearCachedMainTickBox];
    }
}

- (void)clearCachedComparedTickBox
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clearCachedComparedTickBox)])
    {
        [self.delegate clearCachedComparedTickBox];
    }
}
- (void)reloadVolumeGraph {
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadVolumeGraph)])
    {
        //tick是分好幾批給的，第一次會給比較少一點。所以每一次都要把_previousVolume清空重新算，這樣才不會用到上一次算的_previousVolume
        [self.delegate reloadVolumeGraph];
    }
}

- (void)reloadPriceGraph
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadPriceGraph)])
    {
        //tick是分好幾批給的，第一次會給比較少一點。所以每一次都要把_previousVolume清空重新算，這樣才不會用到上一次算的_previousVolume
        [self.delegate reloadPriceGraph];
    }
}

- (void)configureXRange
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(configureXRange)])
    {
        [self.delegate configureXRange];
    } //configureXRange
}

- (void)configureYRange
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(configureYRange:)])
    {
        
        
#ifdef LPCB
        FSSnapshot *snapshot = ((EquityTick *) _dataSource).snapshot_b;
        [self.delegate configureYRangeBValue:snapshot];
#else
        EquitySnapshotDecompressed *snapshot = ((EquityTick *) _dataSource).snapshot;
        [self.delegate configureYRange:snapshot];
#endif
        
        
        
    } //configureYRange:
}

- (void)configureComparedYRange
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scaleComparedPriceGraphToFitPriceWithBValue:)])
    {
#ifdef LPCB
        FSSnapshot *snapshot = ((EquityTick *) _comparedDataSource).snapshot_b;
        [self.delegate scaleComparedPriceGraphToFitPriceWithBValue:snapshot];
#else
        EquitySnapshotDecompressed *snapshot = ((EquityTick *) _comparedDataSource).snapshot;
        [self.delegate scaleComparedPriceGraphToFitPrice:snapshot];
#endif
    } //configureYRange:
    
}

#pragma mark - Data Arrive

- (void) notifyDataArrive:(NSObject <TickDataSourceProtocol> *)dataSource {
    [dataLock lock];
    if ([[_portfolioItem getIdentCodeSymbol] isEqualToString:[_comparedPortfolioItem getIdentCodeSymbol]]) {
        self.dataSource = dataSource;
        self.comparedDataSource = dataSource;
    
        if (dataSource.progress > 0.99 ) {
            _maxMainVolume = 0.0f;
            _maxComparedVolume = 0.0f;
            if (self.delegate && [self.delegate respondsToSelector:@selector(reloadInfoPanel:)])
            {
                
#ifdef LPCB
                FSSnapshot *snapshot = ((EquityTick *) _dataSource).snapshot_b;
                [self.delegate reloadInfoPanel:snapshot];
#else
                EquitySnapshotDecompressed *snapshot = ((EquityTick *) _dataSource).snapshot;
                [self countPlatWithSnapshot:snapshot];
                [self.delegate reloadInfoPanel:snapshot];
#endif
                
            } //reloadInfoPanel:
            //計算主要商品的每個tick真實的量，放進陣列
            [self prepareTickBoxByTime];
            [self prepareComparedTickBoxByTime];
            [self computeVolume];
            [self computeComparedItemVolume];
            [self computeAVL];
            [self prepareDataBeforeFirstTick];
            [self prepareComparedDataBeforeFirstTick];
            [self prepareAVGDataBeforeFirstTick];
            //        [self.delegate insertMainPortfolioData:dataSource.tickNoBox];

            
            if (self.delegate && [self.delegate respondsToSelector:@selector(reloadPriceGraph)])
            {
                [self.delegate reloadPriceGraph];
            } //reloadPriceGraph
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(reloadVolumeGraph)])
            {
                [self.delegate reloadVolumeGraph];
            } //reloadVolumeGraph
            if (self.delegate && [self.delegate respondsToSelector:@selector(showVolumePlot)])
            {
                [self.delegate showVolumePlot];
            } //showVolumePlot
            if (self.delegate && [self.delegate respondsToSelector:@selector(reloadReferencePricePlot)])
            {
                [self.delegate reloadReferencePricePlot];
            }
            if (_comparedDataSourceArrivedTickCount != [dataSource.tickNoBox count]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(reloadComparedPortfolioData)])
                {
                    [self.delegate reloadComparedPortfolioData];
                }
                self.comparedDataSourceArrivedTickCount = [dataSource.tickNoBox count];
            }
            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(hideHUD:)])
//            {
//                [self.delegate hideHUD:YES];
//            } //hideHUD:
            [self configureYRange];
            [self configureComparedYRange];
            
        }

    }else{
        if ([[dataSource getIdenCodeSymbol] isEqualToString:[_portfolioItem getIdentCodeSymbol]]) {
            self.dataSource = dataSource;
            
            if (dataSource.progress > 0.99 ) {
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(reloadInfoPanel:)])
                {
#ifdef LPCB
                    FSSnapshot *snapshot = ((EquityTick *) _dataSource).snapshot_b;
                    [self.delegate reloadInfoPanel:snapshot];
#else
                    EquitySnapshotDecompressed *snapshot = ((EquityTick *) _dataSource).snapshot;
                    [self countPlatWithSnapshot:snapshot];
                    [self.delegate reloadInfoPanel:snapshot];
#endif

                }
                _maxMainVolume = 0.0f;
                //計算主要商品的每個tick真實的量，放進陣列
                [self prepareTickBoxByTime];
                [self computeVolume];
                [self computeAVL];
                [self prepareDataBeforeFirstTick];
                [self prepareAVGDataBeforeFirstTick];
                //        [self.delegate insertMainPortfolioData:dataSource.tickNoBox];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(reloadPriceGraph)])
                {
                    [self.delegate reloadPriceGraph];
                } //reloadPriceGraph
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(reloadVolumeGraph)])
                {
                    [self.delegate reloadVolumeGraph];
                } //reloadVolumeGraph
                if (self.delegate && [self.delegate respondsToSelector:@selector(showVolumePlot)])
                {
                    [self.delegate showVolumePlot];
                } //showVolumePlot
                
//                if (self.delegate && [self.delegate respondsToSelector:@selector(hideHUD:)])
//                {
//                    [self.delegate hideHUD:YES];
//                } //hideHUD:
                [self configureYRange];
                [self configureComparedYRange];
                
            }
        }
        else if ([[dataSource getIdenCodeSymbol] isEqualToString:[_comparedPortfolioItem getIdentCodeSymbol]]) {
            self.comparedDataSource = dataSource;
            
            if(dataSource.progress > 0.99) {
                _maxComparedVolume = 0.0f;
                [self prepareComparedTickBoxByTime];
                [self computeComparedItemVolume];
                [self prepareComparedDataBeforeFirstTick];
                //        [self.delegate insertComparedPortfolioData:dataSource.tickNoBox];
                if (self.delegate && [self.delegate respondsToSelector:@selector(reloadReferencePricePlot)])
                {
                    [self.delegate reloadReferencePricePlot];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(reloadComparedPortfolioData)])
                {
                    [self.delegate reloadComparedPortfolioData];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(reloadPriceGraph)])
                {
                    [self.delegate reloadPriceGraph];
                } //reloadPriceGraph
                if (self.delegate && [self.delegate respondsToSelector:@selector(showVolumePlot)])
                {
                    [self.delegate showVolumePlot];
                } //showVolumePlot
                if (_comparedDataSourceArrivedTickCount != [dataSource.tickNoBox count]) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadComparedPortfolioData)])
                    {
                        [self.delegate reloadComparedPortfolioData];
                    }
                    self.comparedDataSourceArrivedTickCount = [dataSource.tickNoBox count];
                }
                
                [self configureYRange];
                [self configureComparedYRange];
            }
        }
    }
    
    
//    [self configureXRange];
    
    [dataLock unlock];
}

#pragma mark - inner and outer plat
-(void)countPlatWithSnapshot:(EquitySnapshotDecompressed *)snapShot{
    int vol = 0 ,oldVol = 0;
    int inner = 0 ,outer = 0;
    for (NSUInteger tickCounter=1; tickCounter <= _dataSource.tickCount; tickCounter++) {
        
        EquityTickDecompressed * tick = (EquityTickDecompressed *)[_dataSource copyTickAtSequenceNo:(int)tickCounter];
        vol = ([self getRealValue:tick.volume Unit:tick.volumeUnit]-oldVol);
        oldVol =[self getRealValue:tick.volume Unit:tick.volumeUnit];
        if(tick.bid !=0.0 && tick.ask != 0.0){
            if (tick.price <= tick.bid+(MAX(tick.bid, tick.ask)-MIN(tick.ask, tick.bid))/2) {
                inner+=vol;
            }else if (tick.price > tick.bid+(MAX(tick.bid, tick.ask)-MIN(tick.ask, tick.bid))/2){
                outer +=vol;
            }
        }else{
            if (tick.price<=snapShot.referencePrice) {
                inner+=vol;
            }else{
                outer+=vol;
            }
        }
        
    }
    
    snapShot.innerPlat = inner;
    snapShot.outerPlat = outer;
    

}

-(void)countPlatWithBValueSnapshot:(FSSnapshot *)snapShot{
//    int vol = 0 ,oldVol = 0;
//    int inner = 0 ,outer = 0;
//    for (NSUInteger tickCounter=0; tickCounter < [_dataSource.ticksData count]; tickCounter++) {
//        FSTickData *tick = (FSTickData *)[_dataSource.ticksData objectAtIndex:tickCounter];
//        vol = tick.accumulated_volume.calcValue - oldVol;
//        oldVol =tick.accumulated_volume.calcValue;
//        
//        if (tick.last.calcValue == tick.bid.calcValue) {
//            inner+=vol;
//        }else if (tick.last.calcValue == tick.ask.calcValue){
//            outer +=vol;
//        }
//    }
    
}


#pragma mark - CPTPlotDataSource methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {

    //參考價只有兩個點，一個開頭一個結束，Y軸的值都是參考價
    if ([(NSString *)plot.identifier isEqualToString:@"CPDTickerReferencePrice"]) {
        return 2;
    }
    //主走勢
    else if ([(NSString *)plot.identifier isEqualToString:@"CPDTickerSymbolPortfolio"]) {
        if(_dataSource == nil){
            return 0;
        }
        
#ifdef LPCB
        return (NSUInteger)[_dataSource.ticksData count];
#else
        return (NSUInteger)[_dataSource.tickNoBox count]+1;
#endif
        
        
    }
    //主走勢第一個Tick前的線
    else if ([(NSString *)plot.identifier isEqualToString:@"SymbolLineBeforeFirstTick"]) {
        if(_dataSource == nil){
            return 0;
        }
        return (NSUInteger)3;
    }
    //比較走勢
    else if ([(NSString *)plot.identifier isEqualToString:@"CPDComparedTickerSymbolPortfolio"]) {
#ifdef LPCB
        return (NSUInteger)[_comparedDataSource.ticksData count];
#else
        return (NSUInteger)[_comparedDataSource.tickNoBox count]+1;
#endif
    }
    //比較走勢第一個Tick前的線
    else if ([(NSString *)plot.identifier isEqualToString:@"ComparedSymbolLineBeforeFirstTick"]) {
        if(_comparedDataSource == nil){
            return 0;
        }
        return (NSUInteger)3;
    }
    //量
    else if([(NSString *)plot.identifier isEqualToString:@"Volume Plot"]) {
        return (NSUInteger)[_volumeStoreInSameTime count];
    }
    //比較走勢的量
    else if ([(NSString *)plot.identifier isEqualToString:@"Compared Volume Plot"]){
        return (NSUInteger)[_comparedVolumeStoreInSameTime count];
    }
    //均價線
    else if ([(NSString *)plot.identifier isEqualToString:@"AverageLinePlot"]) {
        return [_averagePrices count];
    }
    //均價線第一個tick前的線
    else if ([(NSString *)plot.identifier isEqualToString:@"BeforeFirstTickAverageLinePlot"]) {
        return 3;
    }
    return 0;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    [dataLock lock];
    
    NSNumber *num = nil;
    if ([(NSString *)plot.identifier isEqualToString:@"CPDTickerReferencePrice"]) {
        EquityTick *watchedEquity = (EquityTick*)_dataSource;
        
        if (fieldEnum == CPTScatterPlotFieldX) {
            num = [NSNumber numberWithUnsignedInteger:index==0 ? index : _totalTime];
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
#ifdef LPCB
         num = [NSNumber numberWithDouble:watchedEquity.snapshot_b.reference_price.calcValue];
#else
          num = [NSNumber numberWithDouble:watchedEquity.snapshot.referencePrice];
#endif
            
        }
    }
    else if ([(NSString *)plot.identifier isEqualToString:@"CPDTickerSymbolPortfolio"]) {
        UInt16 tTime = 65535;
        double tPrice = -1;
        if([_dataSource getTimePrice:&tTime Price:&tPrice Sequence:(UInt32)index])
        {
#ifdef LPCB
            tTime-=_chartOpenTime;
#endif
            if (_chartOpenTime+tTime<=_chartCloseTime) {
                if (fieldEnum == CPTScatterPlotFieldX) {
                    if (_chartBreakTime!=0 && tTime>=(_chartReopenTime-_chartOpenTime)) {
                        num = [NSNumber numberWithUnsignedInt:tTime+1-(_chartReopenTime-_chartBreakTime)];
                    }else{
                        num = [NSNumber numberWithUnsignedInt:tTime+1];
                    }
                    
                }
                else if (fieldEnum == CPTScatterPlotFieldY) {
                    num = [NSNumber numberWithDouble:tPrice];
                }
            }else{
                num = nil;
            }
            
        }
        else {
            num = nil;
        }
    }
    //第一個Tick前的線
    else if ([(NSString *)plot.identifier isEqualToString:@"SymbolLineBeforeFirstTick"]) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            if ([_beforeFirstTickTimeData count] > index){
                num = _beforeFirstTickTimeData[index];
            }
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
            if ([_beforeFirstTickData count] > index){
                num = _beforeFirstTickData[index];
            }
        }

    }
    else if ([(NSString *)plot.identifier isEqualToString:@"CPDComparedTickerSymbolPortfolio"]) {
        /*
         兩個商品的價格經常不是在同一個區間內，例：股價100跟20比較。所以必須推算出被比較商品在主要商品的區間內走勢的幅度。
         先算出被比較商品每個點的價格相對於自己參考價的offset%數(正負都有可能)，再用主要商品的參考價乘以這個%數加上參考價即可得到在主要商品區間內的點位
         */
        UInt16 tTime = 65535;
        double tPrice = -1;
        if([_comparedDataSource getTimePrice:&tTime Price:&tPrice Sequence:(UInt32)index]) {
#ifdef LPCB
            tTime-=_chartOpenTime;
#endif
            if (_chartOpenTime+tTime<=_chartCloseTime) {
                if (fieldEnum == CPTScatterPlotFieldX) {
                    if (_chartBreakTime!=0 && tTime>=(_chartReopenTime-_chartOpenTime)) {
                        num = [NSNumber numberWithUnsignedInt:tTime+1-(_chartReopenTime-_chartBreakTime)];
                    }else{
                        num = [NSNumber numberWithUnsignedInt:tTime+1];
                    }
                }
                else if (fieldEnum == CPTScatterPlotFieldY) {
                    num = [NSNumber numberWithDouble:tPrice];
                }
            }else{
                num = nil;
            }
            
        }
        else {
            num = nil;
        }
    }
    //比較走勢第一個Tick前的線
    else if ([(NSString *)plot.identifier isEqualToString:@"ComparedSymbolLineBeforeFirstTick"]) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            if ([_comparedBeforeFirstTickTimeData count] > index){
                num = _comparedBeforeFirstTickTimeData[index];
            }
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
            if ([_comparedBeforeFirstTickData count] > index){
                num = _comparedBeforeFirstTickData[index];
            }
        }
        
    }
    else if([(NSString *)plot.identifier isEqualToString:@"Volume Plot"]) {
        if (fieldEnum == CPTBarPlotFieldBarLocation) {
            if (_chartBreakTime!=0 && index>=(_chartReopenTime-_chartOpenTime)) {
                num = [NSNumber numberWithUnsignedInt:(int)index-(_chartReopenTime-_chartBreakTime)];
            }else{
                num = [NSNumber numberWithUnsignedInt:(int)index];
            }
        }
        else if (fieldEnum == CPTBarPlotFieldBarTip) {
            if ([_volumeStoreInSameTime count] > 0) {
                if ([_volumeStoreInSameTime count] > index) {
                    num = _volumeStoreInSameTime[index];

                }
            }

        }
        else {
            num = nil;
        }
    }
    else if ([(NSString *)plot.identifier isEqualToString:@"Compared Volume Plot"]){
        if (fieldEnum == CPTBarPlotFieldBarLocation) {
            if (_chartBreakTime!=0 && index>=(_chartReopenTime-_chartOpenTime)) {
                num = [NSNumber numberWithUnsignedInt:(int)index-(_chartReopenTime-_chartBreakTime)];
            }else{
                num = [NSNumber numberWithUnsignedInt:(int)index];
            }
        }
        else if (fieldEnum == CPTBarPlotFieldBarTip) {
            if ([_comparedVolumeStoreInSameTime count] > index) {
                num = _comparedVolumeStoreInSameTime[index];
            }
        }
        else {
            num = nil;
        }
    }
    else if ([(NSString *)plot.identifier isEqualToString:@"AverageLinePlot"]) {
        //均價線,計算公式為：每分鐘的平均價格=每分鐘的成交額/成交量
        
#ifdef LPCB
        if ([_dataSource.ticksData count] > 0) {
            FSTickData *tick = (FSTickData *)[_dataSource.ticksData objectAtIndex:index];
            if (fieldEnum == CPTScatterPlotFieldX) {
                if (_chartBreakTime!=0 && ([tick.time absoluteMinutesTime] - _chartOpenTime )>=(_chartReopenTime-_chartOpenTime)) {
                    num = [NSNumber numberWithUnsignedInt:[tick.time absoluteMinutesTime ]- _chartOpenTime+1-(_chartReopenTime-_chartBreakTime)];
                }else{
                    num = [NSNumber numberWithUnsignedInt:[tick.time absoluteMinutesTime]- _chartOpenTime+ 1] ;
                }
            }
            else if (fieldEnum == CPTScatterPlotFieldY) {
                [dataLock unlock];
                return _averagePrices[index];
            }
        }

        
#else
        EquityTickDecompressed * tick = (EquityTickDecompressed *)[_dataSource copyTickAtSequenceNo:index+1];
        
        if (fieldEnum == CPTScatterPlotFieldX) {
            if (_chartBreakTime!=0 && tick.time>=(_chartReopenTime-_chartOpenTime)) {
                num = [NSNumber numberWithUnsignedInt:tick.time+1-(_chartReopenTime-_chartBreakTime)];
            }else{
                num = [NSNumber numberWithUnsignedInt:tick.time+1];
            }
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
            return _averagePrices[index];
        }
#endif
    }
    //均價線第一個Tick前的線
    else if ([(NSString *)plot.identifier isEqualToString:@"BeforeFirstTickAverageLinePlot"]) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            if ([_AVGBeforeFirstTickTimeData count] > index){
                num = _AVGBeforeFirstTickTimeData[index];
            }
        }
        else if (fieldEnum == CPTScatterPlotFieldY) {
            if ([_AVGBeforeFirstTickData count] > index){
                num = _AVGBeforeFirstTickData[index];
            }
        }
        
    }
    [dataLock unlock];
    return num;
}

#pragma mark  - data before first tick

-(void)prepareDataBeforeFirstTick{
    [_beforeFirstTickTimeData removeAllObjects];
    [_beforeFirstTickData removeAllObjects];
    EquityTick *watchedEquity = (EquityTick*)_dataSource;
#ifdef LPCB
     FSTickData *tick = (FSTickData *)[_dataSource.ticksData firstObject];
    //first Tick time:0,price:參考價
    
    [_beforeFirstTickTimeData addObject:[NSNumber numberWithInt:0]];
    [_beforeFirstTickData addObject:[NSNumber numberWithDouble:watchedEquity.snapshot_b.reference_price.calcValue]];
    
    //sec Tick time:first Tick Time, price:參考價
    
    if ([tick.time absoluteMinutesTime] != _chartOpenTime) {
        
        if ([tick.time absoluteMinutesTime] <= _chartBreakTime) {
            [_beforeFirstTickTimeData addObject:[NSNumber numberWithUnsignedInt:[tick.time absoluteMinutesTime]-_chartOpenTime]];
            [_beforeFirstTickData addObject:[NSNumber numberWithDouble:watchedEquity.snapshot_b.reference_price.calcValue]];
            
            [_beforeFirstTickTimeData addObject:[NSNumber numberWithUnsignedInt:[tick.time absoluteMinutesTime] -_chartOpenTime]];
            
        } else if ([tick.time absoluteMinutesTime] >= _chartReopenTime) {
            [_beforeFirstTickTimeData addObject:[NSNumber numberWithUnsignedInt:[tick.time absoluteMinutesTime] - _chartOpenTime - (_chartReopenTime - _chartBreakTime)]];
            [_beforeFirstTickData addObject:[NSNumber numberWithDouble:watchedEquity.snapshot_b.reference_price.calcValue]];
            
            [_beforeFirstTickTimeData addObject:[NSNumber numberWithUnsignedInt:[tick.time absoluteMinutesTime] -_chartOpenTime - (_chartReopenTime - _chartBreakTime)]];
        }
        
    }

    
    if (_portfolioItem->type_id == 6) {
        [_beforeFirstTickData addObject:[NSNumber numberWithDouble:tick.indexValue.calcValue]];
    }else{
        [_beforeFirstTickData addObject:[NSNumber numberWithDouble:tick.last.calcValue]];
    }
    
#else
    EquityTickDecompressed * tick = (EquityTickDecompressed *)[_dataSource copyTickAtSequenceNo:1];
    //first Tick time:0,price:參考價
    
    [_beforeFirstTickTimeData addObject:[NSNumber numberWithInt:0]];
    [_beforeFirstTickData addObject:[NSNumber numberWithDouble:watchedEquity.snapshot.referencePrice]];
    
    //sec Tick time:first Tick Time, price:參考價
    [_beforeFirstTickTimeData addObject:[NSNumber numberWithUnsignedInt:tick.time+1]];
    [_beforeFirstTickData addObject:[NSNumber numberWithDouble:watchedEquity.snapshot.referencePrice]];
    
    [_beforeFirstTickTimeData addObject:[NSNumber numberWithUnsignedInt:tick.time+1]];
    [_beforeFirstTickData addObject:[NSNumber numberWithDouble:tick.price]];
#endif
    
    
}

-(void)prepareComparedDataBeforeFirstTick{
    [_comparedBeforeFirstTickTimeData removeAllObjects];
    [_comparedBeforeFirstTickData removeAllObjects];
    EquityTick *watchedEquity = (EquityTick*)_comparedDataSource;
    
#ifdef LPCB
    FSTickData * tick = (FSTickData *)[_comparedDataSource.ticksData objectAtIndex:0];
    //first Tick time:0,price:參考價
    if (tick) {
        [_comparedBeforeFirstTickTimeData addObject:[NSNumber numberWithInt:0]];
        [_comparedBeforeFirstTickData addObject:[NSNumber numberWithDouble:watchedEquity.snapshot_b.reference_price.calcValue]];
        
        //sec Tick time:first Tick Time, price:參考價
        [_comparedBeforeFirstTickTimeData addObject:[NSNumber numberWithUnsignedInt:[tick.time absoluteMinutesTime]-_chartOpenTime+1]];
        [_comparedBeforeFirstTickData addObject:[NSNumber numberWithDouble:watchedEquity.snapshot_b.reference_price.calcValue]];
        
        [_comparedBeforeFirstTickTimeData addObject:[NSNumber numberWithUnsignedInt:[tick.time absoluteMinutesTime]-_chartOpenTime+1]];
        if (_comparedPortfolioItem->type_id == 6) {
            [_comparedBeforeFirstTickData addObject:[NSNumber numberWithDouble:tick.indexValue.calcValue]];
        }else{
            [_comparedBeforeFirstTickData addObject:[NSNumber numberWithDouble:tick.last.calcValue]];
        }
    }
    
#else
    EquityTickDecompressed * tick = (EquityTickDecompressed *)[_comparedDataSource copyTickAtSequenceNo:1];
    //first Tick time:0,price:參考價
    
    [_comparedBeforeFirstTickTimeData addObject:[NSNumber numberWithInt:0]];
    [_comparedBeforeFirstTickData addObject:[NSNumber numberWithDouble:watchedEquity.snapshot.referencePrice]];
    
    //sec Tick time:first Tick Time, price:參考價
    [_comparedBeforeFirstTickTimeData addObject:[NSNumber numberWithUnsignedInt:tick.time+1]];
    [_comparedBeforeFirstTickData addObject:[NSNumber numberWithDouble:watchedEquity.snapshot.referencePrice]];
    
    [_comparedBeforeFirstTickTimeData addObject:[NSNumber numberWithUnsignedInt:tick.time+1]];
    [_comparedBeforeFirstTickData addObject:[NSNumber numberWithDouble:tick.price]];
#endif
    
}

-(void)prepareAVGDataBeforeFirstTick{
    [_AVGBeforeFirstTickTimeData removeAllObjects];
    [_AVGBeforeFirstTickData removeAllObjects];
    EquityTick *watchedEquity = (EquityTick*)_dataSource;
    EquityTickDecompressed * tick = (EquityTickDecompressed *)[_dataSource copyTickAtSequenceNo:1];
    //first Tick time:0,price:參考價
    if (tick == nil) return;
    [_AVGBeforeFirstTickTimeData addObject:[NSNumber numberWithInt:0]];
    [_AVGBeforeFirstTickData addObject:[NSNumber numberWithDouble:watchedEquity.snapshot.referencePrice]];
    
    //sec Tick time:first Tick Time, price:參考價
    [_AVGBeforeFirstTickTimeData addObject:[NSNumber numberWithUnsignedInt:tick.time+1]];
    [_AVGBeforeFirstTickData addObject:[NSNumber numberWithDouble:watchedEquity.snapshot.referencePrice]];
    
    [_AVGBeforeFirstTickTimeData addObject:[NSNumber numberWithUnsignedInt:tick.time+1]];
    [_AVGBeforeFirstTickData addObject:[_averagePrices objectAtIndex:0]];
}

#pragma mark  - AVL

- (void)computeAVL
{
    double totalPrice = 0.0f;
    double totalVolume = 0.0f;
    double oldVol = 0.0f;
    
    [_averagePrices removeAllObjects];

    
#ifdef LPCB
    
    for (NSUInteger tickCounter=0; tickCounter < [_dataSource.ticksData count]; tickCounter++) {
        FSTickData *tick = (FSTickData *)[_dataSource.ticksData objectAtIndex:tickCounter];
        if (_portfolioItem->type_id == 6) {
            if (tick.dealValue.calcValue>0) {
                totalPrice = totalPrice + tick.indexValue.calcValue * (tick.dealValue.calcValue - oldVol);
                totalVolume = tick.dealValue.calcValue;
                oldVol =tick.dealValue.calcValue;
            }
            
        }else{
            totalPrice = totalPrice + tick.last.calcValue * (tick.accumulated_volume.calcValue - oldVol);
            totalVolume = tick.accumulated_volume.calcValue;
            oldVol =tick.accumulated_volume.calcValue;
        }
        
        
        double AVL=totalPrice/totalVolume;
        
        //NSLog(@"AVL:%f",AVL);
        [_averagePrices addObject:@(AVL)];
    }
    
#else 
    
    for (NSUInteger tickCounter=1; tickCounter <= _dataSource.tickCount; tickCounter++) {
        
        EquityTickDecompressed * tick = (EquityTickDecompressed *)[_dataSource copyTickAtSequenceNo:tickCounter];
        totalPrice = totalPrice + tick.price*([self getRealValue:tick.volume Unit:tick.volumeUnit]-oldVol);
        totalVolume = [self getRealValue:tick.volume Unit:tick.volumeUnit];
        double AVL=totalPrice/totalVolume;
        oldVol =[self getRealValue:tick.volume Unit:tick.volumeUnit];
        //NSLog(@"AVL:%f",AVL);
        [_averagePrices addObject:@(AVL)];
    }
#endif
    
    
}

-(double)getRealValue:(double)value Unit:(NSInteger)unit
{
	double realValue = value * pow(1000, unit);
	return realValue;
}

#pragma mark - Tick

-(void)prepareTickBoxByTime{

    [dataLock lock];
    UInt16 time = 0;
    NSInteger lastTick = -1;
    [_tickStoreInSameTime removeAllObjects];
    
#ifdef LPCB
//        for (NSUInteger tickCounter = 1; tickCounter < [_dataSource.ticksData count]; tickCounter++) {
    for (NSUInteger tickCounter = 0; tickCounter < [_dataSource.ticksData count]; tickCounter++) {

        FSTickData *tick = (FSTickData *)[_dataSource.ticksData objectAtIndex:tickCounter];
        
        if (tick != nil) {
            if ([tick.time absoluteMinutesTime]<=_chartCloseTime) {
                lastTick = tickCounter;
                if ([tick.time absoluteMinutesTime]-_chartOpenTime != time) {
//                    if(tickCounter>1){
                    
                        FSTickData *newTick = [_dataSource.ticksData objectAtIndex:tickCounter];
                        
                        if ( newTick != nil) {
                            [_tickStoreInSameTime addObject:newTick];
                        }
//                    }
                    if (time ==0 && [_tickStoreInSameTime count]==0){
                        [_tickStoreInSameTime addObject:@(0)];
                    }
                    if ([tick.time absoluteMinutesTime]-time!=1) {
                        int maxTime = [tick.time absoluteMinutesTime] - (time + _chartOpenTime);
                        for (int j=1; j<maxTime; j++) {
                            if (!(time+_chartOpenTime>_chartBreakTime && time+_chartOpenTime<_chartReopenTime)) {
                                [_tickStoreInSameTime addObject:@(0)];
                            }
                            
                            time +=1;
                        }
                    }
                    time +=1;
                }
            }
        }
    }

    if (lastTick != -1) {
        FSTickData *lastNewTick = [_dataSource.ticksData objectAtIndex:lastTick];
        if (lastNewTick != nil) {
            [_tickStoreInSameTime addObject:lastNewTick];
        }
    }
    
#else
    for (NSUInteger tickCounter=1; tickCounter <= _dataSource.tickCount; tickCounter++) {
        
        EquityTickDecompressed * tick = (EquityTickDecompressed *)[_dataSource copyTickAtSequenceNo:tickCounter];
        if (tick != nil) {
            if (_chartOpenTime+tick.time<=_chartCloseTime) {
                lastTick = tickCounter;
                if (tick.time != time) {
                    if(tickCounter>1){
                        EquityTickDecompressed * newTick =(EquityTickDecompressed *)[_dataSource copyTickAtSequenceNo:tickCounter-1];
                        if ( newTick != nil) {
                            [_tickStoreInSameTime addObject:newTick];
                        }
                    }
                    if (time ==0 && [_tickStoreInSameTime count]==0){
                        [_tickStoreInSameTime addObject:@(0)];
                    }
                    if (tick.time-time!=1) {
                        int maxTime = tick.time-time;
                        for (int j=1; j<maxTime; j++) {
                            if (!(time+_chartOpenTime>_chartBreakTime && time+_chartOpenTime<_chartReopenTime)) {
                                [_tickStoreInSameTime addObject:@(0)];
                            }
                            
                            time +=1;
                        }
                    }
                    time +=1;
                }
            }
        }
    }
    EquityTickDecompressed * lastNewTick =(EquityTickDecompressed *)[_dataSource copyTickAtSequenceNo:lastTick];
    if (lastNewTick != nil) {
      [_tickStoreInSameTime addObject:lastNewTick];
    }
    
#endif
    
    [dataLock unlock];
}

-(void)prepareComparedTickBoxByTime{
    
    [dataLock lock];
    UInt16 time = 0;
    NSInteger lastTick = -1;
    [_comparedTickStoreInSameTime removeAllObjects];
    
#ifdef LPCB
//        for (NSUInteger tickCounter = 1; tickCounter < [_comparedDataSource.ticksData count]; tickCounter++) {
    for (NSUInteger tickCounter = 0; tickCounter < [_comparedDataSource.ticksData count]; tickCounter++) {
        FSTickData *tick = (FSTickData *)[_comparedDataSource.ticksData objectAtIndex:tickCounter];
        
        if (tick != nil) {
            if ([tick.time absoluteMinutesTime]<=_chartCloseTime) {
                lastTick = tickCounter;
                if ([tick.time absoluteMinutesTime]-_chartOpenTime != time) {
//                    if(tickCounter>1){
                    
                        FSTickData *newTick = [_comparedDataSource.ticksData objectAtIndex:tickCounter];
                        
                        if ( newTick != nil) {
                            [_comparedTickStoreInSameTime addObject:newTick];
                        }
//                    }
                    if (time ==0 && [_comparedTickStoreInSameTime count]==0){
                        [_comparedTickStoreInSameTime addObject:@(0)];
                    }
                    if ([tick.time absoluteMinutesTime]-time!=1) {
                        int maxTime = [tick.time absoluteMinutesTime] - (time + _chartOpenTime);
                        for (int j=1; j<maxTime; j++) {
                            if (!(time+_chartOpenTime>_chartBreakTime && time+_chartOpenTime<_chartReopenTime)) {
                                [_comparedTickStoreInSameTime addObject:@(0)];
                            }
                            
                            time +=1;
                        }
                    }
                    time +=1;
                }
            }
        }
    }
    if (lastTick >= 0) {
        FSTickData *lastNewTick = [_comparedDataSource.ticksData objectAtIndex:lastTick];
        if (lastNewTick != nil) {
            [_comparedTickStoreInSameTime addObject:lastNewTick];
        }
    }
    
#else
    for (NSUInteger tickCounter=1; tickCounter <= _comparedDataSource.tickCount; tickCounter++) {
        
        EquityTickDecompressed * tick = (EquityTickDecompressed *)[_comparedDataSource copyTickAtSequenceNo:tickCounter];
        if (tick != nil) {
            if (_chartOpenTime+tick.time<=_chartCloseTime) {
                lastTick = tickCounter;
                if (tick.time != time) {
                    if(tickCounter>1){
                        EquityTickDecompressed * newTick =(EquityTickDecompressed *)[_comparedDataSource copyTickAtSequenceNo:tickCounter-1];
                        if ( newTick != nil) {
                            [_comparedTickStoreInSameTime addObject:newTick];
                        }
                        
                    }
                    if (time ==0 && [_comparedTickStoreInSameTime count]==0){
                        [_comparedTickStoreInSameTime addObject:@(0)];
                    }
                    if (tick.time-time!=1) {
                        int maxTime = tick.time-time;
                        for (int j=1; j<maxTime; j++) {
                            if (!(time+_chartOpenTime>_chartBreakTime && time+_chartOpenTime<_chartReopenTime)) {
                                [_comparedTickStoreInSameTime addObject:@(0)];
                            }
                            time +=1;
                        }
                    }
                    time +=1;
                }
            }
        }
        
    }
    EquityTickDecompressed * lastNewTick =(EquityTickDecompressed *)[_comparedDataSource copyTickAtSequenceNo:lastTick];
    if (lastNewTick != nil) {
        [_comparedTickStoreInSameTime addObject:lastNewTick];
    }
#endif
    [dataLock unlock];
    
}


#pragma mark - Volume

-(void)prepareVolume{
    [self computeAVL];
    [self computeVolume];
    [self computeComparedItemVolume];
    [self.delegate scaleVolumeAndShow];
    [self.delegate reloadVolumeGraph];
}

- (void)computeVolume
{
    [dataLock lock];
    double oldVol = 0;
    UInt16 time = 0;
    double sameTimeVol = 0;
    double maxVolume = 0.0f;
    double realVol=0.0;
   
    [_volumeStore removeAllObjects];
    [_volumeStoreInSameTime removeAllObjects];
    
#ifdef LPCB
    for (int i=0; i<[_dataSource.ticksData count]; i++) {
        FSTickData * tick = [[FSTickData alloc]init];
        tick = [_dataSource.ticksData objectAtIndex:i];
        if (tick != nil) {
            int tickTime = [tick.time absoluteMinutesTime];
            int tickTimeBeginOpen = [tick.time absoluteMinutesTime]-_chartOpenTime;
            if (_portfolioItem->type_id == 6) {
                if(tick.dealValue.calcValue>0){
                    realVol = tick.dealValue.calcValue-oldVol;
                    oldVol = tick.dealValue.calcValue;
                }
                
            }else{
                realVol = tick.accumulated_volume.calcValue-oldVol;
                oldVol = tick.accumulated_volume.calcValue;
            }
            
            
            if (tickTime<=_chartCloseTime) {
                if (tickTimeBeginOpen == time) {
                    sameTimeVol += realVol;
                }else{
                    [_volumeStoreInSameTime addObject:@(sameTimeVol)];
                    sameTimeVol = realVol;
                    if (tickTimeBeginOpen-time!=1) {
                        int maxTime = tickTimeBeginOpen-time;
                        for (int j=1; j<maxTime; j++) {
                            [_volumeStoreInSameTime addObject:@(0)];
                            time +=1;
                            //                    sameTimeVol = 0;
                        }
                    }else{
                        sameTimeVol = realVol;
                        
                    }
                    time +=1;
                }
                
                if (sameTimeVol > maxVolume) {
                    maxVolume = sameTimeVol;
                }
                
                
                [_volumeStore addObject:@(realVol)];
            }
        }
        
    }
    [_volumeStoreInSameTime addObject:@(sameTimeVol)];
    
#else
   
    for (NSUInteger tickCounter=1; tickCounter <= _dataSource.tickCount; tickCounter++) {
        
        realVol=0.0;
        
        EquityTickDecompressed * tick = (EquityTickDecompressed *)[_dataSource copyTickAtSequenceNo:tickCounter];
        if (tick != nil) {
            
            realVol = [self getRealValue:tick.volume Unit:tick.volumeUnit]-oldVol;
            oldVol = [self getRealValue:tick.volume Unit:tick.volumeUnit];
            
            if (_chartOpenTime+tick.time<=_chartCloseTime) {
                if (tick.time == time) {
                    sameTimeVol += realVol;
                }else{
                    [_volumeStoreInSameTime addObject:@(sameTimeVol)];
                    sameTimeVol = realVol;
                    if (tick.time-time!=1) {
                        int maxTime = tick.time-time;
                        for (int j=1; j<maxTime; j++) {
                            [_volumeStoreInSameTime addObject:@(0)];
                            time +=1;
                            //                    sameTimeVol = 0;
                        }
                    }else{
                        sameTimeVol = realVol;
                        
                    }
                    time +=1;
                }
                
                if (sameTimeVol > maxVolume) {
                    maxVolume = sameTimeVol;
                }
                
                
                [_volumeStore addObject:@(realVol)];
            }
        }
        
    }
    
    [_volumeStoreInSameTime addObject:@(sameTimeVol)];
#endif
    
    self.maxMainVolume = maxVolume;

    [dataLock unlock];
}



- (void)computeComparedItemVolume
{
    [dataLock lock];
    double maxVolume = 0.0f;
    double oldVol = 0;
    UInt16 time = 0;
    double sameTimeVol = 0;
    double realVol = 0.0;
    
    [_comparedVolumeStore removeAllObjects];
    [_comparedVolumeStoreInSameTime removeAllObjects];
    
#ifdef LPCB
    for (int i=0; i<[_comparedDataSource.ticksData count]; i++) {
        realVol=0.0;
        FSTickData * tick = [[FSTickData alloc]init];
        tick = [_comparedDataSource.ticksData objectAtIndex:i];
//        FSTickData * tick = (FSTickData *)[_comparedDataSource.ticksData objectAtIndex: i];
        if (tick != nil) {
            int tickTime = [tick.time absoluteMinutesTime];
            int tickTimeBeginOpen = [tick.time absoluteMinutesTime]-_chartOpenTime;
            if (_comparedPortfolioItem->type_id == 6) {
                if(tick.dealValue.calcValue>0){
                    realVol = tick.dealValue.calcValue-oldVol;
                    oldVol = tick.dealValue.calcValue;
                }
            }else{
                realVol = tick.accumulated_volume.calcValue-oldVol;
                oldVol = tick.accumulated_volume.calcValue;
            }
            
            if (tickTime<=_chartCloseTime) {
                if (tickTimeBeginOpen == time) {
                    sameTimeVol += realVol;
                }else{
                    [_comparedVolumeStoreInSameTime addObject:@(sameTimeVol)];
                    sameTimeVol = realVol;
                    if (tickTimeBeginOpen-time!=1) {
                        int maxTime = tickTimeBeginOpen-time;
                        for (int j=1; j<maxTime; j++) {
                            [_comparedVolumeStoreInSameTime addObject:@(0)];
                            time +=1;
                            //sameTimeVol = 0;
                        }
                    }else{
                        sameTimeVol = realVol;
                    }
                    time +=1;
                }
                
                if (sameTimeVol > maxVolume) {
                    maxVolume = sameTimeVol;
                }
                
                
                [_comparedVolumeStore addObject:@(realVol)];
            }
        }
    }
    [_comparedVolumeStoreInSameTime addObject:@(sameTimeVol)];
    
#else
    
    for (NSUInteger tickCounter=1; tickCounter <= _comparedDataSource.tickCount; tickCounter++) {
        
        realVol=0.0;
        
        EquityTickDecompressed * tick = (EquityTickDecompressed *)[_comparedDataSource copyTickAtSequenceNo:tickCounter];
        if (tick != nil) {
            realVol = [self getRealValue:tick.volume Unit:tick.volumeUnit]-oldVol;
            oldVol = [self getRealValue:tick.volume Unit:tick.volumeUnit];
            
            if (_chartOpenTime+tick.time<=_chartCloseTime) {
                if (tick.time == time) {
                    sameTimeVol += realVol;
                }else{
                    [_comparedVolumeStoreInSameTime addObject:@(sameTimeVol)];
                    sameTimeVol = realVol;
                    if (tick.time-time!=1) {
                        int maxTime = tick.time-time;
                        for (int j=1; j<maxTime; j++) {
                            [_comparedVolumeStoreInSameTime addObject:@(0)];
                            time +=1;
                            //sameTimeVol = 0;
                        }
                    }else{
                        sameTimeVol = realVol;
                    }
                    time +=1;
                }
                
                if (sameTimeVol > maxVolume) {
                    maxVolume = sameTimeVol;
                }
                
                
                [_comparedVolumeStore addObject:@(realVol)];
            }
        }
    }
    [_comparedVolumeStoreInSameTime addObject:@(sameTimeVol)];
#endif
    
    self.maxComparedVolume = maxVolume;
    if(self.delegate && [self.delegate respondsToSelector:@selector(scaleComparedVolumeGraphToFitComparedVolume)]){
        [self.delegate scaleComparedVolumeGraphToFitComparedVolume];
    }
    [dataLock unlock];
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
        self.totalTime = _chartCloseTime - _chartOpenTime + 1;
    }
    else {
        _chartBreakTime = market->endTime_1;
        _chartReopenTime = market->startTime_2;
        _chartCloseTime = market->endTime_2;
        self.totalTime = (_chartBreakTime - _chartOpenTime + 1) + (_chartCloseTime - _chartReopenTime + 1);
    }
    
    
    if (!drawGridLine) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(drawXAxisGridLineOnPriceGraph)]){
            [_delegate drawXAxisGridLineOnPriceGraph];
            drawGridLine=YES;
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(drawXAxisGridLineOnVolumeGraph)]){
            [_delegate drawXAxisGridLineOnVolumeGraph];
            drawGridLine=YES;
        }
        
    }
    

    
}

@end
