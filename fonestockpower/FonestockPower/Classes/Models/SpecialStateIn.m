//
//  SpecialStateIn.m
//  Bullseye
//
//  Created by Neil on 13/9/5.
//
//

#import "SpecialStateIn.h"

@implementation SpecialStateIn

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    dataArray = [[NSMutableArray alloc]init];
    //dataArray內有securityInfoArray內有symbolData,securityNumber,fieldIdArray,fieldValueArray
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    
    UInt8 *tmpPtr;
	tmpPtr = body;
    retCode = retcode;
    
    functionId = *tmpPtr++;
    total = [CodingUtil getUInt16:tmpPtr];
	tmpPtr+=2;
        
    //股票總數
    for (int i=0; i<total; i++) {
        
        securityInfoArray = [[NSMutableArray alloc]init];
        fieldIdArray = [[NSMutableArray alloc]init];
        fieldValueArray = [[NSMutableArray alloc]init];
        
        UInt16 tmpSize;
        
        SymbolFormat1 * symbolData = [[SymbolFormat1 alloc] initWithBuff:tmpPtr objSize:&tmpSize Offset:0];
        symbolData->IdentCode[0] = *tmpPtr++;
        symbolData->IdentCode[1] = *tmpPtr++;
        
        
        symbolData -> symbolLength = *tmpPtr++;
        UInt16 length = symbolData -> symbolLength;
        symbolData->symbol = [[NSString alloc]initWithBytes:tmpPtr length:length encoding:NSUTF8StringEncoding];
        symbolNum = symbolData->symbol;
        tmpPtr+=symbolData->symbolLength;
        
        symbolData -> typeID = *tmpPtr++;
        
        symbolData -> fullNameLength = *tmpPtr++;
        UInt16 nameLength = symbolData -> fullNameLength;
        symbolData->fullName = [[NSString alloc]initWithBytes:tmpPtr length:nameLength encoding:NSUTF8StringEncoding];
        tmpPtr+=symbolData->fullNameLength;
        
        [securityInfoArray addObject:symbolData];
        //tmpPtr += tmpSize;
        
        securityNumber =[CodingUtil getUInt32:tmpPtr];
        [securityInfoArray addObject:[NSNumber numberWithUnsignedInt:securityNumber]];
        tmpPtr+=4;
        
        stringFormatCount = *tmpPtr++;
        
        //string format Data
        for (int j=0 ; j<stringFormatCount; j++) {
            //無資料
            stringFieldId = *tmpPtr++;
            [fieldIdArray addObject:[NSNumber numberWithInt:stringFieldId]];
            
            shortStringFormat * shortString = [[shortStringFormat alloc]initWithBuff:tmpPtr objSize:&tmpSize Offset:0];
            shortString -> length = *tmpPtr++;
            UInt8 dataLength = shortString -> length;
            shortString -> dataString = [[NSString alloc]initWithBytes:tmpPtr length:dataLength encoding:NSUTF8StringEncoding];
            tmpPtr+=dataLength;
            
            [fieldValueArray addObject:shortString];
        }
        
        bValueCount = *tmpPtr++;
        //B-value Data
        for (int j=0 ; j<bValueCount; j++) {
            //成交價,參考價,總量,最高價,最低價
            float value;
            bValueFieldId = *tmpPtr++;
            [fieldIdArray addObject:[NSNumber numberWithInt:bValueFieldId]];
            
            if ([CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:1] == 0) {
                //2 Bytes
                bValueFormat1 * bValue = [[bValueFormat1 alloc]initWithBuff:tmpPtr objSize:&tmpSize Offset:0];
                bValue -> decimal = [CodingUtil getUint8FromBuf:tmpPtr Offset:1 Bits:1];
                bValue -> positive = [CodingUtil getUint8FromBuf:tmpPtr Offset:2 Bits:1];
                bValue -> dataValue = [CodingUtil getUint16FromBuf:tmpPtr Offset:3 Bits:13];
                tmpPtr += 2;
                if (bValue->positive == 0) {
                    value = bValue -> dataValue;
                }else{
                    value = 0 - bValue->dataValue;
                }
                if (bValue -> decimal == 1) {
                    value = value/100;
                }
                
                [fieldValueArray addObject:[NSNumber numberWithFloat:value]];
            }else{
                if ([CodingUtil getUint8FromBuf:tmpPtr Offset:1 Bits:1] == 0) {
                    //4 Bytes
                    bValueFormat2 * bValue = [[bValueFormat2 alloc]initWithBuff:tmpPtr objSize:&tmpSize Offset:0];
                    bValue -> decimal = [CodingUtil getUint8FromBuf:tmpPtr Offset:2 Bits:2];
                    bValue -> positive = [CodingUtil getUint8FromBuf:tmpPtr Offset:4 Bits:1];
                    bValue -> dataValue = [CodingUtil getUint32FromBuf:tmpPtr Offset:5 Bits:27];
                    tmpPtr += 4;
                    
                    if (bValue->positive == 0) {
                        value = bValue -> dataValue;
                    }else{
                        value = 0 - bValue->dataValue;
                    }
                    if (bValue -> decimal == 1) {
                        value = value/100;
                    }else if (bValue -> decimal == 2){
                        value = value/1000;
                    }else if (bValue -> decimal == 3){
                        value = value/10000;
                    }

                    [fieldValueArray addObject:[NSNumber numberWithFloat:value]];
                }else{
                    //8 Bytes
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
                            int newValue = (int)[CodingUtil getUint64FromBuf:tmpPtr Offset:x+8 Bits:4];
                            pbcdValue = pbcdValue + newValue * pow(10, 14-x);
                            
                        }
                        bValue -> dataValue = pbcdValue;
                    }
                    
                    if (bValue->positive == 0) {
                        value = bValue -> dataValue;
                    }else{
                        value = 0 - bValue->dataValue;
                    }
                    if(bValue -> decimal !=0){
                        if (bValue -> exponent ==0) {
                            value = value * pow(10, bValue -> decimal);
                        }else{
                            value = value / pow(10, bValue -> decimal);
                        }
                    }
                    tmpPtr += 8;
                    [fieldValueArray addObject:[NSNumber numberWithFloat:value]];
                }
            }
        }
        bytesDataCount = *tmpPtr++;
        
        //Two bytes Data
        for (int j=0 ; j<bytesDataCount; j++) {
            //status code,suspen_start,suspen_end
            
            bytesDataFieldId = *tmpPtr++;
            [fieldIdArray addObject:[NSNumber numberWithInt:bytesDataFieldId]];
            
            bytesData= [CodingUtil getUInt16:tmpPtr];
            
//            for (int x =0; x<16; x++) {
//                NSLog(@"%d:-%d-",x,[CodingUtil getUint8FromBuf:tmpPtr Offset:x Bits:1]);
//            }
//            NSLog(@"-----------------");
            
            if (bytesDataFieldId != 27) {
                if ([CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:1]==0) {
                    NSString *icSymbol = [NSString stringWithFormat:@"TW %@", symbolNum];
                     PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:icSymbol];
                    
                    UInt8 marketId = portfolioItem != nil ? portfolioItem->market_id : 1;
                    
                    MarketInfoItem *market = [[[FSDataModelProc sharedInstance] marketInfo] getMarketInfo:marketId];
                    int openTime;
                    if (market == nil){
                        openTime =0;
                    }else{
                        openTime = market->startTime_1;

                    }
                    
                    //相對於開盤時間
                    bytesData = [CodingUtil getUint16FromBuf:tmpPtr Offset:1 Bits:9];
                    if ([CodingUtil getUint16FromBuf:tmpPtr Offset:1 Bits:9]!=0) {
                        bytesData = openTime + [CodingUtil getUint16FromBuf:tmpPtr Offset:1 Bits:9];
                    }
                    
                }else{
                    //絕對時間
                    bytesData = [CodingUtil getUint16FromBuf:tmpPtr Offset:1 Bits:12];
                }
            }
            if (bytesDataFieldId == 23) {
                bytesData = [CodingUtil getUint16FromBuf:tmpPtr Offset:13 Bits:3];
            }
            tmpPtr+=2;
            [fieldValueArray addObject:[NSNumber numberWithInt:bytesData]];
        }
        [securityInfoArray addObject:fieldIdArray];
        [securityInfoArray addObject:fieldValueArray];
        
        
        [dataArray addObject:securityInfoArray];
    }
    
    //DataModalProc *dataModal = [DataModalProc getDataModal];
    [dataModal.specialStateModel performSelector:@selector(backToControllerWithArray:) onThread:dataModal.thread withObject:dataArray waitUntilDone:NO];
}

@end
