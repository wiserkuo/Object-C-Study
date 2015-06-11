//
//  FSMainBargainingChipOut.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMainBargainingChipOut.h"
#import "OutPacket.h"

@implementation FSMainBargainingChipOut

-(id)initWithDays:(UInt8)d SortType:(UInt8)st{
    
    if (self = [super init]) {
        days = d;
        sortType = st;
    }
    return self;
}

-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{

    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead->escape = 0x1B;
    phead->message = 10;
    phead->command = 42;
    [CodingUtil setUInt16:(char*)&(phead->size) Value:len];
    tmpPtr+=sizeof(OutPacketHeader);
    
    //days
    [CodingUtil setUInt16:tmpPtr Value:days];
    tmpPtr += 2;
    
    //count
    *tmpPtr++ = 30;
    
    //sortType
    *tmpPtr++ = sortType;
    return YES;
}

-(int)getPacketSize{
    return 4;
}
@end


