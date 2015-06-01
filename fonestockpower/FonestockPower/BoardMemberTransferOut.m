//
//  BoardMemberTransferOut.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "BoardMemberTransferOut.h"
#import "OutPacket.h"
@implementation BoardMemberTransferOut
- (id)initWithSecurityNum:(UInt32)cn Top_n:(UInt8)count start:(UInt16)sDate end:(UInt16)eDate modified:(UInt16)modifiedDate;
{
	if(self = [super init])
	{
		securityNum = cn;
		top_n = count;
        startDate = sDate;
        endDate = eDate;
        lastModifiedDate = modifiedDate;
	}
	return self;
}

- (int)getPacketSize
{
	return sizeof(securityNum) + sizeof(top_n) + sizeof(startDate) + sizeof(endDate) + sizeof(lastModifiedDate);
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 34;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:tmpPtr Value:securityNum];
	tmpPtr += 4;
	*tmpPtr++ = top_n;
	[CodingUtil setUInt16:tmpPtr Value:startDate];
    tmpPtr += 2;
    [CodingUtil setUInt16:tmpPtr Value:endDate];
    tmpPtr += 2;
    [CodingUtil setUInt16:tmpPtr Value:lastModifiedDate];
    tmpPtr += 2;
    
	return YES;
}
@end
