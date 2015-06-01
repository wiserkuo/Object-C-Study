//
//  BoardMemberHoldingIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "BoardMemberHoldingIn.h"
#import "FSDataModelProc.h"
@implementation BoardMemberHoldingIn
- (id)init
{
	if(self = [super init])
	{
		holdDataArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    
	returnCode = retcode;
	commodityNum = commodity;
	dataCount = [CodingUtil getUInt8:&body needOffset:YES];
	modifiedDate = [CodingUtil getUInt16:&body needOffset:YES];
    if(modifiedDate==0){
        return;
    }
	if(dataCount)
	{
		dataDate = [CodingUtil getUInt16:&body needOffset:YES];
		int offset = 0;
		for(int i=0 ; i<dataCount ; i++)
		{
			BoardMemberHoldingObject *bmParam = [[BoardMemberHoldingObject alloc] init];
            
            bmParam->holderName = [CodingUtil getShortStringFormatByBuffer:body bitOffset:&offset];
            
			bmParam->holderTitle = [CodingUtil getShortStringFormatByBuffer:body bitOffset:&offset];
            
            TAvalueFormatData tmpTA;
            
			bmParam->holderShare = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
			bmParam->holderShareUnit = tmpTA.magnitude;
            
			bmParam->holderShareRatio = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
			bmParam->holderShareRatioUnit = tmpTA.magnitude;
			
			[holdDataArray addObject:bmParam];
			
			body += offset/8;
			offset %= 8;
		}
	}
    
	
	FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if ([model.boardMemberHolding respondsToSelector:@selector(BoardMemberHoldingDataCallBack:)]) {
        
        [model.boardMemberHolding performSelector:@selector(BoardMemberHoldingDataCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
}

@end

@implementation BoardMemberHoldingObject
@end

