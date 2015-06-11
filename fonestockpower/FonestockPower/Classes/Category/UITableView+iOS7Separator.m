//
//  UITableView+iOS7Separator.m
//  FonestockPower
//
//  Created by Connor on 14/4/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "UITableView+iOS7Separator.h"

@implementation UITableView (iOS7Separator)
- (id)init {
    self = [super init];
    if (self) {
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    return self;
}
@end
