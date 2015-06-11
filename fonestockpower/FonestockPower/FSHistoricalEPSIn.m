//
//  FSHistoricalEPSIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSHistoricalEPSIn.h"
#import "StockHolderMeeting.h"

@implementation FSHistoricalEPSIn
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
		NewHistoricalEPSParam *historicalEPSParam = [[NewHistoricalEPSParam alloc] init];
		historicalEPSParam->epsType = epsType;
		historicalEPSParam->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
		offset += 16;
		TAvalueFormatData tmpTA;
		historicalEPSParam->epsValue = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		historicalEPSParam->epsValueUnit = tmpTA.magnitude;
		
		[historicalEPSArray addObject:historicalEPSParam];
    }
    
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if ([model.stockHolderMeeting respondsToSelector:@selector(HistoricalEPSCallBack:)]) {
        
        [model.stockHolderMeeting performSelector:@selector(HistoricalEPSCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
}

@end

@implementation NewHistoricalEPSParam
@end

