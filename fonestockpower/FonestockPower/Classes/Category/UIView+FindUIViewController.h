//
//  UIView+FindUIViewController.h
//  FonestockPower
//
//  Created by Connor on 14/3/26.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FindUIViewController)
- (UIViewController *)firstAvailableUIViewController;
- (void)removeFirstAvailableUIViewController;
- (id)traverseResponderChainForUIViewController;
@end
