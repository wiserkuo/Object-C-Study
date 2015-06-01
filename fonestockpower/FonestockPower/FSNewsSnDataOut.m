//
//  FSNewsSnDataOut.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/8.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSNewsSnDataOut.h"
#import "OutPacket.h"

@implementation FSNewsSnDataOut

-(id)initWithSectorID:(UInt16)sID{

    if(self = [super init])
    {
        sectorID = sID;
        
    }
    return self;
}

- (int)getPacketSize{
    
    return 3;
}

-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len
{
    char *tmpPtr = buffer;

    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead -> escape = 0x1B;
    phead -> message = 3;
    phead -> command = 1;
    [CodingUtil setUInt16:(char *)&(phead -> size) Value:len];
    tmpPtr += sizeof(OutPacketHeader);
    
    *tmpPtr++ = 1;
    [CodingUtil setUInt16:&tmpPtr value:sectorID needOffset:YES];
    
    return YES;
}

@end

