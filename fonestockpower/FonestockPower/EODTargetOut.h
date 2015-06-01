//
//  EODTargetOut.h
//  FonestockPower
//
//  Created by Kenny on 2014/6/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface EODTargetOut : NSObject <EncodeProtocol>
{
    UInt8 _serialNumber;
    UInt8 _patternCount;
    UInt8 *_patternName;
    NSString *_equation;
    UInt8 _reserved;
}

- (instancetype)initWithSerialNumber:(UInt8)serialNumber PatternCount:(UInt8)patternCount Equation:(NSString *)equation Reserved:(UInt8)reserved;

@end
