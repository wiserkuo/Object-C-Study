//
//  OutPacket.h
//  test4
//
//  Created by Yehsam on 2008/11/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EncodeProtocol.h"
#import "PacketProtocol.h"

typedef struct _OutPackHeader{
	UInt8 escape;
	UInt8 message;
	UInt8 command;
	UInt8 size;
	UInt8 size_low;
}OutPacketHeader, *OutPacketHeaderRef;

@interface OutPacket : NSObject <PacketProtocol>
{
	NSObject <EncodeProtocol> *body;
	char *buffer;
	int bufferSize;
	int byteSent;
}

- (void)encode:(NSObject *)data;
- (void)attchBody:(NSObject <EncodeProtocol> *)body;

- (UInt8)msg;
- (UInt8)cmd;
@property (nonatomic,retain) NSObject *body;

@end
