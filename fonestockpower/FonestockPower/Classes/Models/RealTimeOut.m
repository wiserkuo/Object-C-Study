//
//  RealTimeOut.m
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "RealTimeOut.h"
#import "OutPacket.h"

@implementation RealTimeOut

- (id)initWithSectorArray:(NSMutableArray *)secArray SearchArray:(NSMutableArray *)array SortingArray:(NSMutableArray *)sArray Size:(int)size Update:(int)u{
    if(self = [super init])
	{
        searchArray = [[NSMutableArray alloc]init];
        sortingArray = [[NSMutableArray alloc]init];
        sectorArray = [[NSMutableArray alloc]init];
        
        searchSize = size;
        update = u;
        searchArray = array;
        sortingArray = sArray;
        sectorArray = secArray;

    }
    return self;
}

-(int)getPacketSize{
    return 18+searchSize;
}

-(BOOL)encode:(NSObject *)account buffer:(char *)buffer length:(int)len{
    
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 9;
	phead->command = 13;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer += sizeof(OutPacketHeader);
    
    char *tmpPtr = buffer;
    
    
    *tmpPtr++ = 2;//查詢market mover(即時排行)
//    *tmpPtr++ = 0;//是否為第一次查詢
    *tmpPtr++ = update;
    [CodingUtil setUInt16:tmpPtr Value:80];//排名前n個,0=前500
    tmpPtr+=2;
    //fields bit mask
    *tmpPtr++ = (char)0x7D;
    *tmpPtr++ = (char)0x01;
    *tmpPtr++ = (char)0x77;
    *tmpPtr++ = (char)0x41;
    *tmpPtr++ = (char)0x01;
    *tmpPtr++ = (char)0x01;
    *tmpPtr++ = (char)0xD0;
    
    if ([searchArray count] != 0) {
        *tmpPtr++ = 3;//filter 個數
    }else{
        *tmpPtr++ = 2;//filter 個數
    }
    
    
    //a:sector
    *tmpPtr++ = 'a';
    *tmpPtr++ = [(NSNumber *)[sectorArray objectAtIndex:0]intValue];
    [CodingUtil setUInt16:tmpPtr Value:[(NSNumber *)[sectorArray objectAtIndex:1]intValue]];
    tmpPtr+=2;
    
    //c:security type
    *tmpPtr++ = 'c';
    *tmpPtr++ = 1;
    *tmpPtr++ = 1;
    
    if ([searchArray count]!= 0) {
        //NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        //for (int i =0; i<[searchArray count]; i++) {
            
            int filter = [(NSNumber *)[searchArray objectAtIndex:0]intValue];
            
            
            if (filter == 101) {//e:瞬間巨量
                *tmpPtr++ = 'e';
                [CodingUtil setUInt16:tmpPtr Value:[(NSNumber *)[searchArray objectAtIndex:1]intValue]];
                tmpPtr+=2;
                [CodingUtil setUInt16:tmpPtr Value:[(NSNumber *)[searchArray objectAtIndex:2]intValue]];
                tmpPtr+=2;
            }else if (filter == 102){//f:開高走低或開低走高
                *tmpPtr++ = 'f';
                *tmpPtr++ = [(NSNumber *)[searchArray objectAtIndex:1]intValue];
            }else if (filter == 103){//g:連續買單或連續賣單
                *tmpPtr++ = 'g';
                *tmpPtr++ = [(NSNumber *)[searchArray objectAtIndex:1]intValue];
                *tmpPtr++ = [(NSNumber *)[searchArray objectAtIndex:2]intValue];
            }else if (filter == 104){//h:瞬間拉抬或瞬間殺盤
                *tmpPtr++ = 'h';
                *tmpPtr++ = [(NSNumber *)[searchArray objectAtIndex:1]intValue];
                [CodingUtil setUInt16:tmpPtr Value:[(NSNumber *)[searchArray objectAtIndex:2]intValue]];
                tmpPtr+=2;
            }
        
    }
    
    //sort
    *tmpPtr++ = 1;
    *tmpPtr++ = [(NSNumber *)[sortingArray objectAtIndex:0]intValue];
    *tmpPtr = [(NSNumber *)[sortingArray objectAtIndex:1]intValue];
    
    
////////////////////////////////////////////////////////////
//    *tmpPtr++ = 2;//filter
//    //a:sector
//        *tmpPtr++ = 'a';
//        *tmpPtr++ = 1;
//    [CodingUtil setUInt16:tmpPtr Value:21];//排名前n個,0=前500
//    tmpPtr+=2;
//        //*tmpPtr++ = 21;
//    //c:security type
//        *tmpPtr++ = 'c';
//        *tmpPtr++ = 1;
//        *tmpPtr++ = 1;
//    
//    *tmpPtr++ = 1;
//    *tmpPtr++ = 11;
//    *tmpPtr = 0;
	return YES;
}

@end
