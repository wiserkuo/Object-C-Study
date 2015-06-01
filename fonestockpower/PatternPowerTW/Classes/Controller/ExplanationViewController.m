//
//  ExplanationViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/12/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "ExplanationViewController.h"
#import "UIViewController+CustomNavigationBar.h"
@interface ExplanationViewController ()
{
    UIWebView *webView;
    NSMutableArray *layoutconstraints;
}
@end

@implementation ExplanationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    layoutconstraints = [[NSMutableArray alloc] init];
    [self setUpImageBackButton];
    [self initWebView];
    [self.view setNeedsUpdateConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initWebView
{
    webView = [[UIWebView alloc] init];
    webView.scrollView.bounces = NO;
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:webView];
    int num = (int)[self.navigationController.childViewControllers count] - 2;
    NSString *htmlFile = @"http://www.fonestock.com/app/%@/edu/%@.html";
    NSString *target;
    if([[self.navigationController.childViewControllers objectAtIndex:num] isKindOfClass:NSClassFromString(@"FSActionAlertViewController")]){
        target = @"4";
        self.title = NSLocalizedStringFromTable(@"Action Plan",@"Launcher",nil);
    }else if([[self.navigationController.childViewControllers objectAtIndex:num] isKindOfClass:NSClassFromString(@"FSTradeDiaryViewController")]){
        target = @"7";
        self.title = NSLocalizedStringFromTable(@"Diary",@"Launcher",nil);
    }else if([[self.navigationController.childViewControllers objectAtIndex:num] isKindOfClass:NSClassFromString(@"FSPositionManagementViewController")]){
        target = @"6";
        self.title = NSLocalizedStringFromTable(@"Positions",@"Launcher",nil);
    }else if([[self.navigationController.childViewControllers objectAtIndex:num] isKindOfClass:NSClassFromString(@"DrawAndScrollController")]){
        target = @"8";
        self.title = NSLocalizedStringFromTable(@"Notes",@"Draw",nil);
    }else if([[self.navigationController.childViewControllers objectAtIndex:num] isKindOfClass:NSClassFromString(@"EODTargetController")]){
        target = @"2";
        self.title = NSLocalizedStringFromTable(@"EOD Targets",@"FigureSearch",nil);
    }else if([[self.navigationController.childViewControllers objectAtIndex:num] isKindOfClass:NSClassFromString(@"EODActionController")]){
        target = @"5";
        self.title = NSLocalizedStringFromTable(@"時機健診",@"Launcher",nil);
    }else if([[self.navigationController.childViewControllers objectAtIndex:num] isKindOfClass:NSClassFromString(@"MyFigureSearchViewController")]){
        target = @"3";
        self.title = NSLocalizedStringFromTable(@"用戶自定", @"FigureSearch", nil);
    }
    
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString *htmlPath = [NSString stringWithFormat:htmlFile,appid,target];
    NSURL *url = [NSURL URLWithString:htmlPath];
    NSURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [webView loadRequest:request];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    [self.view removeConstraints:layoutconstraints];
    [layoutconstraints removeAllObjects];
    
    [layoutconstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    [layoutconstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    
    [self.view addConstraints:layoutconstraints];
}

@end
