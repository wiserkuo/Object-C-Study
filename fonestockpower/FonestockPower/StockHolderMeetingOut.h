//
//  StockHolderMeetingOut.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockHolderMeetingOut : NSObject <EncodeProtocol>{
    UInt32 commodityNum;
	UInt8 queryType;
    UInt16 pdaDate;
}
- (id)initWithCommodityNum:(UInt32)num QueryType:(UInt8)type RecordDate:(UInt16)date;
@end
