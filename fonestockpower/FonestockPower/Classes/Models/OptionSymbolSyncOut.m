//
//  OptionSymbolSyncOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/3/27.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "OptionSymbolSyncOut.h"
#import "OutPacket.h"

@implementation OptionSymbolSyncOut

- (id)initWithSectorID:(UInt16)sID Date:(UInt16)d
{
	if(self = [super init])
	{
		sectorID = sID;
		date = d;
	}
	return self;
}

- (int)getPacketSize
{
	return 4;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 1;
	phead->command = 8;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt16:buffer Value:sectorID];
	buffer += 2;
	[CodingUtil setUInt16:buffer Value:date];
	
	return YES;
}


@end
