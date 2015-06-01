//
//  PortfolioIn.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/25.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PortfolioIn.h"
#import "Portfolio.h"

@implementation PortfolioIn

@synthesize Block1dataArray;
@synthesize Block2dataArray;

- (id)init
{
	if(self = [super init])
	{
		Block1dataArray = [[NSMutableArray alloc] init];
		Block2dataArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	subType = *tmpPtr++;
	block1Count = *tmpPtr++;
	returnCode = retcode;
	for(int i=0 ; i<block1Count ; i++)
	{
		Block1 *b1 = [[Block1 alloc] init];
		b1->marketID = *tmpPtr++;
		b1->Ident_Code[0] = *tmpPtr++;
		b1->Ident_Code[1] = *tmpPtr++;
		b1->symbolLength = *tmpPtr++;
		b1->symbol = [[NSString alloc] initWithBytes:tmpPtr length:b1->symbolLength encoding:NSUTF8StringEncoding];
		tmpPtr += b1->symbolLength;
		b1->sercurity1Num = [CodingUtil getUInt32:tmpPtr];
		tmpPtr += 4;
		[Block1dataArray addObject:b1];
	}

	// Added by Steven.
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.portfolioData performSelector:@selector(setCommodityNo:) onThread:dataModal.thread withObject:self waitUntilDone:NO];

	//Block2 not used now!!
/*	block2Count = *tmpPtr++;
	for(int i=0 ; i<block2Count ; i++)
	{
		Block2 *b2 = [[Block2 alloc] init];;
		b2->sercurity2Num = [CodingUtil getUInt32:tmpPtr];
		tmpPtr+=4;
		b2->TargetNum = [CodingUtil getUInt32:tmpPtr];
		tmpPtr+=4;
		[Block2dataArray addObject:b2];
		[b2 release];
	}*/
	
	
}

@end


@implementation Block1

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}
@end

@implementation Block2

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}


@end
