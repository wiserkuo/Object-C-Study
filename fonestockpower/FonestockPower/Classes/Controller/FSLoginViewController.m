//
//  FSLoginViewController.m
//  FonestockPower
//
//  Created by Connor on 14/3/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLoginViewController.h"
#import "FSUIButton.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSLauncherViewController.h"
#import "FSAccountManager.h"
#import "FSLauncherPageViewController.h"
#import "FSWebViewController.h"
#import "FSForgetPWViewController.h"
#import "FSShowResultViewController.h"
#import "FSADViewController_1.h"
#import "FSADViewController_2.h"

@interface FSLoginViewController () <UITextFieldDelegate> {
    NSString *_account;
    NSString *_password;
    UITextField *accountTextField;
    UITextField *passwordTextField;
}
@end

@implementation FSLoginViewController

- (instancetype)initWithAccount:(NSString *)account AndPassword:(NSString *)password {
    if (self = [super init]) {
        _account = account;
        _password = password;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    [self setUpImageBackButton];
    [self initView];
    /*
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"圖是力", @"Launcher", nil)];
    [self.navigationItem setHidesBackButton:YES];
    
    
    UILabel *accountLabel = [[UILabel alloc] init];
    [accountLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [accountLabel setTextAlignment:NSTextAlignmentRight];
    [accountLabel setText:NSLocalizedStringFromTable(@"Account", @"Launcher", @"登入帳號")];
    [self.view addSubview:accountLabel];
    
    UILabel *passwordLabel = [[UILabel alloc] init];
    [passwordLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [passwordLabel setTextAlignment:NSTextAlignmentRight];
    [passwordLabel setText:NSLocalizedStringFromTable(@"Password", @"Launcher", @"登入密碼")];
    [self.view addSubview:passwordLabel];
    
    accountTextField = [[UITextField alloc] init];
    [accountTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [accountTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [accountTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [accountTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [accountTextField setDelegate:self];
    [accountTextField setText:_account];
    [self.view addSubview:accountTextField];
    
    passwordTextField = [[UITextField alloc] init];
    [passwordTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [passwordTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [passwordTextField setDelegate:self];
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setText:_password];
    [self.view addSubview:passwordTextField];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-22-[accountLabel(80)]-10-[accountTextField]-22-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(accountLabel, accountTextField)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-22-[passwordLabel(80)]-10-[passwordTextField]-22-|" options:NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom metrics:nil views:NSDictionaryOfVariableBindings(passwordLabel, passwordTextField)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-66-[accountLabel]-22-[passwordLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(accountLabel, passwordLabel)]];

    
    FSUIButton *loginButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    [loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [loginButton setTitle:NSLocalizedStringFromTable(@"立即登入", @"Launcher", @"登入按鈕文字") forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    UIButton *forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [forgotPasswordButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [forgotPasswordButton setTitle:NSLocalizedStringFromTable(@"忘記密碼", @"Launcher", @"忘記密碼按鈕文字") forState:UIControlStateNormal];
    [forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgotPasswordButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[passwordLabel]-22-[loginButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(passwordLabel, loginButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-22-[loginButton]-22-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(loginButton)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[loginButton]-20-[forgotPasswordButton]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(loginButton, forgotPasswordButton)]];
    
    
    UILabel *hintMsg = [[UILabel alloc] init];
    [hintMsg setTranslatesAutoresizingMaskIntoConstraints:NO];
    [hintMsg setTextAlignment:NSTextAlignmentCenter];
    [hintMsg setNumberOfLines:0];
    [hintMsg setText:NSLocalizedStringFromTable(@"產品提示文字", @"Launcher", @"提示訊息")];
    [self.view addSubview:hintMsg];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[forgotPasswordButton]-[hintMsg]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(forgotPasswordButton, hintMsg)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-22-[hintMsg]-22-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(hintMsg)]];
    
    UILabel *phoneMsg = [[UILabel alloc] init];
    [phoneMsg setTranslatesAutoresizingMaskIntoConstraints:NO];
    [phoneMsg setTextAlignment:NSTextAlignmentCenter];
    [phoneMsg setBackgroundColor:[UIColor colorWithRed:206.0/255.0 green:73.0/255.0 blue:151.0/255.0 alpha:1.0]];
    [phoneMsg setTextColor:[UIColor whiteColor]];
    [phoneMsg setText:NSLocalizedStringFromTable(@"客服電話", @"Launcher", @"客服電話")];
    [phoneMsg setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:phoneMsg];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[phoneMsg(33)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(phoneMsg)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[phoneMsg]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(phoneMsg)]];
     */
}

-(void)initView
{
    [self.view setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]];
    [self.navigationController setNavigationBarHidden:NO];
#ifdef PatternPowerTW
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"圖是力", @"Launcher", nil)];
#elif DivergenceTipsTW || DivergenceTipsUS || DivergenceTipsCN || DivergenceTipsHK
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"背離力", @"DivergenceTips", nil)];
#elif PatternTipsTW || PatternTipsUS || PatternTipsCN || PattnerTipsHK
     [self.navigationItem setTitle:NSLocalizedStringFromTable(@"時機小秘", @"DivergenceTips", nil)];
#else
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"圖是力", @"Launcher", nil)];
#endif
    [self.navigationItem setHidesBackButton:YES];
    
    accountTextField = [[UITextField alloc] init];
    [accountTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [accountTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [accountTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [accountTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [accountTextField setDelegate:self];
    [accountTextField setPlaceholder:NSLocalizedStringFromTable(@"email帳號", @"Launcher", nil)];
    [accountTextField setText:_account];
    [self.view addSubview:accountTextField];
    
    passwordTextField = [[UITextField alloc] init];
    [passwordTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [passwordTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [passwordTextField setDelegate:self];
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setPlaceholder:NSLocalizedStringFromTable(@"密碼", @"Launcher", nil)];
    [passwordTextField setText:_password];
    [self.view addSubview:passwordTextField];
    
    UITapGestureRecognizer *tapForLogin = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginAction:)];
    UILabel *loginLbl = [[UILabel alloc] init];
    loginLbl.translatesAutoresizingMaskIntoConstraints = NO;
    loginLbl.userInteractionEnabled = YES;
    [loginLbl addGestureRecognizer:tapForLogin];
    loginLbl.font = [UIFont boldSystemFontOfSize:16.0];
    loginLbl.textAlignment = NSTextAlignmentCenter;
    loginLbl.textColor = [UIColor blackColor];
    loginLbl.text = NSLocalizedStringFromTable(@"登入", @"Launcher", nil);
    loginLbl.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    loginLbl.layer.borderColor = [UIColor grayColor].CGColor;
    loginLbl.layer.borderWidth = 1;
    [self.view addSubview:loginLbl];
    
    UITapGestureRecognizer *tapForForget = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgotPasswordButtonAction:)];
    UILabel *forgetLbl = [[UILabel alloc] init];
    forgetLbl.translatesAutoresizingMaskIntoConstraints = NO;
    forgetLbl.userInteractionEnabled = YES;
    [forgetLbl addGestureRecognizer:tapForForget];
    forgetLbl.font = [UIFont boldSystemFontOfSize:16.0];
    forgetLbl.textAlignment = NSTextAlignmentCenter;
    forgetLbl.textColor = [UIColor blackColor];
    forgetLbl.text = NSLocalizedStringFromTable(@"忘記密碼", @"Launcher", nil);
    forgetLbl.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    forgetLbl.layer.borderColor = [UIColor grayColor].CGColor;
    forgetLbl.layer.borderWidth = 1;
    [self.view addSubview:forgetLbl];
    
    UILabel *bottomLbl = [[UILabel alloc] init];
    bottomLbl.translatesAutoresizingMaskIntoConstraints = NO;
    bottomLbl.font = [UIFont systemFontOfSize:16.0];
    bottomLbl.textColor = [UIColor whiteColor];
    bottomLbl.text = NSLocalizedStringFromTable(@"客服電話new", @"Launcher", nil);
    bottomLbl.textAlignment = NSTextAlignmentCenter;
    bottomLbl.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:85.0/255.0 blue:4.0/255.0 alpha:1.0];
    [self.view addSubview:bottomLbl];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(accountTextField, passwordTextField, loginLbl, forgetLbl, bottomLbl);
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:accountTextField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[accountTextField(200)]" options:0 metrics:nil views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[passwordTextField(accountTextField)]" options:0 metrics:nil views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[loginLbl(accountTextField)]" options:0 metrics:nil views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[forgetLbl(accountTextField)]" options:0 metrics:nil views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[accountTextField(44)]-[passwordTextField(accountTextField)]-[loginLbl(accountTextField)]-[forgetLbl(accountTextField)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:allObj]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomLbl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomLbl]|" options:0 metrics:nil views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomLbl(35)]" options:0 metrics:nil views:allObj]];
}
// It works fine
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self.view endEditing:YES];
//}

//This works fine, too.
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UIView *txt in self.view.subviews){
        if([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]){
            [txt resignFirstResponder];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    
    // 登入狀態通知註冊
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginAuthCallBackNotification:) name:@"loginAuthStatus" object:nil];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [FSHUD hideGlobalHUD];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewWillDisappear:(BOOL)animated {
    // 登入狀態通知移除註冊
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loginAction:(id)sender {
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSAccountManager *accountManager = dataModel.accountManager;
    dataModel.isRejectReLogin = NO;
    NSString *account = [accountTextField text];
    NSString *password = [passwordTextField text];
    
    NSString *alertMsg;
    if ([@"" isEqualToString:account]) {
        alertMsg = NSLocalizedStringFromTable(@"沒有輸入帳號密碼", @"AccountSetting", nil);
    } else if ([@"" isEqualToString:password]) {
        alertMsg = NSLocalizedStringFromTable(@"沒有輸入帳號密碼", @"AccountSetting", nil);
    }
    
    if (alertMsg != nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:alertMsg delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"輸入錯誤的下方按鈕", @"AccountSetting", nil) otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [accountManager setLoginAccount:[[accountTextField text] lowercaseString] password:[passwordTextField text]];
    
    if ([accountManager isReadyLogin]) {
        FSLoginService *loginService = dataModel.loginService;
        [FSHUD showGlobalProgressHUDWithTitle:NSLocalizedStringFromTable(@"登入中", @"AccountSetting", nil)];
        [loginService loginAuth];
    }
    
}

- (void)forgotPasswordButtonAction:(id)sender {
    
    FSForgetPWViewController *forgotPWWebView = [[NSClassFromString(@"FSForgetPWViewController") alloc] init];
    [self.navigationController pushViewController:forgotPWWebView animated:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - 登入狀態通知
- (void)loginAuthCallBackNotification:(NSNotification *)notification {
    FSLoginResultType authResultType = [[notification object] intValue];
    
    if (authResultType == FSLoginResultTypeAuthLoginSuccess) {
//        FSLauncherPageViewController *page = [FSLauncherPageViewController pageControlWithViewControllerClassName:@[@"FSLauncherGuideViewController", @"FSLauncherViewController", @"FSLauncherNewsViewController"]];
        FSLauncherPageViewController *page;
#ifdef StockPowerTW
        page = [FSLauncherPageViewController pageControlWithViewControllerClassName:@[@"FSLauncherCustomizeServiceViewController", @"FSLauncherCustomizeNewsViewController", @"FSLauncherCustomizeDerivativeViewController", @"FSLauncherCustomizeDecisionViewController", @"FSLauncherCustomizeAnalysisViewController", @"FSLauncherCustomizeInfoViewController"]];

#elif DivergenceTipsUS || DivergenceTipsTW || DivergenceTipsCN || DivergenceTipsHK
        page = [FSLauncherPageViewController pageControlWithViewControllerClassName:@[@"FSShowResultViewController", @"FSADViewController_1", @"FSADViewController_2", @"FSADViewController_3", @"FSADViewController_4", @"FSADViewController_5"]];

        page.currentPage = 0;
//        FSShowResultViewController *fssrv = [[FSShowResultViewController alloc] init];
//        [self.navigationController pushViewController:fssrv animated:NO];
#elif PatternTipsUS || PatternTipsTW || PatternTipsCN || PatternTipsHK
        page = [FSLauncherPageViewController pageControlWithViewControllerClassName:@[@"MainPatternTipsViewController", @"FSADViewController_1", @"FSADViewController_2", @"FSADViewController_3", @"FSADViewController_4", @"FSADViewController_5"]];

        page.currentPage = 0;
#else
        page = [FSLauncherPageViewController pageControlWithViewControllerClassName:@[@"FSNewMainLeftViewController",@"FSNewMainRightViewController", @"FSADViewController_1", @"FSADViewController_2"]];
        page.currentPage = 1;
#endif
        
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController pushViewController:page animated:NO];
    }
}

@end
