//
//  FSBValueFormat.h
//  FonestockPower
//
//  Created by Connor on 14/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FSBValueFormatPackType) {
    FSBValueFormatPackTypeBinary = 0,
    FSBValueFormatPackTypePackBCD = 1
};

@interface FSBValueFormat : NSObject {

}

@property int type;
@property int subType;
@property long long value;
@property double calcValue;
@property int decimal;
@property int exponentType;
@property int exponent;
@property FSBValueFormatPackType packType;
@property int sign;

- (instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset;
- (NSString *)format;
@end
