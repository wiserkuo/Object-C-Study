//
//  NewsSNIn.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NewsSNIn.h"
#import "CodingUtil.h"


@implementation NewsSNIn

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
	retCode = retcode;
	newsSectorID = [CodingUtil getUInt16:body];
	body+=2;
	year = [CodingUtil getUint8FromBuf:body Offset:0 Bits:7] + 1960;
	month = [CodingUtil getUint8FromBuf:body Offset:7 Bits:4];
	day = [CodingUtil getUint8FromBuf:body Offset:11 Bits:5];
	body+=2;
	count = *body++;
	sectorID = malloc((count*sizeof(UInt16)));
	SN = malloc((count*sizeof(UInt16)));
	for(int i=0 ; i<count ; i++)
	{
		sectorID[i] = [CodingUtil getUInt16:body];
		body+=2;
		SN[i] = [CodingUtil getUInt16:body];
		body+=2;
	}
	body = tmpPtr;
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.newsData performSelector:@selector(addWithSNIn:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end
