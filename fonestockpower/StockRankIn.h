//
//  StockRankIn.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/10/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@interface StockRankIn : NSObject<DecodeProtocol>{
@public

    NSMutableArray *stockDataArray;    
}


@end
