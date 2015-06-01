//
//  PowerTwoPIn.h
//  FonestockPower
//
//  Created by CooperLin on 2014/12/16.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PowerTwoPIn : NSObject <DecodeProtocol>{
@public
    UInt16 identCode;
}
@property (nonatomic, strong) NSString *symbol;
@property (nonatomic) UInt16 startDate;
@property (nonatomic) UInt16 endDate;

@property (nonatomic, strong) NSMutableArray *stockData;

@end


@interface BrokerBranchData : NSObject

@property (nonatomic, strong) NSString *brokerBranchID;
@property (nonatomic) UInt8 stockHeadquarter;
@property FSBValueFormat *sellOffset;

@end
