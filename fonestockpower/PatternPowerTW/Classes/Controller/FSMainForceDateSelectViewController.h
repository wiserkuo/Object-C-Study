//
//  FSMainForceDateSelectViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/8/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSMainForceViewController.h"
#import "FSBrokerInAndOutListViewController.h"

@interface FSMainForceDateSelectViewController : UIViewController
@property (unsafe_unretained, nonatomic) int dateNum;
@property (unsafe_unretained, nonatomic) int dayType;

@property (nonatomic,strong) FSMainForceViewController* data;
@property (nonatomic,strong) FSBrokerInAndOutListViewController *dataBroker;
@end
