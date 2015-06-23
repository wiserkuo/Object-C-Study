//  走勢
//  FSEquityDrawViewController.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/13.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSEquityDrawViewController.h"
#import "Snapshot.h"
#import "FSEquityDrawViewTickPlotDataSourceProtocol.h"
#import "FSCrossHair.h"
#import "FSEquityDrawCrossHairInfoPanel.h"
#import "FSAverageValueLine.h"
#import "ChangeStockViewController.h"
#import "FSEquityInfoPanel.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSEquityDrawButtonSection.h"
#import "FSEquityDrawCrossHairInfo.h"
#import "DDPageControl.h"
#import "FSEquityDrawViewTickPlotDataSource.h"
#import "EquityTick.h"
#import "FSSocketProc.h"
#import "FSBAQuery.h"
#import "FSSnapshotQueryOut.h"

#define SNAPSHOT_FONTSIZE 19.0f

static NSString *MainItemKVOIdentifier = @"MainItemKVOIdentifier";
static NSString *ComparedItemKVOIdentifier = @"ComparedItemKVOIdentifier";

@interface FSEquityDrawViewController (){
    FSBAQuery * baQuery;
    BOOL firstTime;
    BOOL isLogin;
}
@property (nonatomic, strong) UIView *graphContainer;
@property (nonatomic, strong) CPTGraphHostingView *priceHostView;
@property (nonatomic, strong) CPTGraphHostingView *volumeHostView;
@property (nonatomic, strong) CPTGraphHostingView *comparedPriceHostView;
@property (nonatomic, strong) CPTGraphHostingView *comparedVolumeHostView;
@property (nonatomic, strong) CPTGraphHostingView *crossLineView;

@property (nonatomic, strong) FSEquityDrawButtonSection *buttonContainerScrollView;

@property (nonatomic, strong) FSEquityDrawCrossHairInfoPanel *crossInfoPanel;

@property (nonatomic, assign) double limitUp;
@property (nonatomic, assign) double limitDown;

@property (nonatomic, strong) FSCrossHair *crossHair;
@property (nonatomic, strong) FSCrossHair *volumeCrossHair;

@property (nonatomic, assign) NSUInteger crossHairInfoPanelPosition;

@property (nonatomic, strong) FSAverageValueLine *averageValueLine;

@property (nonatomic, strong) FSCDP *cdp;
@property (nonatomic, strong) NSMutableSet *cdpLabels;
@property (nonatomic, strong) NSMutableSet *cdpLocations;

@property (nonatomic, strong) NSMutableArray *cachedMainTickNoBox;
@property (nonatomic, strong) NSMutableArray *cachedComparedTickNoBox;

@property (nonatomic, strong) FSEquityInfoPanel *infoPanel;
//@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) NSMutableArray *dataNameArray;
@property (nonatomic, strong) NSMutableArray *dataIdArray;
@property (nonatomic, strong) NSMutableArray *categoryArray;
@property (nonatomic, strong) NSMutableArray *groupIdArray;
@property (strong, nonatomic) DDPageControl *pageControl;
@property (nonatomic) BOOL cleanFlag;

@property (strong, nonatomic) EquityTickDecompressed * tick;
@property (strong, nonatomic) EquityTickDecompressed * comparedTick;

@property (strong, nonatomic) MarketInfoItem *market;
@end

@implementation FSEquityDrawViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    baQuery = [[FSBAQuery alloc]init];
    _tickPlotDataSource = [[FSEquityDrawViewTickPlotDataSource alloc] initWithPortfolioItem:[FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem comparedPortfolioItem:[FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].comparedPortfolioItem];
    
    _tickPlotDataSource.delegate = self;
    self.cachedMainTickNoBox = [[NSMutableArray alloc]init];
    self.cachedComparedTickNoBox = [[NSMutableArray alloc]init];
    
    self.dataNameArray = [[NSMutableArray alloc]init];
    self.dataIdArray = [[NSMutableArray alloc]init];
    self.categoryArray = [[NSMutableArray alloc]init];
    self.groupIdArray = [[NSMutableArray alloc]init];
    dataLock = [[NSRecursiveLock alloc]init];
    // Do any additional setup after loading the view.
    
    NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
    NSString *fileName = @"TechViewDefaultIndicator.plist";
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSMutableDictionary *techViewInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    _twoStock =[(NSNumber *)[techViewInfo objectForKey:@"stockCompareValue"]intValue];
    [self configureHost];
    
    [self configureGraph];
    [self configureAxes];

    [self addButtonContainerScrollView];
    
    [self addCrossInfoPanel];
    
    [self addComparedPortfolioPlot];
    [self configurePlots];
    [self addCrossHair];
    [self addInfoPanel];
    [self initPageControll];
    [self setLayOut];
    
    if (_twoStock){
        [_buttonContainerScrollView compareBtnClick];
        [self showComparedPortfolioPlot];
    }else{
        [self hideComparedPortfolioPlot];
    }
}

- (void)dealloc {
//    [_tickPlotDataSource.volumeStoreInSameTime removeAllObjects];
//    [_tickPlotDataSource.comparedVolumeStoreInSameTime removeAllObjects];
//    [_cdp stopWatch];
//    [_tickPlotDataSource stopWatch];
//    [_tickPlotDataSource stopWatchComparedEquity];
//    NSLog(@"=======deallocdeallocdeallocdeallocdealloc=====");
    //    if (_comparedValue) {
    //        [_comparedVolumeHostView.hostedGraph plotWithIdentifier:@"Compared Volume Plot"].hidden = YES;
    //    }else{
    //       [_volumeHostView.hostedGraph plotWithIdentifier:@"Volume Plot"].hidden = YES;
    //    }
    //    [self cancelObserveWatchedPortfolio];
}

- (void)initPageControll {
    
    self.pageControl = [[DDPageControl alloc] init];
    [self setPageNum];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    
    self.pageControl.currentPage = [dataModel.infoPanelCenter.currentInfoPage intValue];
    
    [self.pageControl setDefersCurrentPageDisplay: YES] ;
	[self.pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
	[self.pageControl setOnColor: [UIColor redColor]];
	[self.pageControl setOffColor: [UIColor redColor]];
	[self.pageControl setIndicatorDiameter: 7.0f] ;
	[self.pageControl setIndicatorSpace: 7.0f] ;
    
    [self.view addSubview:self.pageControl];
    self.pageControl.hidden = YES;
}

-(void)setPageNum{
    
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
                [portfolioItem setFocus];
                [baQuery sendWithIdentCodeSymbol:[portfolioItem getIdentCodeSymbol]];
            }else if(fractionalPage>=1 && fractionalPage <4){
                [portfolioItem killFocus];
            }
        }
	}
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    dataModel.infoPanelCenter.currentInfoPage = @(self.pageControl.currentPage);
}

-(void)sectorIdCallBack:(NSMutableArray *)dataArray{
    [_infoPanel reloadMarketInfo:dataArray];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView {
    
	[self.pageControl updateCurrentPageDisplay] ;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerLoginNotificationCallBack:self seletor:@selector(getCommodityNo)];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(sendRequest)];
    //搜尋自選股群組名稱
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseGroupTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserGroup) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
    FSSocketProc * mainSocket = dataModal.mainSocket;
    [_tickPlotDataSource prepareVolume];
    [self setPageNum];
    [_infoPanel reSetInfoPanel];
    if (mainSocket.isConnected) {
        [self setWatch];
        [self reloadData];
    }
    PortfolioItem * portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    [self setCurrentInfoPage];
    
    if (_twoStock) {
        [_buttonContainerScrollView setNeedsUpdateConstraints];
    }
#ifdef LPCB
    PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
    FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:portfolioItem.getIdentCodeSymbol];
    [self reloadInfoPanel:snapshot];
    [dataModal.category setTargetObj:self];
    [dataModal.category searchSectorIdByIdentCode:[NSString stringWithFormat:@"%c%c",portfolioItem->identCode[0],portfolioItem->identCode[1]] Symbol:portfolioItem->symbol];
#else
    
    [dataModal.category setTargetObj:self];
    [dataModal.category searchSectorIdByIdentCode:[NSString stringWithFormat:@"%c%c",portfolioItem->identCode[0],portfolioItem->identCode[1]] Symbol:portfolioItem->symbol];
//    EquitySnapshotDecompressed *snapshot = ((EquityTick *) _dataSource).snapshot;
//    [self countPlatWithSnapshot:snapshot];
//    [self reloadInfoPanel:snapshot];
#endif
}

-(void)setCurrentInfoPage{
    PortfolioItem * portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    NSNumber *infoPanelPage = dataModal.infoPanelCenter.currentInfoPage;
    if (infoPanelPage != [NSNumber numberWithInt:0]) {
        if(infoPanelPage == [NSNumber numberWithLong:2]){
            [portfolioItem setFocus];
            [baQuery sendWithIdentCodeSymbol:[portfolioItem getIdentCodeSymbol]];
        }else if(infoPanelPage >= [NSNumber numberWithLong:1] && infoPanelPage < [NSNumber numberWithLong:4]){
            [portfolioItem killFocus];
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //    _tickPlotDataSource.delegate = nil;
//    _buttonContainerScrollView.delegate = nil;
//    _infoPanel.delegate = nil;
//    _cdp.delegate = nil;
    [self unregisterLoginNotificationCallBack:self];
    [self unRegisterSecurityRegisterNotificationCallBack:self];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    
    dataModal.indicator.twoStockCompare = _twoStock;
    [dataModal.indicator writeDefaultBottomViewIndicator];

    [dataModal.securitySearchModel setChooseTarget:nil];
    [dataModal.securitySearchModel setChooseGroupTarget:nil];
    [dataModal.category setTargetObj:nil];
    
//    [_tickPlotDataSource.volumeStoreInSameTime removeAllObjects];
//    [_tickPlotDataSource.comparedVolumeStoreInSameTime removeAllObjects];
    [_cdp stopWatch];
    
    [_tickPlotDataSource stopWatch];
    [_tickPlotDataSource stopWatchComparedEquity];
    firstTime = NO;
}

-(void)reloadData{
    [dataLock lock];

    [_tickPlotDataSource updateMarketTime];
    if (_tickPlotDataSource.totalTime !=0) {
        [self configureXRange];
//        //畫價格的格線
//        [self drawXAxisGridLineOnPriceGraph];
//        //畫量圖的格線
//        [self drawXAxisGridLineOnVolumeGraph];
        [self addCDP];

    }
//    [_cdp startWatch];
//    [self setWatch];
//    [self observeWatchedPortfolio];
    [self resetSelectComparePortfoioButtonTitle];
    [self reloadPriceGraph];
    [self reloadVolumeGraph];
    [self reloadReferencePricePlot];
    [self hideCrossInfoPanel];
    [self hideCrossHair];
    [dataLock unlock];
}

#pragma mark - InfoPanel

- (void)addInfoPanel
{
    self.infoPanel = [[FSEquityInfoPanel alloc] initWithPortfolioItem:_tickPlotDataSource.portfolioItem];
    _infoPanel.translatesAutoresizingMaskIntoConstraints = NO;
    _infoPanel.delegate = self;
    [self.view addSubview:_infoPanel];
    
}

#pragma mark - Cross Info Panel

- (void)addCrossInfoPanel
{
    if (_crossInfoPanel == nil) {
        CGFloat panelWidth = CGRectGetWidth(self.view.bounds)/2;
        CGFloat panelHeight = CGRectGetHeight(self.view.bounds)/2;
        self.crossInfoPanel = [[FSEquityDrawCrossHairInfoPanel alloc] initWithFrame:CGRectMake(panelWidth, panelHeight, panelWidth, panelHeight)];
        _crossHairInfoPanelPosition = RightSide;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTap:)];
        [_crossInfoPanel addGestureRecognizer:tapGestureRecognizer];
        //一開始是隱藏的
        [self hideCrossInfoPanel];
    }
    CGFloat height = [UIScreen mainScreen].applicationFrame.size.height;
    _crossInfoPanel.frame = CGRectMake(self.priceHostView.hostedGraph.plotAreaFrame.paddingLeft+140, height-320, 100, 130);
    [self.view addSubview:_crossInfoPanel];
}

-(void)viewTap:(UITapGestureRecognizer *)sender{
    [self hideCrossInfoPanel];
    [self hideCrossHair];
}

- (void)removeCrossInfoPanel
{
    if (_crossInfoPanel != nil) {
        [_crossInfoPanel removeFromSuperview];
    }
}

/**
 *  十字線出現後，接著顯示資訊面板
 */
- (void)showCrossInfoPanel
{
    [UIView animateWithDuration:0.33 animations:^() {
        _crossInfoPanel.hidden = NO;
    }];
}

- (void)hideCrossInfoPanel
{
    [UIView animateWithDuration:0.33 animations:^() {
        _crossInfoPanel.hidden = YES;
    }];
}

- (BOOL)isCrossInfoPanelVisible
{
    return _crossInfoPanel.hidden = NO;
    
}

#pragma mark - Button Area

- (void)addButtonContainerScrollView
{
    self.buttonContainerScrollView = [[FSEquityDrawButtonSection alloc] init];
    _buttonContainerScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _buttonContainerScrollView.delegate = self;
    [self.view addSubview:_buttonContainerScrollView];
}


#pragma mark - Action

- (void)changeStock
{
    [self.navigationController pushViewController:[[ChangeStockViewController alloc] initWithNumber:2] animated:NO];
    
}

-(void)setWatch{
    
    PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    PortfolioItem *comparedPortfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].comparedPortfolioItem;
    self.market = [[[FSDataModelProc sharedInstance]marketInfo] getMarketInfo:portfolioItem->market_id];
    
    if (![[_cdp.portfolioItem getIdentCodeSymbol] isEqualToString:[portfolioItem getIdentCodeSymbol]]) {
        [_cdp stopWatch];
        [_cdp clearData];
        [self reloadCDP];
        [self clearCDPLabel];
        _cdp.portfolioItem = portfolioItem;
    }
//    [_cdp startWatch];
    [_tickPlotDataSource stopWatch];
    [self clearSnapshotPriceLabel];
    [self clearVolumeLabel];
    _tickPlotDataSource.portfolioItem = portfolioItem;
    _tickPlotDataSource.dataSource = nil;
    [self clearCachedMainTickBox];
    [_tickPlotDataSource startWatch];
    
    [self resetSelectComparePortfoioButtonTitle];
    [_tickPlotDataSource stopWatchComparedEquity];
    _tickPlotDataSource.comparedPortfolioItem = comparedPortfolioItem;
    [self clearCachedComparedTickBox];
    [_tickPlotDataSource startWatchComparedEquity];
    
    
}

-(void)getCommodityNo{
    isLogin = YES;
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[[portfolioItem getIdentCodeSymbol]]];
    [self reloadData];
}

-(void)sendRequest{
    if (isLogin) {
        [_tickPlotDataSource startWatch];
        [_tickPlotDataSource startWatchComparedEquity];
        isLogin = NO;

    }
    [self reloadData];
}
#pragma mark - Core Plot

-(void)configureHost {
//    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds))];
//    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addSubview:_containerView];
    self.graphContainer = [[UIView alloc] init];
    _graphContainer.translatesAutoresizingMaskIntoConstraints = NO;
    _graphContainer.layer.borderColor = [UIColor blackColor].CGColor;
    _graphContainer.layer.borderWidth = 0.5f;
    [self.view addSubview:_graphContainer];
    self.priceHostView = [[CPTGraphHostingView alloc] init];
    self.volumeHostView = [[CPTGraphHostingView alloc] init];
    self.crossLineView = [[CPTGraphHostingView alloc] init];
    self.comparedPriceHostView = [[CPTGraphHostingView alloc] init];
    self.comparedVolumeHostView = [[CPTGraphHostingView alloc] init];
    self.priceHostView.translatesAutoresizingMaskIntoConstraints = NO;
    self.volumeHostView.translatesAutoresizingMaskIntoConstraints = NO;
    self.crossLineView.translatesAutoresizingMaskIntoConstraints = NO;
    self.comparedPriceHostView.translatesAutoresizingMaskIntoConstraints = NO;
    self.comparedVolumeHostView.translatesAutoresizingMaskIntoConstraints = NO;
    [_graphContainer addSubview:_comparedPriceHostView];
    [_graphContainer addSubview:_comparedVolumeHostView];
    [_graphContainer addSubview:_priceHostView];
    [_graphContainer addSubview:_volumeHostView];
    [_graphContainer addSubview:_crossLineView];
}

-(void)configureGraph {
    // 1 - Create the graph
    self.priceHostView.hostedGraph = [[CPTXYGraph alloc] init];
    //套用白色背景
    self.priceHostView.hostedGraph.backgroundColor = (__bridge CGColorRef)([UIColor clearColor]);
    //讓可視區域從(0, 0)開始
    self.priceHostView.hostedGraph.paddingTop = 0.0f;
    self.priceHostView.hostedGraph.paddingBottom = 0.0f;
    self.priceHostView.hostedGraph.paddingLeft = 0.0f;
    self.priceHostView.hostedGraph.paddingRight = 0.0f;
    
    // 2 - Set graph title
    //    NSString *title = @"Portfolio Prices: April 2012";
    //    graph.title = title;
    
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor blackColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    self.priceHostView.hostedGraph.titleTextStyle = titleStyle;
    self.priceHostView.hostedGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    self.priceHostView.hostedGraph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    
    // 4 - Set padding for plot area
    [self.priceHostView.hostedGraph.plotAreaFrame setPaddingLeft:75.0f];
    [self.priceHostView.hostedGraph.plotAreaFrame setPaddingRight:0.0f];
    [self.priceHostView.hostedGraph.plotAreaFrame setPaddingTop:0.0f];
    [self.priceHostView.hostedGraph.plotAreaFrame setPaddingBottom:0.0f];
    [[self.priceHostView.hostedGraph plotAreaFrame] setBorderLineStyle:nil];
    self.priceHostView.hostedGraph.plotAreaFrame.masksToBorder = NO;
    
    
    // 5 - Enable user interactions for plot space
    //要可以互動才可以trigger十字線
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.priceHostView.hostedGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    plotSpace.identifier = @"Price Plot Space";
    plotSpace.delegate = self;
    
    
    // 1 - Create the graph
    self.volumeHostView.hostedGraph = [[CPTXYGraph alloc] init];
    //套用白色背景
    self.volumeHostView.hostedGraph.backgroundColor = (__bridge CGColorRef)([UIColor clearColor]);
    //讓可視區域從(0, 0)開始
    self.volumeHostView.hostedGraph.paddingTop = 0.0f;
    self.volumeHostView.hostedGraph.paddingBottom = 0.0f;
    self.volumeHostView.hostedGraph.paddingLeft = 0.0f;
    self.volumeHostView.hostedGraph.paddingRight = 0.0f;
    
    // 4 - Set padding for plot area
    [self.volumeHostView.hostedGraph.plotAreaFrame setPaddingLeft:75.0f];
    [self.volumeHostView.hostedGraph.plotAreaFrame setPaddingRight:0.0f];
    [self.volumeHostView.hostedGraph.plotAreaFrame setPaddingTop:0.0f];
    [self.volumeHostView.hostedGraph.plotAreaFrame setPaddingBottom:0.0f];
    [[self.volumeHostView.hostedGraph plotAreaFrame] setBorderLineStyle:nil];
    // 5 - Enable user interactions for plot space
    
    CPTXYPlotSpace *plotSpace2 = (CPTXYPlotSpace *) self.volumeHostView.hostedGraph.defaultPlotSpace;
    plotSpace2.allowsUserInteraction = NO;
    plotSpace2.identifier = @"Volume Plot Space";
    plotSpace2.delegate = self;
    
    
    
    // 1 - Create the graph
    self.crossLineView.hostedGraph = [[CPTXYGraph alloc] init];
    //套用白色背景
//    [self.crossLineView.hostedGraph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
    self.crossLineView.hostedGraph.backgroundColor = (__bridge CGColorRef)([UIColor clearColor]);
    //讓可視區域從(0, 0)開始
    self.crossLineView.hostedGraph.paddingTop = 0.0f;
    self.crossLineView.hostedGraph.paddingBottom = 0.0f;
    self.crossLineView.hostedGraph.paddingLeft = 0.0f;
    self.crossLineView.hostedGraph.paddingRight = 0.0f;
    
    // 4 - Set padding for plot area
    [self.crossLineView.hostedGraph.plotAreaFrame setPaddingLeft:75.0f];
    [self.crossLineView.hostedGraph.plotAreaFrame setPaddingRight:0.0f];
    [self.crossLineView.hostedGraph.plotAreaFrame setPaddingTop:0.0f];
    [self.crossLineView.hostedGraph.plotAreaFrame setPaddingBottom:0.0f];
    [[self.crossLineView.hostedGraph plotAreaFrame] setBorderLineStyle:nil];
    
    // 5 - Enable user interactions for plot space
    //要可以互動才可以trigger十字線
    CPTXYPlotSpace *linePlotSpace = (CPTXYPlotSpace *) self.crossLineView.hostedGraph.defaultPlotSpace;
    linePlotSpace.allowsUserInteraction = NO;
    linePlotSpace.identifier = @"Cross Line Space";
    linePlotSpace.delegate = self;
    
    
    //雙走勢的走勢線
    // 1 - Create the graph
    self.comparedPriceHostView.hostedGraph = [[CPTXYGraph alloc] init];
    //套用白色背景
    [self.comparedPriceHostView.hostedGraph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    //讓可視區域從(0, 0)開始
    self.comparedPriceHostView.hostedGraph.paddingTop = 0.0f;
    self.comparedPriceHostView.hostedGraph.paddingBottom = 0.0f;
    self.comparedPriceHostView.hostedGraph.paddingLeft = 0.0f;
    self.comparedPriceHostView.hostedGraph.paddingRight = 0.0f;
    
    // 4 - Set padding for plot area
    [self.comparedPriceHostView.hostedGraph.plotAreaFrame setPaddingLeft:75.0f];
    [self.comparedPriceHostView.hostedGraph.plotAreaFrame setPaddingRight:0.0f];
    [self.comparedPriceHostView.hostedGraph.plotAreaFrame setPaddingTop:0.0f];
    [self.comparedPriceHostView.hostedGraph.plotAreaFrame setPaddingBottom:0.0f];
    [[self.comparedPriceHostView.hostedGraph plotAreaFrame] setBorderLineStyle:nil];
    self.comparedPriceHostView.hostedGraph.plotAreaFrame.masksToBorder = NO;
    
    //雙走勢的量圖
    // 1 - Create the graph
    self.comparedVolumeHostView.hostedGraph = [[CPTXYGraph alloc] init];
    //套用白色背景
    [self.comparedVolumeHostView.hostedGraph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    //讓可視區域從(0, 0)開始
    self.comparedVolumeHostView.hostedGraph.paddingTop = 0.0f;
    self.comparedVolumeHostView.hostedGraph.paddingBottom = 0.0f;
    self.comparedVolumeHostView.hostedGraph.paddingLeft = 0.0f;
    self.comparedVolumeHostView.hostedGraph.paddingRight = 0.0f;
    
    // 4 - Set padding for plot area
    [self.comparedVolumeHostView.hostedGraph.plotAreaFrame setPaddingLeft:75.0f];
    [self.comparedVolumeHostView.hostedGraph.plotAreaFrame setPaddingRight:0.0f];
    [self.comparedVolumeHostView.hostedGraph.plotAreaFrame setPaddingTop:0.0f];
    [self.comparedVolumeHostView.hostedGraph.plotAreaFrame setPaddingBottom:0.0f];
    [[self.comparedVolumeHostView.hostedGraph plotAreaFrame] setBorderLineStyle:nil];
    self.comparedVolumeHostView.hostedGraph.plotAreaFrame.masksToBorder = NO;

}

-(void)configureAxes {
    /*
     讓Core Plot先不去計算坐標軸數字，提高效能。拿掉這段code會造成嚴重的效能問題。
     */
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;
    
    CPTAxis *xAxis = axisSet.xAxis;
    xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    CPTAxis *yAxis = axisSet.yAxis;
    yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    /*
     X軸樣式
     */
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];
    /*
     調整X軸標示數字的樣式
     */
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor colorWithComponentRed:41.0f/255.0f green:42.0f/255.0f blue:94.0f/255.0f alpha:1.0f];
    axisTextStyle.fontName = @"Helvetica";
    axisTextStyle.fontSize = 16.0f;
    /*
     X軸分隔虛線樣式
     */
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor grayColor];
    gridLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:2], [NSNumber numberWithInteger:1], nil];
    gridLineStyle.lineWidth = 0.3f;
    
    xAxis.labelTextStyle = axisTextStyle;
    xAxis.majorTickLineStyle = axisLineStyle;
    xAxis.majorTickLength = 0.0f;
    xAxis.majorGridLineStyle = gridLineStyle;//畫格線
    xAxis.tickDirection = CPTSignPositive;//數字label標示是在正的象限
    
//    //Y軸的數字最多到小數第三位
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//    [numberFormatter setMaximumFractionDigits:3];
//    [numberFormatter setMinimumFractionDigits:2];
//    yAxis.labelFormatter = numberFormatter;
    
    /*
     讓Core Plot先不去計算坐標軸數字，提高效能。拿掉這段code會造成嚴重的效能問題。
     */
    CPTXYAxisSet *volumeAxisSet = (CPTXYAxisSet *) self.volumeHostView.hostedGraph.axisSet;
    
    volumeAxisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    volumeAxisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    //雙走勢隔線
    CPTXYAxisSet *comparedAxisSet = (CPTXYAxisSet *) self.comparedPriceHostView.hostedGraph.axisSet;
    

//    CPTMutableTextStyle *normalStyle = [comparedAxisSet.yAxis.labelTextStyle mutableCopy];
//    normalStyle.color = [CPTColor clearColor];
//    comparedAxisSet.yAxis.labelTextStyle = normalStyle;
    comparedAxisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    comparedAxisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    //雙走勢量圖隔線
    CPTXYAxisSet *comparedVolumeAxisSet = (CPTXYAxisSet *) self.comparedVolumeHostView.hostedGraph.axisSet;
    
//    CPTMutableLineStyle *comparedVolumeGridLineStyle = [CPTMutableLineStyle lineStyle];
//    comparedVolumeGridLineStyle.lineColor = [CPTColor grayColor];
//    comparedVolumeGridLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:2], [NSNumber numberWithInteger:1], nil];
//    gridLineStyle.lineWidth = 0.3f;
//    comparedVolumeAxisSet.xAxis.majorGridLineStyle = gridLineStyle;//畫格線
//    comparedVolumeAxisSet.yAxis.majorGridLineStyle = gridLineStyle;//畫格線
    
    comparedVolumeAxisSet.xAxis.majorTickLength = 0.0f;
    comparedVolumeAxisSet.xAxis.minorTickLength = 0.0f;
    
    comparedVolumeAxisSet.yAxis.majorTickLength = 0.0f;
    comparedVolumeAxisSet.yAxis.minorTickLength = 0.0f;
    comparedVolumeAxisSet.yAxis.axisLabels = nil;
    comparedVolumeAxisSet.yAxis.majorTickLocations = nil;
    CPTMutableTextStyle *comparedVolumeNormalStyle = [comparedVolumeAxisSet.yAxis.labelTextStyle mutableCopy];
    comparedVolumeNormalStyle.color = [CPTColor clearColor];
    comparedVolumeAxisSet.yAxis.labelTextStyle = comparedVolumeNormalStyle;
    
    comparedVolumeAxisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    comparedVolumeAxisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    
    CPTXYAxisSet *crossLineViewaxisSet = (CPTXYAxisSet *) self.crossLineView.hostedGraph.axisSet;
    CPTMutableTextStyle *newStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
    newStyle.color = [CPTColor clearColor];
    crossLineViewaxisSet.yAxis.labelTextStyle = newStyle;
    crossLineViewaxisSet.yAxis.axisLabels = nil;
    crossLineViewaxisSet.yAxis.majorTickLength = 0;
    crossLineViewaxisSet.yAxis.minorTickLength = 0;
    crossLineViewaxisSet.yAxis.majorTickLocations = nil;

}

- (void)configureXRange {
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.priceHostView.hostedGraph.defaultPlotSpace;
    CPTXYPlotSpace *xyPlotSpace2 = (CPTXYPlotSpace *) self.volumeHostView.hostedGraph.defaultPlotSpace;
    CPTXYPlotSpace *xyPlotSpace3 = (CPTXYPlotSpace *) self.crossLineView.hostedGraph.defaultPlotSpace;
    CPTXYPlotSpace *xyPlotSpace4 = (CPTXYPlotSpace *) self.comparedPriceHostView.hostedGraph.defaultPlotSpace;
    CPTXYPlotSpace *xyPlotSpace5 = (CPTXYPlotSpace *) self.comparedVolumeHostView.hostedGraph.defaultPlotSpace;
    //以台灣為例，從9:00~13:30(中間12:00~1:00休息)，剛好270分鐘
    //Patch:totalTime + 1
    NSNumber *totalTime = [NSNumber numberWithUnsignedInt:_tickPlotDataSource.totalTime + 1];
    xyPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat([(NSNumber *)totalTime floatValue]+1)];
    xyPlotSpace2.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat([(NSNumber *)totalTime floatValue]+1)];
    xyPlotSpace3.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat([(NSNumber *)totalTime floatValue]+1)];
    xyPlotSpace4.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat([(NSNumber *)totalTime floatValue]+1)];
    xyPlotSpace5.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat([(NSNumber *)totalTime floatValue]+1)];
    //把globalXRange設為xRange可以防止scroll
    xyPlotSpace.globalXRange = xyPlotSpace.xRange;
    xyPlotSpace2.globalXRange = xyPlotSpace2.xRange;
    xyPlotSpace3.globalXRange = xyPlotSpace3.xRange;
    xyPlotSpace4.globalXRange = xyPlotSpace4.xRange;
    xyPlotSpace5.globalXRange = xyPlotSpace5.xRange;
//    //多2讓最後一個柱子可以被看到
//    CPTXYPlotSpace *volumePlotSpace = (CPTXYPlotSpace *) self.volumeHostView.hostedGraph.defaultPlotSpace;
//    volumePlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat([totalTime floatValue]+1)];
    
    //設定十字線的寬度
    _crossHair.horizonalLineMaxX = [(NSNumber *)totalTime floatValue];
    _volumeCrossHair.horizonalLineMaxX = [(NSNumber *)totalTime floatValue];
}

-(void)configureScrollLineYRange{
    
    CPTXYPlotSpace *xyPlotSpace3 = (CPTXYPlotSpace *) self.crossLineView.hostedGraph.defaultPlotSpace;
    xyPlotSpace3.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(_crossLineView.hostedGraph.frame.size.height)];
    xyPlotSpace3.globalYRange = xyPlotSpace3.yRange;

}

- (void)configureYRangeBValue:(FSSnapshot *)snapshot {
    [self showSnapshotPriceLabel2:snapshot];
    [self scalePriceGraphToFitPrice2:snapshot];
    [self configureScrollLineYRange];
    
    //檢查十字線面板是否需要更換位置
    [self updateCrossHairVerticalLinePosition];
    //顯示量圖的數字標示
    [self showVolumeLabel];
    //把量圖的yRange移動到最大量，讓最大量可以被看見
    [self scaleVolumeGraphToFitVolume];
    
    if (_comparedValue && _twoStock) {
        [self clearSnapshotPriceLabel];
        [self clearVolumeLabel];
        [self scaleComparedVolumeGraphToFitComparedVolume];
        [self showComparedVolumeLabel];
        [self showPriceLabel];
    }
    if (_isCDPVisible) {
        [self showCDP];
    }
}

- (void)configureYRange:(EquitySnapshotDecompressed *) snapshot
{
    [self showSnapshotPriceLabel:snapshot];
    [self scalePriceGraphToFitPrice:snapshot];
    if (_isCDPVisible) {
        [self showCDP];
    }
    
    [self configureScrollLineYRange];

    //檢查十字線面板是否需要更換位置
    [self updateCrossHairVerticalLinePosition];
    //顯示量圖的數字標示
    [self showVolumeLabel];
    //把量圖的yRange移動到最大量，讓最大量可以被看見
    [self scaleVolumeGraphToFitVolume];
    
    if (_comparedValue) {
        [self clearSnapshotPriceLabel];
        [self clearVolumeLabel];
        [self scaleComparedVolumeGraphToFitComparedVolume];
        [self showComparedVolumeLabel];
    }
}

- (CPTAxisLabel *)axisLabelWithPrice:(double) price textStyle:(CPTMutableTextStyle *) textStyle {
    NSString *priceString = [CodingUtil priceRoundRownWithDouble:price];
    
    CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:priceString textStyle:textStyle];
    //決定位置
    label.tickLocation = CPTDecimalFromDouble(price);
//    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;
    label.offset = 0;//axisSet.yAxis.majorTickLength;
    return label;
}

- (CPTAxisLabel *)comparedAxisLabelWithPrice:(double) price textStyle:(CPTMutableTextStyle *) textStyle
{
    NSString *priceString = [CodingUtil priceRoundRownWithDouble:price];
    CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:priceString textStyle:textStyle];
    //決定位置
    label.tickLocation = CPTDecimalFromDouble(price);
//    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.comparedPriceHostView.hostedGraph.axisSet;
    label.offset = 0;//axisSet.yAxis.majorTickLength;
    return label;
}

- (void)customizeYAxisPriceLabelTextColor:(CPTMutableTextStyle **) style snapshot:(EquitySnapshotDecompressed *) snapshot price:(double) price
{
    if ( (price == snapshot.floorPrice) || (price == _limitDown)) {
        (*style).color = [CPTColor whiteColor];
    }
    else if (price == snapshot.referencePrice) {
        (*style).color = [CPTColor brownColor];
    }
    else if ((price == snapshot.ceilingPrice) || (price == _limitUp)) {
        (*style).color = [CPTColor whiteColor];
    }
    else {
        (*style).color = [CPTColor blueColor];
    }
}

- (void)customizeYAxisPriceLabelBackgroundColor:(CPTAxisLabel **) label snapshot:(EquitySnapshotDecompressed *) snapshot price:(double) price
{
    if ( (price == snapshot.floorPrice) || (price == _limitDown)) {
        (*label).contentLayer.backgroundColor = [StockConstant priceDownGradientTopColor].cgColor;
    }
    else if (price == snapshot.referencePrice) {
        
    }
    else if ((price == snapshot.ceilingPrice) || (price == _limitUp)) {
        (*label).contentLayer.backgroundColor = [StockConstant priceUpGradientTopColor].cgColor;
    }
}

- (void)insertMainPortfolioData:(NSMutableArray *) tickNoBox
{
    //tickNoBox減掉cachedTickNoBox就是多出來的tick，insert到plot中
    NSMutableSet *copiedTickNoBoxSet = [NSMutableSet setWithArray:tickNoBox];
    NSSet *cachedMainTickNoBoxSet = [NSSet setWithArray:_cachedMainTickNoBox];
    [copiedTickNoBoxSet minusSet:cachedMainTickNoBoxSet];
    
    for (NSNumber *tickNo in copiedTickNoBoxSet) {
        NSComparator comparator = ^(NSNumber *obj1, NSNumber *obj2) {
            return [obj1 compare:obj2];
        };
        
        NSUInteger newIndex = [_cachedMainTickNoBox indexOfObject:tickNo
                                                    inSortedRange:(NSRange){0, [_cachedMainTickNoBox count]}
                                                          options:NSBinarySearchingInsertionIndex
                                                  usingComparator:comparator];
        
        [[_priceHostView.hostedGraph plotWithIdentifier:@"CPDTickerSymbolPortfolio"] insertDataAtIndex:newIndex numberOfRecords:1];
        [_cachedMainTickNoBox insertObject:tickNo atIndex:newIndex];
    }
}


- (void)insertComparedPortfolioData:(NSMutableArray *) tickNoBox
{
    //tickNoBox減掉cachedTickNoBox就是多出來的tick，insert到plot中
    NSMutableArray *copiedTickNoBox = [tickNoBox mutableCopy];
    [copiedTickNoBox removeObjectsInArray:_cachedComparedTickNoBox];
    
    for (NSUInteger counter=0; counter < [copiedTickNoBox count] ; counter++) {
//        NSUInteger tickSequenceNo = [((NSNumber *)copiedTickNoBox[counter]) unsignedIntegerValue];
        
        NSComparator comparator = ^(NSNumber *obj1, NSNumber *obj2) {
            return [obj1 compare:obj2];
        };
        NSUInteger newIndex = [_cachedComparedTickNoBox indexOfObject:copiedTickNoBox[counter]
                                                    inSortedRange:(NSRange){0, [_cachedComparedTickNoBox count]}
                                                          options:NSBinarySearchingInsertionIndex
                                                  usingComparator:comparator];
        
        [[_priceHostView.hostedGraph plotWithIdentifier:@"CPDComparedTickerSymbolPortfolio"] insertDataAtIndex:newIndex numberOfRecords:1];
        [_cachedComparedTickNoBox insertObject:copiedTickNoBox[counter] atIndex:newIndex];
    }
    
    
//    [[_priceHostView.hostedGraph plotWithIdentifier:@"CPDTickerSymbolPortfolio"] setNeedsDisplay];
}

- (void)clearCachedMainTickBox
{
    [_cachedMainTickNoBox removeAllObjects];
}

- (void)clearCachedComparedTickBox
{
    [_cachedComparedTickNoBox removeAllObjects];
}

- (void)reloadMainPortfolioData
{
    _buttonContainerScrollView.drawCDPButton.selected = NO;
    [self hideCDP];
    [[_priceHostView.hostedGraph plotWithIdentifier:@"CPDTickerSymbolPortfolio"] reloadData];
    //[[FSHUD sharedFSHUD] hideHUDFor:self.view animated:YES];
}

- (void)reloadComparedPortfolioData
{
    [[_comparedVolumeHostView.hostedGraph plotWithIdentifier:@"CPDComparedTickerSymbolPortfolio"] reloadData];
    [_comparedPriceHostView.hostedGraph reloadData];
}

- (void)reloadReferencePricePlot
{
    [_priceHostView.hostedGraph plotWithIdentifier:@"CPDTickerReferencePrice"].hidden = NO;
    [[_priceHostView.hostedGraph plotWithIdentifier:@"CPDTickerReferencePrice"] reloadData];
}

- (void)reloadCDP
{
    [dataLock lock];
    
    [_priceHostView.hostedGraph addPlot:_cdp.ahPlot];
    [_priceHostView.hostedGraph addPlot:_cdp.nhPlot];
    [_priceHostView.hostedGraph addPlot:_cdp.cdpPlot];
    [_priceHostView.hostedGraph addPlot:_cdp.alPlot];
    [_priceHostView.hostedGraph addPlot:_cdp.nlPlot];
    


    if (_isCDPVisible) {
//        [self showCDP];
        [self reloadPriceGraph];
    }else{
        [self hideCDP];
    }
    [dataLock unlock];
}

- (void)reloadPriceGraph
{
    if ([_priceHostView.hostedGraph respondsToSelector:@selector(reloadData)]) {
        [_priceHostView.hostedGraph reloadData];
    }
    
    if ([_comparedPriceHostView.hostedGraph respondsToSelector:@selector(reloadData)]) {
        [_comparedPriceHostView.hostedGraph reloadData];
    }
//    if (_priceHostView.hostedGraph != nil) {
//        [_priceHostView.hostedGraph reloadData];
//    }
//    if (_comparedPriceHostView.hostedGraph != nil) {
//        [_comparedPriceHostView.hostedGraph reloadData];
//    }

}

- (void)reloadVolumeGraph
{
    if ([_volumeHostView.hostedGraph respondsToSelector:@selector(reloadData)]) {
        [_volumeHostView.hostedGraph reloadData];
    }
    
    if ([_comparedVolumeHostView.hostedGraph respondsToSelector:@selector(reloadData)]) {
        [_comparedVolumeHostView.hostedGraph reloadData];
    }
    
//    if (_volumeHostView.hostedGraph != nil) {
//        [_volumeHostView.hostedGraph reloadData];
        //[_volumeHostView.hostedGraph.defaultPlotSpace scaleToFitPlots:[_volumeHostView.hostedGraph allPlots]];
//    }
//    if (_comparedVolumeHostView.hostedGraph != nil) {
//        [_comparedVolumeHostView.hostedGraph reloadData];
//    }
}

- (void)reloadInfoPanel:(NSObject *) snapshot_src
{
    if ([snapshot_src isKindOfClass:[FSSnapshot class]] || snapshot_src == nil) {
        FSSnapshot *snapshot = (FSSnapshot *)snapshot_src;
        [_infoPanel reloadBValueSnapshot:snapshot];
    } else if ([snapshot_src isKindOfClass:[EquitySnapshotDecompressed class]]) {
        EquitySnapshotDecompressed *snapshot = (EquitySnapshotDecompressed *)snapshot_src;
        [_infoPanel reloadDataWithSnapshot:snapshot];
    }
    
}

-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.priceHostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // 2 - Create the plot
    //走勢的線
    CPTScatterPlot *portfolioPlot = [[CPTScatterPlot alloc] init];
    portfolioPlot.identifier = @"CPDTickerSymbolPortfolio";
//    CPTColor *portfolioColor = [CPTColor colorWithComponentRed:0.383 green:0.639 blue:0.945 alpha:1.000];
    
    CPTColor *portfolioColor = [CPTColor colorWithComponentRed:0 green:0 blue:1.0 alpha:1.0];
    portfolioPlot.dataSource = self.tickPlotDataSource;
    portfolioPlot.delegate = self;
    //加入下面這行才可以讓plotSymbolWasSelectedAtRecordIndex被call
//    portfolioPlot.plotSymbolMarginForHitDetection = 2.0f;
    
    [graph addPlot:portfolioPlot toPlotSpace:plotSpace];
    [_priceHostView.hostedGraph plotWithIdentifier:@"CPDTickerSymbolPortfolio"].hidden = NO;
    //參考價的線，就是一條直線固定在參考價上
    CPTScatterPlot *referencePricePlot = [[CPTScatterPlot alloc] init];
    referencePricePlot.identifier = @"CPDTickerReferencePrice";
    CPTColor *referencePriceColor = [CPTColor grayColor];
    referencePricePlot.dataSource = self.tickPlotDataSource;
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
    portfolioLineStyle.lineWidth = 0.7f;
    portfolioLineStyle.lineColor = portfolioColor;
    portfolioPlot.dataLineStyle = portfolioLineStyle;
    CPTMutableLineStyle *portfolioSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    portfolioSymbolLineStyle.lineColor = portfolioColor;
    
    ////參考價的線樣式
    CPTMutableLineStyle *referencePriceLineStyle = [referencePricePlot.dataLineStyle mutableCopy];
    referencePriceLineStyle.lineWidth = 0.3;
    referencePriceLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:2], [NSNumber numberWithInteger:1], nil];
    referencePriceLineStyle.lineColor = referencePriceColor;
    referencePricePlot.dataLineStyle = referencePriceLineStyle;
    CPTMutableLineStyle *referencePriceSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    referencePriceSymbolLineStyle.lineColor = referencePriceColor;
    
    //    CPTPlotSymbol *portfolioSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    //    portfolioSymbol.fill = [CPTFill fillWithColor:portfolioColor];
    //    portfolioSymbol.lineStyle = portfolioSymbolLineStyle;
    //    portfolioSymbol.size = CGSizeMake(6.0f, 6.0f);
    //    portfolioPlot.plotSymbol = portfolioSymbol;
    
    
    //第一個tick前的線
    CPTScatterPlot *lineBeforeTickPlot = [[CPTScatterPlot alloc] init];
    lineBeforeTickPlot.identifier = @"SymbolLineBeforeFirstTick";
    CPTColor *lineBeforeTickColor = [CPTColor colorWithComponentRed:0 green:0 blue:1.0 alpha:1.0];
    //[CPTColor colorWithComponentRed:0.383 green:0.639 blue:0.945 alpha:1.000];
    lineBeforeTickPlot.dataSource = self.tickPlotDataSource;
    [graph addPlot:lineBeforeTickPlot toPlotSpace:plotSpace];
    
    CPTMutableLineStyle *lineBeforeTickLineStyle = [lineBeforeTickPlot.dataLineStyle mutableCopy];
    lineBeforeTickLineStyle.lineWidth = 1;
    lineBeforeTickLineStyle.lineColor = lineBeforeTickColor;
    lineBeforeTickPlot.dataLineStyle = lineBeforeTickLineStyle;
    
    
    // Add plot space for bar chart
    // 1 - Get graph and plot space
    CPTGraph *volumeGraph = self.volumeHostView.hostedGraph;
    CPTXYPlotSpace *volumePlotSpace = (CPTXYPlotSpace *) volumeGraph.defaultPlotSpace;
    volumePlotSpace.identifier = @"Volume Plot Space";
    
    // Volume plot
    CPTBarPlot *volumePlot = [[CPTBarPlot alloc] init];
    volumePlot.dataSource = self.tickPlotDataSource;
    
    //把柱子的外框去掉(設為透明)
    CPTMutableLineStyle *volumePlotLineStyle = [volumePlot.lineStyle mutableCopy];
    volumePlotLineStyle.lineColor  = [CPTColor clearColor];
    volumePlot.lineStyle = volumePlotLineStyle;

    volumePlot.fill           = [[CPTFill alloc] initWithColor:[CPTColor colorWithComponentRed:0 green:0 blue:1 alpha:1]];
    volumePlot.barWidth       = CPTDecimalFromFloat(2.0f);
    volumePlot.barOffset = CPTDecimalFromFloat(1.0f);//設成width的一半才可以讓柱子的中心點在數據上
    volumePlot.identifier     = @"Volume Plot";
    //    volumePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    [volumeGraph addPlot:volumePlot toPlotSpace:volumePlotSpace];
    
}

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event
{
    NSLog(@"%d", (int)idx);
}

#pragma mark - Core plot touch event

/*
 在走勢上面touch會進入這個事件
 */
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    if  (_twoStock){
        if([(NSString *)space.identifier isEqualToString:@"Cross Line Space"])
        {
            if (point.x<75) {
                [self changeLabelAndPlot];
            }
        }
    }
    
    return YES;
}

/*
 在走勢上面touch或drag會進入這個事件
 */
- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)point
{


    if([(NSString *)space.identifier isEqualToString:@"Cross Line Space"])
    {
        [_crossHair setVerticalLineMaxY:_maxPrice + _maxPrice/8];
        [_volumeCrossHair setVerticalLineMaxY:MAX(_tickPlotDataSource.maxMainVolume, _tickPlotDataSource.maxComparedVolume)];
        //圖表hostView有設位移，所以要把位移減回來，才是正確的point座標
        point.x = point.x - self.crossLineView.hostedGraph.plotAreaFrame.paddingLeft;
        NSDecimal newPoint[2];

#ifdef LPCB
        if (point.x>=0) {
            if (_twoStock) {
                if ([_tickPlotDataSource.dataSource.ticksData count] !=0 || [_tickPlotDataSource.comparedDataSource.ticksData count] !=0) {
                    [self showCrossHair];
                    [self showCrossInfoPanel];
                }
            }else{
                if([_tickPlotDataSource.dataSource.ticksData count] !=0){
                    [self showCrossHair];
                    [self showCrossInfoPanel];
                }
            }
        }
#else
        if (point.x>=0) {
            if (_twoStock) {
                if ([_tickPlotDataSource.dataSource.tickNoBox count] !=0 || [_tickPlotDataSource.comparedDataSource.tickNoBox count] !=0) {
                    [self showCrossHair];
                    [self showCrossInfoPanel];
                }
            }else{
                if([_tickPlotDataSource.dataSource.tickNoBox count] !=0){
                    [self showCrossHair];
                    [self showCrossInfoPanel];
                }
            }
        }
#endif
        //把原本的座標轉換成dataPoint，即真正的資料座標，這樣才能得到真正的時間和價格
        [space.graph.defaultPlotSpace plotPoint:newPoint numberOfCoordinates:space.graph.defaultPlotSpace.numberOfCoordinates forPlotAreaViewPoint:point];
        
        if (_tickPlotDataSource.dataSource == nil){
            [self hideCrossInfoPanel];
            return NO;
        }

            //找出最接近的整數值
        int x = [[NSDecimalNumber decimalNumberWithDecimal:newPoint[0]] intValue];

        if (x>[_tickPlotDataSource.tickStoreInSameTime count]) {
            return NO;
        }
        
        if ( x>0 && x<=391) {
            id obj;
            id comparedObj;
            if (x-1<[_tickPlotDataSource.tickStoreInSameTime count]) {
                obj = [_tickPlotDataSource.tickStoreInSameTime objectAtIndex:x-1];
            }
//                else{
//                    obj = [_tickPlotDataSource.tickStoreInSameTime lastObject];
//                }
            if (x-1<[_tickPlotDataSource.comparedTickStoreInSameTime count]) {
                comparedObj =[_tickPlotDataSource.comparedTickStoreInSameTime objectAtIndex:x-1];
            }
//                else{
//                    comparedObj = [_tickPlotDataSource.comparedTickStoreInSameTime lastObject];
//                }
            PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
            NSNumber *tickPlotX;
            NSNumber *tickPlotY;
            if (_twoStock){
#ifdef LPCB
                if ([obj isKindOfClass:[FSTickData class]]) {
                    FSTickData * tick = (FSTickData *)obj;
                    if (portfolioItem->type_id == 6) {
                        tickPlotY = [NSNumber numberWithDouble:tick.indexValue.calcValue];
                    }else{
                        tickPlotY = [NSNumber numberWithDouble:tick.last.calcValue];
                    }
                    
                }else{
                    tickPlotY = nil;
                }
                tickPlotX = [NSNumber numberWithInt:x];
#else
                if ([obj isKindOfClass:[EquityTickDecompressed class]]) {
                    EquityTickDecompressed * tick = (EquityTickDecompressed *)obj;
                    tickPlotY = [NSNumber numberWithDouble:tick.price];
                }else{
                    tickPlotY = nil;
                }
                tickPlotX = [NSNumber numberWithInt:x];
#endif
                
            }else{
                
#ifdef LPCB
                if ([obj isKindOfClass:[FSTickData class]]) {
                    FSTickData * tick = (FSTickData *)obj;
                    tickPlotX = [NSNumber numberWithUnsignedInt:[tick.time absoluteMinutesTime] - _tickPlotDataSource.chartOpenTime];
                    if (portfolioItem->type_id == 6) {
                        tickPlotY = [NSNumber numberWithDouble:tick.indexValue.calcValue];
                    }else{
                        tickPlotY = [NSNumber numberWithDouble:tick.last.calcValue];
                    }
                }
                else {
                    FSTickData * tick =[self findNearTickByLocation2:x-1];
                    obj = tick;
                    tickPlotX = [NSNumber numberWithUnsignedInt:[tick.time absoluteMinutesTime] - _tickPlotDataSource.chartOpenTime];
                    if (portfolioItem->type_id == 6) {
                        tickPlotY = [NSNumber numberWithDouble:tick.indexValue.calcValue];
                    }else{
                        tickPlotY = [NSNumber numberWithDouble:tick.last.calcValue];
                    }
                }
#else
                
                if ([obj isKindOfClass:[EquityTickDecompressed class]]) {
                    EquityTickDecompressed * tick = (EquityTickDecompressed *)obj;
                    tickPlotX = [NSNumber numberWithUnsignedInt:tick.time];
                    tickPlotY = [NSNumber numberWithDouble:tick.price];
                }
                else {
                    EquityTickDecompressed * tick =[self findNearTickByLocation:x-1];
                    obj = tick;
                    tickPlotX = [NSNumber numberWithUnsignedInt:tick.time];
                    tickPlotY = [NSNumber numberWithDouble:tick.price];
                }
                
#endif
                
            }

            
            if (_twoStock) {
                [_crossHair moveVerticalLineToX:[(NSNumber *)tickPlotX floatValue]];
                [_volumeCrossHair moveVerticalLineToX:[(NSNumber *)tickPlotX floatValue]];
            }else{
                if (_market && _market->endTime_1!=0 && [(NSNumber *)tickPlotX floatValue]>_market->endTime_1-_market->startTime_1) {
                    [_crossHair moveVerticalLineToX:[(NSNumber *)tickPlotX floatValue]-(_market->startTime_2-_market->endTime_1)];
                    [_volumeCrossHair moveVerticalLineToX:[(NSNumber *)tickPlotX floatValue]-(_market->startTime_2-_market->endTime_1)];
                }else{
                    [_crossHair moveVerticalLineToX:[(NSNumber *)tickPlotX floatValue]];
                    [_volumeCrossHair moveVerticalLineToX:[(NSNumber *)tickPlotX floatValue]];
                }
            }
            [_crossHair moveHorizonalLineToY:[(NSNumber *)tickPlotY floatValue]];
            
#ifdef LPCB
            //檢查是否有在比較雙走勢
            FSTickData *comparedTick = nil;
            NSNumber *comparedVolumeNumber = nil;
            if (_buttonContainerScrollView.compareOtherPortfoioButton.selected == YES && _tickPlotDataSource.comparedDataSource.tickCount > 0) {
                if ([comparedObj isKindOfClass:[FSTickData class]]) {
                    comparedTick = (FSTickData *)comparedObj;
                }else{
                    comparedTick = nil;
                }
                
                
                float totalVol = -1;
                if (![comparedObj isKindOfClass:[FSTickData class]]) {
                    totalVol = -1;
                }else{
                    int tickTime =[comparedTick.time absoluteMinutesTime]-_tickPlotDataSource.chartOpenTime;
                    
                    if ([_tickPlotDataSource.comparedVolumeStoreInSameTime count] > tickTime) {
                        totalVol = [[_tickPlotDataSource.comparedVolumeStoreInSameTime objectAtIndex:tickTime]floatValue];
                    }
                }
                
                comparedVolumeNumber =[NSNumber numberWithFloat:totalVol];
            }
            
            //先把觸控的位置轉換成以self.view座標為基準的值
            NSSet *allTouches = [event allTouches];
            if ([allTouches count] >0 ) {
                UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
                if (touch1){
                    [self setIfNeedUpdateInfoPanelPosition:[touch1 locationInView:self.view]];
                    FSTickData * mainTick;
                    if ([obj isKindOfClass:[FSTickData class]]) {
                        mainTick = (FSTickData *)obj;
                    }else{
                        mainTick = nil;
                    }
                    float totalVol = -1;
                    if (![obj isKindOfClass:[FSTickData class]]) {
                        totalVol = -1;
                    }else{
                        int tickTime =[mainTick.time absoluteMinutesTime]-_tickPlotDataSource.chartOpenTime;
                        
                        if ([_tickPlotDataSource.volumeStoreInSameTime count] > tickTime) {
                        totalVol = [(NSNumber *)[_tickPlotDataSource.volumeStoreInSameTime objectAtIndex:tickTime]floatValue];
                        }
                    }
                    NSNumber *mainVolumeNumber =[NSNumber numberWithFloat:totalVol];
                    
                    //_tickPlotDataSource.allVolumes[mainSequenceNum-1];
                    [self updateInfoPanelWithBValue:mainTick mainVolumNumber:mainVolumeNumber comparedEquityTickDecompressed:comparedTick comparedVolumeNumber:comparedVolumeNumber];
                }
            }
 
#else
            //檢查是否有在比較雙走勢
            EquityTickDecompressed *comparedTick = nil;
            NSNumber *comparedVolumeNumber = nil;
            if (_buttonContainerScrollView.compareOtherPortfoioButton.selected == YES && _tickPlotDataSource.comparedDataSource.tickCount > 0) {
                if ([comparedObj isKindOfClass:[EquityTickDecompressed class]]) {
                    comparedTick = (EquityTickDecompressed *)comparedObj;
                }else{
                    comparedTick = nil;
                }
                
                
                float totalVol;
                if (![comparedObj isKindOfClass:[EquityTickDecompressed class]]) {
                    totalVol = -1;
                }else{
                    totalVol = [(NSNumber *)[_tickPlotDataSource.comparedVolumeStoreInSameTime objectAtIndex:comparedTick.time]floatValue];
                }
                
                comparedVolumeNumber =[NSNumber numberWithFloat:totalVol]; //_tickPlotDataSource.allComparedVolumes[comparedSequenceNum-1];
            }
            
            //先把觸控的位置轉換成以self.view座標為基準的值
            NSSet *allTouches = [event allTouches];
            if ([allTouches count] >0 ) {
                UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
                if (touch1){
                    [self setIfNeedUpdateInfoPanelPosition:[touch1 locationInView:self.view]];
                    EquityTickDecompressed * mainTick;
                    if ([obj isKindOfClass:[EquityTickDecompressed class]]) {
                        mainTick = (EquityTickDecompressed *)obj;
                    }else{
                        mainTick = nil;
                    }
                    float totalVol;
                    if (![obj isKindOfClass:[EquityTickDecompressed class]]) {
                        totalVol = -1;
                    }else{
                        totalVol = [(NSNumber *)[_tickPlotDataSource.volumeStoreInSameTime objectAtIndex:mainTick.time]floatValue];
                    }
                    NSNumber *mainVolumeNumber =[NSNumber numberWithFloat:totalVol];
                    
                    //_tickPlotDataSource.allVolumes[mainSequenceNum-1];
                    [self updateInfoPanel:mainTick mainVolumNumber:mainVolumeNumber comparedEquityTickDecompressed:comparedTick comparedVolumeNumber:comparedVolumeNumber];
                }
            }

#endif
            
            
        }
    }
    
    
    return YES;
}

-(EquityTickDecompressed*)findNearTickByLocation:(NSInteger)x{
    EquityTickDecompressed * tick;
    EquityTickDecompressed * HighTick;
    EquityTickDecompressed * LowTick;
    
    if ([_tickPlotDataSource.tickStoreInSameTime count] > 0) {
        return tick;
    }
    
    
    for (NSUInteger i =x; i<[_tickPlotDataSource.tickStoreInSameTime count]; i++) {
        id obj = [_tickPlotDataSource.tickStoreInSameTime objectAtIndex:i];
        if ([obj isKindOfClass:[EquityTickDecompressed class]]) {
            HighTick = (EquityTickDecompressed *)obj;
            break;
        }
    }
    
    for (NSInteger i =x; i>=0; i--) {
        id obj = nil;
        if (i<[_tickPlotDataSource.tickStoreInSameTime count]) {
            obj = [_tickPlotDataSource.tickStoreInSameTime objectAtIndex:i];
        }
        if ([obj isKindOfClass:[EquityTickDecompressed class]]) {
            LowTick = (EquityTickDecompressed *)obj;
            break;
        }
    }

    int highRange = (int)HighTick.time - (int)x;
    int lowRange = (int)x-LowTick.time;
    
    if (HighTick !=nil && LowTick !=nil) {
        int range = MIN(highRange, lowRange);
        if (range == lowRange) {
            tick = LowTick;
        }else{
            tick = HighTick;
        }
    }else if (HighTick ==nil){
        tick = LowTick;
    }else{
        tick = HighTick;
    }
    
    
    return tick;
}

- (FSTickData *)findNearTickByLocation2:(NSInteger)x {
    FSTickData * tick;
    FSTickData * HighTick;
    FSTickData * LowTick;
    for (NSUInteger i =x; i<[_tickPlotDataSource.tickStoreInSameTime count]; i++) {
        id obj = [_tickPlotDataSource.tickStoreInSameTime objectAtIndex:i];
        if ([obj isKindOfClass:[FSTickData class]]) {
            HighTick = (FSTickData *)obj;
            break;
        }
    }
    
    for (NSInteger i =x; i>=0; i--) {
        id obj = nil;
        if (i<[_tickPlotDataSource.tickStoreInSameTime count]) {
            obj = [_tickPlotDataSource.tickStoreInSameTime objectAtIndex:i];
        }
        if ([obj isKindOfClass:[FSTickData class]]) {
            LowTick = (FSTickData *)obj;
            break;
        }
    }
    
    int highRange = (int)[HighTick.time absoluteMinutesTime] - (int)x;
    int lowRange = (int)x - (int)[LowTick.time absoluteMinutesTime];
    
    if (HighTick !=nil && LowTick !=nil) {
        int range = MIN(highRange, lowRange);
        if (range == lowRange) {
            tick = LowTick;
        }else{
            tick = HighTick;
        }
    }else if (HighTick ==nil){
        tick = LowTick;
    }else{
        tick = HighTick;
    }
    
    
    return tick;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    //    [self hideCrossHair];
    //    [self hideCrossInfoPanel];
    return YES;
}

/**
 *  檢查資訊面板是否擋到十字線
 *
 *  @return YES就是有檔到，NO就是沒有檔到
 */
- (void)setIfNeedUpdateInfoPanelPosition:(CGPoint) point
{
    //    CGPoint pointInSelfView = [self.view convertPoint:point fromView:_priceHostView];
    switch (_crossHairInfoPanelPosition) {
            //目前panel在畫面左邊
        case Leftside:
            
            if (point.x < 190) {
                _crossHairInfoPanelPosition = RightSide;
                [self setCrossHairInfoPanel];
            }
            break;
            //目前panel在畫面右邊
        case RightSide:
            if (point.x > 190) {
                _crossHairInfoPanelPosition = Leftside;
                //[self.view setNeedsUpdateConstraints];
                [self setCrossHairInfoPanel];
            }
            break;
            
        default:
            _crossHairInfoPanelPosition = RightSide;
            //[self.view setNeedsUpdateConstraints];
            [self setCrossHairInfoPanel];
            break;
    }
}

#pragma mark - Price

- (void)scalePriceGraphToFitPrice:(EquitySnapshotDecompressed *) snapshot
{
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.priceHostView.hostedGraph.defaultPlotSpace;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;
    //有參考價，可以設定y軸的上下RANGE
    if (snapshot.referencePrice > 0 && snapshot.highestPrice > 0 && snapshot.lowestPrice > 0) {
        
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
        
        PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        
        if (portfolioItem->identCode[0] == 'T' && portfolioItem->identCode[1] == 'W' && _buttonContainerScrollView.fitPriceGraphScopeButton.selected == NO && ![snapshot isKindOfClass:[IndexSnapshotDecompressed class]] && (snapshot.ceilingPrice !=0 && snapshot.ceilingPrice !=0)) {
            maxY = snapshot.ceilingPrice;// + snapshot.referencePrice *0.07;
            minY = snapshot.floorPrice;// - snapshot.referencePrice *0.07;
        }else{
            if (increasePercentage >= decreasePercentage && increasePercentage > 0.01) {
                minY = snapshot.referencePrice*(1-increasePercentage-0.002);
                maxY = snapshot.highestPrice;
            }
            else if (increasePercentage < decreasePercentage && decreasePercentage > 0.01) {
                minY = snapshot.lowestPrice-(snapshot.referencePrice*decreasePercentage/10);
                maxY = snapshot.referencePrice*(1+decreasePercentage);
            }
            else {
                minY = snapshot.referencePrice*0.989;
                maxY = snapshot.referencePrice*1.01;
            }
        }

        
        
        /*
         設定價圖表的上下區間
         CorePlot會把新設定的yRange限制在globalRange內，所以先把globalYRange設為nil，避免此限制，要特別注意
         */
        xyPlotSpace.globalYRange = nil;
        xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minY) length:CPTDecimalFromFloat(maxY - minY)];
        CPTMutablePlotRange *yRange = [xyPlotSpace.yRange mutableCopy];
        if (portfolioItem->identCode[0] == 'T' && portfolioItem->identCode[1] == 'W' && _buttonContainerScrollView.fitPriceGraphScopeButton.selected == NO && ![snapshot isKindOfClass:[IndexSnapshotDecompressed class]]) {
            [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
        }else{
            [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
        }
        
        xyPlotSpace.yRange = yRange;
        
        //把globalYRange設為yRange可以防止scroll
        xyPlotSpace.globalYRange = yRange;
    }
    else if (snapshot.referencePrice > 0) {
        /*
         設定價圖表的上下區間
         CorePlot會把新設定的yRange限制在globalRange內，所以先把globalYRange設為nil，避免此限制，要特別注意
         */
        xyPlotSpace.globalYRange = nil;
        double minY = 0;
        double maxY = 0;
        minY = snapshot.referencePrice*0.99;
        maxY = snapshot.referencePrice*1.01;
        xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minY) length:CPTDecimalFromFloat(maxY - minY)];
        CPTMutablePlotRange *yRange = [xyPlotSpace.yRange mutableCopy];
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
        xyPlotSpace.yRange = yRange;
        
        //把globalYRange設為yRange可以防止scroll
        xyPlotSpace.globalYRange = yRange;
    }
}

- (void)scalePriceGraphToFitPrice2:(FSSnapshot *)snapshot
{
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.priceHostView.hostedGraph.defaultPlotSpace;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;

    //有參考價，可以設定y軸的上下RANGE
    if (snapshot.reference_price.calcValue > 0 && snapshot.high_price.calcValue > 0 && snapshot.low_price.calcValue > 0) {
        
        //算出最高最低價格與參考價相差的比率
        double increasePercentage = fabs((snapshot.high_price.calcValue - snapshot.reference_price.calcValue)/snapshot.reference_price.calcValue);
        double decreasePercentage = fabs((snapshot.low_price.calcValue - snapshot.reference_price.calcValue)/snapshot.reference_price.calcValue);
        
        CPTMutableTextStyle *normalStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        normalStyle.color = [CPTColor blueColor];
        
        /**
         *  區間預設先以上下各1%來看，如果漲幅或跌幅超過1%，就要scale到該大小。而相對應的另一方向，也要scale到相同大小。例如漲幅5%，那麼上下就各5%的空間。
         在價格圖裡要顯示五個價格標示：
         */
        double minY = 0;
        double maxY = 0;
        PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        
        if (portfolioItem->identCode[0] == 'T' && portfolioItem->identCode[1] == 'W' && _buttonContainerScrollView.fitPriceGraphScopeButton.selected == NO && ![snapshot isKindOfClass:[IndexSnapshotDecompressed class]] && (snapshot.top_price.calcValue !=0 && snapshot.bottom_price.calcValue !=0) && portfolioItem->type_id != 3 && portfolioItem->type_id != 6) {
            maxY = snapshot.top_price.calcValue;// + snapshot.referencePrice *0.07;
            minY = snapshot.bottom_price.calcValue;// - snapshot.referencePrice *0.07;
        }else{
            if (increasePercentage >= decreasePercentage && increasePercentage > 0.01) {
                minY = snapshot.reference_price.calcValue*(1-increasePercentage-0.002);
                maxY = snapshot.high_price.calcValue;
            }
            else if (increasePercentage < decreasePercentage && decreasePercentage > 0.01) {
                minY = snapshot.low_price.calcValue-(snapshot.reference_price.calcValue*decreasePercentage/10);
                maxY = snapshot.reference_price.calcValue*(1+decreasePercentage);
            }
            else {
                minY = snapshot.reference_price.calcValue*0.989;
                maxY = snapshot.reference_price.calcValue*1.01;
            }

            if (_twoStock) {
                if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
                    if (increasePercentage >= 0.1) {
                        minY = snapshot.reference_price.calcValue*(1-increasePercentage);
                        maxY = snapshot.high_price.calcValue;
                    }else{
                        minY = snapshot.reference_price.calcValue*0.9;
                        maxY = snapshot.reference_price.calcValue*1.1;
                    }
                }
            }
        }
        
        
        /*
         設定價圖表的上下區間
         CorePlot會把新設定的yRange限制在globalRange內，所以先把globalYRange設為nil，避免此限制，要特別注意
         */
        xyPlotSpace.globalYRange = nil;
        xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minY) length:CPTDecimalFromFloat(maxY - minY)];
        CPTMutablePlotRange *yRange = [xyPlotSpace.yRange mutableCopy];
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
        xyPlotSpace.yRange = yRange;
        
        //把globalYRange設為yRange可以防止scroll
        xyPlotSpace.globalYRange = yRange;
    }
    else if (snapshot.reference_price.calcValue > 0) {
        /*
         設定價圖表的上下區間
         CorePlot會把新設定的yRange限制在globalRange內，所以先把globalYRange設為nil，避免此限制，要特別注意
         */
        xyPlotSpace.globalYRange = nil;
        double minY = 0;
        double maxY = 0;
        minY = snapshot.reference_price.calcValue*0.99;
        maxY = snapshot.reference_price.calcValue*1.01;
        xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minY) length:CPTDecimalFromFloat(maxY - minY)];
        CPTMutablePlotRange *yRange = [xyPlotSpace.yRange mutableCopy];
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
        xyPlotSpace.yRange = yRange;
        
        //把globalYRange設為yRange可以防止scroll
        xyPlotSpace.globalYRange = yRange;
    }
}

- (void)scaleComparedPriceGraphToFitPrice:(EquitySnapshotDecompressed *) snapshot
{
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.comparedPriceHostView.hostedGraph.defaultPlotSpace;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.comparedPriceHostView.hostedGraph.axisSet;
    //有參考價，可以設定y軸的上下RANGE
    if (snapshot.referencePrice > 0 && snapshot.highestPrice > 0 && snapshot.lowestPrice > 0) {
        
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
        
        PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].comparedPortfolioItem;
        
        if (portfolioItem) {
            if (portfolioItem->identCode[0] == 'T' && portfolioItem->identCode[1] == 'W' && _buttonContainerScrollView.fitPriceGraphScopeButton.selected == NO && ![snapshot isKindOfClass:[IndexSnapshotDecompressed class]] && (snapshot.ceilingPrice !=0 && snapshot.ceilingPrice !=0)) {
                maxY = snapshot.ceilingPrice;// + snapshot.referencePrice *0.07;
                minY = snapshot.floorPrice;// - snapshot.referencePrice *0.07;
                
                
            }else{
                if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
                    if (increasePercentage >= 0.1) {
                        minY = snapshot.referencePrice*(1-increasePercentage);
                        maxY = snapshot.highestPrice;
                    }else{
                        minY = snapshot.referencePrice*0.9;
                        maxY = snapshot.referencePrice*1.1;
                    }
                }else{
                    if (increasePercentage >= decreasePercentage && increasePercentage > 0.01) {
                        minY = snapshot.referencePrice*(1-increasePercentage-0.002);
                        maxY = snapshot.highestPrice;
                    }
                    else if (increasePercentage < decreasePercentage && decreasePercentage > 0.01) {
                        minY = snapshot.lowestPrice-(snapshot.referencePrice*decreasePercentage/10);
                        maxY = snapshot.referencePrice*(1+decreasePercentage);
                    }
                    else {
                        minY = snapshot.referencePrice*0.989;
                        maxY = snapshot.referencePrice*1.01;
                    }
                }
                /*
                 設定價圖表的上下區間
                 CorePlot會把新設定的yRange限制在globalRange內，所以先把globalYRange設為nil，避免此限制，要特別注意
                 */
                xyPlotSpace.globalYRange = nil;
                xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minY) length:CPTDecimalFromFloat(maxY - minY)];
                CPTMutablePlotRange *yRange = [xyPlotSpace.yRange mutableCopy];
                [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
                xyPlotSpace.yRange = yRange;
                
                //把globalYRange設為yRange可以防止scroll
                xyPlotSpace.globalYRange = yRange;
            }

        }
        
    }
    else if (snapshot.referencePrice > 0) {
        /*
         設定價圖表的上下區間
         CorePlot會把新設定的yRange限制在globalRange內，所以先把globalYRange設為nil，避免此限制，要特別注意
         */
        xyPlotSpace.globalYRange = nil;
        double minY = 0;
        double maxY = 0;
        minY = snapshot.referencePrice*0.99;
        maxY = snapshot.referencePrice*1.01;
        xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minY) length:CPTDecimalFromFloat(maxY - minY)];
        CPTMutablePlotRange *yRange = [xyPlotSpace.yRange mutableCopy];
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
        xyPlotSpace.yRange = yRange;
        
        //把globalYRange設為yRange可以防止scroll
        xyPlotSpace.globalYRange = yRange;
    }
}

- (void)scaleComparedPriceGraphToFitPriceWithBValue:(FSSnapshot *) snapshot
{
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.comparedPriceHostView.hostedGraph.defaultPlotSpace;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.comparedPriceHostView.hostedGraph.axisSet;
    //有參考價，可以設定y軸的上下RANGE
    if (snapshot.reference_price.calcValue > 0 && snapshot.high_price.calcValue > 0 && snapshot.low_price.calcValue > 0) {
        
        //算出最高最低價格與參考價相差的比率
        double increasePercentage = fabs((snapshot.high_price.calcValue - snapshot.reference_price.calcValue)/snapshot.reference_price.calcValue);
        double decreasePercentage = fabs((snapshot.low_price.calcValue - snapshot.reference_price.calcValue)/snapshot.reference_price.calcValue);
        
        CPTMutableTextStyle *normalStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        normalStyle.color = [CPTColor blueColor];
        
        /**
         *  區間預設先以上下各1%來看，如果漲幅或跌幅超過1%，就要scale到該大小。而相對應的另一方向，也要scale到相同大小。例如漲幅5%，那麼上下就各5%的空間。
         在價格圖裡要顯示五個價格標示：
         */
        double minY = 0;
        double maxY = 0;
        
        PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        
        if (portfolioItem->identCode[0] == 'T' && portfolioItem->identCode[1] == 'W' && _buttonContainerScrollView.fitPriceGraphScopeButton.selected == NO &&
            ![snapshot isKindOfClass:[IndexSnapshotDecompressed class]] &&
            (snapshot.top_price.calcValue !=0 && snapshot.bottom_price.calcValue !=0) &&
            portfolioItem->type_id != 3 && portfolioItem->type_id != 6) {
            maxY = snapshot.top_price.calcValue;// + snapshot.referencePrice *0.07;
            minY = snapshot.bottom_price.calcValue;// - snapshot.referencePrice *0.07;
            
            
        }else{
            if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
                if (increasePercentage >= 0.1) {
                    minY = snapshot.reference_price.calcValue*(1-increasePercentage);
                    maxY = snapshot.high_price.calcValue;
                }else{
                    minY = snapshot.reference_price.calcValue*0.9;
                    maxY = snapshot.reference_price.calcValue*1.1;
                }
            }else{

                if (increasePercentage >= decreasePercentage && increasePercentage > 0.01) {
                    minY = snapshot.reference_price.calcValue*(1-increasePercentage-0.002);
                    maxY = snapshot.high_price.calcValue;
                }
                else if (increasePercentage < decreasePercentage && decreasePercentage > 0.01) {
                    minY = snapshot.low_price.calcValue-(snapshot.reference_price.calcValue*decreasePercentage/10);
                    maxY = snapshot.reference_price.calcValue*(1+decreasePercentage);
                }
                else {
                    minY = snapshot.reference_price.calcValue*0.989;
                    maxY = snapshot.reference_price.calcValue*1.01;
                }
            }
            
        }
        
        
        
        /*
         設定價圖表的上下區間
         CorePlot會把新設定的yRange限制在globalRange內，所以先把globalYRange設為nil，避免此限制，要特別注意
         */
        xyPlotSpace.globalYRange = nil;
        xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minY) length:CPTDecimalFromFloat(maxY - minY)];
        CPTMutablePlotRange *yRange = [xyPlotSpace.yRange mutableCopy];
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
        xyPlotSpace.yRange = yRange;
        
        //把globalYRange設為yRange可以防止scroll
        xyPlotSpace.globalYRange = yRange;
    }
    else if (snapshot.reference_price.calcValue > 0) {
        /*
         設定價圖表的上下區間
         CorePlot會把新設定的yRange限制在globalRange內，所以先把globalYRange設為nil，避免此限制，要特別注意
         */
        xyPlotSpace.globalYRange = nil;
        double minY = 0;
        double maxY = 0;
        minY = snapshot.reference_price.calcValue*0.99;
        maxY = snapshot.reference_price.calcValue*1.01;
        xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minY) length:CPTDecimalFromFloat(maxY - minY)];
        CPTMutablePlotRange *yRange = [xyPlotSpace.yRange mutableCopy];
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
        xyPlotSpace.yRange = yRange;
        
        //把globalYRange設為yRange可以防止scroll
        xyPlotSpace.globalYRange = yRange;
    }
}



- (void)showSnapshotPriceLabel:(EquitySnapshotDecompressed *) snapshot
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;
    if (snapshot.referencePrice > 0 && snapshot.highestPrice > 0 && snapshot.lowestPrice > 0) {
        /*
         Y軸標示各個價格
         */
        NSMutableSet *yLabels = [NSMutableSet setWithCapacity:5];
        NSMutableSet *yLocations = [NSMutableSet setWithCapacity:5];
        
        //算出最高最低價格與參考價相差的比率
        double increasePercentage = fabs((snapshot.highestPrice - snapshot.referencePrice)/snapshot.referencePrice);
        double decreasePercentage = fabs((snapshot.lowestPrice - snapshot.referencePrice)/snapshot.referencePrice);
        
        CPTMutableTextStyle *normalStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        normalStyle.color = [CPTColor blueColor];
        normalStyle.fontSize = SNAPSHOT_FONTSIZE;
        
        
        /**
         *  區間預設先以上下各1%來看，如果漲幅或跌幅超過1%，就要scale到該大小。而相對應的另一方向，也要scale到相同大小。例如漲幅5%，那麼上下就各5%的空間。
         在價格圖裡要顯示五個價格標示：
         */
        double minY = 0;
        double maxY = 0;
        double middleNumberOfMinAndReference = 0;
        double middleNumberOfMaxAndReference = 0;
        
        PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        
        if (portfolioItem->identCode[0] == 'T' && portfolioItem->identCode[1] == 'W' && _buttonContainerScrollView.fitPriceGraphScopeButton.selected == NO && ![snapshot isKindOfClass:[IndexSnapshotDecompressed class]] && (snapshot.ceilingPrice !=0 && snapshot.ceilingPrice !=0)) {
            maxY = snapshot.ceilingPrice;// + snapshot.referencePrice *0.07;
            minY = snapshot.floorPrice;// - snapshot.referencePrice *0.07;
            
//            _maxPrice = maxY;
//            _minPrice = minY;

        }else{
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
//            _maxPrice = maxY;
//            _minPrice = minY;
        }
        
        CPTMutableTextStyle *lowHighPriceStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        lowHighPriceStyle.color = [CPTColor blueColor];
        lowHighPriceStyle.fontSize = SNAPSHOT_FONTSIZE;
        
        CPTAxisLabel *lowerBoundLabel;
        if (minY == snapshot.floorPrice) {
            lowHighPriceStyle.color = [CPTColor whiteColor];
        }
        
        lowerBoundLabel = [self axisLabelWithPrice:minY textStyle:lowHighPriceStyle];
        lowerBoundLabel.offset = 1;
        lowerBoundLabel.alignment = CPTAlignmentBottom;
        if (minY == snapshot.floorPrice) {
            lowerBoundLabel.contentLayer.backgroundColor = [[StockConstant priceDownGradientTopColor] cgColor];
        }
        
        CPTAxisLabel *upperBoundLabel;
        if (maxY == snapshot.ceilingPrice) {
            lowHighPriceStyle.color = [CPTColor whiteColor];
        }
        upperBoundLabel = [self axisLabelWithPrice:maxY textStyle:lowHighPriceStyle];
        upperBoundLabel.offset = 1;
        upperBoundLabel.alignment = CPTAlignmentTop;
        if (maxY == snapshot.ceilingPrice) {
            upperBoundLabel.contentLayer.backgroundColor = [[StockConstant priceUpGradientBottomColor] cgColor];
        }
        
        
        //標示區間內最小數字
        if (lowerBoundLabel != nil) {
            [yLabels addObject:lowerBoundLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:lowerBoundLabel.tickLocation]];
        }
        
        //標示區間內最大數字
        if (upperBoundLabel != nil) {
            [yLabels addObject:upperBoundLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:upperBoundLabel.tickLocation]];
        }
        
        middleNumberOfMinAndReference = (snapshot.referencePrice+minY)/2;
        middleNumberOfMaxAndReference = (snapshot.referencePrice+maxY)/2;
        CPTAxisLabel *middleNumberOfMinAndReferenceLabel = [self axisLabelWithPrice:middleNumberOfMinAndReference textStyle:normalStyle];
        middleNumberOfMinAndReferenceLabel.offset = 1;
        CPTAxisLabel *middleNumberOfMaxAndReferenceLabel = [self axisLabelWithPrice:middleNumberOfMaxAndReference textStyle:normalStyle];
        middleNumberOfMaxAndReferenceLabel.offset = 1;
        //標示最低價與參考價中間的數字
        if (middleNumberOfMinAndReferenceLabel != nil) {
            [yLabels addObject:middleNumberOfMinAndReferenceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:middleNumberOfMinAndReferenceLabel.tickLocation]];
        }
        
        //標示最高價與參考價中間的數字
        if (middleNumberOfMaxAndReferenceLabel != nil) {
            [yLabels addObject:middleNumberOfMaxAndReferenceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:middleNumberOfMaxAndReferenceLabel.tickLocation]];
        }
        
        //標示參考價
        CPTMutableTextStyle *referencePriceStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        referencePriceStyle.color = [CPTColor brownColor];
        referencePriceStyle.fontSize = SNAPSHOT_FONTSIZE;
        
        //參考價
        CPTAxisLabel *referencePriceLabel = [self axisLabelWithPrice:snapshot.referencePrice textStyle:referencePriceStyle];
        referencePriceLabel.offset = 1;
        if (referencePriceLabel) {
            [yLabels addObject:referencePriceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:referencePriceLabel.tickLocation]];
        }
        
        axisSet.yAxis.axisLabels = yLabels;
        axisSet.yAxis.majorTickLength = 0;
        axisSet.yAxis.majorTickLocations = yLocations;
    }
    else if (snapshot.referencePrice > 0) {
        NSMutableSet *yLabels = [NSMutableSet setWithCapacity:1];
        NSMutableSet *yLocations = [NSMutableSet setWithCapacity:1];
        
        //標示參考價
        CPTMutableTextStyle *referencePriceStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        referencePriceStyle.color = [CPTColor brownColor];
        referencePriceStyle.fontSize = SNAPSHOT_FONTSIZE;
        
        //參考價
        CPTAxisLabel *referencePriceLabel = [self axisLabelWithPrice:snapshot.referencePrice textStyle:referencePriceStyle];
        
        if (referencePriceLabel) {
            [yLabels addObject:referencePriceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:referencePriceLabel.tickLocation]];
        }

        
        axisSet.yAxis.axisLabels = yLabels;
        axisSet.yAxis.majorTickLength = 0;
        axisSet.yAxis.majorTickLocations = yLocations;
    }
}

- (void)showSnapshotPriceLabel2:(FSSnapshot *) snapshot
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;

    if (snapshot.reference_price.calcValue > 0 && snapshot.high_price.calcValue > 0 && snapshot.low_price.calcValue > 0) {
        /*
         Y軸標示各個價格
         */
        NSMutableSet *yLabels = [NSMutableSet setWithCapacity:5];
        NSMutableSet *yLocations = [NSMutableSet setWithCapacity:5];
        
        //算出最高最低價格與參考價相差的比率
        double increasePercentage = fabs((snapshot.high_price.calcValue - snapshot.reference_price.calcValue)/snapshot.reference_price.calcValue);
        double decreasePercentage = fabs((snapshot.low_price.calcValue - snapshot.reference_price.calcValue)/snapshot.reference_price.calcValue);
        
        CPTMutableTextStyle *normalStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        normalStyle.color = [CPTColor blueColor];
        normalStyle.fontSize = SNAPSHOT_FONTSIZE;
        
        /**
         *  區間預設先以上下各1%來看，如果漲幅或跌幅超過1%，就要scale到該大小。而相對應的另一方向，也要scale到相同大小。例如漲幅5%，那麼上下就各5%的空間。
         在價格圖裡要顯示五個價格標示：
         */
        double minY = 0;
        double maxY = 0;
        double middleNumberOfMinAndReference = 0;
        double middleNumberOfMaxAndReference = 0;
        
        PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        
        if (portfolioItem->identCode[0] == 'T' && portfolioItem->identCode[1] == 'W' && _buttonContainerScrollView.fitPriceGraphScopeButton.selected == NO && ![snapshot isKindOfClass:[IndexSnapshotDecompressed class]] && (snapshot.top_price.calcValue !=0 && snapshot.bottom_price.calcValue !=0) && portfolioItem->type_id != 3 && portfolioItem->type_id != 6) {
            maxY = snapshot.top_price.calcValue;// + snapshot.referencePrice *0.07;
            minY = snapshot.bottom_price.calcValue;// - snapshot.referencePrice *0.07;
        }else{
            if (increasePercentage >= decreasePercentage && increasePercentage > 0.01) {
                minY = snapshot.reference_price.calcValue*(1-increasePercentage);
                maxY = snapshot.high_price.calcValue;
            }
            else if (increasePercentage < decreasePercentage && decreasePercentage > 0.01) {
                minY = snapshot.low_price.calcValue;
                maxY = snapshot.reference_price.calcValue*(1+decreasePercentage);
            }
            else {
                minY = snapshot.reference_price.calcValue*0.99;
                maxY = snapshot.reference_price.calcValue*1.01;
            }
            
            if (_twoStock) {
                if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
                    if (increasePercentage >= 0.1) {
                        minY = snapshot.reference_price.calcValue*(1-increasePercentage);
                        maxY = snapshot.high_price.calcValue;
                    }else{
                        minY = snapshot.reference_price.calcValue*0.9;
                        maxY = snapshot.reference_price.calcValue*1.1;
                    }
                }
            }
        }
        
        _maxPrice = maxY;
        _minPrice = minY;
        
//        CPTAxisLabel *lowerBoundLabel = [self axisLabelWithPrice:minY textStyle:normalStyle];
//        lowerBoundLabel.offset = 1;
//        lowerBoundLabel.alignment = CPTAlignmentBottom;
//        CPTAxisLabel *upperBoundLabel = [self axisLabelWithPrice:maxY textStyle:normalStyle];
//        upperBoundLabel.offset = 1;
//        upperBoundLabel.alignment = CPTAlignmentTop;
        CPTMutableTextStyle *lowHighPriceStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        lowHighPriceStyle.color = [CPTColor blueColor];
        lowHighPriceStyle.fontSize = SNAPSHOT_FONTSIZE;

        
        CPTAxisLabel *lowerBoundLabel;
        if (minY == snapshot.bottom_price.calcValue) {
            lowHighPriceStyle.color = [CPTColor whiteColor];
        }
        
        lowerBoundLabel = [self axisLabelWithPrice:minY textStyle:lowHighPriceStyle];
        lowerBoundLabel.offset = 1;
        lowerBoundLabel.alignment = CPTAlignmentBottom;
        if (minY == snapshot.bottom_price.calcValue) {
            lowerBoundLabel.contentLayer.backgroundColor = [[StockConstant priceDownGradientTopColor] cgColor];
        }
        
        CPTAxisLabel *upperBoundLabel;
        if (maxY == snapshot.top_price.calcValue) {
            lowHighPriceStyle.color = [CPTColor whiteColor];
        }
        upperBoundLabel = [self axisLabelWithPrice:maxY textStyle:lowHighPriceStyle];
        upperBoundLabel.offset = 1;
        upperBoundLabel.alignment = CPTAlignmentTop;
        if (maxY == snapshot.top_price.calcValue) {
            upperBoundLabel.contentLayer.backgroundColor = [[StockConstant priceUpGradientBottomColor] cgColor];
        }
        
        //標示區間內最小數字
        if (lowerBoundLabel != nil) {
            [yLabels addObject:lowerBoundLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:lowerBoundLabel.tickLocation]];
        }
        
        //標示區間內最大數字
        if (upperBoundLabel != nil) {
            [yLabels addObject:upperBoundLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:upperBoundLabel.tickLocation]];
        }
        
        middleNumberOfMinAndReference = (snapshot.reference_price.calcValue+minY)/2;
        middleNumberOfMaxAndReference = (snapshot.reference_price.calcValue+maxY)/2;
        
        CPTAxisLabel *middleNumberOfMinAndReferenceLabel = [self axisLabelWithPrice:middleNumberOfMinAndReference textStyle:normalStyle];
        middleNumberOfMinAndReferenceLabel.offset = 1;
        CPTAxisLabel *middleNumberOfMaxAndReferenceLabel = [self axisLabelWithPrice:middleNumberOfMaxAndReference textStyle:normalStyle];
        middleNumberOfMaxAndReferenceLabel.offset = 1;
        //標示最低價與參考價中間的數字
        if (middleNumberOfMinAndReferenceLabel != nil) {
            [yLabels addObject:middleNumberOfMinAndReferenceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:middleNumberOfMinAndReferenceLabel.tickLocation]];
        }
        
        //標示最高價與參考價中間的數字
        if (middleNumberOfMaxAndReferenceLabel != nil) {
            [yLabels addObject:middleNumberOfMaxAndReferenceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:middleNumberOfMaxAndReferenceLabel.tickLocation]];
        }
        
        //標示參考價
        CPTMutableTextStyle *referencePriceStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        referencePriceStyle.color = [CPTColor brownColor];
        referencePriceStyle.fontSize = SNAPSHOT_FONTSIZE;

        //參考價
        CPTAxisLabel *referencePriceLabel = [self axisLabelWithPrice:snapshot.reference_price.calcValue textStyle:referencePriceStyle];
        referencePriceLabel.offset = 1;
        if (referencePriceLabel) {
            [yLabels addObject:referencePriceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:referencePriceLabel.tickLocation]];
        }
        
        axisSet.yAxis.axisLabels = yLabels;
        axisSet.yAxis.majorTickLength = 0;
        axisSet.yAxis.majorTickLocations = yLocations;
    }
    else if (snapshot.reference_price.calcValue > 0) {
        NSMutableSet *yLabels = [NSMutableSet setWithCapacity:1];
        NSMutableSet *yLocations = [NSMutableSet setWithCapacity:1];
        
        //標示參考價
        CPTMutableTextStyle *referencePriceStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        referencePriceStyle.color = [CPTColor brownColor];
        referencePriceStyle.fontSize = SNAPSHOT_FONTSIZE;

        //參考價
        CPTAxisLabel *referencePriceLabel = [self axisLabelWithPrice:snapshot.reference_price.calcValue textStyle:referencePriceStyle];
        
        if (referencePriceLabel) {
            [yLabels addObject:referencePriceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:referencePriceLabel.tickLocation]];
        }
        
        
        axisSet.yAxis.axisLabels = yLabels;
        axisSet.yAxis.majorTickLength = 0;
        axisSet.yAxis.majorTickLocations = yLocations;
    }
}

- (void)clearSnapshotPriceLabel
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;
    axisSet.yAxis.axisLabels = nil;
//    axisSet.yAxis.majorTickLocations = nil;
}

- (void)drawXAxisGridLineOnPriceGraph
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;
    
    CPTAxis *xAxis = axisSet.xAxis;
    /*
     從開盤時間開始，只要是整數小時而且不是休息時間，就秀在X軸上
     */
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:5];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:5];
    
    for (NSUInteger tickTimeCounter=_tickPlotDataSource.chartOpenTime; tickTimeCounter < _tickPlotDataSource.chartCloseTime; tickTimeCounter++) {
        //略過休息時間
        if (_tickPlotDataSource.chartBreakTime !=0 && (_tickPlotDataSource.chartBreakTime<tickTimeCounter) && (tickTimeCounter<_tickPlotDataSource.chartReopenTime)) {
            continue;
        }
        //每隔半小時畫分隔線
        if (tickTimeCounter%30==0) {
            CGFloat location;
            if(tickTimeCounter>_tickPlotDataSource.chartBreakTime && _tickPlotDataSource.chartBreakTime !=0){
                location = tickTimeCounter-(_tickPlotDataSource.chartReopenTime-_tickPlotDataSource.chartBreakTime)-_tickPlotDataSource.chartOpenTime;
            }else{
                location = tickTimeCounter-_tickPlotDataSource.chartOpenTime;
                
            }
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
        if (tickTimeCounter%60==0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d", (int)tickTimeCounter/60]  textStyle:xAxis.labelTextStyle];
            label.alignment = CPTAlignmentLeft;
            CGFloat location;
            if(tickTimeCounter>_tickPlotDataSource.chartBreakTime && _tickPlotDataSource.chartBreakTime !=0){
                location = tickTimeCounter-(_tickPlotDataSource.chartReopenTime-_tickPlotDataSource.chartBreakTime)-_tickPlotDataSource.chartOpenTime;//-5;
            }else{
                location = tickTimeCounter-_tickPlotDataSource.chartOpenTime;//-5;
            }
            label.tickLocation = CPTDecimalFromCGFloat(location);
            label.offset =-4.0f; //xAxis.majorTickLength;
            
            if (label) {
                [xLabels addObject:label];
//                [xLocations addObject:[NSNumber numberWithFloat:location]];
            }
        }
    }
    xAxis.axisLabels = xLabels;
    xAxis.majorTickLocations = xLocations;
}


-(void)FitPriceGraphScope{
    [dataLock lock];
#ifdef LPCB
    FSSnapshot *snapshot = ((EquityTick *) _tickPlotDataSource.dataSource).snapshot_b;
    [self configureYRangeBValue:snapshot];
#else
    EquitySnapshotDecompressed *snapshot = ((EquityTick *) _tickPlotDataSource.dataSource).snapshot;
    [self configureYRange:snapshot];
#endif
    [self reloadPriceGraph];
    [dataLock unlock];
}

#pragma mark - Volume

-(void)scaleVolumeAndShow{
    [self scaleVolumeGraphToFitVolume];
    [self scaleComparedVolumeGraphToFitComparedVolume];
//    if (_isCDPVisible) {
//        [self showCDPPriceLabel];
//    }
    if (_twoStock) {
        if (_comparedValue) {
            [self showComparedVolumeLabel];
            [self clearVolumeLabel];
            [_comparedVolumeHostView.hostedGraph plotWithIdentifier:@"Compared Volume Plot"].hidden = NO;
            [_volumeHostView.hostedGraph plotWithIdentifier:@"Volume Plot"].hidden = YES;
            
        }else{
            [self showVolumeLabel];
            [self clearComparedVolumeLabel];
            [_comparedVolumeHostView.hostedGraph plotWithIdentifier:@"Compared Volume Plot"].hidden = YES;
            [_volumeHostView.hostedGraph plotWithIdentifier:@"Volume Plot"].hidden = NO;
        }
    }else{
        [self showVolumeLabel];
        [self clearComparedVolumeLabel];
        [_comparedVolumeHostView.hostedGraph plotWithIdentifier:@"Compared Volume Plot"].hidden = YES;
        [_volumeHostView.hostedGraph plotWithIdentifier:@"Volume Plot"].hidden = NO;
    }
    
}

- (void)scaleVolumeGraphToFitVolume
{
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.volumeHostView.hostedGraph.defaultPlotSpace;
    
    if (_tickPlotDataSource.maxMainVolume != 0.0) {
        xyPlotSpace.globalYRange = nil;
        float maxVolume = _tickPlotDataSource.maxMainVolume;
        if (maxVolume > 3) {
            maxVolume = _tickPlotDataSource.maxMainVolume;
        }else{
            maxVolume = 4;
        }
        xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(maxVolume)];
        CPTMutablePlotRange *yRange = [xyPlotSpace.yRange mutableCopy];
//        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
//        xyPlotSpace.yRange = yRange;
        
        //把globalYRange設為yRange可以防止scroll
        xyPlotSpace.globalYRange = yRange;
    }
}

- (void)showVolumeLabel
{
    /*
     這一段在畫量圖表旁邊的數字
     */
    CPTXYAxisSet *volumeAxisSet = (CPTXYAxisSet *) self.volumeHostView.hostedGraph.axisSet;
    if(_tickPlotDataSource.maxMainVolume != 0)
    {
        /*
         X軸分隔虛線樣式
         */
        CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
        gridLineStyle.lineColor = [CPTColor grayColor];
        gridLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:2], [NSNumber numberWithInteger:1], nil];
        gridLineStyle.lineWidth = 0.3f;
        volumeAxisSet.xAxis.majorGridLineStyle = gridLineStyle;//畫格線
        volumeAxisSet.yAxis.majorGridLineStyle = gridLineStyle;//畫格線
        
        NSMutableSet *volumeLabels = [NSMutableSet setWithCapacity:5];
        NSMutableSet *volumeLocations = [NSMutableSet setWithCapacity:5];
        double value = _tickPlotDataSource.maxMainVolume;
        
        //調整字的顏色
        CPTMutableTextStyle *newStyle = [volumeAxisSet.yAxis.labelTextStyle mutableCopy];
        newStyle.color = [CPTColor colorWithComponentRed:0 green:0 blue:1 alpha:1];
        newStyle.fontSize = 16.0f;
        volumeAxisSet.yAxis.labelTextStyle = newStyle;
        if (value > 3) {
            for (double volumeCounter=value/4; volumeCounter < value; volumeCounter+=value/4) {
                //調整背景顏色
                CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[CodingUtil volumeRoundRownWithDouble:volumeCounter]  textStyle:volumeAxisSet.yAxis.labelTextStyle];

                //決定位置
                CGFloat location = volumeCounter;
                label.tickLocation = CPTDecimalFromCGFloat(location);
                label.offset = 1;//volumeAxisSet.yAxis.majorTickLength;
                if (label) {
                    [volumeLabels addObject:label];
                    [volumeLocations addObject:[NSNumber numberWithFloat:location]];
                }
            }
        }else{
            for (double i = 1; i < 4; i ++){
                //調整背景顏色
                CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[CodingUtil volumeRoundRownWithDouble:i]  textStyle:volumeAxisSet.yAxis.labelTextStyle];
                //決定位置
                CGFloat location = i;
                label.tickLocation = CPTDecimalFromCGFloat(location);
                label.offset = 1;//volumeAxisSet.yAxis.majorTickLength;
                if (label) {
                    [volumeLabels addObject:label];
                    [volumeLocations addObject:[NSNumber numberWithDouble:location]];
                }
            }
        }
        volumeAxisSet.yAxis.axisLabels = volumeLabels;
        volumeAxisSet.yAxis.majorTickLength = 0;
        volumeAxisSet.yAxis.majorTickLocations = volumeLocations;
    }
    else {
        volumeAxisSet.yAxis.axisLabels = nil;
        volumeAxisSet.yAxis.majorTickLocations = nil;
    }
}


- (void)clearVolumeLabel
{
    CPTXYAxisSet *volumeAxisSet = (CPTXYAxisSet *) self.volumeHostView.hostedGraph.axisSet;
    volumeAxisSet.yAxis.axisLabels = nil;
    volumeAxisSet.yAxis.majorTickLocations = nil;
}

- (void)drawXAxisGridLineOnVolumeGraph
{
    /*
     從開盤時間開始，只要是整數小時而且不是休息時間，就秀在X軸上
     */
    CPTXYAxisSet *volumeAxisSet = (CPTXYAxisSet *) self.volumeHostView.hostedGraph.axisSet;
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:5];
    
    for (NSUInteger tickTimeCounter=_tickPlotDataSource.chartOpenTime; tickTimeCounter < _tickPlotDataSource.chartCloseTime; tickTimeCounter++) {
        //略過休息時間
        if (_tickPlotDataSource.chartBreakTime !=0 && (_tickPlotDataSource.chartBreakTime<tickTimeCounter) && (tickTimeCounter<_tickPlotDataSource.chartReopenTime)) {
            continue;
        }
        //每隔半小時畫分隔線
        if (tickTimeCounter%30==0) {
            if(tickTimeCounter>_tickPlotDataSource.chartBreakTime && _tickPlotDataSource.chartBreakTime !=0){
                CGFloat location = tickTimeCounter-(_tickPlotDataSource.chartReopenTime-_tickPlotDataSource.chartBreakTime)-_tickPlotDataSource.chartOpenTime;
                [xLocations addObject:[NSNumber numberWithFloat:location]];
            }else{
                CGFloat location = tickTimeCounter-_tickPlotDataSource.chartOpenTime;
                [xLocations addObject:[NSNumber numberWithFloat:location]];
            }
            
        }
    }
    volumeAxisSet.xAxis.majorTickLocations = xLocations;
    volumeAxisSet.xAxis.majorTickLength = 0.0f;
}

-(void)showVolumePlot{
    
    if (_comparedValue) {
        [_comparedVolumeHostView.hostedGraph plotWithIdentifier:@"Compared Volume Plot"].hidden = NO;
    }else{
        [_volumeHostView.hostedGraph plotWithIdentifier:@"Volume Plot"].hidden = NO;
    }
}

-(void)hideVolumePlot{
    if (_comparedValue) {
        [_comparedVolumeHostView.hostedGraph plotWithIdentifier:@"Compared Volume Plot"].hidden = YES;
    }else{
        [_volumeHostView.hostedGraph plotWithIdentifier:@"Volume Plot"].hidden = YES;
    }
}

#pragma mark  - Compared Portfolio

- (void)addComparedPortfolioPlot
{
    //比較走勢的線
    if ([_comparedPriceHostView.hostedGraph plotWithIdentifier:@"CPDComparedTickerSymbolPortfolio"] == nil) {
        CPTScatterPlot *comparedPortfolioPlot = [[CPTScatterPlot alloc] init];
        comparedPortfolioPlot.identifier = @"CPDComparedTickerSymbolPortfolio";
        comparedPortfolioPlot.dataSource = self.tickPlotDataSource;
        
        CPTMutableLineStyle *comparedPortfolioLineStyle = [comparedPortfolioPlot.dataLineStyle mutableCopy];
        comparedPortfolioLineStyle.lineWidth = 0.7f;
        comparedPortfolioLineStyle.lineColor = [CPTColor colorWithComponentRed:224.0f/255.0f green:100.0f/255.0f blue:16.0f/255.0f alpha:1.000];
        comparedPortfolioPlot.dataLineStyle = comparedPortfolioLineStyle;
        
        [_comparedPriceHostView.hostedGraph addPlot:comparedPortfolioPlot];
        
        //比較走勢第一個tick前的線
        CPTScatterPlot *lineBeforeTickPlot = [[CPTScatterPlot alloc] init];
        lineBeforeTickPlot.identifier = @"ComparedSymbolLineBeforeFirstTick";
        CPTColor *lineBeforeTickColor = [CPTColor colorWithComponentRed:224.0f/255.0f green:100.0f/255.0f blue:16.0f/255.0f alpha:1.000];
        lineBeforeTickPlot.dataSource = self.tickPlotDataSource;
        [_comparedPriceHostView.hostedGraph addPlot:lineBeforeTickPlot];
        
        CPTMutableLineStyle *lineBeforeTickLineStyle = [lineBeforeTickPlot.dataLineStyle mutableCopy];
        lineBeforeTickLineStyle.lineWidth = 1;
        lineBeforeTickLineStyle.lineColor = lineBeforeTickColor;
        lineBeforeTickPlot.dataLineStyle = lineBeforeTickLineStyle;
        
    }
    
    //比較走勢的量
    if ([_comparedVolumeHostView.hostedGraph plotWithIdentifier:@"Compared Volume Plot"] == nil) {
        
        //雙走勢量圖
        CPTGraph *comparedVolumeGraph = self.comparedVolumeHostView.hostedGraph;
        CPTXYPlotSpace *comparedVolumePlotSpace = (CPTXYPlotSpace *) comparedVolumeGraph.defaultPlotSpace;
        comparedVolumePlotSpace.identifier = @"Compared Volume Plot Space";
        
        CPTBarPlot *comparedVolumePlot = [[CPTBarPlot alloc] init];
        comparedVolumePlot.dataSource = self.tickPlotDataSource;
        comparedVolumePlot.identifier = @"Compared Volume Plot";
        
        CPTMutableLineStyle *comparedVolumePlotLineStyle = [comparedVolumePlot.lineStyle mutableCopy];
        comparedVolumePlotLineStyle.lineColor  = [CPTColor clearColor];
        comparedVolumePlot.lineStyle = comparedVolumePlotLineStyle;
        
        comparedVolumePlot.fill = [[CPTFill alloc] initWithColor:[CPTColor colorWithComponentRed:224.0f/255.0f green:100.0f/255.0f blue:16.0f/255.0f alpha:1.000]];
        comparedVolumePlot.barWidth = CPTDecimalFromFloat(2.0f);
        comparedVolumePlot.barOffset = CPTDecimalFromFloat(1.0f);//設成width的一半才可以讓柱子的中心點在數據上
        
        //    volumePlot.cachePrecision = CPTPlotCachePrecisionDouble;
        [comparedVolumeGraph addPlot:comparedVolumePlot toPlotSpace:comparedVolumePlotSpace];
        

//        CPTScatterPlot *comparedVolumePlot = [[CPTScatterPlot alloc] init];
//        comparedVolumePlot.identifier = @"Compared Volume Plot";
//        comparedVolumePlot.dataSource = self.tickPlotDataSource;
//        
//        CPTMutableLineStyle *comparedPortfolioLineStyle = [comparedVolumePlot.dataLineStyle mutableCopy];
//        comparedPortfolioLineStyle.lineWidth = 1;
//        comparedPortfolioLineStyle.lineColor = [CPTColor colorWithComponentRed:224.0f/255.0f green:100.0f/255.0f blue:16.0f/255.0f alpha:1.000];
//        comparedVolumePlot.dataLineStyle = comparedPortfolioLineStyle;
//        
//        [_comparedVolumeHostView.hostedGraph addPlot:comparedVolumePlot];
        if (!_twoStock){
            [self hideComparedPortfolioPlot];
        }else{
            [self showComparedPortfolioPlot];
        }
        
    }
    [self showPriceLabel];
    [self hideCrossHair];
    [self hideCrossInfoPanel];
}

- (void)showPriceLabel{
    if (!_isCDPVisible) {
        if (_comparedValue && _twoStock) {
            [self clearVolumeLabel];
            [self showComparedVolumeLabel];
            [self clearSnapshotPriceLabel];
#ifdef LPCB
            [self showComparedPriceLabelWithBValue:((EquityTick *)_tickPlotDataSource.comparedDataSource).snapshot_b];
#else
            [self showComparedPriceLabel:((EquityTick *)_tickPlotDataSource.comparedDataSource).snapshot];
#endif
            [_comparedVolumeHostView.hostedGraph plotWithIdentifier:@"Compared Volume Plot"].hidden = NO;
            [_volumeHostView.hostedGraph plotWithIdentifier:@"Volume Plot"].hidden = YES;
        }else{
            [self clearComparedVolumeLabel];
            [self showVolumeLabel];
            [self clearComparedPriceLabel];
#ifdef LPCB
            [self showSnapshotPriceLabel2:((EquityTick *)_tickPlotDataSource.dataSource).snapshot_b];
#else
            [self showSnapshotPriceLabel:((EquityTick *)_tickPlotDataSource.dataSource).snapshot];
#endif
        }
    }
}

- (void)showComparedPortfolioPlot
{
    _twoStock = YES;
    [_comparedPriceHostView.hostedGraph plotWithIdentifier:@"CPDComparedTickerSymbolPortfolio"].hidden = NO;
    [_comparedPriceHostView.hostedGraph plotWithIdentifier:@"ComparedSymbolLineBeforeFirstTick"].hidden = NO;
    _crossInfoPanel.comparedMode = _buttonContainerScrollView.compareOtherPortfoioButton.selected;

    [_crossInfoPanel setLayout];
}

- (void)hideComparedPortfolioPlot
{
    _twoStock = NO;
    [_comparedPriceHostView.hostedGraph plotWithIdentifier:@"CPDComparedTickerSymbolPortfolio"].hidden = YES;
    [_comparedPriceHostView.hostedGraph plotWithIdentifier:@"ComparedSymbolLineBeforeFirstTick"].hidden = YES;
    [_comparedVolumeHostView.hostedGraph plotWithIdentifier:@"Compared Volume Plot"].hidden = YES;
    [_volumeHostView.hostedGraph plotWithIdentifier:@"Volume Plot"].hidden = NO;
    _crossInfoPanel.comparedMode = _buttonContainerScrollView.compareOtherPortfoioButton.selected;
    [_crossInfoPanel setLayout];
}

- (BOOL)isComparedPortfolioPlotVisible
{
    return ![_comparedPriceHostView.hostedGraph plotWithIdentifier:@"CPDComparedTickerSymbolPortfolio"].hidden;
}


/**
 *  更新比較走勢的按鈕文字
 */
- (void)resetSelectComparePortfoioButtonTitle
{
    if (_tickPlotDataSource.comparedPortfolioItem==nil){
//        [_buttonContainerScrollView.selectComparePortfoioButton setTitle:@"" forState:UIControlStateNormal];
        _buttonContainerScrollView.selectComparePortfoioLabel.text = @"";
    }else{
//        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS)
//        {
//            [_buttonContainerScrollView.selectComparePortfoioButton setTitle:_tickPlotDataSource.comparedPortfolioItem->symbol forState:UIControlStateNormal];
//            _buttonContainerScrollView.selectComparePortfoioLabel.text = _tickPlotDataSource.comparedPortfolioItem->symbol;
//        }else{
//            [_buttonContainerScrollView.selectComparePortfoioButton setTitle:_tickPlotDataSource.comparedPortfolioItem->fullName forState:UIControlStateNormal];
            _buttonContainerScrollView.selectComparePortfoioLabel.text = _tickPlotDataSource.comparedPortfolioItem->fullName;
//        }
    }
}

- (void)scaleComparedVolumeGraphToFitComparedVolume
{
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.comparedVolumeHostView.hostedGraph.defaultPlotSpace;
    if (_tickPlotDataSource.maxComparedVolume != 0.0) {
        xyPlotSpace.globalYRange = nil;
        xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(_tickPlotDataSource.maxComparedVolume)];
//        CPTMutablePlotRange *yRange = [xyPlotSpace.yRange mutableCopy];
    
        //把globalYRange設為yRange可以防止scroll
//        xyPlotSpace.globalYRange = yRange;
        [self reloadVolumeGraph];
    }
}

-(void)changeLabelAndPlot{
    _comparedValue = !_comparedValue;
    if (_comparedValue) {
        [self clearVolumeLabel];
        [self showComparedVolumeLabel];
        if (!_isCDPVisible) {
            [self clearSnapshotPriceLabel];
#ifdef LPCB
            [self showComparedPriceLabelWithBValue:((EquityTick *)_tickPlotDataSource.comparedDataSource).snapshot_b];
#else
            [self showComparedPriceLabel:((EquityTick *)_tickPlotDataSource.comparedDataSource).snapshot];
#endif
        }
    }else{
        [self clearComparedVolumeLabel];
        [self showVolumeLabel];
        if (!_isCDPVisible) {
            [self clearComparedPriceLabel];
#ifdef LPCB
            [self showSnapshotPriceLabel2:((EquityTick *)_tickPlotDataSource.dataSource).snapshot_b];
#else
            [self showSnapshotPriceLabel:((EquityTick *)_tickPlotDataSource.dataSource).snapshot];
#endif
        }
    }
    
    [_comparedVolumeHostView.hostedGraph plotWithIdentifier:@"Compared Volume Plot"].hidden = !_comparedValue;
    [_volumeHostView.hostedGraph plotWithIdentifier:@"Volume Plot"].hidden = _comparedValue;
    

}

-(void)showComparedVolumeLabel{
    /*
     這一段在畫量圖表旁邊的數字
     */
    CPTXYAxisSet *volumeAxisSet = (CPTXYAxisSet *) self.comparedVolumeHostView.hostedGraph.axisSet;
    if(_tickPlotDataSource.maxComparedVolume != 0)
    {
        /*
         X軸分隔虛線樣式
         */
        CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
        gridLineStyle.lineColor = [CPTColor grayColor];
        gridLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:2], [NSNumber numberWithInteger:1], nil];
        gridLineStyle.lineWidth = 0.3f;
        volumeAxisSet.xAxis.majorGridLineStyle = gridLineStyle;//畫格線
        volumeAxisSet.yAxis.majorGridLineStyle = gridLineStyle;//畫格線
        
        NSMutableSet *volumeLabels = [NSMutableSet setWithCapacity:5];
        NSMutableSet *volumeLocations = [NSMutableSet setWithCapacity:5];
        double value = _tickPlotDataSource.maxComparedVolume;

        
        for (double volumeCounter=value/4; volumeCounter < value; volumeCounter+=value/4) {
            
            //調整字的顏色
            CPTMutableTextStyle *newStyle = [volumeAxisSet.yAxis.labelTextStyle mutableCopy];
            newStyle.color = [CPTColor colorWithComponentRed:0 green:0 blue:1 alpha:1];
            newStyle.fontSize = 16.0f;
            volumeAxisSet.yAxis.labelTextStyle = newStyle;
            //調整背景顏色
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[CodingUtil volumeRoundRownWithDouble:volumeCounter]  textStyle:volumeAxisSet.yAxis.labelTextStyle];
            //決定位置
            CGFloat location = volumeCounter;
            label.tickLocation = CPTDecimalFromCGFloat(location);
            label.offset = 1;//volumeAxisSet.yAxis.majorTickLength;
            if (label) {
                [volumeLabels addObject:label];
                [volumeLocations addObject:[NSNumber numberWithFloat:location]];
            }
        }
        volumeAxisSet.yAxis.axisLabels = volumeLabels;
        volumeAxisSet.yAxis.majorTickLength = 0;
        volumeAxisSet.yAxis.majorTickLocations = volumeLocations;
    }
    else {
        volumeAxisSet.yAxis.axisLabels = nil;
        volumeAxisSet.yAxis.majorTickLocations = nil;
    }
}

- (void)clearComparedVolumeLabel
{
    CPTXYAxisSet *volumeAxisSet = (CPTXYAxisSet *) self.comparedVolumeHostView.hostedGraph.axisSet;
    volumeAxisSet.yAxis.axisLabels = nil;
    volumeAxisSet.yAxis.majorTickLocations = nil;
}

- (void)showComparedPriceLabel:(EquitySnapshotDecompressed *) snapshot
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.comparedPriceHostView.hostedGraph.axisSet;
    if (snapshot.referencePrice > 0 && snapshot.highestPrice > 0 && snapshot.lowestPrice > 0) {
        /*
         Y軸標示各個價格
         */
        NSMutableSet *yLabels = [NSMutableSet setWithCapacity:5];
        NSMutableSet *yLocations = [NSMutableSet setWithCapacity:5];
        
        //算出最高最低價格與參考價相差的比率
        double increasePercentage = fabs((snapshot.highestPrice - snapshot.referencePrice)/snapshot.referencePrice);
        double decreasePercentage = fabs((snapshot.lowestPrice - snapshot.referencePrice)/snapshot.referencePrice);
        
        CPTMutableTextStyle *normalStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        normalStyle.color = [CPTColor colorWithComponentRed:224.0f/255.0f green:100.0f/255.0f blue:16.0f/255.0f alpha:1.000];
        normalStyle.fontSize = SNAPSHOT_FONTSIZE;
        
        
        /**
         *  區間預設先以上下各1%來看，如果漲幅或跌幅超過1%，就要scale到該大小。而相對應的另一方向，也要scale到相同大小。例如漲幅5%，那麼上下就各5%的空間。
         在價格圖裡要顯示五個價格標示：
         */
        double minY = 0;
        double maxY = 0;
        double middleNumberOfMinAndReference = 0;
        double middleNumberOfMaxAndReference = 0;
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
        
//        _maxPrice = maxY;
//        _minPrice = minY;
        CPTAxisLabel *lowerBoundLabel = [self comparedAxisLabelWithPrice:minY textStyle:normalStyle];
        lowerBoundLabel.offset = 1;
        lowerBoundLabel.alignment = CPTAlignmentBottom;
        CPTAxisLabel *upperBoundLabel = [self comparedAxisLabelWithPrice:maxY textStyle:normalStyle];
        upperBoundLabel.offset = 1;
        upperBoundLabel.alignment = CPTAlignmentTop;
        
        //標示區間內最小數字
        if (lowerBoundLabel != nil) {
            [yLabels addObject:lowerBoundLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:lowerBoundLabel.tickLocation]];
        }
        
        //標示區間內最大數字
        if (upperBoundLabel != nil) {
            [yLabels addObject:upperBoundLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:upperBoundLabel.tickLocation]];
        }
        
        middleNumberOfMinAndReference = (snapshot.referencePrice+minY)/2;
        middleNumberOfMaxAndReference = (snapshot.referencePrice+maxY)/2;
        
        CPTAxisLabel *middleNumberOfMinAndReferenceLabel =[self comparedAxisLabelWithPrice:middleNumberOfMinAndReference textStyle:normalStyle];
        
        middleNumberOfMinAndReferenceLabel.offset = 1;
        CPTAxisLabel *middleNumberOfMaxAndReferenceLabel =[self comparedAxisLabelWithPrice:middleNumberOfMaxAndReference textStyle:normalStyle];
        
        middleNumberOfMaxAndReferenceLabel.offset = 1;
        //標示最低價與參考價中間的數字
        if (lowerBoundLabel != nil) {
            [yLabels addObject:middleNumberOfMinAndReferenceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:middleNumberOfMinAndReferenceLabel.tickLocation]];
        }
        
        //標示最高價與參考價中間的數字
        if (lowerBoundLabel != nil) {
            [yLabels addObject:middleNumberOfMaxAndReferenceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:middleNumberOfMaxAndReferenceLabel.tickLocation]];
        }
        
        //標示參考價
        CPTMutableTextStyle *referencePriceStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        referencePriceStyle.color = [CPTColor brownColor];
        referencePriceStyle.fontSize = SNAPSHOT_FONTSIZE;
        
        //參考價
        CPTAxisLabel *referencePriceLabel = [self comparedAxisLabelWithPrice:snapshot.referencePrice textStyle:referencePriceStyle];
        referencePriceLabel.offset = 1;
        if (referencePriceLabel) {
            [yLabels addObject:referencePriceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:referencePriceLabel.tickLocation]];
        }
        
        axisSet.yAxis.axisLabels = yLabels;
        axisSet.yAxis.majorTickLength = 1;
        axisSet.yAxis.majorTickLocations = yLocations;
    }
    else if (snapshot.referencePrice > 0) {
        NSMutableSet *yLabels = [NSMutableSet setWithCapacity:1];
        NSMutableSet *yLocations = [NSMutableSet setWithCapacity:1];
        
        //標示參考價
        CPTMutableTextStyle *referencePriceStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        referencePriceStyle.color = [CPTColor brownColor];
        referencePriceStyle.fontSize = SNAPSHOT_FONTSIZE;
        
        //參考價
        CPTAxisLabel *referencePriceLabel =
        [self comparedAxisLabelWithPrice:snapshot.referencePrice textStyle:referencePriceStyle];
        
        if (referencePriceLabel) {
            [yLabels addObject:referencePriceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:referencePriceLabel.tickLocation]];
        }
        
        
        axisSet.yAxis.axisLabels = yLabels;
        axisSet.yAxis.majorTickLength = 1;
        axisSet.yAxis.majorTickLocations = yLocations;
    }
}

- (void)showComparedPriceLabelWithBValue:(FSSnapshot *) snapshot
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.comparedPriceHostView.hostedGraph.axisSet;
    
    if (snapshot.reference_price.calcValue > 0 && snapshot.high_price.calcValue > 0 && snapshot.low_price.calcValue > 0) {
        /*
         Y軸標示各個價格
         */
        NSMutableSet *yLabels = [NSMutableSet setWithCapacity:5];
        NSMutableSet *yLocations = [NSMutableSet setWithCapacity:5];
        
        //算出最高最低價格與參考價相差的比率
        double increasePercentage = fabs((snapshot.high_price.calcValue - snapshot.reference_price.calcValue)/snapshot.reference_price.calcValue);
        double decreasePercentage = fabs((snapshot.low_price.calcValue - snapshot.reference_price.calcValue)/snapshot.reference_price.calcValue);
        
        CPTMutableTextStyle *normalStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        normalStyle.color = [CPTColor colorWithComponentRed:224.0f/255.0f green:100.0f/255.0f blue:16.0f/255.0f alpha:1.000];
        normalStyle.fontSize = SNAPSHOT_FONTSIZE;
        
        
        /**
         *  區間預設先以上下各1%來看，如果漲幅或跌幅超過1%，就要scale到該大小。而相對應的另一方向，也要scale到相同大小。例如漲幅5%，那麼上下就各5%的空間。
         在價格圖裡要顯示五個價格標示：
         */
        double minY = 0;
        double maxY = 0;
        double middleNumberOfMinAndReference = 0;
        double middleNumberOfMaxAndReference = 0;
        
        PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        
        if (portfolioItem->identCode[0] == 'T' && portfolioItem->identCode[1] == 'W' && _buttonContainerScrollView.fitPriceGraphScopeButton.selected == NO && ![snapshot isKindOfClass:[IndexSnapshotDecompressed class]] && (snapshot.top_price.calcValue !=0 && snapshot.bottom_price.calcValue !=0) && portfolioItem->type_id != 3 && portfolioItem->type_id != 6) {
            maxY = snapshot.top_price.calcValue;// + snapshot.referencePrice *0.07;
            minY = snapshot.bottom_price.calcValue;// - snapshot.referencePrice *0.07;
            
            
        }else{
            if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
                if (increasePercentage >= 0.1) {
                    minY = snapshot.reference_price.calcValue*(1-increasePercentage);
                    maxY = snapshot.high_price.calcValue;
                }else{
                    minY = snapshot.reference_price.calcValue*0.9;
                    maxY = snapshot.reference_price.calcValue*1.1;
                }
            }else{
                if (increasePercentage >= decreasePercentage && increasePercentage > 0.01) {
                    minY = snapshot.reference_price.calcValue*(1-increasePercentage);
                    maxY = snapshot.high_price.calcValue;
                }
                else if (increasePercentage < decreasePercentage && decreasePercentage > 0.01) {
                    minY = snapshot.low_price.calcValue;
                    maxY = snapshot.reference_price.calcValue*(1+decreasePercentage);
                }
                else {
                    minY = snapshot.reference_price.calcValue*0.99;
                    maxY = snapshot.reference_price.calcValue*1.01;
                }
            }
        }
    
        //        _maxPrice = maxY;
        //        _minPrice = minY;
        CPTAxisLabel *lowerBoundLabel = [self comparedAxisLabelWithPrice:minY textStyle:normalStyle];
        lowerBoundLabel.offset = 1;
        lowerBoundLabel.alignment = CPTAlignmentBottom;
        CPTAxisLabel *upperBoundLabel = [self comparedAxisLabelWithPrice:maxY textStyle:normalStyle];
        upperBoundLabel.offset = 1;
        upperBoundLabel.alignment = CPTAlignmentTop;
        
        //標示區間內最小數字
        if (lowerBoundLabel != nil) {
            [yLabels addObject:lowerBoundLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:lowerBoundLabel.tickLocation]];
        }
        
        //標示區間內最大數字
        if (upperBoundLabel != nil) {
            [yLabels addObject:upperBoundLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:upperBoundLabel.tickLocation]];
        }
        
        middleNumberOfMinAndReference = (snapshot.reference_price.calcValue+minY)/2;
        middleNumberOfMaxAndReference = (snapshot.reference_price.calcValue+maxY)/2;
        
        CPTAxisLabel *middleNumberOfMinAndReferenceLabel =[self comparedAxisLabelWithPrice:middleNumberOfMinAndReference textStyle:normalStyle];
        middleNumberOfMinAndReferenceLabel.offset = 1;
        
        CPTAxisLabel *middleNumberOfMaxAndReferenceLabel =[self comparedAxisLabelWithPrice:middleNumberOfMaxAndReference textStyle:normalStyle];
        middleNumberOfMaxAndReferenceLabel.offset = 1;
        
        //標示最低價與參考價中間的數字
        if (middleNumberOfMinAndReferenceLabel != nil) {
            [yLabels addObject:middleNumberOfMinAndReferenceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:middleNumberOfMinAndReferenceLabel.tickLocation]];
        }
        
        //標示最高價與參考價中間的數字
        if (middleNumberOfMaxAndReferenceLabel != nil) {
            [yLabels addObject:middleNumberOfMaxAndReferenceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:middleNumberOfMaxAndReferenceLabel.tickLocation]];
        }
        
        //標示參考價
        CPTMutableTextStyle *referencePriceStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        referencePriceStyle.color = [CPTColor brownColor];
        referencePriceStyle.fontSize = SNAPSHOT_FONTSIZE;
        
        //參考價
        CPTAxisLabel *referencePriceLabel = [self comparedAxisLabelWithPrice:snapshot.reference_price.calcValue textStyle:referencePriceStyle];
        referencePriceLabel.offset = 1;
        if (referencePriceLabel) {
            [yLabels addObject:referencePriceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:referencePriceLabel.tickLocation]];
        }
        
        axisSet.yAxis.axisLabels = yLabels;
        axisSet.yAxis.majorTickLength = 1;
        axisSet.yAxis.majorTickLocations = yLocations;
    }
    else if (snapshot.reference_price.calcValue > 0) {
        NSMutableSet *yLabels = [NSMutableSet setWithCapacity:1];
        NSMutableSet *yLocations = [NSMutableSet setWithCapacity:1];
        
        //標示參考價
        CPTMutableTextStyle *referencePriceStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        referencePriceStyle.color = [CPTColor brownColor];
        referencePriceStyle.fontSize = SNAPSHOT_FONTSIZE;
        
        //參考價
        CPTAxisLabel *referencePriceLabel =
        [self comparedAxisLabelWithPrice:snapshot.reference_price.calcValue textStyle:referencePriceStyle];
        
        if (referencePriceLabel) {
            [yLabels addObject:referencePriceLabel];
            [yLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:referencePriceLabel.tickLocation]];
        }
        
        
        axisSet.yAxis.axisLabels = yLabels;
        axisSet.yAxis.majorTickLength = 1;
        axisSet.yAxis.majorTickLocations = yLocations;
    }
}


- (void)clearComparedPriceLabel
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.comparedPriceHostView.hostedGraph.axisSet;
    axisSet.yAxis.axisLabels = nil;
//    axisSet.yAxis.majorTickLocations = nil;
}

#pragma mark - Cross hair
/**
 *  把十字線plot加進graph裡面
 */
- (void)addCrossHair
{
//    if (_crossHair == nil) {
        self.crossHair = [[FSCrossHair alloc] init];
        self.volumeCrossHair = [[FSCrossHair alloc]init];
        [_priceHostView.hostedGraph addPlot:_crossHair.verticalLine];
        [_volumeHostView.hostedGraph addPlot:_volumeCrossHair.verticalLine];
        
        CPTGraph *graph = self.priceHostView.hostedGraph;
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
        [graph addPlot:_crossHair.horizonalLine toPlotSpace:plotSpace];
        
//        CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.crossLineView.hostedGraph.axisSet;
//        
//        axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
//        axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
//        
//        CPTXYAxisSet *axisSet2 = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;
//        
//        axisSet2.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
//        axisSet2.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
//        [_priceHostView.hostedGraph addPlot:_crossHair.horizonalLine];
        [self hideCrossHair];
//    }
}

- (void)removeCrossHair
{
    [_crossLineView.hostedGraph removePlot:_crossHair.verticalLine];
    [_priceHostView.hostedGraph removePlot:_crossHair.horizonalLine];
    
    
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
//    [UIView animateWithDuration:0.33 animations:^() {
//        
//    }];
    _crossHair.verticalLine.hidden = NO;
    _crossHair.horizonalLine.hidden = NO;
    _volumeCrossHair.verticalLine.hidden = NO;
}

- (void)hideCrossHair
{
//    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeOutAnimation.duration = 0.33f;
//    fadeOutAnimation.removedOnCompletion = NO;
//    fadeOutAnimation.fillMode = kCAFillModeForwards;
//    fadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0];

    _crossHair.verticalLine.hidden = YES;
    _crossHair.horizonalLine.hidden = YES;
    _volumeCrossHair.verticalLine.hidden = YES;
}

- (BOOL)isCrossHairVisible
{
    return _crossHair.verticalLine.opacity == 1.0 && _crossHair.horizonalLine.opacity == 1.0;
}

/**
 *  //設定十字線的高度
 */
- (void)updateCrossHairVerticalLinePosition
{
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.crossLineView.hostedGraph.defaultPlotSpace;
    if (_maxPrice>xyPlotSpace.yRange.locationDouble + xyPlotSpace.yRange.lengthDouble) {
        _crossHair.verticalLineMaxY = _maxPrice;
        
    }else{
        _crossHair.verticalLineMaxY = xyPlotSpace.yRange.locationDouble + xyPlotSpace.yRange.lengthDouble;
    }
    _volumeCrossHair.verticalLineMaxY = MAX(_tickPlotDataSource.maxMainVolume, _tickPlotDataSource.maxComparedVolume);
    
}

#pragma mark - AverageValueLine

- (void)addAverageValueLine
{
    if (nil == _averageValueLine) {
        self.averageValueLine = [[FSAverageValueLine alloc] init];
        _averageValueLine.averageLinePlot.dataSource = _tickPlotDataSource;
        [_priceHostView.hostedGraph addPlot:_averageValueLine.averageLinePlot];
        
        
        //第一個tick前的線
        CPTScatterPlot *lineBeforeTickPlot = [[CPTScatterPlot alloc] init];
        lineBeforeTickPlot.identifier = @"BeforeFirstTickAverageLinePlot";
        lineBeforeTickPlot.dataSource = self.tickPlotDataSource;
        [_priceHostView.hostedGraph addPlot:lineBeforeTickPlot];
        
        CPTMutableLineStyle *lineBeforeTickLineStyle = [lineBeforeTickPlot.dataLineStyle mutableCopy];
        lineBeforeTickLineStyle.lineWidth = 1;
        lineBeforeTickLineStyle.lineColor = [CPTColor purpleColor];
        lineBeforeTickPlot.dataLineStyle = lineBeforeTickLineStyle;
        
        [self hideAverageValueLine];
    }
}

- (void)showAverageValueLine
{
    [self hideCrossHair];
    [self hideCrossInfoPanel];
    _isAverageValueLinesVisible = YES;
    _averageValueLine.averageLinePlot.hidden = NO;
    [_priceHostView.hostedGraph plotWithIdentifier:@"BeforeFirstTickAverageLinePlot"].hidden = NO;
    //動畫呈現
    //    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeInAnimation.duration = 0.33f;
//    fadeInAnimation.removedOnCompletion = NO;
//    fadeInAnimation.fillMode = kCAFillModeForwards;
//    fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
//    [_averageValueLine.averageLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
}


- (void)hideAverageValueLine
{
    _isAverageValueLinesVisible = NO;
    _averageValueLine.averageLinePlot.hidden = YES;
    [_priceHostView.hostedGraph plotWithIdentifier:@"BeforeFirstTickAverageLinePlot"].hidden = YES;
    //動畫消失
//    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeOutAnimation.duration = 0.33f;
//    fadeOutAnimation.removedOnCompletion = NO;
//    fadeOutAnimation.fillMode = kCAFillModeForwards;
//    fadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0];
//    [_averageValueLine.averageLinePlot addAnimation:fadeOutAnimation forKey:@"animateOpacity"];
}

#pragma mark - CDP

- (void)addCDP
{
    if (nil == _cdp) {
        self.cdp = [[FSCDP alloc] initWithPortfolioItem:_tickPlotDataSource.portfolioItem];
        _cdp.delegate = self;
        
    }
}

- (void)showCDP
{
    _isCDPVisible = YES;
    [_cdp startWatch];
    
    [self showCDPPriceLabel];
    [self clearComparedPriceLabel];
    if (_changeYRangeForCDP) {
        [self scalePriceGraphToFitCDPPlot];
    }
    
    _cdp.ahPlot.hidden = NO;
    _cdp.nhPlot.hidden = NO;
    _cdp.cdpPlot.hidden = NO;
    _cdp.alPlot.hidden = NO;
    _cdp.nlPlot.hidden = NO;

    if (!firstTime) {
        firstTime = YES;
        PortfolioItem * item = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
        NSString *identCodeSymbol = [NSString stringWithFormat:@"%c%c:%@", item->identCode[0], item->identCode[1], item->symbol];
        FSSnapshotQueryOut *snapshotQueryPacket3 = [[FSSnapshotQueryOut alloc] initWithSnapshotTypes:@[@3] identCodeSymbols:@[identCodeSymbol]];
        [FSDataModelProc sendData:self WithPacket:snapshotQueryPacket3];

    }
    [_cdp reloadData];
    //動畫呈現
//    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeInAnimation.duration = 0.33f;
//    fadeInAnimation.removedOnCompletion = NO;
//    fadeInAnimation.fillMode = kCAFillModeForwards;
//    fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
//    [_cdp.ahPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
//    [_cdp.nhPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
//    [_cdp.cdpPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
//    [_cdp.alPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
//    [_cdp.nlPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];

}

- (void)hideCDP
{
    _isCDPVisible = NO;
    if (_twoStock){
        if (_comparedValue) {
#ifdef LPCB
            [self showComparedPriceLabelWithBValue:((EquityTick *)_tickPlotDataSource.comparedDataSource).snapshot_b];
#else
            [self showComparedPriceLabel:((EquityTick *)_tickPlotDataSource.comparedDataSource).snapshot];
#endif
            [self clearCDPLabel];
        }else{
#ifdef LPCB
            [self showSnapshotPriceLabel2:((EquityTick *)_tickPlotDataSource.dataSource).snapshot_b];
#else
            [self showSnapshotPriceLabel:((EquityTick *)_tickPlotDataSource.dataSource).snapshot];
#endif
        }
    }else{
#ifdef LPCB
        [self showSnapshotPriceLabel2:((EquityTick *)_tickPlotDataSource.dataSource).snapshot_b];
#else
        [self showSnapshotPriceLabel:((EquityTick *)_tickPlotDataSource.dataSource).snapshot];
#endif
    }
    
    
    if (_changeYRangeForCDP) {
#ifdef LPCB
        [self scalePriceGraphToFitPrice2:((EquityTick *)_tickPlotDataSource.dataSource).snapshot_b];
#else
        [self scalePriceGraphToFitPrice:((EquityTick *)_tickPlotDataSource.dataSource).snapshot];
#endif
    }
    _cdp.ahPlot.hidden = YES;
    _cdp.nhPlot.hidden = YES;
    _cdp.cdpPlot.hidden = YES;
    _cdp.alPlot.hidden = YES;
    _cdp.nlPlot.hidden = YES;
}

- (void)showCDPPriceLabel
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;
    
    self.cdpLabels = [NSMutableSet setWithCapacity:5];
    self.cdpLocations = [NSMutableSet setWithCapacity:5];
    
    //把cdp的指標數值都放進來
    NSArray *cdpPrices = @[@(_cdp.cdp), @(_cdp.nh), @(_cdp.ah),@(_cdp.nl), @(_cdp.al)];
    if (_cdp.ah>_maxPrice || _cdp.al<_minPrice) {
        _changeYRangeForCDP = YES;
    }else{
        _changeYRangeForCDP = NO;
    }
//    float maxPrice = MAX(_cdp.ah, _maxPrice);
//    float minPrice = MIN(_cdp.al, _minPrice);
    float priceBlock = (_maxPrice - _minPrice)/8;
    //讀取cdp線的顏色，讓priceLabel與線的顏色一致
    NSArray *cdpPriceColors = @[ _cdp.cdpPlot.dataLineStyle.lineColor, _cdp.nhPlot.dataLineStyle.lineColor,_cdp.ahPlot.dataLineStyle.lineColor, _cdp.nlPlot.dataLineStyle.lineColor, _cdp.alPlot.dataLineStyle.lineColor];
    for (NSUInteger counter=0; counter < [cdpPrices count]; counter++) {
        CPTMutableTextStyle *newStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
        newStyle.color = cdpPriceColors[counter];
        newStyle.fontSize = 19.0f;
        NSString *priceString = [CodingUtil ConvertPriceValueToString:[((NSNumber *)cdpPrices[counter]) floatValue] withIdSymbol:
                             [_tickPlotDataSource.portfolioItem getIdentCodeSymbol]];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:priceString textStyle:newStyle];
        CGFloat location = [((NSNumber *)cdpPrices[counter]) floatValue];
        
        if (counter > 0) {
            float movePrice = 0.0;
            if (counter == 1 || counter == 2) {
                movePrice = MAX([((NSNumber *)cdpPrices[counter]) floatValue]-[((NSNumber *)cdpPrices[0]) floatValue], priceBlock * counter);
                location = [((NSNumber *)cdpPrices[0]) floatValue] + movePrice;
            }else{
                movePrice = MAX([((NSNumber *)cdpPrices[0]) floatValue]-[((NSNumber *)cdpPrices[counter]) floatValue],priceBlock*(counter - 2) );
                location = [((NSNumber *)cdpPrices[0]) floatValue] - movePrice;
            }
        }
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = 0;//axisSet.yAxis.majorTickLength;
        if (label) {
            [_cdpLabels addObject:label];
            [_cdpLocations addObject:((NSNumber *)cdpPrices[counter])];
        }
    }
    
    CPTMutableTextStyle *lowHighPriceStyle = [axisSet.yAxis.labelTextStyle mutableCopy];
    lowHighPriceStyle.color = [CPTColor whiteColor];
    lowHighPriceStyle.fontSize = 19.0f;
    
    PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    if (portfolioItem->type_id == 1 && [_cdpLocations count] > 1 &&
        [FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        
        CPTAxisLabel *lowerBoundLabel;
        lowerBoundLabel = [self axisLabelWithPrice:_minPrice textStyle:lowHighPriceStyle];
        lowerBoundLabel.offset = 1;
        lowerBoundLabel.alignment = CPTAlignmentBottom;
        lowerBoundLabel.contentLayer.backgroundColor = [[StockConstant priceDownGradientTopColor] cgColor];
        
        CPTAxisLabel *upperBoundLabel;
        upperBoundLabel = [self axisLabelWithPrice:_maxPrice textStyle:lowHighPriceStyle];
        upperBoundLabel.offset = 1;
        upperBoundLabel.alignment = CPTAlignmentTop;
        upperBoundLabel.contentLayer.backgroundColor = [[StockConstant priceUpGradientBottomColor] cgColor];

        //標示區間內最小數字
        if (lowerBoundLabel != nil) {
            [_cdpLabels addObject:lowerBoundLabel];
            [_cdpLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:lowerBoundLabel.tickLocation]];
        }
        
        //標示區間內最大數字
        if (upperBoundLabel != nil) {
            [_cdpLabels addObject:upperBoundLabel];
            [_cdpLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:upperBoundLabel.tickLocation]];
        }
    }
    
    axisSet.yAxis.axisLabels = _cdpLabels;
    axisSet.yAxis.majorTickLength = 1;
    axisSet.yAxis.majorTickLocations = _cdpLocations;

}

- (void)hideCDPPriceLabel
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;
    NSMutableSet *axisLabels = [axisSet.yAxis.axisLabels mutableCopy];
    [axisLabels minusSet:_cdpLabels];
    axisSet.yAxis.axisLabels = axisLabels;
    self.cdpLabels = nil;
    
    NSMutableSet *majorTickLocations = [axisSet.yAxis.majorTickLocations mutableCopy];
    [majorTickLocations minusSet:_cdpLocations];
    axisSet.yAxis.majorTickLocations = majorTickLocations;
    self.cdpLocations = nil;
}

- (void)clearCDPLabel
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;
    axisSet.yAxis.axisLabels = nil;
    axisSet.yAxis.majorTickLocations = nil;
    [self.cdpLabels removeAllObjects];
}

- (void)scalePriceGraphToFitCDPPlot
{
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *) self.priceHostView.hostedGraph.defaultPlotSpace;
    /*
     設定價圖表的上下區間
     記得先改globalRange再改yRange，因為CorePlot會把新設定的yRange限制在globalRange內
     */
    /**
     *  如果CDP的資料還沒回來，裡面資料會是空的，這樣設range會造成圖表空白，所以要檢查是否為空值
     */
    if (![_cdp isDataEmpty]) {
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
            xyPlotSpace.globalYRange = nil;
            double minY = 0;
            double maxY = 0;
            minY = _cdp.cdp*0.9;
            maxY = _cdp.cdp*1.1;
            xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minY) length:CPTDecimalFromFloat(maxY - minY)];
            CPTMutablePlotRange *yRange = [xyPlotSpace.yRange mutableCopy];
            [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
            xyPlotSpace.yRange = yRange;
            
            //把globalYRange設為yRange可以防止scroll
            xyPlotSpace.globalYRange = yRange;
        }else{
            if(_cdp.cdp<0.1){
                xyPlotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(_cdp.al*0.99-0.005) length:CPTDecimalFromFloat((_cdp.ah-_cdp.al)+_cdp.al*0.02+0.010)];
            }else{
                xyPlotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(_cdp.al*0.99-0.015) length:CPTDecimalFromFloat((_cdp.ah-_cdp.al)+_cdp.al*0.02+0.015)];
            }
            
            //把globalYRange設為yRange可以防止scroll
            xyPlotSpace.yRange = xyPlotSpace.globalYRange;
        }
    }
}

- (void)updateInfoPanel:(EquityTickDecompressed *) mainEquityTickDecompressed  mainVolumNumber:(NSNumber *) mainVolumNumber comparedEquityTickDecompressed:(EquityTickDecompressed *) comparedEquityTickDecompressed comparedVolumeNumber:(NSNumber *) comparedVolumeNumber
{
    if (mainEquityTickDecompressed == nil && comparedEquityTickDecompressed == nil) {
        [_crossInfoPanel updateTimeNoTick];

    }else{
        if (mainEquityTickDecompressed == nil) {
            [_crossInfoPanel updateTime:comparedEquityTickDecompressed.time openTime:_tickPlotDataSource.chartOpenTime];
        }else{
            [_crossInfoPanel updateTime:mainEquityTickDecompressed.time openTime:_tickPlotDataSource.chartOpenTime];
        }
    }
    
    
    FSEquityDrawCrossHairInfo *crossHairInfo = [[FSEquityDrawCrossHairInfo alloc] init];
    crossHairInfo.bid = [NSNumber numberWithDouble:mainEquityTickDecompressed.bid];
    crossHairInfo.ask = [NSNumber numberWithDouble:mainEquityTickDecompressed.ask];
    crossHairInfo.last = [NSNumber numberWithDouble:mainEquityTickDecompressed.price];
    crossHairInfo.change = [NSNumber numberWithDouble:mainEquityTickDecompressed.price-((EquityTick *)_tickPlotDataSource.dataSource).snapshot.referencePrice];
    crossHairInfo.vol = mainVolumNumber;
    
    if (comparedEquityTickDecompressed == nil) {
        crossHairInfo.comparedLast = [NSNumber numberWithFloat:0.00];
    }else{
        crossHairInfo.comparedLast = @(comparedEquityTickDecompressed.price);
    }
    crossHairInfo.comparedVol = comparedVolumeNumber;
    NSNumber *referencePriceNumber = @(((EquityTick *)_tickPlotDataSource.dataSource).snapshot.referencePrice);
    NSNumber *comparedReferencePriceNumber = @(((EquityTick *)_tickPlotDataSource.comparedDataSource).snapshot.referencePrice);
    
    if (_twoStock) {
        [_crossInfoPanel updatePanelWithColorInfo:crossHairInfo referencePrice:referencePriceNumber comparedReferencePriceNumber:comparedReferencePriceNumber];
    }else{
        [_crossInfoPanel updatePanelWithInfo:crossHairInfo referencePrice:referencePriceNumber comparedReferencePriceNumber:comparedReferencePriceNumber];
    }
    
}

- (void)updateInfoPanelWithBValue:(FSTickData *) mainEquityTickDecompressed  mainVolumNumber:(NSNumber *) mainVolumNumber comparedEquityTickDecompressed:(FSTickData *) comparedEquityTickDecompressed comparedVolumeNumber:(NSNumber *) comparedVolumeNumber
{
    if (mainEquityTickDecompressed == nil && comparedEquityTickDecompressed == nil) {
        [_crossInfoPanel updateTimeNoTick];
        
    }else{
        if (mainEquityTickDecompressed == nil) {
            [_crossInfoPanel updateTime:[comparedEquityTickDecompressed.time absoluteMinutesTime]-_tickPlotDataSource.chartOpenTime openTime:_tickPlotDataSource.chartOpenTime];
        }else{
            [_crossInfoPanel updateTime:[mainEquityTickDecompressed.time absoluteMinutesTime]-_tickPlotDataSource.chartOpenTime openTime:_tickPlotDataSource.chartOpenTime];
        }
    }
    PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    FSEquityDrawCrossHairInfo *crossHairInfo = [[FSEquityDrawCrossHairInfo alloc] init];
    crossHairInfo.bid = [NSNumber numberWithDouble:mainEquityTickDecompressed.bid.calcValue];
    crossHairInfo.ask = [NSNumber numberWithDouble:mainEquityTickDecompressed.ask.calcValue];
    if (portfolioItem->type_id == 6) {
        crossHairInfo.last = [NSNumber numberWithDouble:mainEquityTickDecompressed.indexValue.calcValue];
        crossHairInfo.change = [NSNumber numberWithDouble:mainEquityTickDecompressed.indexValue.calcValue-((EquityTick *)_tickPlotDataSource.dataSource).snapshot_b.reference_price.calcValue];
    }else{
        crossHairInfo.last = [NSNumber numberWithDouble:mainEquityTickDecompressed.last.calcValue];
        crossHairInfo.change = [NSNumber numberWithDouble:mainEquityTickDecompressed.last.calcValue-((EquityTick *)_tickPlotDataSource.dataSource).snapshot_b.reference_price.calcValue];
    }
    
    
    crossHairInfo.vol = mainVolumNumber;
    
    if (comparedEquityTickDecompressed == nil) {
        crossHairInfo.comparedLast = [NSNumber numberWithFloat:0.00];
    }else{
        if (comparedEquityTickDecompressed.indexValue.calcValue) {
            crossHairInfo.comparedLast = @(comparedEquityTickDecompressed.indexValue.calcValue);
        }else{
            crossHairInfo.comparedLast = @(comparedEquityTickDecompressed.last.calcValue);
        }
        
    }
    crossHairInfo.comparedVol = comparedVolumeNumber;
    NSNumber *referencePriceNumber = @(((EquityTick *)_tickPlotDataSource.dataSource).snapshot_b.reference_price.calcValue);
    NSNumber *comparedReferencePriceNumber = @(((EquityTick *)_tickPlotDataSource.comparedDataSource).snapshot_b.reference_price.calcValue);
    
    if (_twoStock) {
        [_crossInfoPanel updatePanelWithColorInfo:crossHairInfo referencePrice:referencePriceNumber comparedReferencePriceNumber:comparedReferencePriceNumber];
    }else{
        [_crossInfoPanel updatePanelWithInfo:crossHairInfo referencePrice:referencePriceNumber comparedReferencePriceNumber:comparedReferencePriceNumber];
    }
    
}


#pragma mark - Autolayout

-(void)setCrossHairInfoPanel
{
    CGFloat height = [UIScreen mainScreen].applicationFrame.size.height;
    
    switch (_crossHairInfoPanelPosition){
        case Leftside:
            _crossInfoPanel.frame = CGRectMake(self.priceHostView.hostedGraph.plotAreaFrame.paddingLeft, height-320, 100, 130);
            break;
        case RightSide:
            _crossInfoPanel.frame = CGRectMake(self.priceHostView.hostedGraph.plotAreaFrame.paddingLeft+140, height-320, 100, 130);
            break;
    }
}


-(void)setLayOut
{
    
   // NSDictionary *selfViewDictionary = NSDictionaryOfVariableBindings(_crossInfoPanel);
//    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    NSMutableArray *constraints = [NSMutableArray new];

    NSDictionary *metrics = @{@"priceHostGraphPadding":@(self.priceHostView.hostedGraph.plotAreaFrame.paddingLeft),
                              @"graphContainerHeight": @(CGRectGetHeight(self.view.bounds)*3/4),
                              @"panelHeight" : @(CGRectGetHeight(self.view.bounds)*1/3),
                              @"priceHeight" : @((self.view.frame.size.height-100)/3*2)
                              };

    NSDictionary *subViewDictionary = NSDictionaryOfVariableBindings(_buttonContainerScrollView,_graphContainer, _infoPanel, _priceHostView, _volumeHostView,_crossLineView,_comparedPriceHostView,_comparedVolumeHostView);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buttonContainerScrollView(44)][_graphContainer][_infoPanel(100)]|" options:0 metrics:metrics views:subViewDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_buttonContainerScrollView]|" options:0 metrics:metrics views:subViewDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_graphContainer]-1-|" options:0 metrics:metrics views:subViewDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_infoPanel]|" options:0 metrics:metrics views:subViewDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_priceHostView][_volumeHostView]" options:0 metrics:metrics views:subViewDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_comparedPriceHostView][_comparedVolumeHostView]" options:0 metrics:metrics views:subViewDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_crossLineView]|" options:0 metrics:metrics views:subViewDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_crossLineView]|" options:0 metrics:metrics views:subViewDictionary]];
    
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_priceHostView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_graphContainer attribute:NSLayoutAttributeHeight multiplier:0.666 constant:0]];

    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_volumeHostView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_graphContainer attribute:NSLayoutAttributeHeight multiplier:0.333 constant:0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_comparedPriceHostView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_priceHostView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_comparedVolumeHostView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_volumeHostView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_priceHostView]|" options:0 metrics:metrics views:subViewDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_volumeHostView]|" options:0 metrics:metrics views:subViewDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_comparedPriceHostView]|" options:0 metrics:metrics views:subViewDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_comparedVolumeHostView]|" options:0 metrics:metrics views:subViewDictionary]];
    
    
    
    //把X軸移到兩個圖表中間的地方，constraintWithUpperOffset是從plotFrame最上方開始算
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.priceHostView.hostedGraph.axisSet;
    axisSet.xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:_volumeHostView.frame.origin.y];
    
    [self replaceCustomizeConstraints:constraints];

}

-(void)viewDidLayoutSubviews{
    [self.pageControl setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height - 10)];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    [self.infoPanel setContentOffset:CGPointMake(self.view.frame.size.width * [dataModel.infoPanelCenter.currentInfoPage intValue], 0)];
    self.pageControl.hidden = NO;
}


#pragma mark - Helper

- (UIColor *)colorWithPriceComparedToReferencePrice:(double) price referencePrice:(double) referencePrice
{
    if (price > referencePrice) {
        return [StockConstant PriceUpColor];
    }
    else if(price < referencePrice) {
        return [StockConstant PriceDownColor];
    }
    return [UIColor blueColor];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _infoPanel) {
        
    }
}

#pragma mark - 查詢自選股
-(void)notifyDataArrive:(NSMutableArray *)array{
    _dataNameArray = [array objectAtIndex:0];
    _dataIdArray = [array objectAtIndex:1];
    
    self.buttonContainerScrollView.dataIdArray = _dataIdArray;
    [_buttonContainerScrollView hideAddUserStockBtn];
}

-(void)groupNotifyDataArrive:(NSMutableArray *)array{ //查詢自選群組名之結果
    _categoryArray = [array objectAtIndex:0];
    _groupIdArray = [array objectAtIndex:1];
    
    self.buttonContainerScrollView.categoryArray = _categoryArray;
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:0] waitUntilDone:NO];
}

-(void)addStockInUserStock{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"群組", @"SecuritySearch", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    int i = 0;
    
    for (i = 0; i<[_categoryArray count]; i++) {
        [actionSheet addButtonWithTitle:[_categoryArray objectAtIndex:i]];
        
    }
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    [actionSheet setCancelButtonIndex:i];
    [self showActionSheet:actionSheet];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    FSInstantInfoWatchedPortfolio * watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    if (buttonIndex < [_categoryArray count]) {
        SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[watchPortfolio.portfolioItem getIdentCodeSymbol]];
        [dataModal.portfolioData selectGroupID:(int)buttonIndex+1];
        [dataModal.portfolioData AddItem:secu];
        self.buttonContainerScrollView.addUserStockButton.hidden = YES;
        [dataModal.securitySearchModel setChooseTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:0] waitUntilDone:NO];
    }
}



@end
