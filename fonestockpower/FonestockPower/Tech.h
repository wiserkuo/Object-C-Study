//
//  Tech.h
//  '
//
//  Created by Kenny on 2014/12/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tech : NSObject
//給數值的部份
typedef NS_ENUM(NSUInteger, TouchPoint) {
    TouchPointStart = YES,              // YES: StartPoint
    TouchPointEnd = NO                 // NO:  EndPoint
};

@property (nonatomic) double pinchValue;
@property (nonatomic) double widthRange;

@property (nonatomic, strong) NSMutableArray *m1Array;
@property (nonatomic, strong) NSMutableArray *m2Array;
@property (nonatomic, strong) NSMutableArray *m3Array;
@property (nonatomic, strong) NSMutableArray *v1Array;
@property (nonatomic, strong) NSMutableArray *v2Array;
@property (nonatomic, strong) NSMutableArray *v3Array;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic)int mNum1;
@property (nonatomic)int mNum2;
@property (nonatomic)int mNum3;
@property (nonatomic)int valueNum1;
@property (nonatomic)int valueNum2;
@property (nonatomic)int kNum;
@property (nonatomic)int dNum;
@property (nonatomic)int rsiNum1;
@property (nonatomic)int rsiNum2;
@property (nonatomic)int emaNum1;
@property (nonatomic)int emaNum2;
@property (nonatomic)int macdNum;
@property (nonatomic)int obvNum;
-(void)IdentCodeSymbol:(NSString *)identCodeSymbol dataType:(UInt8)dataType commodityType:(UInt8)commodityType startDate:(UInt16)startDate endDate:(UInt16)endDate;
-(void)sendIdnetCodeSymbol:(NSString *)identCodeSymbol dataType:(UInt8)dataType commodityType:(UInt8)commodityType count:(UInt16)count;
-(void)techCallBackData:(NSMutableArray *)dataArray;
-(void)setTarget:(NSObject*)object;
-(void)saveKData:(NSMutableArray *)dataArray Dict:(NSDictionary *)dict;
-(NSMutableArray *)getKData:(NSString *)identCodeSymbol;
-(int)getTechTime:(NSString *)identCodeSymbol;
-(void)getMArray;
-(void)getVArrayType:(NSString *)type;
-(BOOL)isTodayK:(NSString *)identCodeSymbol Time:(int)today;
- (BOOL)initDataModel:(NSString *)identCodeSymbol;
@end
