//
//  NewRevenue.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/26.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewRevenueIn.h"

@protocol NewRevenueDelegate;
@protocol NewRevenueChartViewDelegate;
@interface NewRevenue : NSObject

- (void)sendAndRead;
- (void)NewRevenueDataCallBack:(NewRevenueIn *)data;
@property (nonatomic, weak) NSObject <NewRevenueDelegate> *delegate;
@property (nonatomic, weak) NSObject <NewRevenueChartViewDelegate> *chartViewDelegate;
@end

@protocol NewRevenueDelegate <NSObject>

- (void)NewRevenueNotifyData:(id)target;
@end

@protocol NewRevenueChartViewDelegate <NSObject>

- (void)NewRevenueChartViewNotifyData:(id)target;
@end