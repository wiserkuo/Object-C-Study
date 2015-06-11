//
//  WarrantHistoryOut.h
//  FonestockPower
//
//  Created by Kenny on 2014/11/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WarrantHistoryOut : NSObject<EncodeProtocol>
{
    UInt32 securityNum;
    UInt16 count;
    UInt8 queryType;
}
- (id)initWithSecuity_num:(UInt32)num queryType:(UInt8)type dataCount:(UInt16)dCount;
@end
