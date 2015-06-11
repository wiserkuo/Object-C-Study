//
//  FutrueOptionTargetPriceIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/2/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FutrueOptionTargetPriceIn.h"
#import "CodingUtil.h"


@implementation FutrueOptionTargetPriceIn

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	checkType = [CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:1];
	int offset = 1;
	if(checkType)
	{
		PriceFormatData tmpPrice;
		targetPriceTime = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:11];
		offset += 11;
		targetPrice = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		targetPriceUnit = tmpPrice.type;
		PriceFormatData tmpPrice2;
		targetRefPrice = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice2];
	}
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.option performSelector:@selector(targetPriceArrive:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end
