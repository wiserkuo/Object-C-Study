//
//  FSLoginViewController.h
//  FonestockPower
//
//  Created by Connor on 14/3/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSLoginViewController : FSUIViewController
- (instancetype)initWithAccount:(NSString *)account AndPassword:(NSString *)password;
@property BOOL hasBackButton;
@end
