//
//  FSDistributeIn.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/23.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSDistributeIn : NSObject<DecodeProtocol>{
@public
    UInt8 returnCode;	//1還有封包
    UInt8 dayType;		//0:單日,1:累計
    UInt8 dayCount;		//單日:前第幾日,累計:5,10,15
    UInt16 date;		//資料日期
    UInt16 startDate;	//統計起使日期
    UInt16 endDate;		//統計結束日期
    NSMutableArray *tdArray;
}

@end

@interface FSDistributeObj : NSObject

@property FSBValueFormat *price;
@property FSBValueFormat *volume;

@end