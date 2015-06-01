//
//  MajorProductsIn.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MajorProductsIn : NSObject <DecodeProtocol>{
@public
    UInt32 commodityNum;
    UInt8 returnCode;
    NSMutableArray *dataArray;
	UInt8 dataCount;			//回應的個數, 0代表無資料
    UInt16 recordDate;
}
@end
@interface MajorProductsObject : NSObject{
@public
	NSString *productName;
	double revRate;
    double revUnit;
}
@end