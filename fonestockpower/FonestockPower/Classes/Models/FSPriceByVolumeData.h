//
//  FSPriceByVolumeData.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/6.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSPriceByVolumeData : NSObject
@property (nonatomic, assign) double price;
@property (nonatomic, assign) double volume;
//percentage值為0~100
@property (nonatomic, assign) double percentage;
@property (nonatomic, assign) UInt32 tradeOnBid;
@property (nonatomic, assign) UInt32 tradeOnAsk;
@property (nonatomic, assign) UInt16 tickCount;
@end
