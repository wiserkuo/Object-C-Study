//
//  TickDataIn.m
//  Bullseye
//
//  Created by Yehsam on 2008/12/4.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TickDataIn.h"
#import "MessageType10.h"
#import "MessageType11.h"
#import "MessageType12.h"
#import "Tick.h"

@implementation TickDataIn
@synthesize dataArray;

- (id)init
{
	if(self = [super init])
	{
		dataArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	dataCount = [CodingUtil getUInt16:tmpPtr];
	tmpPtr+=2;
	if(dataCount)
	{
		messageType = *tmpPtr++;
		dataLength = 0;
		int offset=0;
		for( int i=0 ; i<dataCount ; i++)
		{
			tmpPtr += dataLength;
			offset = 0;
			dataLength = *tmpPtr++;
			if(messageType == 10)
			{
				EquityTickParam *TickDataParam = [[EquityTickParam alloc] init];
				TickDataParam->securityNO = commodity;
				[MessageType10 decodeType10:tmpPtr TickParam:TickDataParam Offset:&offset];
				[dataArray addObject:TickDataParam];
			}
			else if(messageType == 11)
			{
				EquityTickParam *TickDataParam = [[EquityTickParam alloc] init];
				TickDataParam->securityNO = commodity;
				[MessageType11 decodeType11:tmpPtr TickParam:TickDataParam Offset:&offset];
				[dataArray addObject:TickDataParam];
			}
			else if(messageType == 12)
			{
				IndexTickParam *TickDataParam = [[IndexTickParam alloc] init];
				TickDataParam->securityNO = commodity;
				[MessageType12 decodeType12:tmpPtr TickParam:TickDataParam Offset:&offset];
				[dataArray addObject:TickDataParam];
			}
		}
	}
	
	// Send to Data Modal.
    
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.portfolioTickBank performSelector:@selector(addTick:) onThread:dataModal.thread withObject:dataArray waitUntilDone:NO];
}
@end

