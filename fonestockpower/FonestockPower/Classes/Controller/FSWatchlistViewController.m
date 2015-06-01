//
//  FSWatchlistViewController.m
//  WirtsLeg
//
//  Created by KevinShen on 13/9/24.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSWatchlistViewController.h"
#import "FSUIButton.h"
#import "FSWatchlistTableCell.h"
#import "FSWatchlistPortfolioItem.h"
#import "ValueUtil.h"
#import "FSMainViewController.h"
#import "FSActionPlanSettingViewController.h"
#import "AmericaStockSettingViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSMultiChartViewFlowLayout.h"
#import "FSMultiChartViewController.h"
#import "DDPageControl.h"
#import "Snapshot.h"
#import "RadioTableViewCell.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSSnapshotQueryOut.h"
#import "CodingUtil.h"

#ifdef PatternPowerUS
#define PAGESIZE 1
#else
#define PAGESIZE 2
#endif

@interface FSWatchlistViewController ()<CustomIOS7AlertViewDelegate> {
    BOOL editFlag;//table是否正被編輯
    BOOL moveWatchListFlag;//watchList是否已被移動過
    BOOL isWatchingTick;
    BOOL watchPage;
    int selectRow;
    BOOL sortFlag;
    int rowNumber;
    UIImage *stretchableBlueButton;
    UIImage *stretchableLightBlueButton;
    UIImage *grayButton;
    CustomIOS7AlertView *cxAlertView;

    NSUInteger time;
    NSTimer *timer;
    
    UIImageView *radioImageView;
    
    NSMutableDictionary *alertDict;

}
@property (nonatomic, strong) NSArray *dynamicHeaderArray;
@property (nonatomic, strong) NSArray *headerSymbolArrayForGetValue;
@property (nonatomic, assign) NSUInteger currentSelectedHeader;

@property (nonatomic, strong) NSArray *sortAttributeArray;
@property (nonatomic, strong) NSArray *sortButtonTitleArray;

@property (nonatomic, strong) NSMutableDictionary *singleVolumeDictionary;
@property (nonatomic, strong) NSOperationQueue *cellRenderQueue;

@property (nonatomic, strong) FSUIButton *changeGroupButton;
@property (nonatomic, strong) UIActionSheet *groupSheet;
@property (nonatomic, assign) NSUInteger selectPickerIndex;
@property (nonatomic, assign) NSUInteger selectSortSheetIndex;
@property (nonatomic, assign) NSUInteger recentWatchsIndex;
@property (nonatomic, strong) NSMutableDictionary *mainDict;
@property (nonatomic, strong) NSArray *alertDataArray;//自選警示用，接收從警示model來的通知，並儲存在這裡
@property (nonatomic, strong) NSMutableDictionary *alertDataDict;
@property (nonatomic, strong) NSArray *cancelAlertDataArray;
@property (nonatomic, strong) NSMutableDictionary *cancelAlertDataDict;
@property (nonatomic, strong) FSMultiChartViewController *multiChartViewController;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (strong, nonatomic) DDPageControl *pageControl;
@property (nonatomic, strong) FSDataModelProc *dataModal;
@property (nonatomic, strong) NSMutableArray * nameArray;

@property (nonatomic, strong) UITableView *watchlistTableView;
@property (nonatomic, strong) FSUIButton *nameHeader;
@property (nonatomic, strong) FSUIButton *attributeHeader;
@property (nonatomic, strong) FSUIButton *volumeHeader;

@property (nonatomic, strong) FSUIButton *settingButton;

@property (nonatomic, strong) FSUIButton *checkBtn;
@property (nonatomic, strong) UILabel *checkLabel;
@property (nonatomic, strong) UIView *checkView;

@property (nonatomic, strong) NSObject<FSWatchlistItemProtocol> *watchlistItem;

@property (nonatomic, weak)  UIViewController<UIPageViewControllerDataSource> *pagerViewController;

@property (nonatomic, strong) UITableView *actionTableView;
@end

@implementation FSWatchlistViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    
    stretchableBlueButton = [[UIImage imageNamed:@"blueDetailButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 15)];
    stretchableLightBlueButton = [[UIImage imageNamed:@"發亮藍色按鍵-88"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
    grayButton = [[UIImage imageNamed:@"grayButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 180, 130)];
    
    [self setUpImageBackButton];
    alertDict = [[NSMutableDictionary alloc]init];
    self.alertDataDict = [[NSMutableDictionary alloc]init];
    self.cancelAlertDataDict = [[NSMutableDictionary alloc]init];
    self.cancelAlertDataArray = [[NSArray alloc]init];
    watchPage = YES;
    self.title =NSLocalizedStringFromTable(@"自選分析", @"watchlists", nil);
    
    [self initSort];
    
    //加回江波圖復原以下註解
    //[self initPageControll];
    
    [self initView];
    self.pagerViewController.navigationItem.title = NSLocalizedStringFromTable(@"自選分析", @"watchlists", @"");
    
    [self setupNecessaryArrays];

    [self addNameHeader];
    [self addAttributeHeader];
    [self addVolumeHeader];
    [self addSettingButton];
    [self addChangeGroupButton];
    
    self.cellRenderQueue = [[NSOperationQueue alloc] init];
    
    //單量暫存值
	self.singleVolumeDictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    if (_watchlistTableView == nil) {
        [self addTableView];
        [self.watchlistTableView registerClass:[FSWatchlistTableCell class] forCellReuseIdentifier:@"FSWatchlistTableCell"];
        
    }
    
    [self setLayout];
    [self alertTimer];
    [super viewDidLoad];
}

- (void)initPageControll {
    self.pageControl = [[DDPageControl alloc] init];
    self.pageControl.numberOfPages = PAGESIZE;
    self.pageControl.currentPage = 0;
    
    if (PAGESIZE == 1) {
        [self.pageControl setHidden:YES];
    }
    
    [self.pageControl setDefersCurrentPageDisplay: YES] ;
	[self.pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
	[self.pageControl setOnColor: [UIColor redColor]];
	[self.pageControl setOffColor: [UIColor redColor]];
	[self.pageControl setIndicatorDiameter: 7.0f] ;
	[self.pageControl setIndicatorSpace: 7.0f] ;
    
    [self.view addSubview:self.pageControl];
}


-(void)initView
{
    self.topView = [[UIView alloc] init];
    _topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_topView];
    
    //加回江波圖復原以下註解
    //self.rightView = [[UIView alloc] initWithFrame:self.view.frame];
    
    
    self.leftView = [[UIView alloc] initWithFrame:self.view.frame];
    
    //加回江波圖復原以下註解
//    FSMultiChartViewFlowLayout *gridLayout = [[FSMultiChartViewFlowLayout alloc] init];
//    self.multiChartViewController = [[FSMultiChartViewController alloc] initWithCollectionViewLayout:gridLayout];
//    
//    [self addChildViewController:self.multiChartViewController];
    
    //加回江波圖復原以下註解
    //[self.rightView addSubview:_multiChartViewController.view];
    
    self.scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    //加回江波圖復原以下註解
    //[self.scrollView addSubview:_rightView];
    
    [self.scrollView addSubview:_leftView];
    [self.view addSubview:_scrollView];
    
}

-(void)initGroup
{
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"WatchListGroupTitleMemory.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    if(_mainDict){
        self.currentSelectedHeader = [(NSNumber *)[_mainDict objectForKey:@"GroupNumber"]intValue];
    } else {
        self.currentSelectedHeader = 0;
    }
    
    NSMutableString *title = [NSMutableString string];
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    for (NSUInteger counter=0+self.currentSelectedHeader*3; counter < 3+self.currentSelectedHeader*3; counter++) {
        if(self.currentSelectedHeader == 2) {
            if ([group isEqualToString:@"cn"]) {
                [title appendString:@"  "];
            }else{
                [title appendString:@"  "];
            }
            
            [title appendString:NSLocalizedStringFromTable(self.dynamicHeaderArray[counter], @"watchlists", @"")];
            [title appendString:@"   "];
        }else{
            [title appendString:@"  "];
            [title appendString:NSLocalizedStringFromTable(self.dynamicHeaderArray[counter], @"watchlists", @"")];
            [title appendString:@"   "];
        }
    }
    [self.attributeHeader setTitle:title forState:UIControlStateNormal];
    
}

-(void)initSort
{
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"WatchListSortMemory.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    if(_mainDict){
        [self sortPortfolioItemBySortingIndex:[(NSNumber *)[_mainDict objectForKey:@"SortNumber"]intValue]];
        _selectSortSheetIndex  = [(NSNumber *)[_mainDict objectForKey:@"SortNumber"]intValue];
        [_watchlistTableView reloadData];
        [_multiChartViewController.collectionView reloadData];
        sortFlag = [[_mainDict objectForKey:@"Check"]boolValue];
    }else{
        _selectSortSheetIndex = 0;
        [self dismissSortingPopoverAndReloadData];
    }
    selectRow = (int)_selectSortSheetIndex;
}

- (void)setWatchListMode:(BOOL)setMode {
    if (setMode) {
        
        int count = (int)[_watchlistItem count];
        
        NSMutableArray *identCodeSymbols = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++) {
            PortfolioItem *portfolioItem = [_watchlistItem portfolioItemAtIndex:i];
            [identCodeSymbols addObject:portfolioItem.getIdentCodeSymbol];
        }
        
        Portfolio *portfolio = [[FSDataModelProc sharedInstance] portfolioData];
        [portfolio addWatchListItemByIdentSymbolArray:identCodeSymbols];
    }
    
    else {
        int count = (int)[_watchlistItem count];
        
        NSMutableArray *identCodeSymbols = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++) {
            PortfolioItem *portfolioItem = [_watchlistItem portfolioItemAtIndex:i];
            [identCodeSymbols addObject:portfolioItem.getIdentCodeSymbol];
        }
        
        Portfolio *portfolio = [[FSDataModelProc sharedInstance] portfolioData];
        [portfolio removeWatchListItemByIdentSymbolArray];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.dataModal = [FSDataModelProc sharedInstance];
    [self.dataModal.watchlists updataWatchlists];
    
    self.navigationController.navigationBarHidden = NO;
    //如果沒有塞任何Item來顯示，用預設Item
    
    if (_watchlistItem == nil) {
        self.watchlistItem = [[FSWatchlistPortfolioItem alloc] init];
        
        //[_watchlistTableView reloadData];
    }
    //[self initSort];
    
    
    if (rowNumber != [_watchlistItem count]) {
        [_watchlistTableView reloadData];
        [_multiChartViewController updatePlotDataSource];
        [_multiChartViewController.collectionView reloadData];
    }
    
//    [self addEditBarButtonItem];
    
//    [self loadRecentWatchsIndexFromUserDefault];
//    [self.view updateConstraintsIfNeeded];
    //[self registerAlertNotification];
//
//    [self initSort];
//    self.alertDataArray = [[[FSDataModelProc sharedInstance]alert] checkAlertData];

    [self showAlert];

//    [_watchlistTableView reloadData];
    [self changeReloadName];
    
   // self.selectPickerIndex = buttonIndex;
//    [self dismissGroupPopoverAndReloadData2];

#ifdef LPCB
    [self registerLoginNotificationCallBack:self seletor:@selector(setWatchListMode:)];
    [self setWatchListMode:YES];
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unregisterLoginNotificationCallBack:self];
    rowNumber = (int)[_watchlistItem count];
    [self cancelObserving];
    [self cancelAllAlert];
    [self unregisterAlertNotification];
    
#ifdef LPCB
    [self setWatchListMode:NO];
#endif
    
    [super viewWillDisappear:animated];
}

#pragma mark - AlertNotification

- (void)registerAlertNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertNotification:) name:@"alertNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAlertNotification:) name:@"cancelAlertNotification" object:nil];
    
}

- (void)unregisterAlertNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"alertNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cancelAlertNotification" object:nil];
}

-(void)cancelAllAlert{
    for (int i=0; i<[_watchlistItem count]; i++) {
        PortfolioItem * portfolioItem = [_watchlistItem portfolioItemAtIndex:i];
        portfolioItem->alertState = 0;
    }
}


//-(void)showAlert{
//    BOOL statusChange = NO;
//    NSMutableArray * changeArray = [[NSMutableArray alloc]init];
//    for (int i=0; i<[_watchlistItem count]; i++) {
//        PortfolioItem * portfolioItem = [_watchlistItem portfolioItemAtIndex:i];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:
//                                  @"SELF.identSymbol == %@", [portfolioItem getIdentCodeSymbol]];
//        NSArray *filteredArray = [_alertDataArray filteredArrayUsingPredicate:predicate];
//        if ([filteredArray count] > 0) {
//            /*
//             如果有多個警示條件符合的話，只根據最後那個秀狀態就好
//             */
//            AlertParam *param = [filteredArray lastObject];
//            [changeArray addObject:param->identSymbol];
//            if (param->alertID == profitAlert) {
//                //watchlistCell.nameLabel.backgroundColor = [StockConstant PriceUpColor];
//                if (portfolioItem->alertState != 1) {
//                    portfolioItem->alertState = 1;
//                    statusChange = YES;
//                }
//                
//            }
//            else if (param->alertID == lostAlert) {
//                //watchlistCell.nameLabel.backgroundColor = [StockConstant PriceDownColor];
//                if (portfolioItem->alertState != 2) {
//                    portfolioItem->alertState = 2;
//                    statusChange = YES;
//                }
//                
//            }
//            
//        }
//        
//    }
//    if (statusChange) {
//        NSLog(@"alert");
//        //[_watchlistTableView reloadData];
//        [self alertReloadTableWithArrray:changeArray];
//    }
//
//}

-(void)showAlert{
    BOOL statusChange = NO;
    NSMutableArray * changeArray = [[NSMutableArray alloc]init];
    for (int i=0; i<[_watchlistItem count]; i++) {
        PortfolioItem * portfolioItem = [_watchlistItem portfolioItemAtIndex:i];
        
        FSActionPlan * actionPlan = [_alertDataDict objectForKey:[portfolioItem getIdentCodeSymbol]];
        [changeArray addObject:[portfolioItem getIdentCodeSymbol]];
        if (actionPlan) {
            if ([actionPlan.longShortType isEqualToString:@"Long"]) {
                if (actionPlan.last >= actionPlan.buySP && (actionPlan.target != 0 || actionPlan.cost != 0)) {
                    if (portfolioItem->alertState != 1) {
                        portfolioItem->alertState = 1;
                        statusChange = YES;
                    }
                }
                else if (actionPlan.last < actionPlan.buySL && (actionPlan.target != 0 || actionPlan.cost != 0)) {
                    if (portfolioItem->alertState != 2) {
                        portfolioItem->alertState = 2;
                        statusChange = YES;
                    }
                }
            }else if ([actionPlan.longShortType isEqualToString:@"Short"]){
                if (actionPlan.last < actionPlan.buySP && (actionPlan.target != 0 || actionPlan.cost != 0)) {
                    if (portfolioItem->alertState != 1) {
                        portfolioItem->alertState = 1;
                        statusChange = YES;
                    }
                }
                else if (actionPlan.last >= actionPlan.buySL && (actionPlan.target != 0 || actionPlan.cost != 0)) {
                    if (portfolioItem->alertState != 2) {
                        portfolioItem->alertState = 2;
                        statusChange = YES;
                    }
                }
            }
        }
    }
    if (statusChange) {
        NSLog(@"alert");
        //[_watchlistTableView reloadData];
        [self alertReloadTableWithArrray:changeArray];
    }
    
}

- (void)showAlertNotification:(NSNotification *)notification {
    
    //取得由NSNotificationCenter送來的訊息
//    self.alertDataArray = [notification object];
    self.alertDataDict = [notification object];
    //只更新目前看得到的cells
    //[_watchlistTableView reloadRowsAtIndexPaths:[_watchlistTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self showAlert];
    //[_watchlistTableView reloadData];
}

//- (void)cancelAlertNotification:(NSNotification *)notification {
//    BOOL statusChange = NO;
//    //取得由NSNotificationCenter送來需要關閉警示的訊息
//    self.cancelAlertDataArray = [notification object];
//    NSMutableArray * changeArray = [[NSMutableArray alloc]init];
//    for (int i=0; i<[_watchlistItem count]; i++) {
//        PortfolioItem * portfolioItem = [_watchlistItem portfolioItemAtIndex:i];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:
//                                  @"SELF.identSymbol == %@", [portfolioItem getIdentCodeSymbol]];
//        NSArray *cancelAlertArray = [_cancelAlertDataArray filteredArrayUsingPredicate:predicate];
//        if ([cancelAlertArray count] > 0) {
//            AlertParam *param = [cancelAlertArray lastObject];
//            [changeArray addObject:param->identSymbol];
//            if (param->alertID == profitAlert) {
//                if (portfolioItem->alertState == 1) {
//                    portfolioItem->alertState = 0;
//                    statusChange = YES;
//                }
//            }
//            else if (param->alertID == lostAlert) {
//                if (portfolioItem->alertState == 2) {
//                    portfolioItem->alertState = 0;
//                    statusChange = YES;
//                }
//            }
//            
//        }
//        
//    }
//    if (statusChange) {
//        NSLog(@"cancel Alert");
////        [_watchlistTableView reloadRowsAtIndexPaths:[_watchlistTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
////        [_watchlistTableView reloadData];
//        [self alertReloadTableWithArrray:changeArray];
//    }
//    
//    
//}

- (void)cancelAlertNotification:(NSNotification *)notification {
    BOOL statusChange = NO;
    //取得由NSNotificationCenter送來需要關閉警示的訊息
    self.cancelAlertDataDict = [notification object];
    NSMutableArray * changeArray = [[NSMutableArray alloc]init];
    for (int i=0; i<[_watchlistItem count]; i++) {
        PortfolioItem * portfolioItem = [_watchlistItem portfolioItemAtIndex:i];
        
        FSActionPlan * actionPlan = [_cancelAlertDataDict objectForKey:[portfolioItem getIdentCodeSymbol]];
        [changeArray addObject:[portfolioItem getIdentCodeSymbol]];

        if (actionPlan) {
            
            if ([actionPlan.longShortType isEqualToString:@"Long"]) {
                if (actionPlan.last < actionPlan.buySP) {
                    if (portfolioItem->alertState == 1) {
                        portfolioItem->alertState = 0;
                        statusChange = YES;
                    }
                    
                }
                else if (actionPlan.last >= actionPlan.buySL) {
                    if (portfolioItem->alertState == 2) {
                        portfolioItem->alertState = 0;
                        statusChange = YES;
                    }
                    
                }
            }else if ([actionPlan.longShortType isEqualToString:@"Short"]){
                if (actionPlan.last >= actionPlan.buySP) {
                    if (portfolioItem->alertState == 1) {
                        portfolioItem->alertState = 0;
                        statusChange = YES;
                    }
                    
                }
                else if (actionPlan.last < actionPlan.buySL) {
                    if (portfolioItem->alertState == 2) {
                        portfolioItem->alertState = 0;
                        statusChange = YES;
                    }
                    
                }
            }
            
            
        }
        
    }
    if (statusChange) {
        NSLog(@"cancel Alert");
        //        [_watchlistTableView reloadRowsAtIndexPaths:[_watchlistTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
        //        [_watchlistTableView reloadData];
        [self alertReloadTableWithArrray:changeArray];
    }
    
    
}


-(void)alertReloadTableWithArrray:(NSMutableArray *)array{
    NSArray *indexPathArray = [_watchlistTableView indexPathsForVisibleRows];
    
    for (int i=0; i<[array count]; i++) {
        NSString * identCodeSymbol = [array objectAtIndex:i];
        for(NSIndexPath *indexPath in indexPathArray)
        {
            NSString *idsymbol = nil;
            PortfolioItem *portfolioItem = [_watchlistItem portfolioItem:indexPath];
            if(portfolioItem)
            {
                idsymbol = [NSString stringWithFormat:@"%c%c %@",portfolioItem->identCode[0],portfolioItem->identCode[1],portfolioItem->symbol];
            }
            
            if(idsymbol)
            {
                if([idsymbol isEqualToString:identCodeSymbol])
                {
                    [_watchlistTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    break;
                }
            }
        }
    }
}


#pragma mark - RecentWatchIndex

- (void)loadRecentWatchsIndexFromUserDefault
{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSNumber *groupIndex = [userDefaults objectForKey:@"defaultWatchGroupIndex"];
//    self.recentWatchsIndex = [groupIndex integerValue];
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"WatchListGroupMemory.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if(self.mainDict){
        _selectPickerIndex = [(NSNumber *)[_mainDict objectForKey:@"UserGroupNum"]intValue];
    }else{
        _selectPickerIndex = _recentWatchsIndex;
	}
	[self dismissGroupPopoverAndReloadData2];
    
//    WatchGroup *currentWatchGroup = [[DataModalProc getDataModal].watchlists getWatchGroupWithWatchGroupIndex:_recentWatchsIndex];
//    int groupID = currentWatchGroup.groupID; //群組ID
//    [[DataModalProc getDataModal].portfolioData selectGroupID:_recentWatchsIndex];
//    [_watchlistTableView reloadData];
}

#pragma mark - RecentSortIndex

- (void)sortTableWithRecentSortIndex
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *sortingHeaderIndex = [userDefaults objectForKey:@"sortingHeaderIndex"];
    if (sortingHeaderIndex != nil) {
        [self sortPortfolioItemBySortingIndex:[sortingHeaderIndex integerValue]];
    }
    
}

#pragma mark - UI Init

- (void)addEditBarButtonItem
{
    if ([_watchlistItem editable:_recentWatchsIndex]) {
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"編輯" style:UIBarButtonItemStyleBordered handler:^(UIBarButtonItem *sender) {
//            
//        }];
        UIBarButtonItem *editItem = self.editButtonItem;
        editItem = [[UIBarButtonItem alloc]initWithTitle:editItem.title style:UIBarButtonItemStylePlain target:editItem.target action:editItem.action];
        self.pagerViewController.navigationItem.rightBarButtonItem = editItem;
    }
    else {
        
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"GearButton_White"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(settingTapped) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *accountSettingBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        self.pagerViewController.navigationItem.rightBarButtonItem = accountSettingBarButton;
    }
}

- (void)addSettingButton
{
    self.settingButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    _settingButton.translatesAutoresizingMaskIntoConstraints = NO;
//    UIImage *image = [[UIImage imageNamed:@"gearButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(5,5,5,5)];
    [_settingButton setImage:[UIImage imageNamed:@"GearButton_White"] forState:UIControlStateNormal];
    _settingButton.imageEdgeInsets = UIEdgeInsetsMake(10,10,10,10);
    [_settingButton addTarget:self action:@selector(settingTapped) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_settingButton];
}

-(void)settingTapped
{
    FSActionPlanSettingViewController * stockSettingView = [[FSActionPlanSettingViewController alloc]init];
    [self.navigationController pushViewController:stockSettingView animated:NO];
}

- (void)addChangeGroupButton
{
    self.changeGroupButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    _changeGroupButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_changeGroupButton setTitle:NSLocalizedStringFromTable(@"All", @"watchlists", nil) forState:UIControlStateNormal];
    [_changeGroupButton addTarget:self action:@selector(changeStock:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_changeGroupButton];
}

- (void)addTableView
{
    self.watchlistTableView = [[UITableView alloc] init];
    _watchlistTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _watchlistTableView.dataSource = self;
    _watchlistTableView.delegate = self;
    self.watchlistTableView.bounces =NO;
    [_leftView addSubview:_watchlistTableView];
}

- (void)addNameHeader
{
    self.nameHeader = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    _nameHeader.translatesAutoresizingMaskIntoConstraints = NO;
    [_nameHeader setTitle:NSLocalizedStringFromTable(@"Symbol", @"watchlists", nil) forState:UIControlStateNormal];

    _nameHeader.userInteractionEnabled = NO;
    [_leftView addSubview:_nameHeader];
}

- (void)addAttributeHeader
{
    self.attributeHeader = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    _attributeHeader.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self initGroup];
    /*
     讓上方中間的動態header能夠按一下換一組header名稱
     dynamicHeaderArray裡面裝了全部的header名稱
     按一下以三個一組為單位置換
     */
    [_attributeHeader addTarget:self action:@selector(attributeHeaderClick) forControlEvents:UIControlEventTouchUpInside];
    [_leftView addSubview:_attributeHeader];
}

-(void)attributeHeaderClick{
    [self changeHeaderTitle];
    [self.watchlistTableView reloadRowsAtIndexPaths:[self.watchlistTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addVolumeHeader
{
    self.volumeHeader = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
//    [self.volumeHeader setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.volumeHeader setBackgroundImage:stretchableBlueButton forState:UIControlStateNormal];
//    [self.volumeHeader setBackgroundImage:stretchableLightBlueButton forState:UIControlStateHighlighted];
//    [self.volumeHeader setBackgroundImage:stretchableLightBlueButton forState:UIControlStateSelected];
    if(!sortFlag){
        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID:(int)_recentWatchsIndex];
        [self.volumeHeader setBackgroundImage:grayButton forState:UIControlStateNormal];
        [self.volumeHeader setTitleColor:[UIColor colorWithRed:8.0/255.0 green:55.0/255.0 blue:138.0/255.0 alpha:1] forState:UIControlStateNormal];
    }else{
        [self.volumeHeader setBackgroundImage:stretchableBlueButton forState:UIControlStateNormal];
        [self.volumeHeader setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    _volumeHeader.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _volumeHeader.translatesAutoresizingMaskIntoConstraints = NO;
    _volumeHeader.titleLabel.adjustsFontSizeToFitWidth = YES;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *sortingHeaderIndex = [userDefaults objectForKey:@"sortingHeaderIndex"];
    //尚未使用過sort功能
    if (sortingHeaderIndex == nil) {
        [_volumeHeader setTitle:NSLocalizedStringFromTable(@"VolT", @"watchlists", @"") forState:UIControlStateNormal];
    }
    //已使用過sort功能，讀取上次的選項
    else {
        NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"WatchListSortMemory.plist"]];
        self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        
        if(_mainDict){
            [_volumeHeader setTitle:self.sortButtonTitleArray[[(NSNumber *)[_mainDict objectForKey:@"SortNumber"]intValue]] forState:UIControlStateNormal];
        }else{
            [_volumeHeader setTitle:self.sortButtonTitleArray[[sortingHeaderIndex integerValue]] forState:UIControlStateNormal];
        }
    }
    [_volumeHeader setTitle:[NSString stringWithFormat:@"%@", self.sortButtonTitleArray[[sortingHeaderIndex integerValue]]] forState:UIControlStateNormal];
    
    [_volumeHeader addTarget:self action:@selector(volumeHeaderClick) forControlEvents:UIControlEventTouchUpInside];
    [_leftView addSubview:_volumeHeader];
}

-(void)volumeHeaderClick{
    [self sortItems:self.volumeHeader];
}

- (void)setupNecessaryArrays
{
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        self.dynamicHeaderArray = @[@"Bid", @"Ask", @"Last Price2", @"High", @"Low", @"Change", @"Last Price2", @"Change", @"accumulatedVolume"];
        self.headerSymbolArrayForGetValue = @[@"bid", @"ask", @"price", @"highestPrice", @"lowestPrice", @"chg",@"price", @"chg", @"accumulatedVolume"];
    }
    
    else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        self.dynamicHeaderArray = @[@"Bid", @"Ask", @"Last Price", @"High", @"Low", @"Change", @"Last Price", @"Change", @"Volume"];
        self.headerSymbolArrayForGetValue = @[@"bid", @"ask", @"price", @"highestPrice", @"lowestPrice", @"chg",@"price", @"chg", @"volume"];
    }
    else {
        self.dynamicHeaderArray = @[@"Last$", @"Change", @"Volume", @"High", @"Low", @"Change"];
        self.headerSymbolArrayForGetValue = @[@"price", @"chg", @"volume", @"highestPrice", @"lowestPrice", @"chg"];
    }
    
    if([[[FSFonestock sharedInstance].appId substringToIndex:2]isEqualToString:@"tw"]){
        self.sortButtonTitleArray = @[NSLocalizedStringFromTable(@"VolT", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Vols", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Vol%", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Up", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Rise", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Fall", @"watchlists", nil),
                                      //NSLocalizedStringFromTable(@"Down", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Amp", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Last Price", @"watchlists", nil)
                                      ];
        self.sortAttributeArray = @[NSLocalizedStringFromTable(@"Today's Volume", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"Volume Per 20 Sec", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"VolT/VolY", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"Up Price $", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"Rise %", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"Fall %", @"watchlists", nil),
                                   // NSLocalizedStringFromTable(@"Down Price $", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"Amplitude", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"Last Price", @"watchlists", nil)
                                    ];
    }else{
        self.sortButtonTitleArray = @[NSLocalizedStringFromTable(@"VolT", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Vol%", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Up Price $", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Down Price $", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Rise", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Fall", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"Amp", @"watchlists", nil),
                                      NSLocalizedStringFromTable(@"LastBtn", @"watchlists", nil)
                                      ];
        self.sortAttributeArray = @[NSLocalizedStringFromTable(@"Today's Volume", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"VolT/VolY", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"Up Price $", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"Down Price $", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"Rise %", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"Fall %", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"Amplitude", @"watchlists", nil),
                                    NSLocalizedStringFromTable(@"Last Price", @"watchlists", nil)
                                    ];
    }
    
}

#pragma mark - Action

- (void)changeHeaderTitle
{
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"WatchListGroupTitleMemory.plist"]];
    self.currentSelectedHeader++;
    
    
    if (self.currentSelectedHeader >= [_dynamicHeaderArray count] / 3) {
        _currentSelectedHeader = 0;
    }
    
    self.mainDict = [[NSMutableDictionary alloc] init];
    [self.mainDict setObject:[NSNumber numberWithInteger:_currentSelectedHeader] forKey:@"GroupNumber"];
    [self.mainDict writeToFile:path atomically:YES];
    NSMutableString *title = [NSMutableString string];
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    for (NSUInteger counter=0+self.currentSelectedHeader*3; counter < 3+self.currentSelectedHeader*3; counter++) {
        if(self.currentSelectedHeader == 2) {
            if ([group isEqualToString:@"cn"]) {
                [title appendString:@"  "];
            }else{
                [title appendString:@"  "];
            }
            
            [title appendString:NSLocalizedStringFromTable(self.dynamicHeaderArray[counter], @"watchlists", @"")];
            [title appendString:@"   "];
        }else{
            [title appendString:@"  "];
            [title appendString:NSLocalizedStringFromTable(self.dynamicHeaderArray[counter], @"watchlists", @"")];
            [title appendString:@"   "];
        }
    }
    [self.attributeHeader setTitle:title forState:UIControlStateNormal];
}

- (void)addButtonClicked
{
   
}

#pragma mark - Tell model What to do

-(void)observePortfolios
{
//    [self addTmpStock];
    [self startWatch];
    
}

-(void)cancelObserving
{
    [self stopWatch];
//	[self delTmpStock];
    [_cellRenderQueue cancelAllOperations];
}

- (void)addTmpStock
{
    //	scrollFlag = NO;
	NSMutableArray *isArray = [[NSMutableArray alloc] init];
	NSMutableArray *pathArray = [NSMutableArray arrayWithArray:[_watchlistTableView indexPathsForVisibleRows]];
    
    int count = (int)[_watchlistItem count];
    if([pathArray count] <= 0 && count > 0)		//table 還沒reload 可是有東西了
    {
        int max = count > 10 ? 10 : count;
        for(int i=0 ; i<max ; i++)
        {
            [pathArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    for(NSIndexPath *indexPath in pathArray)
    {
        if(indexPath.row >= count)
            break;
        
        PortfolioItem *portfolioItem = [_watchlistItem portfolioItem:indexPath];
        if(portfolioItem)
        {
            NSString *idSymbol = [NSString stringWithFormat:@"%c%c %@",portfolioItem->identCode[0],portfolioItem->identCode[1],portfolioItem->symbol];
            [isArray addObject:idSymbol];
        }
    }
    [[[FSDataModelProc sharedInstance]portfolioData ]addWatchListItemByIdentSymbolArray:isArray];
}

- (void)delTmpStock
{
	[[[FSDataModelProc sharedInstance]portfolioData ]removeWatchListItemByIdentSymbolArray];
}

- (void)startWatch
{
    PortfolioTick *tickBank = [[FSDataModelProc sharedInstance]portfolioTickBank];
	[tickBank removeWatch:self];
	
    isWatchingTick = YES;
	NSMutableArray *pathArray = [NSMutableArray arrayWithArray:[_watchlistTableView indexPathsForVisibleRows]];
    
    int count = (int)[_watchlistItem count];
    if([pathArray count] <= 0 && count > 0)		//table 還沒reload 可是有東西了
    {
        int max = count > 10 ? 10 : count;
        for(int i=0 ; i<max ; i++)
        {
            [pathArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    for(NSIndexPath *indexPath in pathArray)
    {
        if(indexPath.row >= count)
            break;
        
        PortfolioItem *portfolioItem = [_watchlistItem portfolioItem:indexPath];
        if(portfolioItem)
        {
            NSString *icSymbol = [NSString stringWithFormat:@"%c%c %@",portfolioItem->identCode[0],portfolioItem->identCode[1],portfolioItem->symbol];
            [tickBank watchTarget:self ForEquity:icSymbol];
            
        }
        
    }
    //[self initSort];
}

- (void)stopWatch
{
    isWatchingTick = NO;
    PortfolioTick *tickBank = [[FSDataModelProc sharedInstance]portfolioTickBank];
	[tickBank removeWatch:self];
}

#pragma mark - Data Occur

- (void)notifyDataArrive:(NSObject <TickDataSourceProtocol> *)dataSource
{
	
	if(self.editing)
		return;
    
    /*
     當離開畫面之後，即使已經removeWatch:self，但是data是跑在另外一條thread，所以還是可能有一些tick會送過來。這時我們需要擋住不繼續往下執行，否則
     [_watchlistTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];會錯
     */
    if (!isWatchingTick) {
        return;
    }
    [self initSort];
    //[_watchlistTableView reloadData];
	if([dataSource isKindOfClass:[EquityTick class]])
	{
		EquityTick *eTick = (EquityTick*)dataSource;
		NSArray *indexPathArray = [_watchlistTableView indexPathsForVisibleRows];
		for(NSIndexPath *indexPath in indexPathArray)
		{
			NSString *idsymbol = nil;
            PortfolioItem *portfolioItem = [_watchlistItem portfolioItem:indexPath];
            if(portfolioItem)
            {
                idsymbol = [NSString stringWithFormat:@"%c%c %@",portfolioItem->identCode[0],portfolioItem->identCode[1],portfolioItem->symbol];
            }
            
            if(idsymbol)
			{
				if([idsymbol isEqualToString:eTick.identCodeSymbol])
				{
                    [_watchlistTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
					break;
				}
			}
        }
    }
}


#pragma mark - AutoLayout

- (void)setLayout
{
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_settingButton, _changeGroupButton, _watchlistTableView, _nameHeader, _attributeHeader, _volumeHeader, _scrollView, _topView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topView]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topView(44)][_scrollView]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_changeGroupButton][_settingButton(44)]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nameHeader(64)][_attributeHeader][_volumeHeader(60)]|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewControllers]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_watchlistTableView]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_changeGroupButton(44)][_nameHeader(44)][_watchlistTableView]-20-|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_changeGroupButton(44)][_attributeHeader(44)][_watchlistTableView]-20-|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_settingButton(44)][_volumeHeader(44)][_watchlistTableView]-20-|" options:0 metrics:nil views:viewControllers]];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    
    
    
    //加回江波圖復原以下註解
    //[self.scrollView setContentSize: CGSizeMake(self.scrollView.bounds.size.width * PAGESIZE, self.scrollView.bounds.size.height)];
    [self.scrollView setContentSize: CGSizeMake(self.scrollView.bounds.size.width * 1, self.scrollView.bounds.size.height)];
    
    
    
    //加回江波圖復原以下註解
//    if(watchPage){
//        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * 0, 0);
//    }else{
//        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * 1, 0);
//    }
    //[self.pageControl setCenter:CGPointMake(self.scrollView.center.x, self.view.bounds.size.height - 10)];
    
    [self.leftView setFrame:CGRectMake(self.scrollView.bounds.size.width * 0, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    
    //加回江波圖復原以下註解
    //[self.rightView setFrame:CGRectMake(self.scrollView.bounds.size.width * 1, -25, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    [self observePortfolios];

    [self.view layoutSubviews];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    //加回江波圖復原以下註解
//	CGFloat pageWidth = self.scrollView.bounds.size.width;
//    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
//	NSInteger nearestNumber = lround(fractionalPage);
//	
//	if (self.pageControl.currentPage != nearestNumber) {
//		self.pageControl.currentPage = nearestNumber;
//		if (self.scrollView.dragging) {
//
//			[self.pageControl updateCurrentPageDisplay] ;
//        }
//	}
//    if(self.pageControl.currentPage == 0){
//        watchPage = YES;
//    }else {
//        watchPage = NO;
//    }
}

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView {
//    
//	[self.pageControl updateCurrentPageDisplay] ;
//}

#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:_watchlistTableView]){
        return [_watchlistItem count];
    }else{
        return [_sortAttributeArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:_watchlistTableView]){
        FSWatchlistTableCell *cell = (FSWatchlistTableCell *) [_watchlistTableView dequeueReusableCellWithIdentifier:@"FSWatchlistTableCell" forIndexPath:indexPath];
        if(cell == nil){
            cell = [[FSWatchlistTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FSWatchlistTableCell"];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        //顯示股名
        cell.nameLabel.text = [_watchlistItem name:indexPath];
//            cell.nameLabel.backgroundColor = [_watchlistItem alertStatus:indexPath];
        PortfolioItem *item = [_watchlistItem portfolioItem:indexPath];
        cell.identCodeSymbol = [item getIdentCodeSymbol];
        if (item->alertState==1) {
            [UIView animateWithDuration:1.0
                                  delay:0
                                options:UIViewAnimationOptionRepeat
                             animations:^{
                                 cell.nameLabel.layer.backgroundColor = [StockConstant PriceUpColor].CGColor;
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:1.0
                                                       delay:0
                                                     options:UIViewAnimationOptionRepeat
                                                  animations:^{
                                                      cell.nameLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
                                                  }
                                                  completion:^(BOOL finished) {
                                                  }];
                             }];
        }else if (item->alertState==2){
            [UIView animateWithDuration:1.0
                                  delay:0
                                options:UIViewAnimationOptionRepeat
                             animations:^{
                                 cell.nameLabel.layer.backgroundColor = [StockConstant PriceDownColor].CGColor;
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:1.0
                                                       delay:0
                                                     options:UIViewAnimationOptionRepeat
                                                  animations:^{
                                                      cell.nameLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
                                                  }
                                                  completion:^(BOOL finished) {
                                                  }];
                             }];
        }else{
            [cell.nameLabel.layer removeAllAnimations];
            cell.nameLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
        }
        
        //顯示三個動態欄位
        [self showDynamicLabel:@[cell.dynamicLabel0, cell.dynamicLabel1, cell.dynamicLabel2] indexPath:indexPath];
        
        //顯示總量
        //cell.volumeLabel.text = @"----";
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSNumber *sortingHeaderIndex = [userDefaults objectForKey:@"sortingHeaderIndex"];
        if (sortingHeaderIndex != nil) {
            [self showDynamicLabelTwo:cell.volumeLabel indexPath:indexPath sortIndex:[sortingHeaderIndex integerValue]];
        }
        else {
            //None
            [self showDynamicLabelTwo:cell.volumeLabel indexPath:indexPath sortIndex:9];
        }
        return cell;
    }else{
        static NSString *CellIdentifier = @"CellIdentifier";
        RadioTableViewCell *cell = (RadioTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[RadioTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
//        cell.titleLabel.text = [NSString stringWithFormat:@"    %@",[_sortAttributeArray objectAtIndex:indexPath.row]];
        cell.textLabel.text = [NSString stringWithFormat:@"    %@",[_sortAttributeArray objectAtIndex:indexPath.row]];
        if(indexPath.row == selectRow){
//            cell.checkBtn.selected = YES;
            radioImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RadioButtonYES"]];
        }else{
            radioImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RadioButtonNO"]];
        }
        radioImageView.frame = CGRectMake(0, 0, 22, 22);
        cell.accessoryView = radioImageView;
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark TableView Delegate


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

//    NSString *identCodeSymbol = [[_watchlistItem portfolioItem:indexPath] getIdentCodeSymbol];
    
//    NSLog(@"---->   %@", identCodeSymbol);
//    PortfolioItem * portfolioItem = [_watchlistItem portfolioItem:indexPath];
//    //找出符合條件的物件
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:
//                              @"SELF.identSymbol == %@", identCodeSymbol];
//    NSArray *filteredArray = [_alertDataArray filteredArrayUsingPredicate:predicate];
//    NSArray * cancelAlertArray = [_cancelAlertDataArray filteredArrayUsingPredicate:predicate];
//    FSWatchlistTableCell *watchlistCell = (FSWatchlistTableCell *) cell;
//    if ([filteredArray count] > 0) {
//        /*
//         如果有多個警示條件符合的話，只根據最後那個秀狀態就好
//         */
//        AlertLogParam *param = [filteredArray lastObject];
//        
//        if (param->alertID == -6) {
//            //watchlistCell.nameLabel.backgroundColor = [StockConstant PriceUpColor];
//            portfolioItem->alertState = 1;
//        }
//        else if (param->alertID == -7) {
//            //watchlistCell.nameLabel.backgroundColor = [StockConstant PriceDownColor];
//            portfolioItem->alertState = 2;
//        }
//        
//    }
////    else {
////        watchlistCell.nameLabel.backgroundColor = [UIColor clearColor];
////    }
//    if ([cancelAlertArray count]>0) {
//        portfolioItem->alertState = 0;
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:_watchlistTableView]){
        FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
        PortfolioItem *portfolioItem = [_watchlistItem portfolioItem:indexPath];
    //    mainViewController.parameter = @{@"equityName": portfolioItem->fullName ,@"watchListRowIndex" : [NSNumber numberWithInteger:0],@"portfolioItem" : portfolioItem ,@"isPushFromWatchListController" : [NSNumber numberWithBool:YES],@"firstLevelMenuOption":[NSNumber numberWithInt:1]};
        //讓FSInstantInfoMainViewController觀察FSInstantInfoWatchedPortfolio，隨時更新portfolioItem
        FSInstantInfoWatchedPortfolio *instantInfoWatchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
            instantInfoWatchedPortfolio.portfolioItem = portfolioItem;
        
        NSString * ids = [NSString stringWithFormat:@"%c%c:%@",portfolioItem->identCode[0],portfolioItem->identCode[1],portfolioItem->symbol];
        
        FSSnapshotQueryOut *snapshotQueryPacket2 = [[FSSnapshotQueryOut alloc] initWithSnapshotTypes:@[@2] identCodeSymbols:@[ids]];
        [FSDataModelProc sendData:self WithPacket:snapshotQueryPacket2];
        
//        FSSnapshotQueryOut *snapshotQueryPacket3 = [[FSSnapshotQueryOut alloc] initWithSnapshotTypes:@[@3] identCodeSymbols:@[ids]];
//        [FSDataModelProc sendData:self WithPacket:snapshotQueryPacket3];
        
        FSSnapshotQueryOut *snapshotQueryPacket4 = [[FSSnapshotQueryOut alloc] initWithSnapshotTypes:@[@4] identCodeSymbols:@[ids]];
        [FSDataModelProc sendData:self WithPacket:snapshotQueryPacket4];
        
        //比較商品一開始預設使用加權指數
    //    NSString *icSymbol = @"US GOOG";
    //    PortfolioItem *comparedPortfolioItem = [[DataModalProc getDataModal].portfolioData findItemByIdentCodeSymbol:icSymbol];
    //    instantInfoWatchedPortfolio.comparedPortfolioItem = comparedPortfolioItem;
        
        [self.navigationController pushViewController:mainViewController animated:NO];
    }else{
        selectRow = (int)indexPath.row;
        [_actionTableView reloadData];
    }
}


#pragma mark - Label Handle

- (void)showDynamicLabel:(NSArray *) labels indexPath:(NSIndexPath *) indexPath
{
    for (UILabel *label in labels) {
        label.textAlignment = NSTextAlignmentCenter;
    }
    UIColor *color = [UIColor blackColor]; //數值顏色
    NSString *textValue = @"----";	//數值string
    UIColor *backgroundColor = [UIColor clearColor]; //label背景色
    
    PortfolioItem *portfolioItem = [_watchlistItem portfolioItem:indexPath];
    if (portfolioItem != nil) {
        PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
            
#ifdef LPCB
        FSSnapshot *snapshot = [tickBank getSnapshotBvalue:portfolioItem->commodityNo];
        if (snapshot) {
            
            for (NSUInteger counter = 0; counter < 3; counter++) {
                
                NSString *headerName = self.headerSymbolArrayForGetValue[counter+self.currentSelectedHeader*3];
                
                if ([headerName isEqualToString:@"price"]) {
                    UIColor *color = [ValueUtil colorOfPrice:snapshot.last_price.value refPrice:snapshot.reference_price.value baseColor:[StockConstant watchListTextColor]];
                    
                    
                    textValue = [self watchlistPriceFormatString:snapshot.last_price.calcValue];
                    
                    if ([textValue isEqualToString:[NSString stringWithFormat:@"%.2f", snapshot.top_price.calcValue]]  && snapshot.top_price.calcValue != 0) {
                        [self updateDataLabel:labels[counter] text:textValue textColor:[UIColor whiteColor] backgroundColor:[StockConstant PriceUpColor]];
                    }else if ([textValue doubleValue] == snapshot.bottom_price.calcValue && snapshot.top_price.calcValue != 0) {
                        [self updateDataLabel:labels[counter] text:textValue textColor:[UIColor whiteColor] backgroundColor:[StockConstant PriceDownColor]];
                    }else{
                        [self updateDataLabel:labels[counter] text:textValue textColor:color backgroundColor:backgroundColor];
                    }
                }
                else if ([headerName isEqualToString:@"chg"]) {

                    if (snapshot.last_price.value != 0 && snapshot.reference_price.value != 0) {
                        
                        double chg = snapshot.last_price.calcValue - snapshot.reference_price.calcValue;
                        
                        if (chg < 0){
                            color = [StockConstant PriceDownColor];
                            textValue = [NSString stringWithFormat:@"%.2lf",chg];
                        } else if (chg > 0){
                            color = [StockConstant PriceUpColor];
                            textValue = [NSString stringWithFormat:@"+%.2lf",chg];
                        } else {
                            color = [StockConstant watchListTextColor];
                            textValue = [NSString stringWithFormat:@"%.2lf",chg];
                        }
                        
                        backgroundColor = [UIColor clearColor];
                    }
                    else {
                        color = [StockConstant watchListTextColor];
                        textValue = @"----";
                        backgroundColor = [UIColor clearColor];
                    }
                    
                    [self updateDataLabel:labels[counter] text:textValue textColor:color backgroundColor:backgroundColor];
                }
                
                // 總量
                else if ([@"accumulatedVolume" isEqualToString:headerName]) {
                    
                    if (snapshot.reference_price.calcValue != 0 && snapshot.accumulated_volume.calcValue != 0) {
                        
                        textValue = [CodingUtil volumeRoundRownWithDouble:snapshot.accumulated_volume.calcValue];
                        
                        backgroundColor = [UIColor clearColor];
                        
                        if (snapshot.outer_price.calcValue > snapshot.inner_price.calcValue) {
                            color = [UIColor darkGrayColor];
                        } else {
                            color = [UIColor orangeColor];
                        }
                    }
                    else {
                        color = [StockConstant watchListTextColor];
                        textValue = @"0";
                        backgroundColor = [UIColor clearColor];
                    }
                    
                    [self updateDataLabel:labels[counter] text:textValue textColor:color backgroundColor:backgroundColor];
                    
                    
                }
                
                // 單量
                else if ([headerName isEqualToString:@"volume"]){
                    
                    if (snapshot.reference_price.value != 0 && snapshot.accumulated_volume.value != 0) {
                        
                        NSString * appid = [FSFonestock sharedInstance].appId;
                        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
                        if ([group isEqualToString:@"us"]) {
                            // 美股用
                            
                            textValue = [CodingUtil volumeRoundRownWithDouble:snapshot.accumulated_volume.calcValue];
                            
                        }else{
                            
                            
                            if (portfolioItem->type_id == 6) {
                                
                                if (snapshot.volume.calcValue != 0) {
                                    textValue =[CodingUtil volumeRoundRownWithDouble:snapshot.volume.calcValue];
                                }
                                else {
                                    
                                    if (snapshot.pre_volume == nil) {
                                        textValue =[CodingUtil volumeRoundRownWithDouble:0];
                                    } else {
                                        textValue =[CodingUtil volumeRoundRownWithDouble:snapshot.deal_volume.calcValue - snapshot.pre_volume.calcValue];
                                    }
                                    
                                    snapshot.pre_volume = snapshot.deal_volume;
                                }
                                
                            } else {
                                
                                
                                textValue = [CodingUtil volumeRoundRownWithDouble:snapshot.volume.calcValue];
                            }
                            
                            
                            
                            
                            
                            if (snapshot.accumulated_volume.calcValue == 0)
                                color = [StockConstant watchListTextColor];
                            else{
                                // 顏色改看內外盤
                                if (snapshot.outer_price.calcValue > snapshot.inner_price.calcValue) {
                                    color = [UIColor darkGrayColor];
                                }
                                else {
                                    color = [UIColor orangeColor];
                                }
//                                if (snapshot.last_price.calcValue == snapshot.bid_price.calcValue) {
//                                    color = [UIColor grayColor];
//                                }else if (snapshot.last_price.calcValue == snapshot.ask_price.calcValue){
//                                    color = [UIColor orangeColor];
//                                }
                            }
                            
                        }
                        backgroundColor = [UIColor clearColor];
                    }
                    else {
                        color = [StockConstant watchListTextColor];
                        textValue = @"0";
                        backgroundColor = [UIColor clearColor];
                    }
                    
                    [self updateDataLabel:labels[counter] text:textValue textColor:color backgroundColor:backgroundColor];
                }
                
                //最高
                else if([headerName isEqualToString:@"highestPrice"]){
                    
                    if (snapshot.last_price.value != 0 && snapshot.reference_price.value != 0) {
                        color = [ValueUtil colorOfPrice:snapshot.high_price.calcValue refPrice:snapshot.reference_price.calcValue baseColor:[StockConstant watchListTextColor]];
                        textValue = [self watchlistPriceFormatString:snapshot.high_price.calcValue];
                        backgroundColor = [UIColor clearColor];
                    }
                    else {
                        color = [StockConstant watchListTextColor];
                        textValue = @"----";
                        backgroundColor = [UIColor clearColor];
                    }
                    
                    if ([textValue isEqualToString:[NSString stringWithFormat:@"%.2f", snapshot.top_price.calcValue]]  && snapshot.top_price.calcValue != 0) {
                        [self updateDataLabel:labels[counter] text:textValue textColor:[UIColor whiteColor] backgroundColor:[StockConstant PriceUpColor]];
                    }else if ([textValue doubleValue] == snapshot.bottom_price.calcValue && snapshot.top_price.calcValue != 0) {
                        [self updateDataLabel:labels[counter] text:textValue textColor:[UIColor whiteColor] backgroundColor:[StockConstant PriceDownColor]];
                    }else{
                        [self updateDataLabel:labels[counter] text:textValue textColor:color backgroundColor:backgroundColor];
                    }
                }
                
                //最低
                else if ([headerName isEqualToString:@"lowestPrice"]){
                    
                    if (snapshot.last_price.value != 0 && snapshot.reference_price.value != 0) {
                        color = [ValueUtil colorOfPrice:snapshot.low_price.calcValue refPrice:snapshot.reference_price.calcValue baseColor:[StockConstant watchListTextColor]];
                        textValue = [self watchlistPriceFormatString:snapshot.low_price.calcValue];
                        backgroundColor = [UIColor clearColor];
                    }
                    else {
                        color = [StockConstant watchListTextColor];
                        textValue = @"----";
                        backgroundColor = [UIColor clearColor];
                    }
                    
                    if ([textValue isEqualToString:[NSString stringWithFormat:@"%.2f", snapshot.top_price.calcValue]]  && snapshot.top_price.calcValue != 0) {
                        [self updateDataLabel:labels[counter] text:textValue textColor:[UIColor whiteColor] backgroundColor:[StockConstant PriceUpColor]];
                    }else if ([textValue doubleValue] == snapshot.bottom_price.calcValue && snapshot.top_price.calcValue != 0) {
                        [self updateDataLabel:labels[counter] text:textValue textColor:[UIColor whiteColor] backgroundColor:[StockConstant PriceDownColor]];
                    }else{
                        [self updateDataLabel:labels[counter] text:textValue textColor:color backgroundColor:backgroundColor];
                    }
                }
                //買價
                else if ([headerName isEqualToString:@"bid"]){
                    
                    if (snapshot.last_price.value != 0 && snapshot.reference_price.value != 0 && portfolioItem->type_id != 6 && portfolioItem->type_id !=3) {
                        color = [ValueUtil colorOfPrice:snapshot.bid_price.calcValue refPrice:snapshot.reference_price.calcValue baseColor:[StockConstant watchListTextColor]];
                        textValue = [self watchlistPriceFormatString:snapshot.bid_price.calcValue];
                        backgroundColor = [UIColor clearColor];
                    }
                    else {
                        color = [StockConstant watchListTextColor];
                        textValue = @"----";
                        backgroundColor = [UIColor clearColor];
                    }
                    
                    if ([textValue isEqualToString:[NSString stringWithFormat:@"%.2f", snapshot.top_price.calcValue]]  && snapshot.top_price.calcValue != 0) {
                        [self updateDataLabel:labels[counter] text:textValue textColor:[UIColor whiteColor] backgroundColor:[StockConstant PriceUpColor]];
                    }else if ([textValue doubleValue] == snapshot.bottom_price.calcValue && snapshot.top_price.calcValue != 0) {
                        [self updateDataLabel:labels[counter] text:textValue textColor:[UIColor whiteColor] backgroundColor:[StockConstant PriceDownColor]];
                    }else{
                        [self updateDataLabel:labels[counter] text:textValue textColor:color backgroundColor:backgroundColor];
                    }
                }
                //賣價
                else if ([headerName isEqualToString:@"ask"]){
                    
                    if (snapshot.last_price.value != 0 && snapshot.reference_price.value != 0 && portfolioItem->type_id != 6 && portfolioItem->type_id !=3) {
                        color = [ValueUtil colorOfPrice:snapshot.ask_price.calcValue refPrice:snapshot.reference_price.calcValue baseColor:[StockConstant watchListTextColor]];
                        textValue = [self watchlistPriceFormatString:snapshot.ask_price.calcValue];
                        backgroundColor = [UIColor clearColor];
                    }
                    else {
                        color = [StockConstant watchListTextColor];
                        textValue = @"----";
                        backgroundColor = [UIColor clearColor];
                    }
                    
                    if ([textValue isEqualToString:[NSString stringWithFormat:@"%.2f", snapshot.top_price.calcValue]] && snapshot.top_price.calcValue != 0) {
                        [self updateDataLabel:labels[counter] text:textValue textColor:[UIColor whiteColor] backgroundColor:[StockConstant PriceUpColor]];
                    }else if ([textValue doubleValue] == snapshot.bottom_price.calcValue && snapshot.top_price.calcValue != 0) {
                        [self updateDataLabel:labels[counter] text:textValue textColor:[UIColor whiteColor] backgroundColor:[StockConstant PriceDownColor]];
                    }else{
                        [self updateDataLabel:labels[counter] text:textValue textColor:color backgroundColor:backgroundColor];
                    }
                }

                // 其它
                else {
                    [self updateDataLabel:labels[counter] text:@"----" textColor:color backgroundColor:backgroundColor];
                }
                
            }
        }
        else {
            for (NSUInteger counter=0; counter < 3; counter++) {
                [self updateDataLabel:labels[counter] text:@"----" textColor:color backgroundColor:backgroundColor];
            }
        }
#else
        EquitySnapshotDecompressed *mySnapshot = [tickBank getSnapshotFromIdentCodeSymbol:[portfolioItem getIdentCodeSymbol]];
        // EquitySnapshotDecompressed *mySnapshot = [tickBank getSnapshot:portfolioItem->commodityNo];
        
        if (mySnapshot != nil) {
            for (NSUInteger counter=0; counter < 3; counter++) {
                [self setTextValue:&textValue Color:&color BackgroundColor:&backgroundColor ByHeaderName:self.headerSymbolArrayForGetValue[counter+self.currentSelectedHeader*3] Snapshot:mySnapshot IdSymbol:[portfolioItem getIdentCodeSymbol]];
                [self updateDataLabel:labels[counter] text:textValue textColor:color backgroundColor:backgroundColor];
                
            }
        }else{
            for (NSUInteger counter=0; counter < 3; counter++) {
                [self updateDataLabel:labels[counter] text:@"----" textColor:color backgroundColor:backgroundColor];
            }
        }

#endif
        
        
        }
    //}]];

}

/**
 *  更新最右邊的欄位，此欄位會根據排序的index而變動值
 *
 *  @param label     被更新的label
 *  @param indexPath table的indexpath
 *  @param sortIndex 排序的index
 */
- (void)showDynamicLabelTwo:(UILabel *) label indexPath:(NSIndexPath *) indexPath sortIndex:(NSInteger) sortIndex
{
    [_cellRenderQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        UIColor *color = [UIColor blackColor]; //數值顏色
        NSString *textValue = @"----";	//數值string
        UIColor *backgroundColor = [UIColor clearColor]; //label背景色
        
        __weak __typeof(&*self)weakSelf = self;
        PortfolioItem *portfolioItem = [_watchlistItem portfolioItem:indexPath];
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        if (portfolioItem != nil) {
            NSString *headerName = nil;
            if([[[FSFonestock sharedInstance].appId substringToIndex:2]isEqualToString:@"tw"]){
                switch (sortIndex) {
                    case 0:
                        //VolA
                        headerName = @"accumulatedVolume";
                        break;
                    case 1:
                        //Volp
                        headerName = @"volume";
                        break;
                    case 2:
                        //Vol%
                        headerName = @"volumeRatio";
                        break;
                    case 3:
                        //Up
                        headerName = @"chg";
                        break;
                    case 4:
                        //Rise
                        headerName = @"p_chg";
                        break;
                    case 5:
                        //Fall
                        headerName = @"p_chg";
                        break;
                    
//                    case 6:
//                        //Down
//                        headerName = @"chg";
//                        break;
                    case 6:
                        //Amp
                        headerName = @"stockAmplitude";
                        break;
                    case 7:
                        //Last
                        headerName = @"price";
                        break;
                        
                    default:
                        
                        break;
                }
            }else{
                switch (sortIndex) {
                    case 0:
                        //VolA
                        headerName = @"accumulatedVolume";
                        break;
                    case 1:
                        //Vol%
                        headerName = @"volumeRatio";
                        break;
                    case 2:
                        //Up
                        headerName = @"chg";
                        break;
                    case 3:
                        //Down
                        headerName = @"chg";
                        break;
                    case 4:
                        //Rise
                        headerName = @"p_chg";
                        break;
                    case 5:
                        //Fall
                        headerName = @"p_chg";
                        break;
                    case 6:
                        //Amp
                        headerName = @"stockAmplitude";
                        break;
                    case 7:
                        //Last
                        headerName = @"price";
                        break;
                        
                    default:
                        
                        break;
                }
            }
            
            PortfolioTick *tickBank = [[FSDataModelProc sharedInstance]portfolioTickBank];
            
            
#ifdef LPCB
            FSSnapshot *lpcbSnapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:[portfolioItem getIdentCodeSymbol]];
            if (lpcbSnapshot != nil) {
                [strongSelf setTextValue2:&textValue Color:&color BackgroundColor:&backgroundColor ByHeaderName:headerName Snapshot:lpcbSnapshot IdSymbol:[portfolioItem getIdentCodeSymbol]];
                [strongSelf updateDataLabel:label text:textValue textColor:color backgroundColor:backgroundColor];
            } else {
                [strongSelf setTextValue2:&textValue Color:&color BackgroundColor:&backgroundColor ByHeaderName:headerName Snapshot:lpcbSnapshot IdSymbol:[portfolioItem getIdentCodeSymbol]];
                [strongSelf updateDataLabel:label text:@"----" textColor:color backgroundColor:backgroundColor];
            }
#else
            EquitySnapshotDecompressed *snapshot = [tickBank getSnapshotFromIdentCodeSymbol:[portfolioItem getIdentCodeSymbol]];
            if (snapshot != nil) {
                [strongSelf setTextValue:&textValue Color:&color BackgroundColor:&backgroundColor ByHeaderName:headerName Snapshot:snapshot IdSymbol:[portfolioItem getIdentCodeSymbol]];
                [strongSelf updateDataLabel:label text:textValue textColor:color backgroundColor:backgroundColor];
            }else{
                [strongSelf setTextValue:&textValue Color:&color BackgroundColor:&backgroundColor ByHeaderName:headerName Snapshot:snapshot IdSymbol:[portfolioItem getIdentCodeSymbol]];
                [strongSelf updateDataLabel:label text:@"----" textColor:color backgroundColor:backgroundColor];
            }
#endif
            
        }
    }]];
}
- (void)setTextValue:(NSString**)textValue Color:(UIColor**)color BackgroundColor:(UIColor**)backgroundColor ByHeaderName:(NSString*)headerName
			Snapshot:(EquitySnapshotDecompressed*)snapshot IdSymbol:(NSString *)idSymbol
{
    //成交價
	if([headerName isEqualToString:@"price"]){
		
		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
		{
            if([idSymbol hasPrefix:@"TW"] && (snapshot.currentPrice == snapshot.ceilingPrice || snapshot.currentPrice == snapshot.floorPrice)){
                *color = [UIColor whiteColor];
            }else{
                *color = [ValueUtil colorOfPrice:snapshot.currentPrice refPrice:snapshot.referencePrice baseColor:[StockConstant watchListTextColor]];
            }
			*textValue = [CodingUtil ConvertPriceValueToString:snapshot.currentPrice withIdSymbol:idSymbol];
			*backgroundColor = [self setPriceLabelBackGroundColorWithPrice:snapshot.currentPrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice];
			
		}
        //		else if (snapshot.currentPrice == 0 && snapshot.referencePrice != 0)
        //		{
        //			*color = [StockConstant watchListTextColor];
        //			*textValue = [CodingUtil ConvertPriceValueToString:snapshot.currentPrice withIdSymbol:idSymbol];
        //			*backgroundColor = [UIColor clearColor];
        //		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
	}
	
	//漲疊
	else if([headerName isEqualToString:@"chg"]){
		
		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
		{
			
			double chg = snapshot.currentPrice - snapshot.referencePrice;
			
			if (chg < 0){
				*color = [StockConstant PriceDownColor];
                *textValue = [NSString stringWithFormat:@"%.2lf",chg];
            }else if (chg > 0){
				*color = [StockConstant PriceUpColor];
                *textValue = [NSString stringWithFormat:@"+%.2lf",chg];
            }else{
				*color = [StockConstant watchListTextColor];
                *textValue = [NSString stringWithFormat:@"%.2lf",chg];
			}
			//*textValue = [[NSNumber numberWithFloat:chg]stringValue];
			
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
	
	//漲跌福
	else if([headerName isEqualToString:@"p_chg"]){
		
		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
		{
			double p_chg = (snapshot.currentPrice - snapshot.referencePrice)/snapshot.referencePrice*100;
			
			if (p_chg < 0){
				*color = [StockConstant PriceDownColor];
                *textValue = [NSString stringWithFormat:@"%.2lf%%",p_chg];
			}else if (p_chg > 0){
				*color = [StockConstant PriceUpColor];
                *textValue = [NSString stringWithFormat:@"+%.2lf%%",p_chg];
            }else{
				*color = [StockConstant watchListTextColor];
                *textValue = [NSString stringWithFormat:@"%.2lf%%",p_chg];
            }
			
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"0.00%";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
	
	//買價
	else if([headerName isEqualToString:@"bid"]){
		
		if (snapshot.bid != 0 && snapshot.referencePrice != 0)
		{
			*color = [ValueUtil colorOfPrice:snapshot.currentPrice refPrice:snapshot.referencePrice baseColor:[StockConstant watchListTextColor]];
			if(snapshot.bid == 0)
				*textValue = @"----";
			else
				*textValue = [CodingUtil ConvertPriceValueToString:snapshot.bid withIdSymbol:idSymbol];
			
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
	
	//賣價
	else if([headerName isEqualToString:@"ask"]){
		
		if (snapshot.ask != 0 && snapshot.referencePrice != 0)
		{
			*color = [ValueUtil colorOfPrice:snapshot.currentPrice refPrice:snapshot.referencePrice baseColor:[StockConstant watchListTextColor]];
			if(snapshot.ask == 0)
				*textValue = @"----";
			else
				*textValue = [CodingUtil ConvertPriceValueToString:snapshot.ask withIdSymbol:idSymbol];
			
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
	
	//總量
	else if([headerName isEqualToString:@"accumulatedVolume"]){
		
		if (snapshot.referencePrice != 0 && snapshot.accumulatedVolume !=0)
		{
			
			int accumulatedVolumeUnit = snapshot.accumulatedVolumeUnit;
			double accumulatedVolume = snapshot.accumulatedVolume  * (pow(1000, accumulatedVolumeUnit)); //總量
			
			if(accumulatedVolume == 0)
				*color = [StockConstant watchListTextColor];
			else
				*color = [UIColor colorWithRed:0.436 green:0.000 blue:0.455 alpha:1.000];
			
           *textValue = [CodingUtil volumeRoundRownWithDouble:accumulatedVolume];
            
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"0";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
	
	//單量
	else if([headerName isEqualToString:@"volume"]){
		double newVolume = round(snapshot.volume * pow(1000,snapshot.volumeUnit));
		double tmpVolume = [(NSNumber *)[[_singleVolumeDictionary objectForKey:idSymbol] objectForKey:@"lastVol"]doubleValue];
		double diffVolume = newVolume - tmpVolume;
		
		/*
         double diffVolume;
         if(fabs(snapshot.volume - snapshot.accumulatedVolume)>0.1)
         diffVolume = round(snapshot.volume * pow(1000,snapshot.volumeUnit));
         else
         diffVolume = round((snapshot.accumulatedVolume - snapshot.previousVolume) * pow(1000,snapshot.volumeUnit));
         */
        
        
        //目前的dictionary裡面沒有這個商品
		if(tmpVolume == 0)
		{
			// init
			if(nil != _singleVolumeDictionary[idSymbol] && _singleVolumeDictionary[idSymbol] != [NSNull null] )
			{
				diffVolume = 0;
				NSMutableDictionary *volDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
												[NSNumber numberWithDouble:newVolume],@"lastVol",
												[NSNumber numberWithDouble:diffVolume],@"diffVol",nil];
				[_singleVolumeDictionary setObject:volDict forKey:idSymbol];
			}
			
            //			NSLog(@"tmpVolume == 0 %@ %.1f",idSymbol,diffVolume);
		}
        //在dictionary裡有找到
		else
		{
			if(diffVolume == 0 || diffVolume < 0)
			{
				diffVolume = [(NSNumber *)[[_singleVolumeDictionary objectForKey:idSymbol] objectForKey:@"diffVol"] doubleValue];
				
                //				NSLog(@"diffVolume == 0 %@ %.1f",idSymbol,diffVolume);
			}
			else if(diffVolume > 0)
			{
				
				NSMutableDictionary *volDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
												[NSNumber numberWithDouble:newVolume],@"lastVol",
												[NSNumber numberWithDouble:diffVolume],@"diffVol",nil];
				[_singleVolumeDictionary setObject:volDict forKey:idSymbol];
				
                //				NSLog(@"diffVolume > 0 %@ %.1f",idSymbol,diffVolume);
				
			}
			
		}
        
        
		//*color = [StockConstant watchListTextColor];
		*color = [UIColor colorWithRed:0.436 green:0.000 blue:0.455 alpha:1.000];
		*textValue = [CodingUtil stringWithVolumeByValue2:diffVolume]; //[CodingUtil ConvertDoubleNoZeroValueToString:diffVolume];
		*backgroundColor = [UIColor clearColor];
		
	}
	
	//最高
	else if([headerName isEqualToString:@"highestPrice"]){
		
		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
		{
			*color = [ValueUtil colorOfPrice:snapshot.highestPrice refPrice:snapshot.referencePrice baseColor:[StockConstant watchListTextColor]];
			*textValue = [CodingUtil ConvertPriceValueToString:snapshot.highestPrice withIdSymbol:idSymbol];
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
	
	//最低
	else if([headerName isEqualToString:@"lowestPrice"]){
		
		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
		{
			*color = [ValueUtil colorOfPrice:snapshot.lowestPrice refPrice:snapshot.referencePrice baseColor:[StockConstant watchListTextColor]];
			*textValue = [CodingUtil ConvertPriceValueToString:snapshot.lowestPrice withIdSymbol:idSymbol];
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
	
	//量比
	else if([headerName isEqualToString:@"volumeRatio"]){
		
		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
		{
			
			int previousVolumeUnit = snapshot.previousVolumeUnit;
			double previousVolume = snapshot.previousVolume  * (pow(1000, previousVolumeUnit)); //昨日總量
			
			int accumulatedVolumeUnit = snapshot.accumulatedVolumeUnit;
			double accumulatedVolume = snapshot.accumulatedVolume  * (pow(1000, accumulatedVolumeUnit)); //總量
			double volumeRatio;
			if(previousVolume == 0 || accumulatedVolume == 0)
				volumeRatio = 0;
			else
				volumeRatio = accumulatedVolume / previousVolume; //量比 ( 今日總量/昨日總量)
			
			*color = [StockConstant watchListTextColor];
			*textValue = [CodingUtil ConvertDoubleNoZeroValueToString:volumeRatio];
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
	
	//振幅
	else if([headerName isEqualToString:@"stockAmplitude"]){
		
		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
		{
			/* 股票振幅就是股票開盤後的當日最高價和最低價之間的差的絕對值與前日收盤價的百分比 */
			double stockAmplitude = fabs(snapshot.highestPrice - snapshot.lowestPrice) / snapshot.referencePrice  * 100; // 振幅 (%)
			
			if (stockAmplitude < 0)
				*color = [StockConstant PriceDownColor];
			else if (stockAmplitude > 0)
				*color = [StockConstant PriceUpColor];
			else
				*color = [StockConstant watchListTextColor];
			*textValue = [NSString stringWithFormat:@"%.2lf%%",stockAmplitude];
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
    else {
        *color = [StockConstant watchListTextColor];
        *textValue = @"----";
        *backgroundColor = [UIColor clearColor];
    }
}


- (void)setTextValue2:(NSString**)textValue Color:(UIColor**)color BackgroundColor:(UIColor**)backgroundColor ByHeaderName:(NSString*)headerName
			Snapshot:(FSSnapshot*)snapshot IdSymbol:(NSString *)idSymbol
{
    //成交價
	if ([headerName isEqualToString:@"price"]) {
		if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0) {
            if (snapshot.last_price.calcValue == snapshot.top_price.calcValue || snapshot.last_price.calcValue == snapshot.bottom_price.calcValue) {
                *color = [UIColor whiteColor];
            }else{
                *color = [ValueUtil colorOfPrice:snapshot.last_price.calcValue refPrice:snapshot.reference_price.calcValue baseColor:[StockConstant watchListTextColor]];
            }
			*textValue = [snapshot.last_price format];
			*backgroundColor = [self setPriceLabelBackGroundColorWithPrice:snapshot.last_price.calcValue ceilingPrice:snapshot.top_price.calcValue floorPrice:snapshot.bottom_price.calcValue];
			
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
	}
	
//	//漲疊
//	else if([headerName isEqualToString:@"chg"]){
//		
//		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
//		{
//			
//			double chg = snapshot.currentPrice - snapshot.referencePrice;
//			
//			if (chg < 0){
//				*color = [StockConstant PriceDownColor];
//                *textValue = [NSString stringWithFormat:@"%.2lf",chg];
//            }else if (chg > 0){
//				*color = [StockConstant PriceUpColor];
//                *textValue = [NSString stringWithFormat:@"+%.2lf",chg];
//            }else{
//				*color = [StockConstant watchListTextColor];
//                *textValue = [NSString stringWithFormat:@"%.2lf",chg];
//			}
//			//*textValue = [[NSNumber numberWithFloat:chg]stringValue];
//			
//			*backgroundColor = [UIColor clearColor];
//		}
//		else
//		{
//			*color = [StockConstant watchListTextColor];
//			*textValue = @"----";
//			*backgroundColor = [UIColor clearColor];
//		}
//		
//	}
//	
	//漲跌福
	else if([headerName isEqualToString:@"p_chg"]){
		
		if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0)
		{
			double p_chg = (snapshot.last_price.calcValue - snapshot.reference_price.calcValue)/snapshot.reference_price.calcValue*100;
			
			if (p_chg < 0){
				*color = [StockConstant PriceDownColor];
                *textValue = [NSString stringWithFormat:@"%.2lf%%",p_chg];
			}else if (p_chg > 0){
				*color = [StockConstant PriceUpColor];
                *textValue = [NSString stringWithFormat:@"+%.2lf%%",p_chg];
            }else{
				*color = [StockConstant watchListTextColor];
                *textValue = [NSString stringWithFormat:@"%.2lf%%",p_chg];
            }
			
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"0.00%";
			*backgroundColor = [UIColor clearColor];
		}
		
	}

	//買價
	else if([headerName isEqualToString:@"bid"]){
		
		if (snapshot.bid_price.calcValue != 0 && snapshot.reference_price.calcValue != 0)
		{
			*color = [ValueUtil colorOfPrice:snapshot.last_price.calcValue refPrice:snapshot.reference_price.calcValue baseColor:[StockConstant watchListTextColor]];
			if(snapshot.bid_price.calcValue == 0)
				*textValue = @"----";
			else
				*textValue = [CodingUtil ConvertPriceValueToString:snapshot.bid_price.calcValue withIdSymbol:idSymbol];
			
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
	
	//賣價
	else if([headerName isEqualToString:@"ask"]){
		
		if (snapshot.ask_price.calcValue != 0 && snapshot.reference_price.calcValue != 0)
		{
			*color = [ValueUtil colorOfPrice:snapshot.last_price.calcValue refPrice:snapshot.reference_price.calcValue baseColor:[StockConstant watchListTextColor]];
			if(snapshot.ask_price.calcValue == 0)
				*textValue = @"----";
			else
				*textValue = [CodingUtil ConvertPriceValueToString:snapshot.ask_price.calcValue withIdSymbol:idSymbol];
			
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
	
	// 右邊的選單選總量
	else if([headerName isEqualToString:@"accumulatedVolume"]){
		if (snapshot.reference_price.calcValue != 0 && snapshot.accumulated_volume.calcValue != 0) {
			if (snapshot.accumulated_volume.calcValue == 0) {
				*color = [StockConstant watchListTextColor];
            } else {
				*color = [UIColor colorWithRed:0.436 green:0.000 blue:0.455 alpha:1.000];
			}
            
            *textValue = [CodingUtil volumeRoundRownWithDouble:snapshot.accumulated_volume.calcValue];
            
			*backgroundColor = [UIColor clearColor];
		}
		else {
			*color = [StockConstant watchListTextColor];
			*textValue = @"0";
			*backgroundColor = [UIColor clearColor];
		}
	}

	//單量
	else if([headerName isEqualToString:@"volume"]){
        double newVolume = 0;
        if (snapshot) {
            FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
            PortfolioItem *portfolioItem = [dataModel.portfolioData findItemByIdentCodeSymbol:snapshot.identCodeSymbol];
            
            
            if (portfolioItem->type_id == 6) {
                
                if (snapshot.volume.calcValue != 0) {
                    newVolume = snapshot.volume.calcValue;
//                    textValue =[CodingUtil twStringWithVolumeByValue3:snapshot.volume.calcValue];
                }
                else {
                    
                    if (snapshot.pre_volume == nil) {
                        newVolume = 0;
//                        textValue =[CodingUtil twStringWithVolumeByValue3:0];
                    } else {
                        newVolume = snapshot.deal_volume.calcValue - snapshot.pre_volume.calcValue;
//                        textValue =[CodingUtil twStringWithVolumeByValue3:snapshot.deal_volume.calcValue - snapshot.pre_volume.calcValue];
                    }
                    
                    snapshot.pre_volume = snapshot.deal_volume;
                }
                
            }else{
                newVolume = snapshot.volume.calcValue;
//                textValue =[CodingUtil twStringWithVolumeByValue3:snapshot.volume.calcValue];
            }
            
            
            
//            if (portfolioItem->type_id == 6) {
//                newVolume = round(snapshot.deal_volume.calcValue);
//            }else{
//                newVolume = round(snapshot.volume.calcValue);
//            }
            
            // 顏色改看內外盤
            if (snapshot.outer_price.calcValue > snapshot.inner_price.calcValue) {
                *color = [UIColor darkGrayColor];
            }
            else {
                *color = [UIColor orangeColor];
            }
            
        }

//		double tmpVolume = [(NSNumber *)[[_singleVolumeDictionary objectForKey:idSymbol] objectForKey:@"lastVol"]doubleValue];
//		double diffVolume = newVolume - tmpVolume;
		
		/*
         double diffVolume;
         if(fabs(snapshot.volume - snapshot.accumulatedVolume)>0.1)
         diffVolume = round(snapshot.volume * pow(1000,snapshot.volumeUnit));
         else
         diffVolume = round((snapshot.accumulatedVolume - snapshot.previousVolume) * pow(1000,snapshot.volumeUnit));
         */
        
        
        //目前的dictionary裡面沒有這個商品
//		if(tmpVolume == 0)
//		{
//			// init
//			if(nil != _singleVolumeDictionary[idSymbol] && _singleVolumeDictionary[idSymbol] != [NSNull null] )
//			{
//				diffVolume = 0;
//				NSMutableDictionary *volDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
//												[NSNumber numberWithDouble:newVolume],@"lastVol",
//												[NSNumber numberWithDouble:diffVolume],@"diffVol",nil];
//				[_singleVolumeDictionary setObject:volDict forKey:idSymbol];
//			}
//			
//            //			NSLog(@"tmpVolume == 0 %@ %.1f",idSymbol,diffVolume);
//		}
//        //在dictionary裡有找到
//		else
//		{
//			if(diffVolume == 0 || diffVolume < 0)
//			{
//				diffVolume = [(NSNumber *)[[_singleVolumeDictionary objectForKey:idSymbol] objectForKey:@"diffVol"] doubleValue];
//				
//                //				NSLog(@"diffVolume == 0 %@ %.1f",idSymbol,diffVolume);
//			}
//			else if(diffVolume > 0)
//			{
//				
//				NSMutableDictionary *volDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
//												[NSNumber numberWithDouble:newVolume],@"lastVol",
//												[NSNumber numberWithDouble:diffVolume],@"diffVol",nil];
//				[_singleVolumeDictionary setObject:volDict forKey:idSymbol];
//				
//                //				NSLog(@"diffVolume > 0 %@ %.1f",idSymbol,diffVolume);
//				
//			}
//			
//		}
        
        
		//*color = [StockConstant watchListTextColor];
//		*color = [UIColor colorWithRed:0.436 green:0.000 blue:0.455 alpha:1.000];
        
        
        
        // 美股用
        *textValue =[CodingUtil volumeRoundRownWithDouble:newVolume];
//		*textValue = [CodingUtil stringWithVolumeByValue:diffVolume]; //[CodingUtil ConvertDoubleNoZeroValueToString:diffVolume];
		*backgroundColor = [UIColor clearColor];
		
	}
	
	//最高
	else if([headerName isEqualToString:@"highestPrice"]){
		if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0) {
			*color = [ValueUtil colorOfPrice:snapshot.high_price.calcValue refPrice:snapshot.reference_price.calcValue baseColor:[StockConstant watchListTextColor]];
			*textValue = [snapshot.high_price format];
			*backgroundColor = [UIColor clearColor];
		}
		else {
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
	}

	//最低
	else if([headerName isEqualToString:@"lowestPrice"]){
		if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0) {
			*color = [ValueUtil colorOfPrice:snapshot.low_price.calcValue refPrice:snapshot.reference_price.calcValue baseColor:[StockConstant watchListTextColor]];
			*textValue = [CodingUtil ConvertPriceValueToString:snapshot.low_price.calcValue withIdSymbol:idSymbol];
			*backgroundColor = [UIColor clearColor];
		}
		else {
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
	}

	//量比
	else if([headerName isEqualToString:@"volumeRatio"]){
		if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0) {
			double previousVolume = snapshot.previous_volume.calcValue; //昨日總量
			
			double accumulatedVolume = snapshot.accumulated_volume.calcValue; //總量
			double volumeRatio;
			if(previousVolume == 0 || accumulatedVolume == 0)
				volumeRatio = 0;
			else
				volumeRatio = accumulatedVolume / previousVolume; //量比 ( 今日總量/昨日總量)
			
			*color = [StockConstant watchListTextColor];
			*textValue = [CodingUtil ConvertDoubleNoZeroValueToString:volumeRatio];
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
	
	//振幅
	else if([headerName isEqualToString:@"stockAmplitude"]){
		
		if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0)
		{
			/* 股票振幅就是股票開盤後的當日最高價和最低價之間的差的絕對值與前日收盤價的百分比 */
			double stockAmplitude = fabs(snapshot.high_price.calcValue - snapshot.low_price.calcValue) / snapshot.reference_price.calcValue  * 100; // 振幅 (%)
			
			if (stockAmplitude < 0)
				*color = [StockConstant PriceDownColor];
			else if (stockAmplitude > 0)
				*color = [StockConstant PriceUpColor];
			else
				*color = [StockConstant watchListTextColor];
			*textValue = [NSString stringWithFormat:@"%.2lf%%",stockAmplitude];
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
//    else {
//        *color = [StockConstant watchListTextColor];
//        *textValue = @"----";
//        *backgroundColor = [UIColor clearColor];
//    }
//}
//
//- (void)setTextValue:(NSString**)textValue Color:(UIColor**)color BackgroundColor:(UIColor**)backgroundColor ByHeaderName:(NSString*)headerName
//			Snapshot:(EquitySnapshotDecompressed*)snapshot IdSymbol:(NSString *)idSymbol
//{
//    //成交價
//	if([headerName isEqualToString:@"price"]){
//		
//		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
//		{
//			*color = [ValueUtil colorOfPrice:snapshot.currentPrice refPrice:snapshot.referencePrice baseColor:[StockConstant watchListTextColor]];
//			*textValue = [CodingUtil ConvertPriceValueToString:snapshot.currentPrice withIdSymbol:idSymbol];
//			*backgroundColor = [self setPriceLabelBackGroundColorWithPrice:snapshot.currentPrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice];
//			
//		}
////		else if (snapshot.currentPrice == 0 && snapshot.referencePrice != 0)
////		{
////			*color = [StockConstant watchListTextColor];
////			*textValue = [CodingUtil ConvertPriceValueToString:snapshot.currentPrice withIdSymbol:idSymbol];
////			*backgroundColor = [UIColor clearColor];
////		}
//		else
//		{
//			*color = [StockConstant watchListTextColor];
//			*textValue = @"----";
//			*backgroundColor = [UIColor clearColor];
//		}
//	}
//	
	//漲疊
	else if([headerName isEqualToString:@"chg"]){
		
		if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0)
		{
			
			double chg = snapshot.last_price.calcValue - snapshot.reference_price.calcValue;
			
			if (chg < 0){
				*color = [StockConstant PriceDownColor];
                *textValue = [NSString stringWithFormat:@"%.2lf",chg];
            }else if (chg > 0){
				*color = [StockConstant PriceUpColor];
                *textValue = [NSString stringWithFormat:@"+%.2lf",chg];
            }else{
				*color = [StockConstant watchListTextColor];
                *textValue = [NSString stringWithFormat:@"%.2lf",chg];
			}
			//*textValue = [[NSNumber numberWithFloat:chg]stringValue];
			
			*backgroundColor = [UIColor clearColor];
		}
		else
		{
			*color = [StockConstant watchListTextColor];
			*textValue = @"----";
			*backgroundColor = [UIColor clearColor];
		}
		
	}
//
//	//漲跌福
//	else if([headerName isEqualToString:@"p_chg"]){
//		
//		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
//		{
//			double p_chg = (snapshot.currentPrice - snapshot.referencePrice)/snapshot.referencePrice*100;
//			
//			if (p_chg < 0){
//				*color = [StockConstant PriceDownColor];
//                *textValue = [NSString stringWithFormat:@"%.2lf%%",p_chg];
//			}else if (p_chg > 0){
//				*color = [StockConstant PriceUpColor];
//                *textValue = [NSString stringWithFormat:@"+%.2lf%%",p_chg];
//            }else{
//				*color = [StockConstant watchListTextColor];
//                *textValue = [NSString stringWithFormat:@"%.2lf%%",p_chg];
//            }
//			
//			*backgroundColor = [UIColor clearColor];
//		}
//		else
//		{
//			*color = [StockConstant watchListTextColor];
//			*textValue = @"0.00%";
//			*backgroundColor = [UIColor clearColor];
//		}
//		
//	}
//	
//	//買價
//	else if([headerName isEqualToString:@"bid"]){
//		
//		if (snapshot.bid != 0 && snapshot.referencePrice != 0)
//		{
//			*color = [ValueUtil colorOfPrice:snapshot.currentPrice refPrice:snapshot.referencePrice baseColor:[StockConstant watchListTextColor]];
//			if(snapshot.bid == 0)
//				*textValue = @"----";
//			else
//				*textValue = [CodingUtil ConvertPriceValueToString:snapshot.bid withIdSymbol:idSymbol];
//			
//			*backgroundColor = [UIColor clearColor];
//		}
//		else
//		{
//			*color = [StockConstant watchListTextColor];
//			*textValue = @"----";
//			*backgroundColor = [UIColor clearColor];
//		}
//		
//	}
//	
//	//賣價
//	else if([headerName isEqualToString:@"ask"]){
//		
//		if (snapshot.ask != 0 && snapshot.referencePrice != 0)
//		{
//			*color = [ValueUtil colorOfPrice:snapshot.currentPrice refPrice:snapshot.referencePrice baseColor:[StockConstant watchListTextColor]];
//			if(snapshot.ask == 0)
//				*textValue = @"----";
//			else
//				*textValue = [CodingUtil ConvertPriceValueToString:snapshot.ask withIdSymbol:idSymbol];
//			
//			*backgroundColor = [UIColor clearColor];
//		}
//		else
//		{
//			*color = [StockConstant watchListTextColor];
//			*textValue = @"----";
//			*backgroundColor = [UIColor clearColor];
//		}
//		
//	}
//	
//	//總量
//	else if([headerName isEqualToString:@"accumulatedVolume"]){
//		
//		if (snapshot.referencePrice != 0 && snapshot.accumulatedVolume !=0)
//		{
//			
//			int accumulatedVolumeUnit = snapshot.accumulatedVolumeUnit;
//			double accumulatedVolume = snapshot.accumulatedVolume  * (pow(1000, accumulatedVolumeUnit)); //總量
//			
//			if(accumulatedVolume == 0)
//				*color = [StockConstant watchListTextColor];
//			else
//				*color = [UIColor colorWithRed:0.436 green:0.000 blue:0.455 alpha:1.000];
//			
////			*textValue = [CodingUtil stringWithVolumeValueAndUnit:accumulatedVolume unit:accumulatedVolumeUnit];
//            *textValue = [CodingUtil stringWithVolumeByValue:accumulatedVolume];
//			
//			*backgroundColor = [UIColor clearColor];
//		}
//		else
//		{
//			*color = [StockConstant watchListTextColor];
//			*textValue = @"0";
//			*backgroundColor = [UIColor clearColor];
//		}
//		
//	}
//	
//	//單量
//	else if([headerName isEqualToString:@"volume"]){
//		double newVolume = round(snapshot.volume * pow(1000,snapshot.volumeUnit));
//		double tmpVolume = [[[_singleVolumeDictionary objectForKey:idSymbol] objectForKey:@"lastVol"]doubleValue];
//		double diffVolume = newVolume - tmpVolume;
//		
//		/*
//         double diffVolume;
//         if(fabs(snapshot.volume - snapshot.accumulatedVolume)>0.1)
//         diffVolume = round(snapshot.volume * pow(1000,snapshot.volumeUnit));
//         else
//         diffVolume = round((snapshot.accumulatedVolume - snapshot.previousVolume) * pow(1000,snapshot.volumeUnit));
//         */
//        
//        
//        //目前的dictionary裡面沒有這個商品
//		if(tmpVolume == 0)
//		{
//			// init
//			if(nil != _singleVolumeDictionary[idSymbol] && _singleVolumeDictionary[idSymbol] != [NSNull null] )
//			{
//				diffVolume = 0;
//				NSMutableDictionary *volDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
//												[NSNumber numberWithDouble:newVolume],@"lastVol",
//												[NSNumber numberWithDouble:diffVolume],@"diffVol",nil];
//				[_singleVolumeDictionary setObject:volDict forKey:idSymbol];
//			}
//			
//            //			NSLog(@"tmpVolume == 0 %@ %.1f",idSymbol,diffVolume);
//		}
//        //在dictionary裡有找到
//		else
//		{
//			if(diffVolume == 0 || diffVolume < 0)
//			{
//				diffVolume = [[[_singleVolumeDictionary objectForKey:idSymbol] objectForKey:@"diffVol"] doubleValue];
//				
//                //				NSLog(@"diffVolume == 0 %@ %.1f",idSymbol,diffVolume);
//			}
//			else if(diffVolume > 0)
//			{
//				
//				NSMutableDictionary *volDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
//												[NSNumber numberWithDouble:newVolume],@"lastVol",
//												[NSNumber numberWithDouble:diffVolume],@"diffVol",nil];
//				[_singleVolumeDictionary setObject:volDict forKey:idSymbol];
//				
//                //				NSLog(@"diffVolume > 0 %@ %.1f",idSymbol,diffVolume);
//				
//			}
//			
//		}
//        
//        
//		//*color = [StockConstant watchListTextColor];
//		*color = [UIColor colorWithRed:0.436 green:0.000 blue:0.455 alpha:1.000];
//		*textValue = [CodingUtil stringWithVolumeByValue:diffVolume]; //[CodingUtil ConvertDoubleNoZeroValueToString:diffVolume];
//		*backgroundColor = [UIColor clearColor];
//		
//	}
//	
//	//最高
//	else if([headerName isEqualToString:@"highestPrice"]){
//		
//		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
//		{
//			*color = [ValueUtil colorOfPrice:snapshot.highestPrice refPrice:snapshot.referencePrice baseColor:[StockConstant watchListTextColor]];
//			*textValue = [CodingUtil ConvertPriceValueToString:snapshot.highestPrice withIdSymbol:idSymbol];
//			*backgroundColor = [UIColor clearColor];
//		}
//		else
//		{
//			*color = [StockConstant watchListTextColor];
//			*textValue = @"----";
//			*backgroundColor = [UIColor clearColor];
//		}
//		
//	}
//	
//	//最低
//	else if([headerName isEqualToString:@"lowestPrice"]){
//		
//		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
//		{
//			*color = [ValueUtil colorOfPrice:snapshot.lowestPrice refPrice:snapshot.referencePrice baseColor:[StockConstant watchListTextColor]];
//			*textValue = [CodingUtil ConvertPriceValueToString:snapshot.lowestPrice withIdSymbol:idSymbol];
//			*backgroundColor = [UIColor clearColor];
//		}
//		else
//		{
//			*color = [StockConstant watchListTextColor];
//			*textValue = @"----";
//			*backgroundColor = [UIColor clearColor];
//		}
//		
//	}
//	
//	//量比
//	else if([headerName isEqualToString:@"volumeRatio"]){
//		
//		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
//		{
//			
//			int previousVolumeUnit = snapshot.previousVolumeUnit;
//			double previousVolume = snapshot.previousVolume  * (pow(1000, previousVolumeUnit)); //昨日總量
//			
//			int accumulatedVolumeUnit = snapshot.accumulatedVolumeUnit;
//			double accumulatedVolume = snapshot.accumulatedVolume  * (pow(1000, accumulatedVolumeUnit)); //總量
//			double volumeRatio;
//			if(previousVolume == 0 || accumulatedVolume == 0)
//				volumeRatio = 0;
//			else
//				volumeRatio = accumulatedVolume / previousVolume; //量比 ( 今日總量/昨日總量)
//			
//			*color = [StockConstant watchListTextColor];
//			*textValue = [CodingUtil ConvertDoubleNoZeroValueToString:volumeRatio];
//			*backgroundColor = [UIColor clearColor];
//		}
//		else
//		{
//			*color = [StockConstant watchListTextColor];
//			*textValue = @"----";
//			*backgroundColor = [UIColor clearColor];
//		}
//		
//	}
//	
//	//振幅
//	else if([headerName isEqualToString:@"stockAmplitude"]){
//		
//		if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
//		{
//			/* 股票振幅就是股票開盤後的當日最高價和最低價之間的差的絕對值與前日收盤價的百分比 */
//			double stockAmplitude = fabs(snapshot.highestPrice - snapshot.lowestPrice) / snapshot.referencePrice  * 100; // 振幅 (%)
//			
//			if (stockAmplitude < 0)
//				*color = [StockConstant PriceDownColor];
//			else if (stockAmplitude > 0)
//				*color = [StockConstant PriceUpColor];
//			else
//				*color = [StockConstant watchListTextColor];
//			*textValue = [NSString stringWithFormat:@"%.2lf%%",stockAmplitude];
//			*backgroundColor = [UIColor clearColor];
//		}
//		else
//		{
//			*color = [StockConstant watchListTextColor];
//			*textValue = @"----";
//			*backgroundColor = [UIColor clearColor];
//		}
//		
//	}
//    else {
//        *color = [StockConstant watchListTextColor];
//        *textValue = @"----";
//        *backgroundColor = [UIColor clearColor];
//    }
//    
}

-(void)updateDataLabel:(UILabel *) dataLabel text:(NSString *) aText textColor:(UIColor *) aTextColor backgroundColor:(UIColor *) aBackgroundColor
{
    [dataLabel performSelectorOnMainThread:@selector(setTextColor:) withObject:aTextColor waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
    [dataLabel performSelectorOnMainThread:@selector(setText:) withObject:aText waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
    [dataLabel performSelectorOnMainThread:@selector(setBackgroundColor:) withObject:aBackgroundColor waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
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
		
        return [UIColor clearColor];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate) //不須做減速 加暫存
    {
        [self observePortfolios];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    [self observePortfolios];
}

#pragma mark -
#pragma mark PickList

- (void)changeStock:(id) sender
{
    
	if(editFlag)
	{
		NSString *alertString = NSLocalizedStringFromTable(@"編輯狀態無法切換自選群組",@"watchlists",@"");
		UIAlertView	*alertView = [[UIAlertView alloc] initWithTitle:nil message:alertString delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",@"alarm",nil) otherButtonTitles:nil];
		[alertView show];
		return;
	}
    
    self.groupSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    NSInteger count =0;
    count = [_dataModal.watchlists getWatchGroupCount];
    int i;
    for (i=0; i<count; i++) {
        WatchGroup *currentWatchGroup = [_dataModal.watchlists getWatchGroupWithWatchGroupIndex:i];
        [_groupSheet addButtonWithTitle:currentWatchGroup.groupName];
        
    }
    [_groupSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"watchlists", nil)];
    [_groupSheet setCancelButtonIndex:i];
    [_groupSheet setTitle:NSLocalizedStringFromTable(@"群組", @"watchlists", nil)];
    [self showActionSheet:_groupSheet];
//    [self initSort];
    
}

- (void)sortItems:(UIButton *) sender
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCheckBox)];
    

    cxAlertView = [[CustomIOS7AlertView alloc]init];
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width-30, 347)];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width-30, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedStringFromTable(@"排序", @"watchlists", nil);
    [cxAlertView setTitleLabel:label];
    [cxAlertView setContainerView:view];
    [cxAlertView setButtonTitles:@[NSLocalizedStringFromTable(@"確定", @"watchlists", nil)]];
    cxAlertView.delegate = self;

    self.actionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) style:UITableViewStylePlain];
    _actionTableView.delegate = self;
    _actionTableView.dataSource = self;
    _actionTableView.bounces = NO;
    _actionTableView.backgroundView = nil;
    selectRow = (int)_selectSortSheetIndex;
    
    self.checkView = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height, 300, 44)];
    _checkView.backgroundColor = [UIColor whiteColor];
    _checkView.userInteractionEnabled = YES;
    [_checkView addGestureRecognizer:tapGestureRecognizer];
    [view addSubview:_checkView];
    
    self.checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 44)];
    _checkLabel.text = NSLocalizedStringFromTable(@"Do Not Sort", @"watchlists", nil);
    [_checkView addSubview:_checkLabel];
    
    self.checkBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeCheckBox];
    _checkBtn.selected =[[_mainDict objectForKey:@"Check"]boolValue];
    sortFlag = _checkBtn.selected;
    [self.checkBtn addTarget:self action:@selector(tapCheckBox) forControlEvents:UIControlEventTouchUpInside];
    _checkBtn.frame = CGRectMake(245, 0, 30, 37);
    [_checkView addSubview:_checkBtn];
    
    [view addSubview:_actionTableView];
    
    [cxAlertView show];
}

-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self saveHandler];
    [cxAlertView close];
}

-(void)saveHandler
{
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      
                      [NSString stringWithFormat:@"WatchListSortMemory.plist"]];
    
    _mainDict = [[NSMutableDictionary alloc] init];
    _selectSortSheetIndex = selectRow;
    sortFlag = _checkBtn.selected;
    [self.mainDict setObject:[NSNumber numberWithInteger:_selectSortSheetIndex] forKey:@"SortNumber"];
    [self.mainDict setObject:[NSNumber numberWithBool:_checkBtn.selected] forKey:@"Check"];
    [self.mainDict writeToFile:path atomically:YES];
    
    
    [self dismissSortingPopoverAndReloadData];
    
    if(!sortFlag){
        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID:(int)_recentWatchsIndex];
        [self.volumeHeader setBackgroundImage:grayButton forState:UIControlStateNormal];
        [self.volumeHeader setTitleColor:[UIColor colorWithRed:8.0/255.0 green:55.0/255.0 blue:138.0/255.0 alpha:1] forState:UIControlStateNormal];
    }else{
        [self.volumeHeader setBackgroundImage:stretchableBlueButton forState:UIControlStateNormal];
        [self.volumeHeader setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [_watchlistTableView reloadData];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([tableView isEqual:_actionTableView]){
        return _checkView;
    }else{
        return nil;
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([actionSheet isEqual:_groupSheet]){
        int count = [_dataModal.watchlists getWatchGroupCount];
        if(buttonIndex<count){
            self.selectPickerIndex = buttonIndex;
            [self dismissGroupPopoverAndReloadData2];
            NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"WatchListGroupMemory.plist"]];
            self.mainDict = [[NSMutableDictionary alloc] init];
            [self.mainDict setObject:[NSNumber numberWithInteger:_selectPickerIndex] forKey:@"UserGroupNum"];
            [self.mainDict writeToFile:path atomically:YES];
        }
    }
}

- (void)dismissGroupPopoverAndReloadData2
{
    
	[self cancelObserving];
    WatchGroup *currentWatchGroup = [[[FSDataModelProc sharedInstance]watchlists] getWatchGroupWithWatchGroupIndex:(int)_selectPickerIndex];
    int groupID = currentWatchGroup.groupID; //群組ID
    _recentWatchsIndex = [[[FSDataModelProc sharedInstance]watchlists] getWatchsIndexByWatchGroupID:groupID];
    
    // set default watch group to NSUserDefaults
    NSUserDefaults *tabDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *groupIndex = [NSNumber numberWithInteger:_recentWatchsIndex];
    [tabDefaults setObject:groupIndex forKey:@"defaultWatchGroupIndex"];
    [tabDefaults synchronize];
    
    [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID: groupID];
    [_watchlistTableView reloadData];
    [_multiChartViewController updatePlotDataSource];
    [_multiChartViewController.collectionView reloadData];
    //觀察是看visibleRow，所以必須在table reload之後做
    [self observePortfolios];
	
    [self.changeGroupButton setTitle:currentWatchGroup.groupName forState:UIControlStateNormal];
	
}

-(void)changeReloadName
{
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"WatchListGroupMemory.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    _selectPickerIndex = [(NSNumber *)[_mainDict objectForKey:@"UserGroupNum"]intValue];
    WatchGroup *currentWatchGroup = [[[FSDataModelProc sharedInstance]watchlists] getWatchGroupWithWatchGroupIndex:(int)_selectPickerIndex];
    int groupID = currentWatchGroup.groupID; //群組ID
    _recentWatchsIndex = [[[FSDataModelProc sharedInstance]watchlists] getWatchsIndexByWatchGroupID:groupID];
    [self.changeGroupButton setTitle:currentWatchGroup.groupName forState:UIControlStateNormal];
    
//    [self dismissGroupPopoverAndReloadData2];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([tableView isEqual:_watchlistTableView]){
        return 0;
    }else{
        return 35.0f;
    }
}


- (void)dismissSortingPopoverAndReloadData
{
    
    [self.volumeHeader setTitle:self.sortButtonTitleArray[_selectSortSheetIndex] forState:UIControlStateNormal];
    [self sortPortfolioItemBySortingIndex:_selectSortSheetIndex];
    [_watchlistTableView reloadData];
    //[_multiChartViewController.collectionView reloadData];
    
    [_volumeHeader setTitle:[NSString stringWithFormat:@"%@", self.sortButtonTitleArray[_selectSortSheetIndex]] forState:UIControlStateNormal];

    
    
    
    NSUserDefaults *tabDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *groupIndex = [NSNumber numberWithInt:(int)_selectSortSheetIndex];
    [tabDefaults setObject:groupIndex forKey:@"sortingHeaderIndex"];
    [tabDefaults synchronize];
    
}

/**
 *  根據排序選項把值放進所有的PortfolioItem裡
 *
 *  @param indexPath
 */
- (void)sortPortfolioItemBySortingIndex:(NSUInteger) index
{
    /*    
     self.sortAttributeArray = @[NSLocalizedStringFromTable(@"VolA(Accumulated)", @"watchlists", nil),
     NSLocalizedStringFromTable(@"VolP(Period)", @"watchlists", nil),
     NSLocalizedStringFromTable(@"Vol%(VolA vs Vols Prev)", @"watchlists", nil),
     NSLocalizedStringFromTable(@"Rise", @"watchlists", nil),
     NSLocalizedStringFromTable(@"Fall", @"watchlists", nil),
     NSLocalizedStringFromTable(@"Up($)", @"watchlists", nil),
     NSLocalizedStringFromTable(@"Down($)", @"watchlists", nil),
     NSLocalizedStringFromTable(@"Amp(Amplified)", @"watchlists", nil),
     NSLocalizedStringFromTable(@"Last", @"watchlists", nil),
     NSLocalizedStringFromTable(@"Your own", @"watchlists", nil)
     */
    BOOL descending = NO;
    for (NSUInteger itemCounter=0; itemCounter < [_watchlistItem count]; itemCounter++) {
        PortfolioItem *portfolioItem = [_watchlistItem portfolioItemAtIndex:itemCounter];
        if (portfolioItem != nil) {
            PortfolioTick *tickBank = [[FSDataModelProc sharedInstance]portfolioTickBank];
            
            
#ifdef LPCB
            FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:[portfolioItem getIdentCodeSymbol]];
            if (snapshot != nil) {
                switch (index) {
                        //
                    case 0:
                        //總量
                        if (snapshot.reference_price.calcValue != 0 && snapshot.accumulated_volume.calcValue != 0) {
                            portfolioItem.valueForSorting = @(snapshot.accumulated_volume.calcValue);
                            descending = YES;
                        } else {
                            double accumulatedVolume = 0;
                            portfolioItem.valueForSorting = @(accumulatedVolume);
                            descending = YES;
                        }
                        break;
                        
                    case 1: {
                        //Volp單量
    
                        double newVolume = round(snapshot.volume.calcValue);
                        double tmpVolume = [(NSNumber *)[[_singleVolumeDictionary objectForKey:[portfolioItem getIdentCodeSymbol]] objectForKey:@"lastVol"]doubleValue];
                        double diffVolume = newVolume - tmpVolume;
                        
                        //目前的dictionary裡面沒有這個商品
                        if(tmpVolume == 0)
                        {
                            // init
                            if(nil != _singleVolumeDictionary[[portfolioItem getIdentCodeSymbol]] && _singleVolumeDictionary[[portfolioItem getIdentCodeSymbol]] != [NSNull null] )
                            {
                                diffVolume = 0;
                                NSMutableDictionary *volDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                                                [NSNumber numberWithDouble:newVolume],@"lastVol",
                                                                [NSNumber numberWithDouble:diffVolume],@"diffVol",nil];
                                [_singleVolumeDictionary setObject:volDict forKey:[portfolioItem getIdentCodeSymbol]];
                            }
                            
                            //			NSLog(@"tmpVolume == 0 %@ %.1f",idSymbol,diffVolume);
                        }
                        //在dictionary裡有找到
                        else
                        {
                            if(diffVolume == 0 || diffVolume < 0)
                            {
                                diffVolume = [(NSNumber *)[[_singleVolumeDictionary objectForKey:[portfolioItem getIdentCodeSymbol]] objectForKey:@"diffVol"] doubleValue];
                                
                                //				NSLog(@"diffVolume == 0 %@ %.1f",idSymbol,diffVolume);
                            }
                            else if(diffVolume > 0)
                            {
                                
                                NSMutableDictionary *volDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                                                [NSNumber numberWithDouble:newVolume],@"lastVol",
                                                                [NSNumber numberWithDouble:diffVolume],@"diffVol",nil];
                                [_singleVolumeDictionary setObject:volDict forKey:[portfolioItem getIdentCodeSymbol]];
                                
                                //				NSLog(@"diffVolume > 0 %@ %.1f",idSymbol,diffVolume);
                                
                            }
                            
                        }
                        portfolioItem.valueForSorting = @(diffVolume);
                        descending = YES;
                        break;
                    }
                    case 2:
                        //Vol%
                        if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0) {
                            double previousVolume = snapshot.previous_volume.calcValue;
                            double accumulatedVolume = snapshot.accumulated_volume.calcValue;
                            double volumeRatio;
                            if(previousVolume == 0 || accumulatedVolume == 0)
                                volumeRatio = 0;
                            else
                                volumeRatio = accumulatedVolume / previousVolume; //量比 ( 今日總量/昨日總量)
                            
                            portfolioItem.valueForSorting = @(volumeRatio);
                            descending = YES;
                        }
                        break;
                    case 3:
                        //Up($)
                        if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0)
                        {
                            
                            double chg = snapshot.last_price.calcValue - snapshot.reference_price.calcValue;
                            portfolioItem.valueForSorting = @(chg);
                            descending = YES;
                        }else{
                            double chg = 0;
                            portfolioItem.valueForSorting = @(chg);
                            descending = YES;
                        }
                        break;
                    case 4:
                        //Rise
                        if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0)
                        {
                            double p_chg = (snapshot.last_price.calcValue - snapshot.reference_price.calcValue)/snapshot.reference_price.calcValue*100;
                            portfolioItem.valueForSorting = @(p_chg);
                            descending = YES;
                        }else{
                            double p_chg = 0;
                            portfolioItem.valueForSorting = @(p_chg);
                            descending = YES;
                            
                        }
                        break;
                    case 5:
                        //Fall
                        
                        
                        if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0)
                        {
                            double p_chg = (snapshot.last_price.calcValue - snapshot.reference_price.calcValue)/snapshot.reference_price.calcValue*100;
                            portfolioItem.valueForSorting = @(p_chg);
                        }else{
                            double p_chg = 0;
                            portfolioItem.valueForSorting = @(p_chg);
                        }
                        break;
//                    case 6:
//                        //Down($)
//                        if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0)
//                        {
//                            
//                            double chg = snapshot.last_price.calcValue - snapshot.reference_price.calcValue;
//                            portfolioItem.valueForSorting = @(chg);
//                        }
//                        else{
//                            double chg = 0;
//                            portfolioItem.valueForSorting = @(chg);
//                        }
//                        break;
                    case 6:
                        //Amp
                        if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0)
                        {
                            /* 股票振幅就是股票開盤後的當日最高價和最低價之間的差的絕對值與前日收盤價的百分比 */
                            double stockAmplitude = fabs(snapshot.high_price.calcValue - snapshot.low_price.calcValue) / snapshot.reference_price.calcValue  * 100; // 振幅 (%)
                            
                            portfolioItem.valueForSorting = @(stockAmplitude);
                            descending = YES;
                        }else{
                            double stockAmplitude = 0;
                            
                            portfolioItem.valueForSorting = @(stockAmplitude);
                            descending = YES;
                        }
                        break;
                    case 7:
                        //Last
                        if (snapshot.last_price.calcValue != 0 && snapshot.reference_price.calcValue != 0)
                        {
                            portfolioItem.valueForSorting = @(snapshot.last_price.calcValue);
                            descending = YES;
                            
                        }
                        //                        else if (snapshot.currentPrice == 0 && snapshot.referencePrice != 0)
                        //                        {
                        //                            portfolioItem.valueForSorting = @(snapshot.referencePrice);
                        //                            descending = YES;
                        //                        }
                        else{
                            double last = 0;
                            portfolioItem.valueForSorting = @(last);
                            descending = YES;
                        }
                        
                        break;
                    case 8:
                        //把portfolio裡的watchlistArray洗回原本DB的順序
                        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID:(int)_recentWatchsIndex];
                        break;
                    default:
                        break;
                }
            }
        }
    }
    //如果不是None
    if (index != 8 && sortFlag) {
        [_watchlistItem sortDescending:descending];
    }
#else
            EquitySnapshotDecompressed *snapshot = [tickBank getSnapshotFromIdentCodeSymbol:[portfolioItem getIdentCodeSymbol]];
            if (snapshot != nil) {
                switch (index) {
                        //
                    case 0:
                        //總量
                        if (snapshot.referencePrice != 0 && snapshot.accumulatedVolume !=0)
                        {
                            int accumulatedVolumeUnit = snapshot.accumulatedVolumeUnit;
                            double accumulatedVolume = snapshot.accumulatedVolume  * pow(1000, accumulatedVolumeUnit); //總量
                            portfolioItem.valueForSorting = @(accumulatedVolume);
                            descending = YES;
                        }else
                        {
                            double accumulatedVolume = 0;
                            portfolioItem.valueForSorting = @(accumulatedVolume);
                            descending = YES;
                        }
                        break;
                        
                    case 1: {
                        //Volp單量
                        double newVolume = round(snapshot.volume * pow(1000,snapshot.volumeUnit));
                        double tmpVolume = [(NSNumber *)[[_singleVolumeDictionary objectForKey:[portfolioItem getIdentCodeSymbol]] objectForKey:@"lastVol"]doubleValue];
                        double diffVolume = newVolume - tmpVolume;
                        
                        //目前的dictionary裡面沒有這個商品
                        if(tmpVolume == 0)
                        {
                            // init
                            if(nil != _singleVolumeDictionary[[portfolioItem getIdentCodeSymbol]] && _singleVolumeDictionary[[portfolioItem getIdentCodeSymbol]] != [NSNull null] )
                            {
                                diffVolume = 0;
                                NSMutableDictionary *volDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                                                [NSNumber numberWithDouble:newVolume],@"lastVol",
                                                                [NSNumber numberWithDouble:diffVolume],@"diffVol",nil];
                                [_singleVolumeDictionary setObject:volDict forKey:[portfolioItem getIdentCodeSymbol]];
                            }
                            
                            //			NSLog(@"tmpVolume == 0 %@ %.1f",idSymbol,diffVolume);
                        }
                        //在dictionary裡有找到
                        else
                        {
                            if(diffVolume == 0 || diffVolume < 0)
                            {
                                diffVolume = [(NSNumber *)[[_singleVolumeDictionary objectForKey:[portfolioItem getIdentCodeSymbol]] objectForKey:@"diffVol"] doubleValue];
                                
                                //				NSLog(@"diffVolume == 0 %@ %.1f",idSymbol,diffVolume);
                            }
                            else if(diffVolume > 0)
                            {
                                
                                NSMutableDictionary *volDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                                                [NSNumber numberWithDouble:newVolume],@"lastVol",
                                                                [NSNumber numberWithDouble:diffVolume],@"diffVol",nil];
                                [_singleVolumeDictionary setObject:volDict forKey:[portfolioItem getIdentCodeSymbol]];
                                
                                //				NSLog(@"diffVolume > 0 %@ %.1f",idSymbol,diffVolume);
                                
                            }
                            
                        }
                        portfolioItem.valueForSorting = @(diffVolume);
                        descending = YES;
                        break;
                    }
                    case 2:
                        //Vol%
                        if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
                        {
                            
                            int previousVolumeUnit = snapshot.previousVolumeUnit;
                            double previousVolume = snapshot.previousVolume  * (pow(1000, previousVolumeUnit)); //昨日總量
                            
                            int accumulatedVolumeUnit = snapshot.accumulatedVolumeUnit;
                            double accumulatedVolume = snapshot.accumulatedVolume  * (pow(1000, accumulatedVolumeUnit)); //總量
                            double volumeRatio;
                            if(previousVolume == 0 || accumulatedVolume == 0)
                                volumeRatio = 0;
                            else
                                volumeRatio = accumulatedVolume / previousVolume; //量比 ( 今日總量/昨日總量)
                            
                            portfolioItem.valueForSorting = @(volumeRatio);
                            descending = YES;
                        }
                        break;
                    case 3:
                        //Rise
                        if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
                        {
                            double p_chg = (snapshot.currentPrice - snapshot.referencePrice)/snapshot.referencePrice*100;
                            portfolioItem.valueForSorting = @(p_chg);
                            descending = YES;
                        }else{
                            double p_chg = 0;
                            portfolioItem.valueForSorting = @(p_chg);
                            descending = YES;
                            
                        }
                        break;
                    case 4:
                        //Fall
                        
                        
                        if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
                        {
                            double p_chg = (snapshot.currentPrice - snapshot.referencePrice)/snapshot.referencePrice*100;
                            portfolioItem.valueForSorting = @(p_chg);
                        }else{
                            double p_chg = 0;
                            portfolioItem.valueForSorting = @(p_chg);
                        }
                        break;
                    case 5:
                        //Up($)
                        if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
                        {
                            
                            double chg = snapshot.currentPrice - snapshot.referencePrice;
                            portfolioItem.valueForSorting = @(chg);
                            descending = YES;
                        }else{
                            double chg = 0;
                            portfolioItem.valueForSorting = @(chg);
                            descending = YES;
                        }
                        break;
                    case 6:
                        //Down($)
                        if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
                        {
                            
                            double chg = snapshot.currentPrice - snapshot.referencePrice;
                            portfolioItem.valueForSorting = @(chg);
                        }
                        else{
                            double chg = 0;
                            portfolioItem.valueForSorting = @(chg);
                        }
                        break;
                    case 7:
                        //Amp
                        if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
                        {
                            /* 股票振幅就是股票開盤後的當日最高價和最低價之間的差的絕對值與前日收盤價的百分比 */
                            double stockAmplitude = fabs(snapshot.highestPrice - snapshot.lowestPrice) / snapshot.referencePrice  * 100; // 振幅 (%)
                            
                            portfolioItem.valueForSorting = @(stockAmplitude);
                            descending = YES;
                        }else{
                            double stockAmplitude = 0;
                            
                            portfolioItem.valueForSorting = @(stockAmplitude);
                            descending = YES;
                        }
                        break;
                    case 8:
                        //Last
                        if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0)
                        {
                            portfolioItem.valueForSorting = @(snapshot.currentPrice);
                            descending = YES;
                            
                        }
                        //                        else if (snapshot.currentPrice == 0 && snapshot.referencePrice != 0)
                        //                        {
                        //                            portfolioItem.valueForSorting = @(snapshot.referencePrice);
                        //                            descending = YES;
                        //                        }
                        else{
                            double last = 0;
                            portfolioItem.valueForSorting = @(last);
                            descending = YES;
                        }
                        
                        break;
                    case 9:
                        //把portfolio裡的watchlistArray洗回原本DB的順序
                        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID:_recentWatchsIndex];
                        break;
                    default:
                        break;
                }
            }
        }
    }
    //如果不是None
    if (index != 9 && sortFlag) {
        [_watchlistItem sortDescending:descending];
    }
#endif
            
}

-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([[FSFonestock sharedInstance] checkNeedShowAdvertise]){
        if([[UIApplication sharedApplication] statusBarOrientation]== UIInterfaceOrientationLandscapeLeft){
            self.navigationController.topViewController.view.frame = CGRectMake(0, 52, self.navigationController.topViewController.view.bounds.size.width, self.navigationController.topViewController.view.bounds.size.height-32);
        }else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
            self.navigationController.topViewController.view.frame = CGRectMake(0, 52, self.navigationController.topViewController.view.bounds.size.width, self.navigationController.topViewController.view.bounds.size.height-32);
        }else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait){
            self.navigationController.topViewController.view.frame = CGRectMake(0, 64, self.navigationController.topViewController.view.bounds.size.width, self.navigationController.topViewController.view.bounds.size.height-50);
        }
    }

}

-(void)tapCheckBox
{
    if(_checkBtn.selected){
         _checkBtn.selected = NO;
        sortFlag = NO;
    }else{
         _checkBtn.selected = YES;
        sortFlag = YES;
    }
   
}






// connor update :

/*
 
美股價格數字顯示規則

1. 欄位最多顯示6碼, 小數點不算在內.
2. 小數位顯示2位, 若數字超過6碼依序捨棄小數位.

例:
　數字 100　畫面顯示 100.00
　數字 1000　畫面顯示1000.0
　數字 10000　畫面顯示10000.0
　數字100000　畫面顯示100000

*/

- (NSString *)watchlistPriceFormatString:(double)price {
    if (price == 0) {
        return [NSString stringWithFormat:@"----"];
    }
    else if (price < 1000) {
        return [NSString stringWithFormat:@"%.2f", price];
    }
    else if (price < 10000) {
        return [NSString stringWithFormat:@"%.1f", price];
    }
    else if (price < 100000) {
        return [NSString stringWithFormat:@"%.1f", price];
    }
    else if (price < 1000000) {
        return [NSString stringWithFormat:@"%.0f", price];
    }
    return [NSString stringWithFormat:@"%.0f", price];
}



-(void)alertTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.9 target:self selector:@selector(showAlert:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)showAlert:(NSTimer *)timer{
    time ++;
    FSActionPlanModel *actionPlanModel = [[FSDataModelProc sharedInstance] actionPlanModel];
    NSMutableArray * longArray = actionPlanModel.actionPlanLongArray;
    NSMutableArray * shortArray = actionPlanModel.actionPlanShortArray;
    NSMutableDictionary * colorDic = [[NSMutableDictionary alloc]init];
    
    if ([longArray count] > 0){
        for (int i = 0; i < [longArray count]; i++){
            FSActionPlan *longActionPlan = [longArray objectAtIndex:i];
            if (longActionPlan.buySellType) {
                if (longActionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy &&
                    longActionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
                    [colorDic setObject:[UIColor yellowColor] forKey:longActionPlan.identCodeSymbol];
                }else if (longActionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy){
                    [colorDic setObject:[self countryDefinition:[StockConstant AlertSellProfitColor]] forKey:longActionPlan.identCodeSymbol];
                }else if (longActionPlan.buySellType & FSActionPlanAlertTypeSellStrategy){
                    [colorDic setObject:[self countryDefinition:[StockConstant AlertSellLossColor]] forKey:longActionPlan.identCodeSymbol];
                }else if (longActionPlan.buySellType & FSActionPlanAlertTypeSellProfit){
                    [colorDic setObject:[self countryDefinition:[StockConstant AlertSellProfitColor]] forKey:longActionPlan.identCodeSymbol];
                }else if (longActionPlan.buySellType & FSActionPlanAlertTypeSellLoss){
                    [colorDic setObject:[self countryDefinition:[StockConstant AlertSellLossColor]] forKey:longActionPlan.identCodeSymbol];
                }else if (longActionPlan.buySellType & FSActionPlanAlertTypeTarget){
                    [colorDic setObject:[UIColor yellowColor] forKey:longActionPlan.identCodeSymbol];
                }
            }
        }
    }
    if ([shortArray count] > 0){
        for (int i = 0; i < [shortArray count]; i++){
            FSActionPlan *shortActionPlan = [shortArray objectAtIndex:i];
            if (shortActionPlan.buySellType) {
                if (shortActionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy &&
                    shortActionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
                    [colorDic setObject:[UIColor yellowColor] forKey:shortActionPlan.identCodeSymbol];
                }else if (shortActionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy){
                    [colorDic setObject:[self countryDefinition:[StockConstant AlertSellProfitColor]] forKey:shortActionPlan.identCodeSymbol];
                }else if (shortActionPlan.buySellType & FSActionPlanAlertTypeSellStrategy){
                    [colorDic setObject:[self countryDefinition:[StockConstant AlertSellLossColor]] forKey:shortActionPlan.identCodeSymbol];
                }else if (shortActionPlan.buySellType & FSActionPlanAlertTypeSellProfit){
                    [colorDic setObject:[self countryDefinition:[StockConstant AlertSellLossColor]] forKey:shortActionPlan.identCodeSymbol];
                }else if (shortActionPlan.buySellType & FSActionPlanAlertTypeSellLoss){
                    [colorDic setObject:[self countryDefinition:[StockConstant AlertSellProfitColor]] forKey:shortActionPlan.identCodeSymbol];
                }else if (shortActionPlan.buySellType & FSActionPlanAlertTypeTarget){
                    [colorDic setObject:[UIColor yellowColor] forKey:shortActionPlan.identCodeSymbol];
                }
            }
        }
    }
    if ([longArray count] > 0 && [shortArray count] > 0) {
        for (int i = 0; i < [longArray count]; i++){
            FSActionPlan *longActionPlan = [longArray objectAtIndex:i];
            for (int z = 0; z < [shortArray count]; z++){
                FSActionPlan *shortActionPlan = [shortArray objectAtIndex:z];
                if ([longActionPlan.identCodeSymbol isEqualToString:shortActionPlan.identCodeSymbol]) {
                    if ((longActionPlan.buySellType     & FSActionPlanAlertTypeBuyStrategy &&
                         shortActionPlan.buySellType    & FSActionPlanAlertTypeBuyStrategy) ||
                        (longActionPlan.buySellType     & FSActionPlanAlertTypeBuyStrategy &&
                         shortActionPlan.buySellType    & FSActionPlanAlertTypeSellStrategy) ||
                        (longActionPlan.buySellType     & FSActionPlanAlertTypeSellStrategy &&
                         shortActionPlan.buySellType    & FSActionPlanAlertTypeBuyStrategy) ||
                        (longActionPlan.buySellType     & FSActionPlanAlertTypeSellStrategy &&
                         shortActionPlan.buySellType    & FSActionPlanAlertTypeSellStrategy)){
                        [colorDic setObject:[UIColor orangeColor] forKey:shortActionPlan.identCodeSymbol];
                    }else if ((longActionPlan.buySellType   & FSActionPlanAlertTypeBuyStrategy &&
                               longActionPlan.buySellType   & FSActionPlanAlertTypeSellStrategy) ||
                              (shortActionPlan.buySellType  & FSActionPlanAlertTypeBuyStrategy &&
                               shortActionPlan.buySellType  & FSActionPlanAlertTypeSellStrategy)){
                        [colorDic setObject:[UIColor yellowColor] forKey:shortActionPlan.identCodeSymbol];
                    }else if (shortActionPlan.buySellType   & FSActionPlanAlertTypeBuyStrategy){
                        [colorDic setObject:[self countryDefinition:[StockConstant AlertSellProfitColor]] forKey:shortActionPlan.identCodeSymbol];
                    }else if (shortActionPlan.buySellType   & FSActionPlanAlertTypeSellStrategy){
                        [colorDic setObject:[self countryDefinition:[StockConstant AlertSellLossColor]] forKey:shortActionPlan.identCodeSymbol];
                    }else if ((longActionPlan.buySellType   & FSActionPlanAlertTypeSellProfit &&
                               shortActionPlan.buySellType  & FSActionPlanAlertTypeSellProfit)||
                              (longActionPlan.buySellType   & FSActionPlanAlertTypeSellProfit &&
                               shortActionPlan.buySellType  & FSActionPlanAlertTypeSellLoss)||
                              (shortActionPlan.buySellType  & FSActionPlanAlertTypeSellLoss &&
                               longActionPlan.buySellType   & FSActionPlanAlertTypeSellLoss)||
                              (shortActionPlan.buySellType  & FSActionPlanAlertTypeSellProfit &&
                               longActionPlan.buySellType   & FSActionPlanAlertTypeSellLoss)){
                        [colorDic setObject:[UIColor orangeColor] forKey:shortActionPlan.identCodeSymbol];
                    }
                }
            }
        }
    }
    
    NSArray * array = [_watchlistTableView visibleCells];
    [alertDict removeAllObjects];
    for (int i=0; i<[array count];i++) {
        FSWatchlistTableCell * cell = [array objectAtIndex:i];
        [alertDict setObject:cell.nameLabel forKey:cell.identCodeSymbol];
    }
    
    for (NSString *aKey in [alertDict allKeys]) {
        UILabel *label = [alertDict objectForKey:aKey];
        UIColor * color = [colorDic objectForKey:aKey];
        [label.layer removeAllAnimations];
        label.backgroundColor = [UIColor clearColor];
        if (color) {
            if (time % 2 == 0) {
                label.layer.backgroundColor = color.CGColor;
            }else{
                label.layer.backgroundColor = [UIColor clearColor].CGColor;
            }
        }
    }
}

-(UIColor *)countryDefinition:(UIColor *)labelBackgroundColor{
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        if ([labelBackgroundColor isEqual:[StockConstant AlertSellLossColor]]) {
            return [StockConstant AlertSellProfitColor];
        }else{
            return [StockConstant AlertSellLossColor];
        }
    }else{
        return labelBackgroundColor;
    }
    
}
@end
