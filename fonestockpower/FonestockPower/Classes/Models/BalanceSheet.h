//
//  BalanceSheet.h
//  FonestockPower
//
//  Created by Neil on 14/4/25.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodingUtil.h"

@interface BalanceSheet : NSObject{
    NSObject * notifyObj;
}
@property (nonatomic) BOOL merge;
@property (nonatomic, strong) NSMutableArray * keyArray;

- (void)setTargetNotify:(id)obj;
- (void)loadSymbol1FromIdentSymbol:(NSString*)is;
- (void)loadSymbol2FromIdentSymbol:(NSString*)is;
- (void)sendAndReadWithSymbol1:(NSString *)identSymbol;
- (void)sendAndReadWithSymbol2:(NSString *)identSymbol;
- (UInt16)findDateByIdentSymbol:(NSString*)is Postion:(int)pos;
- (int)getDateCountByIdentSymbol:(NSString*)is;
- (int)getRowCount:(int)index;
- (TAvalueParam *)getRowDataWithIdentSymbol:(NSString*)is RowTitle:(NSString *)RowTitle Index:(int)index;
-(NSMutableDictionary *)getDataDictionaryWithIdentSymbol:(NSString*)is;
@end
