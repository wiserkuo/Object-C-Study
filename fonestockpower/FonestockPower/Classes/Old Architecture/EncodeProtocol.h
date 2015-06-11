//
//  EncodeProtocol.h
//  test4
//
//  Created by Yehsam on 2008/11/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#if defined BROKER_MEGA || defined BROKER_GOLDEN_GATE
	#define ORDER_CMD_TYPE 3
#else
	#define ORDER_CMD_TYPE 4
#endif

@protocol EncodeProtocol

- (BOOL)encode:(NSObject*)account buffer:(char*)buffer length:(int)len;
- (int)getPacketSize;

@optional
- (void)encodeToHttpBody;
- (void)encodeToYuantaBody;

@end