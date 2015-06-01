//
//  FSSetFocusIn.m
//  FonestockPower
//
//  Created by Connor on 14/9/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSSetFocusIn.h"

@implementation FSSetFocusIn
- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
    UInt8 *ptr = body;
    
//    UInt32 timestamp = [CodingUtil getUInt32:ptr];
    ptr += 4;
    
//    UInt8 result = *ptr;
    
}
@end
