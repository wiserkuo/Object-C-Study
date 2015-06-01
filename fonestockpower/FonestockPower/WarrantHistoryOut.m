//
//  WarrantHistoryOut.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantHistoryOut.h"
#import "OutPacket.h"

@implementation WarrantHistoryOut
- (id)initWithSecuity_num:(UInt32)num queryType:(UInt8)type dataCount:(UInt16)dCount {
    if (self = [super init]) {
        securityNum = num;
        queryType = type;
        count = dCount;
    }
    return self;
}

- (int)getPacketSize {
    return sizeof(securityNum) + sizeof(queryType) + sizeof(count);
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len {
    char *tmpPtr = buffer;
    
    OutPacketHeaderRef phead = (OutPacketHeaderRef)tmpPtr;
    phead->escape = 0x1B;
    phead->message = 10;
    phead->command = 40;
    [CodingUtil setUInt16:(char*)&(phead->size) Value:len];
    tmpPtr += sizeof(OutPacketHeader);
    
    
    
    [CodingUtil setUInt32:&tmpPtr value:securityNum needOffset:YES];
    
    [CodingUtil setUInt8:&tmpPtr value:queryType needOffset:YES];
    
    if(queryType == 1){
        [CodingUtil setUInt16:&tmpPtr value:count needOffset:YES];
    }
    
    return YES;
}
@end
