//
//  MessageType09.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/7.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MessageType09.h"
#import "CodingUtil.h"
#import "NewsRelateIn.h"
#import "mime.h"

@implementation MessageType09

@synthesize newsContentFormat3;

- (id)init
{
	if(self = [super init])
	{
		newsContentFormat3 = [[NewsContentFormat3 alloc] init];
	}
	return self;
}

+ (int) decodeType09:(UInt8*)body NewsFormat3:(NewsContentFormat3*)newsFormat3
{
	newsFormat3->newsSN = [CodingUtil getUInt32:body];
	body+=4;
	newsFormat3->date = [CodingUtil getUInt16:body];
	body+=2;
	newsFormat3->time = [CodingUtil getUint16FromBuf:body Offset:0 Bits:11];
	newsFormat3->type = [CodingUtil getUint16FromBuf:body Offset:11 Bits:2];
	newsFormat3->contentFlag = [CodingUtil getUint16FromBuf:body Offset:13 Bits:1];
	newsFormat3->reserved = [CodingUtil getUint16FromBuf:body Offset:14 Bits:2];
	body+=2;
	newsFormat3->sectorID = [CodingUtil getUInt16:body];
	body+=2;
	newsFormat3->SN = [CodingUtil getUInt16:body];
	body+=2;
	newsFormat3->length = [CodingUtil getUInt16:body];
	body+=2;
	UInt16 mimeLength = newsFormat3->length;
	newsFormat3->mimeData = (UInt8*)UnpackMimeText((const char*)body , &mimeLength);   
	if(mimeLength)
		newsFormat3->mimeString = [[NSString alloc] initWithBytes:newsFormat3->mimeData length:mimeLength encoding:NSUTF8StringEncoding];
	body+=newsFormat3->length;
	return 14+newsFormat3->length;	//回傳長度
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	[MessageType09 decodeType09:body NewsFormat3:newsContentFormat3];
//	DataModalProc *dataModal = [DataModalProc getDataModal];
//	[dataModal.newsData performSelector:@selector(addWithRealTimeTitle:) onThread:dataModal.thread withObject:newsContentFormat3 waitUntilDone:NO];
}

@end
