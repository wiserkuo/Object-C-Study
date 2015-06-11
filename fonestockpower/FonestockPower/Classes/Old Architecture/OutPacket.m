//
//  OutPacket.m
//  test4
//
//  Created by Yehsam on 2008/11/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "OutPacket.h"


@implementation OutPacket

@synthesize body;

- (id)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

- (void)dealloc{
	free(buffer);
}


- (void)attchBody:(NSObject <EncodeProtocol> *)obj
{	
	body = obj;
	
	// Check if the method is supported by the body object, call it if it support.
	if ([body respondsToSelector:@selector(getPacketSize)])
		bufferSize = [body getPacketSize]+sizeof(OutPacketHeader);
	
	buffer = malloc(bufferSize); 
}

- (void)encode:(NSObject *)data
{	
    if ([body respondsToSelector:@selector(encode:buffer:length:)]){
		[body encode:data buffer:buffer length:bufferSize];
    }
}


// Implementation of PacketProtocol.
//

- (UInt8 *)getBuffer
{
	return (UInt8 *)(buffer+byteSent);
}

// overrider buffer function
- (int)getBufferSize
{
	return(bufferSize-byteSent);
}

- (void)adjustBuffer:(int)sizechanged
{
	byteSent += sizechanged;
}

/**
 Get the packet type consist of message and command.
 */
- (UInt16)getPacketType
{
	OutPacketHeaderRef header = (OutPacketHeaderRef)buffer;
	UInt16 packetType = header->message;
	packetType = (packetType << 8) & ((UInt16)header->command & 0x00FF);
	return packetType;
}

- (UInt16)getPacketType2		//message type *100 + command type
{
	OutPacketHeaderRef header = (OutPacketHeaderRef)buffer;
	UInt16 packetType = header->message *100 + header->command;
	return packetType;
}

- (UInt8)msg {
    OutPacketHeaderRef header = (OutPacketHeaderRef)buffer;
    return header->message;
}

- (UInt8)cmd {
    OutPacketHeaderRef header = (OutPacketHeaderRef)buffer;
    return header->command;
}

@end
