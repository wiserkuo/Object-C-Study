//
//  FSMarketMoverOut.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface FSMarketMoverOut : NSObject<EncodeProtocol>{
    UInt8 sortingType;
    UInt8 direction;
    UInt8 update;
}
-(id)initWithSortingType:(UInt8)st direction:(UInt8)d update:(UInt8)u;

@end
