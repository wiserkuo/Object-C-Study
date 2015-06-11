//
//  BADataOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/2/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BADataOut.h"
#import "OutPacket.h"

@implementation BADataOut

- (id)initWithCommodityNum:(UInt32)cn
{
	if(self = [super init])
	{
		commodityNum = cn;
	}
	return self;
}

- (int)getPacketSize
{
	return 4;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 1;
	phead->command = 3;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:tmpPtr Value:commodityNum];
	
	return YES;
}


@end
