//
//  SpecialStateOut.m
//  Bullseye
//
//  Created by Neil on 13/9/5.
//
//

#import "SpecialStateOut.h"
#import "OutPacket.h"


@implementation SpecialStateOut

-(id)initWithTimes:(UInt8)t status:(NSNumber *)s{
    
    if(self = [super init])
	{
        times = t;
        status = [s intValue];
        
    }
    return self;
}

-(int)getPacketSize{
    return 19;
}

-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 9;
	phead->command = 13;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer += sizeof(OutPacketHeader);
    
    char *tmpPtr = buffer;
    
    
    *tmpPtr++ = 1;//查詢stock status
    *tmpPtr++ = 0;//是否為第一次查詢
    [CodingUtil setUInt16:tmpPtr Value:0];//排名前n個,0=前500
    tmpPtr+=2;
    //fields bit mask
    *tmpPtr++ = (char)0x71;
    *tmpPtr++ = (char)0x01;
    *tmpPtr++ = (char)0x31;
    *tmpPtr++ = (char)0x87;
    *tmpPtr++ = (char)0x80;
    *tmpPtr++ = 2;//filter 個數
    //c:security type
    *tmpPtr++ = 'c';
    *tmpPtr++ = 1;
    *tmpPtr++ = 1;
    //d : stock status
    *tmpPtr++ = 'd';
    *tmpPtr++ = 1;
    *tmpPtr++ = status;
    //sort
    *tmpPtr++ = 1;
    *tmpPtr++ = 11;
    *tmpPtr = 0;
    
    
	return YES;
}

@end
