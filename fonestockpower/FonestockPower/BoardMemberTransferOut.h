//
//  BoardMemberTransferOut.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoardMemberTransferOut : NSObject<EncodeProtocol>
{
    UInt32 securityNum;
    UInt8 top_n;				//要求回應比數, 0代表回應所有資料
    UInt16 startDate;
    UInt16 endDate;
    UInt16 lastModifiedDate;			//上次更新時間
}

- (id)initWithSecurityNum:(UInt32)cn Top_n:(UInt8)count start:(UInt16)sDate end:(UInt16)eDate modified:(UInt16)modifiedDate;

@end
