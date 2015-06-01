//
//  MessageType12.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tick.h"
#import "DecodeProtocol.h"


@interface MessageType12 : NSObject <DecodeProtocol>{
	IndexTickParam *TickDataParam;
}

+ (void) decodeType12:(UInt8*)body TickParam:(IndexTickParam*)tickParam Offset:(int*)off;

@end
