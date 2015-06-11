//
//  KeepAliveOut.h
//  Bullseye
//
//  Created by Yehsam on 2008/12/8.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EncodeProtocol.h"

@interface KeepAliveOut : NSObject <EncodeProtocol>{
	UInt32 timeStamp;
	UInt16 Identifier;
}

- (id)initWithTimeStamp:(UInt32)t identifier:(UInt16)i;

@end
