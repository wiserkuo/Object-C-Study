//
//  MarginTradingIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MarginTradingIn.h"
#import "CodingUtil.h"

@implementation MarginTradingIn

@synthesize marginTradingArray;

- (id)init
{
	if(self = [super init])
	{
		marginTradingArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	int count = *tmpPtr++;
	int offset=0;
	retCode = retcode;
	for(int i=0 ; i<count ; i++)
	{
		MarginTradingParam *marginTradingParam = [[MarginTradingParam alloc] init];
		marginTradingParam->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
		offset += 16;
		TAvalueFormatData tmpTA;
		marginTradingParam->usedAmount = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		marginTradingParam->usedAmountUnit = tmpTA.magnitude;
		marginTradingParam->amountOffset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		marginTradingParam->amountOffsetUnit = tmpTA.magnitude;
		marginTradingParam->amountRatio = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		marginTradingParam->amountRatioUnit = tmpTA.magnitude;
		marginTradingParam->usedShare = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		marginTradingParam->usedShareUnit = tmpTA.magnitude;
		marginTradingParam->sharedOffset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		marginTradingParam->sharedOffsetUnit = tmpTA.magnitude;
		marginTradingParam->sharedRatio = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		marginTradingParam->sharedRatioUnit = tmpTA.magnitude;
		marginTradingParam->offset = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		marginTradingParam->offsetUnit = tmpTA.magnitude;
		
		[marginTradingArray addObject:marginTradingParam];
	}
	commodityNum = commodity;
	//送出在這~~
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.marginTrading performSelector:@selector(decodeArrive:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end

@implementation MarginTradingParam

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (void)dealloc
{
//	[super dealloc];
}

@end
