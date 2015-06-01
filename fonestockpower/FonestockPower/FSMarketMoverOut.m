//
//  FSMarketMoverOut.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMarketMoverOut.h"
#import "OutPacket.h"


@implementation FSMarketMoverOut


-(id)initWithSortingType:(UInt8)st direction:(UInt8)d update:(UInt8)u{

    if (self = [super init]) {
        sortingType = st;
        direction = d;
        update = u;
    }
    return self;
}


-(int)getPacketSize{
    return 22;
}



-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 9;
	phead->command = 13;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer += sizeof(OutPacketHeader);
    
    char *tmpPtr = buffer;
    
    *tmpPtr++ = 2;//查詢market mover
    *tmpPtr++ = update;//是否為第一次查詢
    [CodingUtil setUInt16:tmpPtr Value:50];//排名前n個,0=前500
    tmpPtr += 2;
    //fields bit mask
    *tmpPtr++ = (char)0x7D;
    *tmpPtr++ = (char)0x01;
    *tmpPtr++ = (char)0x71;
    *tmpPtr++ = (char)0x01;
    *tmpPtr++ = (char)0x01;
    *tmpPtr++ = (char)0x01;
    *tmpPtr++ = (char)0x60;
    *tmpPtr++ = 2;//filter 個數
    //a: sector filter
    *tmpPtr++ = 'a';
    *tmpPtr++ = 1;
    [CodingUtil setUInt16:tmpPtr Value:599];//sector id = 599
    tmpPtr += 2;
//    [CodingUtil setUInt16:tmpPtr Value:sectorId];
//    tmpPtr += 2;
    //c: security type filter
    *tmpPtr++ = 'c';
    *tmpPtr++ = 1;
    *tmpPtr++ = 1;
    //sort
    *tmpPtr++ = 1; //個數
    *tmpPtr++ = sortingType; //type
    *tmpPtr++ = direction; // 0 = desc ; 1 = asec
    
    
	return YES;
}

@end
