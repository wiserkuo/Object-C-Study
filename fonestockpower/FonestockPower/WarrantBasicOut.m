//
//  WarrantBasicOut.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantBasicOut.h"
#import "OutPacket.h"

@implementation WarrantBasicOut
- (id)initWithSecuity_num:(UInt32)num blockMask:(UInt16)mask {
    if (self = [super init]) {
        securityNum = num;
        blackMask = mask;
    }
    return self;
}

- (int)getPacketSize {
    return sizeof(securityNum) + sizeof(blackMask);
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len {
    char *tmpPtr = buffer;
    
    OutPacketHeaderRef phead = (OutPacketHeaderRef)tmpPtr;
    phead->escape = 0x1B;
    phead->message = 10;
    phead->command = 41;
    [CodingUtil setUInt16:(char*)&(phead->size) Value:len];
    tmpPtr += sizeof(OutPacketHeader);
    
    
    
    [CodingUtil setUInt32:&tmpPtr value:securityNum needOffset:YES];
    [CodingUtil setUInt16:&tmpPtr value:blackMask needOffset:YES];
    
    return YES;
}

@end
