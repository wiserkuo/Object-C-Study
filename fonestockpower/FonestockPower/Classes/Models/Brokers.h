//
//  Brokers.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/12.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BrokersByStockIn, BrokersByBrokerIn, BrokersByAnchorIn, BrokersFormat1, BrokersFormat2, BrokersFormat3, NewBrokersByBrokerIn;

typedef enum _SortType{
	BuyShare,SellShare,BuySellShare,BuyAmnt,SellAmnt,BuySellAmnt
}SortType;

@protocol BrokerProtocol <NSObject>

-(void)notifyData;

@end

@interface Brokers : NSObject {
	NSRecursiveLock *datalock;
    
    UInt16 recordDate;
    
	NSMutableArray *mainStockArray;
	NSMutableArray *mainBrokerArray;
	NSMutableArray *mainAnchorArray;
    NSMutableArray *mainNewBrokerArray;
    
    
	int commodityNum;
	int brokerID;
	
	NSObject<BrokerProtocol> * notifyObjByStock;
	NSObject<BrokerProtocol> * notifyObjByBroker;
	NSObject<BrokerProtocol> * notifyObjByAnchor;
    NSObject<BrokerProtocol> * notifyObjByNewBroker;

	
	BOOL removeFlagByStock;
	BOOL removeFlagByBroker;
	BOOL removeFlagByAnchor;
    BOOL removeFlagByNewBroker;

	
}

@property (nonatomic,strong) NSMutableArray *mainStockArray;
@property (nonatomic,strong) NSMutableArray *mainBrokerArray;
@property (nonatomic,strong) NSMutableArray *mainAnchorArray;
@property (nonatomic,strong) NSMutableArray *mainNewBrokerArray;

@property (nonatomic) UInt16 recordDate;


- (void)sendByStockID:(UInt32)cn WithDay:(UInt8)dayCounts BrokersCount:(UInt8)brokersCount SortType:(UInt8)st;
- (void)sendByBrokerID:(UInt16)bID WithDay:(UInt8)dayCounts BrokersCount:(UInt8)brokersCount;
- (void)sendByAnchor:(UInt32)cn BrokerID:(UInt16)bID BrokersCount:(UInt8)brokersCount;
- (void)sendByNewBrokerID:(UInt16)bId WithDay:(UInt8)dayCounts BrokersCount:(UInt8)brokersCount SortType:(UInt8)st;

- (void)decodeByStockArrive:(BrokersByStockIn*)obj;
- (void)decodeByBrokerArrive:(BrokersByBrokerIn*)obj;
- (void)decodeByAnchorArrive:(BrokersByAnchorIn*)obj;
- (void)decodeByNewBrokerArrive:(NewBrokersByBrokerIn*)obj;

- (void)setTargetNotifyByStock:(id)obj;
- (void)setTargetNotifyByBroker:(id)obj;
- (void)setTargetNotifyByAnchor:(id)obj;
- (void)setTargetNotifyByNewBroker:(id)obj;

- (void)sortArrayByStock:(SortType)st ascending:(BOOL)ascending;
- (void)sortArrayByBroker:(SortType)st;
- (void)sortArrayByAnchor:(SortType)st;

- (int)getRowCountByStock;
- (int)getRowCountByBroker;
- (int)getRowCountByAnchor;

- (BrokersFormat1*)getAllocRowDataByStockIndex:(int)indexRow;
- (BrokersFormat2*)getAllocRowDataByBrokerIndex:(int)indexRow;
- (BrokersFormat3*)getAllocRowDataByAnchorIndex:(int)indexRow;


- (void)discardDataByStock;
- (void)discardDataByBroker;
- (void)discardDataByAnchor;

@end

@interface BrokersByModel : NSObject


enum BrokerTrackingViewController {
    FSBrokerInAndOutView,
    FSBranchInAndOutView
};

+ (BrokersByModel *)sharedInstance;

@property NSString *brokerName;
@property NSString *brokerAnchorName;
@property NSString *brokerNameForBranchView;
@property NSString *brokerStockName;

@property int brokerID;
@property NSString *brokerBranchID;
@property (assign, nonatomic) enum BrokerTrackingViewController brokerTrackingViewController;


@end
