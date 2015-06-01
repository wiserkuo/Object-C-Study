//
//  InvesterHoldOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InvesterHoldOut.h"
#import "OutPacket.h"
#import "CodingUtil.h"

@implementation InvesterHoldOut

- (id)initWithCommodityNum:(UInt32)cn IIG_ID:(UInt8)iid StartDate:(UInt16)sDate EndDate:(UInt16)eDate
{
	if(self = [super init])
	{
		commodityNum = cn;
		IIG_ID = iid;
		startDate = sDate;
		endDate = eDate;
	}
	return self;
}

- (int)getPacketSize
{
	return 9;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 7;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:tmpPtr Value:commodityNum];
	tmpPtr += 4;
	*tmpPtr++ = IIG_ID;
	[CodingUtil setUInt16:tmpPtr Value:startDate];
	tmpPtr += 2;
	[CodingUtil setUInt16:tmpPtr Value:endDate];
	return YES;
}

@end
