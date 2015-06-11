//
//  FSSocketProc.h
//  FonestockPower
//
//  Created by Connor on 14/3/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSThreadProtocol.h"

@class OutPacket;

@interface FSSocketProc : NSThread <NSStreamDelegate, FSThreadProtocol> {
    NSInputStream *iStream;
    NSOutputStream *oStream;
}
- (void)connectWithHost:(NSString *)ipAddress Port:(UInt32)portNumber;
- (void)disconnect;
- (BOOL)sendPacket:(OutPacket *)packet;

@property (strong, nonatomic) NSString *ipAddress;
@property (unsafe_unretained, nonatomic) NSInteger portNumber;
@property (readonly, nonatomic) BOOL isConnected;
@property (readonly, nonatomic) BOOL isLoginStage;
@property (readonly, nonatomic) NSThread *thread;


@end
