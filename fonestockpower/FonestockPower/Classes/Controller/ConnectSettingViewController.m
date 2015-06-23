//
//  ConnectSettingViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/6/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "ConnectSettingViewController.h"
#import "ZJSwitch.h"
#import "FSUIButton.h"
#import "FSDataModelProc.h"
#import "FSLoginService.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSPaymentViewController.h"
#import "FSForgetPWViewController.h"

#define IS_IOS8 [[UIDevice currentDevice] systemVersion].floatValue >= 8.0

@interface ConnectSettingViewController ()<UITextFieldDelegate, UIAlertViewDelegate>
{
    
    UILabel *statusTitleLabel;
    UILabel *accountLabel;
    UILabel *passwordLabel;
    ZJSwitch *connectSwitch;
    UILabel *versionLabel;
    UILabel *versionTitleLabel;
    UILabel *statusLabel;
    UITextField *accountText;
    UITextField *passwordText;
    FSUIButton *msgButton;
    UILabel *bottomLabel;
    FSUIButton *forgetBtn;
    FSDataModelProc *model;
}
@end

@implementation ConnectSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpImageBackButton];
    self.title = NSLocalizedStringFromTable(@"連線設定", @"AccountSetting", nil);
    [self initElement];
    [self initDataModel];
    
    [self.view setNeedsUpdateConstraints];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginAuthCallBackNotification:) name:@"loginAuthStatus" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(void)initElement
{
    versionTitleLabel = [[UILabel alloc]init];
    versionTitleLabel.text = NSLocalizedStringFromTable(@"版本資訊", @"AccountSetting", nil);
    versionTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:versionTitleLabel];
    
    versionLabel = [[UILabel alloc] init];
    versionLabel.text = [NSString stringWithFormat:@"V%@", [FSFonestock appFullVersion]];
    versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:versionLabel];
    
    statusTitleLabel = [[UILabel alloc]init];
    statusTitleLabel.text = NSLocalizedStringFromTable(@"狀態", @"AccountSetting", nil);
    statusTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:statusTitleLabel];
    
    statusLabel = [[UILabel alloc]init];
    statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:statusLabel];
    
    accountLabel = [[UILabel alloc] init];
    accountLabel.text = NSLocalizedStringFromTable(@"帳號", @"AccountSetting", nil);
    accountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:accountLabel];
    
    accountText = [[UITextField alloc] init];
    accountText.delegate = self;
    accountText.layer.cornerRadius = 5.0;
    accountText.layer.borderWidth = 1;
    accountText.borderStyle = UITextBorderStyleRoundedRect;
    accountText.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:accountText];
    
    passwordLabel = [[UILabel alloc] init];
    passwordLabel.text = NSLocalizedStringFromTable(@"密碼", @"AccountSetting", nil);
    passwordLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:passwordLabel];
    
    passwordText = [[UITextField alloc] init];
    passwordText.delegate = self;
    passwordText.secureTextEntry = YES;
    passwordText.layer.cornerRadius = 5.0;
    passwordText.layer.borderWidth = 1;
    passwordText.borderStyle = UITextBorderStyleRoundedRect;
    passwordText.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:passwordText];
    
    connectSwitch = [[ZJSwitch alloc] init];
    connectSwitch.onText = NSLocalizedStringFromTable(@"登出", @"AccountSetting", nil);
    connectSwitch.offText = NSLocalizedStringFromTable(@"登入", @"AccountSetting", nil);
    [connectSwitch addTarget:self action:@selector(switchHandler:) forControlEvents:UIControlEventValueChanged];
    connectSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:connectSwitch];
    
    msgButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    [msgButton setTitle:NSLocalizedStringFromTable(@"服務訊息", @"AccountSetting", nil) forState:UIControlStateNormal];
    [msgButton addTarget:self action:@selector(infoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    msgButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:msgButton];
    
    bottomLabel = [[UILabel alloc] init];
    bottomLabel.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:66.0/255.0 blue:0 alpha:1];
    [bottomLabel setTextColor:[UIColor whiteColor]];
    bottomLabel.text = NSLocalizedStringFromTable(@"客服電話new", @"AccountSetting", nil);
    bottomLabel.numberOfLines = 2;
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bottomLabel];
    
    forgetBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    [forgetBtn setTitle:NSLocalizedStringFromTable(@"忘記密碼", @"AccountSetting", nil) forState:UIControlStateNormal];
    forgetBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [forgetBtn addTarget:self action:@selector(forgetHandler:) forControlEvents:UIControlEventTouchUpInside];
    forgetBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:forgetBtn];
}

-(void)initDataModel
{
    model = [FSDataModelProc sharedInstance];
    accountText.text = model.accountManager.account;
    passwordText.text = model.accountManager.password;
    if(!model.mainSocket.isConnected || model.isRejectReLogin){
        connectSwitch.on = NO;
        accountText.enabled = YES;
        passwordText.enabled = YES;
        statusLabel.text = NSLocalizedStringFromTable(@"未登入", @"AccountSetting", nil);
    }else{
        connectSwitch.on = YES;
        accountText.enabled = NO;
        passwordText.enabled = NO;
        statusLabel.text = NSLocalizedStringFromTable(@"已登入", @"AccountSetting", nil);
    }
}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    NSDictionary *viewController = NSDictionaryOfVariableBindings(statusLabel, statusTitleLabel, accountLabel, accountText, passwordLabel, passwordText, connectSwitch, msgButton, bottomLabel, forgetBtn, versionTitleLabel, versionLabel);
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[statusTitleLabel(30)]-20-[accountLabel(30)]-20-[passwordLabel(30)]-20-[versionTitleLabel(30)]" options:0 metrics:nil views:viewController]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[statusLabel(30)]-20-[accountText(30)]-20-[passwordText(30)]-20-[versionLabel(30)]-20-[connectSwitch(30)]" options:0 metrics:nil views:viewController]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[msgButton][bottomLabel(30)]|" options:0 metrics:nil views:viewController]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[versionTitleLabel(100)]-5-[versionLabel(150)]" options:0 metrics:nil views:viewController]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[statusTitleLabel(100)]-5-[statusLabel(150)]" options:0 metrics:nil views:viewController]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[accountLabel(==statusTitleLabel)]-5-[accountText(150)]" options:0 metrics:nil views:viewController]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[passwordLabel(==statusTitleLabel)]-5-[passwordText(150)]" options:0 metrics:nil views:viewController]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-100-[connectSwitch]-100-|" options:0 metrics:nil views:viewController]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[forgetBtn][msgButton(forgetBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[forgetBtn(35)]" options:0 metrics:nil views:viewController]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[msgButton(forgetBtn)]" options:0 metrics:nil views:viewController]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomLabel]|" options:0 metrics:nil views:viewController]];
    
    [self replaceCustomizeConstraints:constraints];
}

-(void)switchHandler:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    if([switchButton isOn]){
        //當switch 為選取狀態時
        accountText.enabled = NO;
        passwordText.enabled = NO;
        if(!model.mainSocket.isConnected){
            statusLabel.text = NSLocalizedStringFromTable(@"未登入", @"AccountSetting", nil);
            [self loginHandler];
        }else{
            statusLabel.text = NSLocalizedStringFromTable(@"已登入", @"AccountSetting", nil);
        }
    }else{
        //當switch 為非選取狀態時
        [model.mainSocket disconnect];
        [model.loginService disconnect];
        [self someDelayMethod];
//        connectSwitch.on = NO;
//        accountText.enabled = YES;
//        passwordText.enabled = YES;
//        statusLabel.text = NSLocalizedStringFromTable(@"未登入", @"AccountSetting", nil);
    }
}

- (void)loginHandler {
    
    if ([accountText.text isEqualToString:@""] || [passwordText.text isEqualToString:@""]) {
        if (IS_IOS8) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"請輸入帳號密碼", @"AccountSetting", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"確認", @"AccountSetting", nil) style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"請輸入帳號密碼", @"AccountSetting", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"AccountSetting", nil) otherButtonTitles:nil, nil];
            [alert show];
            [self someDelayMethod];
        }
        
        [connectSwitch setOn:NO animated:YES];
        
        return;
    }
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    dataModel.isRejectReLogin = NO;
    connectSwitch.enabled = NO;
    [model.accountManager setLoginAccount:[accountText.text lowercaseString] password:passwordText.text];
    [model.loginService disconnectReloginAuth];
}

- (void)loginAuthCallBackNotification:(NSNotification *)notification {
    //登入動作執行完畢後傳送通知至此，以改變顯示的登入狀態
    FSLoginResultType authResultType = [(NSNumber *)[notification object] intValue];
    if(authResultType == FSLoginResultTypeBeKickedOut){
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        dataModel.isRejectReLogin = YES;
        statusLabel.text = NSLocalizedStringFromTable(@"未登入", @"AccountSetting", nil);
        [connectSwitch setOn:NO animated:YES];
    }else if (authResultType == FSLoginResultTypeAuthLoginSuccess) {
        statusLabel.text = NSLocalizedStringFromTable(@"已登入", @"AccountSetting", nil);
        [connectSwitch setOn:YES animated:YES];
    }else if(authResultType == FSLoginResultTypeStopContinuousReLogin){
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        dataModel.isRejectReLogin = YES;
        [self performSelector:@selector(someDelayMethod) withObject:nil afterDelay:1];
    }else{
        [self someDelayMethod];
    }
    connectSwitch.enabled = YES;
}

-(void)someDelayMethod
{
    accountText.enabled = YES;
    passwordText.enabled = YES;
    statusLabel.text = NSLocalizedStringFromTable(@"未登入", @"AccountSetting", nil);
    [connectSwitch setOn:NO animated:YES];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)clearHandler:(UIButton*)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"要清除盤後資料嗎", @"AccountSetting", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"AccountSetting", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確認", @"AccountSetting", nil), nil];
    alertView.tag = 2;
    [alertView show];
}

-(void)forgetHandler:(UIButton*)sender
{
    FSForgetPWViewController *fogg = [[FSForgetPWViewController alloc] init];
    [self.navigationController pushViewController:fogg animated:NO];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 2) {
        if (buttonIndex==1){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"盤後資料清除完畢", @"AccountSetting", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"AccountSetting", nil) otherButtonTitles:nil];
            [alertView show];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if([fileManager fileExistsAtPath:[CodingUtil techLineDataDirectoryPath]]    ){
                [fileManager removeItemAtPath:[CodingUtil techLineDataDirectoryPath] error:nil];
            }
        }
    }
    else {
        if(buttonIndex == 1){
            FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
            FSFonestock *fonestock = [FSFonestock sharedInstance];
            
            NSString *paymentFullURL = [NSString stringWithFormat:@"%@?acc_id=%@&app_id=%@&lang=%@&request_iap=1&forapp=1", fonestock.paymentPageURL, loginService.account, fonestock.appId, fonestock.lang];
            
            
            FSPaymentViewController *paymentWebView = [[FSPaymentViewController alloc] initWithPaymentURL:paymentFullURL];
            
            [self.navigationController pushViewController:paymentWebView animated:NO];
        }
    }
    
}

- (void)infoBtnClick:(id)sender {
    FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
    
    NSDateFormatter *formatterLocal = [[NSDateFormatter alloc] init];
    [formatterLocal setDateFormat:@"yyyy-MM-dd"];
    [formatterLocal setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSString *dueDateAlertString;
    if (loginService.serviceDueDateTimeUTC) {
        dueDateAlertString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"您的使用期限至(%@)", @"Launcher", @"您的使用期限至(%@)"),[formatterLocal stringFromDate:loginService.serviceDueDateTimeUTC]];
    }
    else {
        dueDateAlertString = NSLocalizedStringFromTable(@"無服務訊息", @"Launcher", @"無服務訊息");
    }
    
    if(IS_IOS8){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:dueDateAlertString message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"確認", @"AccountSetting", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                message:dueDateAlertString
                                               delegate:self
                                      cancelButtonTitle:
                                  NSLocalizedStringFromTable(@"確認", @"Launcher", nil)
                                                  otherButtonTitles:nil, nil];
        alertView.tag = 1;
        [alertView show];
    }
}


@end
