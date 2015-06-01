//
//  MarketInfoOut.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MarketInfoOut.h"
#import "OutPacket.h"


@implementation MarketInfoOut

- (id)initWithDate:(int)year month:(int)month day:(int)day
{
	if (self = [super init])
		[CodingUtil setUInt16:(char*)&MITdate Value:[CodingUtil makeDate:year month:month day:day]];
	return self;	
}

- (int)getPacketSize{
	return sizeof(MITdate);
}

- (BOOL)encode:(NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 4;
	phead->command = 10;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	UInt16 *pbody = (UInt16*)(++phead);
	memcpy(pbody,&MITdate,2);
	return YES;
}

@end
