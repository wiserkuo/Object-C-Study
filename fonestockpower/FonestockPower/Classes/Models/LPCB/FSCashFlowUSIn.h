//
//  FSCashFlowUSIn.h
//  FonestockPower
//
//  Created by Derek on 2014/9/12.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSCashFlowUSIn : NSObject<DecodeProtocol>{
    @public
    NSMutableArray *cashFlowArray;
    UInt32 commodityNum;
}

@end
