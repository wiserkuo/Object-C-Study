//
//  FSMainBargainingModel.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSMainPlusIn.h"


@interface FSMainBargaining : NSObject{
    id notifyObj;
}

-(void)mainBargainingChipCallBack:(NSMutableArray *)array;

-(void)setTarget:(id)obj;
@end

@interface FSMainBargainingChip : NSObject

@property UInt16 startDate;
@property UInt16 endDate;
@property UInt8 dataType;
@property SymbolFormat1 *symbol;
@property FSBValueFormat *buyShare;
@property FSBValueFormat *sellShare;
@property FSBValueFormat *avgPrice;
@property FSBValueFormat *changePercentage;
@property FSBValueFormat *avgVolume;
@property FSBValueFormat *buyAvgPrice;
@property FSBValueFormat *sellAvgPrice;
@property FSBValueFormat *data;

@end

@interface FSBrokerBranchByStock : NSObject

@property UInt16 identCode;
@property NSString *symbol;
@property UInt16 startDate;
@property UInt16 endDate;
@property FSBValueFormat *dealVolume;
@property BrokerBranchFormat1 *brokerBranchData;

@end

@interface FSBrokerBranchByAnchor : NSObject

@property UInt16 identCode;
@property NSString *symbol;
@property NSString *brokerBranchId;
@property BrokerBranchFormat3 *brokerBranchData;

@end

@interface FSBrokerBranchDetailByAnchor : NSObject

@property UInt16 identCode;
@property NSString *symbol;
@property NSString *brokerBranchId;
@property UInt16 dataDate;
@property FSBValueFormat *dealVolume;
@property BrokerBranchFormat4 *brokerBranchData;

@end

@interface FSBrokerBranchByBroker : NSObject

@property NSString *brokerBranchId;
@property UInt16 startDate;
@property UInt16 endDate;
@property BrokerBranchFormat2 *brokerBranchData;

@end

@interface FSMainBranchKLine : NSObject

@property UInt16 identCode;
@property NSString *symbol;
@property NSString *brokerBranchId;
@property double offsetShareTotal;
@property BrokerBranchFormat5 *brokerBranchData5;
@property BrokerBranchFormat6 *brokerBranchData6;

@end

@interface FSMainBranchKLineNew : NSObject

@property UInt16 identCode;
@property NSString *symbol;
@property NSString *brokerBranchId;
@property double offsetShareTotal;
@property BrokerBranchFormat5 *brokerBranchData5;
@property BrokerBranchFormat6 *brokerBranchData6;

@end

@interface FSBrokerOptional : NSObject

@property UInt16 startDate;
@property UInt16 endDate;
@property UInt8 idCount;
@property NSString *brokerBranchId;
@property BrokerBranchFormat2 *brokerBranchData;

@end

@interface FSBrokerBranchByStockLeft : NSObject

@property UInt16 identCode;
@property NSString *symbol;
@property UInt16 startDate;
@property UInt16 endDate;
@property FSBValueFormat *dealVolume;
@property BrokerBranchFormat1 *brokerBranchData;

@end

@interface FSBrokerBranchByStockRight : NSObject

@property UInt16 identCode;
@property NSString *symbol;
@property UInt16 startDate;
@property UInt16 endDate;
@property FSBValueFormat *dealVolume;
@property BrokerBranchFormat1 *brokerBranchData;

@end