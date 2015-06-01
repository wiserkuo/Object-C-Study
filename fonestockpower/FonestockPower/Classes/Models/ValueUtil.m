//
//  ValueUtil.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/17.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "ValueUtil.h"


const float valueUnitBase[] = { 1.0, 1000.0, 1000000.0, 1000000000.0, 1000000000000.0 };

static NSCalendar *gCalendar;


@implementation ValueUtil


+ (void)initialize {

    if (self == [ValueUtil class]) {
        if (gCalendar == nil)
            gCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
}


+ (NSCalendar *)sharedGregorianCalendar {
    return gCalendar;
}


+ (UInt16)stkDateFromNSDate:(NSDate *)date {

    NSDateComponents *c = [gCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    return ((c.year-1960) << 9) | (c.month << 5) + c.day;
}


+ (NSDate *)nsDateFromStkDate:(UInt16)date {

    NSDateComponents *c = [[NSDateComponents alloc] init];
    c.year = (date >> 9) + 1960;
    c.month = (date >> 5) & 0xF;
    c.day = date & 0x1F;

    NSDate *d = [gCalendar dateFromComponents:c];
    return d;
}


+ (UIColor *)colorOfPrice:(double)price basePrice:(double)basePrice baseColor:(UIColor *)baseColor {

    if (price == 0) return baseColor;
	NSNumber* numPrice = [NSNumber numberWithFloat:price];
	NSNumber* numRef = [NSNumber numberWithFloat:basePrice];
	
    return [numPrice compare:numRef] == NSOrderedDescending ? [StockConstant PriceUpColor] :
           [numPrice compare:numRef] == NSOrderedAscending ? [StockConstant PriceDownColor] : baseColor;
}


+ (UIColor *)colorOfPrice:(double)price refPrice:(double)refPrice baseColor:(UIColor *)baseColor {

    if (refPrice == 0) return baseColor;

    return [ValueUtil colorOfPrice:price basePrice:refPrice baseColor:baseColor];
}

//回傳多少show多少
+ (void)updateTickPriceLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref ceilingPrice:(double)ceiling floorPrice:(double)floor whiteStyle:(BOOL)whiteStyle
{
    if (price == 0) 
	{
        label.text = ref == 0 ? nil : @"----";
        label.textColor = [UIColor lightGrayColor];
        label.backgroundColor = [UIColor clearColor];
        return;
    }

//	NSNumber *priceNumber = [NSNumber numberWithFloat:price];
    if (price<0.1) {
        label.text =[NSString stringWithFormat:@"%.3f",price];
    }else{
        label.text =[NSString stringWithFormat:@"%.2f",price];
    }
    
    
#ifdef LPCB
    label.textColor = [ValueUtil colorOfPrice:price refPrice:ref baseColor:whiteStyle?[UIColor blueColor]:[UIColor whiteColor]];
    label.backgroundColor = [UIColor clearColor];
#else
    if (price == ceiling) {
        label.textColor = whiteStyle ? [UIColor whiteColor] : [UIColor blackColor];
        label.backgroundColor = [StockConstant PriceUpColor];
    }
    else if (price == floor) {
        label.textColor = whiteStyle ? [UIColor whiteColor] : [UIColor blackColor];
        label.backgroundColor = [StockConstant PriceDownColor];
    }
    else {
        label.textColor = [ValueUtil colorOfPrice:price refPrice:ref baseColor:whiteStyle?[UIColor blueColor]:[UIColor whiteColor]];
        label.backgroundColor = [UIColor clearColor];
    }
#endif
    
	
}

+ (void)updateLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref ceilingPrice:(double)ceiling floorPrice:(double)floor whiteStyle:(BOOL)whiteStyle compact:(BOOL)compact {

    if (price == 0) {
        label.text = ref == 0 ? nil : @"----";
        label.textColor = [UIColor blueColor];
        label.backgroundColor = [UIColor clearColor];
        return;
    }
	
	NSString *format;
	
	if (compact)
	{
		if(price < 1)
		{
			format = @"%.2f";
		}
		else if(price < 100)
		{
			format = @"%.2f";
		}
		else if(price < 1000)
		{
			format = @"%.2f";
		}
		else if(price >= 1000)
		{
			format = @"%.2f";
		}
		
	}
	
    else
	{
		format = price < 1000 ? @"%.2f" : @"%.2f";
	}
	
	label.text = [NSString stringWithFormat:format, price];

#ifdef LPCB
    label.textColor = [ValueUtil colorOfPrice:price refPrice:ref baseColor:[UIColor blueColor]];
    label.backgroundColor = [UIColor clearColor];
#else
    if (price == ceiling) {
        label.textColor = whiteStyle ? [UIColor whiteColor] : [UIColor blackColor];
        label.backgroundColor = [StockConstant PriceUpColor];
    }
    else if (price == floor) {
        label.textColor = whiteStyle ? [UIColor whiteColor] : [UIColor blackColor];
        label.backgroundColor = [StockConstant PriceDownColor];
    }else {
        label.textColor = [ValueUtil colorOfPrice:price refPrice:ref baseColor:whiteStyle?[UIColor blueColor]:[UIColor blueColor]];
        label.backgroundColor = [UIColor clearColor];
    }
#endif
}


+ (void)updateLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref ceilingPrice:(double)ceiling floorPrice:(double)floor whiteStyle:(BOOL)whiteStyle {

    return [ValueUtil updateLabel:label withPrice:price refPrice:ref ceilingPrice:ceiling floorPrice:floor whiteStyle:whiteStyle compact:NO];
}

+ (void)updateLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref whiteStyle:(BOOL)whiteStyle compact:(BOOL)compact{

    return [ValueUtil updateLabel:label withPrice:price refPrice:ref ceilingPrice:0 floorPrice:0 whiteStyle:whiteStyle compact:compact];
}

//for港股
+ (void)updateHKLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref ceilingPrice:(double)ceiling floorPrice:(double)floor whiteStyle:(BOOL)whiteStyle compact:(BOOL)compact {
	
    if (price == 0) {
        label.text = ref == 0 ? nil : @"----";
        label.textColor = [UIColor lightGrayColor];
        label.backgroundColor = [UIColor clearColor];
        return;
    }
	
	NSString *format;
	
	if(price < 10)
	{
		format = @"%.3f";
	}
	else if(price < 100)
	{
		format = @"%.2f";
	}
	else if(price < 1000)
	{
		format = @"%.2f";
	}
	else if(price >= 1000)
	{
		format = @"%.2f";
	}

label.text = [NSString stringWithFormat:format, price];

if (price == ceiling) {
	label.textColor = whiteStyle ? [UIColor whiteColor] : [UIColor blackColor];
	label.backgroundColor = [StockConstant PriceUpColor];
}
else if (price == floor) {
	label.textColor = whiteStyle ? [UIColor whiteColor] : [UIColor blackColor];
	label.backgroundColor = [StockConstant PriceDownColor];
}
else {
	label.textColor = [ValueUtil colorOfPrice:price refPrice:ref baseColor:whiteStyle?[UIColor blackColor]:[UIColor whiteColor]];
	label.backgroundColor = [UIColor clearColor];
}


}

//for港股
+ (void)updateHKLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref ceilingPrice:(double)ceiling floorPrice:(double)floor whiteStyle:(BOOL)whiteStyle {
	
    return [ValueUtil updateHKLabel:label withPrice:price refPrice:ref ceilingPrice:ceiling floorPrice:floor whiteStyle:whiteStyle compact:NO];
}

+ (void)updateChangeLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref whiteStyle:(BOOL)whiteStyle compact:(BOOL)compact {

    if (price == 0 || ref == 0) {
        label.text = @"----";
        label.textColor = [UIColor blueColor];
        return;
    }

    double chg = price - ref;

#if defined (BROKER_YUANTA)
	
	label.text = [[NSNumber numberWithFloat:chg]stringValue];
	
#else
	
    label.textColor = [ValueUtil colorOfPrice:price refPrice:ref baseColor:[UIColor blueColor]];

    if (compact) {
        label.text = price < 0.1  ? [NSString stringWithFormat:chg?@"%+.3f":@"%.3f", chg] :
        price < 100  ? [NSString stringWithFormat:chg?@"%+.2f":@"%.2f", chg] :
                     price < 1000 ? [NSString stringWithFormat:chg?@"%+.2f":@"%.1f", chg] :
                                    [NSString stringWithFormat:chg?@"%+.2f":@"%.0f", chg];
    }
    else {
        label.text = price < 0.1  ? [NSString stringWithFormat:chg?@"%+.3f":@"%.3f", chg] :
        price < 1000 ? [NSString stringWithFormat:chg?@"%+.2f":@"%.2f", chg] :
                                    [NSString stringWithFormat:chg?@"%+.2f":@"%.1f", chg];
    }
#endif	
}


+ (void)updateChangeLabel:(UILabel *)label withPrice:(double)price refPrice:(double)ref whiteStyle:(BOOL)whiteStyle {

    return [ValueUtil updateChangeLabel:label withPrice:price refPrice:ref whiteStyle:whiteStyle compact:NO];
}

+ (NSString *)stringWithValue:(double)value unit:(UInt8)unit sign:(BOOL)sign
{
    NSArray *textArray = @[@"", @"K", @"M", @"B", @"T", @"Q"];
    NSString *format = sign ? @"%+.2f%@" : @"%.2f%@";
    return [NSString stringWithFormat:format, value, textArray[unit]];
}

+ (NSString *)stringWithValue:(double)value unit:(UInt8)unit font:(UIFont *)font width:(CGFloat)width sign:(BOOL)sign {
	
    const char unitChar[] = { 0, 'K', 'M', 'B', 'T', 'Q' };
    const CGSize infiniteSize = { MAXFLOAT, MAXFLOAT };

    NSString *format = sign ? @"%+.2f%c" : @"%.2f%c";
    CGSize size;
    NSString *str;

    if (unit > 0 && value < 1000 && fmodf(value*1000, 1000) != 0) {
        value *= 1000;
        unit--;
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    while (TRUE) {
        if (value == -0) return @"0";
        str = [NSString stringWithFormat:format, value, unitChar[unit]];

        if (fmodf(value, 1000) != 0 || value < 1000) {

            size = [str  boundingRectWithSize:infiniteSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
            if (size.width < width) break;
        }

        value /= 1000;
        unit++;
    }

    return str;
}


+ (NSString *)stringWithValue:(double)value unit:(UInt8)unit font:(UIFont *)font width:(CGFloat)width {
//neil
    return [ValueUtil stringWithValue:value unit:unit font:font width:width sign:NO];
}


+ (void)updateLabel:(UILabel *)label withValue:(double)value unit:(UInt8)unit {

    if (value == 0) {
        label.text = nil;
        return;
    }

    UIFont *font = [label.font fontWithSize:label.minimumScaleFactor];

    label.text = [ValueUtil stringWithValue:value unit:unit font:font width:label.bounds.size.width];
}

+ (void)updateHaveZeroLabel:(UILabel *)label withValue:(double)value unit:(UInt8)unit
{
    UIFont *font = [label.font fontWithSize:label.minimumScaleFactor];
	
    label.text = [ValueUtil stringWithValue:value unit:unit font:font width:label.bounds.size.width];
}



@end
