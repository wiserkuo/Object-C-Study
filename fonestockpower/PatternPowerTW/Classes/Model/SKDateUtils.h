//
//  SKDateUtils.h
//  testgcd
//
//  Created by Connor on 13/7/9.
//  Copyright (c) 2013年 Connor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKDateUtils : NSObject

@property (strong, nonatomic) NSDate *baseDate;

//+ (UInt16)NSDateTransferUInt16:(NSDate *)date;



- (SKDateUtils *)initWithDate:(NSDate *)baseDate;
- (SKDateUtils *)initWithDateUInt16:(UInt16)baseDate;

/* 取得目前時間 */
+ (NSDate *)getCurrentDateTime;
+ (NSDate *)transferDateTimeToSystemTimeZone:(NSDate *)date;

- (NSString *)getBeginningOfWeek:(NSDate **)beginningOfWeek getEndingOfWeek:(NSDate **)endingOfWeek format:(NSString *)format;

- (NSString *)getpreviousOfBeginningOfWeek:(NSDate **)previousOfBeginningOfWeek getEndingOfWeek:(NSDate **)previousOfEndingOfWeek format:(NSString *)format;

- (NSString *)getpreviousOfBeginningOf2Week:(NSDate **)previousOfBeginningOf2Week getEndingOf2Week:(NSDate **)previousOfEndingOf2Week format:(NSString *)format;

- (NSString *)getBeginningOfMonth:(NSDate **)_beginningOfMonth_work getEndingOfMonth:(NSDate **)_endingOfMonth_work format:(NSString *)format;

- (NSString *)getpreviousBeginningOfMonth:(NSDate **)_beginningOfMonth_work getpreviousEndingOfMonth:(NSDate **)_endingOfMonth_work format:(NSString *)format;

- (NSString *)getCustomDate:(NSDate *)beginningOfDay getEndingOfDay:(NSDate *)endingOfDay format:(NSString *)format;

/* 根據月份間隔取得新的時間 */
+ (NSDate *)getDateByMonthOffset:(NSCalendar *)calendar date:(NSDate *)date monthOffset:(NSInteger)monthOffset;

/* 根據天數間隔取得新的時間 */
+ (NSDate *)getDateByDayOffset:(NSCalendar *)calendar date:(NSDate *)date dayOffset:(NSInteger)dayOffset;

/* 根據週數間隔取得新的時間 */
+ (NSDate *)getDateByWeekOffset:(NSCalendar *)calendar date:(NSDate *)date weekOffset:(NSInteger)weekOffset;

/* 回傳指定月的週數 */
+ (NSInteger)getLengthOfWeekInMonth:(NSCalendar *)calendar month:(NSInteger)month year:(NSInteger)year;

/* 計算二個時間差 周數量 */
+ (NSInteger)getWeekCountsOf2Dates:(NSCalendar *)calendar fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;


/* 根據年月日產生日期類別 */
+ (NSDate *)getDateByYMD:(NSCalendar *)calendar year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

/* 將日期類別轉為字串 */
+ (NSString *)dateToStrByFormat:(NSDate *)date format:(NSString *)format;

/* 比對二個日期是否在同一個月份中 */
+ (Boolean)ifInSameMonth:(NSDate *)dateA dateB:(NSDate *)dateB calendar:(NSCalendar *)calendar;

/* 獲取NSDate 變數 */
+ (NSDictionary *)getDateArgs:(NSCalendar *)calendar date:(NSDate *)date;

/* 計算日期在所在月的第幾週 */
+ (NSInteger)getWeekOrderOfMonth:(NSCalendar *)calendar date:(NSDate *)date;

/* 計算日期在某個月的第一週的序號 */
+ (NSInteger)getFirstWeekOrderOfMonth:(NSCalendar *)calendar date:(NSDate *)date;

@end