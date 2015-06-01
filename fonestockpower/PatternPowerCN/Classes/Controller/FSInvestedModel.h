//
//  FSInvestedModel.h
//  FonestockPower
//
//  Created by Derek on 2014/7/1.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSInvestedModel : NSObject <HistoricDataArriveProtocol>
@property (strong, nonatomic) NSMutableDictionary *investedArray;
@property (strong, nonatomic) NSMutableArray *positionArray;
@property (strong, nonatomic) NSMutableDictionary *diaryArray;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *dateArray;
@property (strong, nonatomic) NSMutableArray *historicDataArray;

@property (nonatomic) double maxTotal;
@property (nonatomic) double minTotal;
@property (nonatomic) double maxDaily;
@property (nonatomic) float buyCount;
@property (nonatomic) float buyPrice;
@property (nonatomic) float sellCount;
@property (nonatomic) float sellPrice;

-(void)startWithTerm:(NSString *)t Deal:(NSString *)d beginDate:(UInt16)beginDay;
-(void)setTargetNotify:(NSObject*)object;

@end
