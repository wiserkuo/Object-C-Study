//
//  NewRevenueIn.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/26.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewRevenueIn : NSObject <DecodeProtocol>{
@public
	//NSMutableArray *revenueArray;
	NSMutableDictionary *revenueMainDictionary;
	UInt8 retCode;
	UInt32 commodityNum;
    char dataType;
    UInt8 dataCount;
    NSMutableArray *dataArray;
}


@end

@interface RevenueObject : NSObject
{
@public
	UInt16 date;
	double revenue;
	UInt8 revenueUnit;
	double accumulatedRevenue;
	UInt8 accumulatedRevenueUnit;
	double accumulatedAchieveRate;
	UInt8 accumulatedAchieveRateUnit;
    double mergedRevenue;
    UInt8 mergedRevenueUnit;
    double accumulatedMergedRevenue;
    UInt8 accumulatedMergedRevenueUnit;
}

@end

