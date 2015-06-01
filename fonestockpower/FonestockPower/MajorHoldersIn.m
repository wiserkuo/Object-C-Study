//
//  MajorHoldersIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "MajorHoldersIn.h"

@implementation MajorHoldersIn
- (id)init
{
	if(self = [super init])
	{
		dataArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    
	returnCode = retcode;
	commodityNum = commodity;
	dataCount = [CodingUtil getUInt8:&body needOffset:YES];
    if(dataCount==0){
        return;
    }
    recordDate = [CodingUtil getUInt16:&body needOffset:YES];
    int bitOffset = 0;
    for(int i=0 ; i<dataCount ; i++){
        MajorHoldersObject *major = [[MajorHoldersObject alloc] init];
        
        major->name = [CodingUtil getShortStringFormatByBuffer:body bitOffset:&bitOffset];
        TAvalueFormatData tmpTA;
        
        major->shareRate = [CodingUtil getTAvalueFormatValue:body Offset:&bitOffset TAstruct:&tmpTA];
        major->shareUnit = tmpTA.magnitude;
        [dataArray addObject:major];
    }
    
	FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if ([model.majorHolders respondsToSelector:@selector(MajorHoldersDataCallBack:)]) {
        
        [model.majorHolders performSelector:@selector(MajorHoldersDataCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }

}

@end
@implementation MajorHoldersObject
@end
