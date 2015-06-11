//
//  InvesterHoldIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/1/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InvesterHoldIn.h"
#import "CodingUtil.h"


@implementation InvesterHoldIn

@synthesize investerArray;

- (id)init
{
	if(self = [super init])
	{
        investerArray = [[NSMutableArray alloc]init];
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
//	[investerArray addObject:[NSNumber numberWithBool:YES]];
    BOOL flag = YES;
	for(int i=0 ; i<count ; i++)
	{
		TAvalueFormatData tmpTA;
		InvesterHoldData *investerHoldData = [[InvesterHoldData alloc] init];
		investerHoldData->IIG_ID = IIG_ID;
        
		investerHoldData->date = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
		offset += 16;
		investerHoldData->ownShares = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		investerHoldData->ownSharesUnit = tmpTA.magnitude;
		investerHoldData->ownRatio = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		investerHoldData->ownRatioUnit = tmpTA.magnitude;
        if(flag){
            percent = investerHoldData->ownRatio;
            flag = NO;
        }
		[investerArray addObject:investerHoldData];
	}
	commodityNum = commodity;

	
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    
    if(IIG_ID == 1){
        if ([model.investerHold respondsToSelector:@selector(InvesterDataCallBack1:)]) {
        
            [model.investerHold performSelector:@selector(InvesterDataCallBack1:) onThread:model.thread withObject:self waitUntilDone:NO];
        }
    }else if(IIG_ID == 2){
        if ([model.investerHold respondsToSelector:@selector(InvesterDataCallBack2:)]) {
            
            [model.investerHold performSelector:@selector(InvesterDataCallBack2:) onThread:model.thread withObject:self waitUntilDone:NO];
        }
    }else if(IIG_ID == 3){
        if ([model.investerHold respondsToSelector:@selector(InvesterDataCallBack3:)]) {
            
            [model.investerHold performSelector:@selector(InvesterDataCallBack3:) onThread:model.thread withObject:self waitUntilDone:NO];
        }
    }
}


@end

@implementation InvesterHoldData


- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}


@end

