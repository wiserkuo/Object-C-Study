//
//  SymbolSyncOut.m
//  Bullseye
//
//  Created by Yehsam on 2008/12/3.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SymbolSyncOut.h"
#import "OutPacket.h"
#import "ValueUtil.h"

@implementation SymbolSyncOut

- (id)initWithSectorID:(UInt16)sID year:(UInt16)y month:(UInt8)m day:(UInt8)d
{
	if( self = [super init] )
	{
		sectorID = sID;
		date = [CodingUtil makeDate:y month:m day:d];
//		NSDate *ddd = [ValueUtil nsDateFromStkDate:date];
//		NSLog(@"SymbolSyncOut date:%@",[ddd description]);
	}
	return self;
}

- (id)initWithSectorID_SyncDate:(UInt16)sID syncDate:(UInt16) syncDate
{
	if( self = [super init] )
	{
		sectorID = sID;
		date = syncDate;
//		NSDate *ddd = [ValueUtil nsDateFromStkDate:date];
//		NSLog(@"SymbolSyncOut date:%@",[ddd description]);

	}
	return self;
}

- (int)getPacketSize
{
	return 2*sizeof(UInt16);
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 1;
	phead->command = 4;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer+=sizeof(OutPacketHeader);
    
	[CodingUtil setUInt16:buffer Value:sectorID];
	buffer+=2;
	[CodingUtil setUInt16:buffer Value:date];
	buffer = tmpPtr;
	return YES;
	
}


@end
