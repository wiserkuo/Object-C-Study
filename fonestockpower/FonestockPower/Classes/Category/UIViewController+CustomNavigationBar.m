//
//  UIViewController+CustomNavigationBar.m
//  FonestockPower
//
//  Created by Connor on 14/4/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "UIViewController+CustomNavigationBar.h"

@implementation UIViewController (CustomNavigationBar)

- (void)setUpBackButton {
    NSString *backString = NSLocalizedStringFromTable(@"返回", @"Navigation", nil);
    UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithTitle:backString style:UIBarButtonItemStylePlain target:self action:@selector(popCurrentViewController)];
    self.navigationItem.leftBarButtonItem = barBackButtonItem;
    self.navigationItem.hidesBackButton = YES;
}

- (void)setUpBackButtonWithTitle:(NSString *)title {
    UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(popCurrentViewController)];
    self.navigationItem.leftBarButtonItem = barBackButtonItem;
    self.navigationItem.hidesBackButton = YES;
}

- (void)setUpImageBackButton {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [backButton setImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(popCurrentViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *backButtonView = [[UIView alloc] init];
    [backButtonView addSubview:backButton];
    [backButtonView setFrame:CGRectMake(0, 0, 33, 33)];
    UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    self.navigationItem.leftBarButtonItem = barBackButtonItem;
    
}

- (void)popCurrentViewController {
    [self.navigationController popViewControllerAnimated:NO];
}

@end
