//
//  FSDistributeOut.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/23.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSDistributeOut : NSObject<EncodeProtocol>{

    NSString *identCodeSymbol;
    UInt8 type;
    UInt8 number;
    UInt16 date;
}

- (id)initWithOneDayIdentCodeSymbol:(NSString *)iD number:(UInt8)n date:(UInt16)d;

- (id)initWithAddDayIdentCodeSymbol:(NSString *)iD number:(UInt8)n date:(UInt16)d;

@end
