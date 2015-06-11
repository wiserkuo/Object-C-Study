//
//  MajorProductsOut.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MajorProductsOut : NSObject <EncodeProtocol> {
    UInt32 _securityNum;
    UInt8 _count;
    UInt16 _recordDate;
}
- (instancetype)initWithSecurityNum:(UInt32)sn count:(UInt8)count recordDate:(UInt16)recordDate;

@end
