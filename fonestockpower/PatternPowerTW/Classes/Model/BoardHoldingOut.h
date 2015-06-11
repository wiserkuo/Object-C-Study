//
//  BoardHoldingOut.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoardHoldingOut : NSObject <EncodeProtocol> {
    UInt32 _securityNum;
    UInt8 _queryType;
    UInt8 _count;
    UInt16 _recordDate;
}
- (instancetype)initWithSecurityNum:(UInt32)sn queryType:(UInt8)queryType count:(UInt8)count recordDate:(UInt16)recordDate;
@end
