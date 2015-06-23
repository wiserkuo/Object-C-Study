//
//  FSADViewController_2.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/22.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSADViewController_2.h"
#import "FSADResultViewController.h"
#import "ADSystem.h"

@interface FSADViewController_2 (){
    FSShowResultAdObj *AdObj;
}

@end

@implementation FSADViewController_2

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initView) name:@"2.jpg" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initView
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 82)];
    if ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound) {
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
#if defined(PatternPowerUS) || defined(PatternPowerTW) || defined(PatternPowerCN)
    imageView.image = [UIImage imageNamed:@"型態.jpg"];
    
    UITapGestureRecognizer *tapRecongnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:tapRecongnizer];
#else
    ADSystem *adSystem = [[ADSystem alloc]init];
    NSMutableArray *AdData = [adSystem getLoaclAdPlist];
    if ([AdData count] > 0) {
        AdObj = [[adSystem getLoaclAdPlist] objectAtIndex:1];
        imageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/ADImage/2.jpg",[CodingUtil fonestockDocumentsPath]]];
        if(![AdObj.uri isEqualToString:@""]){
            UITapGestureRecognizer *tapRecongnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:tapRecongnizer];
        }
    }
#endif
    
    [self.view addSubview:imageView];
}

-(void)tapGesture:(id)sender{
#if defined(PatternPowerUS) || defined(PatternPowerTW) || defined(PatternPowerCN)
    NSURL *url;
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/xing-tai-niu-gu/id966169131?l=zh&ls=1&mt=8"];
    }else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS){
        url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/pattern-tips/id966070398?l=zh&ls=1&mt=8"];
    }else{
        url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/xing-tai-niu-gu/id968216458?l=zh&ls=1&mt=8"];
    }
    
    [[UIApplication sharedApplication] openURL:url];
#else
    FSADResultViewController *nextView = [[FSADResultViewController alloc]initWithAdUrl:AdObj.uri];
    [self.navigationController pushViewController:nextView animated:NO];
#endif
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
