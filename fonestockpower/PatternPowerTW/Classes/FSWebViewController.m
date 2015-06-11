//
//  FSWebViewController.m
//  FonestockPower
//
//  Created by Connor on 2015/1/5.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSWebViewController.h"

@interface FSWebViewController ()

@end

@implementation FSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self setUpCustomBackButton];
    
    webview = [[UIWebView alloc] init];
    webview.translatesAutoresizingMaskIntoConstraints = NO;
    webview.delegate = self;
    webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webview.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.view addSubview:webview];
    
    hud = [[MBProgressHUD alloc] initWithView:webview];
    [webview addSubview:hud];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webview]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webview)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webview]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webview)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardShow:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)onKeyBoardShow:(NSNotification*)notification {
    [webview.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeViewController {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setUpCustomBackButton {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [backButton setImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *backButtonView = [[UIView alloc] init];
    [backButtonView addSubview:backButton];
    [backButtonView setFrame:CGRectMake(0, 0, 33, 33)];
    UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    self.navigationItem.leftBarButtonItem = barBackButtonItem;
}

- (void)goBack {
    if ([webview canGoBack]) {
        [webview goBack];
    }
    else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

# pragma mark -
# pragma mark webview delegate
# pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    currentPageURL = [[request URL] absoluteString];
    FSURLParser *parser = [[FSURLParser alloc] initWithURLString:currentPageURL];
    
    // URL攔截模式
    if ([@"1" isEqualToString:[parser valueForVariable:@"forapp"]]) {
        // 進行登入
        if ([@"1" isEqualToString:[parser valueForVariable:@"dologin"]]) {
            NSString *phoneNo = [parser valueForVariable:@"phoneno"];
            NSString *passwd = [parser valueForVariable:@"sms_code"];
            if (phoneNo != nil && passwd != nil) {
                phoneNo = [phoneNo stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                passwd = [passwd stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[FSAccountManager sharedInstance] setLoginAccount:phoneNo password:passwd];
            }
        }
        
        // 關閉webview
        if ([@"1" isEqualToString:[parser valueForVariable:@"close"]]) {
            [self closeViewController];
            return NO;
        }
        
        if ([@"1" isEqualToString:[parser valueForVariable:@"login_page"]]) {
            [self closeViewController];
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [hud show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [hud hide:YES];
    
    // 禁止用戶選擇
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // 禁止長按彈出框
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

@end
