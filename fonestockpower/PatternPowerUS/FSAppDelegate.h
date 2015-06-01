//
//  FSAppDelegate.h
//  PatternPowerUS
//
//  Created by Connor on 14/3/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSNavigationViewController.h"

@interface FSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FSNavigationViewController *rootViewNavController;
@property (strong, nonatomic) UIWindow *actionSheetWindow;
@end
