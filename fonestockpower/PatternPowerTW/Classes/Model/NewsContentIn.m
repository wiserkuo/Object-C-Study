//
//  NewsContentIn.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NewsContentIn.h"
#import "CodingUtil.h"
#import "mime.h"


@implementation NewsContentIn

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
	type = *body++;
	retCode = retcode;
	if(type){ 
		date = [CodingUtil getUInt16:body];
		year = [CodingUtil getUint8FromBuf:body Offset:0 Bits:7]+1960;
		month = [CodingUtil getUint8FromBuf:body Offset:7 Bits:4];
		day = [CodingUtil getUint8FromBuf:body Offset:11 Bits:5];
		body+=2;	
		sectorID = [CodingUtil getUInt16:body];
		body+=2;
		SN = [CodingUtil getUInt16:body];
		body+=2;
		count = *body++;
		for(int i=0 ; i<count ; i++)
		{
			NewsContentFormat2 *news;
			news = [[NewsContentFormat2 alloc] init];
			news->length = [CodingUtil getUInt16:body];
			body+=2;
			UInt16 mimeLength = news->length;
			UInt8 *mimeData = (UInt8*)UnpackMimeText((const char*)body , &mimeLength); 
			news->mimeData = malloc(mimeLength);
			memcpy(news->mimeData, mimeData, mimeLength);
			news->mimeString = nil;
			//news->mimeString = [[NSString alloc] initWithBytes:news->mimeData length:mimeLength encoding:NSUTF8StringEncoding];
			body+=news->length;
			news->length = mimeLength;
			[mimeArray addObject:news];
		}
	}
	else{
		newsSN = [CodingUtil getUInt32:body];
		body+=4;
		count = *body++;
		for(int i=0 ; i<count ; i++)
		{
			NewsContentFormat2 *news;
			news = [[NewsContentFormat2 alloc] init];
			news->length = [CodingUtil getUInt16:body];
			body+=2;
			UInt16 mimeLength = news->length;
			UInt8 *mimeData = (UInt8*)UnpackMimeText((const char*)body , &mimeLength);  
			news->mimeData = malloc(mimeLength);
			memcpy(news->mimeData, mimeData, mimeLength);
			news->mimeString = nil;
			//news->mimeString = [[NSString alloc] initWithBytes:news->mimeData length:mimeLength encoding:NSUTF8StringEncoding];
			body+=news->length;
			news->length = mimeLength;
			[mimeArray addObject:news];
		}
	}
	body = tmpPtr;
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.newsData performSelector:@selector(addWithContent:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}


@end

@implementation NewsContentFormat2

- (id)init
{
	if(self = [super init])
	{
		mimeData = NULL;
	}
	return self;
}


@end
