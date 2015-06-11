//
//  FSForgetViewController.m
//  FonestockPower
//
//  Created by Connor on 2014/12/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSForgetPWViewController.h"
#import "FSSignupModel.h"

@implementation FSForgetPWViewController

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"密碼重設", @"Launcher", nil);
    
    FSDataModelProc *dataModelProc = [FSDataModelProc sharedInstance];
    [webview loadRequest:[dataModelProc.signupModel forgetPWRequest]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
