//
//  AlertSnapshotIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/11/2.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "AlertSnapshotIn.h"

@implementation AlertSnapshotIn

@synthesize alertSnapshotArray;

- (id)init
{
	if(self = [super init])
	{
		alertSnapshotArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;

	UInt16 allCount = [CodingUtil getUInt16:tmpPtr];
	tmpPtr += 2;
	int offset = 0;
	retCode = retcode;
	for(int i=0 ; i<allCount ; i++)
	{
		AlertSnapshotParam *asParam = [[AlertSnapshotParam alloc] init];
		
		asParam->securityNum = [CodingUtil getUint32FromBuf:tmpPtr Offset:offset Bits:32];
		tmpPtr += 4;
		asParam->tickTime = [CodingUtil getTimeFormat2Value:tmpPtr Offset:&offset];
		
		TAvalueFormatData tmpTA;
		asParam->dealValue = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		asParam->dealValueUnit = tmpTA.magnitude;
		asParam->dealVolume = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		asParam->dealVolumeUnit = tmpTA.magnitude;		
		
		asParam->alertBytesCount = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		if(asParam->alertBytesCount) asParam->alertBytes = malloc(asParam->alertBytesCount * sizeof(UInt8));
		for(int j=0 ; j<asParam->alertBytesCount ; j++)
			asParam->alertBytes[j] = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		
		[alertSnapshotArray addObject:asParam];
	}
	//neil
//	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//	[dataModal.alert performSelector:@selector(alertSnapshotArrive:) onThread:dataModal.thread withObject:self waitUntilDone:NO];

}

@end



@implementation AlertSnapshotParam

- (void)dealloc
{
	if(alertBytes) free(alertBytes);
}

@end
