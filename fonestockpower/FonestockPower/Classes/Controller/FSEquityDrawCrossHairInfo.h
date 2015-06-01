//
//  FSEquityDrawCrossHairInfo.h
//  WirtsLeg
//
//  Created by KevinShen on 2014/2/6.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSEquityDrawCrossHairInfo : NSObject
@property (nonatomic, strong) NSNumber *bid;
@property (nonatomic, strong) NSNumber *ask;
@property (nonatomic, strong) NSNumber *last;
@property (nonatomic, strong) NSNumber *change;
@property (nonatomic, strong) NSNumber *vol;

@property (nonatomic, strong) NSNumber *comparedLast;
@property (nonatomic, strong) NSNumber *comparedVol;
@end
