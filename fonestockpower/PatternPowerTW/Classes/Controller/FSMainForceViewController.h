//
//  FSMainForceViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/8/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSMainForceAnchorViewController.h"

@interface FSMainForceViewController : FSUIViewController<BrokerProtocol>
@property (nonatomic) int dayType;
@end

@interface FSMainForceData : NSObject
@property (strong, nonatomic) NSString *name;
@property (unsafe_unretained, nonatomic) double overBought;
@property (unsafe_unretained, nonatomic) double buy;
@property (unsafe_unretained, nonatomic) double sell;
@property (unsafe_unretained, nonatomic) double buyAvg;
@property (unsafe_unretained, nonatomic) double sellAvg;

@end

