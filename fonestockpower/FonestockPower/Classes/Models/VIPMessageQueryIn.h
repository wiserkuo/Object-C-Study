//
//  VIPMessageQueryIn.h
//  Bullseye
//
//  Created by Neil on 13/9/3.
//
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface VIPMessageQueryIn : NSObject<DecodeProtocol>{
    UInt16 count;
    UInt8 retCode;
    NSMutableArray *dataArray;
    
}

@end

@interface ConsultancyMessage : NSObject{
@public
	UInt8 companyId;
    UInt16 consultancyId;
    UInt8 pdaItemId;
    UInt16 serialNumber;
    
    UInt16 date;
    UInt16 year;
	UInt8 month;
	UInt8 day;
    
    UInt32 time;
    UInt8 hour;
    UInt8 minute;
    UInt8 second;
    
    UInt8 totalPacket;
    UInt8 packetIndex;
    UInt8 format;
    UInt16 packetLength;
    NSString * dataContent;
}

@end
