//
//  BoardMemberHoldingOut.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoardMemberHoldingOut : NSObject<EncodeProtocol>
{
    UInt32 securityNum;
    UInt8 counts;				//要求回應比數, 0代表回應所有資料
    UInt16 recordDate;			//上次更新時間
}

- (id)initWithSecurityNum:(UInt32)cn RecordDate:(UInt16)rd Counts:(UInt8)c;

@end
