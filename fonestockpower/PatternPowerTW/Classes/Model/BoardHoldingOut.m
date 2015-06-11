//
//  BoardHoldingOut.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "BoardHoldingOut.h"
#import "OutPacket.h"
@implementation BoardHoldingOut
- (instancetype)initWithSecurityNum:(UInt32)sn queryType:(UInt8)queryType count:(UInt8)count recordDate:(UInt16)recordDate {
    if (self = [super init]) {
        _securityNum = sn;
        _queryType = queryType;
        _count = count;
        _recordDate = recordDate;
    }
    return self;
}

- (int)getPacketSize {
    return sizeof(_securityNum) + sizeof(_queryType) + sizeof(_count) + sizeof(_recordDate);
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len {
	char *tmpPtr = buffer;
    
	OutPacketHeaderRef phead = (OutPacketHeaderRef)tmpPtr;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 20;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr += sizeof(OutPacketHeader);
	
    [CodingUtil setUInt32:&tmpPtr value:_securityNum needOffset:YES];
    [CodingUtil setUInt8:&tmpPtr value:_queryType needOffset:YES];
    [CodingUtil setUInt8:&tmpPtr value:_count needOffset:YES];
	[CodingUtil setUInt16:&tmpPtr value:_recordDate needOffset:YES];
    
	return YES;
}
@end
