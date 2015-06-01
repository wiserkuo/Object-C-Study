//
//  FigureSearchUS.h
//  WirtsLeg
//
//  Created by Connor on 13/11/21.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FigureSearchUSIn;

enum FigureSearchUSFeeType {
    FigureSearchUSFeeTypePreviousSessionBuildIn = 1,
    FigureSearchUSFeeTypeInSessionBuildIn = 2,
    FigureSearchUSFeeTypePreviousSessionDIY = 3,
    FigureSearchUSFeeTypeInSessionDIY = 4
};

@protocol FigureSearchDelegate;

@interface FigureSearchUS : NSObject

@property (weak, nonatomic) id <FigureSearchDelegate> delegate;

- (void)searchByType:(enum FigureSearchUSFeeType)type sectorIDs:(NSArray *)sectorIDsArray flag:(UInt8)flag sn:(UInt8)sn reqCount:(UInt8)reqCount equationString:(NSString *)equationString;
- (void)callBackData:(FigureSearchUSIn *)data;
@end

@protocol FigureSearchDelegate <NSObject>
- (void)callBackResultEquationName:(NSString *)equationName targetMarket:(NSString *)targetMarket dataAmount:(int)dataAmount totalAmount:(int)totalAmount dataDate:(UInt16)date dataArray:(NSArray *)dataArray markPriceArray:(NSArray *)markPriceArray;
@end