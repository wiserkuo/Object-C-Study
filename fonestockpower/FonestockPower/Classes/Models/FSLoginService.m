//
//  FSLoginService.m
//  FonestockPower
//
//  Created by Connor on 14/4/1.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLoginService.h"
#import "FSPointsAuthCenter.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "FSSocketProc.h"
#import "FSLoginPacket.h"
#import "FSAccountManager.h"
#import "FSHUD.h"
#import "FSLauncherPageViewController.h"
#import "FSPaymentViewController.h"
#import "FSAppDelegate.h"
#import "FSLoginViewController.h"

#define IS_IOS8 [[UIDevice currentDevice] systemVersion].floatValue >= 8.0

@interface FSLoginService() <FSPointsAuthCenterDelegate, UIAlertViewDelegate> {
    NSString *accessToken;
    
    NSString *serviceServerIP;
    NSString *serviceServerPort;
    NSString *queryServerIP;
    NSString *queryServerPort;
    NSString *expiredAccessTokenDateTime;
    NSString *systemDateTime;
    UIAlertController *_alertController;
    UIAlertController *_alertControllerForReLoginCount;
    UIAlertView *_alertView;
    UIAlertView *_alertViewForReLoginCount;
    
    UILabel *msgLabelView;
    
    int ios8AlertTag;
}
@property (nonatomic, strong) UIView *toastView;
@end

@implementation FSLoginService

- (id)initWithAuthURLString:(NSString *)urlString {
    if (self = [super init]) {
        _fsAuthCenter = [[FSPointsAuthCenter alloc] initWithAuthURL:[NSURL URLWithString:urlString]];
        _loginCounter = 0;
        _aTarget = [[FSLauncherPageViewController alloc] init];
    }
    return self;
}

- (void)loginAuth {
    _loginCounter++;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    _loginResultType = FSLoginResultTypeNoLogin;
    
    if(dataModel.isRejectReLogin) return;
    [self loginAuthUsingSelfAccount];
}

- (void)disconnectReloginAuth {
    [FSHUD showGlobalProgressHUDWithTitle:NSLocalizedStringFromTable(@"Reconnecting...", @"Launcher", nil)];
    _loginResultType = FSLoginResultTypeNoLogin;
    
    _loginCounter++;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    if(_loginCounter == 10){
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        dataModel.isRejectReLogin = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAuthStatus" object:[NSNumber numberWithInteger:FSLoginResultTypeStopContinuousReLogin]];
        if(IS_IOS8){
            _alertControllerForReLoginCount = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromTable(@"登入失敗，請問是否重連", @"Launcher", nil) preferredStyle:UIAlertControllerStyleAlert];
            [_alertControllerForReLoginCount addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"否", @"Launcher", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){[self reLoginBtnBeClicked:1];}]];
            [_alertControllerForReLoginCount addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"是", @"Launcher", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){[self reLoginBtnBeClicked:2];}]];
            [[CodingUtil getTopMostViewController] presentViewController:_alertControllerForReLoginCount animated:YES completion:nil];
        }else{
            _alertViewForReLoginCount = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"登入失敗，請問是否重連", @"Launcher", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"否", @"Launcher", nil) otherButtonTitles:NSLocalizedStringFromTable(@"是", @"Launcher", nil), nil];
            [_alertViewForReLoginCount show];
        }
    }
    if(dataModel.isRejectReLogin) {
        [FSHUD hideGlobalHUD];
        return;
    }
    [self loginAuthUsingSelfAccount];
}

- (void)loginAuthUsingPromoteAccount {
    FSFonestock *fonestock = [FSFonestock sharedInstance];
    [self fsAuthLoginWithAccount:[fonestock account]
                        password:[fonestock password]
                     accountType:[fonestock authType]];
}

- (void)loginAuthUsingSelfAccount {
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSAccountManager *accountManager = dataModel.accountManager;
    [self fsAuthLoginWithAccount:[accountManager account]
                        password:[accountManager password]
                     accountType:[accountManager authType]];
}

// 帳號登入
- (void)fsAuthLoginWithAccount:(NSString *)account
                      password:(NSString *)password
                   accountType:(NSString *)accountType {
    
    if (_loginResultType != FSLoginResultTypeNoLogin) return;
    
    _loginResultType = FSLoginResultTypeAuthLoginNow;
    
    _fsAuthCenter.delegate = self;
    [_fsAuthCenter loginWithAccount:account
                          password:password
                       accountType:accountType
                          deviceId:[FSFonestock uuid]
                             appId:[[FSFonestock sharedInstance] appId]
                           factory:[FSFonestock manufacturingFactory]
                             model:[FSFonestock machineModelNumber]
                                os:[FSFonestock operatingSystemVersion]
                           version:[FSFonestock appVersion]
                           buildNo:[FSFonestock appBuildNo]];
}

// 帳號Auth登入
- (void)fsAuthDidFinishWithData:(FSPointsAuthCenter *)pointsAuthData {
    
    
    if ([@"200" isEqualToString:pointsAuthData.connectStatusCode]) {
        
        _loginResultType = FSLoginResultTypeAuthLoginSuccess;
        
        // server callback 200
        serviceServerIP = pointsAuthData.serviceServerIP;
        serviceServerPort = pointsAuthData.serviceServerPort;
        queryServerIP = pointsAuthData.queryServerIP;
        queryServerPort = pointsAuthData.queryServerPort;
        
        _account = pointsAuthData.account;
        _accountType = pointsAuthData.accountType;
        _appId = pointsAuthData.appId;
        
        accessToken = pointsAuthData.accessToken;
        expiredAccessTokenDateTime = pointsAuthData.expiredAccessTokenDateTime;
        systemDateTime = pointsAuthData.systemDateTime;
        
        // 2014-07-16T23:59:59Z
        _serviceDueDateTimeUTC = [NSDate dateFromUTCString:pointsAuthData.serviceDueDateTime];
        
        FSFonestock *fonestock = [FSFonestock sharedInstance];
        fonestock.portfolioQuota = pointsAuthData.authority.portfolio_quota;
        [fonestock setAuthorityData:pointsAuthData.authority];
        
        fonestock.queryServerURL = [NSString stringWithFormat:@"http://%@:%@", queryServerIP, queryServerPort];

        // 更新推播token
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
        
        [[NSUserDefaults standardUserDefaults] setValue:_account forKey:@"account"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        if (deviceToken) {
            [dataModel.pushNotificationCenter updatePushTokenWithDeviceType:@"apple" deviceId:[FSFonestock uuid] token:deviceToken account:dataModel.loginService.account app_id:[FSFonestock sharedInstance].appId];
            
        }
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAuthStatus" object:[NSNumber numberWithInteger:FSLoginResultTypeAuthLoginSuccess]];
        
        
        // 登入service server
        [self connectServiceServer];
        
//        [self showTheStatus:@""];
    }
    
    
/*
    NSDateFormatter *formatterLocal = [[NSDateFormatter alloc] init];
    [formatterLocal setDateFormat:@"yyyy-MM-dd"];
    [formatterLocal setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDate *today = [NSDate date];
    if ([today compare:_serviceDueDateTimeUTC] == NSOrderedDescending) {
        _alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"提示收費", @"Launcher", nil)
                                                message:NSLocalizedStringFromTable(@"您的服務已經到期，請前往繳費", @"Launcher", @"您的服務已經到期，請前往繳費")
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Launcher", nil)
                                      otherButtonTitles:NSLocalizedStringFromTable(@"前往付費", @"Launcher", nil), nil];
//        [_alertView show];
    } else {
        
        NSDate *checkDateTime = [[NSDate date] dateByAddingTimeInterval:60*60*24*5];
        if ([checkDateTime compare:_serviceDueDateTimeUTC] == NSOrderedDescending) {
            
            NSString *dueDateAlertString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"您的使用期限至(%@)已快到期，為維護您的使用權益，建議儘快續約", @"Launcher", @"您的使用期限至(yyyy-mm-dd)已快到期，為維護您的使用權益，建議儘快續約"),
                                            [formatterLocal stringFromDate:_serviceDueDateTimeUTC]];
            
            _alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"提示收費", @"Launcher", nil)
                                                    message:dueDateAlertString
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Launcher", nil)
                                          otherButtonTitles:NSLocalizedStringFromTable(@"前往付費", @"Launcher", nil), nil];
//            [_alertView show];
            
        }
    }
    [_alertView performSelector:@selector(show) withObject:nil afterDelay:2];
    
*/

    
}

- (void)fsAuthDidFailWithData:(FSPointsAuthCenter *)pointsAuthData {
    
    /*
     200: success(OK), 204: no data(No content),
     304: up to date(not modified),
     400: Bad Request,  401: Unauthorized,
     500: Internal Server Error, 503: Service Unavailable, 505: Version Not Supported.
     */
    
    NSString *alertTitle = pointsAuthData.connectStatusCode;
    NSString *alertMessage = pointsAuthData.connectStatusMessage;
    
    if ([@"400" isEqualToString:pointsAuthData.connectStatusCode]) {
//        alertMessage = @"Bad Request";
        alertTitle = @"";
        alertMessage = NSLocalizedStringFromTable(@"帳號或密碼錯誤", @"Launcher", @"帳號或密碼錯誤");
        
        _alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil) otherButtonTitles:nil];
    }
    else if ([@"401" isEqualToString:pointsAuthData.connectStatusCode]) {
        alertTitle = @"";
        alertMessage = NSLocalizedStringFromTable(@"帳號或密碼錯誤", @"Launcher", @"帳號或密碼錯誤");
        
        _alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil) otherButtonTitles:nil];
    }
    else if ([@"402" isEqualToString:pointsAuthData.connectStatusCode]) {
        
        _account = pointsAuthData.account;
        _accountType = pointsAuthData.accountType;
        _appId = pointsAuthData.appId;
        
        [[NSUserDefaults standardUserDefaults] setValue:_account forKey:@"account"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAuthStatus" object:[NSNumber numberWithInteger:FSLoginResultTypePaymentRequired]];
        
        
        _alertView = [[UIAlertView alloc] initWithTitle:nil
                                                message:NSLocalizedStringFromTable(@"您的服務已經到期，請前往繳費", @"Launcher", @"您的服務已經到期，請前往繳費")
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedStringFromTable(@"離開", @"Launcher", nil)
                                      otherButtonTitles:NSLocalizedStringFromTable(@"前往付費", @"Launcher", nil), nil];
    }
    
    else if ([@"500" isEqualToString:pointsAuthData.connectStatusCode]) {
        alertMessage = @"Internal Server Error";
        
        _alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil) otherButtonTitles:nil];
    }
    else if ([@"503" isEqualToString:pointsAuthData.connectStatusCode]) {
        alertMessage = @"Service Unavailable";
        
        _alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil) otherButtonTitles:nil];
        
        [_alertView show];
    }
    else if ([@"505" isEqualToString:pointsAuthData.connectStatusCode]) {
        alertTitle = @"重大更新";
        alertMessage = @"強制更新版本";
        
        _alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil) otherButtonTitles:nil];
        
        [_alertView show];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAuthStatus" object:[NSNumber numberWithInteger:FSLoginResultTypeLoginFailed]];
    
    [FSHUD hideGlobalHUD];
    
    
    if([pointsAuthData.connectStatusCode intValue]){
        _alertView.tag = [pointsAuthData.connectStatusCode intValue];
        [_alertView show];
    }
    else {
        _alertViewForReLoginCount = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"系統忙線中", @"Launcher", nil) message:NSLocalizedStringFromTable(@"登入失敗，請問是否重連", @"Launcher", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"否", @"Launcher", nil) otherButtonTitles:NSLocalizedStringFromTable(@"是", @"Launcher", nil), nil];
        [_alertViewForReLoginCount show];
    }
    
    if (![@"402" isEqualToString:pointsAuthData.connectStatusCode]){
        _loginResultType = FSLoginResultTypeNoLogin;
    }
}

-(void)gotoLoginViewController
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSAccountManager *accountManager = dataModel.accountManager;
    [accountManager removeAllUserInformationData];
    dataModel.isRejectReLogin = YES;
    
    FSAppDelegate *application = (FSAppDelegate *)[UIApplication sharedApplication].delegate;
    FSNavigationViewController *nav = application.rootViewNavController;
    [nav popToRootViewControllerAnimated:NO];
    FSLoginViewController *loginVC = [[FSLoginViewController alloc] init];
    [nav pushViewController:loginVC animated:NO];
    
}

- (void)fsAuthDidFailWithError:(NSError *)error {
    
    _loginResultType = FSLoginResultTypeNoLogin;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAuthStatus" object:[NSNumber numberWithInteger:FSLoginResultTypeServiceUnavailable]];
    
    [self performSelector:@selector(disconnectReloginAuth) withObject:nil afterDelay:3];
}

- (void)connectServiceServer {
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSSocketProc *mainSocket = dataModel.mainSocket;
    if (mainSocket.isConnected) {
        [mainSocket disconnect];
    }
    [FSHUD hideGlobalHUD];
    _loginResultType = FSLoginResultTypeServiceServerLoginNow;
    [mainSocket connectWithHost:serviceServerIP Port:[serviceServerPort intValue]];
}

- (void)loginServiceServer {
    FSAuthLoginOut *loginOut = [[FSAuthLoginOut alloc] initServiceServerLoginWithAccount:_account
                                                                        expiredTimestamp:expiredAccessTokenDateTime
                                                                                deviceId:[FSFonestock uuid]
                                                                                   appId:[[FSFonestock sharedInstance] appId]
                                                                             accessToken:accessToken
                                                                              clientInfo:[FSFonestock appClientInfo]];
    
    [FSDataModelProc sendData:self WithPacket:loginOut];
}

- (void)serviceServerLoginCallBack:(FSAuthLoginIn *)data {
    
    if (data->statusCode == 200) {
        
        _loginResultType = FSLoginResultTypeServiceServerLoginSuccess;
        
        [FSHUD hideGlobalHUD];
        
        [FSHUD showMsg:NSLocalizedStringFromTable(@"已登入", @"Launcher", nil)];
        
        

#ifdef PatternPowerTW
#elif PatternPowerUS
#else
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"wakeTheSgInfoAlert" object:[NSNumber numberWithInteger:123]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginServiceStatus" object:[NSNumber numberWithInteger:123]];
#endif
        
        
#ifdef SERVER_SYNC
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        
        [dataModal.category performSelector:@selector(loginNotify) onThread:dataModal.thread withObject:nil waitUntilDone:YES];
        [dataModal.marketInfo performSelector:@selector(loginNotify) onThread:dataModal.thread withObject:nil waitUntilDone:YES];
        [dataModal.actionPlanModel performSelector:@selector(loginNotify) onThread:dataModal.thread withObject:nil waitUntilDone:YES];
        [dataModal.indicator performSelector:@selector(loginNotify) onThread:dataModal.thread withObject:nil waitUntilDone:YES];
#ifdef PatternPowerTW
        //券商資料
        [dataModal.brokerInfo performSelector:@selector(loginNotify) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
        //券商分公司
        [dataModal.brokerBranchInfo performSelector:@selector(loginNotify) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
        //營業員
        //[dataModal.esmTraderInfo performSelector:@selector(loginNotify) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
#endif
#else
        
#endif
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginServiceStatus" object:[NSNumber numberWithInteger:FSLoginResultTypeServiceServerLoginSuccess]];
    }
    else {
        [FSHUD showGlobalProgressHUDWithTitle:NSLocalizedStringFromTable(@"登入中", @"AccountSetting", nil) hideAfterDelay:3];
        
        _loginResultType = FSLoginResultTypeNoLogin;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == FSLoginResultTypeBadRequest) {
//        [self performSelector:@selector(loginAuthUsingSelfAccount) withObject:nil afterDelay:3];
        [self gotoLoginViewController];
    }
    else if (alertView.tag == FSLoginResultTypeUnauthorized) {
//        FSAccountManager *accountManager = [[FSDataModelProc sharedInstance] accountManager];
//        [accountManager setLoginAccount:nil password:nil];
        [self gotoLoginViewController];
    }
    else if (alertView.tag == FSLoginResultTypePaymentRequired) {
        if (buttonIndex == 1){
            
            FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
            FSFonestock *fonestock = [FSFonestock sharedInstance];
            
            NSString *paymentFullURL = [NSString stringWithFormat:@"%@?acc_id=%@&app_id=%@&lang=%@&request_iap=1&forapp=1", fonestock.paymentPageURL, loginService.account, fonestock.appId, fonestock.lang];
            
            FSPaymentViewController *paymentWebView = [[FSPaymentViewController alloc] initWithPaymentURL:paymentFullURL];
            
            [fonestock.currentViewController.navigationController pushViewController:paymentWebView animated:NO];
        }
    }
    else if (alertView.tag == FSLoginResultTypeInternalServerError) {
        [self performSelector:@selector(loginAuthUsingSelfAccount) withObject:nil afterDelay:3];
    }
    else if (alertView.tag == FSLoginResultTypeServiceUnavailable) {
        [self performSelector:@selector(loginAuthUsingSelfAccount) withObject:nil afterDelay:3];
    }
    else if (alertView.tag == FSLoginResultTypeVersionNotSupported) {
        NSURL *url = [NSURL URLWithString:[[FSFonestock sharedInstance] appStoreURL]];
        [[UIApplication sharedApplication] openURL:url];
        // 無窮alert
        UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:[alertView title] message:[alertView message] delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil) otherButtonTitles:nil];
        [alertView2 show];
    }
    if(alertView == _alertViewForReLoginCount){
        _loginCounter = 0;
        if(buttonIndex == 1){
            FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
            dataModel.isRejectReLogin = NO;
            [self disconnectReloginAuth];
        }
    }
    
    
//    if(buttonIndex == 1){
//        [_aTarget moveToPaymentView];
//    }
}

//for _alertController
-(void)okBtnBeClicked:(NSInteger)target
{
    if(ios8AlertTag == FSLoginResultTypeBadRequest){
        [self gotoLoginViewController];
    }else if(ios8AlertTag == FSLoginResultTypeUnauthorized){
        [self gotoLoginViewController];
    }else if(ios8AlertTag == FSLoginResultTypePaymentRequired){
        if(target == 2){
            FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
            FSFonestock *fonestock = [FSFonestock sharedInstance];
            
            NSString *paymentFullURL = [NSString stringWithFormat:@"%@?acc_id=%@&app_id=%@&lang=%@&request_iap=1&forapp=1", fonestock.paymentPageURL, loginService.account, fonestock.appId, fonestock.lang];
            
            FSPaymentViewController *paymentWebView = [[FSPaymentViewController alloc] initWithPaymentURL:paymentFullURL];
            
            [fonestock.currentViewController.navigationController pushViewController:paymentWebView animated:NO];
        }
    }else if (ios8AlertTag == FSLoginResultTypeInternalServerError) {
        [self performSelector:@selector(loginAuthUsingSelfAccount) withObject:nil afterDelay:3];
    }
    else if (ios8AlertTag == FSLoginResultTypeServiceUnavailable) {
        [self performSelector:@selector(loginAuthUsingSelfAccount) withObject:nil afterDelay:3];
    }
    else if (ios8AlertTag == FSLoginResultTypeVersionNotSupported) {
        NSURL *url = [NSURL URLWithString:[[FSFonestock sharedInstance] appStoreURL]];
        [[UIApplication sharedApplication] openURL:url];
        // 無窮alert
        UIAlertController *alertController2 = [UIAlertController alertControllerWithTitle:[_alertController title] message:[_alertController message] preferredStyle:UIAlertControllerStyleAlert];
        [alertController2 addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"確認", @"Launcher", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){[self okBtnBeClicked:1];}]];
        [[CodingUtil getTopMostViewController] presentViewController:alertController2 animated:YES completion:nil];
    }
}

//for _alertControllerForReLoginCount
-(void)reLoginBtnBeClicked:(NSInteger)num
{
    if(num == 2){
        _loginCounter = 0;
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        dataModel.isRejectReLogin = NO;
        [self disconnectReloginAuth];
    }
}

-(void)setTarget:(id)aTarget
{
    _aTarget = aTarget;
}

-(void)showTheStatus:(NSString *)showMsg {
    
    
//    [FSHUD showMsg:@"脆迪酥"];
    
//    FSAppDelegate *application = (FSAppDelegate *)[UIApplication sharedApplication].delegate;
//    UIWindow *window = application.window;
    
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:window];
//    hud.userInteractionEnabled = NO;
//    hud.labelText = [NSString stringWithFormat:@"%@", NSLocalizedStringFromTable(@"已登入", @"Launcher", nil)];
//    
//    [window addSubview:hud];
//    
//    
//    
//    [hud show:YES];
//    
//    [hud hide:YES afterDelay:2];
    
//    if (!msgLabelView) {
//        msgLabelView = [[UILabel alloc] init];
//        msgLabelView.translatesAutoresizingMaskIntoConstraints = NO;
//        msgLabelView.text = [NSString stringWithFormat:@"  %@  ", NSLocalizedStringFromTable(@"已登入", @"Launcher", nil)];
//        msgLabelView.textColor = [UIColor whiteColor];
//        msgLabelView.textAlignment = NSTextAlignmentLeft;
//        msgLabelView.layer.masksToBounds = YES;
//        msgLabelView.layer.cornerRadius = 10;
//        msgLabelView.backgroundColor = [UIColor blackColor];
//        
//        [window addSubview:msgLabelView];
//        
//        [window addConstraint:[NSLayoutConstraint constraintWithItem:msgLabelView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
//        
//        [window addConstraint:[NSLayoutConstraint constraintWithItem:msgLabelView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-22]];
//    } else {
//        msgLabelView.hidden = NO;
//    }
//    
//    [self performSelector:@selector(hiddenMsgLabel) withObject:nil afterDelay:3];
}

- (void)hiddenMsgLabel {
    [msgLabelView performSelectorOnMainThread:@selector(setHidden:) withObject:@YES waitUntilDone:NO];
}

- (void)disconnect {
    _loginResultType = FSLoginResultTypeNoLogin;
}

@end
