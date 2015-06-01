//
//  TechOut.h
//  FonestockPower
//
//  Created by Kenny on 2014/12/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TechOut : NSObject<EncodeProtocol>
{
    NSString *_identCodeSymbol;
    UInt32 _securityNum;
    UInt8 _dataType;
    UInt8 _commodityType;
    UInt8 _queryType;
    UInt16 _dataCount;
    UInt16 _startDate;
    UInt16 _endDate;
}
-(id)initIdentCodeSymbol:(NSString *)identCodeSymbol dataType:(UInt8)dataType commodityType:(UInt8)commodityType startDate:(UInt16)startDate endDate:(UInt16)endDate;
-(id)initWithIdentCodeSymbol:(NSString *)identCodeSymbol dataType:(UInt8)dataType commodityType:(UInt8)commodityType count:(UInt16)count;
@end
