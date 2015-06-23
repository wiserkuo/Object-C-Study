//
//  FSLauncherPageViewController.m
//  FonestockPower
//
//  Created by Connor on 14/6/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherPageViewController.h"
#import "FSLauncherConfigureViewController.h"
#import "FSFinanceReportUS.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSOptionMainViewController.h"
#import "FSPaymentViewController.h"
#import "RelatedNewsListViewController.h"
#import "FSLauncherConfigureViewController.h"
#import "FSRootPaymentViewController.h"
#import "ExplanationForTipSeriesViewController.h"

@interface FSLauncherPageViewController ()<UIScrollViewDelegate>

@end

@implementation FSLauncherPageViewController{
#ifdef StockPowerTW
    UIBarButtonItem *forView1R;
    UIBarButtonItem *forView2L;
    UIBarButtonItem *forView2R;
    UIBarButtonItem *forView3L;
    UIBarButtonItem *forView3R;
    UIBarButtonItem *forView4L;
    UIBarButtonItem *forView4R;
    UIBarButtonItem *forView5L;
    UIBarButtonItem *forView5R;
    UIBarButtonItem *forView6L;
#endif
    UIScrollView *explanationView;
    UIButton *backFromExpBtn;
}

- (void)viewDidLoad {
    
    self.navigationController.navigationBarHidden = NO;
    
//#ifdef StockPowerTW
//    UIImageView *backImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundIMG"]];
//    backImg.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addSubview:backImg];
//    NSDictionary *allObj = NSDictionaryOfVariableBindings(backImg);
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backImg]|" options:0 metrics:nil views:allObj]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backImg]|" options:0 metrics:nil views:allObj]];
//#else
#ifdef DivergenceTipsUS
    UIColor *backgroundColor = [UIColor whiteColor];
    [self.view setBackgroundColor:backgroundColor];
#elif DivergenceTipsTW || DivergenceTipsCN || DivergenceTipsHK || PatternTipsUS || PatternTipsTW || PatternTipsCN || PatternTipsHK
    UIColor *backgroundColor = [UIColor whiteColor];
    [self.view setBackgroundColor:backgroundColor];
#else
    UIColor *backgroundColor = [UIColor colorWithRed:102.0f/255 green:145.0f/255 blue:1.0f/255 alpha:1.0];
    [self.view setBackgroundColor:backgroundColor];
#endif
    [[[FSDataModelProc sharedInstance] loginService] setTarget:self];
//#endif
    //UIImage *backgroundImage = [UIImage imageNamed:@"LauncherMainBackground"];
    
    //UIImageView *backgroudView = [[UIImageView alloc] initWithImage:backgroundImage];
    //backgroudView.translatesAutoresizingMaskIntoConstraints = NO;
    //[self.view addSubview:backgroudView];

    
    [self setupNavigationBar];
    [super viewDidLoad];
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroudView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backgroudView)]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backgroudView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(backgroudView)]];
}
#ifdef StockPowerTW
#else
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.scrollView.contentOffset.x == 72.0){
        self.scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0);
    }
    
    
//    if (self.numberOfPages > 0 && self.currentPage < self.numberOfPages) {
//
//        [self loadScrollViewWithPage:self.currentPage];
//
//        if (self.currentPage + 1 < self.numberOfPages) {
//            [self loadScrollViewWithPage:self.currentPage + 1];
//        }
//        if (self.currentPage - 1 >= 0) {
//            [self loadScrollViewWithPage:self.currentPage - 1];
//        }
//    }
//    [self.scrollView setContentOffset:CGPointMake(self.currentPage * self.scrollView.frame.size.width, 0)];
}
#endif

- (void)setupNavigationBar {
//    NSString * appid = [FSFonestock sharedInstance].appId;
//    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    
    
//    if ([group isEqualToString:@"tw"])
//    {
    
//        UIButton *accountSettingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
//        [accountSettingButton setImage:[UIImage imageNamed:@"GearButton_Black"] forState:UIControlStateNormal];
//        [accountSettingButton addTarget:self action:@selector(leftTapped:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIBarButtonItem *accountSettingBarButton = [[UIBarButtonItem alloc] initWithCustomView:accountSettingButton];
//        self.navigationItem.leftBarButtonItem = accountSettingBarButton;
    
    [self.navigationItem setHidesBackButton:YES];
#ifdef StockPowerTW
    UIButton *btn1R = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 33)];
    [btn1R setBackgroundImage:[UIImage imageNamed:@"指右邊"] forState:UIControlStateNormal];
    [btn1R setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1R setTitle:@"訊息" forState:UIControlStateNormal];
    [btn1R addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    forView1R = [[UIBarButtonItem alloc] initWithCustomView:btn1R];
    self.navigationItem.rightBarButtonItem = forView1R;
    
    UIButton *btn2L = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 33)];
    [btn2L setBackgroundImage:[UIImage imageNamed:@"指左邊"] forState:UIControlStateNormal];
    [btn2L setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2L setTitle:@"服務" forState:UIControlStateNormal];
    [btn2L addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    forView2L = [[UIBarButtonItem alloc] initWithCustomView:btn2L];
    self.navigationItem.leftBarButtonItem = forView2L;
    
    UIButton *btn2R = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 33)];
    [btn2R setBackgroundImage:[UIImage imageNamed:@"指右邊"] forState:UIControlStateNormal];
    [btn2R setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2R setTitle:@"衍生" forState:UIControlStateNormal];
    [btn2R addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    forView2R = [[UIBarButtonItem alloc] initWithCustomView:btn2R];
    self.navigationItem.rightBarButtonItem = forView2R;
    
    UIButton *btn3L = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 33)];
    [btn3L setBackgroundImage:[UIImage imageNamed:@"指左邊"] forState:UIControlStateNormal];
    [btn3L setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn3L setTitle:@"訊息" forState:UIControlStateNormal];
    [btn3L addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    forView3L = [[UIBarButtonItem alloc] initWithCustomView:btn3L];
    self.navigationItem.leftBarButtonItem = forView3L;
    
    UIButton *btn3R = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 33)];
    [btn3R setBackgroundImage:[UIImage imageNamed:@"指右邊"] forState:UIControlStateNormal];
    [btn3R setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn3R setTitle:@"決策" forState:UIControlStateNormal];
    [btn3R addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    forView3R = [[UIBarButtonItem alloc] initWithCustomView:btn3R];
    self.navigationItem.rightBarButtonItem = forView3R;
    
    UIButton *btn4L = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 33)];
    [btn4L setBackgroundImage:[UIImage imageNamed:@"指左邊"] forState:UIControlStateNormal];
    [btn4L setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn4L setTitle:@"衍生" forState:UIControlStateNormal];
    [btn4L addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    forView4L = [[UIBarButtonItem alloc] initWithCustomView:btn4L];
    self.navigationItem.leftBarButtonItem = forView4L;
    
    UIButton *btn4R = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 33)];
    [btn4R setBackgroundImage:[UIImage imageNamed:@"指右邊"] forState:UIControlStateNormal];
    [btn4R setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn4R setTitle:@"分析" forState:UIControlStateNormal];
    [btn4R addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    forView4R = [[UIBarButtonItem alloc] initWithCustomView:btn4R];
    self.navigationItem.rightBarButtonItem = forView4R;
    
    UIButton *btn5L = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 33)];
    [btn5L setBackgroundImage:[UIImage imageNamed:@"指左邊"] forState:UIControlStateNormal];
    [btn5L setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn5L setTitle:@"決策" forState:UIControlStateNormal];
    [btn5L addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    forView5L = [[UIBarButtonItem alloc] initWithCustomView:btn5L];
    self.navigationItem.leftBarButtonItem = forView5L;
    
    UIButton *btn5R = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 33)];
    [btn5R setBackgroundImage:[UIImage imageNamed:@"指右邊"] forState:UIControlStateNormal];
    [btn5R setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn5R setTitle:@"國際" forState:UIControlStateNormal];
    [btn5R addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    forView5R = [[UIBarButtonItem alloc] initWithCustomView:btn5R];
    self.navigationItem.rightBarButtonItem = forView5R;
    
    UIButton *btn6L = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 33)];
    [btn6L setBackgroundImage:[UIImage imageNamed:@"指左邊"] forState:UIControlStateNormal];
    [btn6L setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn6L setTitle:@"分析" forState:UIControlStateNormal];
    [btn6L addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    forView6L = [[UIBarButtonItem alloc] initWithCustomView:btn6L];
    self.navigationItem.leftBarButtonItem = forView6L;

    [btn1R setTag:1];
    [btn2L setTag:2];
    [btn2R setTag:3];
    [btn3L setTag:4];
    [btn3R setTag:5];
    [btn4L setTag:6];
    [btn4R setTag:7];
    [btn5L setTag:8];
    [btn5R setTag:9];
    [btn6L setTag:10];
    
    [self checkTheNavigation:1];
    
#elif DivergenceTipsUS || DivergenceTipsTW || DivergenceTipsCN || DivergenceTipsHK
    
    self.title = NSLocalizedStringFromTable(@"背離力", @"DivergenceTips", nil);
    
    UIButton *expButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [expButton addTarget:self action:@selector(showExplanationView) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *itemButton = [[UIBarButtonItem alloc] initWithCustomView:expButton];
    
    self.navigationItem.rightBarButtonItems = @[itemButton];
    
#elif PatternTipsUS || PatternTipsTW || PatternTipsCN || PatternTipsHK
    [self setTitle:NSLocalizedStringFromTable(@"時機小秘", @"DivergenceTips", nil)];
    
    UIButton *expButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [expButton addTarget:self action:@selector(showExplanationView) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *itemButton = [[UIBarButtonItem alloc] initWithCustomView:expButton];
    
    self.navigationItem.rightBarButtonItems = @[itemButton];
//    [self showExplanationView];
//    [explanationView setHidden:YES];
    
//    backFromExpBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
//    [backFromExpBtn setBackgroundImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
//    [backFromExpBtn addTarget:self action:@selector(toggleForExp) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backFromExpBtn];
//    self.navigationItem.leftBarButtonItems = @[backButton];
//    backFromExpBtn.hidden = YES;

#else
    
    
    

//    NSString * appid = [FSFonestock sharedInstance].appId;
//    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    [self setTitle:NSLocalizedStringFromTable(@"圖是力", @"Launcher", nil)];
    
    
    
    
#ifdef PatternPowerTW
    UIButton *serviceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [serviceButton setImage:[UIImage imageNamed:@"Macroeconomic"] forState:UIControlStateNormal];
    [serviceButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    [serviceButton addTarget:self action:@selector(rightTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *serviceBarButton = [[UIBarButtonItem alloc] initWithCustomView:serviceButton];
    self.navigationItem.leftBarButtonItems = @[serviceBarButton];
#endif
    
    UIButton *expButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [expButton addTarget:self action:@selector(showExplanationView) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *itemButton = [[UIBarButtonItem alloc] initWithCustomView:expButton];
    
    self.navigationItem.rightBarButtonItem = itemButton;

    [self.navigationItem setHidesBackButton:YES];
#endif
}

-(void)toggleForExp
{
    explanationView.hidden = !explanationView.hidden;
    backFromExpBtn.hidden = explanationView.hidden;
    [self.view bringSubviewToFront:explanationView];
}

-(void)showExplanationView
{/*
    explanationView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    explanationView.bounces = NO;
    explanationView.delegate = self;
    explanationView.backgroundColor = [UIColor whiteColor];
    UITextView *mainLabel = [[UITextView alloc] init];
    [mainLabel setBackgroundColor:[UIColor whiteColor]];
    mainLabel.userInteractionEnabled = NO;
    NSMutableAttributedString *attStr;
    NSRange subTitle0;
    NSRange subTitle1;
    NSRange subTitle2;
    //因為divergenceTips 跟patternTips 的說明頁內容不相同，所以內文的部份要分開做
#ifdef DivergenceTipsUS
    [explanationView setContentSize:CGSizeMake(self.view.frame.size.width, 820)];
    mainLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 820);
    NSString *aa = @"Divergence Tips provides stocks that chance upon divergences.\n\nDivergence happens when the price of a stock and its volume or other technical indicators go in the opposite direction.  Divergences are often early signals of major shifts in the direction of the price.   Divergence Tips offers both positive divergence (divert to bull) and negative divergence (divert to bear).\n\nBeginners and professionals alike can easily find good targets with just a few taps.\nDivergence Tips is simple and useful. Please try it now!\n\nFeatures:\nObserve divergences with trends and patterns for decisive timing signals.\nDaily update on the stocks with divergence.\nPush notification at the end of day for key investing opportunities.\n\nIn addition to USA stocks, Divergence Tips have versions for China stocks, Hong Kong stocks, Taiwan stocks, and more to come.\n\nFoneStock wishes you success in stock investment!";
    attStr = [[NSMutableAttributedString alloc] initWithString:aa];
    subTitle0 = NSMakeRange(0,518);
    subTitle1 = NSMakeRange(519, 10);
    subTitle2 = NSMakeRange(520,aa.length - 520);
#elif DivergenceTipsTW
    [explanationView setContentSize:CGSizeMake(self.view.frame.size.width, 700)];
    mainLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 700);
    NSString *aa = @"「背離牛股」每日彙整背離的股票及其所對應的項目，快速告知潛在買進或放空之標的。\n\n當某支股票的股價和其成交量或其他技術指標的走向相反時，就出現背離。  背離經常是股價趨勢即將反轉的先行指標，妥善運用將會大幅提高獲利的機會。  「背離牛股」提供正向背離 (背離轉多) 以及負向背離 (背離轉空).\n\n「背離牛股」簡單又好用，歡迎大家使用！\n\n功能介紹:\n1.	每日盤後主動通知。\n每日獲得發生背離現象之個股名單及其對應之指標。\n以背離搭配K線趨勢以及最近型態，快速精準掌握轉折契機。\n\n「背離牛股」除台股之外，還有美股、港股，陸股的APP，之後還會陸續推出其他交易所的版本。  「背離牛股」幫您佈局達全球，獲利通四海，趕快下載，賺錢機會稍縱即逝。\n\n神乎科技祝您財富累積！";
    attStr = [[NSMutableAttributedString alloc] initWithString:aa];
    subTitle0 = NSMakeRange(0,172);
    subTitle1 = NSMakeRange(173, 5);
    subTitle2 = NSMakeRange(179,aa.length - 179);
#elif PatternTipsUS
    [explanationView setContentSize:CGSizeMake(self.view.frame.size.width, 700)];
    mainLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 700);
    NSString *aa = @"Pattern Tips provides stocks that meet certain candlestick patterns.\n\nThese patterns often indicate good timing or turning points for buying/selling or shorting/covering the stocks.  Beginners and professionals alike can easily find good targets with just a few taps.\n\nPattern Tips is simple and useful. Please try it now!\n\nFeatures:\nObserve patterns with trends for more decisive timing signals.\nDaily update on the newly matched stocks with certain patterns.\nPush notification at the end of day.\n\nIn addition to USA stocks, Patterns Tips has versions for China stocks, Hong Kong stocks, Taiwan stocks, and more to come.\n\nFoneStock wishes you success in stock investment!";
    attStr = [[NSMutableAttributedString alloc] initWithString:aa];
    subTitle0 = NSMakeRange(0,321);
    subTitle1 = NSMakeRange(323, 10);
    subTitle2 = NSMakeRange(334, aa.length - 334);
#elif PatternTipsTW
    [explanationView setContentSize:CGSizeMake(self.view.frame.size.width, 650)];
    mainLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 650);
    NSString *aa = @"「型態牛股」每天從數千支股票中，挑選出符合某些特殊型態的股票。\n\n這些特殊型態出現時通常代表股價走勢的關鍵轉折，也就是重要的買賣時機。  不論您是新手還是專家，要做多還是做空，只要輕鬆一點，就可快速找到新的投資標的。\n\n「型態牛股」簡單又好用，歡迎大家使用！\n\n功能介紹:\n每日盤後主動通知。\n每日獲得關鍵轉折型態之個股名單，多空兼備。\n搭配趨勢與型態快速研判股價走勢，確實掌握關鍵契機。\n\n「型態牛股」除台股之外，還有美股、港股、陸股的APP，之後還會陸續推出其他交易所的版本。  「型態牛股」幫您佈局達全球，獲利通四海，趕快下載，賺錢機會稍縱即逝。\n\n神乎科技祝您財富累積！";
    attStr = [[NSMutableAttributedString alloc] initWithString:aa];
    subTitle0 = NSMakeRange(0,132);
    subTitle1 = NSMakeRange(133, 5);
    subTitle2 = NSMakeRange(139, aa.length - 139);
#endif
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0f] range:subTitle0];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0f] range:subTitle2];
    [attStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:22.0f] range:subTitle1];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:subTitle1];
    [mainLabel setAttributedText:attStr];
    
    [explanationView addSubview:mainLabel];
    [self.view addSubview:explanationView];
  */
    //因為項目符號跟換行的關係，沒辦法使用textView 達到，所以才回使用webView 的方式進行實作
    [self.navigationController pushViewController:[[ExplanationForTipSeriesViewController alloc] init] animated:NO];
}

#pragma the orientation
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#ifdef StockPowerTW
-(void)barItemClicked:(UIButton *)sender
{
    UIButton *btn = (UIButton *)sender;
    NSInteger whichPage = 0;
    
    switch(btn.tag){
        case 1: whichPage = 1; break;
        case 2: whichPage = 0; break;
        case 3: whichPage = 2; break;
        case 4: whichPage = 1; break;
        case 5: whichPage = 3; break;
        case 6: whichPage = 2; break;
        case 7: whichPage = 4; break;
        case 8: whichPage = 3; break;
        case 9: whichPage = 5; break;
        case 10: whichPage = 4; break;
        default: break;
    }

    self.currentPage = whichPage;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * whichPage, 0) animated:YES];
    [self checkTheNavigation:whichPage];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self checkTheNavigation:self.currentPage];
}

-(void)checkTheNavigation:(NSInteger)currentPage
{
    switch(currentPage){
        case 0:
            [self setTitle:NSLocalizedStringFromTable(@"神乎服務", @"CustomizeUnitView", nil)];
            self.navigationItem.rightBarButtonItem = forView1R;
            self.navigationItem.leftBarButtonItem = nil;
            break;
        case 1:
            [self setTitle:NSLocalizedStringFromTable(@"新聞訊息", @"CustomizeUnitView", nil)];
            self.navigationItem.leftBarButtonItem = forView2L;
            self.navigationItem.rightBarButtonItem = forView2R;
            break;
        case 2:
            [self setTitle:NSLocalizedStringFromTable(@"衍生性商品", @"CustomizeUnitView", nil)];
            self.navigationItem.leftBarButtonItem = forView3L;
            self.navigationItem.rightBarButtonItem = forView3R;
            break;
        case 3:
            [self setTitle:NSLocalizedStringFromTable(@"神奇力", @"CustomizeUnitView", nil)];
            self.navigationItem.leftBarButtonItem = forView4L;
            self.navigationItem.rightBarButtonItem = forView4R;
            break;
        case 4:
            [self setTitle:NSLocalizedStringFromTable(@"神乎分析", @"CustomizeUnitView", nil)];
            self.navigationItem.leftBarButtonItem = forView5L;
            self.navigationItem.rightBarButtonItem = forView5R;
            break;
        case 5:
            [self setTitle:NSLocalizedStringFromTable(@"國際資訊", @"CustomizeUnitView", nil)];
            self.navigationItem.leftBarButtonItem = forView6L;
            self.navigationItem.rightBarButtonItem = nil;
            break;
        default:
            break;
    }
}
#else

- (void)rightTapped:(id)sender {
#ifdef SERVER_SYNC
    [self.navigationController pushViewController:[[FSLauncherConfigureViewController alloc] init] animated:NO];
#endif
}

#endif
-(void)moveToPaymentView
{
//    FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
//    FSFonestock *fonestock = [FSFonestock sharedInstance];
//    
//    NSString *paymentFullURL = [NSString stringWithFormat:@"%@?acc_id=%@&app_id=%@&lang=%@", fonestock.paymentPageURL, loginService.account, fonestock.appId, fonestock.lang];
//    
//    FSPaymentViewController *paymentWebView = [[FSPaymentViewController alloc] initWithPaymentURL:paymentFullURL];
//    [self.navigationController pushViewController:paymentWebView animated:NO];
    
    
    FSRootPaymentViewController *rootPayment = [[FSRootPaymentViewController alloc]init];
    [self.navigationController pushViewController:rootPayment animated:NO];

}
//
//- (void)rightTapped:(id)sender {
//    PortfolioItem *portfolioItem = [[FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio] portfolioItem];

//    FSFinanceReportUS *test = [[FSFinanceReportUS alloc] init];
//    [test searchAllSheetWithSecurityNumber:portfolioItem->commodityNo dataType:'Q' searchStartDate:[[NSDate date] dayOffset:-365]];
//    FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
//    NSString *paymentFullURL = [NSString stringWithFormat:@"%@&account=%@", [[FSFonestock sharedInstance] paymentPageURL], [loginService account]];
//    
//    FSWebViewController *webview = [[FSWebViewController alloc] initWithURL:paymentFullURL];
//    [webview setNeedsToolBar:YES];
//    [self.navigationController pushViewController:webview animated:NO];
//
//}
@end
