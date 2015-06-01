//
//  VIPMessageQueryOut.h
//  Bullseye
//
//  Created by Neil on 13/9/3.
//
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface VIPMessageQueryOut : NSObject<EncodeProtocol>{
    UInt16 count;
    UInt16 consultancyId;
    UInt8 pdaItemId;
    UInt16 askDate;
    UInt8 * type;
    UInt16 * beginSerial;
    UInt16 * endSerial;
    UInt8 * typeCount;
    UInt16 * serial;
    int size;
    int typeA;
    int typeB;
}

- (id)initWithConsultancyId:(UInt16)cId pdaItemId:(UInt8)pId askDate:(UInt16)d count:(UInt8)c type:(UInt8 *)t beginSerial:(UInt16 *)beginS endSerial:(UInt16 *)endS typeCount:(UInt8 *)typeC serial:(UInt16 *)s;

@end
