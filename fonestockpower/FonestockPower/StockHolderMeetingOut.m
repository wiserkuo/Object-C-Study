//
//  StockHolderMeetingOut.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "StockHolderMeetingOut.h"
#import "OutPacket.h"

@implementation StockHolderMeetingOut
- (id)initWithCommodityNum:(UInt32)num QueryType:(UInt8)type RecordDate:(UInt16)date
{
	if(self = [super init])
	{
		commodityNum = num;
		queryType = type;
		pdaDate = date;
	}
	return self;
}

- (int)getPacketSize
{
	return sizeof(commodityNum) + sizeof(queryType) + sizeof(pdaDate);
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 10;
	phead->command = 21;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
    [CodingUtil setUInt32:&tmpPtr value:commodityNum needOffset:YES];
	[CodingUtil setUInt8:&tmpPtr value:queryType needOffset:YES];
    [CodingUtil setUInt16:&tmpPtr value:pdaDate needOffset:YES];
	return YES;
}
@end
