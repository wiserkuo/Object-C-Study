//
//  CYQModel.h
//  Bullseye
//
//  Created by Connor on 13/8/28.
//
//

#import <Foundation/Foundation.h>

// 每日 or 累計
typedef NS_ENUM(NSUInteger, CYQSearchType) {
    CYQSearchType_dailyMode,
    CYQSearchType_accumulateMode
};

// 日期範圍 日曆或近幾天內
enum CYQAccmulateOptionType {
    CYQAcuumulateOptionTypeCalendar,
    CYQAcuumulateOptionTypeRecently
};
// 日期範圍 日曆或近幾天內 MainPlus
enum MainPlusAccmulateOptionType {
    MainPlusAcuumulateOptionTypeRecently,
    MainPlusAcuumulateOptionTypeCalendar
};

@interface CYQModel : NSObject

+ (CYQModel *)sharedInstance;

// 融券,三大法人日期設定用
@property (assign, nonatomic) CYQSearchType currentSearchType;                  // 每日 or 累計
@property (strong, nonatomic) NSArray *dateArray;                               // 所有日期
@property (assign, nonatomic) enum CYQAccmulateOptionType accumulateOptionType; // 自定範圍 日曆或近幾天內
@property (strong, nonatomic) NSDate *startDate;                                // 自定, 起始日期
@property (strong, nonatomic) NSDate *endDate;                                  // 自定, 結束日期
@property (assign, nonatomic) int recentlyDay;                                  // 自定, 結束日期
@property (assign, nonatomic) int tickVolume;
// MainPlus
@property (assign, nonatomic) enum MainPlusAccmulateOptionType mainPlusAccumulateOptionType;
@property (assign, nonatomic) int pickDays;

@end
