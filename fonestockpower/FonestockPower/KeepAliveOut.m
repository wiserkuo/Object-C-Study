//
//  KeepAliveOut.m
//  Bullseye
//
//  Created by Yehsam on 2008/12/8.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KeepAliveOut.h"
#import "OutPacket.h"
#import "CodingUtil.h"


@implementation KeepAliveOut

- (id)initWithTimeStamp:(UInt32)t identifier:(UInt16)i
{
	if(self = [super init])
	{
		timeStamp = t;
		Identifier = i;
	}
	return self;
}

- (int)getPacketSize
{
	return 7;
}

- (BOOL)encode:(NSObject*)account buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 12;
	phead->command = 5;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr += sizeof(OutPacketHeader);
	[CodingUtil setUInt32:tmpPtr Value:timeStamp];
	tmpPtr+=4;
	[CodingUtil setUInt16:tmpPtr Value:Identifier];
	tmpPtr+=2;
    *tmpPtr++ = 0;
    *tmpPtr++ = 0;
	return YES;
}


@end
