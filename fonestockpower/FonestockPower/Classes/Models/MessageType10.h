//
//  MessageType10.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecodeProtocol.h"
#import "Tick.h"

@interface MessageType10 : NSObject <DecodeProtocol>{
	EquityTickParam *TickDataParam;
}

+ (void) decodeType10:(UInt8*)body TickParam:(EquityTickParam*)tickParam Offset:(int*)off;

@end
