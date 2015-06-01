//
//  NewCompanyProfileOut.h
//  WirtsLeg
//
//  Created by Connor on 13/12/30.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewCompanyProfileOut : NSObject <EncodeProtocol> {
    UInt32 _securityNum;
    UInt8 _subType;
    UInt16 _recordDate;
}
- (instancetype)initWithSecurityNum:(UInt32)sn subType:(UInt8)subType recordDate:(UInt16)recordDate;
@end
