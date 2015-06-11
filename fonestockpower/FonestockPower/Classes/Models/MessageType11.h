//
//  MessageType11.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tick.h"
#import "DecodeProtocol.h"

@interface MessageType11 : NSObject <DecodeProtocol>{
	EquityTickParam *TickDataParam;
}

+ (void) decodeType11:(UInt8*)body TickParam:(EquityTickParam*)tickParam Offset:(int*)off;

@end
