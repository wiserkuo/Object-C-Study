//
//  FSLauncherViewController.m
//  FonestockPower
//
//  Created by Connor on 14/3/25.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherViewController.h"
#import "FSMainViewController.h"
#import "FSAccountSettingViewController.h"
#import "CustomIOS7AlertView.h"
#import "UIView+FindUIViewController.h"

@interface FSLauncherViewController ()

@end

@implementation FSLauncherViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationBar];
    
    FSUIButton *b1 = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    [b1 setFrame:CGRectMake(0, 64, 60, 44)];
    [b1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonClick:(UIButton *)button {
//    FSMainViewController *nextViewController = [[FSMainViewController alloc] init];
//    UIView *a = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
//    [a setBackgroundColor:[UIColor redColor]];
//    [self.navigationController pushViewController:nextViewController animated:NO];
    
//    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
//    [alertView setContainerView:a];
//    [alertView show];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}


#pragma mark NavigationBar Init

- (void)setupNavigationBar {
    [self.navigationController setNavigationBarHidden:NO];
    UIButton *accountSettingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [accountSettingButton setImage:[UIImage imageNamed:@"GearButton_Black"] forState:UIControlStateNormal];
    [accountSettingButton addTarget:self action:@selector(leftTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *accountSettingBarButton = [[UIBarButtonItem alloc] initWithCustomView:accountSettingButton];
    
    self.navigationItem.leftBarButtonItem = accountSettingBarButton;
}

- (void)leftTapped:(id)sender {
    [self.navigationController pushViewController:[[FSAccountSettingViewController alloc] init] animated:NO];
}

- (void)rightTapped:(id)sender {
    [self.navigationController pushViewController:[[UIViewController alloc] init] animated:NO];
}

@end
