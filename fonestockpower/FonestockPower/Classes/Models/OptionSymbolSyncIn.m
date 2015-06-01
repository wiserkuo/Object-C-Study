//
//  OptionSymbolSyncIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/3/27.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "OptionSymbolSyncIn.h"
#import "CodingUtil.h"

@implementation OptionSymbolSyncIn

@synthesize dataArray;

- (id)init
{
	if(self = [super init])
	{
		NSMutableArray *tmp = [[NSMutableArray alloc] init];
		self.dataArray = tmp;
	}
	return self;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	date = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	syncType = *tmpPtr++;
	sectorID = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	numberOfSymbol = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	for(int i=0 ; i<numberOfSymbol ; i++)
	{
		if (syncType == 1) //remove
		{
			UInt16 size = 0;
			SymbolFormat6 *symbolFormat6 = [[SymbolFormat6 alloc] initWithBuff:tmpPtr objSize:&size Offset:0];
			tmpPtr += size;
			[dataArray addObject:symbolFormat6];
		}
		else if (syncType == 0) //add
		{
			UInt16 size = 0;
			SymbolFormat5 *symbolFormat5 = [[SymbolFormat5 alloc] initWithBuff:tmpPtr objSize:&size Offset:0];
			tmpPtr += size;
			[dataArray addObject:symbolFormat5];
		}
	}
	//送出在這	傳self
	retCode = retcode;
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.securityName performSelector:@selector(addOption:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}


@end
