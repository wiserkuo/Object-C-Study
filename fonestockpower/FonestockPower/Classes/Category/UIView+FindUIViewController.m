//
//  UIView+FindUIViewController.m
//  FonestockPower
//
//  Created by Connor on 14/3/26.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "UIView+FindUIViewController.h"

@implementation UIView (FindUIViewController)

- (void)removeFirstAvailableUIViewController {
    UIViewController *viewController = (UIViewController *)[self traverseResponderChainForUIViewController];
    [viewController removeFromParentViewController];
}

- (UIViewController *)firstAvailableUIViewController {
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id)traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}

@end
