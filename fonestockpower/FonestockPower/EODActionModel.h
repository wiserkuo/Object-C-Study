//
//  EDOActionModel.h
//  FonestockPower
//
//  Created by Kenny on 2014/6/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSWatchlistPortfolioItem.h"
#import "PortfolioTick.h"
@class FigureSearchData;
@interface EODActionModel : NSObject <HistoricDataArriveProtocol>
{
    NSInteger portfolioCount;
    BOOL loopFlag;
    NSString *identCodeSymbol;
    NSMutableDictionary * eodDictionary;
    NSMutableDictionary * mainDict;
    PortfolioItem *item;
    NSDateComponents *components;
    //公式Flag
    BOOL price0_20HighFlag;
    BOOL price0_20LowFlag;
    BOOL price1_20HighFlag;
    BOOL price1_20LowFlag;
    BOOL price2_20LowFlag;
    BOOL price2_20HighFlag;
    BOOL price1_15LowFlag;
    BOOL price1_15HighFlag;
    
}
@property (nonatomic, strong) NSObject<FSWatchlistItemProtocol> *watchlistItem;
-(NSString *)getStockName:(NSIndexPath*)indexPath;
-(int)getStockCount;
-(NSString *)getIdentCodeSymbol:(NSIndexPath*)indexPath;
-(void)getFigureImage:(NSString *)symbol Type:(NSString *)type;
-(void)setArray:(NSMutableArray*)array setIdentCodeSymbol:(NSString *)is;
-(void)ImageNumber:(int)imageNumber Symbol:(NSString *)symbol FSData:(FigureSearchData *)fsData
             Alert:(void (^)(BOOL needAlert))alert;
-(void)setTargetNotify:(NSObject*)object;
@end

@interface DIYObject : NSObject
{
@public
    int figureSearch_ID;
    int tNumber;
    double highValue;
    double lowValue;
    double openValue;
    double closeValue;
    BOOL rangeFlag;
    BOOL colorFlag;
    BOOL upLineFlag;
    BOOL kLineFlag;
    BOOL downLineFlag;
}
@end


@interface FigureSearchData : NSObject
{
@public
    int date;
    double openPrice;
    double highPrice;
    double lowPrice;
    double closePrice;
}
@end

@interface ArrayData : NSObject
{
@public
    NSMutableArray *dataArray;
    NSMutableArray *nameArray;
    NSString *fullName;
    NSString *identCodeSymbol;
    NSString *symbol;
}
@end

