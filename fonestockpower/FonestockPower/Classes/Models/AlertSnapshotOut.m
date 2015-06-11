//
//  AlertSnapshotOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/11/2.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "AlertSnapshotOut.h"
#import "OutPacket.h"

@implementation AlertSnapshotOut

- (id)initWithSecurityNum:(UInt32*)sNum Count:(UInt16)c
{
	if(self = [super init])
	{
		count = c;
		if(count)
			securityNum = malloc(count * sizeof(UInt32));
		for(int i=0 ; i<count ; i++)
			securityNum[i] = sNum[i];
	}
	return self;	
}

- (int)getPacketSize{
	
	return 2 + count * sizeof(UInt32);
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr;
	tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 1;
	phead->command = 21;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr += sizeof(OutPacketHeader);
	
	[CodingUtil setUInt16:tmpPtr Value:count];
	tmpPtr += 2;
	for(int i=0 ; i<count ; i++)
	{
		[CodingUtil setUInt32:tmpPtr Value:securityNum[i]];
		tmpPtr += 4;
	}
	return YES;
}

- (void)dealloc
{
	if(securityNum) free(securityNum);
}

@end
