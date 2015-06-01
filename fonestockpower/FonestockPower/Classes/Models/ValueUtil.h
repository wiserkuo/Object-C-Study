//
//  ValueUtil.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/17.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ValueUtil : NSObject

+ (UIColor *)colorOfPrice:(double)price basePrice:(double)basePrice baseColor:(UIColor *)baseColor;
+ (UIColor *)colorOfPrice:(double)price refPrice:(double)refPrice baseColor:(UIColor *)baseColor;

//回傳多少show多少 (成交價)
+ (void)updateTickPriceLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref ceilingPrice:(double)ceiling floorPrice:(double)floor whiteStyle:(BOOL)whiteStyle;

+ (void)updateLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref ceilingPrice:(double)ceiling floorPrice:(double)floor whiteStyle:(BOOL)whiteStyle compact:(BOOL)compact;
+ (void)updateLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref ceilingPrice:(double)ceiling floorPrice:(double)floor whiteStyle:(BOOL)whiteStyle;
+ (void)updateLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref whiteStyle:(BOOL)whiteStyle compact:(BOOL)compact;

// for 港股
+ (void)updateHKLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref ceilingPrice:(double)ceiling floorPrice:(double)floor whiteStyle:(BOOL)whiteStyle;
+ (void)updateHKLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref ceilingPrice:(double)ceiling floorPrice:(double)floor whiteStyle:(BOOL)whiteStyle compact:(BOOL)compact;

+ (void)updateChangeLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref whiteStyle:(BOOL)whiteStyle compact:(BOOL)compact;
+ (void)updateChangeLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref whiteStyle:(BOOL)whiteStyle;

+ (void)updateLabel:(UILabel *)label withValue:(double)value unit:(UInt8)unit;

+ (NSString *)stringWithValue:(double)value unit:(UInt8)unit sign:(BOOL)sign;
+ (NSString *)stringWithValue:(double)value unit:(UInt8)unit font:(UIFont *)font width:(CGFloat)width sign:(BOOL)sign;
+ (NSString *)stringWithValue:(double)value unit:(UInt8)unit font:(UIFont *)font width:(CGFloat)width;

+ (UInt16)stkDateFromNSDate:(NSDate *)date;
+ (NSDate *)nsDateFromStkDate:(UInt16)date;
+ (NSCalendar *)sharedGregorianCalendar;

//add by Yehsam
+ (void)updateHaveZeroLabel:(UILabel *)label withValue:(double)value unit:(UInt8)unit;

@end


extern const float valueUnitBase[];
