//
//  FigureSearchMyProfileModel.h
//  WirtsLeg
//
//  Created by Connor on 13/10/28.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FigureSearchMyProfileModel : NSObject

//判斷是要使用哪一種儲存方式
typedef NS_ENUM(NSUInteger, FSFigureCustomStoreType){
    FSFigureCustomStoreTypeTempStore = 0,           // 0: 暫存，儲存FigureSearchId * 10
    FSFigureCustomStoreTypeSubmitStore = 1          // 1: 儲存，將有FigureSearchId 的*10 更新為原數值
};

//判斷哪個textField 被按到
typedef NS_ENUM(NSUInteger, FSFigureCustomTextFieldType){
    FSFigureCustomTextFieldTypeDaily = 0,           // 0: 日的範圍
    FSFigureCustomTextFieldTypeWeekly = 1,          // 1: 週的範圍
    FSFigureCustomTextFieldTypeMonthly = 2          // 2: 月的範圍
};

//給數值的部份
typedef NS_ENUM(NSUInteger, FSFigureCustomSearchType) {
    FSFigureCustomSearchTypeNothing = 3,             // 3: 任意值
    FSFigureCustomSearchTypeBigger = 1,              // 1: 大於
    FSFigureCustomSearchTypeSmaller = 2,             // 2: 小於
    FSFigureCustomSearchTypeEqualTo = 0              // 0: 約等於
};

//顏色的部份
typedef NS_ENUM(NSUInteger, FSFigureCustomColorType) {
    FSFigureCustomColorTypeNeverBother = 2,         // 2: 任意顏色
    FSFigureCustomColorTypeRed = 0,                 // 0: 紅色
    FSFigureCustomColorTypeGreen = 1                // 1: 綠色
};

//欄位傳遞上的通用部份
typedef NS_ENUM(NSUInteger, FSFigureDBColumn){
    FSFigureDBColumnRange = 0,                  // 0: range欄位
    FSFigureDBColumnColor = 1,                      // 1: color欄位
    FSFigureDBColumnUpLine = 2,                     // 2: upLine欄位
    FSFigureDBColumnKLine = 3,                      // 3: kLine欄位
    FSFigureDBColumnDownLine = 4                    // 4: downLine欄位
};

//日、週、月間的切換
typedef NS_ENUM(NSUInteger, FSFigureDWM){
    FSFigureDWMForD = 0,                        // 0: 指日線
    FSFigureDWMForW = 1,                        // 1: 指週線
    FSFigureDWMForM = 2                         // 2: 指月線
};

@property (nonatomic) BOOL beSubmit;

-(NSMutableArray *)searchDefaultKbarWithNumber:(NSNumber *)num;
-(NSMutableArray *)searchFigureSearchIdWithGategory:(NSString *)gategory ItemOrder:(NSNumber *)itemOrder;
-(NSMutableArray *)searchCustomKbarWithFigureSearchId:(NSNumber *)figureSearchId TNumber:(NSNumber *)tNum;
-(void)updateRangeWithFigureSearchId:(NSNumber *)figureSearchId DayRange:(NSNumber *)day WeekRange:(NSNumber *)week MonthRange:(NSNumber *)month;
-(void)editKbarValueWithFigureSearchId:(NSNumber *)figureSearchId TNumber:(NSNumber *)tNum High:(NSNumber *)high Low:(NSNumber *)low Open:(NSNumber *)open Close:(NSNumber *)close;
-(void)changeFigureSearchTitleWithFigureSearchId:(NSNumber *)figureSearchId String:(NSString *)title;
-(void)deleteAllKbarWithFigureSearchId:(NSNumber *)figureSearchId;
-(void)deleteKbarWithFigureSearchId:(NSNumber *)figureSearchId tNum:(NSNumber *)num;
-(void)changeFigureSearchImageWithFigureSearchId:(NSNumber *)figureSearchId Image:(NSData *)image;
-(void)updateFigureSearchImageToUSStyle:(NSNumber *)figureSearchId LongOrShort:(NSString *)longOrShort Image:(NSData *)image;
-(void)changeFigureSearchNameWithFigureSearchId:(NSNumber *)figureSearchId Name:(NSString *)name;
-(int)checkFigureSearchTitle:(NSString *)title SearchID:(NSNumber *)figureSearchId System:(NSString *)system;
-(BOOL)CountKbarWithFigureSearchId:(NSNumber *)figureSearchId;
-(NSData *)searchImageWithGategory:(NSString *)gategory ItemOrder:(NSNumber *)itemOrder;
-(void)setFigureSearchToDefaultWithFigureSearchId:(NSNumber *)figureSearchId;

-(NSArray *)getDWMRange:(int)target;
-(NSMutableArray *)searchLastResultWithFigureSearchId:(NSNumber *)figureSearchId Range:(NSString *)range SearchType:(NSString *)type;
-(void)editTheOriginNum:(NSNumber *)figureSearchId ToMutliTen:(NSNumber *)newFigureSearchId TNumber:(NSNumber *)tNum;
-(void)editFigureSearchResultInfoWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type SearchDate:(NSDate *)date SearchRange:(NSString *)range Total:(NSNumber *)total SearchType:(NSString *)searchType;
-(void)editFigureSearchResultDataWithFigureSearchResultInfoId:(NSNumber *)figureSearchResultInfoId DataArray:(NSArray *)data MarkPriceArray:(NSArray *)markPriceArray;
-(NSMutableArray *)searchFigureSearchResultDataWithFigureSearchResultInfoId:(NSNumber *)figureSearchResultInfoId;
-(void)deleteFigureSearchResultDataWithFigureSearchResultInfoId:(NSNumber *)figureSearchResultInfoId;
-(NSMutableArray *)searchResultInfoWithFigureSearchId:(NSNumber *)figureSearchId;
-(void)deleteResultInfoWithFigureSearchId:(NSNumber *)figureSearchId;
-(NSMutableArray *)searchStockNameWithIdentCode:(NSString *)identCode Symbol:(NSString *)symbol;
-(UIViewController *)popBackTo:(NSString *)target from:(NSArray *)array;

//Track
-(void)addTrackWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type IdentCode:(NSString *)identCode Symbol:(NSString *)symbol TrackDate:(NSDate *)date SearchType:(NSString *)searchType MarkPrice:(NSNumber *)markPrice FullName:(NSString *)fullName;
-(BOOL)searchTrackWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type IdentCode:(NSString *)identCode Symbol:(NSString *)symbol TrackDate:(NSDate *)date SearchType:(NSString *)searchType;
-(NSMutableArray *)searchAllTrackWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type SearchType:(NSString *)searchType;
-(void)deleteTrackWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type IdentCode:(NSString *)identCode Symbol:(NSString *)symbol TrackDate:(NSDate *)date;
-(void)deleteAllTrackWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type IdentCode:(NSString *)identCode Symbol:(NSString *)symbol SearchType:(NSString *)searchType;
-(void)deleteAllTrackWithFigureSearchId:(NSNumber *)figureSearchId;
-(NSMutableArray *)searchAllTrackWithFigureSearchId:(NSNumber *)figureSearchId RangeType:(NSString *)type;


-(NSString *)searchFormulaWithFigureSearchId:(NSNumber *)figureSearchId;
-(void)editSearchFormulaWithFigureSearchId:(NSNumber *)figureSearchId Formula:(NSString *)formula;


-(void)editFigureSearchConditionsWithFigureSearch_ID:(NSNumber *)figureSearchId Range:(NSString *)range Color:(NSString *)color UpLine:(NSString *)upLine KLine:(NSString *)kLine DownLine:(NSString *)downLine;

-(NSString *)searchInstructionByControllerName:(NSString *)controllerName;
-(BOOL)searchInstruction;
-(void)setAllInstruction:(NSString *)status;
-(void)editInstructionByControllerName:(NSString *)controllerName Show:(NSString *)show;

-(int)searchTrendTypeByFigureSearch_ID:(NSNumber *)figureSearchId;
-(void)editTrendWithFigureSearchId:(NSNumber *)figureSearchId Trend:(NSNumber *)trend;
-(void)editTrendValueWithFigureSearchId:(NSNumber *)figureSearchId UpLine:(NSNumber *)upLine DownLine:(NSNumber *)downLine FlatLine:(NSNumber *)flatLine;
-(NSMutableArray *)searchTrendValueByFigureSearch_ID:(NSNumber *)figureSearchId;

-(void)editKbarFigureSearchId:(NSNumber *)figureSearchId NewFigureSearchId:(NSNumber *)newFigureSearchId TNumber:(NSNumber *)tNum;

-(void)doneEditKBarFigureSearchID:(NSNumber *)figureSearchId NewFigureSearchId:(NSNumber *)newFigureSearchId TNumber:(NSNumber *)tNum theData:(NSArray *)dataArray type:(NSUInteger)storeType;
-(int)getCounts:(NSNumber *)figureSearchID;

-(void)editdifinitionWithFigureSearchId:(NSNumber *)figureSearchId Difinition:(NSString *)difinition;

-(void)updateFlatTrendWithFigureSearchId:(NSNumber *)figureSearchId DayRange:(NSNumber *)day WeekRange:(NSNumber *)week MonthRange:(NSNumber *)month;

-(NSMutableArray *)searchkBarConditionsWithFigureSearchId:(NSNumber *)figureSearchId tNumber:(NSNumber *)tNumber;
-(NSMutableArray *)searchKBarDetailWithFigureSearchID:(NSNumber *)figureSearchId tNumber:(NSNumber *)tNumber;
-(void)changeKbarConditionsWithFigureSearchId:(NSNumber *)figureSearchId TNumber:(NSNumber *)tNum Range:(NSString *)range Color:(NSString *)color UpLine:(NSString *)upLine KLine:(NSString *)kLine DownLine:(NSString *)downLine;

-(NSString *)searchFullNameWithIdentCode:(NSString *)identCode Symbol:(NSString*)symbol;
+ (FigureSearchMyProfileModel *)sharedInstance;
-(NSMutableArray *)actionSearchFigureSearchId;
-(NSMutableArray *)actionPlanBtnTitleSearchFigureSearchIdWithFigureSearchID:(NSNumber *)figureSearchID;
-(NSData *)searchImageWithFigureSearch_ID:(NSString *)figuresearch_ID;
+(NSURLRequest *)openExplanation;
@end
