//
//  PowerPPPOut.m
//  FonestockPower
//
//  Created by CooperLin on 2014/11/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "PowerPPPOut.h"
#import "OutPacket.h"

@interface PowerPPPOut()
{
    BOOL isPPPBeCalled;
    
    UInt16 identCode;
    NSString *symbol;
    UInt32 price;
    UInt16 days;
    UInt16 startDate;
    UInt16 endDate;
    UInt8 count;
}
@end

@implementation PowerPPPOut

-(id)initWithPowerPPP:(UInt16)ic :(NSString *)sl :(UInt32)p :(UInt16)d :(UInt16)sd :(UInt16)ed :(UInt8)c
{
    if(self = [super init]){
        isPPPBeCalled = YES;
        
        identCode = ic;
        symbol = sl;
        price = p;
        days = d;
        startDate = sd;
        endDate = ed;
        count = c;
    }
    return self;
}

-(id)initWithPowerPP:(UInt16)ic :(NSString *)sl :(UInt16)d :(UInt16)sd :(UInt16)ed
{
    if(self = [super init]){
        isPPPBeCalled = NO;
        
        identCode = ic;
        symbol = sl;
        days = d;
        startDate = sd;
        endDate = ed;
    }
    return self;
}

- (int)getPacketSize
{
    if(isPPPBeCalled){
        return 13 + (int)[symbol length] + 1;
    }else{
        return 9 + (int)[symbol length] + 1;
    }
}
- (BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len
{
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead->escape = 0x1B;
    phead->message = 10;
    if(isPPPBeCalled){
        phead->command = 45;
    }else{
        phead->command = 46;
    }
    [CodingUtil setUInt16:(char*)&(phead->size) Value:len];
    tmpPtr+=sizeof(OutPacketHeader);
    

//    fs-tipscation    //這個是app name
//    NSData *portbuf; //此nsdata 資料的來源是由Tips_location_up轉好然後傳進來的
//    strncpy(tmpPtr, portbuf.bytes, portbuf.length);
//    tmpPtr+=portbuf.length;
    
    *tmpPtr++ = 'T';
    *tmpPtr++ = 'W';
    
    *tmpPtr ++=[symbol length];
    strncpy(tmpPtr, [symbol cStringUsingEncoding:NSASCIIStringEncoding], [symbol length]);
    tmpPtr += [symbol length];
    
    if(isPPPBeCalled){
        [CodingUtil setUInt32:tmpPtr Value:price];
        tmpPtr+=4;
    }
    [CodingUtil setUInt16:tmpPtr Value:days];
    tmpPtr+=2;
    
//    UInt16 tmpDate;
//    tmpDate = [CodingUtil makeDate:2014 month:12 day:12];
//    [CodingUtil setUInt16:tmpPtr Value:tmpDate];
    [CodingUtil setUInt16:tmpPtr Value:startDate];
    tmpPtr+=2;
    
//    UInt16 tmpDate2;
//    tmpDate2 = [CodingUtil makeDate:2014 month:12 day:16];
//    [CodingUtil setUInt16:tmpPtr Value:tmpDate2];
    [CodingUtil setUInt16:tmpPtr Value:endDate];
    tmpPtr+=2;
    
    if(isPPPBeCalled){
        *tmpPtr++= count;
    }

    return YES;
}

@end
