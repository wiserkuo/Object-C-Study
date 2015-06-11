//
//  InPacket.m
//  bullseye
//
//  Created by johaiyu on 2008/11/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "InPacket.h"
#import "InPacketFactory.h"


@implementation InPacket

@synthesize body;

// 封包初始化
- (id)init {
	if (self = [super init]) {
		buffer = nil;
		body = nil;
		buffSize = 1;       // 先給1 讀escape
		bytesRead = 0;      // 已讀bytes
	}
	return self;
}

- (void)dealloc {
	free(buffer);
}

// Implementation of Packet Protocol:
// - (UInt8 *)getBuffer;
// - (int)getBufferSize;
// - (void)adjustBuffer:(int)sizechanged;

- (UInt8 *)getBuffer {
	if (body != nil) {
		return buffer + bytesRead;
    }
	else {
        return (UInt8 *)&header + bytesRead;
    }
}

- (int)getBufferSize {
    assert((buffSize - bytesRead) >= 0); // 剩餘size不可能小於0
	return buffSize - bytesRead;
}

- (void)adjustBuffer:(int)sizechanged {
	bytesRead += sizechanged;      // 加上已讀取多少byte
	
	if (buffSize == bytesRead) {
		if (body)
		{
			// The whole packet had been read proceeding to decode.
		}
		else
		{
			BOOL canParseBody = NO;
			if(header.escape == 0x1C)		//FidaAuth的header格式 沒有commodity Num
			{
				if(buffSize == 1)
					buffSize = 5;
				else
				{
					header.type = header.commodity[0];
					header.size[0] = header.commodity[1];
					header.size[1] = header.commodity[2];
					header.code = 0;
					canParseBody = YES;
				}
			}
			
            else if (header.escape == 0x1B) {
				if (buffSize == 1)
					buffSize = 10;
				else
					canParseBody = YES;
			}
			// The whole header had been read.
			// Process the head and start reading the body
			if(canParseBody)
			{
				[self parseHeader];
				buffSize = bodySize;
				bytesRead = 0;
			}
		}
	}
}


- (UInt8*) getHeader:(int*)psize
{
	psize = (int*)sizeof(header);
    return (UInt8*)&header;	
}

- (UInt8*) getBody:(int*)psize
{
	psize = &bodySize;
	return buffer;
}

- (void)parseHeader {
	int message, command;
	message = header.message;
	command = header.type;
	retcode = header.code;

	int headerSize = 0;
	if (header.escape == 0x1B) {
		headerSize = 10;
		body = [[InPacketFactory createInPacketWithMessage:message Command:command] init];
//		if(message == 2 && command == 29)	//New Revenue
//			[body performSelector:@selector(setNewRevenue)];
	}
	else
	{
		headerSize = 5;
//		body = [[InPacketFactory createFidaAuthPacketWithMessage:message Command:command] init];
	}
	
	bodySize = [CodingUtil getUInt16:(char *)&(header.size)] - headerSize;
	
	commodity = [CodingUtil getUInt32:(char *)&(header.commodity)];
	assert(bodySize > 0);
	buffer = malloc(bodySize);
}

/**
	Get the packet type consist of message and type(command).
 */

- (UInt16)getPacketType
{
	UInt16 packetType = header.message;
	packetType = (packetType << 8) & ((UInt16)header.type & 0x00FF);
	return packetType;
}

- (UInt16)getPacketType2		//message type *100 + command type
{
	UInt16 packetType = header.message *100 + header.type;
	return packetType;
}

- (int)msg {
    return header.message;
}
- (int)cmd {
    return header.type;
}

- (void) decode
{
    if (body) {
        if ([body respondsToSelector:@selector(decode:size:commodity:retcode:)]) {
            [body decode:(UInt8*)buffer size:bodySize commodity:commodity retcode:retcode];
        }
    }
}


/**
	Check the return code of the header.
		0 : represents the last packet of the server's response.
		1 : more packets are coming in.
 */
- (BOOL)isLast
{
	if (header.code)
		return FALSE;
	else
		return TRUE;
}

@end
