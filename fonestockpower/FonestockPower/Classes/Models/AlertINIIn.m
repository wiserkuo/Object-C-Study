//
//  AlertINIIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/11/18.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "AlertINIIn.h"

@implementation AlertINIIn

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	returnCode = retcode;
	date = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	sn = *tmpPtr++;
	totalSN = *tmpPtr++;
	dataLength = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	if(dataLength)
	{
		data = malloc(dataLength * sizeof(UInt8));
		for(int i=0 ; i<dataLength ; i++)
			data[i] = *tmpPtr++;
	}
    
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.alert performSelector:@selector(xmlDataIn:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
}

- (void)dealloc
{
	if(data) free(data);
}

@end
