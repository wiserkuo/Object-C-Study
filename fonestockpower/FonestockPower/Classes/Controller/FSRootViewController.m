//
//  FSRootViewController.m
//  FonestockPower
//
//  Created by Connor on 14/3/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSRootViewController.h"
#import "FSLauncherViewController.h"
#import "UIView+NewComponent.h"
#import "FSSignupViewController.h"
#import "FSLoginViewController.h"
#import "FSAccountManager.h"
#import "FSMacros.h"
#import "FSLauncherPageViewController.h"
#import "FSLauncherCustomizeViewController.h"
#import "FSLauncherCustomizeAnalysisViewController.h"
#import "FSLauncherCustomizeServiceViewController.h"
#import "FSLauncherCustomizeNewsViewController.h"
#import "FSLauncherCustomizeDerivativeViewController.h"
#import "FSLauncherCustomizeDecisionViewController.h"
#import "FSLauncherCustomizeInfoViewController.h"
#import "FSNewMainLeftViewController.h"
#import "FSNewMainRightViewController.h"
#import "FSADViewController_1.h"
#import "FSADViewController_2.h"
#import "FSADViewController_3.h"
#import "FSADViewController_4.h"
#import "FSADViewController_5.h"
#import "MainPatternTipsViewController.h"
#import "FSUIButton.h"
#import "FSDataModelProc.h"
#import "ADSystem.h"

#define SIGNUP_BASEVIEW_BLUE_BACKGROUNDCOLOR [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.0f/255.0f green:177.0f/255.0f blue:233.0f/255.0f alpha:1.0] CGColor], (id)[[UIColor colorWithRed:180.0f/255.0f green:228.0f/255.0f blue:248.0f/255.0f alpha:1.0] CGColor], nil]
#define SIGNUP_BASEVIEW_YELLOW_BACKGROUNDCOLOR [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:244.0f/255.0f green:167.0f/255.0f blue:8.0f/255.0f alpha:1.0] CGColor], (id)[[UIColor colorWithRed:247.0f/255.0f green:213.0f/255.0f blue:10.0f/255.0f alpha:1.0] CGColor], nil]

@interface FSRootViewController() {
    UIView *mainView;
    UIImageView *logoView;
    UILabel *show14Days;
    FSUIButton *registerBtn;
    FSUIButton *loginBtn;
    UILabel *hintLabel;
    BOOL isLandscapeOK;
    int btnHeight;
    int labelFor14DaysAndBtn;
    NSInteger currentUsingType;
}
@end

@implementation FSRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkUsingType];
    [self setupBackground];
    [self setupLogoView];
    [self setupButtonAndLabelView];
}

- (void)checkUsingType
{
#ifdef PatternPowerTW
    currentUsingType = FSCurrentUsingTypeTW;
#elif PatternPowerUS
    currentUsingType = FSCurrentUsingTypeUS;
#elif PatternPowerCN
    currentUsingType = FSCurrentUsingTypeCN;
#elif StockPowerTW
    currentUsingType = FSCurrentUsingTypeSP;
#else
    currentUsingType = FSCurrentUsingTypeTips;
#endif
}


- (void)loginDefaultAccount {
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSAccountManager *accountManager = dataModel.accountManager;
    
#ifdef DivergenceTipsUS
    NSString *account, *password;
    account = @"ios.divus@tips.fonestock.com";
    password = @"312885";
    [accountManager setLoginFreeAccount:account password:password];
#elif DivergenceTipsCN
    NSString *account, *password;
    account = @"ios.divcn@tips.fonestock.com";
    password = @"315978";
    [accountManager setLoginFreeAccount:account password:password];
#elif DivergenceTipsTW
    NSString *account, *password;
    account = @"ios.divtw@tips.fonestock.com";
    password = @"772899";
    [accountManager setLoginFreeAccount:account password:password];
#elif PatternTipsUS
    NSString *account, *password;
    account = @"ios.patus@tips.fonestock.com";
    password = @"235938";
    [accountManager setLoginFreeAccount:account password:password];
#elif PatternTipsCN
    NSString *account, *password;
    account = @"ios.patcn@tips.fonestock.com";
    password = @"922238";
    [accountManager setLoginFreeAccount:account password:password];
#elif PatternTipsTW
    NSString *account, *password;
    account = @"ios.pattw@tips.fonestock.com";
    password = @"133958";
    [accountManager setLoginFreeAccount:account password:password];
    
    
    
#elif PatternPowerUS
    NSString *account, *password;
    account = @"ios.us@charttrade.fonestock.com";
    password = @"378678";
    [accountManager setLoginFreeAccount:account password:password];
#elif PatternPowerCN
    NSString *account, *password;
    account = @"ios.cn@charttrade.fonestock.com";
    password = @"666595";
    [accountManager setLoginFreeAccount:account password:password];
#else
    
    
    
    
    [accountManager reloadAccountAndPassword];
#endif
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 不顯示navigation
    self.navigationController.navigationBarHidden = YES;
    
    // 載入預設帳號
    [self loginDefaultAccount];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSAccountManager *accountManager = dataModel.accountManager;
    
    if ([accountManager isReadyLogin]) {
        FSLoginService *loginService = dataModel.loginService;

        // 登入中的提示訊息
        [FSHUD showGlobalProgressHUDWithTitle:NSLocalizedStringFromTable(@"登入中", @"AccountSetting", @"登入中, 請稍候")];
        
        
        [loginService loginAuth];
        
        FSLauncherPageViewController *page;
        
#ifdef StockPowerTW
        page = [FSLauncherPageViewController pageControlWithViewControllerClassName:@[@"FSLauncherCustomizeServiceViewController", @"FSLauncherCustomizeNewsViewController", @"FSLauncherCustomizeDerivativeViewController", @"FSLauncherCustomizeDecisionViewController", @"FSLauncherCustomizeAnalysisViewController", @"FSLauncherCustomizeInfoViewController"]];

#elif PatternPowerTW || PatternPowerUS || PatternPowerCN
        
        page = [FSLauncherPageViewController pageControlWithViewControllerClassName:@[@"FSNewMainLeftViewController",@"FSNewMainRightViewController", @"FSADViewController_1", @"FSADViewController_2"]];
        page.currentPage = 1;
        
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"us"]) {}

            
        
#elif PatternTipsUS || PatternTipsTW || PatternTipsCN || PatternTipsHK
        
        ADSystem *adSystem = [[ADSystem alloc]init];
        [adSystem getAdConnect];
        
        page = [FSLauncherPageViewController pageControlWithViewControllerClassName:@[@"MainPatternTipsViewController", @"FSADViewController_1", @"FSADViewController_2", @"FSADViewController_3", @"FSADViewController_4", @"FSADViewController_5"]];
        page.currentPage = 0;
        
#elif DivergenceTipsUS || DivergenceTipsTW || DivergenceTipsCN || DivergenceTipsHK
        
        ADSystem *adSystem = [[ADSystem alloc]init];
        [adSystem getAdConnect];
        
        page = [FSLauncherPageViewController pageControlWithViewControllerClassName:@[@"FSShowResultViewController", @"FSADViewController_1", @"FSADViewController_2", @"FSADViewController_3", @"FSADViewController_4", @"FSADViewController_5"]];
        page.currentPage = 0;
        
#endif

        [self.navigationController pushViewController:page animated:NO];

    }
}

- (void)setupBackground {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    
    // 由上到下的漸層顏色
    
    switch(currentUsingType){
        case FSCurrentUsingTypeTW:
        case FSCurrentUsingTypeUS:
        case FSCurrentUsingTypeCN:
            gradient.colors = SIGNUP_BASEVIEW_BLUE_BACKGROUNDCOLOR;
            [self.view.layer insertSublayer:gradient atIndex:0];
            break;
        default:
            gradient.colors = SIGNUP_BASEVIEW_YELLOW_BACKGROUNDCOLOR;
            [self.view.layer insertSublayer:gradient atIndex:0];
            break;
    }

    // 設定NavigationBar背景顏色
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:234.0/255.0 green:85.0/255.0 blue:4.0/255.0 alpha:1.0]];
    } else {
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:234.0/255.0 green:85.0/255.0 blue:4.0/255.0 alpha:1.0]];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    }
    // 設定NavigationBar不透明
    [self.navigationController.navigationBar setTranslucent:NO];
    
    mainView = [[UIView alloc] init];
    mainView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(mainView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-85-[mainView(250)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(mainView)]];
//#endif
}

-(void)theOldSetupSignupImageMethod:(UIImageView*)countryImg offset:(int *)constrantOffset;
{
#ifdef PatternPowerUS
    // 設定美國國旗
    logoView.image = [UIImage imageNamed:@"AppLogo"];
#elif DivergenceTipsUS || PatternTipsUS
    //設定美國國旗
    //    countryImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"美國國旗"]];
    logoView.image = [UIImage imageNamed:@"綠紅雙線"];
    *constrantOffset = 0;
#elif DivergenceTipsTW || PatternTipsTW
    // 設定台灣國旗
    countryImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"現已不需國旗圖"]];
    logoView.image = [UIImage imageNamed:@"時機操盤手"];
    *constrantOffset = -30;
#elif PatternPowerTW
    countryImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"現已不需國旗圖"]];
    logoView.image = [UIImage imageNamed:@"AppLogo"];
    *constrantOffset = -30;
#elif StockPowerTW
    // 設定台灣國旗
    countryImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"現已不需國旗圖"]];
    logoView.image = [UIImage imageNamed:@"TWGoingUp"];
    *constrantOffset = -50;
#elif PatternPowerCN || DivergenceTipsCN || PatternTipsCN || PatternTipsHK
    *constrantOffset = -50;
    countryImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"現已不需國旗圖"]];
    logoView.image = [UIImage imageNamed:@"AppLogo"];
#endif
}

- (void)setupLogoView {
    int constrantOffset = 0;
    logoView = [[UIImageView alloc] init];
    logoView.translatesAutoresizingMaskIntoConstraints = NO;
    [mainView addSubview:logoView];
    //以前的方法，現改用switch case所以先將其註解起來
//    [self theOldSetupSignupImageMethod:countryImg offset:&constrantOffSet];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    switch(currentUsingType){
        case FSCurrentUsingTypeTW:
            logoView.image = [UIImage imageNamed:@"AppLogo"];
            constrantOffset = -100;
            // 置中
            [mainView addConstraint:[NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
            break;
        case FSCurrentUsingTypeUS:
            logoView.image = [UIImage imageNamed:@"AppLogo"];
            [mainView addConstraint:[NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-65]];
            [mainView addConstraint:[NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
            [mainView addConstraint:[NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20]];
            [mainView addConstraint:[NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:constrantOffset]];
            constrantOffset = 0;
            break;
        case FSCurrentUsingTypeCN:
            constrantOffset = -100;
            logoView.image = [UIImage imageNamed:@"AppLogo"];
            // 置中
            [mainView addConstraint:[NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
            break;
        case FSCurrentUsingTypeTips:
            //目前tips 不需要註冊頁面
            break;
        case FSCurrentUsingTypeSP:
            logoView.image = [UIImage imageNamed:@"TWGoingUp"];
            constrantOffset = -50;
            break;
        default:
            break;
    }

    NSLog(@"screenBounds %.0f",screenBounds.size.height);
    
    // 垂直
    if(currentUsingType == FSCurrentUsingTypeUS)return;
    if(screenBounds.size.height < 500){
        [mainView addConstraint:[NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }else if(screenBounds.size.height < 660){
        [mainView addConstraint:[NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:constrantOffset]];
    }else{
        [mainView addConstraint:[NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-100]];
    }
    
    // 寬度限制
    [mainView addConstraint:[NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:598/2]];
    
    // 高度限制
    [mainView addConstraint:[NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:652/2]];
    
    
//#endif
}

- (BOOL)shouldAutorotate {
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setupButtonAndLabelView {
    
    show14Days = [[UILabel alloc] init];
    show14Days.text = NSLocalizedStringFromTable(@"本產品提供14天試用期", @"Launcher", nil);
    show14Days.translatesAutoresizingMaskIntoConstraints = NO;
    show14Days.textAlignment = NSTextAlignmentCenter;
    show14Days.font = [UIFont systemFontOfSize:16.0];
    [self.view addSubview:show14Days];
    
    registerBtn = [self.view newButton:FSUIButtonTypeNormalRed];
    [registerBtn setTitle:NSLocalizedStringFromTable(@"加入會員", @"Launcher", nil) forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    registerBtn.titleLabel.numberOfLines = 0;
    registerBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [registerBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    loginBtn = [self.view newButton:FSUIButtonTypeNormalRed];
    [loginBtn setTitle:NSLocalizedStringFromTable(@"登入", @"Launcher", nil) forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *metrics = @{@"labelWidth":[NSNumber numberWithFloat:self.view.frame.size.width]};

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:show14Days attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[show14Days(labelWidth)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(show14Days)]];
    switch(currentUsingType){
        case FSCurrentUsingTypeUS:
            if([[UIScreen mainScreen] bounds].size.height == 480){
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[show14Days(35)]-55-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(show14Days)]];
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[loginBtn(50)]-7-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(show14Days, loginBtn, registerBtn)]];
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[registerBtn(50)]-7-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(loginBtn, registerBtn, show14Days)]];
            }else{
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[show14Days(35)]-120-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(show14Days)]];
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[loginBtn(55)]-65-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(show14Days, loginBtn, registerBtn)]];
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[registerBtn(55)]-65-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(loginBtn, registerBtn, show14Days)]];
            }
            break;
        case FSCurrentUsingTypeCN:
            if([[UIScreen mainScreen] bounds].size.height > 660){
                registerBtn.titleLabel.font = [UIFont systemFontOfSize:26.0f];
                loginBtn.titleLabel.font = [UIFont systemFontOfSize:26.0f];
                show14Days.font = [UIFont systemFontOfSize:20.0f];
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[show14Days(60)]-90-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(show14Days)]];
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[loginBtn(50)]-40-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(show14Days, loginBtn, registerBtn)]];
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[registerBtn(50)]-40-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(loginBtn, registerBtn, show14Days)]];
            }else{
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[show14Days(35)]-40-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(show14Days)]];
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[loginBtn(34)]-10-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(show14Days, loginBtn, registerBtn)]];
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[registerBtn(34)]-10-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(loginBtn, registerBtn, show14Days)]];
            }
            break;
        case FSCurrentUsingTypeTW:
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[show14Days(35)]-55-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(show14Days)]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[loginBtn(34)]-25-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(show14Days, loginBtn, registerBtn)]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[registerBtn(34)]-25-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(loginBtn, registerBtn, show14Days)]];
            break;
        default:
            break;
    }

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[registerBtn(loginBtn)]-10-[loginBtn]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(loginBtn,registerBtn)]];
}

- (void)clickButton:(UIButton *)btn {
    if (btn == registerBtn) {
        // 第一次使用, 註冊
        FSSignupViewController *webview = [[FSSignupViewController alloc] init];
        [self.navigationController pushViewController:webview animated:NO];
    } else if (btn == loginBtn) {
        
        FSAccountManager *a = [FSAccountManager sharedInstance];
        
        FSLoginViewController *loginViewController = [[FSLoginViewController alloc] initWithAccount:a.account AndPassword:a.password];
        loginViewController.hasBackButton = YES;
        [self.navigationController pushViewController:loginViewController animated:NO];
    }
}


@end
