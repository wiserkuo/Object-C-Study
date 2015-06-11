//
//  FSKPIOut.m
//  FonestockPower
//
//  Created by Derek on 2015/1/16.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSKPIOut.h"
#import "OutPacket.h"

@interface FSKPIOut()
{
    UInt8 sectorIDCount;
    UInt16 sectorID;
    UInt8 counts;
    UInt8 ids;
    UInt8 unitOfMatch	;
    UInt32 valueOfMatch	;
    UInt8 numbersOfHitFields;
    UInt8 maxReturnSecurityByPDA;
}
@end

@implementation FSKPIOut


-(int)getPacketSize{
    return 1;
}

-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead->escape = 0x1B;
    phead->message = 6;
    phead->command = 1;
    [CodingUtil setUInt16:(char*)&(phead->size) Value:len];
    tmpPtr+=sizeof(OutPacketHeader);
    
    
    *tmpPtr++ = 'T';
    *tmpPtr++ = 'W';
    
    [CodingUtil setUInt8:&tmpPtr value:sectorIDCount needOffset:YES];
    [CodingUtil setUInt16:&tmpPtr value:sectorID needOffset:YES];
    [CodingUtil setUInt8:&tmpPtr value:counts needOffset:YES];
    [CodingUtil setUInt8:&tmpPtr value:ids needOffset:YES];
    
//    [CodingUtil setUInt32:<#(char **)#> value:<#(UInt32)#> needOffset:<#(BOOL)#>];
    
    
    
    
    return YES;
}

@end
