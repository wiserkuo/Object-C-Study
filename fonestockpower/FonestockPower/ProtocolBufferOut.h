//
//  ProtocolBufferOut.h
//  FonestockPower
//
//  Created by CooperLin on 2015/1/7.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProtocolBufferOut : NSObject <EncodeProtocol>

-(instancetype)initWithUpStream:(NSData *)inPutData;

@end
