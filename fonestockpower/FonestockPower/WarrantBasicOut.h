//
//  WarrantBasicOut.h
//  FonestockPower
//
//  Created by Kenny on 2014/11/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WarrantBasicOut : NSObject<EncodeProtocol>
{
    UInt32 securityNum;
    UInt16 blackMask;
}
- (id)initWithSecuity_num:(UInt32)num blockMask:(UInt16)mask;
@end
