//
//  TrendEODActionModel.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSWatchlistPortfolioItem.h"
#import "PortfolioTick.h"
#import "EODActionModel.h"

@interface TrendEODActionModel : NSObject <HistoricDataArriveProtocol>
{
    NSInteger portfolioCount;
    NSObject *notifyObj;
    NSString *identCodeSymbol;
    
}
@property (nonatomic, strong) NSObject<FSWatchlistItemProtocol> *watchlistItem;
-(NSString *)getStockName:(NSIndexPath*)indexPath;
-(int)getStockCount;
-(NSString *)getIdentCodeSymbol:(NSIndexPath*)indexPath;
-(void)getFigureImage:(NSString *)symbol Type:(NSString *)type;
-(void)setArray:(NSMutableArray*)array setIdentCodeSymbol:(NSString *)is;
//-(void)ImageNumber:(int)imageNumber Symbol:(NSString *)symbol FSData:(FigureSearchData *)fsData
            // Alert:(void (^)(BOOL needAlert))alert;
-(void)setTargetNotify:(NSObject*)object;
@end

@interface KObject : NSObject
{
@public
    int day;
    double lastPrice;
}
@end
