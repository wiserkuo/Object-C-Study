//
//  TradeDistributeOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/15.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "TradeDistributeOut.h"
#import "OutPacket.h"

@implementation TradeDistributeOut

- (id)initWithOneDaySecurityNum:(UInt32)cn DayCount:(UInt8)dc BeforeDate:(UInt16)d
{
	if(self = [super init])
	{
		dayType = 0;	//0:單日,1:累計
		securityNum = cn;
		dayCount = dc;
		date = d;
	}
	return self;
}

- (id)initWithAddDaySecurityNum:(UInt32)cn DayCount:(UInt8)dc BeforeDate:(UInt16)d
{
	if(self = [super init])
	{
		dayType = 1;	//0:單日,1:累計
		securityNum = cn;
		dayCount = dc;
		date = d;
	}
	return self;
}


- (int)getPacketSize
{
	return 8;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 1;
	phead->command = 11;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer+=sizeof(OutPacketHeader);

	[CodingUtil setUInt32:buffer Value:securityNum];
	buffer += 4;
	*buffer++ = dayType;
	*buffer++ = dayCount;
	[CodingUtil setUInt16:buffer Value:date];

	return YES;
}

@end
