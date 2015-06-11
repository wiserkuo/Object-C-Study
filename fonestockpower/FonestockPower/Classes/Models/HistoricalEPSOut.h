//
//  HistoricalEPSOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"


@interface HistoricalEPSOut : NSObject <EncodeProtocol>{
	UInt32 commodityNum;
	UInt8 epsType;
	UInt8 count;
	UInt16 startDate;
	UInt16 endDate;
}

- (id)initWithStartDate:(UInt16)sd EndDate:(UInt16)ed CommodityNum:(UInt32)cn EPSType:(UInt8)et;
- (id)initWithCount:(UInt8)c CommodityNum:(UInt32)cn EPSType:(UInt8)et;

@end
