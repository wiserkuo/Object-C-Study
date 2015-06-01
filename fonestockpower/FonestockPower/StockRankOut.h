//
//  StockRankOut.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/10/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface StockRankOut : NSObject <EncodeProtocol>{
    UInt8 subType;
    UInt8 sectorCount;
    UInt16 sectorId;
    UInt8 orderByFieldId;
    UInt8 direction;            //0, 遞增. 1, 遞減;
    UInt8 requestCount;         //要求回傳結果數0表示不限制, 但是maximum is 100
    UInt8 parameter1;

}

-(id)initWithSubType:(UInt8)st SectorCount:(UInt8)sc SectorId:(UInt16)si orderByFiledId:(UInt8)obfi direction:(UInt8)d requestCount:(UInt8)rq;
//-(id)initWithSubType:(UInt8)st SectorCount:(UInt8)sc SectorId:(UInt16)si orderByFieldId:(UInt8)obfi direction:(UInt8)d parameter1:(UInt8)p requestCount:(UInt8)rq;
-(id)initWithSubType:(UInt8)st SectorCount:(UInt8)sc SectorId:(UInt16)si  direction:(UInt8)d parameter1:(UInt8)p requestCount:(UInt8)rq;
-(id)initWithSubType:(UInt8)st SectorId:(UInt16)si orderByFiledId:(UInt8)obfi direction:(UInt8)d parameter1:(UInt8)p requestCount:(UInt8)rq;
@end
