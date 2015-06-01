//
//  FSNavigationViewController.m
//  FonestockPower
//
//  Created by Connor on 14/4/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSNavigationViewController.h"
#import "FSMainViewController.h"
#import "FSAccountSettingViewController.h"
#import "GADInterstitial.h"
#import "NetWorthViewController.h"
#import "FSActionAlertViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <Social/Social.h>
#import "FSAppDelegate.h"
#import "FSActionPlanSettingViewController.h"
#import "FSAddFundsViewController.h"
#import "FSPositionManagementViewController.h"
#import "FSTradeDiaryViewController.h"
#import "FSTradeHistoryViewController.h"
#import "DrawAndScrollController.h"
#import "FSLauncherPageViewController.h"

//@interface FSNavigationViewController () <GADInterstitialDelegate> {
@interface FSNavigationViewController () {
//    GADInterstitial *gad_interstitial;
    UIInterfaceOrientation devOrientation;
    CGPoint originV;
    CGPoint originH;
    BOOL popFullAdFlag;
}

@end

@implementation FSNavigationViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    //[self popGoogleFullAd];
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    if ([[FSFonestock sharedInstance] checkNeedShowAdvertise]) {
//        if ([self.visibleViewController isKindOfClass:[FSActionAlertViewController class]] ||
//            [self.visibleViewController isKindOfClass:[FSPositionViewController class]]  ||
//            [self.visibleViewController isKindOfClass:[FSDiaryViewController class]]||
//            [self.visibleViewController isKindOfClass:[FSPositionInformationViewController class]]||
//            [self.visibleViewController isKindOfClass:NSClassFromString(@"FSAddPortfolioShortViewController")] ||
//            [self.visibleViewController isKindOfClass:NSClassFromString(@"FSAddPorrtflioViewController")]||
//            [self.visibleViewController isKindOfClass:NSClassFromString(@"FSAddPortfolioShortViewController")]||
//            [self.visibleViewController isKindOfClass:NSClassFromString(@"FSActionPlanSettingViewController")]||
//            [self.visibleViewController isKindOfClass:NSClassFromString(@"FSInvestedViewController")] ||
//            [self.visibleViewController isKindOfClass:NSClassFromString(@"NetWorthViewController")] ||
//            [self.visibleViewController isKindOfClass:NSClassFromString(@"FSInvestedViewController")] ||
//            [self.visibleViewController isKindOfClass:NSClassFromString(@"FSAddFundsViewController")] ||
//            [self.visibleViewController isKindOfClass:NSClassFromString(@"FSAddToPerformanceViewController")]){
//            if(devOrientation == UIInterfaceOrientationLandscapeLeft){
//                self.gAdView.adSize = kGADAdSizeSmartBannerLandscape;
//                self.gAdView.frame = CGRectMake(0,self.view.bounds.size.height-32 , self.view.bounds.size.width, 32);
//                self.topViewController.view.frame = CGRectMake(0, 52, self.topViewController.view.bounds.size.width, self.topViewController.view.bounds.size.height-32);
//            }else if(devOrientation == UIInterfaceOrientationLandscapeRight){
//                self.gAdView.adSize = kGADAdSizeSmartBannerLandscape;
//                self.gAdView.frame = CGRectMake(0,self.view.bounds.size.height-32 , self.view.bounds.size.width, 32);
//                self.topViewController.view.frame = CGRectMake(0, 52, self.topViewController.view.bounds.size.width, self.topViewController.view.bounds.size.height-32);
//            }else if(devOrientation == UIInterfaceOrientationPortrait){
//                self.gAdView.adSize = kGADAdSizeSmartBannerPortrait;
//                self.gAdView.frame = CGRectMake(0, self.view.bounds.size.height-50 ,self.view.bounds.size.width, 50);
//                self.topViewController.view.frame = CGRectMake(0, 64, self.topViewController.view.bounds.size.width, self.topViewController.view.bounds.size.height-50);
//            }
//        }
//    }
//    if ([self.visibleViewController isKindOfClass:NSClassFromString(@"NetWorthViewController")] ) {
//        NetWorthViewController * view = (NetWorthViewController*)self.visibleViewController;
//        [view setAutoLayOut];
//    }
//    if ([self.visibleViewController isKindOfClass:NSClassFromString(@"FSActionPlanSettingViewController")]) {
//        FSActionPlanSettingViewController * view = (FSActionPlanSettingViewController*)self.visibleViewController;
//        [view reloadTable];
//    }
//    if ([self.visibleViewController isKindOfClass:[FSActionAlertViewController class]]) {
//        FSActionAlertViewController * view = (FSActionAlertViewController*)self.visibleViewController;
//        [view rotate];
//    }
//    
//    if ([self.visibleViewController isKindOfClass:NSClassFromString(@"FSAddFundsViewController")]) {
//        FSAddFundsViewController * view = (FSAddFundsViewController*)self.visibleViewController;
//        [view rotate];
//    }
//    
    if ([self.visibleViewController isKindOfClass:NSClassFromString(@"DrawAndScrollController")]) {
        DrawAndScrollController * view = (DrawAndScrollController*)self.visibleViewController;
        [view rotate];
    }
    
    if ([self.visibleViewController isKindOfClass:NSClassFromString(@"NetWorthViewController")]) {
        NetWorthViewController * view = (NetWorthViewController*)self.visibleViewController;
        [view didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
    
    if ([self.visibleViewController isKindOfClass:NSClassFromString(@"FSMainViewController")]) {
        FSMainViewController * view = (FSMainViewController*)self.visibleViewController;
        [view didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    devOrientation = toInterfaceOrientation;
}

- (BOOL)shouldAutorotate {
    
#ifdef SERVER_SYNC
    if ([self.visibleViewController isKindOfClass:NSClassFromString(@"FSMainViewController")]){
        FSMainViewController *mainView = (FSMainViewController *)self.visibleViewController;
        if ([mainView.mainViewController isKindOfClass:NSClassFromString(@"DrawAndScrollController")]) {
            return YES;
        }
    }else if([self.visibleViewController isKindOfClass:[FSActionAlertViewController class]]){
        return YES;
    }else if([self.visibleViewController isKindOfClass:[FSPositionManagementViewController class]]){
        return YES;
    }else if ([self.visibleViewController isKindOfClass:[FSTradeDiaryViewController class]]){
        return YES;
    }else if ([self.visibleViewController isKindOfClass:[FSTradeHistoryViewController class]]){
        return YES;
    }else if ([self.visibleViewController isKindOfClass:NSClassFromString(@"NetWorthViewController")]){
        return YES;
    }else if ([self.visibleViewController isKindOfClass:NSClassFromString(@"FSActionPlanSettingViewController")]){
        return YES;
    }else if ([self.visibleViewController isKindOfClass:NSClassFromString(@"FSActionEditCondictionViewController")]){
        return YES;
    }else if ([self.visibleViewController isKindOfClass:NSClassFromString(@"FSAddPortfolioShortViewController")]){
        return YES;
    }else if ([self.visibleViewController isKindOfClass:NSClassFromString(@"FSInvestedViewController")]){
        return YES;
    }else if ([self.visibleViewController isKindOfClass:NSClassFromString(@"FSInvestedViewController")]){
        return YES;
    }else if ([self.visibleViewController isKindOfClass:NSClassFromString(@"FSAddFundsViewController")]){
        return YES;
    }else if ([self.visibleViewController isKindOfClass:NSClassFromString(@"FSAddToPerformanceViewController")]){
        return YES;
    }else if([self.visibleViewController isKindOfClass:NSClassFromString(@"FSRootViewController")]){
        return YES;
    }else if([self.visibleViewController isKindOfClass:NSClassFromString(@"DrawAndScrollController")]){
        return YES;
    }else if([self.visibleViewController isKindOfClass:NSClassFromString(@"FSLauncherPageViewController")]){
        return YES;
    }else if([self.visibleViewController isKindOfClass:NSClassFromString(@"FSTradeViewController")]){
        return YES;
    }else if([self.visibleViewController isKindOfClass:NSClassFromString(@"FSAddActionPlanSettingViewController")]){
        return YES;
    }
#endif
    return NO;//[self.visibleViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    if([self.visibleViewController isKindOfClass:NSClassFromString(@"FSLauncherPageViewController")] || [self.visibleViewController isKindOfClass:NSClassFromString(@"FSRootViewController")]){
        return UIInterfaceOrientationMaskPortrait;
    }else if ([self.visibleViewController isKindOfClass:NSClassFromString(@"NetWorthViewController")]){
        return UIInterfaceOrientationMaskLandscape;
    }else{
        return self.visibleViewController.supportedInterfaceOrientations;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    if ([[FSFonestock sharedInstance] checkNeedShowAdvertise]) {
//        if ([viewController isKindOfClass:NSClassFromString(@"FSLauncherPageViewController")]) {
//            if(popFullAdFlag){
//                [gad_interstitial presentFromRootViewController:self.topViewController];
//                popFullAdFlag = NO;
//                [self popGoogleFullAd];
//            }
//        }
//    }
//    [super pushViewController:viewController animated:animated];
//}

//- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
//    NSArray *viewControllers = [self viewControllers];
//    if ([viewControllers count] > 1) {
//        if ([[viewControllers objectAtIndex:[viewControllers count] - 2] isKindOfClass:NSClassFromString(@"FSLauncherPageViewController")]) {
//            if ([[FSFonestock sharedInstance] checkNeedShowAdvertise]) {
//                if(popFullAdFlag){
//                   [gad_interstitial presentFromRootViewController:self.topViewController];
//                    popFullAdFlag = NO;
//                    [self popGoogleFullAd];
//                }
//            }
//            //[self setScreen];
//            //self.gAdView.hidden = YES;
////            if ([[FSFonestock sharedInstance] checkNeedShowAdvertise]) {
////                if(popFullAdFlag){
////                    [gad_interstitial presentFromRootViewController:self.topViewController];
////                    popFullAdFlag = NO;
////                    [self popGoogleFullAd];
////                }
////            }
//        }
////        if([[viewControllers objectAtIndex:[viewControllers count] - 2] isKindOfClass:NSClassFromString(@"FigureSearchResultViewController")]|| [[viewControllers objectAtIndex:[viewControllers count] - 2] isKindOfClass:NSClassFromString(@"FSWatchlistViewController")]|[[viewControllers objectAtIndex:[viewControllers count] - 2] isKindOfClass:NSClassFromString(@"EODActionController")]){
////            [self setScreen];
////        }
////            self.view.frame  = [UIApplication sharedApplication].keyWindow.bounds;
//    }
//    return [super popViewControllerAnimated:animated];
//}


//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    [self.gAdView loadRequest:[GADRequest request]];
//    if([[FSFonestock sharedInstance] checkNeedShowAdvertise]){
//        if ([viewController isKindOfClass:NSClassFromString(@"FSLauncherPageViewController")] || ![viewController isKindOfClass:NSClassFromString(@"FSEquityDrawViewController")]) {
//            [self insideBannerAd];
//        }
//        if ([viewController isKindOfClass:NSClassFromString(@"FSMainViewController")]){
//            FSMainViewController *mainView = (FSMainViewController *)viewController;
//            if([mainView.mainViewController isKindOfClass:NSClassFromString(@"FSEquityDrawViewController")] || [mainView.mainViewController isKindOfClass:NSClassFromString(@"DrawAndScrollController")]){
//                self.view.frame  = [UIApplication sharedApplication].keyWindow.bounds;
//                self.gAdView.hidden = YES;
//            }
//            if (![mainView.mainViewController isKindOfClass:NSClassFromString(@"FSEquityDrawViewController")]) {
//                if(![mainView.mainViewController isKindOfClass:NSClassFromString(@"DrawAndScrollController")]){
//                    if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
//                        if(self.navigationBarHidden){
//                            self.topViewController.view.frame = CGRectMake(0, 0, self.topViewController.view.bounds.size.width, self.topViewController.view.bounds.size.height-32);
//                            self.gAdView.adSize = kGADAdSizeSmartBannerPortrait;
//                            self.gAdView.frame = CGRectMake(0, self.view.bounds.size.height-32 ,self.view.bounds.size.width, 50);
//                        }else{
//                            self.topViewController.view.frame = CGRectMake(0, 52, self.topViewController.view.bounds.size.width, self.topViewController.view.bounds.size.height-32);
//                            self.gAdView.adSize = kGADAdSizeSmartBannerLandscape;
//                            self.gAdView.frame = CGRectMake(0,self.view.bounds.size.height-32 , self.view.bounds.size.width, 32);
//                        }
//                    }else{
//                        if(self.navigationBarHidden){
//                            self.topViewController.view.frame = CGRectMake(0, 0, self.topViewController.view.bounds.size.width, self.topViewController.view.bounds.size.height-50);
//                            self.gAdView.adSize = kGADAdSizeSmartBannerPortrait;
//                            self.gAdView.frame = CGRectMake(0, self.view.bounds.size.height-50 ,self.view.bounds.size.width, 50);
//                        }else{
//                            self.topViewController.view.frame = CGRectMake(0, 64, self.topViewController.view.bounds.size.width, self.topViewController.view.bounds.size.height-50);
//                            self.gAdView.adSize = kGADAdSizeSmartBannerPortrait;
//                            self.gAdView.frame = CGRectMake(0, self.view.bounds.size.height-50 ,self.view.bounds.size.width, 50);
//                        }
//                    }
//                    self.gAdView.hidden = NO;
//                }
//            }
//        }else{
//            if(![viewController isKindOfClass:NSClassFromString(@"FSLauncherPageViewController")]){
//                self.gAdView.hidden = NO;
//    
//                if( [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft){
//                    self.topViewController.view.frame = CGRectMake(0, 52, self.topViewController.view.bounds.size.width, self.topViewController.view.bounds.size.height-32);
//                    self.gAdView.adSize = kGADAdSizeSmartBannerLandscape;
//                    self.gAdView.frame = CGRectMake(0,self.view.bounds.size.height-32 , self.view.bounds.size.width, 32);
//                }else if([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight){
//                    if(self.navigationBarHidden){
//                        self.topViewController.view.frame = CGRectMake(0, 0, self.topViewController.view.bounds.size.width, self.topViewController.view.bounds.size.height-32);
//                        self.gAdView.adSize = kGADAdSizeSmartBannerPortrait;
//                        self.gAdView.frame = CGRectMake(0, self.view.bounds.size.height-32 ,self.view.bounds.size.width, 50);
//                    }else{
//                        self.topViewController.view.frame = CGRectMake(0, 52, self.topViewController.view.bounds.size.width, self.topViewController.view.bounds.size.height-32);
//                        self.gAdView.adSize = kGADAdSizeSmartBannerLandscape;
//                        self.gAdView.frame = CGRectMake(0,self.view.bounds.size.height-32 , self.view.bounds.size.width, 32);
//                    }
//                }else{
//                    if(self.navigationBarHidden){
//                        self.topViewController.view.frame = CGRectMake(0, 0, self.topViewController.view.bounds.size.width, self.topViewController.view.bounds.size.height-50);
//                        self.gAdView.adSize = kGADAdSizeSmartBannerPortrait;
//                        self.gAdView.frame = CGRectMake(0, self.view.bounds.size.height-50 ,self.view.bounds.size.width, 50);
//                    }else{
//                        self.topViewController.view.frame = CGRectMake(0, 64, self.topViewController.view.bounds.size.width, self.topViewController.view.bounds.size.height-50);
//                        self.gAdView.adSize = kGADAdSizeSmartBannerPortrait;
//                        self.gAdView.frame = CGRectMake(0, self.view.bounds.size.height-50 ,self.view.bounds.size.width, 50);
//                    }
//                }
//            }else{
//                self.gAdView.hidden = YES;
//                self.view.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
//            }
//        
//        }
//    }
//}

//- (void)popGoogleFullAd {
//    gad_interstitial = [[GADInterstitial alloc] init];
//    gad_interstitial.delegate = self;
//    gad_interstitial.adUnitID = @"ca-app-pub-4455304471526605/2340677577";  // Pattern Power iOS 插頁廣告
//    [gad_interstitial loadRequest:[GADRequest request]];
//}

//- (void)insideBannerAd {
//    originV = CGPointMake(0.0, self.view.window.frame.size.height - CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height);
//    originH = CGPointMake(0.0, self.view.window.frame.size.height - CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height);
//    if(self.gAdView==nil){
//        self.gAdView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait origin:originV];
//        self.gAdView.adUnitID = @"ca-app-pub-4455304471526605/2599859579";    // Pattern Power iOS 橫幅廣告
//        self.gAdView.rootViewController = self;
//        
//        [self.view addSubview:self.gAdView];
//    }
//    [self.gAdView loadRequest:[GADRequest request]];
//}

//- (GADRequest *)createTestRequest{
//    GADRequest *request = [GADRequest request];
//    request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, [FSFonestock uuid], nil];
//    return request;
//}
//
//- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
//    popFullAdFlag = YES;
//}

//- (void)gad_interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
//    
//}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    [self shareScreenToFB:[[UIApplication sharedApplication] keyWindow]];
}

- (void)shareScreenToFB:(UIView *)screenView {
    
    //建立對應社群網站的ComposeViewController
    SLComposeViewController *mySocialComposeView = [[SLComposeViewController alloc] init];
    mySocialComposeView = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];

    mySocialComposeView.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                [self shareFBNotificationToServer];
                break;
        }
    };
    
    //插入文字
    [mySocialComposeView setInitialText:@""];
    
    //插入網址
    NSURL *myURL = [[NSURL alloc] initWithString:@"http://www.fonestock.com/"];
    [mySocialComposeView addURL: myURL];
    
    
    //插入圖片
    UIImage *myImage = [self getImageFromView:screenView];
    [mySocialComposeView addImage:myImage];
    
    //呼叫建立的SocialComposeView
    [self presentViewController:mySocialComposeView animated:YES completion:^{
        NSLog(@"成功呼叫 SocialComposeView ");
    }];
}

- (UIImage *)getImageFromView:(UIView *)orgView{
    UIGraphicsBeginImageContext(orgView.bounds.size);
    [orgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)shareFBNotificationToServer {
    
    [FSHUD showGlobalProgressHUDWithTitle:@"Loading..."];
    
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"account"];
    NSString *url = [NSString stringWithFormat:@"%@?app_id=%@&account=%@",
                     [FSFonestock sharedInstance].FBShareNotificationURL,
                     [FSFonestock sharedInstance].appId,
                     account];
    
    NSMutableURLRequest *connectionRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [connectionRequest setTimeoutInterval:120.0];
	[connectionRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:connectionRequest returningResponse:nil error:&error];
    
    [FSHUD hideGlobalHUD];
    
    if (error == nil) {
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"贈送天期失敗" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            return;
        }
        
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *results = object;
            
            NSString *resCode = [results objectForKey:@"resCode"];
            if ([@"200" isEqualToString:resCode])
            {
                NSString *resMessage = [results objectForKey:@"resMessage"];
                [[[UIAlertView alloc] initWithTitle:resMessage message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                
            }
            else if ([@"204" isEqualToString:resCode])
            {
                // do nothing
            }
            else if ([@"500" isEqualToString:resCode])
            {
                [[[UIAlertView alloc] initWithTitle:@"贈送天期失敗" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
        
        
    }
}

-(void)setScreen
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

@end
