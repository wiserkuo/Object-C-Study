//
//  BoardHoldingIn.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoardHoldingIn : NSObject <DecodeProtocol>{
@public
    UInt32 commodityNum;
    UInt8 returnCode;
    NSMutableArray *dataArray;
    UInt8 dataType;
	UInt8 dataCount;			//回應的個數, 0代表無資料
}
@end

@interface BoardHoldingObject : NSObject{
@public
    UInt16 recordDate;
	double holdRatio;
    double offsetRatio;
    double pledgeVolume;
    double pledgeRatio;
}
@end
