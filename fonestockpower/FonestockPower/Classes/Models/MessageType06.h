//
//  MessageType06.h
//  Bullseye
//
//  Created by Yehsam on 2009/2/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageType06Param;
@interface MessageType06 : NSObject {
	MessageType06Param *messageType06Param;
}

+ (void) decodeType06:(UInt8*)body messageType06Param:(MessageType06Param*)mtParam Commodity:(UInt32)sn;

@end


@interface MessageType06Param : NSObject {
@public
	UInt32 commodityNo;
	UInt32 referencePrice;	//參考價（為絕對）
	UInt32 ceilingPrice;	//漲停價(相對於reference), 沒有漲跌停限制時, 填0 
	UInt32 floorPrice;		//跌停價(相對於reference), 沒有漲跌停限制時, 填0
	UInt32 preVolume;		//昨量 (commodity type 3為昨值)
	UInt16 date;
	//Commodity_type=4,5 
	UInt32 preOpenInterest;	//昨倉 
	//Commodity_type=2 (以下欄位先不傳送，等權證資料ｏｋ時，再實作！)
	UInt32 strikePrice;		//履約價 (相對於參考價)
	UInt32 conversionRate;	//行使比例
	UInt32 totalVolume;		//發行量
}

@end