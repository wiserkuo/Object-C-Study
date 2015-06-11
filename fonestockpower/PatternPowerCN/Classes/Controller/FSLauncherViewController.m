//
//  FSLauncherViewController.m
//  FonestockPower
//
//  Created by Connor on 14/4/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherViewController.h"
#import "FSAccountSettingViewController.h"
#import "FSLauncherCollectionViewCell.h"
#import "FigureSearchViewController.h"
#import "MyFigureSearchViewController.h"
#import "FSWatchlistViewController.h"
#import "FSWebViewController.h"
#import "Portfolio.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSActionAlertViewController.h"
#import "FSPerformanceViewController.h"
#import "FSPositionManagementViewController.h"
#import "FSDiaryViewController.h"
#import "FSLauncherConfigureViewController.h"

@interface FSLauncherViewController () <UICollectionViewDelegate, UICollectionViewDataSource> {
    UICollectionView *mainFuctionCollectionView;
    UIView *bannerWebview;
    UICollectionView *newsLinkCollectionView;
    FSWebViewController *bannerWebviewController;
}

@end

@implementation FSLauncherViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupMainFuctionCollectionView];
    [self setupBannerWebview];
    [self setupNewsLinkCollectionView];
    [self setupNewsLabel];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark NavigationBar Init

- (void)setupNavigationBar {
    
    [self.navigationController setNavigationBarHidden:NO];
    [self setTitle:NSLocalizedStringFromTable(@"圖是力", @"Launcher", nil)];
    
    //set bar color
//    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:85.0/255.0 green:143.0/255.0 blue:220.0/255.0 alpha:1.0]];
    //optional, i don't want my bar to be translucent
    [self.navigationController.navigationBar setTranslucent:NO];
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    //set back button color
    
//    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    //set back button arrow color
//    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UIButton *accountSettingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [accountSettingButton setImage:[UIImage imageNamed:@"GearButton_Black"] forState:UIControlStateNormal];
    [accountSettingButton addTarget:self action:@selector(leftTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *accountSettingBarButton = [[UIBarButtonItem alloc] initWithCustomView:accountSettingButton];
    
    self.navigationItem.leftBarButtonItem = accountSettingBarButton;
}

- (void)leftTapped:(id)sender {
    [self.navigationController pushViewController:[[FSAccountSettingViewController alloc] init] animated:NO];
}

#pragma mark CollectionView Init

- (void)setupMainFuctionCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(92, 92)];
    [layout setMinimumInteritemSpacing:0];
    [layout setMinimumLineSpacing:10];
    [layout setSectionInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    // collection body
    mainFuctionCollectionView = [[UICollectionView alloc]
                                 initWithFrame:CGRectZero
                                 collectionViewLayout:layout];
    
    mainFuctionCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    mainFuctionCollectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    mainFuctionCollectionView.backgroundColor = [UIColor clearColor];
    
    mainFuctionCollectionView.delegate = self;
    mainFuctionCollectionView.dataSource = self;
    [mainFuctionCollectionView registerClass:NSClassFromString(@"FSLauncherCollectionViewCell")
                       forCellWithReuseIdentifier:@"mainFuctionCollectionView"];

    UIImageView *topBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LauncherMainCollectionViewBackground"]];
    [mainFuctionCollectionView setBackgroundView:topBackgroundView];
    
    [self.view addSubview:mainFuctionCollectionView];

    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(mainFuctionCollectionView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainFuctionCollectionView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainFuctionCollectionView(218)]" options:0 metrics:nil views:viewControllers]];
}

- (void)setupBannerWebview {
    bannerWebviewController = [[FSWebViewController alloc] initWithURL:[[FSFonestock sharedInstance] mainPageAdvertiseURL]];
    [bannerWebviewController willMoveToParentViewController:self];
    [self addChildViewController:bannerWebviewController];
    [bannerWebviewController didMoveToParentViewController:self];
    
    bannerWebview = bannerWebviewController.view;
    [bannerWebview setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:bannerWebview];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(mainFuctionCollectionView, bannerWebview);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bannerWebview]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainFuctionCollectionView][bannerWebview]" options:0 metrics:nil views:viewControllers]];
}

- (void)setupNewsLinkCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(70, 70)];
    [layout setMinimumInteritemSpacing:2];
    [layout setMinimumLineSpacing:20];
    [layout setSectionInset:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    // layout
    newsLinkCollectionView = [[UICollectionView alloc]
                                   initWithFrame:CGRectZero
                                   collectionViewLayout:layout];
    
    newsLinkCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [newsLinkCollectionView registerClass:NSClassFromString(@"FSLauncherCollectionViewCell")
                    forCellWithReuseIdentifier:@"newsLinkCollectionView"];
    
    newsLinkCollectionView.delegate = self;
    newsLinkCollectionView.dataSource = self;
    newsLinkCollectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    UIImage *image = [UIImage imageNamed:@"LauncherButtomBackgroud"];
    newsLinkCollectionView.backgroundView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:newsLinkCollectionView];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(bannerWebview, newsLinkCollectionView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[newsLinkCollectionView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bannerWebview][newsLinkCollectionView(90)]|" options:0 metrics:nil views:viewControllers]];
}

- (void)setupNewsLabel {
    UILabel *newsHeaderLabel = [[UILabel alloc] init];
    newsHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    newsHeaderLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    newsHeaderLabel.textColor = [UIColor colorWithRed:82.0f/255.0f green:95.0f/255.0f blue:125.0f/255.0f alpha:1.0f];
    newsHeaderLabel.textAlignment = NSTextAlignmentCenter;
    newsHeaderLabel.text = NSLocalizedStringFromTable(@"News", @"Launcher", nil);
    [self.view addSubview:newsHeaderLabel];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:newsLinkCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:newsHeaderLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:newsLinkCollectionView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:newsHeaderLabel attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (mainFuctionCollectionView == view) {
        return 6;
    } else if (newsLinkCollectionView == view) {
        return 4;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    if (mainFuctionCollectionView == collectionView) {
        return 1;
    } else if (newsLinkCollectionView == collectionView) {
        return 1;
    }
    return 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FSLauncherCollectionViewCell *cell;
    
    if (cv == mainFuctionCollectionView) {
        cell = (FSLauncherCollectionViewCell *) [cv dequeueReusableCellWithReuseIdentifier:@"mainFuctionCollectionView" forIndexPath:indexPath];
        
        cell.title.textColor = [UIColor colorWithRed:82.0f/255.0f green:95.0f/255.0f blue:125.0f/255.0f alpha:1.0f];
        
        switch (indexPath.row) {
            case 0:
                cell.title.text = NSLocalizedStringFromTable(@"標竿型態", @"Launcher", nil);
                cell.imageView.image = [UIImage imageNamed:@"Typical Pattern-icon"];
                break;
            case 1:
                cell.title.text = NSLocalizedStringFromTable(@"我的型態", @"Launcher", nil);
                cell.imageView.image = [UIImage imageNamed:@"DIY Pattern-icon"];
                break;
            case 2:
                cell.title.text = NSLocalizedStringFromTable(@"個股研究", @"Launcher", nil);
                cell.imageView.image = [UIImage imageNamed:@"Watch List-icon"];
                break;
            case 3:
                cell.title.text = NSLocalizedStringFromTable(@"標竿型態", @"Launcher", nil);
                cell.imageView.image = [UIImage imageNamed:@"Typical Pattern-icon"];
                break;
            case 4:
                cell.title.text = NSLocalizedStringFromTable(@"Portfolio", @"Launcher", nil);
                cell.imageView.image = [UIImage imageNamed:@"DIY Pattern-icon"];
                break;
            case 5:
                cell.title.text = NSLocalizedStringFromTable(@"個股研究", @"Launcher", nil);
                cell.imageView.image = [UIImage imageNamed:@"Watch List-icon"];
                break;
            default:
                break;
        }
    }
    
    if (cv == newsLinkCollectionView) {
        cell = (FSLauncherCollectionViewCell *) [cv dequeueReusableCellWithReuseIdentifier:@"newsLinkCollectionView" forIndexPath:indexPath];
        
        cell.title.textColor = [UIColor colorWithRed:82.0f/255.0f green:95.0f/255.0f blue:125.0f/255.0f alpha:1.0f];
        
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [UIImage imageNamed:@"cnstock news-icon"];
                break;
            case 1:
                cell.imageView.image = [UIImage imageNamed:@"sina news-icon"];
                break;
            case 2:
                cell.imageView.image = [UIImage imageNamed:@"3gnews news-icon"];
                break;
            case 3:
                cell.imageView.image = [UIImage imageNamed:@"yicai news-icon"];
                break;
            default:
                break;
        }
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIViewController *viewController = nil;
    
    // 主功能選項
    if (collectionView == mainFuctionCollectionView) {
        
        switch (indexPath.row) {
            case 0:
                viewController = [[FigureSearchViewController alloc] init];
                break;
            case 1:
                viewController = [[MyFigureSearchViewController alloc] init];
                break;
            case 2:{
                FSDataModelProc * dataModel = [FSDataModelProc sharedInstance];
                PortfolioItem *portfolioItem = [dataModel.portfolioData findItemByIdentCodeSymbol:@"SS 600019"];
                PortfolioItem *comparedPortfolioItem = [dataModel.portfolioData findItemByIdentCodeSymbol:@"SS 600000"];
                FSInstantInfoWatchedPortfolio *instantInfoWatchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
                instantInfoWatchedPortfolio.portfolioItem = portfolioItem;
                instantInfoWatchedPortfolio.comparedPortfolioItem =comparedPortfolioItem;
                viewController = [[FSWatchlistViewController alloc] init];
                break;
            }
            case 3:
                viewController = [[FSActionAlertViewController alloc] init];
                break;
            case 4:
                viewController = [[FSPositionManagementViewController alloc] init];
                break;
            case 5:
                viewController = [[FSDiaryViewController alloc] init];
                break;
            default:
                break;
        }
        
        [self.navigationController pushViewController:viewController animated:NO];
        //用一個PageViewController去裝watchlist以及江波圖
//        FSPagerViewController *pagerViewController = [[FSPagerViewController alloc] init];
        
        
//        //Watchlist
//        FSWatchlistViewController *watchlistViewController = [[FSWatchlistViewController alloc] init];
//        //江波圖
//        FSMultiChartViewFlowLayout *gridLayout = [[FSMultiChartViewFlowLayout alloc] init];
//        FSMultiChartViewController *multiChartViewController = [[FSMultiChartViewController alloc] initWithCollectionViewLayout:gridLayout];
//        //把兩個controller加進PageViewController裡面
//        [pagerViewController setViewControllers:@[watchlistViewController]];
    }
    
    // 新聞選項
    else if (collectionView == newsLinkCollectionView) {
        
        NSString *url;
        
        switch ([indexPath row]) {
            case 0:
                url = @"http://3g.cnstock.com";
                break;
            case 1:
                url = @"http://finance.sina.cn/?vt=4";
                break;
            case 2:
                url = @"http://3g.news.cn/fortune.htm";
                break;
            case 3:
                url = @"http://m.yicai.com/webapp/newslist.php?tid=50";
                break;
            default:
                break;
        }
        
        FSWebViewController *webBrowser = [[FSWebViewController alloc] initWithURL:url];
        [webBrowser setNeedsToolBar:YES];
        [webBrowser setCanGoBack:YES];
        [self.navigationController pushViewController:webBrowser animated:NO];
    }
    
}

- (void)dealloc {

}
@end
