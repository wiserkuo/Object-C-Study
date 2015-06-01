//
//  KeepAliveIn.h
//  Bullseye
//
//  Created by Yehsam on 2008/12/8.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecodeProtocol.h"


@interface KeepAliveIn : NSObject <DecodeProtocol>{
	UInt8 startByte;
	UInt32 timeStamp;
	UInt16 Identifier;
    UInt8 code;
    NSString *message;
}

@end
