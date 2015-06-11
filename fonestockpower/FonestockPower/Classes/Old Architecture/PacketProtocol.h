//
//  PacketProtocol.h
//  bullseye
//
//  Created by johaiyu on 2008/11/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PacketProtocol

- (UInt8 *)getBuffer;
- (int)getBufferSize;
- (void)adjustBuffer:(int)sizechanged;

/**
	Get the type of a packet.
 
	The high byte contains message type of the packet.
	The low byte contains command type of the packet.
 */
- (UInt16)getPacketType;

@optional

- (UInt16)getPacketType2;		//message type *100 + command type

@end
