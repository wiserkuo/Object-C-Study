//
//  WarrantHistroyIn.h
//  FonestockPower
//
//  Created by Kenny on 2014/11/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WarrantHistoryIn : NSObject
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@interface HistoryObject : NSObject
@property (nonatomic) UInt16 dataDate;
@property (nonatomic) double hv_30;
@property (nonatomic) double hv_60;
@property (nonatomic) double hv_90;
@property (nonatomic) double hv_120;
@property (nonatomic) double iv;
@property (nonatomic) double siv;
@property (nonatomic) double biv;
@property (nonatomic) double volume;
@end