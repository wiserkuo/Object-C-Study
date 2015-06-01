//
//  BrokersByStockOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/12.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface BrokersByStockOut : NSObject <EncodeProtocol>{
	UInt32 securityNum;
	UInt16 date;
	UInt8 dayType;
	UInt8 days;
	UInt8 countType;
	UInt8 count;
    UInt8 sortType;
}

- (id)initWithSecurityNum:(UInt32)cn RecordDate:(UInt16)d DayType:(UInt8)dt CountType:(UInt8)ct SortType:(UInt8)st;
- (id)initWithSecurityNum:(UInt32)cn RecordDate:(UInt16)d Days:(UInt8)ds Counts:(UInt8)cs SortType:(UInt8)st;

@end

@interface BrokersByBrokerOut : NSObject <EncodeProtocol>{
	UInt16 brokerID;
	UInt16 date;
	UInt8 dayType;
	UInt8 days;
	UInt8 countType;
	UInt8 count;
	
}

- (id)initWithBrokerID:(UInt16)bID RecordDate:(UInt16)d DayType:(UInt8)dt CountType:(UInt8)ct;
- (id)initWithBrokerID:(UInt16)bID RecordDate:(UInt16)d Days:(UInt8)ds Counts:(UInt8)cs;

@end

@interface BrokersByAnchorOut : NSObject <EncodeProtocol>{
	UInt32 securityNum;
	UInt16 brokerID;
	UInt8 count;
	UInt16 startDate;
	UInt16 endDate;
	
}

- (id)initWithSecurityNum:(UInt32)cn BrokerID:(UInt16)bID Count:(UInt8)c; 
- (id)initWithSecurityNum:(UInt32)cn BrokerID:(UInt16)bID StartDate:(UInt16)sd EndDate:(UInt16)ed;

@end

//Michael
@interface NewBrokersByBroker : NSObject<EncodeProtocol>{
    UInt16 brokerId;
    UInt16 date;
    UInt8 dayType;
    UInt8 days;
    UInt8 countType;
    UInt8 count;
    UInt8 sortType;
}

- (id)initWithBrokerId:(UInt16)bId RecordDate:(UInt16)d DayType:(UInt8)dt CountType:(UInt8)ct SortType:(UInt8)st;
- (id)initWithBrokerId:(UInt16)bId RecordDate:(UInt16)d Days:(UInt8)ds Counts:(UInt8)cs SortType:(UInt8)st;

@end