//
//  UIViewController+ActionSheet.m
//  FonestockPower
//
//  Created by Connor on 14/4/23.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "UIViewController+ActionSheet.h"

@implementation UIViewController (ActionSheet)
- (void)showActionSheet:(UIActionSheet *)actionSheet {
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}
@end
