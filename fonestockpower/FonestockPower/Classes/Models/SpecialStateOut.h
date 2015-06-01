//
//  SpecialStateOut.h
//  Bullseye
//
//  Created by Neil on 13/9/5.
//
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface SpecialStateOut : NSObject<EncodeProtocol>{
    UInt8 times;
    UInt8 status;
    char *fieldMask;
}

-(id)initWithTimes:(UInt8)t status:(NSNumber *)s;

@end
