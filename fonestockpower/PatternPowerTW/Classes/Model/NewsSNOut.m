//
//  NewSNOut.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NewsSNOut.h"
#import "CodingUtil.h"
#import "OutPacket.h"


@implementation NewsSNOut

- (id)initWithNewsSectorID:(UInt16*)sID count:(UInt8)c
{
	if(self = [super init])
	{
		count = c;
		newsSectorRootID = malloc((count*sizeof(UInt16)));
		memcpy(newsSectorRootID , sID , (count*sizeof(UInt16)));
	}
	return self;
}

- (int)getPacketSize
{
	return 1+(count*sizeof(UInt16));
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 3;
	phead->command = 1;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer += sizeof(OutPacketHeader);
	*buffer++ = count;
	for(int i=0 ; i<count ; i++)
	{
		[CodingUtil setUInt16:buffer Value:newsSectorRootID[i]];
		buffer+=2;
	}
	buffer = tmpPtr;
	return YES;
}



@end
