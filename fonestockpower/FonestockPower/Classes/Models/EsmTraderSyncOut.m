//
//  EsmTraderSyncOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/17.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "EsmTraderSyncOut.h"
#import "OutPacket.h"

@implementation EsmTraderSyncOut

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
	phead->command = 26;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt16:tmpPtr Value:recordDate];
	return YES;
}

@end
