//
//  FSNewsTitleDataOut.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/8.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSNewsTitleDataOut.h"
#import "OutPacket.h"

@implementation FSNewsTitleDataOut

-(id)initWithSectorID:(UInt16)s beginSN:(UInt16)bSN endSN:(UInt16)eSN{
    
    if(self = [super init])
    {
        sectorID = s;
        beginSN = bSN;
        endSN = eSN;
        
    }
    return self;
}

-(id)initWithSectorID:(UInt16)s beginSN:(UInt16)bSN{
    
    if(self = [super init])
    {
        sectorID = s;
        beginSN = bSN;
        
    }
    return self;
}

-(int)getPacketSize{
    if (beginSN == 0) {
        return 4;
    }else{
        return 6;
    }
}

-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{

    char *tmpPtr = buffer;
    
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead -> escape = 0x1B;
    phead -> message = 3;
    phead -> command = 2;
    [CodingUtil setUInt16:(char *)&(phead -> size) Value:len];
    tmpPtr += sizeof(OutPacketHeader);
    
    [CodingUtil setUInt16:&tmpPtr value:sectorID needOffset:YES];
    [CodingUtil setUInt16:&tmpPtr value:beginSN needOffset:YES];
    if (beginSN != 0) {
        [CodingUtil setUInt16:&tmpPtr value:endSN needOffset:YES];
    }
    return YES;
}

@end

