//
//  FSHUD.m
//  FonestockPower
//
//  Created by Connor on 14/4/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSHUD.h"

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
//    [NSTimer scheduledTimerWithTimeInterval:10 block:^(NSTimer *timer) {
//        [MBProgressHUD hideAllHUDsForView:view animated:animated];
//        [timer invalidate];
//    } repeats:YES];
    
//    } else {
//		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:animated];
//        hud.labelText = NSLocalizedStringFromTable(@"Connection Require", @"ConnectionWarning", nil);
//        
//        [NSTimer scheduledTimerWithTimeInterval:3 block:^(NSTimer *timer) {
//            if (socket.isConnected) {
//                [MBProgressHUD hideAllHUDsForView:view animated:animated];
//                [timer invalidate];
//            }
//        } repeats:YES];
//    }
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



@end
