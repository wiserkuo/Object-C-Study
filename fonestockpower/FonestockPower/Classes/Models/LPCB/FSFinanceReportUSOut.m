//
//  FSFinanceReportUSOut.m
//  FonestockPower
//
//  Created by Connor on 14/9/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSFinanceReportUSOut.h"
#import "OutPacket.h"

@interface FSFinanceReportUSOut() {
    FSFinanceReportQueryType _queryType;
    char _dataType;
    UInt32 _securityNumber;
    UInt16 _startDate;
    UInt16 _endDate;
}
@end

@implementation FSFinanceReportUSOut

- (instancetype)initWithSecurityNumber:(UInt32)securityNumber dataType:(char)dataType queryType:(FSFinanceReportQueryType)queryType searchStartDate:(UInt16)startDate {
    if (self = [super init]) {
        _dataType = dataType;
        _queryType = FSFinanceReportQueryTypeSpecify;
        _securityNumber = securityNumber;
        _startDate = startDate;
        _financeReportCommend = FSFinanceReportCommendBalanceSheet;
    }
    return self;
}

- (instancetype)initWithSecurityNumber:(UInt32)securityNumber dataType:(char)dataType queryType:(FSFinanceReportQueryType)queryType searchStartDate:(UInt16)startDate endDate:(UInt16)endDate {
    if (self = [super init]) {
        _dataType = dataType;
        _queryType = FSFinanceReportQueryTypeInterval;
        _securityNumber = securityNumber;
        _startDate = startDate;
        _endDate = endDate;
        _financeReportCommend = FSFinanceReportCommendBalanceSheet;
    }
    return self;
}

- (int)getPacketSize {
    if (_queryType == FSFinanceReportQueryTypeSpecify) {
        return 8;
    }
    else if (_queryType == FSFinanceReportQueryTypeInterval) {
        return 10;
    }
    return 0;
}

- (BOOL)encode:(NSObject*)account1 buffer:(char*)buffer length:(int)len {
    char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 10;
    phead->command = _financeReportCommend;
    
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
    
    [CodingUtil setUInt32:&tmpPtr value:_securityNumber needOffset:YES];
    
	*tmpPtr++ = _dataType;
	*tmpPtr++ = _queryType;

	[CodingUtil setUInt16:&tmpPtr value:_startDate needOffset:YES];
    if (_queryType == FSFinanceReportQueryTypeInterval) {
        [CodingUtil setUInt16:&tmpPtr value:_endDate needOffset:YES];
    }
    return YES;
}

@end
