//
//  MarginTradingOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MarginTradingOut.h"
#import "OutPacket.h"
#import "CodingUtil.h"


@implementation MarginTradingOut

- (id)initWithCommodityNum:(UInt32)cn StartDate:(UInt16)sd EndDate:(UInt16)ed
{
	if(self = [super init])
	{
		commodityNum = cn;
		startDate = sd;
		endDate = ed;
	}
	return self;
}

- (int)getPacketSize
{
	return 8;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 13;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:tmpPtr Value:commodityNum];
	tmpPtr += 4;
	[CodingUtil setUInt16:tmpPtr Value:startDate + 1];
	tmpPtr += 2;
	[CodingUtil setUInt16:tmpPtr Value:endDate];
	
	return YES;
}

- (void)dealloc
{
//	[super dealloc];
}

@end
