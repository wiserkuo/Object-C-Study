//
//  BoardMemberHoldingIn.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoardMemberHoldingIn : NSObject<DecodeProtocol>{
@public
    NSMutableDictionary *dict;
    NSMutableArray *holdDataArray;	//存BoardMemberHoldingParam
	UInt8 returnCode;
	UInt8 dataCount;			//回應的個數, 0代表無資料
	UInt16 modifiedDate;		//更新時間
	UInt16 dataDate;			//資料時間 (無資料不回應此欄位)
	UInt32 commodityNum;
    
}
@end

@interface BoardMemberHoldingObject : NSObject
{
@public
    UInt16 date;
    NSString *holderName;		//持股人名稱
	NSString *holderTitle;		//持股人職稱
	double holderShare;			//持股數
	UInt8 holderShareUnit;
	double holderShareRatio;	//持股比例 (4位小數)
	UInt8 holderShareRatioUnit;
}
@end
