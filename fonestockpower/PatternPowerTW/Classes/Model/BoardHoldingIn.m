//
//  BoardHoldingIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "BoardHoldingIn.h"

@implementation BoardHoldingIn
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
    dataType = [CodingUtil getUInt8:&body needOffset:YES];
	dataCount = [CodingUtil getUInt8:&body needOffset:YES];
    if(dataCount==0){
        return;
    }
    int offset = 0;
    
    TAvalueFormatData tmpTA;
    for(int i=0; i<dataCount; i++){
        BoardHoldingObject *board = [[BoardHoldingObject alloc] init];
        if(dataType == 'H'){
            board->recordDate = [CodingUtil getUint16FromBuf:body Offset:offset Bits:16];
            offset += 16;
            board->holdRatio = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
            board->offsetRatio = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
        }else if(dataType == 'P'){
            board->recordDate = [CodingUtil getUint16FromBuf:body Offset:offset Bits:16];
            offset += 16;
            board->pledgeVolume = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
            board->pledgeRatio = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
        }
        
        [dataArray addObject:board];
    }
    

	FSDataModelProc *model = [FSDataModelProc sharedInstance];
    
    if(dataType == 'H'){
        if ([model.boardHolding respondsToSelector:@selector(HDataCallBack:)]) {
            
            [model.boardHolding performSelector:@selector(HDataCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
        }
    }else if(dataType == 'P'){
        if ([model.boardHolding respondsToSelector:@selector(PDataCallBack:)]) {
            
            [model.boardHolding performSelector:@selector(PDataCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
        }
    }
    
    
}

@end
@implementation BoardHoldingObject
@end
