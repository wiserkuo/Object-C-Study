//
//  MessageType06.m
//  Bullseye
//
//  Created by Yehsam on 2009/2/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MessageType06.h"
#import "Portfolio.h"

@implementation MessageType06

- (id)init
{
	if(self = [super init])
	{
		messageType06Param = [[MessageType06Param alloc] init];
	}
	return self;
}

+ (void) decodeType06:(UInt8*)body messageType06Param:(MessageType06Param*)mtParam Commodity:(UInt32)sn
{
	UInt8 *tmpPtr = body;
	int tmpOffset=0,offset=0;
	double tmpVal;
	TAvalueFormatData tmpTA;
	PriceFormatData tmpPrice;
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	PortfolioItem *portfolioItem;
	portfolioItem = [dataModal.portfolioData getItem:sn];
	if(portfolioItem == nil) return ;
	
	mtParam->commodityNo = sn;
	tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&mtParam->referencePrice Offset:0]; 
	tmpOffset = offset;
	
	tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&mtParam->ceilingPrice Offset:0]; 
	tmpOffset = offset;
	
	tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&mtParam->floorPrice Offset:0]; 
	tmpOffset = offset;
	
	tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
	[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&mtParam->preVolume Offset:0];
	tmpOffset = offset;
	
	mtParam->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
	offset += 16;
	tmpOffset = offset;
	if(portfolioItem->type_id == 2 || portfolioItem->type_id == 4 || portfolioItem->type_id == 5)
	{
		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&mtParam->preOpenInterest Offset:0];
		tmpOffset = offset;
	}
	/*if(portfolioItem->type_id == 2)  //未用到!!??
	{
		tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&mtParam->strikePrice Offset:0]; 
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&mtParam->conversionRate Offset:0];
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&mtParam->totalVolume Offset:0];
		tmpOffset = offset;
	}*/
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	[MessageType06 decodeType06:body messageType06Param:messageType06Param Commodity:commodity];
	
	NSLog(@"MessageType06 decode");
	
	//傳送在這~~
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.portfolioTickBank performSelector:@selector(addClearSnapshot:) onThread:dataModal.thread withObject:messageType06Param waitUntilDone:NO];

}

@end


@implementation MessageType06Param

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

@end
