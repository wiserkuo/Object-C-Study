//
//  InvesterBSOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InvesterBSOut.h"
#import "OutPacket.h"
#import "CodingUtil.h"


@implementation InvesterBSOut

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
	phead->command = 6;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:&tmpPtr value:commodityNum needOffset:YES];
	*tmpPtr++ = IIG_ID;
//	[CodingUtil setUInt16:&tmpPtr value:startDate+1 needOffset:YES];
    [CodingUtil setUInt16:&tmpPtr value:startDate needOffset:YES];
    [CodingUtil setUInt16:&tmpPtr value:endDate needOffset:YES];

	return YES;
}

@end
