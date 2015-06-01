//
//  BrokersIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BrokersIn.h"


@implementation BrokersIn

@synthesize brokersAddArray;
@synthesize brokersRemoveArray;

- (id)init
{
	if(self = [super init])
	{
		brokersAddArray = [[NSMutableArray alloc] init];
		brokersRemoveArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	returnCode = retcode;
	recordDate = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	int count = *tmpPtr++;
	int offset = 0;
	for(int i=0 ; i<count ; i++)	//add
	{
		int size = 0;
		BrokersParam *brokersParam = [[BrokersParam alloc] initWithBuffer:tmpPtr Offset:&offset ObjSize:&size];
		tmpPtr += size;
		[brokersAddArray addObject:brokersParam];
	}
	count = *tmpPtr++;
	for(int i=0 ; i<count ; i++)	//remove
	{
		int size = 0;
		BrokersParam *brokersParam = [[BrokersParam alloc] initWithBuffer:tmpPtr Offset:&offset ObjSize:&size];
		tmpPtr += size;
		[brokersRemoveArray addObject:brokersParam];
	}
	
	//送出在這~~
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.brokerInfo performSelector:@selector(syncBrokerInfo:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end

@implementation BrokersParam

@synthesize brokerName;

- (id)initWithBuffer:(UInt8*)tmpPtr Offset:(int*)offset ObjSize:(int*)size
{
	if(self = [super init])
	{
		UInt8 *firstPtr = tmpPtr;
		brokerType = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:*offset Bits:8];
		brokerID = [CodingUtil getUint16FromBuf:tmpPtr Offset:*offset Bits:16];
		tmpPtr += 2;
		UInt8 msgSize = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:*offset Bits:8];
		if(msgSize)
			brokerName = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:*offset Length:msgSize Encoding:NSUTF8StringEncoding];
		tmpPtr += msgSize;
		*size += (tmpPtr - firstPtr);
		
	}
	return self;
}

@end
