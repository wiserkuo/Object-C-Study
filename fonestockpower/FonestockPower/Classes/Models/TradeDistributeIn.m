//
//  TradeDistributeIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/15.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "TradeDistributeIn.h"

@implementation TradeDistributeIn

@synthesize tdArray;

- (id)init
{
	if(self = [super init])
	{
		tdArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	securityNum = commodity;
	returnCode = retcode;
	dayType = *tmpPtr++;
	dayCount = *tmpPtr++;
	date = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	startDate = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	endDate = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	
	int count = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	int offset = 0;
	for(int i=0 ; i<count ; i++)
	{
		TradeDistributeParam *tdParam = [[TradeDistributeParam alloc] init];
		PriceFormatData tmpPrice;
		TAvalueFormatData tmpTA;
		tdParam->price = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		tdParam->volume = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		tdParam->volumeUnit = tmpTA.magnitude;
		
		[tdArray addObject:tdParam];
		
	}
	
	//送出在這
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.tradeDistribute performSelector:@selector(TDIn:) onThread:dataModal.thread withObject:self waitUntilDone:NO];

}

@end


@implementation TradeDistributeParam


@end

@implementation NewTradeDistributeParam


@end

