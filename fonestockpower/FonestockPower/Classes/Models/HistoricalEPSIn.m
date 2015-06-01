//
//  HistoricalEPSIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HistoricalEPSIn.h"


@implementation HistoricalEPSIn

@synthesize historicalEPSArray;

- (id)init
{
	if(self = [super init])
	{
		historicalEPSArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	UInt8 epsType = [CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:1];
	UInt8 count = [CodingUtil getUint8FromBuf:tmpPtr Offset:1 Bits:7];
	tmpPtr++;
	int offset=0;
	retCode = retcode;
	for(int i=0 ; i<count ; i++)
	{
		HistoricalEPSParam *historicalEPSParam = [[HistoricalEPSParam alloc] init];
		historicalEPSParam->epsType = epsType;
		historicalEPSParam->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
		offset += 16;
		TAvalueFormatData tmpTA;
		historicalEPSParam->epsValue = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		historicalEPSParam->epsValueUnit = tmpTA.magnitude;
		
		[historicalEPSArray addObject:historicalEPSParam];
	}
	commodityNum = commodity;
	//送出在這~~
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    if(epsType == 0){
        [dataModal.historicalEPS performSelector:@selector(decodeArrive:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
    }else{
        [dataModal.stockHolderMeeting performSelector:@selector(HistoricalEPSCallBack:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
    }
	
}


@end

@implementation HistoricalEPSParam

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}


@end