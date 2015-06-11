//
//  TechIn.h
//  FonestockPower
//
//  Created by Kenny on 2014/12/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TechIn : NSObject<DecodeProtocol>{
    HistoricalParm *historicalParm;
}

@property (nonatomic,strong) HistoricalParm *historicalParm;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic) int retCode;

@end
@interface TechObject : NSObject
@property(nonatomic) UInt16 date;
@property(nonatomic) double open;
@property(nonatomic) double high;
@property(nonatomic) double low;
@property(nonatomic) double last;
@property(nonatomic) double volume;
@end