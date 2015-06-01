//
//  FSKPIConditionViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/12/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSKPIConditionViewController : UIViewController

@end

@interface KPIObject : NSObject
@property (unsafe_unretained, nonatomic) int kpiID;
@property (unsafe_unretained, nonatomic) int parentID;
@property (strong, nonatomic) NSString *kpiName;
@property (unsafe_unretained, nonatomic) float lowScore;
@property (unsafe_unretained, nonatomic) float highScore;
@property (unsafe_unretained, nonatomic) BOOL status;

@end