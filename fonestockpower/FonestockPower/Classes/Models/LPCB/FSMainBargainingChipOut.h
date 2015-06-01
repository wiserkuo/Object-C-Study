//
//  FSMainBargainingChipOut.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSMainBargainingChipOut : NSObject<EncodeProtocol>{
    UInt16 days;
    UInt8 sortType;
}
-(id)initWithDays:(UInt8)d SortType:(UInt8)st;

@end
