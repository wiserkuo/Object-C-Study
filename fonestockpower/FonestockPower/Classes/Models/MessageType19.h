//
//  MessageType19.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/19.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@class EsmPriceParam;
@interface MessageType19 : NSObject <DecodeProtocol>{
	EsmPriceParam *esmPriceParam;
@public
	UInt8 returnCode;
}

@property (readonly) EsmPriceParam *esmPriceParam;

@end



@interface EsmPriceParam : NSObject
{
	NSMutableArray *bidDataArray;	//存EsmBidAskParam
	NSMutableArray *askDataArray;
@public
	UInt8 priceType;		//送出的價格種類，分別為只有B, 只有S和B and S都送這三種	0 : B	1 : S	2 : B and S (for snapshot)
	double bidBestPrice;		//買進最佳價格
	UInt8 bidCounts;			//買進報價的券商數目
	double askBestPrice;		//賣出最佳價格
	UInt8 askCounts;			//賣出報價的券商數目

}

@property (readonly) NSMutableArray *bidDataArray;
@property (readonly) NSMutableArray *askDataArray;

- (id)initWithBuffer:(UInt8*)tmpPtr Offset:(int*)offset Size:(UInt16*)size Commodity:(UInt32)commodity;


@end


@interface EsmBidAskParam : NSObject
{
@public
	UInt16 brokerID;			// broker id (4位數字)
	UInt16 traderTelephoneID;
	double volume;				//券商提供的買價量
	UInt8 volumeUnit;
}

@end
