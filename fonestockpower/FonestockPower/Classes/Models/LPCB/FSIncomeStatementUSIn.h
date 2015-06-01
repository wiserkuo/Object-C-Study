//
//  FSIncomeStatementUSIn.h
//  FonestockPower
//
//  Created by Derek on 2014/9/12.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSIncomeStatementUSIn : NSObject<DecodeProtocol>{
    @public
    NSMutableArray *incomeStatementArray;
    UInt32 commodityNum;

}

@end
