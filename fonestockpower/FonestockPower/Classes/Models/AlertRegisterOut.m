//
//  AlertRegisterOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/11/2.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "AlertRegisterOut.h"
#import "OutPacket.h"
@implementation AlertRegisterOut

- (id)initWithAlertFlag:(BOOL)onOff
{
	if(self = [super init])
	{
		alertFlag = onOff;
	}
	return self;	
}

- (int)getPacketSize{
	
	return 2;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr;
	tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 4;
	phead->command = 17;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr += sizeof(OutPacketHeader);
	
	*tmpPtr++ = alertFlag ? 1 : 0;
	*tmpPtr++ = alertFlag ? 1 : 0;		//帶下全部的snapshot
	return YES;
}

@end
