//
//  MarginTradingOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"


@interface MarginTradingOut : NSObject <EncodeProtocol>{
	UInt32 commodityNum;
	UInt16 startDate;
	UInt16 endDate;
}

- (id)initWithCommodityNum:(UInt32)cn StartDate:(UInt16)sd EndDate:(UInt16)ed;

@end
