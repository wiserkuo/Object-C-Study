//
//  BADataIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/2/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BADataIn.h"
#import "MessageType03.h"

@implementation BADataIn

@synthesize BAArray;
@synthesize securityNO;

- (id)init
{
	if(self = [super init])
	{
		BAArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	securityNO = commodity;
	if (*body == 0) return;
	body++;
	[MessageType03 decodeType03:body Array:BAArray];
	//傳送在這~~ 傳BAArray
    //neil
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	BOOL flag = [dataModal.option checkFocusSN:commodity];	//判斷是否為Option的
	if(flag)
		[dataModal.option performSelector:@selector(BAArrive:) onThread:dataModal.thread withObject:BAArray waitUntilDone:NO];
	else
		[dataModal.portfolioTickBank performSelector:@selector(addNearestBidAsk:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

@end


@implementation BADataParam

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

@end

