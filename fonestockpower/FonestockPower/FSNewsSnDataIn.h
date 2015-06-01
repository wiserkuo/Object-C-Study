//
//  FSNewsSnDataIn.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/8.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSNewsSnDataIn : NSObject<DecodeProtocol>

@end

@interface NewsSnData : NSObject

@property UInt16 rootSectorID;
@property UInt16 date;
@property UInt16 sectorID;
@property UInt16 sn;

@end