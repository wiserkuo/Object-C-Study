//
//  SectorTableOut.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/25.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SectorTableOut.h"
#import "OutPacket.h"


@implementation SectorTableOut

- (id)initWithIDsync:(UInt16)sID recursive:(UInt8)r Sync:(UInt8)ifsync sectorCount:(UInt16)c sectorID:(UInt16*)d
{
	if (self = [super init])
	{
		[CodingUtil setUInt16:(char*)headerData.sectorIDsync Value:sID];
		headerData.recursive = r;
		headerData.ifsync = ifsync;
		if(ifsync)
		{
			sectorCount = c;
			sectorID = malloc(sectorCount*sizeof(UInt16));
			for(int i=0 ; i<sectorCount ; i++)
			{
				sectorID[i] = d[i];
			}
		}
	}
	return self;	
}

- (void)makedate:(int)year month:(int)month day:(int)day
{
	[CodingUtil setUInt16:(char*)&(headerData.STdate) Value:[CodingUtil makeDate:year month:month day:day]];
}

- (void)setdate:(UInt16)date;
{
	[CodingUtil setUInt16:(char*)&(headerData.STdate) Value:date];
}

- (int)getPacketSize{
	if(headerData.ifsync)
		return (sizeof(SectorTableOutData)+2+2*sectorCount);
	else
		return sizeof(SectorTableOutData);
}

- (BOOL)encode:(NSObject*)account buffer:(char*)buffer length:(int)len
{
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 4;
	phead->command = 8;
//    phead->message = 12;
//	phead->command = 8;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	
	SectorTableOutRef pbody = (SectorTableOutRef)(++phead);
	memcpy(pbody,&headerData,sizeof(headerData));
	if(headerData.ifsync)
	{
		[CodingUtil setUInt16:(buffer+sizeof(OutPacketHeader)+sizeof(SectorTableOutData)) Value:sectorCount];
		[CodingUtil setUInt16:(buffer+sizeof(OutPacketHeader)+sizeof(SectorTableOutData)+2) Value:sectorID[0]];
		for(int i=0 ; i<sectorCount ; i++)
		{
			[CodingUtil setUInt16:(buffer+sizeof(OutPacketHeader)+sizeof(SectorTableOutData)+2*(i+1)) Value:sectorID[i]];
		}
	}
	
	
	return YES;
}

- (void)dealloc{
	if(headerData.ifsync)
		free(sectorID);
}

@end
