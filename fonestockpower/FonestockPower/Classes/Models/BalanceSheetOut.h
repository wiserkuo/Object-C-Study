//
//  BalanceSheetOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"


@interface BalanceSheetOut : NSObject <EncodeProtocol>{
	UInt32 commodityNum;
	char dataType;
	UInt8 queryType;
	UInt16 date;
	UInt16 endDate;
}

- (id)initWithSpecifyDate:(UInt16)sDate CommodityNum:(UInt32)cn DataType:(char)dt;
- (id)initWithStartDate:(UInt16)sDate EndDate:(UInt16)eDate CommodityNum:(UInt32)cn DataType:(char)dt;

@end
