//
//  BoardMemberTransferIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "BoardMemberTransferIn.h"
#import "FSDataModelProc.h"
@implementation BoardMemberTransferIn
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
    
    
    for(int i=0 ; i<dataCount ; i++){
        
        int offset = 0;
        length = [CodingUtil getUint8FromBuf:body Offset:offset Bits:8];
        offset += 8;
        BoardMemberTransferObject *bmParam = [[BoardMemberTransferObject alloc] init];
        
        bmParam->dataDate = [CodingUtil getUint16FromBuf:body Offset:offset Bits:16];
        offset += 16;
        bmParam->holderName = [CodingUtil getShortStringFormatByBuffer:body bitOffset:&offset];
        bmParam->holderTitle = [CodingUtil getShortStringFormatByBuffer:body bitOffset:&offset];
            
        TAvalueFormatData tmpTA;
            
        bmParam->applyShare = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
        bmParam->applyPrice = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
            
        bmParam->orgShare = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
        bmParam->untransferDate = [CodingUtil getUint16FromBuf:body Offset:offset Bits:16];
        offset +=16;
        bmParam->actualTransfer = [CodingUtil getTAvalueFormatValue:body Offset:&offset TAstruct:&tmpTA];
        bmParam->transferMethod = [CodingUtil getShortStringFormatByBuffer:body bitOffset:&offset];
        [holdDataArray addObject:bmParam];
			
        body +=length+1;
        
    }
    

    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    if ([model.boardMemberTransfer respondsToSelector:@selector(BoardMemberTransferDataCallBack:)]) {
        
        [model.boardMemberTransfer performSelector:@selector(BoardMemberTransferDataCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
}

@end

@implementation BoardMemberTransferObject
@end

