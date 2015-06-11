//
//  NewsTitleIn.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NewsTitleIn.h"
#import "CodingUtil.h"
#import "mime.h"

@implementation NewsTitleIn

@synthesize mimeArray;

- (id)init
{
	if(self = [super init])
	{
		mimeArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr;
	tmpPtr = body;
	date = [CodingUtil getUInt16:body];
	year = [CodingUtil getUint8FromBuf:body Offset:0 Bits:7]+1960;
	month = [CodingUtil getUint8FromBuf:body Offset:7 Bits:4];
	day = [CodingUtil getUint8FromBuf:body Offset:11 Bits:5];
	body+=2;	
	sectorID = [CodingUtil getUInt16:body];
	body+=2;
	count = [CodingUtil getUInt16:body];
	body+=2;
	retCode = retcode;
	for(int i=0 ; i<count ; i++)
	{
		NewsContentFormat1 *new;
		new = [[NewsContentFormat1 alloc] init];
		new->SN = [CodingUtil getUInt16:body];
		body+=2;
		new->newsSN = [CodingUtil getUInt32:body];
		body+=4;
		new->time = [CodingUtil getUint16FromBuf:body Offset:0 Bits:11];
		new->type = [CodingUtil getUint16FromBuf:body Offset:11 Bits:2];
		new->contentFlag = [CodingUtil getUint16FromBuf:body Offset:13 Bits:1];
		new->reserved = [CodingUtil getUint16FromBuf:body Offset:14 Bits:2];
		body+=2;
		new->length = [CodingUtil getUInt16:body];
		body+=2;
		UInt16 mimeLength = new->length;
		new->mimeData = (UInt8*)UnpackMimeText((const char*)body , &mimeLength);   
		new->mimeString = [[NSString alloc] initWithBytes:new->mimeData length:mimeLength encoding:NSUTF8StringEncoding];
		body+=new->length;
		[mimeArray addObject:new];
	}
	body = tmpPtr;
	
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.newsData performSelector:@selector(addWithTitle:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}


@end

@implementation NewsContentFormat1

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}



@end
