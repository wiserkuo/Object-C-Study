//
//  HistoricalDividendOut.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "HistoricalDividendOut.h"
#import "OutPacket.h"

@implementation HistoricalDividendOut
- (id)initWithStartDate:(UInt16)sd EndDate:(UInt16)ed CommodityNum:(UInt32)cn
{
	if(self = [super init])
	{
		commodityNum = cn;
		startDate = sd;
		endDate = ed;
		count = 0;
		queryType = 0;
	}
	return self;
}

- (id)initWithCount:(UInt8)c CommodityNum:(UInt32)cn
{
	if(self = [super init])
	{
		commodityNum = cn;
		count = c;
		queryType = 0;
	}
	return self;
}

- (int)getPacketSize
{
	if(!queryType) return 9;  // query with Date
	else return 5;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 11;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:tmpPtr Value:commodityNum];
	tmpPtr += 4;
    *tmpPtr++ = 0;
	if(!queryType)
	{
		[CodingUtil setUInt16:tmpPtr Value:startDate];
		tmpPtr += 2;
		[CodingUtil setUInt16:tmpPtr Value:endDate];
	}
	return YES;
}

@end
