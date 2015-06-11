//
//  FSBrokerBranchOut.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBrokerBranchOut.h"
#import "OutPacket.h"

@implementation FSBrokerBranchOut

-(id)initWithDate:(UInt16)d{
    
    if (self = [super init]) {

        date = d;
    }
    
    return self;
}

-(int)getPacketSize{
    
    return 2;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead->escape = 0x1B;
    phead->message = 10;
    phead->command = 39;
    [CodingUtil setUInt16:(char*)&(phead->size) Value:len];
    tmpPtr+=sizeof(OutPacketHeader);
    
    [CodingUtil setUInt16:tmpPtr Value:date];
    return YES;
}

@end


