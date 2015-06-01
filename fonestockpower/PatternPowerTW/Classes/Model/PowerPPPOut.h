//
//  PowerPPPOut.h
//  FonestockPower
//
//  Created by CooperLin on 2014/11/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PowerPPPOut : NSObject<EncodeProtocol>

//for PowerPPPViewController and PowerTwoPViewController

-(id)initWithPowerPPP:(UInt16)ic :(NSString *)sl :(UInt32)p :(UInt16)d :(UInt16)sd :(UInt16)ed :(UInt8)c;

-(id)initWithPowerPP:(UInt16)ic :(NSString *)sl :(UInt16)d :(UInt16)sd :(UInt16)ed;

@end
