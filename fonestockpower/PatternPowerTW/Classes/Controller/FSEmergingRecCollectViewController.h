//
//  RecCollectViewController.h
//  EmergingRec
//
//  Created by Michael.Hsieh on 2014/10/15.
//  Copyright (c) 2014年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSEmergingRecommendViewController.h"

@interface FSEmergingRecCollectViewController : UIViewController<DataArriveProtocol>

@property NSString *tempName;

@property (nonatomic,strong)FSEmergingRecommendViewController * Recommend;

@end
