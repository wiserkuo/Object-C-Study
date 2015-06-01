//
//  MessageType19.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/19.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "MessageType19.h"

@implementation MessageType19

@synthesize esmPriceParam;

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	int offset = 0;
	UInt16 objSize = 0;
	returnCode = retcode;
	esmPriceParam = [[EsmPriceParam alloc] initWithBuffer:body Offset:&offset Size:&objSize Commodity:commodity];
	
	//傳送在這
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.esmData performSelector:@selector(messageType19Arrive:) onThread:dataModal.thread withObject:esmPriceParam waitUntilDone:NO];	

}


@end



@implementation EsmPriceParam

@synthesize bidDataArray;
@synthesize askDataArray;

- (id)initWithBuffer:(UInt8*)tmpPtr Offset:(int*)offset Size:(UInt16*)size Commodity:(UInt32)commodity
{
	if(self = [super init])
	{
		bidDataArray = [[NSMutableArray alloc] init];
		askDataArray = [[NSMutableArray alloc] init];
		UInt8 *firstPtr = tmpPtr;
		int tmpOffset = *offset;
		PriceFormatData tmpPrice;
		TAvalueFormatData tmpTA;

		priceType = [CodingUtil getUint8FromBuf:tmpPtr Offset:tmpOffset Bits:2];
		tmpOffset += 2;
		bidBestPrice = [CodingUtil getPriceFormatValue:tmpPtr Offset:&tmpOffset TAstruct:&tmpPrice];
		EquitySnapshotDecompressed *snapshot = [[[FSDataModelProc sharedInstance]portfolioTickBank] getSnapshot:commodity];
		if(tmpPrice.type>2)
		{
			bidBestPrice += snapshot.referencePrice;
		}
		bidCounts = [CodingUtil getUint8FromBuf:tmpPtr Offset:tmpOffset Bits:3];
		tmpOffset += 3;
		for(int i=0 ; i<bidCounts ; i++)
		{
			EsmBidAskParam *baParam = [[EsmBidAskParam alloc] init];
			baParam->brokerID = [CodingUtil getUint16FromBuf:tmpPtr Offset:tmpOffset Bits:16];
			tmpPtr += 2;
			baParam->traderTelephoneID = [CodingUtil getUint16FromBuf:tmpPtr Offset:tmpOffset Bits:16];
			tmpPtr += 2;
			baParam->volume = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&tmpOffset TAstruct:&tmpTA];
			baParam->volumeUnit = tmpTA.magnitude;
			[bidDataArray addObject:baParam];
		}

		askBestPrice = [CodingUtil getPriceFormatValue:tmpPtr Offset:&tmpOffset TAstruct:&tmpPrice];
		if(tmpPrice.type>2)
		{
			askBestPrice += snapshot.referencePrice;
		}
		askCounts = [CodingUtil getUint8FromBuf:tmpPtr Offset:tmpOffset Bits:3];
		tmpOffset += 3;
		for(int i=0 ; i<askCounts ; i++)
		{
			EsmBidAskParam *baParam = [[EsmBidAskParam alloc] init];
			baParam->brokerID = [CodingUtil getUint16FromBuf:tmpPtr Offset:tmpOffset Bits:16];
			tmpPtr += 2;
			baParam->traderTelephoneID = [CodingUtil getUint16FromBuf:tmpPtr Offset:tmpOffset Bits:16];
			tmpPtr += 2;
			baParam->volume = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&tmpOffset TAstruct:&tmpTA];
			baParam->volumeUnit = tmpTA.magnitude;
			[askDataArray addObject:baParam];
		}
		
		*size += (tmpPtr - firstPtr);
	}
	return self;
}

@end



@implementation EsmBidAskParam

@end
