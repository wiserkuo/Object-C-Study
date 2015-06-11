//
//  FSRegisterViewController.m
//  DivergenceStock
//
//  Created by Connor on 2014/12/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSSignupViewController.h"
#import "FSSignupModel.h"

@interface FSSignupViewController() {
    
}

@end

@implementation FSSignupViewController

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"申裝註冊", @"Launcher", nil);
    
    FSDataModelProc *dataModelProc = [FSDataModelProc sharedInstance];
    [webview loadRequest:[dataModelProc.signupModel request]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
