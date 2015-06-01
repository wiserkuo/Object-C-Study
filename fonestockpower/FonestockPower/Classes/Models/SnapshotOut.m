//
//  SnapshotOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/5/22.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "SnapshotOut.h"
#import "OutPacket.h"

@implementation SnapshotOut

- (id) initWithSubType:(UInt8)st CommodityNum:(UInt32)cn
{
	if(self = [super init])
	{
		count = 1;
		subType[count-1] = st;
		commodityNum[count-1] = cn;
	}
	return self;
}

- (void) addWithSubType:(UInt8)st CommodityNum:(UInt32)cn
{
	count++;
	subType[count-1] = st;
	commodityNum[count-1] = cn;
}

- (int)getPacketSize
{
	return 1+count*(sizeof(UInt8)+sizeof(UInt32));
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 1;
	phead->command = 2;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer+=sizeof(OutPacketHeader);
	*buffer++ = count;
	for(int i=0 ; i<count ; i++)
	{
		*buffer++ = subType[i];
		[CodingUtil setUInt32:buffer Value:commodityNum[i]];
		buffer += 4;
	}
	return YES;
}

@end
