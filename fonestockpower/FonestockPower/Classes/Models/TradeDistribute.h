//
//  TradeDistribute.h
//  Bullseye
//
//  Created by ilien.liao on 2009/6/16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDNotifyProtocol

-(void)TDNotify;

@end


@interface TDParam : NSObject
{
	UInt8 volumeUnit; //for hightVolume and lowVolume
	float hightPrice;
	float lowPrice;
	double hightVolume;
	double lowVolume;
	NSMutableArray* arrayData;
}

@property(nonatomic,strong) NSMutableArray* arrayData;
@property(nonatomic,readwrite) UInt8 volumeUnit; //for hightVolume and lowVolume
@property(nonatomic,readwrite) float hightPrice;
@property(nonatomic,readwrite) float lowPrice;
@property(nonatomic,readwrite) double hightVolume;
@property(nonatomic,readwrite) double lowVolume; 

@end


@interface TradeDistribute : NSObject 
{
	NSObject <TDNotifyProtocol>* notifyTarget;
	NSInteger dayType;
	NSInteger dayCount;
	NSString* date;
	NSString* startDate;
	NSString* endDate;
	
	
	TDParam* oneDay;
	TDParam* period;
    
    id notifyObj;

}

-(void)fSDistributeIn:(NSObject *)data;

-(void)setTarget:(id)obj;

@property (strong) NSObject <TDNotifyProtocol>* notifyTarget;
@property(nonatomic,strong) TDParam* oneDay;
@property(nonatomic,strong) TDParam* period;
@property(nonatomic,strong) NSString* date;
@property(nonatomic,strong) NSString* startDate;
@property(nonatomic,strong) NSString* endDate;
@property(nonatomic,readonly) NSInteger dayType;
@property(nonatomic,readonly) NSInteger dayCount;


- (void)SetTarget:(NSObject <TDNotifyProtocol>*) obj;
- (void)AskOneDaySecurityNum:(UInt32)cn DayCount:(UInt8)dc BeforeDate:(UInt16)d;
- (void)AskDaysSecurityNum:(UInt32)cn DayCount:(UInt8)dc BeforeDate:(UInt16)d;

-(double)getRealValue:(double)value Unit:(NSInteger)unit;

- (void)TDIn:(NSObject*)obj;
-(void)AskDaysIdentCodeSymbol:(NSString *)ident number:(UInt8)n date:(UInt16)d;
-(void)AskOneDayIdentCodeSymbol:(NSString *)ident number:(UInt8)n date:(UInt16)d;
- (NSString *)signByExamingPrice:(double) price equalToOpenPrice:(double) openPrice closePrice:(double) closePrice;
@end
