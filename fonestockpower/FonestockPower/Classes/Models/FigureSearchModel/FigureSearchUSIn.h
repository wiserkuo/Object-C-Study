//
//  FigureSearchUSIn.h
//  WirtsLeg
//
//  Created by Connor on 13/11/20.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FigureSearchUSIn : NSObject <DecodeProtocol> {
@public
	UInt8 sn;
	UInt16 totalAmount;
    UInt16 dataDate;
	UInt8 dataAmount;
    NSMutableArray * markPriceArray;
    NSMutableArray * dataArray;
    BOOL moreData;
}

@end