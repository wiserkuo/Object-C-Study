//
//  FSSetFocusOut.h
//  FonestockPower
//
//  Created by Connor on 14/9/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FSSetFocusType) {
    FSSetFocusTypeTick = 1,
    FSSetFocusTypeBA = 2,
    FSSetFocusTypeTickAndBA = 3
};

typedef NS_ENUM(NSUInteger, FSSetFocusOperate) {
    FSSetFocusOperateClear = 0,
    FSSetFocusOperateReplace = 1
};

@interface FSSetFocusOut : NSObject <EncodeProtocol>
- (instancetype)initWithFocusType:(FSSetFocusType)focusType queryType:(FSSetFocusOperate)focusOperate timestamp:(UInt32)timestamp securityNumbers:(NSArray *)securityNumbers;
@end
