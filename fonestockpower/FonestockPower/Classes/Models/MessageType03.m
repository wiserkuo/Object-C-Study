//
//  MessageType03.m
//  Bullseye
//
//  Created by Yehsam on 2009/2/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MessageType03.h"
#import "BADataIn.h"
#import "CodingUtil.h"


@implementation MessageType03

@synthesize BAArray;
@synthesize securityNO;

- (id)init
{
	if(self = [super init])
	{
		BAArray = [[NSMutableArray alloc] init];
	}
	return self;
}

+ (void) decodeType03:(UInt8*)body Array:(NSMutableArray*)tmpArray
{
	UInt8 *tmpPtr = body;
	int offset = 0;
	UInt8 count = [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:3];
	//NSLog(@"五檔:%d",count);
	offset += 3;
	int tmpOffset = offset;
	for(int i=0 ; i<count ; i++)
	{
		BADataParam *baParam = [[BADataParam alloc] init];;
		PriceFormatData tmpPrice;
		TAvalueFormatData tmpTA;
		double tmpVal;
		
		if(i==0 || [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:1]==0)
		{
			if(i>0 && [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:1]==0) tmpOffset=++offset;
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&baParam->bidPrice Offset:0]; 
			tmpOffset = offset;
		}
		else
		{
			if(i>0 && [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:1]==1) tmpOffset=++offset;
			BADataParam *tmpParam = [tmpArray objectAtIndex:i-1];
			baParam->bidPrice=tmpParam->bidPrice;
		}

		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&baParam->bidVolume Offset:0]; 
		tmpOffset = offset;
		
		if(i==0 || [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:1]==0)
		{
			if(i>0 && [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:1]==0) tmpOffset=++offset;
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&baParam->askPrice Offset:0]; 
			tmpOffset = offset;
		}
		else 
		{
			if(i>0 && [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:1]==1) tmpOffset=++offset;
			BADataParam *tmpParam = [tmpArray objectAtIndex:i-1];
			baParam->askPrice=tmpParam->askPrice;
		}
		
		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&baParam->askVolume Offset:0]; 
		tmpOffset = offset;
		[tmpArray addObject:baParam];
	}
	
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	securityNO = commodity;
	[MessageType03 decodeType03:body Array:BAArray];
	//傳送在這~~傳BAArray
	// Send to Data Modal.
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    //neil
	BOOL flag = [dataModal.option checkFocusSN:commodity];	//判斷是否為Option的
	if(flag)
		[dataModal.option performSelector:@selector(BAArrive:) onThread:dataModal.thread withObject:BAArray waitUntilDone:NO];
	else
		[dataModal.portfolioTickBank performSelector:@selector(addNearestBidAsk:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end
