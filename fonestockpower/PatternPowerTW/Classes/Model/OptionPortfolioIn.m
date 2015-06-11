//
//  OptionPortfolioIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/2/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OptionPortfolioIn.h"
#import "CodingUtil.h"


@implementation OptionPortfolioIn

@synthesize optionPortfolioArray;

- (id)init
{
	if (self = [super init])
	{
		optionPortfolioArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	int count = *tmpPtr++;
	for(int i=0 ; i<count ; i++)
	{
		OptionPortfolioParam *opParam = [[OptionPortfolioParam alloc] init];
		opParam->marketID = *tmpPtr++;
		opParam->identCode[0] = *tmpPtr++;
		opParam->identCode[1] = *tmpPtr++;
		int stringSize = *tmpPtr++;
		NSString *tmpString = [[NSString alloc] initWithBytes:tmpPtr length:stringSize encoding:NSASCIIStringEncoding];
		opParam.symbol = tmpString;
		tmpPtr += stringSize;
		opParam->year = (*tmpPtr++) + 1960;
		opParam->month = *tmpPtr++;
		opParam->callPut = *tmpPtr++;
		opParam->targetSecurityNum = [CodingUtil getUInt32:tmpPtr];
		tmpPtr += 4;
		int strikeCount = *tmpPtr++;
		for(int j=0 ; j<strikeCount ; j++)
		{
			StrikePriceParam *spParam = [[StrikePriceParam alloc] init];
			spParam->exponent = *tmpPtr++;
			spParam->strikePrice = [CodingUtil getUInt32:tmpPtr];
			tmpPtr += 4;
			spParam->sn = [CodingUtil getUInt32:tmpPtr];
			tmpPtr += 4;
			[opParam.strikePriceArray addObject:spParam];
		}
		
		[optionPortfolioArray addObject:opParam];
	}
	
	//傳送在這～～～
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.option performSelector:@selector(optionPortfolioArrive:) onThread:dataModal.thread withObject:optionPortfolioArray waitUntilDone:NO];
}

@end


@implementation OptionPortfolioParam

@synthesize symbol;
@synthesize strikePriceArray;

- (id)init
{
	if (self = [super init])
	{
		strikePriceArray = [[NSMutableArray alloc] init];
	}
	return self;
}

@end


@implementation StrikePriceParam

- (id)init
{
	if (self = [super init])
	{
	}
	return self;
}

@end

