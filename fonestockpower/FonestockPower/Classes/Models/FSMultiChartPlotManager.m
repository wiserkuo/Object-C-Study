//
//  FSMultiChartCellDataSourceManager.m
//  Bullseye
//
//  Created by KevinShen on 13/8/13.
//
//

#import "FSMultiChartPlotManager.h"
#import "FSMultiChartPlotData.h"

@implementation FSMultiChartPlotManager

+ (FSMultiChartPlotManager *)sharedInstance
{
    static dispatch_once_t onceQueue;
    static FSMultiChartPlotManager *fSMultiChartCellDataSourceManager = nil;
    
    dispatch_once(&onceQueue, ^{ fSMultiChartCellDataSourceManager = [[self alloc] init]; });
    return fSMultiChartCellDataSourceManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.plotDataSources = [NSMutableArray array];
    }
    return self;
}

/**
 *  幫每個小走勢圖產生一個用來裝tick資料的data source
 *
 *  @param void
 *
 *  @return  
 */

- (void)generatePlotDataSourceForItem:(NSObject<FSWatchlistItemProtocol> *) watchlistItem
{
    //產生plot資料源以及graph(畫走勢)
    NSMutableArray *newPlotDataSources = [NSMutableArray array];
    for (NSInteger itemCounter=0 ; itemCounter < [watchlistItem count]; itemCounter++) {
        PortfolioItem *item = [watchlistItem portfolioItem:[NSIndexPath indexPathForRow:itemCounter inSection:0]];
        
        FSMultiChartPlotData *existedDataSource = [self findPlotDataInplotDataSources:[item getIdentCodeSymbol]];
        if (existedDataSource != nil) {
            [newPlotDataSources addObject:existedDataSource];
        }
        else {
            FSMultiChartPlotData *newDataSource = [[FSMultiChartPlotData alloc] initWithPortfolioItem:item];
            newDataSource.delegate = self;
            [newPlotDataSources addObject:newDataSource];
        }
    }
    //找出那些不再使用的dataSource，並且stopWatch
    [_plotDataSources removeObjectsInArray:newPlotDataSources];
    for (FSMultiChartPlotData *abandonedDataSource in _plotDataSources) {
        [abandonedDataSource stopWatch];
    }
    //採用新的陣列，等一下CollectionView的model會從這裡拿資料
    self.plotDataSources = newPlotDataSources;
}

-(FSMultiChartPlotData *)findPlotDataInplotDataSources:(NSString *) IdentCodeSymbolOfPortfolioItem
{
    //在原本的plotDataSource裡尋找有沒有已存在的
    for (NSInteger plotDataSourceCounter=0; plotDataSourceCounter < [_plotDataSources count]; plotDataSourceCounter++) {
        FSMultiChartPlotData *existedDataSource = _plotDataSources[plotDataSourceCounter];
        if ([[existedDataSource.portfolioItem getIdentCodeSymbol] isEqualToString:IdentCodeSymbolOfPortfolioItem]) {
            return existedDataSource;
        }
    }
    return nil;
}

- (void)watchEquityForAllItems
{
    [_plotDataSources makeObjectsPerformSelector:@selector(startWatch)];
    NSMutableArray *equities = [NSMutableArray array];
    for (FSMultiChartPlotData *plotData in _plotDataSources) {
        [equities addObject:[plotData.portfolioItem getIdentCodeSymbol]];
    }
//    [[DataModalProc getDataModal].portfolioData addWatchListItemByIdentSymbolArray:equities];
}

/**
 *  確保只有目前被看到的items收tick，不然server負擔會太重
 *
 *  @param indexPaths 目前可見的items indexPath陣列
 */
- (void)watchEquityForVisibleItems:(NSArray *) indexPaths
{
    /*如果表格還沒準備好，那麼visibleIndexPaths會是0。
     為了要能正常抓數據，算出第一頁的item數最多為9個，就抓最多9個的tick
     */
    if ([_plotDataSources count] > 0 && [indexPaths count] == 0) {
        NSInteger firstPageItemCount = [_plotDataSources count] < 9 ? [_plotDataSources count] : 9;
        for (NSInteger counter=0 ; counter < firstPageItemCount; counter++) {
            FSMultiChartPlotData *dataSource = _plotDataSources[counter];
            [dataSource startWatch];
        }
    }
    else {
        //只有目前被看到的Item收tick
        for (NSIndexPath *indexPath in indexPaths) {
            FSMultiChartPlotData *dataSource = _plotDataSources[indexPath.row];
            [dataSource startWatch];
        }
    }
}

- (void)stopWatchEquityForAllItems
{
    //所有datasource先暫時停止收tick
    [_plotDataSources makeObjectsPerformSelector:@selector(stopWatch)];
}

/**
 *  實作FSMultiChartPlotDataArriving，當FSMultiChartPlotData收到tick時，呼叫此delegate，藉此讓cell更新資料
 *
 *  @param multiChartPlotData 呼叫此delegate method的multiChartPlotData
 *  @param dataSource         該multiChartPlotData所收到的tick dataSource
 */
- (void)multiChartPlotData:(FSMultiChartPlotData *) multiChartPlotData dataSource:(NSObject <TickDataSourceProtocol> *)dataSource
{
    NSUInteger index = [_plotDataSources indexOfObject:multiChartPlotData];
    if (index < [_plotDataSources count]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(reloadCellAtIndex:)])
        {
            [self.delegate reloadCellAtIndex:index];
        }
    }
}

@end
