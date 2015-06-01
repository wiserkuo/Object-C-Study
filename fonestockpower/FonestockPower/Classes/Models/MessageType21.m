//
//  MessageType21.m
//  Bullseye
//
//  Created by Yehsam on 2009/11/2.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "MessageType21.h"

@implementation MessageType21

@synthesize apParam;

- (id)init
{
	if(self = [super init])
	{
		apParam = [[AlertPushParam alloc] init];
	}
	return self;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	
	int offset = 0;
	retCode = retcode;
	apParam->securityNum = [CodingUtil getUInt32:tmpPtr];
	tmpPtr += 4;
	apParam->tickTime = [CodingUtil getTimeFormat2Value:tmpPtr Offset:&offset];

	TAvalueFormatData tmpTA;
	apParam->dealValue = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
	apParam->dealValueUnit = tmpTA.magnitude;
	apParam->dealVolume = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
	apParam->dealVolumeUnit = tmpTA.magnitude;
	apParam->alertIDCount = [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:8];
	tmpPtr++;
	if(apParam->alertIDCount)
	{
		apParam->alertID = malloc(apParam->alertIDCount);
		apParam->alertType = malloc(apParam->alertIDCount);
	}
	for(int i=0 ; i<apParam->alertIDCount ; i++)
	{
		apParam->alertID[i] = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		apParam->alertType[i] = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
	}
//neil
//	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//	[dataModal.alert performSelector:@selector(alertPushMessage:) onThread:dataModal.thread withObject:self waitUntilDone:NO];	

}



@end


@implementation AlertPushParam

- (void)dealloc
{
	if(alertID) free(alertID);
	if(alertType) free(alertType);
}

@end

