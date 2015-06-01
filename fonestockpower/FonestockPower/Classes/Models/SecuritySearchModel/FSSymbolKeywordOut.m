//
//  FSSymbolKeywordOut.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/4/29.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSSymbolKeywordOut.h"
#import "OutPacket.h"
@implementation FSSymbolKeywordOut

-(id)initWithCountPage:(UInt8)cP PageNo:(UInt8)pN FieldType:(UInt8)fT SearchType:(UInt8)sT{
    if(self = [super init])
    {
        count = cP;
        pageNo = pN;
        fieldType = fT;
        searchType = sT;
    }
    return self;
}

- (void)setKeyword:(NSString*)s
{
    if(s)
        keyword = [[NSString alloc] initWithString:s];
    else
        keyword = nil;
    length = [keyword lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

-(int)getPacketSize{
    int size = 2 + 2 + 1 + 1 + length;
    return size;
}

-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead->escape = 0x1B;
    phead->message = 1;
    phead->command = 6;
    [CodingUtil setUInt16:(char*)&(phead->size) Value:len];
    buffer+=sizeof(OutPacketHeader);
    
    [CodingUtil setUInt8:&buffer value:101  needOffset:YES];
    [CodingUtil setUInt8:&buffer value:121  needOffset:YES];
    
    *buffer++ = count;
    *buffer++ = pageNo;
    
    [CodingUtil setBufferr:fieldType Bits:4 Buffer:buffer Offset:0];
    [CodingUtil setBufferr:searchType Bits:4 Buffer:buffer Offset:4];
    buffer++;
    
    *buffer++ = length;
    memcpy(buffer , [keyword UTF8String] , length);
    
    return YES;
}

@end
