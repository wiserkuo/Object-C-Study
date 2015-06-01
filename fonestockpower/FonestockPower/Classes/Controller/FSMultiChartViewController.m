//
//  FSMultiChartViewController.m
//  Bullseye
//
//  Created by Shen Kevin on 13/8/5.
//
//

#import "FSMultiChartViewController.h"
#import "FSMultiChartViewModel.h"
#import "FSMultiChartCell.h"
#import "FSMultiChartPlotManager.h"
#import "FSMultiChartPlotData.h"
#import "FSWatchlistPortfolioItem.h"
#import "UICollectionView+FSMultiChartExtensions.h"
#import "FSMultiChartCellRefreshingOperation.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface FSMultiChartViewController ()
@property (nonatomic, strong) FSMultiChartViewModel *collectionViewModel;
@property (nonatomic, strong) NSTimer *refreshTimer;
@end

@implementation FSMultiChartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithWatchlistItem:(NSObject<FSWatchlistItemProtocol>*)aWatchlistItem
{
    self = [super init];
    if (self) {
        self.watchlistItem = aWatchlistItem;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLauncherView];
    [self setupCollectionViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //如果沒有塞任何Item來顯示，用預設Item
    if (_watchlistItem == nil) {
        self.watchlistItem = [[FSWatchlistPortfolioItem alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSNumber *groupIndex = [userDefaults objectForKey:@"defaultWatchGroupIndex"];
        WatchGroup *currentWatchGroup = [[[FSDataModelProc sharedInstance]watchlists] getWatchGroupWithWatchGroupIndex:[groupIndex intValue]];
        int groupID = currentWatchGroup.groupID; //群組ID
        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID: groupID];
    }
    //[self setupDataSourceManager];要放在viewWillAppear裡面，這樣每次進江波圖才會去設定
    [self setupDataSourceManager];
    self.collectionViewModel.watchlistItem = _watchlistItem;
    
    //根據Item有幾個產生相對應數量的data source
    [[FSMultiChartPlotManager sharedInstance] generatePlotDataSourceForItem:_watchlistItem];
//    [self.collectionView reloadData];
    [self watchVisibleItems];
}

-(void)updatePlotDataSource{
    //根據Item有幾個產生相對應數量的data source
    [[FSMultiChartPlotManager sharedInstance] generatePlotDataSourceForItem:_watchlistItem];
//    [self.collectionView reloadData];
    [self watchVisibleItems];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unwatchAllItems];
    //離開畫面之後把dataSourceManager的delegate設為nil，這樣dataSourceManager才不會繼續呼叫collectionView的reloadCellAtIndex更新
    [FSMultiChartPlotManager sharedInstance].delegate = nil;
    //確定使用者離開畫面就不要再繼續做畫面更新的動作了
    [[NSOperationQueue mainQueue] cancelAllOperations];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Setup

- (void)setupCollectionViewModel
{
    self.collectionViewModel = [[FSMultiChartViewModel alloc] init];
    self.collectionView.dataSource = self.collectionViewModel;
}

-(void)setupLauncherView
{
    [self.collectionView registerClass:[FSMultiChartCell class] forCellWithReuseIdentifier:@"MultiChartCell"];
    self.collectionView.delegate = self;
    self.collectionView.bounces = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)setupDataSourceManager
{
    FSMultiChartPlotManager *dataSourceManager = [FSMultiChartPlotManager sharedInstance];
    dataSourceManager.delegate = self;
}

#pragma mark Watch Equity

- (void)watchVisibleItems
{
    //[[FSMultiChartPlotManager sharedInstance] watchEquityForVisibleItems:[self.collectionView indexPathsForVisibleItems]];
    [[FSMultiChartPlotManager sharedInstance] watchEquityForAllItems];
}

- (void)unwatchAllItems
{
    [[FSMultiChartPlotManager sharedInstance] stopWatchEquityForAllItems];
}

- (void)reloadCellAtIndex:(NSUInteger) index;
{
    __weak __typeof(&*self)weakSelf = self;
    [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^() {
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        [strongSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    }]];
//    [self.collectionView reloadCellAtIndex:index preventTooManyUpdateing:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSMainViewController *instantInfoMainViewController = [[FSMainViewController alloc] init];
    PortfolioItem *portfolioItem = [_watchlistItem portfolioItem:indexPath];
    
    FSInstantInfoWatchedPortfolio *instantInfoWatchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    instantInfoWatchedPortfolio.portfolioItem = portfolioItem;
    
    [self.parentViewController.navigationController pushViewController:instantInfoMainViewController animated:NO];
}

#pragma mark - UICollectionView ScrollView Delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate) //不須做減速 加暫存
    {
//        [self watchVisibleItems];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    [self watchVisibleItems];
}

#pragma mark - Timer

- (void)setRefreshTimer:(NSTimer *)refreshTimer
{
    if (refreshTimer != _refreshTimer)
    {
        [_refreshTimer invalidate];
        _refreshTimer = refreshTimer;
    }
}

- (void)startCellRefreshingTimer
{
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reloadItemsAtIndexPaths:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_refreshTimer forMode:NSRunLoopCommonModes];
}

@end
