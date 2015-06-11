//
//  FSNewsTitleDataIn.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/8.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSNewsDataModel.h"

@interface FSNewsTitleDataIn : NSObject

@end

@interface NewsTitleData : NSObject

@property UInt8 retCode;
@property UInt16 date;
@property UInt16 rootSectorID;
@property NewNewsContentFormat1 *newsContent;


@end