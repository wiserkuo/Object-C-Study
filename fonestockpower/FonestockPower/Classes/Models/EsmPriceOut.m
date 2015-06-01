//
//  EsmPriceOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/19.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "EsmPriceOut.h"
#import "OutPacket.h"

@implementation EsmPriceOut

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
	phead->command = 19;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:tmpPtr Value:commodityNum];
	
	return YES;
}

@end
