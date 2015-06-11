//
//  VIPSNQueryIn.h
//  Bullseye
//
//  Created by Neil on 13/8/30.
//
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface VIPSNQueryIn : NSObject<DecodeProtocol>{
@public
    UInt16 count;
    UInt8 retCode;
    
    UInt16 * consultancyId;
    UInt8 * pdaItemId;
    UInt16 * date;
    
    UInt16 * year;
	UInt8 * month;
	UInt8 * day;
    UInt16 * maxSerial;
    
    
}

@end
