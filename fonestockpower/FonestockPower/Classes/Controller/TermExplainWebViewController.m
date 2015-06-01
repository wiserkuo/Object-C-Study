//
//  TermExplainWebViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/11/22.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "TermExplainWebViewController.h"

@interface TermExplainWebViewController ()

@end

@implementation TermExplainWebViewController

- (id)initWithWebUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        self.webUrl = url;
        NSLog(@"%@",url);
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:_webUrl]];
    
    [_webView loadRequest:request];
    [_webView reload];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedStringFromTable(@"名詞解釋", @"Equity", nil);
    
    self.webView = [[UIWebView alloc] init];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.delegate = self;
    
    [self.view addSubview:_webView];
    [self setLayOut];
	// Do any additional setup after loading the view.
}

-(void)setLayOut{
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_webView);
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:viewControllers]];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"Start Load");
    [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"Equity", nil)];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"Error : %@",error);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"Finish Load");
    [self.view hideHUD];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
