//
//  NewsRelateIn.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NewsRelateIn.h"
#import "MessageType09.h"
#import "CodingUtil.h"


@implementation NewsRelateIn

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
	count = *body++;
	commodityNo = commodity;
	retCode = retcode;
	if(count)
	{	
		for(int i=0 ; i<count ; i++)
		{
			NewsContentFormat3 *news = [[NewsContentFormat3 alloc] init];
			int len = [MessageType09 decodeType09:body NewsFormat3:news];
			body += len;
			[mimeArray addObject:news];
		}
	}
	flag = *body++;
	if(flag){
		totalNum = [CodingUtil getUInt16:body];
		body+=2;
	}
	body = tmpPtr;	
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.relatedNewsData performSelector:@selector(addWithTitle:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end

@implementation NewsContentFormat3
@end
