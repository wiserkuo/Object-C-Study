//
//  PowerTwoPIn.m
//  FonestockPower
//
//  Created by CooperLin on 2014/12/16.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "PowerTwoPIn.h"

@implementation PowerTwoPIn

-(id)init
{
    if(self = [super init]){
        _stockData = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    NSLog(@"i had received some data");
    
    UInt8 *tmpPtr = body;
    // retcode == 1 代表後面還有資料
    // retcode == 0 結束
    int returnCode = (unsigned int)retcode;
    //用一個新的容器裝
    
    //broker branch data
    UInt16 brokerCount;
    
    identCode = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    _symbol = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    _startDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    _endDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    
    brokerCount = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    for(int i = 0; i < brokerCount; i++){
        BrokerBranchData *bbd = [[BrokerBranchData alloc] init];
        bbd.brokerBranchID = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
        bbd.stockHeadquarter = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
        bbd.sellOffset = [[FSBValueFormat alloc] initWithByte:&tmpPtr needOffset:YES];
//        if(i < 20){
            [_stockData addObject:bbd];
//        }
    }
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    if ([dataModel.powerSeriesObject respondsToSelector:@selector(powerppSeriesCallBackData:recv_complete:)]) {
        if(returnCode == 1){
            [dataModel.powerSeriesObject performSelector:@selector(powerppSeriesCallBackData:recv_complete:) withObject:self withObject:0];
        }else{
            [dataModel.powerSeriesObject performSelector:@selector(powerppSeriesCallBackData:recv_complete:) withObject:self withObject:[NSNumber numberWithBool:YES]];
        }
        //第兩個withObject輸入0 以外的數值怎麼在powerSeriesObject那邊收到的都會是yes呢
        //不過還好，輸入0 的話在powerSeriesObject那邊收到的是nil 也等於no 的意思
    }
}


@end

@implementation BrokerBranchData
@end
