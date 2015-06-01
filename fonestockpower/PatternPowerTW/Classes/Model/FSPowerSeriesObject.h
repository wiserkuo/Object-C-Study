//
//  FSPowerSeriesObject.h
//  FonestockPower
//
//  Created by CooperLin on 2014/11/26.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PowerPPPIn;
@class PowerTwoPIn;

@protocol FSPowerSeriesDelegate;

@interface FSPowerSeriesObject : NSObject

@property (weak ,nonatomic) id <FSPowerSeriesDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *dateArray;

-(void)powerSeriesCallBackData:(PowerPPPIn *)data;
@property (nonatomic, strong) NSMutableArray *storeBuyBranchIdAndValue;
@property (nonatomic, strong) NSMutableArray *storeSellBranchIdAndValue;
//callBack method for 主力+++
-(void)powerppSeriesCallBackData:(PowerTwoPIn *)data recv_complete:(NSNumber *)retCode;
@property (nonatomic, strong) NSMutableArray *storeTempData;
@property (nonatomic, strong) NSMutableArray *storeBrokerBranchData;
//callBack method for 主力++

-(int)getBrokerBranchCount;
-(NSMutableArray *)getBrokerOptional;
-(NSMutableArray *)queryBrokerOptionalIDTable:(NSString *)target;

@end

@protocol FSPowerSeriesDelegate <NSObject>
@required
-(void)loadDidFinishWithData:(FSPowerSeriesObject *)data;
@end
//實作FSPowerSeriesDelegate 時必須要實作的method

@interface StoreBuyFormat : NSObject{
@public
    NSString *brokerBranchId;
    int value;
}
@end
//儲存買超券商資料，不應該將買超跟賣超寫分開（主力+++）

@interface StoreSellFormat : NSObject{
@public
    NSString *brokerBranchId;
    int value;
}
@end
//儲存賣超券商資料，不應該將買超跟賣超寫分開（主力+++）

@interface StoreBrokerBranch :NSObject

@property NSString *brokerBranchId;
@property UInt8 stockHeadquarter;
@property FSBValueFormat *sellOffset;

@end
//儲存券商資料（主力++)
