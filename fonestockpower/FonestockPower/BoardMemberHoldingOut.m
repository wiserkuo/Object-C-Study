//
//  BoardMemberHoldingOut.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "BoardMemberHoldingOut.h"
#import "OutPacket.h"
@implementation BoardMemberHoldingOut
- (id)initWithSecurityNum:(UInt32)cn RecordDate:(UInt16)rd Counts:(UInt8)c
{
	if(self = [super init])
	{
		securityNum = cn;
		counts = c;
		recordDate = rd;
	}
	return self;
}

- (int)getPacketSize
{
	return 7;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 27;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:tmpPtr Value:securityNum];
	tmpPtr += 4;
	*tmpPtr++ = counts;
	[CodingUtil setUInt16:tmpPtr Value:recordDate];
    
	return YES;
}

@end
