//
//  NewCompanyProfileOut.m
//  WirtsLeg
//
//  Created by Connor on 13/12/30.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "NewCompanyProfileOut.h"
#import "OutPacket.h"

@implementation NewCompanyProfileOut

- (instancetype)initWithSecurityNum:(UInt32)sn subType:(UInt8)subType recordDate:(UInt16)recordDate {
    if (self = [super init]) {
        _securityNum = sn;
        _subType = subType;
        _recordDate = recordDate;
    }
    return self;
}

- (int)getPacketSize {
    return sizeof(_securityNum) + sizeof(_subType) + sizeof(_recordDate);
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len {
	char *tmpPtr = buffer;
    
	OutPacketHeaderRef phead = (OutPacketHeaderRef)tmpPtr;
	phead->escape = 0x1B;
#ifdef PatternPowerCN
    phead->message = 10;
    phead->command = 8;
#else
	phead->message = 2;
	phead->command = 8;
#endif
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr += sizeof(OutPacketHeader);
	
    [CodingUtil setUInt32:&tmpPtr value:_securityNum needOffset:YES];
    [CodingUtil setUInt8:&tmpPtr value:_subType needOffset:YES];
	[CodingUtil setUInt16:&tmpPtr value:_recordDate needOffset:YES];
    
	return YES;
}

@end
