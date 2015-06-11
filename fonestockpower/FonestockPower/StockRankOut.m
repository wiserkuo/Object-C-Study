//
//  StockRankOut.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/10/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "StockRankOut.h"
#import "OutPacket.h"


@implementation StockRankOut


-(id)initWithSubType:(UInt8)st SectorCount:(UInt8)sc SectorId:(UInt16)si orderByFiledId:(UInt8)obfi direction:(UInt8)d requestCount:(UInt8)rq{
    if(self = [super init]) {
        subType = st;
        sectorCount = sc;
        sectorId = si;
        orderByFieldId = obfi;
        direction = d;
        requestCount = rq;

    }
    return self;
}
-(id)initWithSubType:(UInt8)st SectorCount:(UInt8)sc SectorId:(UInt16)si direction:(UInt8)d parameter1:(UInt8)p requestCount:(UInt8)rq{
    
    if(self = [super init]) {
        subType = st;
        sectorCount = sc;
        sectorId = si;
        direction = d;
        parameter1 = p;
        requestCount = rq;
        
    }
    return self;
}
-(id)initWithSubType:(UInt8)st SectorId:(UInt16)si orderByFiledId:(UInt8)obfi direction:(UInt8)d parameter1:(UInt8)p requestCount:(UInt8)rq;{
    
    if(self = [super init]) {
        subType = st;
        sectorId = si;
        orderByFieldId = obfi;
        direction = d;
        parameter1 = p;
        requestCount = rq;
        
    }
    return self;
}



-(int)getPacketSize{

    if(subType == 6 || subType == 10 || subType == 11 || subType == 13) {
        return 8;
    }else {
        return 7;
    }

}

-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    char *tmpPtr = buffer;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 10;
	phead->command = 32;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	tmpPtr+=sizeof(OutPacketHeader);
    *tmpPtr++ = subType;
    *tmpPtr++ = 1;   //sector count
    [CodingUtil setUInt16:tmpPtr Value:sectorId];
    tmpPtr += 2;
    
    //新高新低排行 || 均線交叉 || 技術指標
    if (subType == 10 || subType == 11 || subType == 13) {
        *tmpPtr++ = 0; //orderByFieldId 填 0 無作用欄位
        [CodingUtil setBufferr:direction Bits:1 Buffer:tmpPtr Offset:0];
        [CodingUtil setBufferr:1 Bits:1 Buffer:tmpPtr Offset:1];
        tmpPtr++;
        *tmpPtr++ = parameter1;
        
    //平均股利
    }else if (subType == 6){
        *tmpPtr++ = orderByFieldId;
        [CodingUtil setBufferr:direction Bits:1 Buffer:tmpPtr Offset:0];
        [CodingUtil setBufferr:1 Bits:1 Buffer:tmpPtr Offset:1];
        tmpPtr++;
        *tmpPtr++ = parameter1;
        
    //漲勢排行
    }else {
        *tmpPtr++ = orderByFieldId;
        [CodingUtil setBufferr:direction Bits:1 Buffer:tmpPtr Offset:0];
        tmpPtr++;
    }
    
    *tmpPtr++ = requestCount;
    
    return YES;
}

@end
