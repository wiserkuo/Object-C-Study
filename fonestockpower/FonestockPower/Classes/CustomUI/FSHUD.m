//
//  FSHUD.m
//  FonestockPower
//
//  Created by Connor on 14/4/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSHUD.h"
#import "FSAppDelegate.h"
#import "FSInsetsLabel.h"

@implementation FSHUD

+ (id)sharedFSHUD {
    static dispatch_once_t onceQueue;
    static FSHUD *fSHUD = nil;
    
    dispatch_once(&onceQueue, ^{ fSHUD = [[self alloc] init]; });
    return fSHUD;
}

+ (void)showHUDin:(UIView *)view title:(NSString *)title {
    // 僅讓view同時僅有一個hud
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (nil != title) {
        hud.labelText = title;
    }
    
    FSLoginService *service = [[FSDataModelProc sharedInstance] loginService];
    if (service.loginResultType == FSLoginResultTypeNoLogin) {
        [MBProgressHUD hideAllHUDsForView:view animated:YES];
    }
}

+ (void)hideHUDFor:(UIView *)view {
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

+ (MBProgressHUD *)showGlobalProgressHUDWithTitle:(NSString *)title {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [MBProgressHUD hideAllHUDsForView:window animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.labelText = title;
    return hud;
}

+ (MBProgressHUD *)showGlobalProgressHUDWithTitle:(NSString *)title hideAfterDelay:(NSTimeInterval)delay {
    
    [FSHUD hideGlobalHUD];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    [hud hide:YES afterDelay:delay];
    hud.labelText = title;
    return hud;
}

+ (void)hideGlobalHUD {
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        [MBProgressHUD hideHUDForView:window animated:YES];
    }
}

+ (MBProgressHUD *)showGlobalProgressHUDWithTitleTextOnly:(NSString *)title hideAfterDelay:(NSTimeInterval)delay {
    
    [FSHUD hideGlobalHUD];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
    
    return hud;
}

+ (void)showMsg:(NSString *)msg {
    [FSHUD showMsg:msg hideAfterDelay:3];
}

+ (void)showMsg:(NSString *)msg hideAfterDelay:(NSTimeInterval)delay {
    FSAppDelegate *appDelegate = (FSAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = appDelegate.window;
    FSInsetsLabel *msgLabelView = appDelegate.msgLabelView;
    msgLabelView.leftInset = 5;
    msgLabelView.numberOfLines = 0;
    msgLabelView.preferredMaxLayoutWidth = window.frame.size.width;

    [window addSubview:msgLabelView];
    
    [window addConstraint:[NSLayoutConstraint constraintWithItem:msgLabelView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [window addConstraint:[NSLayoutConstraint constraintWithItem:msgLabelView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-44]];
    
    msgLabelView.text = [NSString stringWithFormat:@"%@  ", msg];
    
//    [msgLabelView cancelPreviousPerformRequestsWithTarget:msgLabelView selector:@selector(removeFromSuperview) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:msgLabelView];
    [msgLabelView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:delay];
}

@end
