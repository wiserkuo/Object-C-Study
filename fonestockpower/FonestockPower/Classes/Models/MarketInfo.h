//
//  MarketInfo.h
//  Bullseye
//
//  Created by steven on 2009/1/9.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MarketInfoIn.h"

@interface MarketInfoItem : NSObject 
{
@public
	UInt8    market_id;
	NSString *marketName;
	char     identCode[2];
	UInt16   startTime_1;
	UInt16   endTime_1;
	UInt16   startTime_2;
	UInt16   endTime_2;
}

@end


@interface MarketInfo : NSObject

- (MarketInfoItem *)getMarketInfo: (UInt8) market_id;
- (BOOL)isBreakTime:(UInt16) time marketId:(UInt8) marketId;
- (BOOL)isTickTime:(UInt16) tickTime EqualToMarketClosedTime:(UInt8) marketId;
- (UInt16)subtractTime:(UInt16)end by:(UInt16)start marketId:(UInt8) marketId;
- (void) addMarketInfo:(MarketInfoIn *)obj;
- (void) sendRequest;
- (void)loginNotify;

@end
