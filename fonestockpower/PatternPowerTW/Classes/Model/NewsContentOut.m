//
//  NewsContentOut.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NewsContentOut.h"
#import "OutPacket.h"
#import "CodingUtil.h"

@implementation NewsContentOut

- (id)initWithType0SN:(UInt32)newSN
{
	if(self = [super init])
	{
		type = 0;
		newsSN = newSN;
	}
	return self;
}

- (id)initWithType1Date:(UInt16)d sectorID:(UInt16)sID SN:(UInt16)s
{
	if(self = [super init])
	{
		type = 1;
		date = d;
		sectorID = sID;
		SN = s;
	}
	return self;
}

- (int)getPacketSize
{
	if(type)
		return 1+(3*sizeof(UInt16));
	else
		return 1+sizeof(UInt32);
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr;
	tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 3;
	phead->command = 3;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer += sizeof(OutPacketHeader);
	*buffer++ = type;	
	if(type == 0){
		[CodingUtil setUInt32:buffer Value:newsSN];
//        [CodingUtil setUInt32:&buffer value:newsSN needOffset:YES];
	}
	else{
		[CodingUtil setUInt16:buffer Value:date];
		buffer += sizeof(UInt16);
		[CodingUtil setUInt16:buffer Value:sectorID];
		buffer += sizeof(UInt16);
		[CodingUtil setUInt16:buffer Value:SN];
	}
	
	buffer = tmpPtr;
	return YES;
}


@end
