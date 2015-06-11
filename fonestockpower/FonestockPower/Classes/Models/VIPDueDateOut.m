//
//  VIPDueDateOut.m
//  Bullseye
//
//  Created by Neil on 13/8/30.
//
//

#import "VIPDueDateOut.h"
#import "OutPacket.h"
#import "CodingUtil.h"

@implementation VIPDueDateOut


-(int)getPacketSize{
    return 0;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 5;
	phead->command = 1;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer += sizeof(OutPacketHeader);

	buffer = tmpPtr;
	return YES;
}


@end
