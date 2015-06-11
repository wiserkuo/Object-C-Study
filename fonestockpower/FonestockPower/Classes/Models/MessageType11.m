//
//  MessageType11.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MessageType11.h"


@implementation MessageType11

- (id)init
{
	if(self = [super init])
	{
		TickDataParam = [[EquityTickParam alloc] init];
	}
	return self;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	TickDataParam->securityNO = commodity;
	int offset = 0;
	[MessageType11 decodeType11:body TickParam:TickDataParam Offset:&offset];
	//傳送在這邊~~~~~!!
	NSArray *tickArray = [[NSArray alloc] initWithObjects:TickDataParam, nil];
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.portfolioTickBank performSelector:@selector(addPromptTick:) onThread:dataModal.thread withObject:tickArray waitUntilDone:NO];
	
}

+ (void) decodeType11:(UInt8*)body TickParam:(EquityTickParam*)tickParam Offset:(int*)off
{
	int tmpOffset,offset, has_vol;
	tmpOffset = offset = *off;
	UInt8 *tmpPtr = body;
	PriceFormatData tmpPrice;
	TAvalueFormatData tmpTA;
	double tmpVal;
	tickParam->etick.status = 0;
	tickParam->etick.bid = 0;
	tickParam->etick.ask = 0;
	tickParam->etick.tick.time = [CodingUtil getTimeFormat2Value:tmpPtr Offset:&offset];
	tickParam->sequence = [CodingUtil getTickSNValue:body Offset:&offset];
	tmpOffset = offset;

	tmpVal = [CodingUtil getPriceFormatValue:body Offset:&offset TAstruct:&tmpPrice];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->etick.tick.price Offset:0]; 
	tmpOffset = offset;
	
	has_vol = [CodingUtil getUint8FromBuf:body Offset:offset++ Bits:1];   //若1, 有以下之成交量欄位; 0則否 
	if (has_vol)
	{
		tickParam->volumeType = [CodingUtil getUint8FromBuf:body Offset:offset++ Bits:1];
		tmpOffset = offset;

		tmpVal = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->etick.tick.volume Offset:0]; 
	}
	else
	{
		tickParam->volumeType = 0;
		tickParam->etick.tick.volume = 0;
	}
	
	*off = offset;
}

@end
