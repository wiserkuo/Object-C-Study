//
//  NewRevenueIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/26.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "NewRevenueIn.h"

@implementation NewRevenueIn
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
	dataType = [CodingUtil getUInt8:&body needOffset:YES];
    dataCount = [CodingUtil getUInt8:&body needOffset:YES];
    
    int bitOffset = 0;
    for(int i = 0; i < dataCount ; i++){
        RevenueObject *object = [[RevenueObject alloc] init];
        object->date = [CodingUtil getUint16FromBuf:body Offset:bitOffset Bits:16];
        bitOffset += 16;
        TAvalueFormatData tmpTA;
        object->revenue = [CodingUtil getTAvalue:body Offset:&bitOffset TAstruct:&tmpTA];
        object->revenueUnit = tmpTA.magnitude;
        
        object->accumulatedRevenue = [CodingUtil getTAvalue:body Offset:&bitOffset TAstruct:&tmpTA];
        object->accumulatedRevenueUnit = tmpTA.magnitude;
        
        object->accumulatedAchieveRate = [CodingUtil getTAvalue:body Offset:&bitOffset TAstruct:&tmpTA];
        object->accumulatedAchieveRateUnit = tmpTA.magnitude;
        
        object->mergedRevenue = [CodingUtil getTAvalue:body Offset:&bitOffset TAstruct:&tmpTA];
        object->mergedRevenueUnit = tmpTA.magnitude;
        
        object->accumulatedMergedRevenue = [CodingUtil getTAvalue:body Offset:&bitOffset TAstruct:&tmpTA];
        object->accumulatedMergedRevenueUnit = tmpTA.magnitude;
        
        [dataArray addObject:object];
    }
    
//    //送出在這~~
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.nRevenue performSelector:@selector(NewRevenueDataCallBack:) onThread:dataModal.thread withObject:self waitUntilDone:NO];

    
}
@end

@implementation RevenueObject

@end
