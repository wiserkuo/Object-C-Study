//
//  BoardMemberTransferIn.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoardMemberTransferIn : NSObject <DecodeProtocol>{
@public
    NSMutableArray *holdDataArray;	//存BoardMemberHoldingParam
	UInt8 returnCode;
	UInt8 dataCount;			//回應的個數, 0代表無資料
	UInt16 modifiedDate;		//更新時間
	UInt32 commodityNum;
    int length;
}
@end

@interface BoardMemberTransferObject : NSObject
{
@public
    UInt16 dataDate;
    NSString *holderName;		//持股人名稱
	NSString *holderTitle;		//持股人職稱
	double applyShare;			//申讓張數
    double applyPrice;          //申讓價格
    double orgShare;            //原來持有張數
	UInt16 untransferDate;      //未轉讓日期
	double actualTransfer;      //申讓後持有張數
    NSString *transferMethod;
}
@end
