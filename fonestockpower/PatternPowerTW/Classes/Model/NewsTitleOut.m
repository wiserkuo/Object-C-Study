//
//  NewsTitleOut.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NewsTitleOut.h"
#import "OutPacket.h"
#import "CodingUtil.h"


@implementation NewsTitleOut

- (id)initWithSectorID:(UInt16)sID BeginSN:(UInt16)bSN EndSN:(UInt16)eSN
{
	if(self = [super init])
	{
		sectorID = sID;
		beginSN = bSN;
		endSN = eSN;
	}
	return self;
}

- (int)getPacketSize
{
	if(beginSN == 0)
		return (2*sizeof(UInt16));
	else
		return (3*sizeof(UInt16));
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;

	
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 3;
	phead->command = 2;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer += sizeof(OutPacketHeader);
	[CodingUtil setUInt16:buffer Value:sectorID];
	buffer+=2;
	[CodingUtil setUInt16:buffer Value:beginSN];
	buffer+=2;
	if(beginSN)
		[CodingUtil setUInt16:buffer Value:endSN];
	buffer = tmpPtr;
	return YES;
}



@end
