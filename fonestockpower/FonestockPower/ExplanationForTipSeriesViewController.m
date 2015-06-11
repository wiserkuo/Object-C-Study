//
//  ExpanationForTipSeriesViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2015/2/5.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "ExplanationForTipSeriesViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "PageControlViewController.h"
#import "FSWebViewController.h"
#import "FSDivergenceModel.h"
#import "FigureSearchMyProfileModel.h"

@interface ExplanationForTipSeriesViewController ()

@end

@implementation ExplanationForTipSeriesViewController

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpImageBackButton];

#if DivergenceTipsUS || DivergenceTipsTW || DivergenceTipsCN || DivergenceTipsHK
    self.title = NSLocalizedStringFromTable(@"背離力", @"DivergenceTips", nil);
    [webview loadRequest:[FSDivergenceModel openExplanation]];
#elif PatternTipsUS || PatternTipsTW || PatternTipsCN || PatternTipsHK
    [self setTitle:NSLocalizedStringFromTable(@"時機小秘", @"DivergenceTips", nil)];
    [webview loadRequest:[FigureSearchMyProfileModel openExplanation]];
#else
    self.title = NSLocalizedStringFromTable(@"圖是力", @"Launcher", nil);
    [webview loadRequest:[FigureSearchMyProfileModel openExplanation]];
#endif
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
