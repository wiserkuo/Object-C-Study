//
//  BrokersOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BrokersOut.h"
#import "OutPacket.h"


@implementation BrokersOut

- (id)initWithRecordDate:(UInt16)rd
{
	if(self = [super init])
	{
		recordDate = rd;
	}
	return self;
}

- (int)getPacketSize
{
	return 2;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 22;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt16:tmpPtr Value:recordDate];
	return YES;
}

@end
