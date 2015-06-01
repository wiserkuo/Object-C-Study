//
//  FSUIViewController.h
//  FonestockPower
//
//  Created by Connor on 2014/11/12.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSUIViewController : UIViewController

/*
 
// 新版Autolayout更新(簡化版)

- (void)updateViewConstraints {
    [super updateViewConstraints];
 
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
 
    ...
 
    [self replaceCustomizeConstraints:constraints];
}
 
*/
- (void)replaceCustomizeConstraints:(NSArray *)newConstraints;

@end
