//
//  FSDistributeOut.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/23.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSDistributeOut.h"
#import "OutPacket.h"

@implementation FSDistributeOut

- (id)initWithOneDayIdentCodeSymbol:(NSString *)iD number:(UInt8)n date:(UInt16)d
{
    if(self = [super init])
    {
        type = 0;	//0:單日,1:累計
        identCodeSymbol = iD;
        number = n;
        date = d;
    }
    return self;
}

- (id)initWithAddDayIdentCodeSymbol:(NSString *)iD number:(UInt8)n date:(UInt16)d
{
    if(self = [super init])
    {
        type = 1;	//0:單日,1:累計
        identCodeSymbol = iD;
        number = n;
        date = d;
    }
    return self;
}


- (int)getPacketSize
{
    return (int)[identCodeSymbol length] + 5;
}
-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead->escape = 0x1B;
    phead->message = 9;
    phead->command = 11;
    [CodingUtil setUInt16:(char*)&(phead->size) Value:len];
    tmpPtr+=sizeof(OutPacketHeader);
    
    *tmpPtr++= [identCodeSymbol length];
    strncpy(tmpPtr, [identCodeSymbol cStringUsingEncoding:NSASCIIStringEncoding], [identCodeSymbol length]);
    tmpPtr += [identCodeSymbol length];
    
    *tmpPtr++ = type;
    *tmpPtr++ = number;
    [CodingUtil setUInt16:&tmpPtr value:date needOffset:YES];

    return YES;


}
@end