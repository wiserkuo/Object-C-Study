//
//  FSPriceByVolumeTableViewController.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/5.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSPriceByVolumeTableViewController.h"
#import "FSArrayTableViewDataSource.h"
#import "FSPriceByVolumeTableViewCell.h"
#import "FSPriceByVolumeData.h"
#import "EquityTick.h"
#import "FSPriceByVolumeTableViewDelegate.h"
#import "MarketInfo.h"
#import "FSEquityInfoPanel.h"
#import "TradeDistribute.h"
#import "TradeDistributeIn.h"
#import "DDPageControl.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSBAQuery.h"

static NSString *cellIdentifier = @"FSPriceByVolumeTableViewCell";
static float E = 0.001;//精確度

@interface FSPriceByVolumeTableViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSObject <TickDataSourceProtocol> *tickData;
    BOOL hasPlat;
    FSBAQuery * baQuery;
}
@property (nonatomic, strong) FSArrayTableViewDataSource *tableViewDataSource;
@property (nonatomic, strong) FSPriceByVolumeTableViewDelegate *tableViewDelegate;
@property (nonatomic, strong) UIView *priceByVolumeTableViewHeaderView;
@property (nonatomic, strong) FSEquityInfoPanel *infoPanel;
@property (nonatomic, strong) NSMutableArray *tickPriceVolumeData;
@property (nonatomic, strong) NSMutableArray *groupPriceVolumeData;
@property (strong, nonatomic) DDPageControl *pageControl;
@property (strong, nonatomic) FSInstantInfoWatchedPortfolio * warchPortfolio;
@property (strong, nonatomic) EquitySnapshotDecompressed * symbolSnapshot;
@end

@implementation FSPriceByVolumeTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    baQuery = [[FSBAQuery alloc]init];
    self.warchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    self.tickPriceVolumeData = [[NSMutableArray alloc]init];
    self.groupPriceVolumeData = [[NSMutableArray alloc]init];
    [self addHeaderView];
    [self addPriceByVolumeTableView];
    [self addInfoPanel];
    [self setLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [self registerTickDataNotificationCallBack:self seletor:@selector(reloadData)];
    if (_warchPortfolio.portfolioItem != nil){
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"Equity", nil)];
        [_tickPriceVolumeData removeAllObjects];
        [_groupPriceVolumeData removeAllObjects];
#ifdef LPCB
        [[[FSDataModelProc sharedInstance]portfolioTickBank] setTaget:self IdentCodeSymbol:[_warchPortfolio.portfolioItem getIdentCodeSymbol]];
        [[[FSDataModelProc sharedInstance]portfolioTickBank] updateTickDataByIdentCodeSymbol:[_warchPortfolio.portfolioItem getIdentCodeSymbol]];
        
        [dataModal.category setTargetObj:self];
        [dataModal.category searchSectorIdByIdentCode:[NSString stringWithFormat:@"%c%c",_warchPortfolio.portfolioItem->identCode[0],_warchPortfolio.portfolioItem->identCode[1]] Symbol:_warchPortfolio.portfolioItem->symbol];
#else
        [[[FSDataModelProc sharedInstance]portfolioTickBank] watchTarget:self ForEquity:[_warchPortfolio.portfolioItem getIdentCodeSymbol] GetTick:YES];
#endif
        
    }
    EquityTick * equityTick = [dataModal.portfolioTickBank getEquityTick:[_warchPortfolio.portfolioItem getIdentCodeSymbol]];
    
    [self setDefaultData:equityTick.ticksData];
    [_priceByVolumeTableView reloadData];
//    [self configureTableViewDelegate];
    //[self startWatch];
    [self initPageControll];
}

-(void)reloadData{
    [_priceByVolumeTableView reloadData];
}

- (void)initPageControll {
    self.infoPanel.delegate = self;
    self.pageControl = [[DDPageControl alloc] init];
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]) {
        self.pageControl.numberOfPages = 2;
    }
    else if([group isEqualToString:@"tw"]){
        PortfolioItem * portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        if (portfolioItem->type_id == 6) {
            self.pageControl.numberOfPages = 2;
        }else if (portfolioItem->type_id == 3){
            self.pageControl.numberOfPages = 1;
        }else{
            self.pageControl.numberOfPages = 4;
        }
    }else{
        self.pageControl.numberOfPages = 5;
    }
    
    self.pageControl.currentPage = 0;
    
    [self.pageControl setDefersCurrentPageDisplay: YES] ;
	[self.pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
	[self.pageControl setOnColor: [UIColor redColor]];
	[self.pageControl setOffColor: [UIColor redColor]];
	[self.pageControl setIndicatorDiameter: 7.0f] ;
	[self.pageControl setIndicatorSpace: 7.0f] ;
    
    [self.view addSubview:self.pageControl];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
	CGFloat pageWidth = self.infoPanel.bounds.size.width;
    float fractionalPage = self.infoPanel.contentOffset.x / pageWidth;
	NSInteger nearestNumber = lround(fractionalPage);
	
	if (self.pageControl.currentPage != nearestNumber) {
		self.pageControl.currentPage = nearestNumber;
		if (self.infoPanel.dragging) {
			PortfolioItem * portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
			[self.pageControl updateCurrentPageDisplay] ;
            if (nearestNumber ==2) {//瀏覽最佳五檔
                [baQuery sendWithIdentCodeSymbol:[portfolioItem getIdentCodeSymbol]];
                [portfolioItem setFocus];
            }else if(fractionalPage>=1 && fractionalPage <4){
                [portfolioItem killFocus];
            }
        }
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView {
    
	[self.pageControl updateCurrentPageDisplay] ;
}

-(double)getRealValue:(double)value Unit:(NSInteger)unit
{
	double realValue = value * pow(1000, unit);
	return realValue;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unRegisterTickDataNotificationCallBack:nil];
    if (_warchPortfolio.portfolioItem != nil) {
#ifdef LPCB
        [[[FSDataModelProc sharedInstance]portfolioTickBank] removeKeyWithTaget:self IdentCodeSymbol:[_warchPortfolio.portfolioItem getIdentCodeSymbol]];
#else
        [[[FSDataModelProc sharedInstance]portfolioTickBank] stopWatch:self ForEquity:[_warchPortfolio.portfolioItem getIdentCodeSymbol]];

#endif
        
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Init

- (void)addPriceByVolumeTableView
{
    self.priceByVolumeTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
//    if ([self.priceByVolumeTableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.priceByVolumeTableView setSeparatorInset:UIEdgeInsetsZero];
//    }
    
    _priceByVolumeTableView.translatesAutoresizingMaskIntoConstraints = NO;
//    [_priceByVolumeTableView registerClass:[FSPriceByVolumeTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    _priceByVolumeTableView.bounces = NO;
    _priceByVolumeTableView.delegate = self;
    _priceByVolumeTableView.dataSource = self;
    [self.view addSubview:_priceByVolumeTableView];
}

- (void)addHeaderView
{
    
    PortfolioItem * portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    CGRect headerViewFrame = CGRectMake(0, 0, self.view.bounds.size.width, 33);
    self.priceByVolumeTableViewHeaderView = [[UIView alloc] initWithFrame:headerViewFrame];
    _priceByVolumeTableViewHeaderView.backgroundColor = [UIColor colorWithRed:0.044 green:0.337 blue:0.442 alpha:1.000];
    CGFloat offset;
    if (portfolioItem->identCode[0]=='T' && portfolioItem->identCode[1]=='W') {
        offset = self.view.bounds.size.width/5;
        for (NSUInteger labelCounter=0; labelCounter < 5; labelCounter++) {
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(offset * labelCounter, 0, offset, 33);
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            
            switch (labelCounter) {
                case 0:
                    label.text = NSLocalizedStringFromTable(@"成價", @"Equity", @"");
                    break;
                case 1:
                    label.text = NSLocalizedStringFromTable(@"成量", @"Equity", @"");
                    break;
                case 2:
                    label.text = NSLocalizedStringFromTable(@"比例", @"Equity", @"");
                    break;
                case 3:
                    label.text = NSLocalizedStringFromTable(@"內盤", @"Equity", @"");
                    break;
                case 4:
                    label.text = NSLocalizedStringFromTable(@"外盤", @"Equity", @"");
                    break;
                default:
                    break;
            }
            [_priceByVolumeTableViewHeaderView addSubview:label];
        }
    }else{
        offset = self.view.bounds.size.width/4;
        for (NSUInteger labelCounter=0; labelCounter < 3; labelCounter++) {
            UILabel *label = [[UILabel alloc] init];
            if (labelCounter==0) {
                label.frame = CGRectMake(offset*labelCounter, 0, offset*2, 33);
                label.textAlignment = NSTextAlignmentCenter;
            }else{
                label.frame = CGRectMake(offset*(labelCounter+1), 0, offset, 33);
                label.textAlignment = NSTextAlignmentLeft;
            }
            
            label.textColor = [UIColor whiteColor];
            
            switch (labelCounter) {
                case 0:
                    label.text = NSLocalizedStringFromTable(@"成價", @"Equity", @"");
                    break;
                case 1:
                    label.text = NSLocalizedStringFromTable(@"成量", @"Equity", @"");
                    break;
                case 2:
                    label.text = NSLocalizedStringFromTable(@"比例", @"Equity", @"");
                    break;
                    
                default:
                    break;
            }
            [_priceByVolumeTableViewHeaderView addSubview:label];
        }
    }
    
    
}

- (void)addInfoPanel
{
    self.infoPanel = [[FSEquityInfoPanel alloc] initWithPortfolioItem:_warchPortfolio.portfolioItem];
    _infoPanel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_infoPanel];
}

#pragma mark - TableViewDataSource and Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FSPriceByVolumeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FSPriceByVolumeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    double referencePrice = 0, ceilingPrice = 0, floorPrice = 0;
    
#ifdef LPCB
    
    
    double totalVol = 0;
    PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
    FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:[_warchPortfolio.portfolioItem getIdentCodeSymbol]];
    if (snapshot) {
        totalVol = snapshot.accumulated_volume.calcValue;
        referencePrice = snapshot.reference_price.calcValue;
    }
    
#else
    PortfolioTick * pt =[[FSDataModelProc sharedInstance]portfolioTickBank];
    EquityTick * equityTick =[pt getEquityTick:[_warchPortfolio.portfolioItem getIdentCodeSymbol]];
    double totalVol = [self getRealValue:equityTick.snapshot.accumulatedVolume Unit:equityTick.snapshot.accumulatedVolumeUnit];
    referencePrice = equityTick.snapshot.referencePrice;
    ceilingPrice = equityTick.snapshot.ceilingPrice;
    floorPrice = equityTick.snapshot.floorPrice;
#endif

    
    
    PortfolioItem * p = _warchPortfolio.portfolioItem;
    if (p->identCode[0] == 'T' && p->identCode[1]=='W') {
        cell.hasPlat = YES;
            
        TradeDistributeParam *data = (TradeDistributeParam *)[_groupPriceVolumeData objectAtIndex:indexPath.row];
#ifdef LPCB
        cell.priceLabel.text = [NSString stringWithFormat:@"%.2f %@",data->price,[self signByExamingPrice:data->price equalToOpenPrice:snapshot.open_price.calcValue closePrice:snapshot.last_price.calcValue]];
#else
        cell.priceLabel.text = [NSString stringWithFormat:@"%.2f %@",data->price,[self signByExamingPrice:data->price equalToOpenPrice:equityTick.snapshot.openPrice closePrice:equityTick.snapshot.currentPrice]];
#endif

        if (data->price>referencePrice) {
            cell.priceLabel.textColor = [StockConstant PriceUpColor];
        }else if(data->price<referencePrice){
            cell.priceLabel.textColor = [StockConstant PriceDownColor];
        }else{
            cell.priceLabel.textColor = [UIColor blackColor];
        }
        
        if (data->price == ceilingPrice) {
            cell.priceLabel.backgroundColor = [StockConstant PriceUpColor];
            cell.priceLabel.textColor =[UIColor whiteColor];
        }else if (data->price == floorPrice){
            cell.priceLabel.backgroundColor = [StockConstant PriceDownColor];
            cell.priceLabel.textColor =[UIColor whiteColor];
        }
        
        cell.volumeLabel.text = [CodingUtil stringWithVolumeByValue2:data->volume];
        cell.percentageLabel.text = [NSString stringWithFormat:@"%.1f%%", (data->volume/totalVol)*100];
        cell.innerLabel.text = [CodingUtil stringWithVolumeByValue2:data->innerVolume];
        cell.outerLabel.text = [CodingUtil stringWithVolumeByValue2:data->outerVolume];
    }else{
            NewTradeDistributeParam *data = (NewTradeDistributeParam *)[_groupPriceVolumeData objectAtIndex:indexPath.row];
            cell.priceLabel.text = data->price;
            if (data->highPrice>referencePrice) {
                cell.priceLabel.textColor = [StockConstant PriceUpColor];
            }else if(data->highPrice<referencePrice){
                cell.priceLabel.textColor = [StockConstant PriceDownColor];
            }else{
                cell.priceLabel.textColor = [UIColor blackColor];
            }
            
            cell.volumeLabel.text = [CodingUtil stringWithVolumeByValue2:data->volume];
            cell.percentageLabel.text = [NSString stringWithFormat:@"%.1f%%", (data->volume/totalVol)*100];
    }
    
    return cell;
}


- (BOOL)isMarketClosed:(UInt16) time marketId:(UInt16) marketId
{
    return [[[FSDataModelProc sharedInstance]marketInfo] isTickTime:time EqualToMarketClosedTime:marketId];
}

- (NSString *)signByExamingPrice:(double) price equalToOpenPrice:(double) openPrice closePrice:(double) closePrice
{
    if ((price==openPrice) && (price==closePrice) && (openPrice == closePrice)) { //開收等價
        return @"=";
    }
    else if (price == openPrice) { //價格等於開盤價，加上*
        return @"*";
    }
    else if (price == closePrice) { //價格等於收盤價，加上#
        return @"#";
    }
    return @"";
}

- (NSString *)signByExamingBetweenLowPrice:(double) lowPrice HighPrice:(double) highPrice
{
    
#ifdef LPCB
    
    PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
    FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:tickData.getIdenCodeSymbol];

    if ((snapshot.open_price.calcValue==snapshot.last_price.calcValue) && snapshot.open_price.calcValue > lowPrice && snapshot.open_price.calcValue<=highPrice) { //開收等價
        return @"=";
    }
    else if (snapshot.open_price.calcValue > lowPrice && snapshot.open_price.calcValue<=highPrice) { //價格等於開盤價，加上*
        return @"*";
    }
    else if (snapshot.last_price.calcValue > lowPrice && snapshot.last_price.calcValue<=highPrice) { //價格等於收盤價，加上#
        return @"#";
    }
    return @"";
#else
    if ((_symbolSnapshot.openPrice==_symbolSnapshot.currentPrice) && _symbolSnapshot.openPrice > lowPrice && _symbolSnapshot.openPrice<=highPrice) { //開收等價
        return @"=";
    }
    else if (_symbolSnapshot.openPrice > lowPrice && _symbolSnapshot.openPrice<=highPrice) { //價格等於開盤價，加上*
        return @"*";
    }
    else if (_symbolSnapshot.currentPrice > lowPrice && _symbolSnapshot.currentPrice<=highPrice) { //價格等於收盤價，加上#
        return @"#";
    }
    return @"";
#endif

}

#pragma mark - Data arrive

-(void)sectorIdCallBack:(NSMutableArray *)dataArray{
    [_infoPanel reloadMarketInfo:dataArray];
}

- (void)notifyDataArrive:(NSObject <TickDataSourceProtocol> *)dataSource
{
 
#ifdef LPCB
    
//    [dataSource lock];
    
    tickData = dataSource;
    [_tickPriceVolumeData removeAllObjects];
    
    PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
    FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:tickData.getIdenCodeSymbol];
    
    if (snapshot) {
        [_infoPanel reloadBValueSnapshot:snapshot];
    }
    
    NSInteger tickCount = [dataSource.ticksData count];
	double oldVolume = 0;
    
    PortfolioItem * p = _warchPortfolio.portfolioItem;
    if (p->identCode[0] == 'T' && p->identCode[1]=='W') {
        for (int tickCounter = 0; tickCounter < tickCount; tickCounter++)
        {
            double tickPrice = 0.0, volume = 0.0,  m= 0.0, innerUpperPrice = 0.0 ;
//            UInt16 tmpVolUnit;
            
            FSTickData * tick = [tickData.ticksData objectAtIndex:tickCounter];
            if(tick.type == FSTickType3){
                tickPrice =tick.last.calcValue;
                volume = tick.accumulated_volume.calcValue;
                m =(MAX(tick.bid.calcValue, tick.ask.calcValue)-MIN(tick.bid.calcValue, tick.ask.calcValue));
                innerUpperPrice = tick.bid.calcValue + m/2.0f;
            }else{
                tickPrice =tick.indexValue.calcValue;
                volume = tick.dealValue.calcValue;
                innerUpperPrice = tick.bid.calcValue;
            }
            
//            double volume = [self getRealValue:tmpVol Unit:tmpVolUnit];
            
            
            if(oldVolume == volume)
            {
                continue;
            }
            else if(oldVolume<volume)
            {
                double temp = oldVolume;
                oldVolume = volume;
                volume -= temp;
            }
            else
            {
//                continue;
                //			oldVolume += volume;
            }
            
            int count = (int)[_tickPriceVolumeData count];
            if(count == 0) // 空的 直接塞
            {
                TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                paramtemp->price = tickPrice;
                paramtemp->volume = volume;
                if (tick.type == FSTickType3) {
                    if (tick.bid.calcValue ==0 || tick.ask.calcValue==0) {
                        if (tickPrice<=snapshot.reference_price.calcValue) {
                            paramtemp->innerVolume = volume;
                        }else{
                            paramtemp->outerVolume = volume;
                        }
                    }else{
                        if (tickPrice <=innerUpperPrice) {
                            paramtemp->innerVolume = volume;
                        }else{
                            paramtemp->outerVolume = volume;
                        }
                    }
                }else{
                    if (tickPrice <=innerUpperPrice) {
                        paramtemp->innerVolume = volume;
                    }else{
                        paramtemp->outerVolume = volume;
                    }
                }
                
                
                [_tickPriceVolumeData addObject:paramtemp];
                //break;
                continue;
            }
            else
            {
                for(int index=0; index<count; index++)
                {
                    TradeDistributeParam* param = [_tickPriceVolumeData objectAtIndex:index];
                    
                    if(fabs(tickPrice-param->price)<E)
                    {
                        param->volume += volume;
                        if (tick.type == FSTickType3) {
                            if (tick.bid.calcValue ==0 || tick.ask.calcValue==0) {
                                if (tickPrice<=snapshot.reference_price.calcValue) {
                                    param->innerVolume += volume;
                                }else{
                                    param->outerVolume += volume;
                                }
                            }else{
                                if (tickPrice <=innerUpperPrice) {
                                    param->innerVolume += volume;
                                }else{
                                    param->outerVolume += volume;
                                }
                            }
                        }else{
                            if (tickPrice <=innerUpperPrice) {
                                param->innerVolume += volume;
                            }else{
                                param->outerVolume += volume;
                            }
                        }
                        
                        
                        
                        break;
                    }
                    else if(tickPrice>param->price)
                    {
                        TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                        paramtemp->price = tickPrice;
                        paramtemp->volume = volume;
                        if (tick.type == FSTickType3) {
                            if (tick.bid.calcValue ==0 || tick.ask.calcValue==0) {
                                if (tickPrice<=snapshot.reference_price.calcValue) {
                                    paramtemp->innerVolume = volume;
                                }else{
                                    paramtemp->outerVolume = volume;
                                }
                            }else{
                                if (tickPrice <=innerUpperPrice) {
                                    paramtemp->innerVolume = volume;
                                }else{
                                    paramtemp->outerVolume = volume;
                                }
                            }
                        }else{
                            if (tickPrice <=innerUpperPrice) {
                                paramtemp->innerVolume = volume;
                            }else{
                                paramtemp->outerVolume = volume;
                            }
                        }
                        
                        [_tickPriceVolumeData insertObject:paramtemp atIndex:index];
                        break;
                    }
                    else{
                        
                    }
                    
                    if(index == count-1)
                    {
                        if(tickPrice<param->price)
                        {
                            TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                            paramtemp->price = tickPrice;
                            paramtemp->volume = volume;
                            if (tick.type == FSTickType3) {
                                if (tick.bid.calcValue ==0 || tick.ask.calcValue==0) {
                                    if (tickPrice<=snapshot.reference_price.calcValue) {
                                        paramtemp->innerVolume = volume;
                                    }else{
                                        paramtemp->outerVolume = volume;
                                    }
                                }else{
                                    if (tickPrice <=innerUpperPrice) {
                                        paramtemp->innerVolume = volume;
                                    }else{
                                        paramtemp->outerVolume = volume;
                                    }
                                }
                            }else{
                                if (tickPrice <=innerUpperPrice) {
                                    paramtemp->innerVolume = volume;
                                }else{
                                    paramtemp->outerVolume = volume;
                                }
                            }
                            
                            
                            
                            [_tickPriceVolumeData addObject:paramtemp];
                            break;
                        }
                    }
                }
            }
        }
    }else{
        for (int i = 0; i < tickCount; i++) {
            double tickPrice;
            double volume;
            
            FSTickData *tick = [tickData.ticksData objectAtIndex:i];
            
            if(tick.type == FSTickType3){
                tickPrice = tick.last.calcValue;
                volume = tick.accumulated_volume.calcValue;
            }else{
                tickPrice = tick.indexValue.calcValue;
                volume = tick.dealValue.calcValue;
            }
            
        
            if(oldVolume == volume)
            {
                continue;
            }
            else if(oldVolume<volume)
            {
                double temp = oldVolume;
                oldVolume = volume;
                volume -= temp;
            }
            else
            {
                continue;
                //oldVolume += volume;
            }
            
            int count = (int)[_tickPriceVolumeData count];
            if(count == 0) // 空的 直接塞
            {
                TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                paramtemp->price = tickPrice;
                paramtemp->volume = volume;
                [_tickPriceVolumeData addObject:paramtemp];
                //break;
                continue;
            }
            else
            {
                for(int index=0; index<count; index++)
                {
                    TradeDistributeParam* param = [_tickPriceVolumeData objectAtIndex:index];
                    
                    if(fabs(tickPrice-param->price)<E)
                    {
                        param->volume += volume;
                        break;
                    }
                    else if(tickPrice>param->price)
                    {
                        TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                        paramtemp->price = tickPrice;
                        paramtemp->volume = volume;
                        [_tickPriceVolumeData insertObject:paramtemp atIndex:index];
                        break;
                    }
                    
                    if(index == count-1)
                    {
                        if(tickPrice<param->price)
                        {
                            TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                            paramtemp->price = tickPrice;
                            paramtemp->volume = volume;
                            [_tickPriceVolumeData addObject:paramtemp];
                            break;
                        }
                    }
                }
            }
        }
    }
    
    if (dataSource.progress > 0.99){
        [self setDataToGroup];
    }
    
//    [dataSource unlock];
#else
    EquityTick *equityTick = (EquityTick *) dataSource;
    EquitySnapshotDecompressed *snapshot = ((EquityTick *) dataSource).snapshot;
    self.symbolSnapshot = snapshot;
    [_infoPanel reloadDataWithSnapshot:snapshot];
    
    [_tickPriceVolumeData removeAllObjects];
    [dataSource lock];
    NSInteger tickCount = dataSource.tickCount;
	double oldVolume = 0;
    for (int tickCounter = 1; tickCounter <= tickCount; tickCounter++)
    {
		double tickPrice,tmpVol;
		UInt16 tmpVolUnit;
		if(![dataSource getPriceVolume:&tickPrice Volume:&tmpVol VolUnit:&tmpVolUnit Sequence:tickCounter])
			continue;
		double volume = [self getRealValue:tmpVol Unit:tmpVolUnit];
        EquityTickDecompressed * tick = [equityTick copyTickAtSequenceNo:tickCounter];
        double m =(MAX(tick.bid, tick.ask)-MIN(tick.bid, tick.ask));
        double innerUpperPrice = tick.bid + m/2.0f;
        if(oldVolume == volume)
		{
			continue;
		}
		else if(oldVolume<volume)
		{
			double temp = oldVolume;
			oldVolume = volume;
			volume -= temp;
		}
		else
		{
            continue;
//			oldVolume += volume;
		}
		
		int count = [_tickPriceVolumeData count];
		if(count == 0) // 空的 直接塞
		{
			TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
			paramtemp->price = tickPrice;
			paramtemp->volume = volume;
            if (tick.bid ==0 || tick.ask==0) {
                if (tickPrice<=snapshot.referencePrice) {
                    paramtemp->innerVolume = volume;
                }else{
                    paramtemp->outerVolume = volume;
                }
            }else{
                if (tickPrice <=innerUpperPrice) {
                    paramtemp->innerVolume = volume;
                }else{
                    paramtemp->outerVolume = volume;
                }
            }
            
			[_tickPriceVolumeData addObject:paramtemp];
			//break;
			continue;
		}
		else
		{
			for(int index=0; index<count; index++)
			{
				TradeDistributeParam* param = [_tickPriceVolumeData objectAtIndex:index];
				
				if(fabs(tickPrice-param->price)<E)
				{
					param->volume += volume;
                    if (tick.bid ==0 || tick.ask==0) {
                        if (tickPrice<=snapshot.referencePrice) {
                            param->innerVolume += volume;
                        }else{
                            param->outerVolume += volume;
                        }
                    }else{
                        if (tickPrice <=innerUpperPrice) {
                            param->innerVolume += volume;
                        }else{
                            param->outerVolume += volume;
                        }
                    }
                    

					break;
				}
				else if(tickPrice>param->price)
				{
					TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
					paramtemp->price = tickPrice;
					paramtemp->volume = volume;
                    if (tick.bid ==0 || tick.ask==0) {
                        if (tickPrice<=snapshot.referencePrice) {
                            paramtemp->innerVolume = volume;
                        }else{
                            paramtemp->outerVolume = volume;
                        }
                    }else{
                        if (tickPrice <=innerUpperPrice) {
                            paramtemp->innerVolume = volume;
                        }else{
                            paramtemp->outerVolume = volume;
                        }
                    }
                    

					[_tickPriceVolumeData insertObject:paramtemp atIndex:index];
					break;
				}
				
				if(index == count-1)
				{
					if(tickPrice<param->price)
					{
						TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
						paramtemp->price = tickPrice;
						paramtemp->volume = volume;
                        if (tick.bid ==0 || tick.ask==0) {
                            if (tickPrice<=snapshot.referencePrice) {
                                paramtemp->innerVolume = volume;
                            }else{
                                paramtemp->outerVolume = volume;
                            }
                        }else{
                            if (tickPrice <=innerUpperPrice) {
                                paramtemp->innerVolume = volume;
                            }else{
                                paramtemp->outerVolume = volume;
                            }
                        }
                        

						[_tickPriceVolumeData addObject:paramtemp];
						break;
					}
				}
			}
		}
    }
    [dataSource unlock];
    
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
    //    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    //    NSMutableArray *sortedArray = [[NSMutableArray alloc]initWithArray:[_tickPriceVolumeData sortedArrayUsingDescriptors:sortDescriptors]];
    //    _tickPriceVolumeData = sortedArray;
    if  (dataSource.progress>0.99){
        [self setDataToGroup];
    }
#endif
    
}


-(void)setDefaultData:(NSMutableArray*)array{
    
    [_tickPriceVolumeData removeAllObjects];
    
    PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
    FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:tickData.getIdenCodeSymbol];
    
    if (snapshot) {
        [_infoPanel reloadBValueSnapshot:snapshot];
    }
    double oldVolume = 0;
    
    PortfolioItem * p = _warchPortfolio.portfolioItem;
    if (p->identCode[0] == 'T' && p->identCode[1]=='W') {
        for (int tickCounter = 0; tickCounter < [array count]; tickCounter++)
        {
            double tickPrice = 0.0, volume = 0.0,  m= 0.0, innerUpperPrice = 0.0 ;
            //            UInt16 tmpVolUnit;
            
            FSTickData * tick = [array objectAtIndex:tickCounter];
            if(tick.type == FSTickType3){
                tickPrice =tick.last.calcValue;
                volume = tick.accumulated_volume.calcValue;
                m =(MAX(tick.bid.calcValue, tick.ask.calcValue)-MIN(tick.bid.calcValue, tick.ask.calcValue));
                innerUpperPrice = tick.bid.calcValue + m/2.0f;
            }else{
                tickPrice =tick.indexValue.calcValue;
                volume = tick.dealValue.calcValue;
                innerUpperPrice = tick.bid.calcValue;
            }
            
            //            double volume = [self getRealValue:tmpVol Unit:tmpVolUnit];
            
            
            if(oldVolume == volume)
            {
                continue;
            }
            else if(oldVolume<volume)
            {
                double temp = oldVolume;
                oldVolume = volume;
                volume -= temp;
            }
            else
            {
                //                continue;
                //			oldVolume += volume;
            }
            
            int count = (int)[_tickPriceVolumeData count];
            if(count == 0) // 空的 直接塞
            {
                TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                paramtemp->price = tickPrice;
                paramtemp->volume = volume;
                if (tick.type == FSTickType3) {
                    if (tick.bid.calcValue ==0 || tick.ask.calcValue==0) {
                        if (tickPrice<=snapshot.reference_price.calcValue) {
                            paramtemp->innerVolume = volume;
                        }else{
                            paramtemp->outerVolume = volume;
                        }
                    }else{
                        if (tickPrice <=innerUpperPrice) {
                            paramtemp->innerVolume = volume;
                        }else{
                            paramtemp->outerVolume = volume;
                        }
                    }
                }else{
                    if (tickPrice <=innerUpperPrice) {
                        paramtemp->innerVolume = volume;
                    }else{
                        paramtemp->outerVolume = volume;
                    }
                }
                
                
                [_tickPriceVolumeData addObject:paramtemp];
                //break;
                continue;
            }
            else
            {
                for(int index=0; index<count; index++)
                {
                    TradeDistributeParam* param = [_tickPriceVolumeData objectAtIndex:index];
                    
                    if(fabs(tickPrice-param->price)<E)
                    {
                        param->volume += volume;
                        if (tick.type == FSTickType3) {
                            if (tick.bid.calcValue ==0 || tick.ask.calcValue==0) {
                                if (tickPrice<=snapshot.reference_price.calcValue) {
                                    param->innerVolume += volume;
                                }else{
                                    param->outerVolume += volume;
                                }
                            }else{
                                if (tickPrice <=innerUpperPrice) {
                                    param->innerVolume += volume;
                                }else{
                                    param->outerVolume += volume;
                                }
                            }
                        }else{
                            if (tickPrice <=innerUpperPrice) {
                                param->innerVolume += volume;
                            }else{
                                param->outerVolume += volume;
                            }
                        }
                        
                        
                        
                        break;
                    }
                    else if(tickPrice>param->price)
                    {
                        TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                        paramtemp->price = tickPrice;
                        paramtemp->volume = volume;
                        if (tick.type == FSTickType3) {
                            if (tick.bid.calcValue ==0 || tick.ask.calcValue==0) {
                                if (tickPrice<=snapshot.reference_price.calcValue) {
                                    paramtemp->innerVolume = volume;
                                }else{
                                    paramtemp->outerVolume = volume;
                                }
                            }else{
                                if (tickPrice <=innerUpperPrice) {
                                    paramtemp->innerVolume = volume;
                                }else{
                                    paramtemp->outerVolume = volume;
                                }
                            }
                        }else{
                            if (tickPrice <=innerUpperPrice) {
                                paramtemp->innerVolume = volume;
                            }else{
                                paramtemp->outerVolume = volume;
                            }
                        }
                        
                        [_tickPriceVolumeData insertObject:paramtemp atIndex:index];
                        break;
                    }
                    else{
                        
                    }
                    
                    if(index == count-1)
                    {
                        if(tickPrice<param->price)
                        {
                            TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                            paramtemp->price = tickPrice;
                            paramtemp->volume = volume;
                            if (tick.type == FSTickType3) {
                                if (tick.bid.calcValue ==0 || tick.ask.calcValue==0) {
                                    if (tickPrice<=snapshot.reference_price.calcValue) {
                                        paramtemp->innerVolume = volume;
                                    }else{
                                        paramtemp->outerVolume = volume;
                                    }
                                }else{
                                    if (tickPrice <=innerUpperPrice) {
                                        paramtemp->innerVolume = volume;
                                    }else{
                                        paramtemp->outerVolume = volume;
                                    }
                                }
                            }else{
                                if (tickPrice <=innerUpperPrice) {
                                    paramtemp->innerVolume = volume;
                                }else{
                                    paramtemp->outerVolume = volume;
                                }
                            }
                            
                            
                            
                            [_tickPriceVolumeData addObject:paramtemp];
                            break;
                        }
                    }
                }
            }
        }
    }else{
        for (int i = 0; i < [array count]; i++) {
            double tickPrice;
            double volume;
            
            FSTickData *tick = [array objectAtIndex:i];
            
            if(tick.type == FSTickType3){
                tickPrice = tick.last.calcValue;
                volume = tick.accumulated_volume.calcValue;
            }else{
                tickPrice = tick.indexValue.calcValue;
                volume = tick.dealValue.calcValue;
            }
            
            
            if(oldVolume == volume)
            {
                continue;
            }
            else if(oldVolume<volume)
            {
                double temp = oldVolume;
                oldVolume = volume;
                volume -= temp;
            }
            else
            {
                continue;
                //oldVolume += volume;
            }
            
            int count = (int)[_tickPriceVolumeData count];
            if(count == 0) // 空的 直接塞
            {
                TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                paramtemp->price = tickPrice;
                paramtemp->volume = volume;
                [_tickPriceVolumeData addObject:paramtemp];
                //break;
                continue;
            }
            else
            {
                for(int index=0; index<count; index++)
                {
                    TradeDistributeParam* param = [_tickPriceVolumeData objectAtIndex:index];
                    
                    if(fabs(tickPrice-param->price)<E)
                    {
                        param->volume += volume;
                        break;
                    }
                    else if(tickPrice>param->price)
                    {
                        TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                        paramtemp->price = tickPrice;
                        paramtemp->volume = volume;
                        [_tickPriceVolumeData insertObject:paramtemp atIndex:index];
                        break;
                    }
                    
                    if(index == count-1)
                    {
                        if(tickPrice<param->price)
                        {
                            TradeDistributeParam* paramtemp = [[TradeDistributeParam alloc] init];
                            paramtemp->price = tickPrice;
                            paramtemp->volume = volume;
                            [_tickPriceVolumeData addObject:paramtemp];
                            break;
                        }
                    }
                }
            }
        }
    }
    
    [self setDataToGroup];
}

-(void)setDataToGroup{
    [_groupPriceVolumeData removeAllObjects];
    
#ifdef LPCB
    
    PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
    
    FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:[_warchPortfolio.portfolioItem getIdentCodeSymbol]];
    
    
    //分50組,如小於0.01則為0.01
    float priceBlock =(snapshot.high_price.calcValue-snapshot.low_price.calcValue)/50;
    float block = 0.01;
    if (priceBlock<0.01) {
        priceBlock = 0.01;
        block = 0;
    }
    double highPrice = snapshot.high_price.calcValue;
    double lowPrice = snapshot.high_price.calcValue - priceBlock;
    double totalVol = 0;
    
    PortfolioItem * p = _warchPortfolio.portfolioItem;
    if (p->identCode[0] == 'T' && p->identCode[1]=='W') {
        
        if ([_tickPriceVolumeData count]>0) {
            for (int j=0; j<[_tickPriceVolumeData count]; j++) {
                TradeDistributeParam* paramtemp = (TradeDistributeParam*)[_tickPriceVolumeData objectAtIndex:j];
                [_groupPriceVolumeData addObject:paramtemp];
            }
        }
        
    }else{
        if ([_tickPriceVolumeData count]>0) {
            for (int i=0; i<[_tickPriceVolumeData count]; i++) {
                TradeDistributeParam* paramtemp = (TradeDistributeParam*)[_tickPriceVolumeData objectAtIndex:i];
                
                
                if(lowPrice == snapshot.low_price.calcValue){
                    if (paramtemp->price >= lowPrice && paramtemp->price <= highPrice) {
                        totalVol += paramtemp->volume;
                    }
                }else{
                    if (paramtemp->price > lowPrice && paramtemp->price <= highPrice) {
                        totalVol += paramtemp->volume;
                    }else{
                        NewTradeDistributeParam * groupData = [[NewTradeDistributeParam alloc] init];
                        if (highPrice == snapshot.high_price.calcValue) {
                            groupData->price = [NSString stringWithFormat:@"%.2f~%.2f %@",lowPrice,highPrice,[self signByExamingBetweenLowPrice:lowPrice HighPrice:highPrice]];
                        }else{
                            groupData->price = [NSString stringWithFormat:@"%.2f~%.2f %@",lowPrice,highPrice-block,[self signByExamingBetweenLowPrice:lowPrice HighPrice:highPrice]];
                        }
                        
                        groupData->highPrice = highPrice;
                        groupData->volume = totalVol;
                        if(groupData->volume != 0.00){
                            [_groupPriceVolumeData addObject:groupData];
                        }
                        
                        highPrice = lowPrice;
                        lowPrice = lowPrice-priceBlock;
                        
                        
                        if (paramtemp->price > lowPrice && paramtemp->price <= highPrice) {
                            totalVol = paramtemp->volume;
                            
                        }else{
                            
                            for (int j=0;j<50; j++) {
                                if (paramtemp->price > lowPrice && paramtemp->price <= highPrice) {
                                    totalVol = paramtemp->volume;
                                    break;
                                }else{
                                    NewTradeDistributeParam * groupData = [[NewTradeDistributeParam alloc] init];
                                    if (highPrice == snapshot.high_price.calcValue) {
                                        groupData->price = [NSString stringWithFormat:@"%.2f~%.2f %@",lowPrice,highPrice,[self signByExamingBetweenLowPrice:lowPrice HighPrice:highPrice]];
                                    }else{
                                        groupData->price = [NSString stringWithFormat:@"%.2f~%.2f %@",lowPrice,highPrice-block,[self signByExamingBetweenLowPrice:lowPrice HighPrice:highPrice]];
                                    }
                                    
                                    groupData->highPrice = highPrice;
                                    groupData->volume = 0;
                                    if(groupData->volume != 0.00){
                                        [_groupPriceVolumeData addObject:groupData];
                                    }
                                    highPrice = lowPrice;
                                    lowPrice = lowPrice-priceBlock;
                                }
                            }
                        }
                        
                    }
                }
                
            }
            NewTradeDistributeParam * groupData = [[NewTradeDistributeParam alloc] init];
            groupData->price = [NSString stringWithFormat:@"%.2f~%.2f %@",snapshot.low_price.calcValue,highPrice-block,[self signByExamingBetweenLowPrice:lowPrice HighPrice:highPrice]];
            groupData->highPrice = highPrice;
            groupData->volume = totalVol;
            
            float low = [NSString stringWithFormat:@"%.2f",lowPrice].floatValue;
            float sLow = [NSString stringWithFormat:@"%.2f",snapshot.low_price.calcValue].floatValue;
            
            if(groupData->volume != 0.00 && low == sLow){
                [_groupPriceVolumeData addObject:groupData];
            }

        }
    
    }
    
#else
    PortfolioItem * p = _warchPortfolio.portfolioItem;
    if (p->identCode[0] == 'T' && p->identCode[1]=='W') {
        
        if ([_tickPriceVolumeData count]>0) {
            for (int j=0; j<[_tickPriceVolumeData count]; j++) {
                TradeDistributeParam* paramtemp = (TradeDistributeParam*)[_tickPriceVolumeData objectAtIndex:j];
                [_groupPriceVolumeData addObject:paramtemp];
            }
        }

    }else{
        //分50組,如小於0.01則為0.01
        float priceBlock =(_symbolSnapshot.highestPrice-_symbolSnapshot.lowestPrice)/50;
        if (priceBlock<0.01) {
            priceBlock = 0.01;
        }
        
        double highPrice = _symbolSnapshot.highestPrice;
        double lowPrice = _symbolSnapshot.highestPrice - priceBlock;
        double totalVol = 0;
        
        if ([_tickPriceVolumeData count]>0) {
            for (int i=0; i<[_tickPriceVolumeData count]; i++) {
                TradeDistributeParam* paramtemp = (TradeDistributeParam*)[_tickPriceVolumeData objectAtIndex:i];
                if(lowPrice == _symbolSnapshot.lowestPrice){
                    if (paramtemp->price >= lowPrice && paramtemp->price <= highPrice) {
                        totalVol += paramtemp->volume;
                    }
                }else{
                    if (paramtemp->price > lowPrice && paramtemp->price <= highPrice) {
                        totalVol += paramtemp->volume;
                    }else{
                        NewTradeDistributeParam * groupData = [[NewTradeDistributeParam alloc] init];
                        groupData->price = [NSString stringWithFormat:@"%.2f~%.2f %@",lowPrice,highPrice,[self signByExamingBetweenLowPrice:lowPrice HighPrice:highPrice]];
                        groupData->highPrice = highPrice;
                        groupData->volume = totalVol;
                        [_groupPriceVolumeData addObject:groupData];
                        highPrice = lowPrice;
                        lowPrice = lowPrice-priceBlock;
                        
                        if (paramtemp->price > lowPrice && paramtemp->price <= highPrice) {
                            totalVol = paramtemp->volume;
                            
                        }else{
                            
                            for (int j=0;j<50; j++) {
                                if (paramtemp->price > lowPrice && paramtemp->price <= highPrice) {
                                    totalVol = paramtemp->volume;
                                    break;
                                }else{
                                    NewTradeDistributeParam * groupData = [[NewTradeDistributeParam alloc] init];
                                    groupData->price = [NSString stringWithFormat:@"%.2f~%.2f %@",lowPrice,highPrice,[self signByExamingBetweenLowPrice:lowPrice HighPrice:highPrice]];
                                    groupData->highPrice = highPrice;
                                    groupData->volume = 0;
                                    [_groupPriceVolumeData addObject:groupData];
                                    highPrice = lowPrice;
                                    lowPrice = lowPrice-priceBlock;
                                }
                            }
                        }
                        
                    }
                }
                
            }
            NewTradeDistributeParam * groupData = [[NewTradeDistributeParam alloc] init];
            groupData->price = [NSString stringWithFormat:@"%.2f~%.2f %@",lowPrice,highPrice,[self signByExamingBetweenLowPrice:lowPrice HighPrice:highPrice]];
            groupData->highPrice = highPrice;
            groupData->volume = totalVol;
            [_groupPriceVolumeData addObject:groupData];
        }
    }
    
    
#endif
    [self.view hideHUD];
    [_priceByVolumeTableView reloadData];
}


#pragma mark - layout

-(void)setLayout
{
    
//    [super updateViewConstraints];
    [self.view removeConstraints:self.view.constraints];
    NSDictionary *metrics = @{@"panelHeight" : @(100)
                              };
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_priceByVolumeTableView, _infoPanel);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_priceByVolumeTableView][_infoPanel(panelHeight)]|" options:0 metrics:metrics views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_priceByVolumeTableView]|" options:0 metrics:metrics views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_infoPanel]|" options:0 metrics:metrics views:viewsDictionary]];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 33.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.priceByVolumeTableViewHeaderView;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [_groupPriceVolumeData count];
}

-(void)viewDidLayoutSubviews
{
//    [super viewDidLayoutSubviews];

    [self.pageControl setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height - 10)];
}

@end
