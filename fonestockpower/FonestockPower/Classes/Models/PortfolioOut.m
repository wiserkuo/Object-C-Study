//
//  PortfolioOut.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/25.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PortfolioOut.h"
#import "OutPacket.h"
#import "Commodity.h"


@implementation PortfolioOut

- (id)init
{
	if (self = [super init])
	{
	}
	
	return self;
}


- (void)removePortfolio:(UInt32*)s count:(UInt8)c
{
	subType = 1;
	count = c;
	allSize = count*sizeof(UInt32);
	allSercurityNos = malloc(allSize);
	for(int i=0 ; i<count ; i++)
		[CodingUtil setUInt32:(char*)(allSercurityNos+i) Value:*(s+i)];
}

- (void)addPortfolio:(NSMutableArray*)s;
{
	int address=0;
	subType = 0;
	count = 0;
	allSize = 0;
	Commodity *obj;
	for (obj in s)
	{
		allSize+=[obj getSize];
	}
	allIdenSymbol = malloc(allSize);
	for (obj in s)
	{
		memcpy(allIdenSymbol+address, [obj getIdentSymbol], [obj getSize]);
		address+=[obj getSize];
		count++;
	}
}

- (void)addWatchLists:(NSMutableArray*)s
{
	int address=0;
	subType = 4;
	count = 0;
	allSize = 0;
	Commodity *obj;
	for (obj in s)
	{
		allSize+=[obj getSize];
	}
	allIdenSymbol = malloc(allSize);
	for (obj in s)
	{
		memcpy(allIdenSymbol+address, [obj getIdentSymbol], [obj getSize]);
		address+=[obj getSize];
		count++;
	}
}

- (void)removeWatchLists:(UInt32*)s count:(UInt8)c
{
	subType = 5;
	count = c;
	allSize = count*sizeof(UInt32);
	allSercurityNos = malloc(allSize);
	for(int i=0 ; i<count ; i++)
		[CodingUtil setUInt32:(char*)(allSercurityNos+i) Value:*(s+i)];
}

- (void)addFocusd:(UInt32)s
{
	subType = 2;
	count = 1;
	allSize = sizeof(UInt32);
	allSercurityNos = malloc(allSize);
	[CodingUtil setUInt32:(char*)(allSercurityNos) Value:s];
}

- (void)removeFocusd
{
	subType = 3;
	count = 0;
	allSize = 0;
}

- (int)getPacketSize
{
	int size = 0;
	if(subType == 0 || subType == 1 || subType == 4 || subType == 5)
		size = 2+allSize;
	else
		size = 1+allSize;
	return size;
}

- (BOOL)encode:(NSObject*)account buffer:(char*)buffer length:(int)len
{
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 4;
	phead->command = 2;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	char *tmpPtr = buffer+sizeof(OutPacketHeader);
	
	memcpy(tmpPtr , &subType , 1);
	if (subType == 1 || subType == 5)  //subType == 1 is Remove
	{
		memcpy(tmpPtr+1 , &count , 1);
		memcpy(tmpPtr+2 , allSercurityNos , allSize);
	}
	else if (subType == 0 || subType == 4)        // Add
	{
		memcpy(tmpPtr+1 , &count , 1);
		memcpy(tmpPtr+2 , allIdenSymbol , allSize);
	}
	else if (subType == 2)        // set focus
	{
		memcpy(tmpPtr+1 , allSercurityNos , allSize);
	}
	return YES;
}

- (void)dealloc
{
	if(allSercurityNos) free(allSercurityNos);
	if(allIdenSymbol) free(allIdenSymbol);
}

@end
