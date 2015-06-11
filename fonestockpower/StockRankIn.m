//
//  StockRankIn.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/10/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "StockRankIn.h"

//#import "FSBValueFormat.h"

@implementation StockRankIn



-(id)init{
    if (self = [super init]) {
        stockDataArray = [[NSMutableArray alloc]init];
    }
    return self;

}

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode{
    UInt8 *tmpPtr = body;
    UInt8 subType = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    NSString *title = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    UInt16 mask = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt8 resultCount = [CodingUtil getUInt8:&tmpPtr needOffset:YES];

    for(int i = 0; i < resultCount; i++){
        //記錄上面欄位
        UInt8 *tmpTitle = tmpPtr;
        //記錄資料長度
        int dataLength = [CodingUtil getUInt8:&tmpTitle needOffset:YES];
        
        FSEmergingObject *emergingObj = [[FSEmergingObject alloc]init];
        UInt16 tmpSize = 0 ;
        emergingObj.retCode = retcode;
        emergingObj.subType = subType;
        emergingObj.title = title;
        emergingObj.mask = mask;
        emergingObj.resultCount = resultCount;
        emergingObj.securities = [[SymbolFormat1 alloc] initWithBuff:tmpTitle objSize:&tmpSize Offset:0];
        
        tmpTitle += tmpSize;
        if (emergingObj.subType == 5) {
            emergingObj.stockDividendDate = [CodingUtil getUInt16:&tmpTitle needOffset:YES];
            emergingObj.fieldId2 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId3 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId4 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.cashDividendDate = [CodingUtil getUInt16:&tmpTitle needOffset:YES];
            emergingObj.fieldId6 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId7 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.shareHolderMeetingDate = [CodingUtil getUInt16:&tmpTitle needOffset:YES];
            emergingObj.fieldId9 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.directorsDate = [CodingUtil getShortStringFormatByBuffer:&tmpTitle needOffset:YES];
            emergingObj.stockDividendDate2 = [CodingUtil getUInt16:&tmpTitle needOffset:YES];
            emergingObj.cashDividend = [CodingUtil getUInt16:&tmpTitle needOffset:YES];
            emergingObj.cashCapitalIncrease = [CodingUtil getUInt16:&tmpTitle needOffset:YES];
            emergingObj.fieldId14 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];

        }else{
            emergingObj.fieldId1 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId2 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId3 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId4 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId5 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId6 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId7 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId8 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId9 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId10 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId11 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId12 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId13 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId14 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId15 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
            emergingObj.fieldId16 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
        }

        
//        //成長能力
//
//        
//        //漲勢排行 , 新高新低排行 , 償債能力
//        if (subType == 9 || subType == 10 || subType == 19) {
//            emergingObj.fieldId1 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId2 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId3 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId4 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId5 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//        }
//        //營收排行
//        else if (subType == 16) {
//        //tmpId 是跳過不需要的欄位
//            tmpId1 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            tmpId2 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId1 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId2 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId3 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            tmpId3 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            tmpId4 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            tmpId5 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId4 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId5 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//        }
//        //獲利能力
//        else if (subType == 17){
//            emergingObj.fieldId1 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId2 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId3 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId4 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId5 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId6 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId7 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//        }
//        //經營能力 , 財務結構
//        else if (subType == 20 || subType == 21){
//            emergingObj.fieldId1 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId2 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId3 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//            emergingObj.fieldId4 = [[FSBValueFormat alloc]initWithByte:&tmpTitle needOffset:YES];
//        }
        
        
        [stockDataArray addObject:emergingObj];
        
        //dataLength 要加 1 byte 資料才正確;
        tmpPtr += dataLength + 1;
        
    }
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];

    if ([dataModel.emergingObj respondsToSelector:@selector(stockRankCallBack:)]) {
        [dataModel.emergingObj performSelector:@selector(stockRankCallBack:) onThread:dataModel.thread withObject:stockDataArray waitUntilDone:NO];
    }
    
}

@end
