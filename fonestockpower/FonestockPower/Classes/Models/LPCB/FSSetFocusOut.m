//
//  FSSetFocusOut.m
//  FonestockPower
//
//  Created by Connor on 14/9/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSSetFocusOut.h"
#import "OutPacket.h"

@interface FSSetFocusOut() {
    FSSetFocusType _focusType;
    FSSetFocusOperate _focusOperate;
    UInt32 _timestamp;
    NSArray *_securityNumbers;
}

@end
@implementation FSSetFocusOut
- (instancetype)initWithFocusType:(FSSetFocusType)focusType queryType:(FSSetFocusOperate)focusOperate timestamp:(UInt32)timestamp securityNumbers:(NSArray *)securityNumbers {
    if (self = [super init]) {
        _focusType = focusType;
        _focusOperate = focusOperate;
        _timestamp = timestamp;
        _securityNumbers = securityNumbers;
    }
    return self;
}

- (int)getPacketSize {
    return 8 + (int)[_securityNumbers count] * 4;
}

- (BOOL)encode:(NSObject*)account1 buffer:(char*)buffer length:(int)len {
    char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 4;
    phead->command = 24;
    
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
    
    *tmpPtr++ = _focusType;
    *tmpPtr++ = _focusOperate;
    
    [CodingUtil setUInt32:&tmpPtr value:_timestamp needOffset:YES];
    
    [CodingUtil setUInt16:&tmpPtr value:[_securityNumbers count] needOffset:YES];
    for (NSNumber *securityNumber in _securityNumbers) {
        [CodingUtil setUInt32:&tmpPtr value:[securityNumber unsignedIntValue] needOffset:YES];
    }
    
    return YES;
}
@end
