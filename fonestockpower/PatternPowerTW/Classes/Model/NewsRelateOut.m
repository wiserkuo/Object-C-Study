//
//  NewsRelateOut.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NewsRelateOut.h"
#import "CodingUtil.h"
#import "OutPacket.h"

@implementation NewsRelateOut

- (id)initWithSecuritySN:(UInt32)s StarDate:(UInt16)sd EndDate:(UInt16)ed CountPage:(UInt8)c PageNo:(UInt8)p
{
	if(self = [super init])
	{
		securitySN = s;
		startDate = sd;
		endDate = ed;
		countPage = c;
		pageNo = p;
		
	}
	return self;
}

- (int)getPacketSize
{
	return 10;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr;
	tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 3;
	phead->command = 4;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer += sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:buffer Value:securitySN];
	buffer+=4;
	[CodingUtil setUInt16:buffer Value:startDate];
	buffer+=2;
	[CodingUtil setUInt16:buffer Value:endDate];
	buffer+=2;
	*buffer++ = countPage;
	*buffer = pageNo;
	
	return YES;
}

@end
