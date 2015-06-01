//
//  RealtimeListController.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/16.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "RealtimeListController.h"
#import "RealtimeListCell.h"
#import "ValueUtil.h"
#import "MarketInfo.h"
#import "Commodity.h"
#import "FSEquityInfoPanel.h"
#import "DDPageControl.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSBAQuery.h"

@interface RealtimeListController() {
    FSDataModelProc * dataModal;
    NSObject<TickDataSourceProtocol> *tickData;
    NSString *idSymbol;
    BOOL hasBidAsk;
    UInt16 marketOpenTime;
    double referencePrice;
    double ceilingPrice;
    double floorPrice;
    BOOL hasVolume;
    NSMutableArray * tickDataByTime;
    FSBAQuery * baQuery;

}
@property (nonatomic, strong) UITableView *realtimeListTableView;
@property (nonatomic, strong) UIView *realTimeTitleView;
@property (nonatomic, strong) FSEquityInfoPanel *infoPanel;
@property (nonatomic, strong) DDPageControl *pageControl;
@property (nonatomic, strong) FSInstantInfoWatchedPortfolio * watchPortfolio;
@end


@implementation RealtimeListController

- (void)viewDidLoad {
	
    [super viewDidLoad];
    baQuery = [[FSBAQuery alloc]init];
    dataModal = [FSDataModelProc sharedInstance];
    self.watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    tickDataByTime = [[NSMutableArray alloc]init];
	
    //touchView.viewController = self;
	[self addRealtimeListTableView];
    [self addInfoPanel];
    
    [self initPageControll];
    [self setLayout];
}

- (void)initPageControll {
    self.infoPanel.delegate = self;
    self.pageControl = [[DDPageControl alloc] init];
    
    PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    self.pageControl.numberOfPages = 4;
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        
        self.pageControl.numberOfPages = 2;
        
    } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        
        if (portfolioItem->type_id == 6) {
            
            self.pageControl.numberOfPages = 2;
            
        } else if (portfolioItem->type_id == 3){
            
            self.pageControl.numberOfPages = 1;
            
        }
        
    } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        
        if (portfolioItem->type_id == 6) {
            
            self.pageControl.numberOfPages = 2;
            
        } else if (portfolioItem->type_id == 3) {
            
            self.pageControl.numberOfPages = 2;
            
        }
    }
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];

    self.pageControl.currentPage =[dataModel.infoPanelCenter.currentInfoPage intValue];
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
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    dataModel.infoPanelCenter.currentInfoPage = @(self.pageControl.currentPage);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView {
    
	[self.pageControl updateCurrentPageDisplay] ;
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    [self registerLoginNotificationCallBack:self seletor:@selector(sendRequest)];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(sendRequest)];
    
	NSString *equity = [_watchPortfolio.portfolioItem getIdentCodeSymbol];
	if (![idSymbol isEqualToString:equity]) {
		if(_watchPortfolio.portfolioItem->market_id == 28)
		{ //興櫃
			
			idSymbol = equity;
			[_realtimeListTableView reloadData];
			//[bidSellInfoView reloadData:nil];
		}
		else
		{
			idSymbol = equity;
			tickData = nil;
			[_realtimeListTableView reloadData];
		}
	}
    if (_watchPortfolio.portfolioItem != nil)
    {
//        NSString *equity = [_watchPortfolio.portfolioItem getIdentCodeSymbol];
        
#ifdef LPCB
        
//        [[[FSDataModelProc sharedInstance]portfolioTickBank] setTaget:self IdentCodeSymbol:equity];
//        [[[FSDataModelProc sharedInstance]portfolioTickBank] updateTickDataByIdentCodeSymbol:equity];
//        [dataModal.category setTargetObj:self];
//        [dataModal.category searchSectorIdByIdentCode:[NSString stringWithFormat:@"%c%c",_watchPortfolio.portfolioItem->identCode[0],_watchPortfolio.portfolioItem->identCode[1]] Symbol:_watchPortfolio.portfolioItem->symbol];
        [self sendRequest];
        
#else
        [[[FSDataModelProc sharedInstance]portfolioTickBank] watchTarget:self ForEquity:equity GetTick:YES];
#endif
        MarketInfoItem *market = [dataModal.marketInfo getMarketInfo:_watchPortfolio.portfolioItem->market_id];
#ifdef LPCB
        
        FSSnapshot * snapshot = [dataModal.portfolioTickBank getSnapshotBvalue:_watchPortfolio.portfolioItem->commodityNo];
        if (snapshot == nil) return;
        
        if (market) {
            marketOpenTime = market->startTime_1;
        }
        if (snapshot) {
            referencePrice = snapshot.reference_price.calcValue;
            ceilingPrice = snapshot.high_price.calcValue;
            floorPrice = snapshot.low_price.calcValue;
            hasVolume = snapshot.accumulated_volume.calcValue ? YES : NO;
            [_infoPanel reloadBValueSnapshot:snapshot];
        }
#else
        EquitySnapshotDecompressed *snapshot = [dataModal.portfolioTickBank getSnapshot:_watchPortfolio.portfolioItem->commodityNo];
        if (snapshot == nil) return;
        
        [_infoPanel reloadDataWithSnapshot:snapshot];
        if (market) {
            marketOpenTime = market->startTime_1;
        }
        if (snapshot) {
            referencePrice = snapshot.referencePrice;
            ceilingPrice = snapshot.ceilingPrice;
            floorPrice = snapshot.floorPrice;
            hasVolume = snapshot.accumulatedVolume ? YES : NO;
            
            switch (snapshot.commodityType) {
                case kCommodityTypeMarketIndex:
                case kCommodityTypeIndex:
                    hasBidAsk = NO;
                    break;
                default:
                    hasBidAsk = YES;
                    break;
            }
        }
        
        
#endif
        if (_watchPortfolio.portfolioItem->identCode[0] == 'T' && _watchPortfolio.portfolioItem->identCode[1]=='W') {
            hasBidAsk = YES;
        } else {
            hasBidAsk = NO;
        }
        
        if (_watchPortfolio.portfolioItem->type_id == 6) {
            hasBidAsk = NO;
        }
        
        EquityTick * equityTick = [dataModal.portfolioTickBank getEquityTick:[_watchPortfolio.portfolioItem getIdentCodeSymbol]];
        
        [self prepareTickByTime:equityTick.ticksData];
  
    }
}
-(void)sendRequest{
    NSString *equity = [_watchPortfolio.portfolioItem getIdentCodeSymbol];
    
    [[[FSDataModelProc sharedInstance]portfolioTickBank] setTaget:self IdentCodeSymbol:equity];
    [[[FSDataModelProc sharedInstance]portfolioTickBank] updateTickDataByIdentCodeSymbol:equity];
    [dataModal.category setTargetObj:self];
    [dataModal.category searchSectorIdByIdentCode:[NSString stringWithFormat:@"%c%c",_watchPortfolio.portfolioItem->identCode[0],_watchPortfolio.portfolioItem->identCode[1]] Symbol:_watchPortfolio.portfolioItem->symbol];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSInteger n = [_realtimeListTableView numberOfRowsInSection:0];
    if (n > 0)
        [_realtimeListTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:n-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}


- (void)viewWillDisappear:(BOOL)animated {
    [self unregisterLoginNotificationCallBack:self];
    [self unRegisterSecurityRegisterNotificationCallBack:self];
    if (_watchPortfolio.portfolioItem != nil) {
#ifdef LPCB
        [[[FSDataModelProc sharedInstance]portfolioTickBank] removeKeyWithTaget:self IdentCodeSymbol:[_watchPortfolio.portfolioItem getIdentCodeSymbol]];
#else
        [[[FSDataModelProc sharedInstance]portfolioTickBank] stopWatch:self ForEquity:[_watchPortfolio.portfolioItem getIdentCodeSymbol]];
        
#endif
        
        //[_watchPortfolio.portfolioItem killFocus];
    }

	if(_watchPortfolio.portfolioItem->market_id == 28)
	{ //興櫃	
		
		[dataModal.esmData setTarget:nil];
		[dataModal.esmData discardData];
		
	}
	
    [super viewWillDisappear:animated];
}

#pragma mark - UI Init

- (void)addRealtimeListTableView
{
    self.realtimeListTableView = [[UITableView alloc] init];
    _realtimeListTableView.delegate = self;
    _realtimeListTableView.dataSource = self;
    _realtimeListTableView.bounces = NO;
    _realtimeListTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _realtimeListTableView.sectionIndexBackgroundColor = [UIColor clearColor];
//    self.realtimeListTableView.backgroundColor = [PlainStyleTableViewUtil tableViewBackgroundColor];
// 	_realtimeListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_realtimeListTableView];
    [_realtimeListTableView registerClass:[RealtimeListCell class] forCellReuseIdentifier:@"RealtimeListCell"];
}


- (void)addInfoPanel
{
    self.infoPanel = [[FSEquityInfoPanel alloc] initWithPortfolioItem:_watchPortfolio.portfolioItem];
    _infoPanel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_infoPanel];
}


- (void)notifyDataArrive:(NSObject<TickDataSourceProtocol> *)dataSource {

    if (_watchPortfolio.portfolioItem == nil) return;
	

    MarketInfoItem *market = [dataModal.marketInfo getMarketInfo:_watchPortfolio.portfolioItem->market_id];
    if (market == nil) return;

#ifdef LPCB
    FSSnapshot * snapshot = [dataModal.portfolioTickBank getSnapshotBvalue:_watchPortfolio.portfolioItem->commodityNo];
    if (snapshot == nil) return;
    
    marketOpenTime = market->startTime_1;
    referencePrice = snapshot.reference_price.calcValue;
    ceilingPrice = snapshot.high_price.calcValue;
    floorPrice = snapshot.low_price.calcValue;
    hasVolume = snapshot.accumulated_volume.calcValue ? YES : NO;


#else
    EquitySnapshotDecompressed *snapshot = [dataModal.portfolioTickBank getSnapshot:_watchPortfolio.portfolioItem->commodityNo];
    if (snapshot == nil) return;

    [_infoPanel reloadDataWithSnapshot:snapshot];

    marketOpenTime = market->startTime_1;
    referencePrice = snapshot.referencePrice;
    ceilingPrice = snapshot.ceilingPrice;
    floorPrice = snapshot.floorPrice;
    hasVolume = snapshot.accumulatedVolume ? YES : NO;

    switch (snapshot.commodityType) {
        case kCommodityTypeMarketIndex:
        case kCommodityTypeIndex:
            hasBidAsk = NO;
            break;
        default:
            hasBidAsk = YES;
            break;
    }
#endif
    
    tickData = dataSource;
    [self prepareTickByTime:tickData.ticksData];
    
    
    if (dataSource.progress > 0.99){
        [_realtimeListTableView reloadData];
    }
    
#ifdef LPCB
    if (snapshot) {
        referencePrice = snapshot.reference_price.calcValue;
    }
    [_infoPanel reloadBValueSnapshot:snapshot];
#endif
    NSInteger n = [_realtimeListTableView numberOfRowsInSection:0];
    if (n > 0)
        [_realtimeListTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:n-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void)prepareTickByTime:(NSMutableArray *)dataArray{
    
    
    tickDataByTime = dataArray;
    [_realtimeListTableView reloadData];
    
    return;
    
    [tickDataByTime removeAllObjects];
    UInt16 time = 0;
    float openPrice = 0 , highPrice = 0 , lowPrice = 0 , lastPrice = 0;
    FSTickData * oldTick;
    NSMutableArray * tmpDataArray = [[NSMutableArray alloc]init];
    float newVol = 0,oldVol = 0;
//    NSDate* now = [NSDate date];
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
//    NSInteger hour = [dateComponents hour];
//    NSInteger minute = [dateComponents minute];
//    int nowTime =hour*60+minute;
    for (NSUInteger tickCounter=0; tickCounter < [dataArray count]; tickCounter++) {
        FSTickData *tick = (FSTickData *)[dataArray objectAtIndex:tickCounter];
    
        if (tick != nil) {
            
            float last = 0;
            if (tick.type == FSTickType3) {
                last = tick.last.calcValue;
            }else if (tick.type == FSTickType4){
                last = tick.indexValue.calcValue;
            }
            
            if(tickCounter ==0){
                time = [tick.time absoluteMinutesTime];
                openPrice = last;
                highPrice = last;
                lowPrice = last;
                lastPrice = last;
                [tmpDataArray addObject:tick];
            }else{
//                if ([tick.time absoluteMinutesTime] == time) {
                
                    lastPrice = last;
                    
                    if(last>highPrice){
                        highPrice = last;
                    }
                    if (last<lowPrice) {
                        lowPrice = last;
                    }
                    [tmpDataArray addObject:tick];
                    
//                }
//                else{
//                    FSTickData * openTick = nil;
//                    FSTickData * lastTick = nil;
//                    FSTickData * highTick = nil;
//                    FSTickData * lowTick = nil;
//                    
//                    
//                    for (int i =0; i<[tmpDataArray count]; i++) {
//                        FSTickData * newTick = [tmpDataArray objectAtIndex:i];
//                        if (newTick.dealValue.calcValue) {
//                            newVol = newTick.dealValue.calcValue;
//                        }
//                        if (!oldTick) {
//                            oldTick = [[FSTickData alloc]init];
//                            oldTick.type = newTick.type;
//                            if (oldTick.type == FSTickType3) {
//                                oldTick.accumulated_volume.calcValue = 0;
//                            }else{
//                                oldTick.dealValue.calcValue = 0;
//                            }
//                            
//                        }
//                        
//                        if (i==0 && openPrice == lastPrice && (highPrice !=lastPrice || lowPrice != lastPrice)) {
//                            if (openTick) {
//                                if (oldTick.type == FSTickType3) {
//                                    openTick.volume.calcValue += newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                                }else{
//                                    if (newTick.dealValue.calcValue>0) {
//                                        openTick.dealValue.calcValue += newTick.dealValue.calcValue-oldVol;
//                                    }
//                                }
//                                
//                            }else{
//                                openTick = [[FSTickData alloc]init];
//                                [self copyOldTick:newTick toNewTick:openTick];
//                                if (oldTick.type == FSTickType3) {
//                                    openTick.volume.calcValue = newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                                }else{
//                                    if (newTick.dealValue.calcValue>0) {
//                                        openTick.dealValue.calcValue = newTick.dealValue.calcValue-oldVol;
//                                    }
//                                }
//                                
//                            }
//                            if (oldTick.type == FSTickType3) {
//                                [self copyOldTick:newTick toNewTick:oldTick];
//                            }else {
//                                if (newVol>0) {
//                                    oldVol = newVol;
//                                }
//                            }
//                            continue;
//                        }
//                        
//                        float newLast = 0;
//                        if (oldTick.type == FSTickType3) {
//                            newLast = newTick.last.calcValue;
//                        }else{
//                            newLast = newTick.indexValue.calcValue;
//                        }
//                        
//                        if (newLast == lastPrice) {
//                            if (lastTick) {
//                                if (oldTick.type == FSTickType3) {
//                                    lastTick.volume.calcValue += newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                                }else{
//                                    if (newTick.dealValue.calcValue>0) {
//                                        lastTick.dealValue.calcValue += newTick.dealValue.calcValue-oldVol;
//                                    }
//                                    
//                                }
//                                
//                            }else{
//                                lastTick = [[FSTickData alloc]init];
//                                [self copyOldTick:newTick toNewTick:lastTick];
//                                if (oldTick.type == FSTickType3) {
//                                    lastTick.volume.calcValue = newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                                }else{
//                                    if (newTick.dealValue.calcValue>0) {
//                                        lastTick.dealValue.calcValue = newTick.dealValue.calcValue-oldVol;
//                                    }
//                                }
//                                
//                            }
//                            
//                        }else if (newLast == openPrice){
//                            if (openTick) {
//                                if (oldTick.type == FSTickType3) {
//                                    openTick.volume.calcValue += newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                                }else{
//                                    if (newTick.dealValue.calcValue>0) {
//                                        openTick.dealValue.calcValue += newTick.dealValue.calcValue-oldVol;
//                                    }
//                                }
//                                
//                            }else{
//                                openTick = [[FSTickData alloc]init];
//                                [self copyOldTick:newTick toNewTick:openTick];
//                                if (oldTick.type == FSTickType3) {
//                                    openTick.volume.calcValue = newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                                }else{
//                                    if (newTick.dealValue.calcValue>0) {
//                                        openTick.dealValue.calcValue = newTick.dealValue.calcValue-oldVol;
//                                    }
//                                }
//                                
//                            }
//                            
//                        }else if (newLast == highPrice){
//                            if (highTick) {
//                                if (oldTick.type == FSTickType3) {
//                                    highTick.volume.calcValue += newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                                }else{
//                                    if (newTick.dealValue.calcValue>0) {
//                                        highTick.dealValue.calcValue += newTick.dealValue.calcValue-oldVol;
//                                    }
//                                }
//                                
//                            }else{
//                                highTick = [[FSTickData alloc]init];
//                                [self copyOldTick:newTick toNewTick:highTick];
//                                if (oldTick.type == FSTickType3) {
//                                    highTick.volume.calcValue = newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                                }else{
//                                    if (newTick.dealValue.calcValue>0) {
//                                        highTick.dealValue.calcValue = newTick.dealValue.calcValue-oldVol;
//                                    }
//                                }
//                                
//                            }
//                        }else if (newLast == lowPrice){
//                            if (lowTick) {
//                                if (oldTick.type == FSTickType3) {
//                                    lowTick.volume.calcValue += newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                                }else{
//                                    if (newTick.dealValue.calcValue>0) {
//                                        lowTick.dealValue.calcValue += newTick.dealValue.calcValue-oldVol;
//                                    }
//                                }
//                                
//                            }else{
//                                lowTick = [[FSTickData alloc]init];
//                                [self copyOldTick:newTick toNewTick:lowTick];
//                                if (oldTick.type == FSTickType3) {
//                                    lowTick.volume.calcValue = newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                                }else{
//                                    if (newTick.dealValue.calcValue>0) {
//                                        lowTick.dealValue.calcValue = newTick.dealValue.calcValue-oldVol;
//                                    }
//                                }
//                                
//                            }
//                        }
//                        if (oldTick.type == FSTickType3) {
//                            [self copyOldTick:newTick toNewTick:oldTick];
//                        }else {
//                            if (newVol>0) {
//                                oldVol = newVol;
//                            }
//                        }
//                        
//                    }
//                    if(openTick){
//                        [tickDataByTime addObject:openTick];
//                    }
//                    if (highTick) {
//                        [tickDataByTime addObject:highTick];
//                    }
//                    if (lowTick) {
//                        [tickDataByTime addObject:lowTick];
//                    }
//                    if (lastTick) {
//                        [tickDataByTime addObject:lastTick];
//                    }
                
//                    if (tickCounter>0) {
//                        if (oldTick.type == FSTickType3) {
//                            oldTick = (FSTickData *)[tickData.ticksData objectAtIndex:tickCounter-1];
//                        }else{
//                            FSTickData * tick = (FSTickData *)[tickData.ticksData objectAtIndex:tickCounter-1];
//                            if (tick.dealValue.calcValue>0) {
//                                oldTick = tick;
//                            }
//                        }
//                        
//                    }
                    
//                    [tmpDataArray removeAllObjects];
//                    
//                    time = [tick.time absoluteMinutesTime];
//
//                    openPrice = last;
//                    highPrice = last;
//                    lowPrice = last;
//                    lastPrice = last;
//                    [tmpDataArray addObject:tick];
//                }
            }
            
        }
        
    }
    for (int i =0; i<[tmpDataArray count]; i++) {
        FSTickData * newTick = [tmpDataArray objectAtIndex:i];
        if (newTick.dealValue.calcValue) {
            newVol = newTick.dealValue.calcValue;
        }
        FSTickData *insertTick = [[FSTickData alloc]init];
        
        if (!oldTick) {
            oldTick = [[FSTickData alloc]init];
            oldTick.type = newTick.type;
            if (oldTick.type == FSTickType3) {
                oldTick.accumulated_volume.calcValue = 0;
            }else{
                oldTick.dealValue.calcValue = 0;
            }
            
        }
        [self copyOldTick:newTick toNewTick:insertTick];
        if (oldTick.type == FSTickType3) {
            insertTick.volume.calcValue = newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
            if (insertTick.volume.calcValue>0) {
                [tickDataByTime addObject:insertTick];
            }
        }else{
            if (newTick.dealValue.calcValue>0) {
                insertTick.dealValue.calcValue += newTick.dealValue.calcValue-oldVol;
            }
            if (insertTick.dealValue.calcValue>0) {
                [tickDataByTime addObject:insertTick];
            }
            
        }
        if (newTick.type == FSTickType3) {
            [self copyOldTick:newTick toNewTick:oldTick];
        }else{
            if (newVol>0) {
                oldVol = newVol;
            }
        }
//        if ([tickDataByTime count] > 200) {
//            [tickDataByTime removeObjectAtIndex:0];
//        }
    }
    
//    FSTickData * openTick = nil;
//    FSTickData * lastTick = nil;
//    FSTickData * highTick = nil;
//    FSTickData * lowTick = nil;
//    for (int i =0; i<[tmpDataArray count]; i++) {
//        FSTickData * newTick = [tmpDataArray objectAtIndex:i];
//        if (newTick.dealValue.calcValue) {
//            newVol = newTick.dealValue.calcValue;
//        }
//        if (!oldTick) {
//            oldTick = [[FSTickData alloc]init];
//            oldTick.type = newTick.type;
//            if (oldTick.type == FSTickType3) {
//                oldTick.accumulated_volume.calcValue = 0;
//            }else{
//                oldTick.dealValue.calcValue = 0;
//            }
//            
//        }
//        float newLast = 0;
//        if (oldTick.type == FSTickType3) {
//            newLast = newTick.last.calcValue;
//        }else{
//            newLast = newTick.indexValue.calcValue;
//        }
//        
//        if (newLast == lastPrice) {
//            if (lastTick) {
//                if (oldTick.type == FSTickType3) {
//                    lastTick.volume.calcValue += newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                }else{
//                    if (newTick.dealValue.calcValue>0) {
//                        lastTick.dealValue.calcValue += newTick.dealValue.calcValue-oldVol;
//                    }
//                    
//                }
//                
//            }else{
//                lastTick = [[FSTickData alloc]init];
//                [self copyOldTick:newTick toNewTick:lastTick];
//                if (oldTick.type == FSTickType3) {
//                    lastTick.volume.calcValue = newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                }else{
//                    if (newTick.dealValue.calcValue>0) {
//                        lastTick.dealValue.calcValue = newTick.dealValue.calcValue-oldVol;
//                    }
//                }
//                
//            }
//            
//        }else if (newLast == openPrice){
//            if (openTick) {
//                if (oldTick.type == FSTickType3) {
//                    openTick.volume.calcValue += newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                }else{
//                    if (newTick.dealValue.calcValue>0) {
//                        openTick.dealValue.calcValue += newTick.dealValue.calcValue-oldVol;
//                    }
//                    
//                }
//                
//            }else{
//                openTick = [[FSTickData alloc]init];
//                [self copyOldTick:newTick toNewTick:openTick];
//                if (oldTick.type == FSTickType3) {
//                    openTick.volume.calcValue = newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                }else{
//                    if (newTick.dealValue.calcValue>0) {
//                        openTick.dealValue.calcValue = newTick.dealValue.calcValue-oldVol;
//                    }
//                    
//                }
//                
//            }
//            
//        }else if (newLast == highPrice){
//            if (highTick) {
//                if (oldTick.type == FSTickType3) {
//                    highTick.volume.calcValue += newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                }else{
//                    if (newTick.dealValue.calcValue>0) {
//                        highTick.dealValue.calcValue += newTick.dealValue.calcValue-oldVol;
//                    }
//                }
//                
//            }else{
//                highTick = [[FSTickData alloc]init];
//                [self copyOldTick:newTick toNewTick:highTick];
//                if (oldTick.type == FSTickType3) {
//                    highTick.volume.calcValue = newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                }else{
//                    if (newTick.dealValue.calcValue>0) {
//                        highTick.dealValue.calcValue = newTick.dealValue.calcValue-oldVol;
//                    }
//                }
//                
//            }
//        }else if (newLast == lowPrice){
//            if (lowTick) {
//                if (oldTick.type == FSTickType3) {
//                    lowTick.volume.calcValue += newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                }else{
//                    if (newTick.dealValue.calcValue>0) {
//                        lowTick.dealValue.calcValue += newTick.dealValue.calcValue-oldVol;
//                    }
//                }
//                
//            }else{
//                lowTick = [[FSTickData alloc]init];
//                [self copyOldTick:newTick toNewTick:lowTick];
//                if (oldTick.type == FSTickType3) {
//                    lowTick.volume.calcValue = newTick.accumulated_volume.calcValue-oldTick.accumulated_volume.calcValue;
//                }else{
//                    if (newTick.dealValue.calcValue>0) {
//                        lowTick.dealValue.calcValue = newTick.dealValue.calcValue-oldVol;
//                    }
//                }
//                
//            }
//        }
//        if (newTick.type == FSTickType3) {
//            [self copyOldTick:newTick toNewTick:oldTick];
//        }else{
//            if (newVol>0) {
//                oldVol = newVol;
//            }
//        }
//        
//    }
//    if(openTick){
//        [tickDataByTime addObject:openTick];
//    }
//    if (highTick) {
//        [tickDataByTime addObject:highTick];
//    }
//    if (lowTick) {
//        [tickDataByTime addObject:lowTick];
//    }
//    if (lastTick) {
//        [tickDataByTime addObject:lastTick];
//    }
    
    [_realtimeListTableView reloadData];
}

-(void)copyOldTick:(FSTickData *)oldTick toNewTick:(FSTickData *)newTick{
    newTick.time = oldTick.time;
    newTick.last = oldTick.last;
    newTick.identCodeSymbol = oldTick.identCodeSymbol;
    newTick.securityNumber = oldTick.securityNumber;
    newTick.type = oldTick.type;
    newTick.accumulated_volume = oldTick.accumulated_volume;
    newTick.volume = oldTick.volume;
    newTick.bid = oldTick.bid;
    newTick.ask = oldTick.ask;
    newTick.bid_volume = oldTick.bid_volume;
    newTick.ask_volume = oldTick.ask_volume;
    newTick.queryType = oldTick.queryType;
    newTick.indexValue = oldTick.indexValue;
    newTick.dealValue = [[FSBValueFormat alloc]init];
    newTick.dealVolume = oldTick.dealVolume;
    newTick.dealRecord = oldTick.dealRecord;
    newTick.bidRecord = oldTick.bidRecord;
    newTick.askRecord = oldTick.askRecord;
    newTick.bidVolume = oldTick.bidVolume;
    newTick.askVolume = oldTick.askVolume;
    newTick.up = oldTick.up;
    newTick.down = oldTick.down;
    newTick.unchanged = oldTick.unchanged;
    newTick.topCount = oldTick.topCount;
    newTick.bottomCount = oldTick.bottomCount;
}

- (void)esmDataDataArrive{
	
    //
	if(([dataModal.esmData getBidBestPrice] == 0 && dataModal.esmData.priceType == 0) ||
	   ([dataModal.esmData getSellBestPrice] == 0 && dataModal.esmData.priceType == 1))
		return;


	int bidDataCount = [dataModal.esmData getBidDataCount];
	int sellDataCount = [dataModal.esmData getSellDataCount];
	
	int rowCount;
	if(bidDataCount > sellDataCount)
		rowCount = bidDataCount;
	else
		rowCount = sellDataCount;

}

- (void)type19NotifyDataArrive{
	
	// real time
	
	int bidDataCount = [dataModal.esmData getBidDataCount];
	int sellDataCount = [dataModal.esmData getSellDataCount];
	
	int rowCount;
	if(bidDataCount > sellDataCount)
		rowCount = bidDataCount;
	else
		rowCount = sellDataCount;
	

}

- (void)showBidSellInfoWithBidOrSell:(int)bidorSell rowIndex:(int)index{
	
	NSString *brokerName;
	NSString *traderName;
	NSString *telePhone;
	
	if(([dataModal.esmData getBidBestPrice] == 0 && dataModal.esmData.priceType == 0) ||
	   ([dataModal.esmData getSellBestPrice] == 0 && dataModal.esmData.priceType == 1))
		return;	
	
	if(bidorSell==0){ //買
		
		int bidDataCount = [dataModal.esmData getBidDataCount];
		
		if(index < bidDataCount){
			
			NSMutableDictionary *bidDict = [dataModal.esmData getBidDataWithRowIndex:index];
			brokerName = [bidDict objectForKey:@"brokerName"];
			traderName = [bidDict objectForKey:@"traderName"];
			telePhone = [bidDict objectForKey:@"traderPhone"];
			
			NSString *messageString = [NSString stringWithFormat:@"%@\n%@",traderName,telePhone];
			
			UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:brokerName message:messageString delegate:self 
													 cancelButtonTitle:@"確定" otherButtonTitles:nil];
			
			[alertview show];
			
		
		}
		
	
	}
	else if(bidorSell==1){ //賣
		
		int sellDataCount = [dataModal.esmData getSellDataCount];		
		
		if(index < sellDataCount){
			
			NSMutableDictionary *sellDict = [dataModal.esmData getSellDataWithRowIndex:index];
			brokerName = [sellDict objectForKey:@"brokerName"];		
			traderName = [sellDict objectForKey:@"traderName"];
			telePhone = [sellDict objectForKey:@"traderPhone"];
			
			NSString *messageString = [NSString stringWithFormat:@"%@\n%@",traderName,telePhone];
			
			UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:brokerName message:messageString delegate:self 
													 cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"setting", nil) otherButtonTitles:nil];
			
			[alertview show];
			
		
		}
	
	}
	
	
}

-(void)sectorIdCallBack:(NSMutableArray *)dataArray{
    [_infoPanel reloadMarketInfo:dataArray];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tickDataByTime count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RealtimeListCell *cell = [[RealtimeListCell alloc]initWithStyle:UITableViewCellStyleDefault HasBidAsk:hasBidAsk];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
#ifdef LPCB
    
    int seq = (int)indexPath.row;
    [tickData lock];
//    FSTickData *tick = [tickData.ticksData objectAtIndex:seq];
    FSTickData * tick = [tickDataByTime objectAtIndex:seq];
    FSSnapshot * snapshot = [dataModal.portfolioTickBank getSnapshotBvalue:_watchPortfolio.portfolioItem->commodityNo];
    
    if (tick != nil) {
        cell.timeLabel.text = [tick.time timeString];
        cell.timeLabel.textColor = [UIColor blackColor];
        if (hasBidAsk)
		{
            
//            [ValueUtil updateLabel:cell.bidLabel withPrice:tick.bid.calcValue refPrice:referencePrice whiteStyle:YES compact:YES]; //買價
//            [ValueUtil updateLabel:cell.askLabel withPrice:tick.ask.calcValue refPrice:referencePrice whiteStyle:YES compact:YES]; //賣價
            
            
            
            if ([snapshot.top_price calcValue] == tick.bid.calcValue && tick.bid.calcValue != 0) {
                cell.bidLabel.backgroundColor = [StockConstant PriceUpColor];
                cell.bidLabel.textColor = [UIColor whiteColor];
                cell.bidLabel.text = [NSString stringWithFormat:@"%.2f", tick.bid.calcValue];
            }else if ([snapshot.bottom_price calcValue] == tick.bid.calcValue && tick.bid.calcValue != 0){
                cell.bidLabel.backgroundColor = [StockConstant PriceDownColor];
                cell.bidLabel.textColor = [UIColor whiteColor];
                cell.bidLabel.text = [NSString stringWithFormat:@"%.2f", tick.bid.calcValue];
            }else{
                [ValueUtil updateLabel:cell.bidLabel withPrice:tick.bid.calcValue refPrice:referencePrice whiteStyle:YES compact:YES]; //買價
            }
            if ([snapshot.top_price calcValue] == tick.ask.calcValue && tick.ask.calcValue != 0){
                cell.askLabel.backgroundColor = [StockConstant PriceUpColor];
                cell.askLabel.textColor = [UIColor whiteColor];
                cell.askLabel.text = [NSString stringWithFormat:@"%.2f", tick.ask.calcValue];
            }else if ([snapshot.bottom_price calcValue] == tick.ask.calcValue && tick.ask.calcValue != 0) {
                cell.askLabel.backgroundColor = [StockConstant PriceDownColor];
                cell.askLabel.textColor = [UIColor whiteColor];
                cell.askLabel.text = [NSString stringWithFormat:@"%.2f", tick.ask.calcValue];
            }else{
                [ValueUtil updateLabel:cell.askLabel withPrice:tick.ask.calcValue refPrice:referencePrice whiteStyle:YES compact:YES]; //賣價
            }
            
        }
        
        
        
        PortfolioItem * portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        
        if (portfolioItem->type_id == 1){
            if ([snapshot.top_price calcValue] == tick.last.calcValue && tick.last.calcValue > 0) {
                cell.tradeLabel.backgroundColor = [StockConstant PriceUpColor];
                cell.tradeLabel.textColor = [UIColor whiteColor];
                cell.tradeLabel.text = [NSString stringWithFormat:@"%.2f", tick.last.calcValue];
            }else if ([snapshot.bottom_price calcValue] == tick.last.calcValue && tick.last.calcValue > 0){
                cell.tradeLabel.backgroundColor = [StockConstant PriceDownColor];
                cell.tradeLabel.textColor = [UIColor whiteColor];
                cell.tradeLabel.text = [NSString stringWithFormat:@"%.2f", tick.last.calcValue];
            }else{
                [ValueUtil updateTickPriceLabel:cell.tradeLabel withPrice:tick.last.calcValue refPrice:snapshot.reference_price.calcValue ceilingPrice:ceilingPrice floorPrice:floorPrice whiteStyle:YES];
            }
            [ValueUtil updateChangeLabel:cell.chgLabel withPrice:tick.last.calcValue refPrice:referencePrice whiteStyle:YES compact:NO];
            
            // 累計相減
            if (tick.accumulated_volume.calcValue == 0) {
                cell.volLabel.text = @"----";
            }
            else if (seq == 0) {
                cell.volLabel.text = [CodingUtil volumeRoundRownWithDouble:tick.accumulated_volume.calcValue];
            }
            else if (tick.accumulated_volume.calcValue > 0 && seq > 0) {
                FSTickData *preTick = [tickDataByTime objectAtIndex:seq - 1];
                cell.volLabel.text = [CodingUtil volumeRoundRownWithDouble:tick.accumulated_volume.calcValue - preTick.accumulated_volume.calcValue];
            }
            
        }else if (portfolioItem->type_id == 6){
            [ValueUtil updateTickPriceLabel:cell.tradeLabel withPrice:tick.indexValue.calcValue refPrice:snapshot.reference_price.calcValue ceilingPrice:ceilingPrice floorPrice:floorPrice whiteStyle:YES];
            [ValueUtil updateChangeLabel:cell.chgLabel withPrice:tick.indexValue.calcValue refPrice:referencePrice whiteStyle:YES compact:NO];
            
            // 累計相減
            if (tick.dealValue.calcValue == 0) {
                cell.volLabel.text = @"----";
            }
            else if (seq == 0) {
                cell.volLabel.text = [CodingUtil volumeRoundRownWithDouble:tick.dealValue.calcValue];
            }
            else if (tick.dealValue.calcValue > 0 && seq > 0) {
                FSTickData *preTick = [tickDataByTime objectAtIndex:seq - 1];
                cell.volLabel.text = [CodingUtil volumeRoundRownWithDouble:tick.dealValue.calcValue - preTick.dealValue.calcValue];
            }
            
        }else if (portfolioItem->type_id == 3){
            [ValueUtil updateTickPriceLabel:cell.tradeLabel withPrice:tick.last.calcValue refPrice:snapshot.reference_price.calcValue ceilingPrice:ceilingPrice floorPrice:floorPrice whiteStyle:YES];
            [ValueUtil updateChangeLabel:cell.chgLabel withPrice:tick.last.calcValue refPrice:referencePrice whiteStyle:YES compact:NO];
            cell.volLabel.text = [CodingUtil stringWithVolumeByValue2:tick.accumulated_volume.calcValue];
            
            // 累計相減
            if (tick.accumulated_volume.calcValue == 0) {
                cell.volLabel.text = @"----";
            }
            else if (seq == 0) {
                cell.volLabel.text = [CodingUtil volumeRoundRownWithDouble:tick.accumulated_volume.calcValue];
            }
            else if (tick.accumulated_volume.calcValue > 0 && seq > 0) {
                FSTickData *preTick = [tickDataByTime objectAtIndex:seq - 1];
                cell.volLabel.text = [CodingUtil volumeRoundRownWithDouble:tick.accumulated_volume.calcValue - preTick.accumulated_volume.calcValue];
            }
            
        }
        
        if (tick.last.calcValue == tick.bid.calcValue) {
            cell.volLabel.textColor = [UIColor darkGrayColor];
        }else if (tick.last.calcValue == tick.ask.calcValue){
            cell.volLabel.textColor = [UIColor orangeColor];
        } else {
            cell.volLabel.textColor = [UIColor darkGrayColor];
        }
        
    }
 
    [tickData unlock];
    
#else

    int seq = indexPath.row+1;
    [tickData lock];
    TickDecompressed *tick = [tickData copyTickAtSequenceNo:seq];

    if (tick != nil) 
	{

        int time = tick.time + marketOpenTime;
		//NSLog(@"tick time:%d marketOpenTime:%d",tick.time,marketOpenTime);
        cell.timeLabel.text = [NSString stringWithFormat:@"%d:%02d", time/60, time%60];
        cell.timeLabel.textColor = [UIColor blackColor];

        if (hasBidAsk) 
		{
            EquityTickDecompressed *equityTick = (EquityTickDecompressed *)tick;
            [ValueUtil updateLabel:cell.bidLabel withPrice:equityTick.bid refPrice:referencePrice whiteStyle:YES compact:YES]; //買價
            [ValueUtil updateLabel:cell.askLabel withPrice:equityTick.ask refPrice:referencePrice whiteStyle:YES compact:YES]; //賣價
            if (tick.price == equityTick.bid) {
                cell.volLabel.textColor = [UIColor darkGrayColor];
            }else if (tick.price == equityTick.ask){
                cell.volLabel.textColor = [UIColor orangeColor];
            }
        }
        else {
            cell.volLabel.textColor = [UIColor blackColor];
            cell.bidLabel.text = nil;
            cell.askLabel.text = nil;
        }
		
		//成交價
        [ValueUtil updateTickPriceLabel:cell.tradeLabel withPrice:tick.price refPrice:referencePrice ceilingPrice:ceilingPrice floorPrice:floorPrice whiteStyle:YES];
		
		//漲跌
        [ValueUtil updateChangeLabel:cell.chgLabel withPrice:tick.price refPrice:referencePrice whiteStyle:YES compact:NO];

        double vol = [self getRealValue:tick.volume Unit:tick.volumeUnit];

        if (vol > 0 && seq > 1) {

            tick = [tickData copyTickAtSequenceNo:seq-1];

            if (tick != nil) {
                
                double oldVol =[self getRealValue:tick.volume Unit:tick.volumeUnit];
                vol -=oldVol;
            }
            else
                vol = 0;
        }

        if (vol > 0) {

            cell.volLabel.text = [CodingUtil stringWithVolumeByValue:vol];
//            cell.volLabel.textColor = [UIColor blackColor];
        }
        else {
            cell.volLabel.text = hasVolume ? @"----" : nil;
            cell.volLabel.textColor = [UIColor lightGrayColor];
        }
    }
    else {
        cell.timeLabel.text = @"--:--";
        cell.bidLabel.text = nil;
        cell.askLabel.text = nil;
        cell.tradeLabel.text = nil;
        cell.chgLabel.text = nil;
        cell.volLabel.text = nil;
        cell.tradeLabel.backgroundColor = [UIColor clearColor];
    }
    
    [tickData unlock];
#endif
    return cell;
}

-(double)getRealValue:(double)value Unit:(NSInteger)unit
{
	double realValue = value * pow(1000, unit);
	return realValue;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat tableWidth = CGRectGetWidth(_realtimeListTableView.bounds);
    CGFloat offset;
    self.realTimeTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 33.0f)];
    _realTimeTitleView.backgroundColor = [UIColor colorWithRed:0.044 green:0.337 blue:0.442 alpha:1.000];
    NSArray *titleArray;
    if(hasBidAsk){
        offset = tableWidth/6;
        titleArray = @[NSLocalizedStringFromTable(@"時間", @"Equity", @""),
                       NSLocalizedStringFromTable(@"買價", @"Equity", @""),
                       NSLocalizedStringFromTable(@"賣價", @"Equity", @""),NSLocalizedStringFromTable(@"成交", @"Equity", @""),NSLocalizedStringFromTable(@"Chg", @"Equity", @""),NSLocalizedStringFromTable(@"Vol", @"Equity", @"")];
    }else{
        offset = tableWidth/4;
        titleArray = @[NSLocalizedStringFromTable(@"時間", @"Equity", @""),NSLocalizedStringFromTable(@"成交", @"Equity", @""),NSLocalizedStringFromTable(@"Chg", @"Equity", @""),NSLocalizedStringFromTable(@"Vol", @"Equity", @"")];
    }
    
    NSUInteger counter=0;
	for (NSString *title in titleArray) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = title;
        titleLabel.frame = CGRectMake(offset * counter, 0, offset, 33.0f);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        counter++;
        [_realTimeTitleView addSubview:titleLabel];
    }
    return _realTimeTitleView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 33.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 33.0f;
}
#pragma mark AutoLayout

- (void)setLayout {
    
    NSDictionary *metrics = @{@"tableViewHeight": @((CGRectGetHeight(self.view.bounds)-44)*3/4),
                              @"panelHeight" : @(100)
                              };
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings( _realtimeListTableView, _infoPanel);
    [self.view removeConstraints:self.view.constraints];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_realtimeListTableView][_infoPanel(panelHeight)]|" options:0 metrics:metrics views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_realtimeListTableView]|" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_infoPanel]|" options:0 metrics:nil views:viewsDictionary]];
}

-(void)viewDidLayoutSubviews
{
//    [super viewDidLayoutSubviews];
     [self.pageControl setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height - 10)];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    self.infoPanel.contentOffset = CGPointMake(self.infoPanel.bounds.size.width * [dataModel.infoPanelCenter.currentInfoPage intValue], 0);
}
@end
