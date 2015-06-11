//
//  FSAddActionPlanSettingViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/5/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSAddActionPlanSettingViewController : FSUIViewController<UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSString *termStr;
-(void)reloadTable;

@end
