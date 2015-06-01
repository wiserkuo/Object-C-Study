//
//  TickDataOut.m
//  Bullseye
//
//  Created by Yehsam on 2008/12/4.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TickDataOut.h"
#import "OutPacket.h"


@implementation TickDataOut

- (id)initWithCommodityNum:(UInt32)c BeginSN:(UInt16)bSN EndSN:(UInt16)eSN
{
	if(self = [super init])
	{
		commodityNum = c;
		beginSN = bSN;
		endSN = eSN;
	}
	return self;
}

- (int)getPacketSize
{
	if( ((beginSN > 1279) || (endSN > 1279)) && ((beginSN>255 && endSN>255)))   // beginSN or endSN using 15 Bits
		return 8;
	else
		return 7;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 1;
	phead->command = 1;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:buffer Value:commodityNum];
	buffer+=4;
	UInt8 offset=0;
	if(beginSN < 256)
	{
		[CodingUtil setBufferr:beginSN Bits:9 Buffer:buffer Offset:0];
		offset = 9;
	}
	else if(beginSN > 255 && beginSN<1280)
	{
		beginSN = ((beginSN -256) + (2<<10));
		[CodingUtil setBufferr:beginSN Bits:12 Buffer:buffer Offset:0];
		offset = 12;
	}
	else
	{
		beginSN = ((beginSN - 1280) + (3<<13));
		[CodingUtil setBufferr:beginSN Bits:15 Buffer:buffer Offset:0];
		offset = 15;
	}
	
	if(endSN < 256)
	{
		[CodingUtil setBufferr:endSN Bits:9 Buffer:buffer Offset:offset];
	}
	else if(endSN > 255 && endSN<1280)
	{
		endSN = ((endSN -256) + (2<<10));
		[CodingUtil setBufferr:endSN Bits:12 Buffer:buffer Offset:offset];
	}
	else
	{
		endSN = ((endSN - 1280) + (3<<13));
		[CodingUtil setBufferr:endSN Bits:15 Buffer:buffer Offset:offset];
	}
	buffer = tmpPtr;
	
	return YES;
}

@end
