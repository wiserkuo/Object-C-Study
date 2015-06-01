//
//  UIViewController+ContainerNavigationItem.m
//  FonestockPower
//
//  Created by Connor on 14/6/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "UIViewController+ContainerNavigationItem.h"

NSString *const UIViewControllerRightBarButtonItemsChangedNotification = @"UIViewControllerRightBarButtonItemsChangedNotification";


@implementation UIViewController (ContainerNavigationItem)

- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems
{
    [[self navigationItem] setRightBarButtonItems:rightBarButtonItems];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:UIViewControllerRightBarButtonItemsChangedNotification object:self];
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem
{
    if(rightBarButtonItem != nil)
        [self setRightBarButtonItems:@[ rightBarButtonItem ]];
    else
        [self setRightBarButtonItems:nil];
}

@end