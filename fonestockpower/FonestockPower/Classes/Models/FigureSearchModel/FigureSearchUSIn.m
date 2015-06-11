//
//  FigureSearchUSIn.m
//  WirtsLeg
//
//  Created by Connor on 13/11/20.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureSearchUSIn.h"
#import "FigureSearchUS.h"
@implementation FigureSearchUSIn
- (id)init {
    if (self = [super init]) {
        dataArray = [[NSMutableArray alloc] init];
        markPriceArray = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
	moreData = retcode;
    
	UInt8 *tmpPtr = body;
    
    UInt16 optionLength;
    optionLength = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt8 bitMask;
    bitMask = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    UInt16 trans_id;
    trans_id = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt16 status_code;
    status_code = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt16 content_length;
    content_length = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    
    sn = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    totalAmount = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    
    if (totalAmount == 0xFFFF) {
        return;
    }
    dataDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    
    dataAmount = *tmpPtr++;
    
    if (dataAmount) {
        for (int i = 0; i < dataAmount; i++) {
            
            UInt16 tmpSize=0;
            SymbolFormat1 *symbol = [[SymbolFormat1 alloc] initWithBuff:tmpPtr objSize:&tmpSize Offset:0];
            tmpPtr += tmpSize;
            [dataArray addObject:symbol];
            float value;
            //Price B_Value_format
            if ([CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:1] == 0) {
                // 2 Bytes
                bValueFormat1 * bValue = [[bValueFormat1 alloc]initWithBuff:tmpPtr objSize:&tmpSize Offset:0];
                bValue -> decimal = [CodingUtil getUint8FromBuf:tmpPtr Offset:1 Bits:1];
                bValue -> positive = [CodingUtil getUint8FromBuf:tmpPtr Offset:2 Bits:1];
                bValue -> dataValue = [CodingUtil getUint16FromBuf:tmpPtr Offset:3 Bits:13];
                tmpPtr += 2;
                if (bValue->positive == 0) {
                    value = bValue -> dataValue;
                }else{
                    value = -1 * bValue->dataValue;
                }
                if (bValue -> decimal == 1) {
                    value = value/100;
                }
                
            } else if ([CodingUtil getUint8FromBuf:tmpPtr Offset:1 Bits:1] == 0) {
                // 4 Bytes
                bValueFormat2 * bValue = [[bValueFormat2 alloc]initWithBuff:tmpPtr objSize:&tmpSize Offset:0];
                bValue -> decimal = [CodingUtil getUint8FromBuf:tmpPtr Offset:2 Bits:2];
                bValue -> positive = [CodingUtil getUint8FromBuf:tmpPtr Offset:4 Bits:1];
                bValue -> dataValue = [CodingUtil getUint32FromBuf:tmpPtr Offset:5 Bits:27];
                tmpPtr += 4;
                
                if (bValue->positive == 0) {
                    value = bValue -> dataValue;
                }else{
                    value = -1 * bValue->dataValue;
                }
                if (bValue -> decimal == 1) {
                    value = value/100;
                }else if (bValue -> decimal == 2){
                    value = value/1000;
                }else if (bValue -> decimal == 3){
                    value = value/10000;
                }
                
            } else {
                // 8 Bytes
                bValueFormat3 * bValue = [[bValueFormat3 alloc]initWithBuff:tmpPtr objSize:&tmpSize Offset:0];
                bValue -> decimal = [CodingUtil getUint8FromBuf:tmpPtr Offset:2 Bits:3];
                bValue -> type = [CodingUtil getUint8FromBuf:tmpPtr Offset:5 Bits:1];
                bValue -> exponent = [CodingUtil getUint8FromBuf:tmpPtr Offset:6 Bits:1];
                bValue -> positive = [CodingUtil getUint8FromBuf:tmpPtr Offset:7 Bits:1];
                
                if (bValue -> type == 0) {
                    bValue -> dataValue = [CodingUtil getUint64FromBuf:tmpPtr Offset:8 Bits:56];
                }else{
                    int pbcdValue = 0;
                    for (int x=1; x<15; x++) {
                        UInt64 newValue = [CodingUtil getUint64FromBuf:tmpPtr Offset:x+8 Bits:4];
                        pbcdValue = pbcdValue + newValue * pow(10, 14-x);
                        
                    }
                    bValue -> dataValue = pbcdValue;
                }
                
                if (bValue->positive == 0) {
                    value = bValue -> dataValue;
                }else{
                    value = -1 * bValue->dataValue;
                }
                if(bValue -> decimal !=0){
                    if (bValue -> exponent ==0) {
                        value = value * pow(10, bValue -> decimal);
                    }else{
                        value = value / pow(10, bValue -> decimal);
                    }
                }
                tmpPtr += 8;
            }
            [markPriceArray addObject:[NSNumber numberWithFloat:value]];
            
            UInt8 taCount = *tmpPtr++;
            
            for (int i = 0; i < taCount; i++) {
                
                // short string format
                UInt8 stringLen = *tmpPtr++;
                tmpPtr += stringLen;
                
                // B_Value_format
                if ([CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:1] == 0) {
                    // 2 Bytes
                    tmpPtr += 2;
                } else if ([CodingUtil getUint8FromBuf:tmpPtr Offset:1 Bits:1] == 0) {
                    // 4 Bytes
                    tmpPtr += 4;
                } else {
                    // 8 Bytes
                    tmpPtr += 8;
                }
            }
        }
    }
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FigureSearchUS * figureSearchUS = dataModel.figureSearchUS;
    
    if ([figureSearchUS respondsToSelector:@selector(callBackData:)]) {
        [figureSearchUS performSelector:@selector(callBackData:) onThread:dataModel.thread withObject:self waitUntilDone:NO];
    }
}
@end
