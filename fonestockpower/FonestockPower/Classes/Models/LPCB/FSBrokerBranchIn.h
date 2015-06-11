//
//  FSBrokerBranchIn.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBrokerBranchIn : NSObject<DecodeProtocol>{
    
}

@property NSMutableArray *brokerBranchAdd;
@property NSMutableArray *brokerBranchRemove;
@property UInt8 returnCode;
@property UInt16 date;

@end

@interface BrokerBranchNameFormat  : NSObject


@property NSString *brokerBranchID;
@property UInt16 brokerID;
@property NSString *name;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset;
@end
