//
//  FSMainPlusOut.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

//Broker Branch B/S by Stock (Msg=10, Cmd=35)
@interface BrokerBranchByStockOut : NSObject<EncodeProtocol>{

    NSString *symbol;
    UInt16 days;
    UInt16 startDate;
    UInt16 endDate;
    UInt8 sortType;
    UInt8 count;
}

-(id)initWithSymbol:(NSString *)s days:(UInt16)d startDate:(UInt16)sD endDate:(UInt16)eD sortType:(UInt8)sT count:(UInt8)c;
-(id)initWithSymbol:(NSString *)s days:(UInt16)d sortType:(UInt8)sT count:(UInt8)c;

@end

// Broker Branch B/S by Anchor (Msg=10, Cmd=36)
@interface BrokerBranchByAnchorOut : NSObject<EncodeProtocol>{
    
    NSString *symbol;
    NSString *brokerBranchId;
    UInt16 count;
    UInt16 startDate;
    UInt16 endDate;
}

-(id)initWithSymbol:(NSString *)s brokerBranchID:(NSString *)bID count:(UInt16)c startDate:(UInt16)sD endDate:(UInt16)eD;
-(id)initWithSymbol:(NSString *)s brokerBranchID:(NSString *)bID count:(UInt16)c;
@end

//Broker Branch B/S Detail by Anchor (Msg=10, Cmd=37)
@interface BrokerBranchDetailByAnchorOut : NSObject<EncodeProtocol>{
    
    NSString *symbol;
    NSString *brokerBranchId;
    UInt16 dataDate;
}

-(id)initWithSymbol:(NSString *)s brokerBranchID:(NSString *)bID dataDate:(UInt16)dD;
@end

//Broker Branch B/S by Broker (Msg=10, Cmd=38)
@interface BrokerBranchByBrokerOut : NSObject<EncodeProtocol>{
    
    NSString *brokerBranchId;
    UInt16 days;
    UInt16 startDate;
    UInt16 endDate;
    UInt8 sortType;
    
}
-(id)initWithBrokerBranchId:(NSString *)bBId days:(UInt16)d startDate:(UInt16)sD endDate:(UInt16)eD sortType:(UInt8)st;
-(id)initWithBrokerBranchId:(NSString *)bBId days:(UInt16)d sortType:(UInt8)st;

@end

//主力分公司K線查詢 (msg_id=10, cmd_id=43)
@interface MainBranchKLineOut : NSObject<EncodeProtocol>{

    NSString *symbol;
    NSString *brokerBranchId;
    UInt8 dataType;
    UInt16 count;
    UInt16 startDate;
    UInt16 endDate;
    
}

-(id)initWithSymbol:(NSString *)s brokerBranchIdD:(NSString *)bBId dataType:(UInt8)dT count:(UInt8)c startDate:(UInt16)sD endDate:(UInt16)eD;
@end

//自選主力進出表 (msg_id=10, cmd_id=44)
@interface OptionalMainOut : NSObject<EncodeProtocol>{
    
    UInt8 idCount;
    NSArray *brokerBranchId;
    UInt16 days;
    UInt16 startDate;
    UInt16 endDate;
    UInt8 count;
    UInt8 sortType;
    
}

//@property NSArray *brokerBranchId;

-(id)initWithBrokerBranchId:(NSArray *)bBId days:(UInt16)d startDate:(UInt16)sD endDate:(UInt16)eD count:(UInt8)c sortType:(UInt8)sT;

-(id)initWithidBrokerBranchId:(NSArray *)bBId days:(UInt16)d count:(UInt8)c sortType:(UInt8)sT;
@end
