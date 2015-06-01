//
//  GetINIOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/11/18.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "GetINIOut.h"
#import "OutPacket.h"

@implementation GetINIOut

- (id)initWithDate:(UInt16)d SwitchINI:(UInt8)asFlag;
{
	if(self = [super init])
	{
		date = d;
		alertStockFlag = asFlag;
	}
	return self;	
}

- (int)getPacketSize{
	
	return 3;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr;
	tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 4;
	if(alertStockFlag == 0)
		phead->command = 18;
	else
		phead->command = 19;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr += sizeof(OutPacketHeader);
	
	[CodingUtil setUInt16:tmpPtr Value:date];
	tmpPtr += 2;
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"cn"]) {
		*tmpPtr++ = 3;		//簡體XML
    }else{
		*tmpPtr++ = 1;		//XML format
    }
	return YES;
}


@end
