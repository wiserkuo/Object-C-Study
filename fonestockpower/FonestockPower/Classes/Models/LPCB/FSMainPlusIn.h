//
//  FSMainPlusIn.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSNewsTitleDataIn.h"

@interface FSBrokerBranchByStockIn : NSObject<DecodeProtocol>
@end
@interface FSBrokerBranchByAnchorIn : NSObject<DecodeProtocol>
@end
@interface FSBrokerBranchDetailByAnchorIn : NSObject<DecodeProtocol>
@end
@interface FSBrokerBranchByBrokerIn : NSObject<DecodeProtocol>
@end
@interface FSMainBranchKLineIn : NSObject<DecodeProtocol>
@end
@interface FSOptionalMainIn : NSObject<DecodeProtocol>
@end





@interface BrokerBranchFormat1 : NSObject{
    
}

@property NSString *brokerBranchID;
@property FSBValueFormat *buyShare;
@property FSBValueFormat *sellShare;
@property FSBValueFormat *buyPrice;
@property FSBValueFormat *sellPrice;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset;
@end

@interface BrokerBranchFormat2 : NSObject{
    
}

@property SymbolFormat1 *symbolFormat1;
@property FSBValueFormat *buyAmount;
@property FSBValueFormat *sellAmount;
@property FSBValueFormat *dealAmount;
@property FSBValueFormat *buyPrice;
@property FSBValueFormat *sellPrice;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset;
@end


@interface BrokerBranchFormat3 : NSObject{
    
}

@property UInt16 dataDate;
@property FSBValueFormat *buyShare;
@property FSBValueFormat *sellShare;
@property FSBValueFormat *dealShare;
@property FSBValueFormat *buyPrice;
@property FSBValueFormat *sellPrice;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset;
@end

@interface BrokerBranchFormat4 : NSObject{
    
}
@property FSBValueFormat *dealShare;
@property FSBValueFormat *buyShare;
@property FSBValueFormat *sellShare;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset;
@end

@interface BrokerBranchFormat5 : NSObject{
    
}
@property UInt16 dataDate;
@property FSBValueFormat *offsetShare;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset;
@end

@interface BrokerBranchFormat6 : NSObject{
    
}
@property UInt16 dataDate;
@property FSBValueFormat *buyShare;
@property FSBValueFormat *sellShare;
@property FSBValueFormat *buyAmnt;
@property FSBValueFormat *sellAmnt;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset;
@end