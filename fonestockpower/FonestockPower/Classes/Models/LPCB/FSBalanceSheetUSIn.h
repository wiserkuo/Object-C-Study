//
//  FSBalanceSheetUSIn.h
//  FonestockPower
//
//  Created by Connor on 14/9/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBalanceSheetUSIn : NSObject <DecodeProtocol>{
    @public
    NSMutableArray *balanceSheetArray;
    UInt32 commodityNum;
}


@end
