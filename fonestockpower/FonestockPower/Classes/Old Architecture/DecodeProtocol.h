//
//  DecodeProtocol.h
//  test4
//
//  Created by Yehsam on 2008/11/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DecodeProtocol

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8) retcode;

@end


@protocol OrderDecodeProtocol

- (void)decode:(UInt8*)body size:(int)size retcode:(UInt8) retcode;

@optional
- (void)decodeByHttp:(UInt8*)body;
- (void)decodeYuantaByData:(NSData*)body;
- (void)decodeYuantaByBuffer:(UInt8*)body BodyLen:(int)length;

@end
