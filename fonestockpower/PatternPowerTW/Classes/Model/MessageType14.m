//
//  MessageType14.m
//  Bullseye
//
//  Created by Yehsam on 2009/2/18.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MessageType14.h"
#import "CodingUtil.h"


@implementation MessageType14

- (id)init
{
	if(self = [super init])
	{
		tpParam = [[TargetPriceParam alloc] init];
	}
	return self;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{	
	UInt8 *tmpPtr = body;
	tpParam->targetPriceTime = [CodingUtil getUint16FromBuf:tmpPtr Offset:0 Bits:11];
	PriceFormatData tmpPrice;
	int offset = 11;
	tpParam->targetPrice = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
	
	PriceFormatData tmpPrice2;
	
	tpParam->targetRefPrice = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice2];
	
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.option performSelector:@selector(type14Arrive:) onThread:dataModal.thread withObject:tpParam waitUntilDone:NO];
}


@end


@implementation TargetPriceParam

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

@end
