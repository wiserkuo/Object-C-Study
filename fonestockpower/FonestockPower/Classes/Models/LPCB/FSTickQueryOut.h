//
//  FSTickQueryOut.h
//  FonestockPower
//
//  Created by Connor on 14/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSTickQueryOut : NSObject <EncodeProtocol>

- (instancetype)initWithIdentCodeSymbol:(NSString *)identCodeSymbol;
- (instancetype)initWithIdentCodeSymbol:(NSString *)identCodeSymbol lastTickBTimeFormat:(FSBTimeFormat *)lastTickValue;
@end
