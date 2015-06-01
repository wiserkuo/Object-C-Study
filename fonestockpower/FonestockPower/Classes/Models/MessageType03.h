//
//  MessageType03.h
//  Bullseye
//
//  Created by Yehsam on 2009/2/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface MessageType03 : NSObject <DecodeProtocol>{
	UInt32 securityNO;
	NSMutableArray *BAArray;
}

@property (nonatomic,retain) NSMutableArray *BAArray;
@property (nonatomic,readonly) UInt32 securityNO;

+ (void) decodeType03:(UInt8*)body Array:(NSMutableArray*)tmpArray;

@end
