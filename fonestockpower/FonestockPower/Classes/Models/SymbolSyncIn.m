//
//  SymbolSyncIn.m
//  Bullseye
//
//  Created by Yehsam on 2008/12/3.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SymbolSyncIn.h"


@implementation SymbolSyncIn

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
	year = [CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:7] + 1960;
	month = [CodingUtil getUint8FromBuf:tmpPtr Offset:7 Bits:4];
	day = [CodingUtil getUint8FromBuf:tmpPtr Offset:11 Bits:5];
	date = [CodingUtil getUInt16:tmpPtr];
	tmpPtr+=2;
	syncType = *tmpPtr++;
	sectorID = [CodingUtil getUInt16:tmpPtr];
	tmpPtr+=2;
	countSymbol = [CodingUtil getUInt16:tmpPtr];
	tmpPtr+=2;
	retCode = retcode;
	
	//NSLog(@"SymbolSyncIn count:%d",countSymbol);

	for( int i=0 ; i<countSymbol ; i++)
	{
		if (syncType == 1)   //Remove
		{
			SymbolFormat3 *symbolData;
			UInt16 tmpSize;
			symbolData = [[SymbolFormat3 alloc] initWithBuff:tmpPtr objSize:&tmpSize Offset:0];
			tmpPtr += tmpSize;
			[dataArray addObject:symbolData];
		}
		else if (syncType == 0 || syncType == 2)   //Add or Replace
		{
			SymbolFormat1 *symbolData;
			UInt16 tmpSize;
			symbolData = [[SymbolFormat1 alloc] initWithBuff:tmpPtr objSize:&tmpSize Offset:0];
			tmpPtr += tmpSize;
			[dataArray addObject:symbolData];
		}
	}
	// not ok!!
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.securityName performSelector:@selector(addSecurity:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end
