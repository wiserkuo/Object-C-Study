//
//  FSPriceVolumeCrossInfo.h
//  WirtsLeg
//
//  Created by KevinShen on 2014/2/11.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSPriceVolumeCrossHairInfo : NSObject
@property (nonatomic, strong) NSNumber *singleDayPrice;
@property (nonatomic, strong) NSNumber *accumulationPrice;
@property (nonatomic, strong) NSNumber *singleDayVol;
@property (nonatomic, strong) NSNumber *accumulationVol;
@end
