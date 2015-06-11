//
//  ProtocolBufferOut.m
//  FonestockPower
//
//  Created by CooperLin on 2015/1/7.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "ProtocolBufferOut.h"
#import "OutPacket.h"

@interface ProtocolBufferOut (){
    NSData *data;
}

@end

@implementation ProtocolBufferOut

-(instancetype)initWithUpStream:(NSData *)inPutData
{
    self = [super init];
    if(self){
        data = inPutData;
    }
    return self;
}

-(int)getPacketSize
{
    return (int)data.length + 13 + 1 + 2;
}

-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len
{
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead->escape = 0x1B;
    phead->message = 103;
    phead->command = 1;
    [CodingUtil setUInt16:(char*)&(phead->size) Value:len];
    tmpPtr+=sizeof(OutPacketHeader);
    
    
    NSString *appName = @"fs_tipscation";
    *tmpPtr ++= [appName length];
    strncpy(tmpPtr, [appName cStringUsingEncoding:NSASCIIStringEncoding], [appName length]);
    tmpPtr += [appName length];
    
    [CodingUtil setUInt16:tmpPtr Value:data.length];
    tmpPtr += 2;
    
//    *tmpPtr++ = 0x08;
//    *tmpPtr++ = 0x00;
    
    strncpy(tmpPtr, data.bytes, data.length);
    tmpPtr+=data.length;
    
    return YES;
}

@end