//
//  FSBAQueryOut.m
//  FonestockPower
//
//  Created by Connor on 14/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBAQueryOut.h"
#import "OutPacket.h"

@interface FSBAQueryOut() {
    NSArray *_identCodeSymbols;
}
@end

@implementation FSBAQueryOut

- (instancetype)initWithIdentCodeSymbols:(NSArray *)identCodeSymbols {
    if (self = [super init]) {
        _identCodeSymbols = identCodeSymbols;
    }
    return self;
}

- (int)getPacketSize {
    return 1000;// + 4 * [_identCodeSymbols count];
}

- (BOOL)encode:(NSObject*)account1 buffer:(char*)buffer length:(int)len {
    
    char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 9;
	phead->command = 2;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
    
    *tmpPtr++ = [_identCodeSymbols count];
    
    for (NSString *identCodeSymbol in _identCodeSymbols) {
        *tmpPtr++ = [identCodeSymbol length];
        strncpy(tmpPtr, [identCodeSymbol cStringUsingEncoding:NSASCIIStringEncoding], [identCodeSymbol length]);
        tmpPtr += [identCodeSymbol length];
    }
    
    return YES;
}
@end
