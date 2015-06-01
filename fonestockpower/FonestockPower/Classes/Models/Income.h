//
//  Income.h
//  Bullseye
//
//  Created by Yehsam on 2009/1/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Income : NSObject {
    NSObject * notifyObj;
}

@property (nonatomic, strong) NSMutableArray * keyArray;
@property (nonatomic) BOOL merge;
@property (nonatomic) BOOL total;

- (void)setTargetNotify:(id)obj;
- (void)loadSymbol1FromIdentSymbol:(NSString*)is;
- (void)loadSymbol2FromIdentSymbol:(NSString*)is;
- (void)sendAndReadWithSymbol1:(NSString *)identSymbol Type:(char)type;
- (void)sendAndReadWithSymbol2:(NSString *)identSymbol Type:(char)type;
- (UInt16)findDateByIdentSymbol:(NSString*)is Postion:(int)pos;
- (int)getDateCountByIdentSymbol:(NSString*)is;
- (int)getRowCount:(int)index;
- (TAvalueParam *)getRowDataWithIdentSymbol:(NSString*)is RowTitle:(NSString *)RowTitle Index:(int)index;
-(NSMutableDictionary *)getDataDictionaryWithIdentSymbol:(NSString*)is;
@end
