//
//  MessageType12.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MessageType12.h"


@implementation MessageType12

- (id)init
{
	if(self = [super init])
	{
		TickDataParam = [[IndexTickParam alloc] init];
	}
	return self;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	int offset=0;
	
	TickDataParam->securityNO = commodity;
	
	[MessageType12 decodeType12:body TickParam:TickDataParam Offset:&offset];
	
	NSArray *dataArray = [[NSArray alloc] initWithObjects:TickDataParam, nil];
	
	//傳送在這邊!!
	// Send to Data Modal.
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.portfolioTickBank performSelector:@selector(addPromptTick:) onThread:dataModal.thread withObject:dataArray waitUntilDone:NO];
	
}

+ (void) decodeType12:(UInt8*)body TickParam:(IndexTickParam*)tickParam Offset:(int*)off
{
	int tmpOffset,offset;
	tmpOffset = offset = *off;
	UInt8 *tmpPtr = body;
	TAvalueFormatData tmpTA;
	double tmpVal;
	PriceFormatData tmpPrice;
	tickParam->itick.tick.time = [CodingUtil getTimeFormat2Value:tmpPtr Offset:&offset];
	tickParam->sequence = [CodingUtil getTickSNValue:body Offset:&offset];
	tmpOffset = offset;

	tmpVal = [CodingUtil getPriceFormatValue:body Offset:&offset TAstruct:&tmpPrice];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->itick.tick.price Offset:0]; 
	tmpOffset = offset;

	tickParam->volumeType = [CodingUtil getUint8FromBuf:body Offset:offset++ Bits:1];
	tmpOffset++;

	tmpVal = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->itick.dealvolume Offset:0]; 
	tmpOffset = offset;
	
	tmpVal = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->itick.dealValue Offset:0]; 
	tmpOffset = offset;
	
	tmpVal = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->itick.dealCount Offset:0]; 
	tmpOffset = offset;
	
	tmpVal = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->itick.bidCount Offset:0]; 
	tmpOffset = offset;
	
	tmpVal = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->itick.askCount Offset:0]; 
	tmpOffset = offset;

	tmpVal = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->itick.bidVolume Offset:0]; 
	tmpOffset = offset;
	
	tmpVal = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->itick.askVolume Offset:0]; 
	tmpOffset = offset;
	
	tickParam->itick.upNo = [CodingUtil getUint16FromBuf:body Offset:offset Bits:16];
	tmpOffset+=16;
	
	tickParam->itick.downNo = [CodingUtil getUint16FromBuf:body Offset:offset Bits:16];
	tmpOffset+=16;
	
	tickParam->itick.unchangedNo = [CodingUtil getUint16FromBuf:body Offset:offset Bits:16];
	*off = offset;
	
	tickParam->itick.tick.volume = tickParam->itick.dealvolume;
}

@end
