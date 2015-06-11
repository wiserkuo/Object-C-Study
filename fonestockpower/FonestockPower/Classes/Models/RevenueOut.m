//
//  RevenueOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RevenueOut.h"
#import "OutPacket.h"


@implementation RevenueOut

- (id)initWithDate:(UInt16)d CommodityNum:(UInt32)cn DataType:(char)t
{
	if(self = [super init])
	{
		commodityNum = cn;
		dataType = t;
		queryType = 0;
		date = d;
	}
	return self;
}

- (id)initWithYearCount:(UInt8)c CommodityNum:(UInt32)cn DataType:(char)t
{
	if(self = [super init])
	{
		commodityNum = cn;
		dataType = t;
		queryType = 0; 
		yearCount = c;
	}
	return self;
}

- (void)setThisIsNewRevenue
{
	newRevenue = YES;
}

- (int)getPacketSize
{
	if(queryType) return 7; // Count of year Type
	else return	8;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
//	if(newRevenue)
		phead->command = 29;
//	else
//		phead->command = 10;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:tmpPtr Value:commodityNum];
	tmpPtr += 4;
	*tmpPtr++ = dataType;
	*tmpPtr++ = queryType;
	if(queryType)
		*tmpPtr = yearCount;
	else
		[CodingUtil setUInt16:&tmpPtr value:date needOffset:YES];
	return YES;
}


@end
