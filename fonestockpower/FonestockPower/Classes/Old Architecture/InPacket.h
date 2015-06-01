//
//  InPacket.h
//  bullseye
//
//  Created by Yehsam on 2008/11/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "LoginInPacket.h"
#import "DecodeProtocol.h"
#import "PacketProtocol.h"

typedef struct _InPacketHeader {
	UInt8 escape;
	UInt8 message;
	UInt8 commodity[4];
	UInt8 type;
	UInt8 code;
	UInt8 size[2];
}InPacketHeader, *InPacketHeaderRef;


@interface InPacket : NSObject <PacketProtocol>
{
	NSObject <DecodeProtocol> *body;
	InPacketHeader header;
	UInt32 commodity;
	UInt8 *buffer;
	UInt8 retcode;
	int buffSize;
	int bytesRead;	
	int bodySize;
}

@property (nonatomic,retain) NSObject *body;

- (UInt8*) getHeader:(int*)psize;
- (UInt8*) getBody:(int*)psize;
- (void) parseHeader;
- (void) decode;
- (BOOL)isLast;

- (int)msg;
- (int)cmd;

@end
