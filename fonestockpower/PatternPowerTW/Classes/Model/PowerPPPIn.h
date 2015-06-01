//
//  PowerPPPIn.h
//  FonestockPower
//
//  Created by CooperLin on 2014/11/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PowerPPPIn : NSObject <DecodeProtocol>{
@public
    UInt16 identCode;
    NSString *symbol;
    UInt16 startDate;
    UInt16 endDate;
    FSBValueFormat *price;
    
    NSMutableArray *buyData;
    NSMutableArray *sellData;
}

@end


@interface BuyStuff : NSObject

@property NSString *buyBrokerBranchId;
@property FSBValueFormat *buyShare;

@end

@interface SellStuff : NSObject

@property NSString *sellBrokerBranchId;
@property FSBValueFormat *sellShare;

@end


