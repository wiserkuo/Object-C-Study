//
//  HistoricalEPSOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HistoricalEPSOut.h"
#import "OutPacket.h"


@implementation HistoricalEPSOut

- (id)initWithStartDate:(UInt16)sd EndDate:(UInt16)ed CommodityNum:(UInt32)cn EPSType:(UInt8)et
{
	if(self = [super init])
	{
		commodityNum = cn;
		epsType = et;
		count = 0;
		startDate = sd;
		endDate = ed;
	}
	return self;
}

- (id)initWithCount:(UInt8)c CommodityNum:(UInt32)cn EPSType:(UInt8)et
{
	if(self = [super init])
	{
		commodityNum = cn;
		epsType = et;
		count = c;
	}
	return self;
}

- (int)getPacketSize
{
	if(count) return 5;
	else return 9;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 12;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:tmpPtr Value:commodityNum];
	tmpPtr += 4;
	[CodingUtil setBufferr:epsType Bits:1 Buffer:tmpPtr Offset:0];
	[CodingUtil setBufferr:count Bits:7 Buffer:tmpPtr Offset:1];
	tmpPtr++;
	if(!count)
	{
		[CodingUtil setUInt16:tmpPtr Value:startDate];
		tmpPtr += 2;
		[CodingUtil setUInt16:tmpPtr Value:endDate];
	}
	return YES;
}

@end
