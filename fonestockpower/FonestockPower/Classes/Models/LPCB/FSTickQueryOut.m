//
//  FSTickQueryOut.m
//  FonestockPower
//
//  Created by Connor on 14/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSTickQueryOut.h"
#import "OutPacket.h"

@interface FSTickQueryOut() {
    NSString *_identCodeSymbol;
    FSBTimeFormat *_lastTickValue;
}

@end

@implementation FSTickQueryOut

- (instancetype)initWithIdentCodeSymbol:(NSString *)identCodeSymbol {
    if (self = [super init]) {
        _identCodeSymbol = [identCodeSymbol stringByReplacingOccurrencesOfString:@" " withString:@":"];
        
        
        
    }
    return self;
}

- (instancetype)initWithIdentCodeSymbol:(NSString *)identCodeSymbol lastTickBTimeFormat:(FSBTimeFormat *)lastTickValue{
    if (self = [super init]) {
        _identCodeSymbol = [identCodeSymbol stringByReplacingOccurrencesOfString:@" " withString:@":"];
        _lastTickValue = lastTickValue;
    }
    return self;
}

- (int)getPacketSize {
    int len = 1 + (int)[_identCodeSymbol length] + 1 + 4 + 4;
    return len;
}

- (BOOL)encode:(NSObject*)account1 buffer:(char*)buffer length:(int)len {
    
    char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 9;
	phead->command = 3;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
    
    *tmpPtr++ = [_identCodeSymbol length];
    strncpy(tmpPtr, [_identCodeSymbol cStringUsingEncoding:NSASCIIStringEncoding], [_identCodeSymbol length]);
    tmpPtr += [_identCodeSymbol length];
    
    *tmpPtr++ = 'A';
    
    FSBTimeFormat *time;
    if (_lastTickValue) {
        time = _lastTickValue;
    }
    else {
        time = [[FSBTimeFormat alloc] initWithHours:8 minutes:30 seconds:0 sn:0];
    }
    
    [time setBuffer:&tmpPtr needOffset:YES];
    
    [CodingUtil setBufferr:0 Bits:1 Buffer:tmpPtr Offset:0];
	[CodingUtil setBufferr:0 Bits:31 Buffer:tmpPtr Offset:1];
    
    return YES;
}

@end
