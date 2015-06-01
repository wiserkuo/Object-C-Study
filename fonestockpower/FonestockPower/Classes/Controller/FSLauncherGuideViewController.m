//
//  FSLauncherGuideViewController.m
//  FonestockPower
//
//  Created by Connor on 14/6/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherGuideViewController.h"

@interface FSLauncherGuideViewController () <UIWebViewDelegate, UIScrollViewDelegate>

@end

@implementation FSLauncherGuideViewController{
    UIImageView *backImg;
    UIScrollView *sclView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];

//    UIWebView *webview = [[UIWebView alloc] init];
//    webview.translatesAutoresizingMaskIntoConstraints = NO;
//    webview.backgroundColor = [UIColor clearColor];
//    webview.opaque = NO;
//    webview.delegate = self;
//    [self.view addSubview:webview];
//    
//    NSURL *rtfUrl = [[NSBundle mainBundle] URLForResource:@"PatternPowerIntroduction" withExtension:@"html"];
//    [webview loadRequest:[NSURLRequest requestWithURL:rtfUrl]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webview]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(webview)]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webview]-20-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(webview)]];
    [self initView];
    [self.view setNeedsUpdateConstraints];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
//    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

-(void)initView
{
//    self.view.autoresizesSubviews = YES;
    
    sclView = [[UIScrollView alloc] init];
    sclView.userInteractionEnabled = YES;
    sclView.directionalLockEnabled = YES;
    sclView.bounces = NO;
    sclView.delegate = self;
    sclView.translatesAutoresizingMaskIntoConstraints = NO;
//    sclView.frame = self.view.frame;
    sclView.contentSize = CGSizeMake(320, 511);
//    sclView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:sclView];
    
    backImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"oldOne1"]];
    backImg.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:backImg];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(sclView, backImg);

    NSNumber *theWidth = [[NSNumber alloc] initWithFloat:320.0];
    NSNumber *theHeight = [[NSNumber alloc] initWithFloat:511.0];
    NSDictionary *metrics = @{@"theWidth":theWidth, @"theHeight":theHeight};
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sclView]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sclView]-20-|" options:0 metrics:nil views:allObj]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[backImg(theWidth)]" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backImg(theHeight)]" options:0 metrics:metrics views:allObj]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:backImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
//    [constraints addObject:[NSLayoutConstraint constraintWithItem:backImg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self replaceCustomizeConstraints:constraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
