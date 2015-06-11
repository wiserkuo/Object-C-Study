//
//  FSADViewController_5.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/22.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSADViewController_5.h"
#import "FSADResultViewController.h"
#import "ADSystem.h"

@interface FSADViewController_5 (){
    FSShowResultAdObj *AdObj;
}

@end

@implementation FSADViewController_5

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initView) name:@"5.jpg" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initView
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 82)];
    ADSystem *adSystem = [[ADSystem alloc]init];
    NSMutableArray *AdData = [adSystem getLoaclAdPlist];
    if ([AdData count] > 0) {
        AdObj = [[adSystem getLoaclAdPlist] objectAtIndex:4];
        imageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/ADImage/5.jpg",[CodingUtil fonestockDocumentsPath]]];
        if(![AdObj.uri isEqualToString:@""]){
            UITapGestureRecognizer *tapRecongnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:tapRecongnizer];
        }
    }
    
    [self.view addSubview:imageView];
}

-(void)tapGesture:(id)sender{
    FSADResultViewController *nextView = [[FSADResultViewController alloc]initWithAdUrl:AdObj.uri];
    [self.navigationController pushViewController:nextView animated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
