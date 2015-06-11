//
//  InvesterBSIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InvesterBSIn.h"
#import "CodingUtil.h"


@implementation InvesterBSIn

@synthesize investerArray;

- (id)init
{
	if(self = [super init])
	{
		investerArray = [[NSMutableArray alloc]	init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	UInt8 IIG_ID = *tmpPtr++;
	int count = *tmpPtr++;
	int offset = 0;
	retCode = retcode;
//	[investerArray addObject:[NSNumber numberWithBool:NO]];
	for(int i=0 ; i<count ; i++)
	{
		TAvalueFormatData tmpTA;
		InvesterBSData *investerBSData = [[InvesterBSData alloc] init];
		investerBSData->IIG_ID = IIG_ID;
		investerBSData->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
		offset += 16;
		investerBSData->buyShares = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		investerBSData->buySharesUnit = tmpTA.magnitude;
		investerBSData->sellShares = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		investerBSData->sellSharesUnit = tmpTA.magnitude;
		investerBSData->buySell = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		investerBSData->buySellUnit = tmpTA.magnitude;
		
		[investerArray addObject:investerBSData];
	}
	commodityNum = commodity;
	//送出在這~~
	
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
	[dataModel.investerBS performSelector:@selector(decodeInvesterBSArrive:) onThread:dataModel.thread withObject:self waitUntilDone:NO];
}

@end


@implementation InvesterBSData

@end
