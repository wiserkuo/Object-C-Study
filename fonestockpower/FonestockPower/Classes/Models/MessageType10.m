//
//  MessageType10.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MessageType10.h"


@implementation MessageType10

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
	[MessageType10 decodeType10:body TickParam:TickDataParam Offset:&offset];
	// Added by Steven
//	commodityNum = commodity;
//	DataModalProc *dataModal = [DataModalProc getDataModal];
//	[dataModal.tickData performSelector:@selector(addTick:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
	
	// Send to Data Modal.
//	NSArray *tickArray = [NSArray arrayWithObject:TickDataParam];	// This will be auto-released and cause this array to be released one more time.
	NSArray *tickArray = [[NSArray alloc] initWithObjects:TickDataParam,nil];
	//neil
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	BOOL flag = [dataModal.option checkSecurityNum:commodity];	//判斷是否為Option的
	if(flag)
		[dataModal.option performSelector:@selector(tickArrive:) onThread:dataModal.thread withObject:tickArray waitUntilDone:NO];
	else
		[dataModal.portfolioTickBank performSelector:@selector(addPromptTick:) onThread:dataModal.thread withObject:tickArray waitUntilDone:NO];
	
}

+ (void) decodeType10:(UInt8*)body TickParam:(EquityTickParam*)tickParam Offset:(int*)off;
{
	int tmpOffset,offset;
	tmpOffset = offset = *off;
	UInt8 *tmpPtr = body;
	tickParam->etick.tick.time = [CodingUtil getTimeFormat2Value:tmpPtr Offset:&offset];
	tmpOffset = offset;
	//status
	if([CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:1]){
		tickParam->etick.status = [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:3];
		offset+=3;
	}
	else{
		tickParam->etick.status = [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:1];
		offset+=1;		
	}
	// trade_data
	if(tickParam->etick.status<6) {   // bits:110 以下才做
		PriceFormatData tmpPrice;
		TAvalueFormatData tmpTA;
		double tmpVal;
		tickParam->sequence = [CodingUtil getTickSNValue:body Offset:&offset];
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getPriceFormatValue:body Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->etick.tick.price Offset:0]; 
		tmpOffset = offset;
		
		tickParam->volumeType = [CodingUtil getUint8FromBuf:body Offset:offset++ Bits:1];
		tmpOffset++;
		
		tmpVal = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->etick.tick.volume Offset:0]; 
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getPriceFormatValue:body Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->etick.bid Offset:0]; 
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getPriceFormatValue:body Offset:&offset TAstruct:&tmpPrice];				
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&tickParam->etick.ask Offset:0]; 
	}
	*off = offset;
}

@end
