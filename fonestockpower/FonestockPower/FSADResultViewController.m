//
//  FSADResultViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/2/2.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSADResultViewController.h"
#import "UIViewController+CustomNavigationBar.h"

@interface FSADResultViewController ()<UIWebViewDelegate>{
    MBProgressHUD *hud;
}
@end

@implementation FSADResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

-(id)initWithAdUrl:(NSString *)url{
    
    [self setUpImageBackButton];
    [self.navigationController setNavigationBarHidden:NO];
    UIWebView *adWebView = [[UIWebView alloc]init];
    adWebView.frame = self.view.frame;
    adWebView.delegate = self;
    adWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [adWebView setBackgroundColor:[UIColor whiteColor]];
    
    NSURL *urlStr = [NSURL URLWithString:url];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:urlStr];
    
    [adWebView loadRequest:requestObj];
    [self.view addSubview:adWebView];
    
    hud = [[MBProgressHUD alloc] initWithView:adWebView];
    [adWebView addSubview:hud];
    return self;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [hud show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [hud hide:YES];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"FSADResultViewController didFailLoadWithError:%@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
