//
//  VIPSNQueryOut.h
//  Bullseye
//
//  Created by Neil on 13/8/30.
//
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface VIPSNQueryOut : NSObject<EncodeProtocol>{
    UInt8 count;
    UInt8 * days;
    UInt16 * consultancyId;
    UInt8 * pdaItemId;
}

- (id)initWithCount:(UInt8)c consultancyId:(UInt16*)cId pdaItemId:(UInt8*)pId days:(UInt8*)d;

@end
