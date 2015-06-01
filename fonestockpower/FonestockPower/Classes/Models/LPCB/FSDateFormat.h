//
//  FSDateFormat.h
//  FonestockPower
//
//  Created by Connor on 14/8/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSDateFormat : NSObject {
    
}

@property UInt16 date16;

- (instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset;
- (NSDate *)date;
- (NSString *)dateFormatToString:(NSString *)string;
@end
