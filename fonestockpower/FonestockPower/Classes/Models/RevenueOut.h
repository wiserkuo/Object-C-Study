//
//  RevenueOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"


@interface RevenueOut : NSObject <EncodeProtocol>{
	UInt32 commodityNum;
	char dataType;
	UInt8 queryType;
	UInt16 date;
	UInt8 yearCount;
	BOOL newRevenue;
}

- (id)initWithDate:(UInt16)d CommodityNum:(UInt32)cn DataType:(char)t;
- (id)initWithYearCount:(UInt8)c CommodityNum:(UInt32)cn DataType:(char)t;
- (void)setThisIsNewRevenue;

@end
