//
//  MessageType09.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/7.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@class NewsContentFormat3;
@interface MessageType09 : NSObject <DecodeProtocol>{
	NewsContentFormat3 *newsContentFormat3;
}

@property (nonatomic,retain) NewsContentFormat3 *newsContentFormat3;

+ (int) decodeType09:(UInt8*)body NewsFormat3:(NewsContentFormat3*)newsFormat3;

@end
