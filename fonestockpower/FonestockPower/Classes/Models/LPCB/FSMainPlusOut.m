//
//  FSMainPlusOut.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMainPlusOut.h"
#import "OutPacket.h"

static int stringSize = 0;

@implementation BrokerBranchByStockOut

//Broker Branch B/S by Stock (Msg=10, Cmd=35)
-(id)initWithSymbol:(NSString *)s days:(UInt16)d startDate:(UInt16)sD endDate:(UInt16)eD sortType:(UInt8)sT count:(UInt8)c{
    
    if (self = [super init]) {
        symbol = s;
        days = d;
        startDate = sD;
        endDate = eD;
        sortType = sT;
        count = c;
    }
    return self;
}
-(id)initWithSymbol:(NSString *)s days:(UInt16)d sortType:(UInt8)sT count:(UInt8)c{
    
    if (self = [super init]) {
        symbol = s;
        days = d;
        sortType = sT;
        count = c;
    }
    return self;
}

-(int)getPacketSize{
    if (days == 0) {
        return 2 + (int)[symbol length] + 2 + 2 + 2 + 1 + 1 + 1 + 1;
    }else{
        return 2 + (int)[symbol length] + 2 + 1 + 1 + 1 + 1;
    }
}

-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead -> escape = 0x1B;
    phead -> message = 10;
    phead -> command = 35;
    [CodingUtil setUInt16:(char *)&(phead -> size) Value:len];
    tmpPtr += sizeof(OutPacketHeader);
    
    *tmpPtr++ = 'T';
    *tmpPtr++ = 'W';
    
    *tmpPtr++ = [symbol length];
    strncpy(tmpPtr, [symbol cStringUsingEncoding:NSASCIIStringEncoding], [symbol length]);
    tmpPtr += [symbol length];
    
    [CodingUtil setUInt16:tmpPtr Value:days];
    tmpPtr += 2;
    
    if (days == 0) {
        [CodingUtil setUInt16:tmpPtr Value:startDate];
        tmpPtr += 2;
        
        [CodingUtil setUInt16:tmpPtr Value:endDate];
        tmpPtr += 2;
    }
    
    //broker select
    *tmpPtr++ = 0;
    //count
    *tmpPtr++ = count;

    *tmpPtr++ = sortType ;
    return YES;
    
}
@end

@implementation BrokerBranchByAnchorOut

-(id)initWithSymbol:(NSString *)s brokerBranchID:(NSString *)bID count:(UInt16)c startDate:(UInt16)sD endDate:(UInt16)eD{
    if (self = [super init]) {
        symbol = s;
        brokerBranchId = bID;
        count = c;
        startDate = sD;
        endDate = eD;
    }
    return self;
}

-(id)initWithSymbol:(NSString *)s brokerBranchID:(NSString *)bID count:(UInt16)c{
    if (self = [super init]) {
        symbol = s;
        brokerBranchId = bID;
        count = c;
    }
    return self;
}

-(int)getPacketSize{
    if (count == 0) {
        return 2 + (int)[symbol length] + 1 + (int)[brokerBranchId length] + 1 + 2 + 2 + 2;
    }else{
        return 2 + (int)[symbol length] + 1 + (int)[brokerBranchId length] + 1 + 2;
    }
}
-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead -> escape = 0x1B;
    phead -> message = 10;
    phead -> command = 36;
    [CodingUtil setUInt16:(char *)&(phead -> size) Value:len];
    tmpPtr += sizeof(OutPacketHeader);
    
    *tmpPtr++ = 'T';
    *tmpPtr++ = 'W';
    
    *tmpPtr++ = [symbol length];
    strncpy(tmpPtr, [symbol cStringUsingEncoding:NSASCIIStringEncoding], [symbol length]);
    tmpPtr += [symbol length];
    
    *tmpPtr++ = [brokerBranchId length];
    strncpy(tmpPtr, [brokerBranchId cStringUsingEncoding:NSASCIIStringEncoding], [brokerBranchId length]);
    tmpPtr += [brokerBranchId length];
    
    [CodingUtil setUInt16:tmpPtr Value:count];
    tmpPtr += 2;
    
    if (count == 0) {
        [CodingUtil setUInt16:tmpPtr Value:startDate];
        tmpPtr += 2;
        
        [CodingUtil setUInt16:tmpPtr Value:endDate];
        tmpPtr += 2;
    }
    return YES;
    
}


@end

@implementation BrokerBranchDetailByAnchorOut

-(id)initWithSymbol:(NSString *)s brokerBranchID:(NSString *)bID dataDate:(UInt16)dD{
    if (self = [super init]) {
        symbol = s;
        brokerBranchId = bID;
        dataDate = dD;
    }
    return self;
}

-(int)getPacketSize{
    return 2 + (int)[symbol length] + 1 + (int)[brokerBranchId length] + 1 + 2;
}
-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead -> escape = 0x1B;
    phead -> message = 10;
    phead -> command = 37;
    [CodingUtil setUInt16:(char *)&(phead -> size) Value:len];
    tmpPtr += sizeof(OutPacketHeader);
    
    *tmpPtr++ = 'T';
    *tmpPtr++ = 'W';
    
    *tmpPtr++ = [symbol length];
    strncpy(tmpPtr, [symbol cStringUsingEncoding:NSASCIIStringEncoding], [symbol length]);
    tmpPtr += [symbol length];
    
    *tmpPtr++ = [brokerBranchId length];
    strncpy(tmpPtr, [brokerBranchId cStringUsingEncoding:NSASCIIStringEncoding], [brokerBranchId length]);
    tmpPtr += [brokerBranchId length];
    
    [CodingUtil setUInt16:tmpPtr Value:dataDate];
    tmpPtr += 2;
    
    return YES;
    
}

@end

@implementation BrokerBranchByBrokerOut

-(id)initWithBrokerBranchId:(NSString *)bBId days:(UInt16)d startDate:(UInt16)sD endDate:(UInt16)eD sortType:(UInt8)st{
    if (self = [super init]) {
        brokerBranchId = bBId;
        days = d;
        startDate = sD;
        endDate = eD;
        sortType = st;
    }
    return self;
}

-(id)initWithBrokerBranchId:(NSString *)bBId days:(UInt16)d sortType:(UInt8)st{
    if (self = [super init]) {
        brokerBranchId = bBId;
        days = d;
        sortType = st;
    }
    return self;
}

-(int)getPacketSize{
    if (days == 0) {
        return (int)[brokerBranchId length] + 1 + 2 + 2 + 2 + 1 + 1;
    }else{
        return (int)[brokerBranchId length] + 1 + 2 + 1 + 1;
    }
}
-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead -> escape = 0x1B;
    phead -> message = 10;
    phead -> command = 38;
    [CodingUtil setUInt16:(char *)&(phead -> size) Value:len];
    tmpPtr += sizeof(OutPacketHeader);

    *tmpPtr++ = [brokerBranchId length];
    strncpy(tmpPtr, [brokerBranchId cStringUsingEncoding:NSASCIIStringEncoding], [brokerBranchId length]);
    tmpPtr += [brokerBranchId length];
    
    [CodingUtil setUInt16:tmpPtr Value:days];
    tmpPtr += 2;
    
    if (days == 0) {

        [CodingUtil setUInt16:tmpPtr Value:startDate];
        tmpPtr += 2;
        [CodingUtil setUInt16:tmpPtr Value:endDate];
        tmpPtr += 2;
    }
    
    *tmpPtr++ = 30;
    
    *tmpPtr++ = sortType;
    return YES;
    
}

@end

@implementation MainBranchKLineOut

-(id)initWithSymbol:(NSString *)s brokerBranchIdD:(NSString *)bBId dataType:(UInt8)dT count:(UInt8)c startDate:(UInt16)sD endDate:(UInt16)eD{

    if (self = [super init]) {
        symbol = s;
        brokerBranchId = bBId;
        dataType = dT;
        count = c;
        startDate = sD;
        endDate = eD;
    }
    return self;
}

-(int)getPacketSize{
    if (count == 0) {
        return 2 + (int)[symbol length] + 1 + 1 + (int)[brokerBranchId length] + 1 + 1 + 2 + 2 + 2;
    }else{
        return 2 + (int)[symbol length] + 1 + 1 + (int)[brokerBranchId length] + 1 + 1 + 2;
    }
}
-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead -> escape = 0x1B;
    phead -> message = 10;
    phead -> command = 43;
    [CodingUtil setUInt16:(char *)&(phead -> size) Value:len];
    tmpPtr += sizeof(OutPacketHeader);
    
    *tmpPtr++ = 'T';
    *tmpPtr++ = 'W';
    
    *tmpPtr++ = [symbol length];
    strncpy(tmpPtr, [symbol cStringUsingEncoding:NSASCIIStringEncoding], [symbol length]);
    tmpPtr += [symbol length];
    
    *tmpPtr++ = 1;
    
    *tmpPtr++ = [brokerBranchId length];
    strncpy(tmpPtr, [brokerBranchId cStringUsingEncoding:NSASCIIStringEncoding], [brokerBranchId length]);
    tmpPtr += [brokerBranchId length];
    
    *tmpPtr++ = dataType;
    
    [CodingUtil setUInt16:tmpPtr Value:count];
    tmpPtr += 2;
    
    if (count == 0) {
        [CodingUtil setUInt16:tmpPtr Value:startDate];
        tmpPtr += 2;
        [CodingUtil setUInt16:tmpPtr Value:endDate];
        tmpPtr += 2;
    }
    
    return YES;
    
}
@end

@implementation OptionalMainOut

//@synthesize brokerBranchId;

-(id)initWithBrokerBranchId:(NSArray *)bBId days:(UInt16)d startDate:(UInt16)sD endDate:(UInt16)eD count:(UInt8)c sortType:(UInt8)sT{
    
    if (self = [super init]) {
        brokerBranchId = bBId;
        for (NSString *tmpString in bBId) {
            stringSize = stringSize + (int)[tmpString lengthOfBytesUsingEncoding:NSASCIIStringEncoding] + 1;
        }
        days = d;
        startDate = sD;
        endDate = eD;
        count = c;
        sortType = sT;
    }
    return self;
}

-(id)initWithidBrokerBranchId:(NSArray *)bBId days:(UInt16)d count:(UInt8)c sortType:(UInt8)sT{
    
    if (self = [super init]) {
        brokerBranchId = bBId;
        for (NSString *tmpString in bBId) {
            stringSize = stringSize + (int)[tmpString lengthOfBytesUsingEncoding:NSASCIIStringEncoding] + 1;
        }
        days = d;
        count = c;
        sortType = sT;
    }
    return self;
}

-(int)getPacketSize{
    if (days == 0) {
        return 1 + stringSize + 2 + 2 + 2 + 1 + 1;
    }else{
        return 1 + stringSize + 2 + 1 + 1;
    }
}
-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    
    char *tmpPtr = buffer;
    OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
    phead -> escape = 0x1B;
    phead -> message = 10;
    phead -> command = 44;
    [CodingUtil setUInt16:(char *)&(phead -> size) Value:len];
    tmpPtr += sizeof(OutPacketHeader);

    *tmpPtr++ = [brokerBranchId count];
    
    for (NSString *tmpString in brokerBranchId) {
        int tmpStringSize = (int)[tmpString lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
        *tmpPtr++ = tmpStringSize;
        memcpy(tmpPtr, [tmpString cStringUsingEncoding:NSASCIIStringEncoding], tmpStringSize);
        tmpPtr += tmpStringSize;
    }
    
    [CodingUtil setUInt16:tmpPtr Value:days];
    tmpPtr += 2;
    
    if (days == 0) {
        [CodingUtil setUInt16:tmpPtr Value:startDate];
        tmpPtr += 2;
        [CodingUtil setUInt16:tmpPtr Value:endDate];
        tmpPtr += 2;
    }
    *tmpPtr++ = count;
    
    *tmpPtr++ = sortType;
    
    return YES;
    
}

@end