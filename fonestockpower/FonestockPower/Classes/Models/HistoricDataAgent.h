//
//  HistoricDataAgent.h
//  Bullseye
//
//  Created by Ray Kuo on 2008/12/25.
//  Copyright 2008 TelePaq Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ValueUtil.h"
#import "TickDataSource.h"
#import "Portfolio.h"

#define DateNumMax 780

typedef enum {
    AnalysisPeriodDay,
    AnalysisPeriodWeek,
    AnalysisPeriodMonth,
    AnalysisPeriod5Minute,
    AnalysisPeriod15Minute,
    AnalysisPeriod30Minute,
    AnalysisPeriod60Minute,
} AnalysisPeriod;


@interface HistoricDataAgent : NSObject <HistoricTickDataSourceProtocol> {

    NSMutableArray *dataArray;
}

@property (nonatomic, strong) NSMutableArray *dataArray;

- (id)getHistoricTickWithIndex:(int)index;
- (UInt32)historicTickCountFromStartDate:(UInt16)startDate toEndDate:(UInt16)endDate; //抓區間資料總數
- (float)getTheHightestValueFromStartIndex:(NSInteger)startIndex toEndIndex:(NSInteger)endIndex; //抓區間最低值
- (float)getTheLowestValueFromStartIndex:(NSInteger)startIndex toEndIndex:(NSInteger)endIndex; //抓區間最高值
- (float)getTheChangeValueFromStartDate:(UInt16)startDate toEndDate:(UInt16)endDate; //抓此區間資料的變動值
- (id)getHistoricTickFromStartDate:(UInt16)startDate toEndDate:(UInt16)endDate withIndex:(int)index; //取得區間日期 以區間為範圍的第index筆資料

- (BOOL)updateData:(id<HistoricTickDataSourceProtocol>)dataSource forPeriod:(AnalysisPeriod)period portfolioItem:(PortfolioItem *)portfolioItem;

+ (UInt8)tickTypeForAnalysisPeriod:(AnalysisPeriod)period;
+ (NSComparisonResult)compareDate:(UInt16)date1 with:(UInt16)date2 forPeriod:(AnalysisPeriod)period;

@end
