//
//  EsmPriceIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/19.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "EsmPriceIn.h"
#import "MessageType19.h"

@implementation EsmPriceIn

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
	dataLength = *body++;
	esmPriceParam = [[EsmPriceParam alloc] initWithBuffer:body Offset:&offset Size:&objSize Commodity:commodity];
	
	//傳送在這
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.esmData performSelector:@selector(decodeArrive:) onThread:dataModal.thread withObject:esmPriceParam waitUntilDone:NO];	
}


@end
