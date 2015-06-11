//
//  MajorProductsIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "MajorProductsIn.h"
#import "MajorProducts.h"
@implementation MajorProductsIn
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
    int offset = 0;
    for(int i=0 ; i<dataCount ; i++){
        MajorProductsObject *major = [[MajorProductsObject alloc] init];

        major->productName = [CodingUtil getShortStringFormatByBuffer:body bitOffset:&offset];
        TAvalueFormatData tmpTA;
        
        major->revRate = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
        major->revUnit = tmpTA.magnitude;
        [dataArray addObject:major];
        }
    
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if ([model.majorProducts respondsToSelector:@selector(MajorProductsDataCallBack:)]) {
        
        [model.majorProducts performSelector:@selector(MajorProductsDataCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
}

@end
@implementation MajorProductsObject
@end
