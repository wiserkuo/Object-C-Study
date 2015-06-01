//
//  StockHolderMeeting.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoricalDividendIn.h"
#import "FSHistoricalEPSIn.h"
#import "StockHolderMeetingIn.h"
@protocol StockHolderMeetingDelegate;

@interface StockHolderMeeting : NSObject
{
    int sendNumber;
}
- (void)sendAndRead;
- (NSDictionary *)getDictData;
- (void)getTypeDate:(int)TypeNumber;
- (void)HistoricalDividendDataCallBack:(HistoricalDividendIn *)data;
- (void)HistoricalEPSCallBack:(FSHistoricalEPSIn*)data;
- (void)stockHolderMeetingDataCallBack:(StockHolderMeetingIn *)data;
@property (nonatomic, weak) NSObject <StockHolderMeetingDelegate> *delegate;
@end

@protocol StockHolderMeetingDelegate <NSObject>
- (void)StockHolderMeetingNotifyData:(id)target;
- (void)EPSNotifyData:(id)target;
- (void)HisNotifyData:(id)target;
@end
