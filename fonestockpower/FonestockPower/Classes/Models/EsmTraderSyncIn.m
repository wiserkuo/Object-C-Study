//
//  EsmTraderSyncIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/17.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "EsmTraderSyncIn.h"
#import "EsmTraderInfo.h"

@implementation EsmTraderSyncIn

@synthesize traderAddArray;
@synthesize traderRemoveArray;

- (id)init
{
	if(self = [super init])
	{
		traderAddArray = [[NSMutableArray alloc] init];
		traderRemoveArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	returnCode = retcode;
	recordDate = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	int syncType = *tmpPtr++;
	int count = *tmpPtr++;
	if(syncType == 0)	//add
	{
		for(int i=0 ; i<count ; i++)	//add
		{
			EsmTraderParam *tdParam = [[EsmTraderParam alloc] init];
			tdParam->traderID = [CodingUtil getUInt16:tmpPtr];
			tmpPtr += 2;
			int msgSize = *tmpPtr++;
			NSString *tmpString;
			tmpString = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:0 Length:msgSize Encoding:NSUTF8StringEncoding];
			tdParam.traderName = tmpString;
			tmpPtr += msgSize;
			
			msgSize = *tmpPtr++;
			tmpString = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:0 Length:msgSize Encoding:NSUTF8StringEncoding];
			tdParam.traderTele = tmpString;
			tmpPtr += msgSize;
			
			[traderAddArray addObject:tdParam];
		}
	}
	else if(syncType == 1)	//remove
	{
		for(int i=0 ; i<count ; i++)
		{
			EsmTraderParam *tdParam = [[EsmTraderParam alloc] init];
			tdParam->traderID = [CodingUtil getUInt16:tmpPtr];
			tmpPtr += 2;
			
			[traderRemoveArray addObject:tdParam];
		}
	}	
	//送出在這~~
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.esmTraderInfo performSelector:@selector(syncEsmTraderInfo:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end



@implementation EsmTraderParam

@synthesize traderName;
@synthesize traderTele;


@end
