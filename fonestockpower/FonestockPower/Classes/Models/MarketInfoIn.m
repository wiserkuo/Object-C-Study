//
//  MarketInfoIn.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MarketInfoIn.h"
#import "MarketInfo.h"

@implementation MarketInfoIn

@synthesize marketAdd;
@synthesize marketRemove;

- (id)init
{
	if (self = [super init])
	{
		marketAdd = [[NSMutableArray alloc] init];
		marketRemove = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	year = [CodingUtil getUint8FromBuf:body Offset:0 Bits:7]+1960;
	month = [CodingUtil getUint8FromBuf:body Offset:7 Bits:4];
	day = [CodingUtil getUint8FromBuf:body Offset:11 Bits:5];
	MITdate = [CodingUtil getUInt16:body];
	body+=2;
	retCode = retcode;

	addCount = *body++;
	for(int i=0 ; i<addCount ; i++)
	{
		addMarket *add = [[addMarket alloc] init];
		add->MarketID = *body++;
		add->MarketInfoSize = *body++;
		add->MarketName = [[NSString alloc] initWithBytes:body length:add->MarketInfoSize encoding:NSUTF8StringEncoding];
		body+= add->MarketInfoSize;
		add->CountryCode[0] = *body++;
		add->CountryCode[1] = *body++;
		add->start_time1 = [CodingUtil getUInt16:body];
		body+=2;
		add->end_time1 = [CodingUtil getUInt16:body];
		body+=2;
		add->start_time2 = [CodingUtil getUInt16:body];
		body+=2;
		add->end_time2 = [CodingUtil getUInt16:body];
		body+=2;
		[marketAdd addObject:add];
	}
	for(int i=0 ; i<removeCount ; i++)
	{
		removeMarket *remove = [[removeMarket alloc] init];
		remove->MarketID = *body++;
		[marketRemove addObject:remove];
	}

	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.marketInfo performSelector:@selector(addMarketInfo:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
	
	body = tmpPtr;
	//not used
}

@end


@implementation addMarket

- (id)init
{
	if(self = [super init])
	{
		CountryCode = malloc(2);
	}
	return self;
}

- (void)dealloc
{
	free(CountryCode);
}

@end

@implementation removeMarket

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}


@end



