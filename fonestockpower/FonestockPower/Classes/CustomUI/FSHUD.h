//
//  FSHUD.h
//  FonestockPower
//
//  Created by Connor on 14/4/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface FSHUD : NSObject

+ (void)showHUDin:(UIView *)view title:(NSString *)title;
+ (void)hideHUDFor:(UIView *)view;

+ (MBProgressHUD *)showGlobalProgressHUDWithTitle:(NSString *)title;
+ (MBProgressHUD *)showGlobalProgressHUDWithTitle:(NSString *)title hideAfterDelay:(NSTimeInterval)delay;
+ (MBProgressHUD *)showGlobalProgressHUDWithTitleTextOnly:(NSString *)title hideAfterDelay:(NSTimeInterval)delay;
+ (void)hideGlobalHUD;


+ (void)showMsg:(NSString *)msg;
+ (void)showMsg:(NSString *)msg hideAfterDelay:(NSTimeInterval)delay;
@end
