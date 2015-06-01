//
//  WarrantQueryOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/11.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "WarrantQueryOut.h"
#import "CodingUtil.h"
#import "OutPacket.h"
@implementation WarrantQueryOut

- (id)initWithIdentCodeSymbol:(NSString *)symbol function:(int)num
{
    if(self = [super init])
	{
		identCodeSymbol = symbol;
        functionID = num;
	}
	return self;
}
- (id)initWithFunction:(int)num rankingType:(int)rankingNum direction:(int)dir filltI:(int)type
{
    if(self = [super init])
	{
        functionID = num;
        rankingType = rankingNum;
        filltI = type;
        direction = dir;
	}
	return self;
}

- (int)getPacketSize
{
	int size = 0;
    identCodeSymbol = [identCodeSymbol stringByReplacingOccurrencesOfString:@" " withString:@":"];
    size += [identCodeSymbol length];	//扣掉空白 但 加上1個bytes的msgLen
	return 20+size;	//最後一個是fieldMask size
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 9;
	phead->command = 13;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer+=sizeof(OutPacketHeader);
	
	char *tmpPtr = buffer;
    
    *tmpPtr++ = functionID;//查詢stock status 3:權證搜尋
    
    if(functionID == 3){
        *tmpPtr++ = 0;
        [CodingUtil setUInt16:tmpPtr Value:0];//排名前n個,0=前500
        tmpPtr+=2;
        
        //fields bit mask
        *tmpPtr++ = (char)0x3F;
        *tmpPtr++ = (char)0xFF;
        *tmpPtr++ = (char)0xC1;
        *tmpPtr++ = (char)0x1D;
        *tmpPtr++ = (char)0x1F;
        *tmpPtr++ = (char)0xFC;
        
        
        *tmpPtr++ = 2;
        *tmpPtr++ = 'b';
        *tmpPtr++ = 1;
        
        identCodeSymbol = [identCodeSymbol stringByReplacingOccurrencesOfString:@" " withString:@":"];
        *tmpPtr++= [identCodeSymbol length];
        strncpy(tmpPtr, [identCodeSymbol cStringUsingEncoding:NSASCIIStringEncoding], [identCodeSymbol length]);
        tmpPtr += [identCodeSymbol length];
        
        *tmpPtr++ = 'c';
        *tmpPtr++ = 1;
        *tmpPtr++ = 2;
        
        *tmpPtr++ = 1;
        *tmpPtr++ = 11;
        *tmpPtr = 0;
    }else if(functionID == 7){
        
        *tmpPtr++ = 0;
        [CodingUtil setUInt16:tmpPtr Value:30];//排名前n個,0=前500
        tmpPtr+=2;
        
        //fields bit mask
        *tmpPtr++ = (char)0x39;
        *tmpPtr++ = (char)0xF3;
        *tmpPtr++ = (char)0x81;
        *tmpPtr++ = (char)0x11;
        *tmpPtr++ = (char)0x01;
        *tmpPtr++ = (char)0x07;
        *tmpPtr++ = (char)0x80;
        
        *tmpPtr++ = 1;
        
        *tmpPtr++ = 'i';
        *tmpPtr++ = filltI;
        
        *tmpPtr++ = 2;
        *tmpPtr++ = rankingType;
        *tmpPtr++ = direction;
    }else if(functionID == 6){
        *tmpPtr++ = 0;
        [CodingUtil setUInt16:tmpPtr Value:0];//排名前n個,0=前500
        tmpPtr+=2;
        
        //fields bit mask
        *tmpPtr++ = (char)0x31;
        *tmpPtr++ = (char)0xD5;
        *tmpPtr++ = (char)0xC0;
        
        
        *tmpPtr++ = 2;
        *tmpPtr++ = 'b';
        *tmpPtr++ = 1;
        
        identCodeSymbol = [identCodeSymbol stringByReplacingOccurrencesOfString:@" " withString:@":"];
        *tmpPtr++= [identCodeSymbol length];
        strncpy(tmpPtr, [identCodeSymbol cStringUsingEncoding:NSASCIIStringEncoding], [identCodeSymbol length]);
        tmpPtr += [identCodeSymbol length];
        
        *tmpPtr++ = 'c';
        *tmpPtr++ = 1;
        *tmpPtr++ = 2;
        
        *tmpPtr++ = 1;
        *tmpPtr++ = 11;
        *tmpPtr = 0;
    }else if(functionID == 5){
        *tmpPtr++ = 0;
        [CodingUtil setUInt16:tmpPtr Value:0];//排名前n個,0=前500
        tmpPtr+=2;
        
        //fields bit mask
        *tmpPtr++ = (char)0x31;
        *tmpPtr++ = (char)0xD5;
        *tmpPtr++ = (char)0xC0;
        
        
        *tmpPtr++ = 2;
        *tmpPtr++ = 'b';
        *tmpPtr++ = 1;
        
        identCodeSymbol = [identCodeSymbol stringByReplacingOccurrencesOfString:@" " withString:@":"];
        *tmpPtr++= [identCodeSymbol length];
        strncpy(tmpPtr, [identCodeSymbol cStringUsingEncoding:NSASCIIStringEncoding], [identCodeSymbol length]);
        tmpPtr += [identCodeSymbol length];
        
        *tmpPtr++ = 'c';
        *tmpPtr++ = 1;
        *tmpPtr++ = 2;
        
        *tmpPtr++ = 1;
        *tmpPtr++ = 11;
        *tmpPtr = 0;
    }else if(functionID == 4){
        *tmpPtr++ = 0;
        [CodingUtil setUInt16:tmpPtr Value:0];//排名前n個,0=前500
        tmpPtr+=2;
        
        //fields bit mask
        *tmpPtr++ = (char)0x31;
        *tmpPtr++ = (char)0xD5;
        *tmpPtr++ = (char)0xC0;
        
        
        *tmpPtr++ = 2;
        *tmpPtr++ = 'b';
        *tmpPtr++ = 1;
        
        identCodeSymbol = [identCodeSymbol stringByReplacingOccurrencesOfString:@" " withString:@":"];
        *tmpPtr++= [identCodeSymbol length];
        strncpy(tmpPtr, [identCodeSymbol cStringUsingEncoding:NSASCIIStringEncoding], [identCodeSymbol length]);
        tmpPtr += [identCodeSymbol length];
        
        *tmpPtr++ = 'c';
        *tmpPtr++ = 1;
        *tmpPtr++ = 2;
        
        *tmpPtr++ = 1;
        *tmpPtr++ = 11;
        *tmpPtr = 0;
    }

	return YES;
}

@end
