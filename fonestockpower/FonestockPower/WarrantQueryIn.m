//
//  WarrantQueryIn.m
//  Bullseye
//
//  Created by Yehsam on 2009/6/11.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "WarrantQueryIn.h"
#import "CodingUtil.h"

@implementation WarrantQueryIn

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
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
        
        securityNumber = [CodingUtil getUInt32:tmpPtr];
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
            bValueFieldId = *tmpPtr++;
            [fieldIdArray addObject:[NSNumber numberWithInt:bValueFieldId]];
            [fieldValueArray addObject:[NSNumber numberWithDouble:[[FSBValueFormat alloc] initWithByte:&tmpPtr needOffset:YES].calcValue]];
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
            
            if (bytesDataFieldId != 27 && bytesDataFieldId != 7 && bytesDataFieldId != 15) {
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
            if (bytesDataFieldId == 15){
                UInt8 first = [CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:4];
                UInt8 second = [CodingUtil getUint8FromBuf:tmpPtr Offset:4 Bits:4];
                UInt8 third = [CodingUtil getUint8FromBuf:tmpPtr Offset:8 Bits:4];
                if(first == 0){
                    first = 3;
                }
                if(second == 0){
                    second = 3;
                }
                if(third == 0){
                    third = 3;
                }
                bytesData = [[NSString stringWithFormat:@"%d%d%d", first, second, third]intValue];
            }
            tmpPtr+=2;
            [fieldValueArray addObject:[NSNumber numberWithInt:bytesData]];
        }
        [securityInfoArray addObject:fieldIdArray];
        [securityInfoArray addObject:fieldValueArray];
    
        
        [dataArray addObject:securityInfoArray];
    }
    //送出在這
    //權證搜尋
    if(functionId == 3){
        [dataModal.warrant performSelector:@selector(warrantSearchDataCallBack:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
        //權證排行
    }else if(functionId == 7){
        [dataModal.warrant performSelector:@selector(warrantRankingDataCallBack:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
        //對比分析
    }else if(functionId == 6){
        [dataModal.warrant performSelector:@selector(warrantComparativeDataCallBack:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
    }else if(functionId == 5){
        [dataModal.warrant performSelector:@selector(warrantSpreadsDataCallBack:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
    }else if(functionId == 4){
        [dataModal.warrant performSelector:@selector(warrantTQuotedDataCallBack:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
    }
}
@end

@implementation FieldMaskParam

@synthesize shortString;

- (id) init
{
	if(self = [super init])
	{
	}
	return self;
}

@end


@implementation SecurityQueryParam

@synthesize securityInfo;
@synthesize fieldMaskArray;
@synthesize compareString;

- (id)initWithBuffer:(UInt8*)tmpPtr Offset:(int*)offset SymbolSize:(UInt16*)size;
{
	if(self = [super init])
	{
		securityInfo = [[SymbolFormat1 alloc] initWithBuff:tmpPtr objSize:size Offset:*offset];
		fieldMaskArray = [[NSMutableArray alloc] init];
	}
	return self;
}

@end
