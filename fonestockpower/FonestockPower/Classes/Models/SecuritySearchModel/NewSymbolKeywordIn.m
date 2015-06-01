//
//  NewSymbolKeywordIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/11/6.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "NewSymbolKeywordIn.h"
#import "SecuritySearchModel.h"

@implementation NewSymbolKeywordIn

@synthesize keyword;
@synthesize dataArray;

- (id)init
{
	if(self = [super init])
	{
		dataArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	
	UInt8 *tmpPtr = body;
	fieldType = [CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:4];
	searchType = [CodingUtil getUint8FromBuf:tmpPtr Offset:4 Bits:4];
	tmpPtr++;
	lengthKeyword = *tmpPtr++;
	keyword = [[NSString alloc] initWithBytes:tmpPtr length:lengthKeyword encoding:NSUTF8StringEncoding];
	tmpPtr += lengthKeyword;
	numSymbol = *tmpPtr++;
	retCode = retcode;
	
	NSLog(@"NewSymbolKeywordIn count:%d retCode:%d",numSymbol,retCode);
	
	if(numSymbol)
	{
		for(int i=0 ; i<numSymbol ; i++)
		{
			NumberOfSymbol *NOS = [[NumberOfSymbol alloc] init];
			UInt16 tmpSize=0;
			NOS->data = [[SymbolFormat1 alloc] initWithBuff:tmpPtr objSize:&tmpSize Offset:0];
			tmpPtr += tmpSize;
			NOS->sectorID = [CodingUtil getUInt16:tmpPtr];
			tmpPtr += 2;
			[dataArray addObject:NOS];
		}
		flag = *tmpPtr++;
		if(flag)
			totalNumber = [CodingUtil getUInt16:tmpPtr];
	}
//	retCode = retcode;
	
//#if defined (BROKER_GOLDEN_GATE)	
//	if(retCode==0)
//#endif		
	{
		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
		[dataModal.securitySearchModel performSelector:@selector(searchAgain:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
	
	}
}


@end

@implementation NumberOfSymbol


- (id)init
{
	if(self = [super init])
	{
		data = nil;
	}
	return self;
}


@end
