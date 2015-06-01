//
//  NewHistoricalPriceOut.m
//  Bullseye
//
//  Created by Connor on 13/9/6.
//
//

#import "NewHistoricalPriceOut.h"
#import "OutPacket.h"

@interface NewHistoricalPriceOut() {
    NSInteger *packetSize;
}
@end

@implementation NewHistoricalPriceOut

-(id)initWithSecurityNumber:(UInt32)securityNumber dataType:(UInt8)dataType commodityType:(UInt8)commodityType startDate:(UInt16)startDate endDate:(UInt16)endDate {
    
    if (self = [super init]) {
        _securityNumber = securityNumber;
        _dataType = dataType;
        _commodityType = commodityType;
        _startDate = startDate;
        _endDate = endDate;
        _queryType = 0;
    }
    return self;
}

-(id)initWithSecurityNumber:(UInt32)securityNumber dataType:(UInt8)dataType commodityType:(UInt8)commodityType count:(UInt16)count {
    
    if (self = [super init]) {
        _securityNumber = securityNumber;
        _dataType = dataType;
        _commodityType = commodityType;
        _queryType = 1;
        _count = count;
    }
    return self;
}

- (int)getPacketSize {
    if (_queryType == 0 || _queryType == 2) {
        return 11;
    } else {
        return 10;
    }
	
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len {
	char *tmpPtr = buffer;
    
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 2;
	phead->command = 32;
	[CodingUtil setUInt16:(char *)&(phead->size) Value:len];
	buffer += sizeof(OutPacketHeader);
	
	[CodingUtil setUInt32:buffer Value:_securityNumber];
	buffer += sizeof(_securityNumber);
    
	*buffer++ = _dataType;
	*buffer++ = _commodityType;
    *buffer++ = _queryType;

	if (_queryType == 0) {
        [CodingUtil setUInt16:buffer Value:_startDate];
        buffer += sizeof(_startDate);
        [CodingUtil setUInt16:buffer Value:_endDate];
        buffer += sizeof(_endDate);
        
    } else if (_queryType == 1) {
        [CodingUtil setUInt16:buffer Value:_count];
        buffer += sizeof(_count);
        
    } else if (_queryType == 2) {
        [CodingUtil setUInt16:buffer Value:_startDate];
        buffer += sizeof(_startDate);
        [CodingUtil setUInt16:buffer Value:_count];
        buffer += sizeof(_count);
    }
    
    buffer = tmpPtr;
	return YES;
}
@end
