//
//  BrokersByStockOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/12.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "BrokersByOut.h"
#import "OutPacket.h"

@implementation BrokersByStockOut

- (id)initWithSecurityNum:(UInt32)cn RecordDate:(UInt16)d DayType:(UInt8)dt CountType:(UInt8)ct SortType:(UInt8)st
{
	if(self = [super init])
	{
		securityNum = cn;
		date = d;
		dayType = dt;
		countType = ct;
        sortType = st;
	}
	return self;
}

- (id)initWithSecurityNum:(UInt32)cn RecordDate:(UInt16)d Days:(UInt8)ds Counts:(UInt8)cs SortType:(UInt8)st
{
	if(self = [super init])
	{
		securityNum = cn;
		date = d;
		dayType = 0;
		days = ds;
		countType = 0;
		count = cs;
        sortType = st;
	}
	return self;
}

- (int)getPacketSize
{
	int baseSize = 9;
	if(dayType == 0)
		baseSize++;
	if(countType == 0)
		baseSize++;
	return baseSize;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 30;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);

	[CodingUtil setUInt32:tmpPtr Value:securityNum];
	tmpPtr += 4;
	[CodingUtil setUInt16:tmpPtr Value:date];
	tmpPtr += 2;
	*tmpPtr++ = dayType;
	if(dayType == 0)
		*tmpPtr++ = days;
	*tmpPtr++ = countType;
	if(countType == 0)
		*tmpPtr++ = count;
    *tmpPtr++ = sortType;
    
	
	return YES;
}


@end


@implementation BrokersByBrokerOut

- (id)initWithBrokerID:(UInt16)bID RecordDate:(UInt16)d DayType:(UInt8)dt CountType:(UInt8)ct
{
	if(self = [super init])
	{
		brokerID = bID;
		date = d;
		dayType = dt;
		countType = ct;
	}
	return self;
}

- (id)initWithBrokerID:(UInt16)bID RecordDate:(UInt16)d Days:(UInt8)ds Counts:(UInt8)cs
{
	if(self = [super init])
	{
		brokerID = bID;
		date = d;
		dayType = 0;
		days = ds;
		countType = 0;
		count = cs;
	}
	return self;
}

- (int)getPacketSize
{
	int baseSize = 6;
	if(dayType == 0)
		baseSize++;
	if(countType == 0)
		baseSize++;
	return baseSize;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 24;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
	
	[CodingUtil setUInt16:tmpPtr Value:brokerID];
	tmpPtr += 2;
	[CodingUtil setUInt16:tmpPtr Value:date];
	tmpPtr += 2;
	*tmpPtr++ = dayType;
	if(dayType == 0)
		*tmpPtr++ = days;
	*tmpPtr++ = countType;
	if(countType == 0)
		*tmpPtr++ = count;
	
	return YES;
}

@end


@implementation BrokersByAnchorOut

- (id)initWithSecurityNum:(UInt32)cn BrokerID:(UInt16)bID Count:(UInt8)c
{
	if(self = [super init])
	{
		securityNum = cn;
		brokerID = bID;
		count = c;
	}
	return self;
}

- (id)initWithSecurityNum:(UInt32)cn BrokerID:(UInt16)bID StartDate:(UInt16)sd EndDate:(UInt16)ed
{
	if(self = [super init])
	{
		securityNum = cn;
		brokerID = bID;
		count = 0;
		startDate = sd;
		endDate = ed;
	}
	return self;
}

- (int)getPacketSize
{
	int baseSize = 7;
	if(count == 0)
		baseSize += 4;
	return baseSize;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 25;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);

	[CodingUtil setUInt32:tmpPtr Value:securityNum];
	tmpPtr += 4;
	[CodingUtil setUInt16:tmpPtr Value:brokerID];
	tmpPtr += 2;
	*tmpPtr++ = count;
	if(count == 0)
	{
		[CodingUtil setUInt16:tmpPtr Value:startDate];
		tmpPtr += 2;
		[CodingUtil setUInt16:tmpPtr Value:endDate];
		tmpPtr += 2;
	}
	
	return YES;
}

@end

@implementation NewBrokersByBroker

- (id)initWithBrokerId:(UInt16)bId RecordDate:(UInt16)d DayType:(UInt8)dt CountType:(UInt8)ct SortType:(UInt8)st
{
    if(self = [super init])
    {
        brokerId = bId;
        date = d;
        dayType = dt;
        countType = ct;
        sortType = st;
    }
    return self;
}

- (id)initWithBrokerId:(UInt16)bId RecordDate:(UInt16)d Days:(UInt8)ds Counts:(UInt8)cs SortType:(UInt8)st
{
    if(self = [super init])
    {
        brokerId = bId;
        date = d;
        dayType = 0;
        days = ds;
        countType = 0;
        count = cs;
        sortType = st;
    }
    return self;
}

- (int)getPacketSize
{
    int baseSize = 7;
    if(dayType == 0)
        baseSize++;
    if(countType == 0)
        baseSize++;
    return baseSize;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead->escape = 0x1B;
    phead->message = 2;
    phead->command = 31;
    [CodingUtil setUInt16:(char*)&(phead->size) Value:len];
    tmpPtr+=sizeof(OutPacketHeader);
    
    [CodingUtil setUInt16:tmpPtr Value:brokerId];
    tmpPtr += 2;
    [CodingUtil setUInt16:tmpPtr Value:date];
    tmpPtr += 2;
    *tmpPtr++ = dayType;
    if(dayType == 0)
        *tmpPtr++ = days;
    *tmpPtr++ = countType;
    if(countType == 0)
        *tmpPtr++ = count;
    *tmpPtr++ = sortType;
    
    return YES;
}

@end