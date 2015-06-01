//
//  UIViewController+ContainerNavigationItem.h
//  FonestockPower
//
//  Created by Connor on 14/6/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const UIViewControllerRightBarButtonItemsChangedNotification;

@interface UIViewController (ContainerNavigationItem)

- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems;
- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem;

@end
