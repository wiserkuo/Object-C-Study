//
//  HistoryModel.h
//  FonestockPower
//
//  Created by Kenny on 2014/11/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryModel : NSObject<HistoricDataArriveProtocol>
-(void)getDLine:(NSString *)symbol;
-(void)setTarget:(id)target;
@end

@interface HistoryDrawObject : NSObject
{
@public
    double lastPrice;
    int volume;
    UInt16 date;
}

@end