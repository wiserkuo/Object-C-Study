//
//  TechOut.m
//  FonestockPower
//
//  Created by Kenny on 2014/12/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TechOut.h"
#import "OutPacket.h"

@implementation TechOut{
    NSInteger *packetSize;
}
-(id)initIdentCodeSymbol:(NSString *)identCodeSymbol dataType:(UInt8)dataType commodityType:(UInt8)commodityType startDate:(UInt16)startDate endDate:(UInt16)endDate {
    
    if (self = [super init]) {
        _identCodeSymbol = identCodeSymbol;
        _dataType = dataType;
        _commodityType = commodityType;
        _queryType = 0;
        _startDate = startDate;
        _endDate = endDate;
    }
    return self;
}

-(id)initWithIdentCodeSymbol:(NSString *)identCodeSymbol dataType:(UInt8)dataType commodityType:(UInt8)commodityType count:(UInt16)count{
    if (self = [super init]) {
        _identCodeSymbol = identCodeSymbol;
        _dataType = dataType;
        _commodityType = commodityType;
        _queryType = 1;
        _dataCount = count;
    }
    return self;
}
- (int)getPacketSize {
    if (_queryType == 0 || _queryType == 2) {
        return 8 + (int)[_identCodeSymbol length];
    } else {
        return 6 + (int)[_identCodeSymbol length];
    }
    
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len {
    char *tmpPtr = buffer;
    
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead->escape = 0x1B;
    phead->message = 2;
    phead->command = 37;
    [CodingUtil setUInt16:(char *)&(phead->size) Value:len];
    buffer += sizeof(OutPacketHeader);
    
    NSString *identCodeSymbol = [_identCodeSymbol stringByReplacingOccurrencesOfString:@" " withString:@":"];
    
    *buffer++ = [identCodeSymbol length];
    strncpy(buffer, [identCodeSymbol cStringUsingEncoding:NSASCIIStringEncoding], [identCodeSymbol length]);
    buffer += [identCodeSymbol length];
    
    *buffer++ = _dataType;
    *buffer++ = _commodityType;
    *buffer++ = _queryType;
    
//    if (_queryType == 0) {
//        [CodingUtil setUInt16:buffer Value:_startDate];
//        buffer += sizeof(_startDate);
//        [CodingUtil setUInt16:buffer Value:_endDate];
//        buffer += sizeof(_endDate);
//        
//    } else if (_queryType == 1) {
//        [CodingUtil setUInt16:buffer Value:_dataCount];
//        buffer += sizeof(_dataCount);
//        
//    } else if (_queryType == 2) {
//        [CodingUtil setUInt16:buffer Value:_startDate];
//        buffer += sizeof(_startDate);
//        [CodingUtil setUInt16:buffer Value:_dataCount];
//        buffer += sizeof(_dataCount);
//    }
    
    if (_queryType == 0) {
        [CodingUtil setUInt16:&buffer value:_startDate needOffset:YES];
        [CodingUtil setUInt16:&buffer value:_endDate needOffset:YES];
        
    } else if (_queryType == 1) {
        [CodingUtil setUInt16:&buffer value:_dataCount needOffset:YES];
        
    } else if (_queryType == 2) {
        [CodingUtil setUInt16:&buffer value:_startDate needOffset:YES];
        [CodingUtil setUInt16:&buffer value:_dataCount needOffset:YES];
    }
    
    buffer = tmpPtr;
    return YES;
}


@end
