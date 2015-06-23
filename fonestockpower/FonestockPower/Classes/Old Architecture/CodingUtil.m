//
//  CodingUtil.m
//  test4
//
//  Created by Yehsam on 2008/11/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CodingUtil.h"
//#import "IPAddress.h"
#ifdef SUPPORT_TRADING
#import "OrderLoadingController.h"
#endif


#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <arpa/inet.h>

#if ! defined(IFT_ETHER)
#define IFT_ETHER 0x6/* Ethernet CSMACD */
#endif

#ifdef BROKER_TDAMERITRADE

#import "TDAmeritradeLoading.h"

#endif

#import <CommonCrypto/CommonDigest.h>

@implementation CodingUtil


+ (NSString *)volumeRoundRownWithDouble:(double)value {
    
    NSString *callBackString;
    NSString *callBackUnitString = @"";
    
    if (value == 0) {
        return @"----";
    }
    
    double inputValue = value;
    
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:inputValue];
    NSNumberFormatter *formatter0 = [[NSNumberFormatter alloc] init];
    [formatter0 setRoundingMode:NSNumberFormatterRoundDown];
    [formatter0 setMinimumFractionDigits:0];
    [formatter0 setMinimumIntegerDigits:1];
    
    NSInteger integerLen;
    if (inputValue >= 0) {
        integerLen = [[formatter0 stringFromNumber:number] length];
    } else {
        integerLen = [[formatter0 stringFromNumber:number] length] - 1;
    }
    
    NSInteger fraction;
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS ||
        [FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        
        if (integerLen >= 10) {
            NSDecimalNumber *div = [[NSDecimalNumber alloc] initWithDouble:1000000000];
            number = [number decimalNumberByDividingBy:div];
            
            NSNumberFormatter *formatter0 = [[NSNumberFormatter alloc] init];
            [formatter0 setRoundingMode:NSNumberFormatterRoundDown];
            [formatter0 setMinimumFractionDigits:0];
            [formatter0 setMinimumIntegerDigits:1];
            
            if (inputValue >= 0) {
                integerLen = [[formatter0 stringFromNumber:number] length];
            } else {
                integerLen = [[formatter0 stringFromNumber:number] length] - 1;
            }
            
            callBackUnitString = @"B";
            fraction = 5 - integerLen - 1;
         
            
        } else if (integerLen >= 7) {
            NSDecimalNumber *div = [[NSDecimalNumber alloc] initWithDouble:1000000];
            number = [number decimalNumberByDividingBy:div];
            
            NSNumberFormatter *formatter0 = [[NSNumberFormatter alloc] init];
            [formatter0 setRoundingMode:NSNumberFormatterRoundDown];
            [formatter0 setMinimumFractionDigits:0];
            [formatter0 setMinimumIntegerDigits:1];
            
            if (inputValue >= 0) {
                integerLen = [[formatter0 stringFromNumber:number] length];
            } else {
                integerLen = [[formatter0 stringFromNumber:number] length] - 1;
            }
            
            callBackUnitString = @"M";
            fraction = 5 - integerLen - 1;
            
        } else if (integerLen >= 6) {
            NSDecimalNumber *div = [[NSDecimalNumber alloc] initWithDouble:1000];
            number = [number decimalNumberByDividingBy:div];
            
            NSNumberFormatter *formatter0 = [[NSNumberFormatter alloc] init];
            [formatter0 setRoundingMode:NSNumberFormatterRoundDown];
            [formatter0 setMinimumFractionDigits:0];
            [formatter0 setMinimumIntegerDigits:1];
            
            if (inputValue >= 0) {
                integerLen = [[formatter0 stringFromNumber:number] length];
            } else {
                integerLen = [[formatter0 stringFromNumber:number] length] - 1;
            }
            
            callBackUnitString = @"K";
            fraction = 5 - integerLen - 1;
            
        } else {
            fraction = 0;
        }
        
    } else {
        
        
        if (integerLen >= 9) {
            NSDecimalNumber *div = [[NSDecimalNumber alloc] initWithDouble:100000000];
            number = [number decimalNumberByDividingBy:div];
            
            NSNumberFormatter *formatter0 = [[NSNumberFormatter alloc] init];
            [formatter0 setRoundingMode:NSNumberFormatterRoundDown];
            [formatter0 setMinimumFractionDigits:0];
            [formatter0 setMinimumIntegerDigits:1];
            
            if (inputValue >= 0) {
                integerLen = [[formatter0 stringFromNumber:number] length];
            } else {
                integerLen = [[formatter0 stringFromNumber:number] length] - 1;
            }
            
            callBackUnitString = @"億";
            fraction = 5 - integerLen - 1;
            
        } else if (integerLen >= 6) {
            NSDecimalNumber *div = [[NSDecimalNumber alloc] initWithDouble:10000];
            number = [number decimalNumberByDividingBy:div];
            
            NSNumberFormatter *formatter0 = [[NSNumberFormatter alloc] init];
            [formatter0 setRoundingMode:NSNumberFormatterRoundDown];
            [formatter0 setMinimumFractionDigits:0];
            [formatter0 setMinimumIntegerDigits:1];
            
            if (inputValue >= 0) {
                integerLen = [[formatter0 stringFromNumber:number] length];
            } else {
                integerLen = [[formatter0 stringFromNumber:number] length] - 1;
            }
            
            callBackUnitString = @"萬";
            fraction = 5 - integerLen - 1;
            
        } else {
            fraction = 0;
        }
        
        
    }
    
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundDown];
    
    [formatter setMinimumFractionDigits:fraction];
    [formatter setMinimumIntegerDigits:1];
    
    callBackString = [formatter stringFromNumber:number];
    
//    NSLog(@"%@", [NSString stringWithFormat:@"%@%@", callBackString, callBackUnitString]);
    
    return [NSString stringWithFormat:@"%@%@", callBackString, callBackUnitString];
}

// 價格用
+ (NSString *)priceRoundRownWithDouble:(double)value {
    
    NSString *callBackString;
    NSString *callBackUnitString;
    
    double inputValue = value;
    
    NSNumber *number = [NSNumber numberWithDouble:inputValue];
    
    NSNumberFormatter *formatter0 = [[NSNumberFormatter alloc] init];
    [formatter0 setRoundingMode:NSNumberFormatterRoundDown];
    [formatter0 setMinimumFractionDigits:0];
    [formatter0 setMinimumIntegerDigits:1];
    
    NSInteger integerLen;
    if (inputValue >= 0) {
        integerLen = [[formatter0 stringFromNumber:number] length];
    } else {
        integerLen = [[formatter0 stringFromNumber:number] length] - 1;
    }
    
    NSInteger fraction = 5 - integerLen;
    
    if (fraction > 2) {
        fraction = 2;
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundDown];
    
    [formatter setMinimumFractionDigits:fraction];
    [formatter setMinimumIntegerDigits:1];
    
    callBackString = [formatter stringFromNumber:number];
    callBackUnitString = @"";
    
    return [NSString stringWithFormat:@"%@%@", callBackString, callBackUnitString];
}









+ (NSString *)hexadecimalString:(UInt8)bytes BytesLength:(NSUInteger)bytesLength
{
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = &bytes;
    
    if (!dataBuffer)
    {
        return [NSString string];
    }
    
    NSUInteger          dataLength  = bytesLength;
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
    {
        if(i % 2 == 0 && i != 0)
           [hexString appendFormat:@" "];
        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }
    
    return [NSString stringWithString:hexString];
}

// value 原始數值, scale小數幾位, digitCount 最多幾位數字
+ (NSString *)valueRoundDownAndChangeUnitWithDouble:(double)value scale:(short)scale digitsCount:(int)digitsCount {
    
    NSDecimalNumberHandler *handler;
    if (value >= 0) {
        handler = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundDown scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    } else {
        handler = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundUp scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    }
    
    NSDecimalNumber *decimalInput, *decimalOutput;
    
    NSString *callBackString;
    NSString *callBackUnitString;
    
    double preCalc;
    
    
    switch ([FSFonestock sharedInstance].marketVersion) {
        case FSMarketVersionUS:
            
            if (pow(10, digitsCount) > value) {
                preCalc = value;
                callBackUnitString = @"";
            } else if (value >= pow(10, 9)) {
                // 美股 十億
                preCalc = value / pow(10, 9);
                callBackUnitString = @"B";
                
            } else if (value >= pow(10, 6)) {
                // 台股 百萬
                preCalc = value / pow(10, 6);
                callBackUnitString = @"M";
                
            } else if (value >= pow(10, 3)) {
                // 台股 千
                preCalc = value / pow(10, 3);
                callBackUnitString = @"K";
            } else {
                preCalc = value;
                callBackUnitString = @"";
            }
            
            break;
            
        case FSMarketVersionCN:
            
            if (pow(10, digitsCount) > value) {
                preCalc = value;
                callBackUnitString = @"";
            } else if (value >= pow(10, 9)) {
                // 美股 十億
                preCalc = value / pow(10, 9);
                callBackUnitString = @"B";
                
            } else if (value >= pow(10, 6)) {
                // 台股 百萬
                preCalc = value / pow(10, 6);
                callBackUnitString = @"M";
                
            } else if (value >= pow(10, 3)) {
                // 台股 千
                preCalc = value / pow(10, 3);
                callBackUnitString = @"K";
            } else {
                preCalc = value;
                callBackUnitString = @"";
            }
            
            break;
            
        case FSMarketVersionTW:
            
            if (pow(10, digitsCount) > value) {
                preCalc = value;
                callBackUnitString = @"";
            } else if (value >= pow(10, 8)) {
                // 台股 億
                preCalc = value / pow(10, 8);
                callBackUnitString = @"億";
            } else if (value >= pow(10, 6)) {
                // 台股 百萬
                preCalc = value / pow(10, 6);
                callBackUnitString = @"百萬";
            } else if (value >= pow(10, 4)) {
                // 台股 萬
                preCalc = value / pow(10, 4);
                callBackUnitString = @"萬";
            } else {
                preCalc = value;
                callBackUnitString = @"";
            }
            
            break;
            
        default:
            return @"----";
            break;
    }
    
    
    decimalInput = [[NSDecimalNumber alloc] initWithDouble:preCalc];
    decimalOutput = [decimalInput decimalNumberByRoundingAccordingToBehavior:handler];
    callBackString = [decimalOutput stringValue];
    
    while ([callBackString length] > digitsCount) {
        NSRange range = [callBackString rangeOfString:@"."];
        if (range.location != NSNotFound) {
            callBackString = [callBackString substringToIndex:[callBackString length] -1];
        }
    }
    
    if ([callBackString hasSuffix:@"."]) {
        callBackString = [callBackString substringToIndex:[callBackString length] - 1];
    }
    
    if ([callBackUnitString length] > 0) {
        NSRange range = [callBackString rangeOfString:@"."];
        if (range.location == NSNotFound) {
            callBackString = [callBackString stringByAppendingString:@".0"];
        }
    }
    
    return [NSString stringWithFormat:@"%@%@", callBackString, callBackUnitString];
}









+ (NSString *)hashed_string:(NSString *)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes,(int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}


+ (NSString *)md5:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

+ (UInt16)getUInt8:(UInt8 **)buffer needOffset:(BOOL)needOffset {
    UInt8 *buf = *buffer;
    UInt8 val = *buf;
    
    if (needOffset) {
        *buffer += 1;
    }
	
	return val;
}

+ (UInt16)getUInt16:(UInt8 **)buffer needOffset:(BOOL)needOffset {
    UInt8 *buf = *buffer;
    UInt8 a = *buf++;
    UInt8 b = *buf;
    
    if (needOffset) {
        *buffer += 2;
    }
	return (a << 8) + b;
}

+ (void)setUInt8:(char **)buffer value:(UInt8)val needOffset:(BOOL)needOffset {
    char *buf = *buffer;
	*buf = (char)val;
    
    if (needOffset) {
        *buffer += 1;
    }
}

+ (void)setUInt16:(char **)buffer value:(UInt16)val needOffset:(BOOL)needOffset {
    char *buf = *buffer;
	*buf++ = (char)(val >> 8);
	*buf = (char)val;
    
    if (needOffset) {
        *buffer += 2;
    }
}

+ (void)setUInt32:(char **)buffer value:(UInt32)val needOffset:(BOOL)needOffset {
    char *buf = *buffer;
    *buf++ = (char)(val >> 24);
	*buf++ = (char)(val >> 16);
	*buf++ = (char)(val >> 8);
	*buf = (char)val;
    
    if (needOffset) {
        *buffer += 4;
    }
}

// 用來取得ShortStringFormat, 並且可以直接offset
+ (NSString *)getShortStringFormatByBuffer:(UInt8 **)buffer needOffset:(BOOL)needOffset {
    
    NSString *retString = [NSString string];
    
    UInt16 messageLen = [CodingUtil getUInt8:buffer needOffset:YES];
    
    if (messageLen) {
        retString = [[NSString alloc] initWithBytes:*buffer length:messageLen encoding:NSUTF8StringEncoding];
        if (needOffset) {
            *buffer += messageLen;
        }
    }
    return retString;
}

// 用來取得LongStringFormat, 並且可以直接offset
+ (NSString *)getLongStringFormatByBuffer:(UInt8 **)buffer needOffset:(BOOL)needOffset {
    
    NSString *retString = [NSString string];
    
    UInt16 messageLen = [CodingUtil getUInt16:buffer needOffset:YES];
    
    if (messageLen) {
        retString = [[NSString alloc] initWithBytes:*buffer length:messageLen encoding:NSUTF8StringEncoding];
        if (needOffset) {
            *buffer += messageLen;
        }
    }
    return retString;
}

// 用來取得ShortStringFormat, 並且可以直接offset
+ (NSString *)getShortStringFormatByBuffer:(UInt8 *)buffer bitOffset:(int *)bitOffset {
    
    NSString *retString = [NSString string];
    
    int tmpSize = [CodingUtil getUint8FromBuf:buffer Offset:*bitOffset Bits:8];
    *bitOffset+=8;
    
    if (tmpSize) {
        UInt8 *tmp = malloc(tmpSize);
        for (int i = 0;i < tmpSize; i++) {
            tmp[i] = [CodingUtil getUint8FromBuf:buffer Offset:*bitOffset Bits:8];
            *bitOffset+=8;
        }
        retString = [[NSString alloc] initWithBytes:tmp length:tmpSize encoding:NSUTF8StringEncoding];
        free(tmp);
    }
    return retString;
}

// 用來取得LongStringFormat, 並且可以直接offset
+ (NSString *)getLongStringFormatByBuffer:(UInt8 *)buffer bitOffset:(int *)bitOffset {
    
    NSString *retString = [NSString string];
    
    int tmpSize = [CodingUtil getUint16FromBuf:buffer Offset:*bitOffset Bits:16];
    *bitOffset+=16;
    
    if (tmpSize) {
        UInt8 *tmp = malloc(tmpSize);
        for (int i = 0;i < tmpSize; i++) {
            tmp[i] = [CodingUtil getUint8FromBuf:buffer Offset:*bitOffset Bits:8];
            *bitOffset+=8;
        }
        retString = [[NSString alloc] initWithBytes:tmp length:tmpSize encoding:NSUTF8StringEncoding];
        free(tmp);
    }
    return retString;
}


+ (BOOL) DateIsTodayDateWithYear:(UInt16)year month:(UInt8)month day:(UInt8)day
{
	
	NSDateComponents *todayDate = [[NSCalendar currentCalendar] 
								   components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
	
	
	BOOL isTodayOpenDate = NO;
	if([todayDate day] == day && [todayDate month] == month && [todayDate year] == year) 
	{
		//do stuff
		isTodayOpenDate = YES;
		NSLog(@"today");
	}
	
	return isTodayOpenDate;
}

+ (void)setUInt8 : (char *)buff value: (UInt8)val
{
    *buff = (char)val;
}


+ (void)setUInt16 : (char*)buff Value: (UInt16)val
{	
	*buff++ = (char)(val >> 8);
	*buff = (char)val;
}

+ (void)setUInt32 : (char*)buff Value:(UInt32)val;
{
	*buff++ = (char)(val >> 24);
	*buff++ = (char)(val >> 16);
	*buff++ = (char)(val >> 8);
	*buff = (char)val;
}

+ (UInt16)getUInt16 : (void *)buf
{
	UInt8 *p = buf;
	UInt16 val = *p++;
	
	return (val << 8) + *p;
}

+ (UInt32)getUInt32 : (void *)buf
{
	UInt8 *p = buf;
	UInt32 val = *p++;

	for (int i = 0; i < 3; i++)
		val = (val << 8) + (*p++);
	
	return val;
}

+ (UInt64)getUInt64 : (void *)buf
{
	UInt8 *p = buf;
	UInt64 val = *p++;
	
	for (int i = 0; i < 7; i++)
		val = (val << 8) + (*p++);
	
	return val;
}


+ (void)setBufferr:(UInt32)val Bits:(NSInteger)bits Buffer:(void *)buf Offset:(NSInteger)off
{
	UInt8 *p = buf;
	UInt32 mask = 0xffffffff;
	NSInteger bitOff = off%8;
	p += off/8;

	UInt32 value = [self getUInt32:p];
	
	NSInteger shift = 8*sizeof(UInt32) - bitOff - bits;

	mask = ((mask << bitOff) >> bitOff);
	mask = ((mask >> shift) << shift);
	val <<= shift;
	val &= mask;
	value &= ~mask;
	value |= val;
	
	[self setUInt32:(char *)p Value:value];
}




+ (UInt16) makeDate:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
	UInt16 newDate=0;
	newDate+= (year-1960)<<9;
	newDate+= month<<5;
	newDate+= day;   
	return newDate;    //High-endian
}

+ (void) getDate:(UInt16)date year:(UInt16*)y month:(UInt8*)m day:(UInt8*)d
{
	UInt16 val = [self getUInt16:&date];
	*y = [self getUint8FromBuf:&val Offset:0 Bits:7] + 1960;
	*m = [self getUint8FromBuf:&val Offset:7 Bits:4];
	*d = [self getUint8FromBuf:&val Offset:11 Bits:5];
	
}

+ (void) getDateNew:(UInt16)date year:(UInt16*)y month:(UInt8*)m day:(UInt8*)d
{
    UInt16 val = [self getUInt16:&date];
    *y = [self getUint8FromBuf:&val Offset:0 Bits:7] + 2000;
    *m = [self getUint8FromBuf:&val Offset:7 Bits:4];
    *d = [self getUint8FromBuf:&val Offset:11 Bits:5];
    
}

+ (NSString*) getStringDate:(UInt16)rdate
{
	UInt16 year;
	UInt8 month,day;
	[CodingUtil getDate:rdate year:&year month:&month day:&day];
	if(month == 0 || day == 0 || rdate == 0)
		return @"---/--- (---)";
	NSDateComponents *dayComps = [[NSDateComponents alloc] init];
	[dayComps setDay:day];
	[dayComps setMonth:month];
	[dayComps setYear:year];
    return [NSString stringWithFormat:@"%d/%d/%d", year, month, day];
}

+ (NSString*) getStringDateNew:(UInt16)rdate
{
    UInt16 year;
    UInt8 month,day;
    [CodingUtil getDateNew:rdate year:&year month:&month day:&day];
    if(month == 0 || day == 0 || rdate == 0)
        return @"---/--- (---)";
    NSDateComponents *dayComps = [[NSDateComponents alloc] init];
    [dayComps setDay:day];
    [dayComps setMonth:month];
    [dayComps setYear:year];
    return [NSString stringWithFormat:@"%d/%02d/%02d", year, month, day];
}

//yearsOffSet 1960 to 2000;
+ (UInt16 )dateConvertToNewDate:(UInt16)rdate
{
    UInt16 year;
    UInt8 month,day;
    [CodingUtil getDate:rdate year:&year month:&month day:&day];

    NSDateComponents *dayComps = [[NSDateComponents alloc] init];
    [dayComps setDay:day];
    [dayComps setMonth:month];
    [dayComps setYear:year];
    
    UInt16 newDate = 0;
    newDate += (year - 2000) << 9;
    newDate += month << 5;
    newDate += day;
    return newDate;

}

//轉換日期後 月 , 日 補足兩位數
+ (NSString*) getStringDatePlusZero:(UInt16)rdate
{
    UInt16 year;
    UInt8 month,day;
    [CodingUtil getDate:rdate year:&year month:&month day:&day];
    if(month == 0 || day == 0 || rdate == 0)
        return @"--------";
    NSDateComponents *dayComps = [[NSDateComponents alloc] init];
    [dayComps setDay:day];
    [dayComps setMonth:month];
    [dayComps setYear:year];
    //	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //	NSDate *date = [gregorian dateFromComponents:dayComps];
    //
    //	NSDateComponents *comps = [gregorian components:(NSWeekdayCalendarUnit) fromDate:date];
    //	UInt8 weekDay = [comps weekday];
    //	NSString *weekDayString;
    //	if(weekDay==1) weekDayString = @"日";
    //	else if(weekDay==2) weekDayString = @"一";
    //	else if(weekDay==3) weekDayString = @"二";
    //	else if(weekDay==4) weekDayString = @"三";
    //	else if(weekDay==5) weekDayString = @"四";
    //	else if(weekDay==6) weekDayString = @"五";
    //	else if(weekDay==7) weekDayString = @"六";
    
    //	return [NSString stringWithFormat:@"%02d/%02d (%@)",month,day,weekDayString];

    return [NSString stringWithFormat:@"%d/%02d/%02d", year, month, day];
}


+ (NSString*)getStringDate2:(UInt16)rdate
{
    UInt16 year;
    UInt8 month,day;
    [CodingUtil getDate:rdate year:&year month:&month day:&day];
    if(month == 0 || day == 0 || rdate == 0)
        return @"---/---";
    NSDateComponents *dayComps = [[NSDateComponents alloc] init];
    [dayComps setDay:day];
    [dayComps setMonth:month];
    [dayComps setYear:year];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:dayComps];
    
    NSDateComponents *comps = [gregorian components:(NSWeekdayCalendarUnit) fromDate:date];
	UInt8 weekDay = [comps weekday];
	NSString *weekDayString;
	if (weekDay==1) weekDayString = @"日";
	else if(weekDay==2) weekDayString = @"一";
	else if(weekDay==3) weekDayString = @"二";
	else if(weekDay==4) weekDayString = @"三";
	else if(weekDay==5) weekDayString = @"四";
	else if(weekDay==6) weekDayString = @"五";
	else if(weekDay==7) weekDayString = @"六";

	return [NSString stringWithFormat:@"%02d/%02d (%@)",month,day,weekDayString];
}




+ (UInt16)makeDateFromDate:(NSDate *)date
{
	UInt16 retDate;
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
//	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSUInteger unitFlags = NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
	NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
	
	retDate = (UInt16)[CodingUtil makeDate:(int)comps.year month:(int)comps.month day:(int)comps.day];

//	[comps release];
	
	return retDate;
}

+ (NSString *) getMacroeconomicValue:(double)value
{
    NSString *valueStr;
    if(value >= 100000 || value <= -100000){
        valueStr = [NSString stringWithFormat:@"%.0fK",value / 1000];
    }else{
        valueStr = [NSString stringWithFormat:@"%.2f", value];
    }
    
    
    return valueStr;
}


+ (NSString*) getValueUnitString:(double)value Unit:(UInt8)unit
{
	if([[[NSNumber numberWithDouble:value] stringValue] isEqualToString:@"-0"] || [[NSNumber numberWithDouble:value] isEqualToNumber:(NSNumber*)kCFNumberNaN]) 
		return @"----";

	//
	if((fabs(value)*pow(1000,unit)>1000000) && unit <= 1)
	{
		value = value/1000000;
		unit = unit + 2;
	}
	
	if(unit > 1) 
	{
		if(fabs((value*pow(1000,unit-2)-(int)(value*pow(1000,unit-2)))) < 0.001) //當做整數看
			return [NSString stringWithFormat:@"%.0lfM",value*pow(1000,unit-2)];
		else 
			return [NSString stringWithFormat:@"%.2lfM",floor(value*100)/100*pow(1000,unit-2)];
	}
	else
	{
		if(fabs((value*pow(1000,unit)-(int)(value*pow(1000,unit)))) < 0.001)
			return [NSString stringWithFormat:@"%.0lf",value*pow(1000,unit)];
		else 
			return [NSString stringWithFormat:@"%.2lf",floor(value*100)/100*pow(1000,unit)];
	}
}

+(NSString *)getValueString:(double)value Unit:(UInt8)unit{
    if([[[NSNumber numberWithDouble:value] stringValue] isEqualToString:@"-0"] || [[NSNumber numberWithDouble:value] isEqualToNumber:(NSNumber*)kCFNumberNaN])
		return @"----";
    
	//
	if((fabs(value)*pow(1000,unit)>=1000000) && unit <= 1)
	{
		value = value/1000000;
		unit = unit + 2;
	}
	
	if(unit > 1)
	{
        return [NSString stringWithFormat:@"%.2lf",value*pow(1000,unit-2)];
	}
	else
	{
        return [NSString stringWithFormat:@"%.2lf",value*pow(1000,unit)];
	}
}
+ (NSString*)getValueToPrecent:(double)value
{
    NSString *precent = [NSString stringWithFormat:@"%.2f%%", value *100];
    return precent;
}

+(NSString *)getValueString_2:(double)value Unit:(UInt8)unit{
    if([[[NSNumber numberWithDouble:value] stringValue] isEqualToString:@"-0"] || [[NSNumber numberWithDouble:value] isEqualToNumber:(NSNumber*)kCFNumberNaN])
		return @"----";
    
	//
	if((fabs(value)*pow(1000,unit)>1000000) && unit <= 1)
	{
		value = value/1000000;
		unit = unit + 2;
	}
	
	if(unit > 1)
	{
        if(value*pow(1000,unit-2) >= 10000){
            return [NSString stringWithFormat:@"%.0lf",value*pow(1000,unit-2)];
        }else if(value*pow(1000,unit-2) >= 1000){
            return [NSString stringWithFormat:@"%.1lf",value*pow(1000,unit-2)];
        }else{
            return [NSString stringWithFormat:@"%.2lf",value*pow(1000,unit-2)];
        }
	}
	else
	{
        if(value*pow(1000,unit) >=10000){
            return [NSString stringWithFormat:@"%.0lf",value*pow(1000,unit)];
        }else if(value*pow(1000,unit) >=1000){
            return [NSString stringWithFormat:@"%.1lf",value*pow(1000,unit)];
        }else if(value*pow(1000,unit) >=1){
            return [NSString stringWithFormat:@"%.2lf",value*pow(1000,unit)];
        }else{
            return [NSString stringWithFormat:@"%.3lf",value*pow(1000,unit)];
        }
        
	}
}

+ (NSString*) getMarketValue:(double)value
{
    double marketValue = value;
    if (marketValue>1 && marketValue<1000){
        return [NSString stringWithFormat:@"%.2f", marketValue];
    }else if(marketValue>1000 && marketValue<1000000){
        marketValue = marketValue * 0.001;
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"計算千", @"Equity", nil), marketValue];
    }else if(marketValue>1000000 && marketValue<1000000000){
        marketValue = marketValue * 0.000001;
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"計算百萬", @"Equity", nil), marketValue];
    }else if(marketValue>1000000000 && marketValue<1000000000000){
        marketValue = marketValue * 0.000000001;
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"計算十億", @"Equity", nil), marketValue];
    }else if(marketValue>1000000000000 && marketValue<1000000000000000){
        marketValue = marketValue * 0.000000000001;
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"計算兆", @"Equity", nil), marketValue];
    }else{
        return [NSString stringWithFormat:@"%.2f", marketValue];
    }
}

+ (UInt8) getUint8FromBuf:(void *)buf Offset:(int)off Bits:(int)bits
{
	UInt16 val;
	int startbit;
	UInt8 *p = buf;
	NSAssert(bits <= 8, @"getUInt8FromBuf:OffsetBits request bits too long");
	p += off/8;
	val = [self getUInt16:p];
	startbit = off%8;
	val <<= startbit;
	val >>= 16 - bits;
	return val;
}

+ (UInt16) getUint16FromBuf:(void *)buf Offset:(int)off Bits:(int)bits
{
	UInt32 val;
	int startbit;
	UInt8 *p = buf;
	NSAssert(bits <= 16, @"getUInt8FromBuf:OffsetBits request bits too long");
	p += off/8;
	val = [self getUInt32:p];
	startbit = off%8;
	val <<= startbit;
	val >>= 32 - bits;
	return val;
}

+ (UInt32) getUint32FromBuf:(void *)buf Offset:(int)off Bits:(int)bits
{
	UInt64 val;
	int startbit;
	UInt8 *p = buf;
	NSAssert(bits <= 32, @"getUInt8FromBuf:OffsetBits request bits too long");

	p += off/8;
	val = [self getUInt64:p];
	startbit = off%8;
	val <<= startbit;
	val >>= 64 - bits;
	return (UInt32)val;
}

+ (UInt64) getUint64FromBuf:(void *)buf Offset:(int)off Bits:(int)bits
{
	UInt64 val;
	int startbit;
	UInt8 *p = buf;
	NSAssert(bits <= 64, @"getUInt64FromBuf:OffsetBits request bits too long");

	p += off/8;
	val = [self getUInt64:p];
	startbit = off%8;
	val <<= startbit;
	val >>= 64 - bits;
	return val;
}

+ (void)updateVolume:(double *)pVol Unit:(UInt16 *)pUnit WithVolume:(double)vol Unit:(UInt16)unit
{
	UInt16 lastUnit;
	double accumulateVol = *pVol;
	double updateVol = vol;
	
	// Adjust both volume value to the same unit.
	if (*pUnit < unit)
	{
		lastUnit = unit;
		for (int i = 0; i < lastUnit - *pUnit; i++)
			accumulateVol /= 1000;
	}
	else
	{
		lastUnit = *pUnit;
		for (int i = 0; i < lastUnit - unit; i++)
			updateVol /= 1000;
	}
	*pUnit = lastUnit;
	
	// Compare volumes to find if the updated one is accumulated value or not.
	if (updateVol >= accumulateVol)
		*pVol = updateVol;
	else
		*pVol += updateVol;
}

+ (UInt16) getTimeFormat2Value:(void *)buf Offset:(int*)off
{
	UInt16 val;
	int offset = *off;
	if([CodingUtil getUint8FromBuf:buf Offset:offset++ Bits:1]){
		val = [self getUint16FromBuf:buf Offset:offset Bits:12];
		val = val | 0x8000;
		offset+=12;
	}
	else{
		val = [self getUint16FromBuf:buf Offset:offset Bits:9];
		offset+=9;
	}
	*off = offset;
	return val;
}

+ (UInt16) getTickSNValue:(void *)buf Offset:(int*)off
{
	UInt16 val;
	int offset = *off;
	if([self getUint8FromBuf:buf Offset:offset++ Bits:1]){
		if([self getUint8FromBuf:buf Offset:offset++ Bits:1]){
			val = [CodingUtil getUint16FromBuf:buf Offset:offset Bits:13] + 1280;
			offset+=13;
		}
		else{
			val = [CodingUtil getUint16FromBuf:buf Offset:offset Bits:10] + 256;
			offset+=10;
		}
	}
	else{
		val = [CodingUtil getUint8FromBuf:buf Offset:offset Bits:8];
		offset+=8;
	}
	*off = offset;
	return val;
}


+ (double) getPriceFormatValue:(void *)buf Offset:(int*)off TAstruct:(PriceFormatRef)pr
{
	
	/*
	 typedef struct _priceFormat {
	 UInt8 type;
	 int significand;
	 UInt8 exponent;
	 }PriceFormatData,*PriceFormatRef;	 
	 */
	
	int offset = *off;
	double val;
	pr->type = [self getUint8FromBuf:buf Offset:offset Bits:3];
	offset+=3;
	if(pr->type == 0){
		pr->significand = [self getUint8FromBuf:buf Offset:offset Bits:8];
		offset+=8;
	}
	else if(pr->type == 1){
		pr->significand = [self getUint16FromBuf:buf Offset:offset Bits:16]+256;
		offset+=16;
	}
	else if(pr->type == 2){
		pr->significand = [self getUint32FromBuf:buf Offset:offset Bits:24]+65792;
		offset+=24;
	}
	else if(pr->type == 3){
		pr->significand = 0;
		pr->exponent =0;
	}
	else if(pr->type == 4){
		pr->significand = [self getUint8FromBuf:buf Offset:offset Bits:2];
		if(pr->significand == 0)
			pr->significand = 1;
		else if(pr->significand == 2)
			pr->significand = -1;
		else if(pr->significand == 1)
			pr->significand = 5;
		else if(pr->significand == 3)
			pr->significand = -5;
		offset+=2;		
	}
	else if(pr->type == 5){
		pr->significand = [self getUint8FromBuf:buf Offset:offset Bits:3];
		if((pr->significand)>=0 && (pr->significand)<3)
			pr->significand+=2;
		else if(pr->significand == 3)
			pr->significand = 6;
		else if((pr->significand)>3 && (pr->significand)<7)
			pr->significand = (pr->significand*(-1)) + 2;
		else
			pr->significand = -6;
		offset+=3;
	}
	else if(pr->type == 6){
		pr->significand = [self getUint8FromBuf:buf Offset:offset Bits:5];
		if((pr->significand)>=0 && (pr->significand)<16)
			pr->significand+=7;
		else
			pr->significand = (pr->significand*(-1)) + 9;
		offset+=5;
	}
	else if(pr->type == 7){
		pr->significand = [self getUint16FromBuf:buf Offset:offset Bits:12];
		if((pr->significand)>=0 && (pr->significand)<2048)
			pr->significand+=23;
		else
			pr->significand = (pr->significand*(-1)) + 2025;
		offset+=12;
	}
	// get exponent
	if(pr->type != 3){
		pr->exponent = [self getUint8FromBuf:buf Offset:offset Bits:3];
		offset+=3;
	}
	// get value
	if(pr->exponent < 5){
		val = pr->significand * pow(10,((-1)*pr->exponent));
	}
	else val = pr->significand;
	*off = offset;
	return val;
}

+ (double) getTAvalueFormatValue:(void *)buf Offset:(int*)off TAstruct:(TAvalueFormatRef)ta
{
	int offset = *off;
	double val;
	ta->type = [self getUint8FromBuf:buf Offset:offset Bits:3];
	offset+=3;
	ta->sign = [self getUint8FromBuf:buf Offset:offset++ Bits:1];
	if(ta->type == 0){
		ta->value = [self getUint8FromBuf:buf Offset:offset Bits:5];
		offset+=5;
	}
	else if(ta->type == 1){
		ta->value = [self getUint16FromBuf:buf Offset:offset Bits:10] + 32;
		offset+=10;		
	}
	else if(ta->type == 2){
		ta->value = [self getUint16FromBuf:buf Offset:offset Bits:15] + 1056;
		offset+=15;		
	}
	else if(ta->type == 3){
		ta->value = [self getUint32FromBuf:buf Offset:offset Bits:20] + 33824;
		offset+=20;		
	}
	else if(ta->type == 4){
		ta->value = [self getUint32FromBuf:buf Offset:offset Bits:25] + 1082400;
		offset+=25;		
	}
	else if(ta->type == 5){
		ta->value = [self getUint16FromBuf:buf Offset:offset Bits:14];
		offset+=14;		
	}
	else if(ta->type == 6){
		ta->value = [self getUint32FromBuf:buf Offset:offset Bits:17];
		offset+=17;		
	}
	else if(ta->type == 7){
		ta->value = [self getUint32FromBuf:buf Offset:offset Bits:20];
		offset+=20;		
	}
	if((ta->type)>4 && (ta->type)<8)
	{
		ta->magnitude = [self getUint8FromBuf:buf Offset:offset Bits:3];
		offset+=3;
	}
	if((ta->type)>4 && (ta->type)<8){
        if(ta->magnitude == 4)
			val = ta->value * 0.1;
		else if(ta->magnitude == 4)
			val = ta->value * 0.1;
		else if(ta->magnitude == 5)
			val = ta->value * 0.01;
		else if(ta->magnitude == 6)
			val = ta->value * 0.001;
		else if(ta->magnitude == 7)
			val = ta->value * 0.0001;
		else
			val = ta->value * 0.001;
	}
	else val = ta->value;
	if(ta->magnitude>3 || (ta->type)<5 ) ta->magnitude = 0;
	else ta->magnitude++;
	if(ta->sign)
		val*=(-1);
	*off = offset;
	return val;
}

+ (double) getTAvalue:(void *)buf Offset:(int*)off TAstruct:(TAvalueFormatRef)ta
{
	int offset = *off;
	double val;
	ta->type = [self getUint8FromBuf:buf Offset:offset Bits:3];
	offset+=3;
	ta->sign = [self getUint8FromBuf:buf Offset:offset++ Bits:1];
	if(ta->type == 0){
		ta->value = [self getUint8FromBuf:buf Offset:offset Bits:5];
		offset+=5;
	}
	else if(ta->type == 1){
		ta->value = [self getUint16FromBuf:buf Offset:offset Bits:10] + 32;
		offset+=10;
	}
	else if(ta->type == 2){
		ta->value = [self getUint16FromBuf:buf Offset:offset Bits:15] + 1056;
		offset+=15;
	}
	else if(ta->type == 3){
		ta->value = [self getUint32FromBuf:buf Offset:offset Bits:20] + 33824;
		offset+=20;
	}
	else if(ta->type == 4){
		ta->value = [self getUint32FromBuf:buf Offset:offset Bits:25] + 1082400;
		offset+=25;
	}
	else if(ta->type == 5){
		ta->value = [self getUint16FromBuf:buf Offset:offset Bits:14];
		offset+=14;
	}
	else if(ta->type == 6){
		ta->value = [self getUint32FromBuf:buf Offset:offset Bits:17];
		offset+=17;
	}
	else if(ta->type == 7){
		ta->value = [self getUint32FromBuf:buf Offset:offset Bits:20];
		offset+=20;
	}
	if((ta->type)>4 && (ta->type)<8)
	{
		ta->magnitude = [self getUint8FromBuf:buf Offset:offset Bits:3];
		offset+=3;
	}
	if((ta->type)>4 && (ta->type)<8){
        val = ta->value;
        if (ta->magnitude ==0)
            val = (ta->value * 0.001) * 1000;
        else if (ta->magnitude ==1)
            val = (ta->value * 0.001) * 1000000;
        else if (ta->magnitude ==2)
            val = (ta->value * 0.001) * 1000000000;
        else if (ta->magnitude ==3)
            val = (ta->value * 0.001) * 1000000000000;
		else if(ta->magnitude == 4)
			val = ta->value * 0.1;
		else if(ta->magnitude == 5)
			val = ta->value * 0.01;
		else if(ta->magnitude == 6)
			val = ta->value * 0.001;
		else if(ta->magnitude == 7)
			val = ta->value * 0.0001;
	}
	else val = ta->value;
	if(ta->magnitude>3 || (ta->type)<5 ) ta->magnitude = 0;
	else ta->magnitude++;
	if(ta->sign)
		val*=(-1);
	*off = offset;
	return val;
}


+ (NSString *) getTAvalueFormatString:(void *)buf Offset:(int)off TAstruct:(TAvalueFormatRef)ta
{
	int offset = off;
	double val;
    NSString * unit=nil;
	ta->type = [self getUint8FromBuf:buf Offset:offset Bits:3];
	offset+=3;
	ta->sign = [self getUint8FromBuf:buf Offset:offset++ Bits:1];
	if(ta->type == 0){
		ta->value = [self getUint8FromBuf:buf Offset:offset Bits:5];
		offset+=5;
	}
	else if(ta->type == 1){
		ta->value = [self getUint16FromBuf:buf Offset:offset Bits:10] + 32;
		offset+=10;
	}
	else if(ta->type == 2){
		ta->value = [self getUint16FromBuf:buf Offset:offset Bits:15] + 1056;
		offset+=15;
	}
	else if(ta->type == 3){
		ta->value = [self getUint32FromBuf:buf Offset:offset Bits:20] + 33824;
		offset+=20;
	}
	else if(ta->type == 4){
		ta->value = [self getUint32FromBuf:buf Offset:offset Bits:25] + 1082400;
		offset+=25;
	}
	else if(ta->type == 5){
		ta->value = [self getUint16FromBuf:buf Offset:offset Bits:14];
		offset+=14;
	}
	else if(ta->type == 6){
		ta->value = [self getUint32FromBuf:buf Offset:offset Bits:17];
		offset+=17;
	}
	else if(ta->type == 7){
		ta->value = [self getUint32FromBuf:buf Offset:offset Bits:20];
		offset+=20;
	}
	if((ta->type)>4 && (ta->type)<8)
	{
		ta->magnitude = [self getUint8FromBuf:buf Offset:offset Bits:3];
		offset+=3;
	}
	if((ta->type)>4 && (ta->type)<8){
        val = ta->value * 0.001;
        if(ta->magnitude == 0){
			unit = @"K";
        }else if(ta->magnitude == 1){
            unit = @"M";
        }else if(ta->magnitude == 2){
            unit = @"B";
        }else if(ta->magnitude == 3){
            unit = @"T";
		}else if(ta->magnitude == 4){
			val = ta->value * 0.1;
		}else if(ta->magnitude == 5){
			val = ta->value * 0.01;
		}else if(ta->magnitude == 6){
			val = ta->value * 0.001;
		}else if(ta->magnitude == 7){
			val = ta->value * 0.0001;
		}
	}
	else val = ta->value;
	if(ta->magnitude>3 || (ta->type)<5 ) ta->magnitude = 0;
	else ta->magnitude++;
	if(ta->sign)
		val*=(-1);

    NSString * taValueStr = [NSString stringWithFormat:@"%.2f%@", val, unit];
	return taValueStr;
}


+ (double) ConvertPrice:(UInt32)value RefPrice:(double)refPrice
{
	int offset = 0;
	UInt8 *buf = (UInt8*)&value;
	int tmpVal;
	UInt8 tmpType = 0,tmpExp = 0;
	double val;
	tmpType = [self getUint8FromBuf:buf Offset:offset Bits:3];
	offset+=3;
	if(tmpType == 0){
		tmpVal = [self getUint8FromBuf:buf Offset:offset Bits:8];
		offset+=8;
	}
	else if(tmpType == 1){
		tmpVal = [self getUint16FromBuf:buf Offset:offset Bits:16]+256;
		offset+=16;
	}
	else if(tmpType == 2){
		tmpVal = [self getUint32FromBuf:buf Offset:offset Bits:24]+65792;
		offset+=24;
	}
	else if(tmpType == 3){
		tmpVal = 0;
		tmpExp =0;
	}
	else if(tmpType == 4){
		tmpVal = [self getUint8FromBuf:buf Offset:offset Bits:2];
		if(tmpVal == 0)
			tmpVal = 1;
		else if(tmpVal == 2)
			tmpVal = -1;
		else if(tmpVal == 1)
			tmpVal = 5;
		else if(tmpVal == 3)
			tmpVal = -5;
		offset+=2;		
	}
	else if(tmpType == 5){
		tmpVal = [self getUint8FromBuf:buf Offset:offset Bits:3];
		if((tmpVal)>=0 && (tmpVal)<3)
			tmpVal+=2;
		else if(tmpVal == 3)
			tmpVal = 6;
		else if((tmpVal)>3 && (tmpVal)<7)
			tmpVal = (tmpVal*(-1)) + 2;
		else
			tmpVal = -6;
		offset+=3;
	}
	else if(tmpType == 6){
		tmpVal = [self getUint8FromBuf:buf Offset:offset Bits:5];
		if((tmpVal)>=0 && (tmpVal)<16)
			tmpVal+=7;
		else
			tmpVal = (tmpVal*(-1)) + 9;
		offset+=5;
	}
	else if(tmpType == 7){
		tmpVal = [self getUint16FromBuf:buf Offset:offset Bits:12];
		if((tmpVal)>=0 && (tmpVal)<2048)
			tmpVal+=23;
		else
			tmpVal = (tmpVal*(-1)) + 2025;
		offset+=12;
	}
	// get exponent
	if(tmpType != 3){
		tmpExp = [self getUint8FromBuf:buf Offset:offset Bits:3];
		offset+=3;
	}
	// get value
	if(tmpExp < 5){
		val = tmpVal * pow(10,((-1)*tmpExp));
	}
	else val = tmpVal;
	if (tmpType >2)		 //相對價格
		val += refPrice;
    if (fabs(val) < 0.000001)
        val = 0;
//	if (value == 0 && refPrice != 0)
//		val += refPrice;
	return val;	
}

+ (double) ConvertPrice:(UInt32)value RefPrice:(double)refPrice Exponent:(UInt8*)exp
{
	int offset = 0;
	UInt8 *buf = (UInt8*)&value;
	int tmpVal;
	UInt8 tmpType = 0,tmpExp = 0;
	double val;
	tmpType = [self getUint8FromBuf:buf Offset:offset Bits:3];
	offset+=3;
	if(tmpType == 0){
		tmpVal = [self getUint8FromBuf:buf Offset:offset Bits:8];
		offset+=8;
	}
	else if(tmpType == 1){
		tmpVal = [self getUint16FromBuf:buf Offset:offset Bits:16]+256;
		offset+=16;
	}
	else if(tmpType == 2){
		tmpVal = [self getUint32FromBuf:buf Offset:offset Bits:24]+65792;
		offset+=24;
	}
	else if(tmpType == 3){
		tmpVal = 0;
		tmpExp =0;
	}
	else if(tmpType == 4){
		tmpVal = [self getUint8FromBuf:buf Offset:offset Bits:2];
		if(tmpVal == 0)
			tmpVal = 1;
		else if(tmpVal == 2)
			tmpVal = -1;
		else if(tmpVal == 1)
			tmpVal = 5;
		else if(tmpVal == 3)
			tmpVal = -5;
		offset+=2;		
	}
	else if(tmpType == 5){
		tmpVal = [self getUint8FromBuf:buf Offset:offset Bits:3];
		if((tmpVal)>=0 && (tmpVal)<3)
			tmpVal+=2;
		else if(tmpVal == 3)
			tmpVal = 6;
		else if((tmpVal)>3 && (tmpVal)<7)
			tmpVal = (tmpVal*(-1)) + 2;
		else
			tmpVal = -6;
		offset+=3;
	}
	else if(tmpType == 6){
		tmpVal = [self getUint8FromBuf:buf Offset:offset Bits:5];
		if((tmpVal)>=0 && (tmpVal)<16)
			tmpVal+=7;
		else
			tmpVal = (tmpVal*(-1)) + 9;
		offset+=5;
	}
	else if(tmpType == 7){
		tmpVal = [self getUint16FromBuf:buf Offset:offset Bits:12];
		if((tmpVal)>=0 && (tmpVal)<2048)
			tmpVal+=23;
		else
			tmpVal = (tmpVal*(-1)) + 2025;
		offset+=12;
	}
	// get exponent
	if(tmpType != 3){
		tmpExp = [self getUint8FromBuf:buf Offset:offset Bits:3];
		offset+=3;
	}
	// get value
	if(tmpExp < 5){
		val = tmpVal * pow(10,((-1)*tmpExp));
	}
	else val = tmpVal;
	if (tmpType >2)		 //相對價格
		val += refPrice;
	//	if (value == 0 && refPrice != 0)
	//		val += refPrice;
	*exp = tmpExp;
	return val;	
}


+ (double) ConvertTAValue:(UInt32)value WithType:(UInt16 *)type
{
    
	int offset = 0;
	UInt8 *buf = (UInt8*)&value;
	double val;
	UInt8 tmpType,sign=0,magnitude=0;
	int tmpVal;
	tmpType = [self getUint8FromBuf:buf Offset:offset Bits:3];
	offset+=3;
	sign = [self getUint8FromBuf:buf Offset:offset++ Bits:1];
	if(tmpType == 0){
		tmpVal = [self getUint8FromBuf:buf Offset:offset Bits:5];
		offset+=5;
	}
	else if(tmpType == 1){
		tmpVal = [self getUint16FromBuf:buf Offset:offset Bits:10] + 32;
		offset+=10;		
	}
	else if(tmpType == 2){
		tmpVal = [self getUint16FromBuf:buf Offset:offset Bits:15] + 1056;
		offset+=15;		
	}
	else if(tmpType == 3){
		tmpVal = [self getUint32FromBuf:buf Offset:offset Bits:20] + 33824;
		offset+=20;		
	}
	else if(tmpType == 4){
		tmpVal = [self getUint32FromBuf:buf Offset:offset Bits:25] + 1082400;
		offset+=25;		
	}
	else if(tmpType == 5){
		tmpVal = [self getUint16FromBuf:buf Offset:offset Bits:14];
		offset+=14;		
	}
	else if(tmpType == 6){
		tmpVal = [self getUint32FromBuf:buf Offset:offset Bits:17];
		offset+=17;		
	}
	else if(tmpType == 7){
		tmpVal = [self getUint32FromBuf:buf Offset:offset Bits:20];
		offset+=20;		
	}
	if((tmpType)>4 && (tmpType)<8)
	{
		magnitude = [self getUint8FromBuf:buf Offset:offset Bits:3];
		offset+=3;
	}
	
    //magnitude 0:K, 1:M, 2:B, 3:T, 4:10-1, 5:10-2, 6:10-3, 7:10-4
	*type = kVolumeUnitNone;
	if((tmpType)>4 && (tmpType)<8){
		if(magnitude == 4)
			val = tmpVal * 0.1;
		else if(magnitude == 5)
			val = tmpVal * 0.01;
		else if(magnitude == 6)
			val = tmpVal * 0.001;
		else if(magnitude == 7)
			val = tmpVal * 0.0001;
		else
		{
            //type = 5	14	0~16383	當magnitude type = 0~3時，隱含三位小數(for X.XXX)
            //type = 6	17	0~131071	當magnitude type = 0~3時，隱含三位小數(for XX.XXX)
            //type = 7	20	0~1048575	當magnitude type = 0~3時，隱含三位小數(for XXX.XXX)
			val = tmpVal * 0.001;
			*type = (UInt16)magnitude + 1;
		}
	}
	else
		val = tmpVal;
	if(sign)
		val*=(-1);
//	*type = (char)magnitude;
	return val;	
}

//數值小於1 show小數點後三位, 其餘為兩位
+(NSString*) ConvertPriceValueToString:(double)value
{
	NSString *valueString;
	if(value>1)
	{
		valueString = [NSString stringWithFormat:@"%.2lf",value];
	}
	else
	{
		valueString = [NSString stringWithFormat:@"%.3lf",value];
	}
	
	return valueString;

}

+ (NSString*) ConvertPriceValueToString:(double)value withIdSymbol:(NSString*)idSymbol
{
	
	if(isinf(value))
		return @"----";
	if([[NSNumber numberWithDouble:value] isEqualToNumber:(NSNumber*)kCFNumberNaN]) 
		return @"----";
	if([[[NSNumber numberWithDouble:value] stringValue] isEqualToString:@"-0"])
		return @"----";
	
	NSString *valueString;
	

	if([idSymbol hasPrefix:@"HK"] || [idSymbol hasPrefix:@"SS"] || [idSymbol hasPrefix:@"SZ"])
	{
		//港股
		if(value<10)
		{
			valueString = [NSString stringWithFormat:@"%.2lf",value];
		}
		else
		{
			valueString = [NSString stringWithFormat:@"%.2lf",value];
		}
		
	}
	else
	{
		//期貨利率 期貨公債 期貨黃金 顯示小數點後三位 
		if([idSymbol rangeOfString:@"CPF"].location != NSNotFound || 
		   [idSymbol rangeOfString:@"GBF"].location != NSNotFound || 
		   [idSymbol rangeOfString:@"GDF"].location != NSNotFound)
		{
			valueString = [NSString stringWithFormat:@"%.3lf",value];
		}
		else
		{
            if(value<0.1){
                valueString = [NSString stringWithFormat:@"%.2lf",value];
            }else{
                valueString = [NSString stringWithFormat:@"%.2lf",value];
            }
			
		}
	}
	
	return valueString;
	
}
//

+ (NSString*) ConvertDoubleValueToString:(double)val
{
	if(isinf(val))
		return @"----";
	if([[NSNumber numberWithDouble:val] isEqualToNumber:(NSNumber*)kCFNumberNaN]) 
		return @"----";
	if([[[NSNumber numberWithDouble:val] stringValue] isEqualToString:@"-0"])
		return @"----";
	NSString *tmp = [NSString stringWithFormat:@"%.2lf",val];
	NSArray *checkArray = [tmp componentsSeparatedByString:@"."];
	if([[checkArray objectAtIndex:1] isEqualToString:@"00"]) return [NSString stringWithFormat:@"%.0lf",val];
	else return [NSString stringWithFormat:@"%.2lf",val];
}

+ (NSString*) ConvertDoubleAndZeroValueToString:(double)val	//包含把0以下轉成"---"
{
	if(isinf(val))
		return @"----";
	if([[NSNumber numberWithDouble:val] isEqualToNumber:(NSNumber*)kCFNumberNaN] || val<=0) 
		return @"----";
	NSString *tmp = [NSString stringWithFormat:@"%.2lf",val];
	NSArray *checkArray = [tmp componentsSeparatedByString:@"."];
	if([[checkArray objectAtIndex:1] isEqualToString:@"00"]) return [NSString stringWithFormat:@"%.0lf",val];
	else return [NSString stringWithFormat:@"%.2lf",val];
}

+ (NSString*) ConvertDoubleNoZeroValueToString:(double)val	//把0轉成"---" 負數不轉
{
	
	if(isinf(val))
		return @"----";
	if([[NSNumber numberWithDouble:val] isEqualToNumber:(NSNumber*)kCFNumberNaN] || val==0) 
		return @"----";
	NSString *tmp = [NSString stringWithFormat:@"%.2lf",val];
	NSArray *checkArray = [tmp componentsSeparatedByString:@"."];
	if([[checkArray objectAtIndex:1] isEqualToString:@"00"]) return [NSString stringWithFormat:@"%.0lf",val];
	else return [NSString stringWithFormat:@"%.2lf",val];
}

+ (NSString *)stringWithVolumeValueAndUnit:(double)value unit:(UInt8)unit{ 
	
	NSString *valueString;
	
	if(isinf(value))
		return @"----";
	if(value == 0)
		return [NSString stringWithFormat:@"----"];
	
	switch (unit) {
		case 0:
			valueString = [NSString stringWithFormat:@"%.0f", value];			
			break;
		case 1:
			valueString = [NSString stringWithFormat:@"%.0f", value];			
			break;
		case 2:
			value = (value/(pow(1000, 2)));		   
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"M"];	
			break;
		case 3:
			value = (value/(pow(1000, 3)));		   
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"B"];	 
			break;
		case 4:
			value = (value/(pow(1000, 4)));		   
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"T"];	 
			break;
		case 5:
			value = (value/(pow(1000, 5)));		   
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"Q"];	 
			break;
			
			
	}
	
	return valueString;
}

+(double)getRevenueTAValue:(double)value Uint:(int)unit
{
    switch (unit) {
        case 0:
            value = value * 1000 / 1000000;
            break;
        case 1:
            value = value * 10000 / 1000000 / pow(1000, 1);
            break;
        case 2:
            value = value * 1000000 / 1000000 / pow(1000, 2);;
            break;
        case 3:
            value = value * 1000000000 / 1000000 / pow(1000, 3);;
            break;
    }
    return value;
}


+ (NSString *)stringWithVolumeByValue:(double)value{
	
	NSString *valueString;
	int unit;
	
	if(isinf(value))
		return @"----";
	if(value == 0)
	{
		return [NSString stringWithFormat:@"----"];
	}
	else if(fabs(value) > 1000000000000)
	{
		unit = 4;
		value = value / 1000000000000;
	
	}
	else if(fabs(value) > 1000000000)
	{
		unit = 3;
		value = value / 1000000000;
	}
	else if(fabs(value) > 1000000)
	{
		unit = 2;
		value = value / 1000000;
	}
    else if(fabs(value) > 1000)
	{
		unit = 1;
		value = value / 1000;
	}
	else
	{
		unit = 0;
	}
	
	
	switch (unit) {
		case 0:
			valueString = [NSString stringWithFormat:@"%.0f", value];			
			break;
		case 1:
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"K"];
			break;
		case 2:	   
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"M"];	
			break;
		case 3:
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"B"];	 
			break;
		case 4:
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"T"];	 
			break;
		case 5:
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"Q"];	 
			break;
			
			
	}
	
	return valueString;

}

+ (NSString *)stringWithMergedRevenueByValue:(double)value Sign:(BOOL)sign{
	
	NSString *valueString;
	int unit;
	
	if(isinf(value))
		return @"----";
	if(value == 0)
	{
		return [NSString stringWithFormat:@"----"];
	}
	else if(fabs(value) > 1000000000000)
	{
		unit = 4;
		value = value / 1000000000000;
        
	}
	else if(fabs(value) > 1000000000)
	{
		unit = 3;
		value = floor(value / 10000000) / 100;
	}
	else if(fabs(value) > 1000000)
	{
		unit = 2;
		value = value / 1000000;
	}
    else if(fabs(value) > 1000)
	{
		unit = 1;
		value = value / 1000;
	}
	else
	{
		unit = 0;
	}
    NSString * marks;
    marks = @"";
    if (sign) {
        if (value>0) {
            marks = @"+";
        }else {
            marks = @"";
        }
    }
	
	switch (unit) {
		case 0:
			valueString = [NSString stringWithFormat:@"%@%.0f",marks, value];
			break;
		case 1:
            if (fabs(value) <= 100) {
                value = value * 1000;
                valueString = [NSString stringWithFormat:@"%@%.0f",marks, value];
            }else{
                valueString = [NSString stringWithFormat:@"%@%.0lf%@",marks, value,@"K"];
            }
			break;
		case 2:
            if (value >= 100) {
                valueString = [NSString stringWithFormat:@"%@%.0lf%@",marks, value,@"M"];
            }else if (value >= 10){
                valueString = [NSString stringWithFormat:@"%@%.1lf%@",marks, value,@"M"];
            }else {
                valueString = [NSString stringWithFormat:@"%@%.2lf%@",marks, value,@"M"];
            }
			break;
		case 3:
            if (value >= 100) {
                valueString = [NSString stringWithFormat:@"%@%.0lf%@",marks, value,@"B"];
            }else if (value >= 10){
                valueString = [NSString stringWithFormat:@"%@%.1lf%@",marks, value,@"B"];
            }else{
                valueString = [NSString stringWithFormat:@"%@%.2lf%@",marks, value,@"B"];
            }
			break;
		case 4:
			valueString = [NSString stringWithFormat:@"%@%.2lf%@",marks, value,@"T"];
			break;
		case 5:
			valueString = [NSString stringWithFormat:@"%@%.2lf%@",marks, value,@"Q"];
			break;
			
			
	}
	
	return valueString;
    
}


+ (NSString *)stringWithVolumeByValue2:(double)value{
	
	NSString *valueString;
	int unit;
	
	if(isinf(value))
		return @"----";
	if(value == 0)
	{
		return [NSString stringWithFormat:@"----"];
	}
	else if(fabs(value) > 1000000000000)
	{
		unit = 4;
		value = value / 1000000000000;
        
	}
	else if(fabs(value) > 10000000000)
	{
		unit = 3;
		value = value / 1000000000;
	}
	else if(fabs(value) > 10000000)
	{
		unit = 2;
		value = value / 1000000;
	}
    else if(fabs(value) > 100000)
	{
		unit = 1;
		value = value / 1000;
	}
	else
	{
		unit = 0;
	}
	
	
	switch (unit) {
		case 0:
			valueString = [NSString stringWithFormat:@"%.0f", value];
			break;
		case 1:
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"K"];
			break;
		case 2:
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"M"];
			break;
		case 3:
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"B"];
			break;
		case 4:
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"T"];
			break;
		case 5:
			valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"Q"];
			break;
			
			
	}
	
	return valueString;
    
}
+ (NSString *)stringWithVolumeByValue2NoFloat:(double)value{
    
    NSString *valueString;
    int unit;
    
    if(isinf(value))
        return @"----";
    if(value == 0)
    {
        return [NSString stringWithFormat:@"----"];
    }
    else if(fabs(value) > 1000000000000)
    {
        unit = 4;
        value = value / 1000000000000;
        
    }
    else if(fabs(value) > 10000000000)
    {
        unit = 3;
        value = value / 1000000000;
    }
    else if(fabs(value) > 10000000)//千萬才用M
    {
        unit = 2;
        value = value / 1000000;
    }
    else if(fabs(value) > 100000)
    {
        unit = 1;
        value = value / 1000;
    }
    else
    {
        unit = 0;
    }
    
    if((value-(int)value)/0.1>=0.5){//四捨五入
        value+=1;
    }
    switch (unit) {
        case 0:
            valueString = [NSString stringWithFormat:@"%d", (int)value];//去小數點
            break;
        case 1:
            valueString = [NSString stringWithFormat:@"%d%@", (int)value,@"K"];
            break;
        case 2:
            valueString = [NSString stringWithFormat:@"%d%@", (int)value,@"M"];
            break;
        case 3:
            valueString = [NSString stringWithFormat:@"%d%@", (int)value,@"B"];
            break;
        case 4:
            valueString = [NSString stringWithFormat:@"%d%@", (int)value,@"T"];
            break;
        case 5:
            valueString = [NSString stringWithFormat:@"%d%@", (int)value,@"Q"];
            break;
            
            
    }
    
    return valueString;
    
}

+ (NSString *)stringWithVolumeByValueNoDecimal:(double)value{
    
    NSString *valueString;
    int unit;
    
    if(isinf(value))
        return @"----";
    if(value == 0)
    {
        return [NSString stringWithFormat:@"----"];
    }
    else if(fabs(value) > 1000000000000)
    {
        unit = 4;
        value = value / 1000000000000;
        
    }
    else if(fabs(value) > 10000000000)
    {
        unit = 3;
        value = value / 1000000000;
    }
    else if(fabs(value) > 10000000)
    {
        unit = 2;
        value = value / 1000000;
    }
    else if(fabs(value) > 100000)
    {
        unit = 1;
        value = value / 1000;
    }
    else
    {
        unit = 0;
    }
    
    
    switch (unit) {
        case 0:
            valueString = [NSString stringWithFormat:@"%.0f", value];
            break;
        case 1:
            valueString = [NSString stringWithFormat:@"%.0lf%@", value,@"K"];
            break;
        case 2:
            valueString = [NSString stringWithFormat:@"%.0lf%@", value,@"M"];
            break;
        case 3:
            valueString = [NSString stringWithFormat:@"%.0lf%@", value,@"B"];
            break;
        case 4:
            valueString = [NSString stringWithFormat:@"%.0lf%@", value,@"T"];
            break;
        case 5:
            valueString = [NSString stringWithFormat:@"%.0lf%@", value,@"Q"];
            break;
            
            
    }
    
    return valueString;
    
}

+ (NSString *)twStringWithInfoVolumeByValue:(double)value{
    
    NSString *valueString;
    int unit;
    
    if(isinf(value))
        return @"----";
    if(value == 0)
    {
        return [NSString stringWithFormat:@"----"];
    }
    else if(fabs(value) > 1000000)
    {
        unit = 1;
        value = value / 1000000;
    }
    else
    {
        unit = 0;
    }
    
    
    switch (unit) {
        case 0:
            valueString = [NSString stringWithFormat:@"%.0f", value];
            break;
        case 1:
            valueString = [NSString stringWithFormat:@"%.3lf%@", value,@"M"];
            break;
    }
    
    return valueString;
    
}

+ (NSString *)twStringWithVolumeByValue:(double)value{
    
    NSString *valueString;
    int unit;
    
    if(isinf(value))
        return @"----";
    if(value == 0)
    {
        return [NSString stringWithFormat:@"----"];
    }
    else if(fabs(value) > 100000000)
    {
        unit = 2;
        value = value / 100000000;
    }
    else if(fabs(value) > 100000)
    {
        unit = 1;
        value = value / 10000;
    }
    else
    {
        unit = 0;
    }
    
    
    switch (unit) {
        case 0:
            valueString = [NSString stringWithFormat:@"%.0f", value];
            break;
        case 1:
            if (value>=1000) {
                valueString = [NSString stringWithFormat:@"%.0lf%@", value,@"萬"];
            }else if (value>=100){
                valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"萬"];
            }else if (value>=10){
                valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"萬"];
            }else{
                valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"萬"];
            }
            
            break;
        case 2:
            if (value>=1000) {
                valueString = [NSString stringWithFormat:@"%.0lf%@", value,@"億"];
            }else if (value>=100){
                valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"億"];
            }else if (value>=10){
                valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"億"];
            }else{
                valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"億"];
            }
            break;
        case 3:
            if (value>=1000) {
                valueString = [NSString stringWithFormat:@"%.0lf%@", value,@"兆"];
            }else if (value>=100){
                valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"兆"];
            }else if (value>=10){
                valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"兆"];
            }else{
                valueString = [NSString stringWithFormat:@"%.2lf%@", value,@"兆"];
            }
            break;
            
            
    }
    
    return valueString;
    
}



+ (NSString *)twStringWithVolumeByValue3:(double)value {
    
    NSString *valueString;
    int unit;
    
    if(isinf(value))
        return @"----";
    if(value == 0)
    {
        return [NSString stringWithFormat:@"----"];
    }
    else if(fabs(value) > 100000000)
    {
        unit = 2;
        value = value / 100000000;
    }
    else if(fabs(value) > 100000)
    {
        unit = 1;
        value = value / 10000;
    }
    else
    {
        unit = 0;
    }
    
    
    switch (unit) {
        case 0:
            valueString = [NSString stringWithFormat:@"%.0f", value];
            break;
        case 1:
            if (value>=1000) {
                valueString = [NSString stringWithFormat:@"%.0lf%@", value,@"萬"];
            }else if (value>=100){
                valueString = [NSString stringWithFormat:@"%.3lf%@", value,@"萬"];
            }else if (value>=10){
                valueString = [NSString stringWithFormat:@"%.3lf%@", value,@"萬"];
            }else{
                valueString = [NSString stringWithFormat:@"%.3lf%@", value,@"萬"];
            }
            
            break;
        case 2:
            if (value>=1000) {
                valueString = [NSString stringWithFormat:@"%.0lf%@", value,@"億"];
            }else if (value>=100){
                valueString = [NSString stringWithFormat:@"%.3lf%@", value,@"億"];
            }else if (value>=10){
                valueString = [NSString stringWithFormat:@"%.3lf%@", value,@"億"];
            }else{
                valueString = [NSString stringWithFormat:@"%.3lf%@", value,@"億"];
            }
            break;
        case 3:
            if (value>=1000) {
                valueString = [NSString stringWithFormat:@"%.0lf%@", value,@"兆"];
            }else if (value>=100){
                valueString = [NSString stringWithFormat:@"%.3lf%@", value,@"兆"];
            }else if (value>=10){
                valueString = [NSString stringWithFormat:@"%.3lf%@", value,@"兆"];
            }else{
                valueString = [NSString stringWithFormat:@"%.3lf%@", value,@"兆"];
            }
            break;
            
            
    }
    
    return valueString;
    
}

+ (NSString *)stringNoDecimalByValue:(double)value Sign:(BOOL)sign{
	
	NSString *valueString;
	int unit;
	
	if(isinf(value))
		return @"----";
    if (sign) {
        if(value == 0)
        {
            return [NSString stringWithFormat:@"----"];
        }
        else if(fabs(value) >= 100000000)
        {
            unit = 2;
            value = value / 1000000;
            
        }
        else if(fabs(value) >= 10000000)
        {
            unit = 1;
            value = value / 1000;
        }
        else
        {
            unit = 0;
        }

    }else{
        if(value == 0)
        {
            return [NSString stringWithFormat:@"----"];
        }
        else if(fabs(value) >= 1000000000)
        {
            unit = 2;
            value = value / 1000000;
            
        }
        else if(fabs(value) >= 100000000)
        {
            unit = 1;
            value = value / 1000;
        }
        else
        {
            unit = 0;
        }

    }
		
    NSString * marks;
    marks = @"";
    if (sign) {
        if (value>0) {
            marks = @"+";
        }else {
            marks = @"";
        }
    }

    
    NSString * valueStr = [self CoverFloatWithComma:value DecimalPoint:0];
	
	switch (unit) {
		case 0:
			valueString = [NSString stringWithFormat:@"%@%@",marks, valueStr];
			break;
		case 1:
			valueString = [NSString stringWithFormat:@"%@%@%@",marks, valueStr,@"K"];
			break;
		case 2:
			valueString = [NSString stringWithFormat:@"%@%@%@",marks, valueStr,@"M"];
			break;
		case 3:
			valueString = [NSString stringWithFormat:@"%@%@%@",marks, valueStr,@"B"];
			break;
		case 4:
			valueString = [NSString stringWithFormat:@"%@%@%@",marks, valueStr,@"T"];
			break;
		case 5:
			valueString = [NSString stringWithFormat:@"%@%@%@",marks, valueStr,@"Q"];
			break;
			
			
	}
	
	return valueString;
    
}

+(NSString *)CoverFloatWithCommaPositionForCN:(double)value{
    NSString * valueStr = @"";
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    if (value < pow(10, 3)) {
        [formatter setPositiveFormat:@"###,##0.00"];
    }else if (value < pow(10, 4)){
        [formatter setPositiveFormat:@"###,##0.0"];
    }else{
        [formatter setPositiveFormat:@"###,###"];
    }
    
    valueStr = [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
    
    return valueStr;
}

+(NSString *)CoverFloatWithCommaPositionInfoForCN:(double)value{
    NSString * valueStr = @"";
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    if (value < pow(10, 4)) {
        [formatter setPositiveFormat:@"###,##0.00"];
    }else{
        [formatter setPositiveFormat:@"###,###"];
    }
    
    valueStr = [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
    
    return valueStr;
}
+(NSString *)CoverFloatWithCommaForCN:(double)value{
    NSString * valueStr = @"";
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    if (fabs(value) < pow(10, 4)) {
        [formatter setPositiveFormat:@"###,##0.00"];
    }else if (fabs(value) < pow(10, 5)){
        [formatter setPositiveFormat:@"###,##0.0"];
    }else{
        [formatter setPositiveFormat:@"###,###"];
    }
    
    valueStr = [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
    
    return valueStr;
}

+(NSString *)ConvertFloatWithComma:(double)value DecimalPoint:(int)num{
    NSString *valueStr = @"";
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW ||
        [FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        if (num == 0) {
            [formatter setPositiveFormat:@"###,###"];
        }else if (num == 1){
            [formatter setPositiveFormat:@"###,##0.0"];
        }else if (num == 2){
            [formatter setPositiveFormat:@"###,##0.00"];
        }

    }else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS){
        if (value < pow(10, 4)) {
            [formatter setPositiveFormat:@"###,##0.00"];
        }else if (value < pow(10, 5)){
            [formatter setPositiveFormat:@"###,##0.0"];
        }else{
            [formatter setPositiveFormat:@"###,###"];
        }
    }else{
    
    }
    valueStr = [formatter stringFromNumber:[NSNumber numberWithDouble:value]];;
    return valueStr;
}

+(NSString *)CoverFloatWithComma:(double)value DecimalPoint:(int)num{
    NSString * valueStr = @"";
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    if (num == 0) {
        [formatter setPositiveFormat:@"###,###"];
    }else if (num == 1){
        [formatter setPositiveFormat:@"###,##0.0"];
    }else if (num == 2){
        [formatter setPositiveFormat:@"###,##0.00"];
    }
    
    valueStr = [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
    
    return valueStr;
}

+ (double) ConvertDouble:(double)value WithType:(UInt16 *)type{
    if(value == 0)
	{
        *type = 0;
        value = value;
	}
	else if(fabs(value) > 1000000000000)
	{
		*type = 4;
		value = value / 1000000000000;
        
	}
	else if(fabs(value) > 1000000000)
	{
		*type = 3;
		value = value / 1000000000;
	}
	else if(fabs(value) > 1000000)
	{
		*type = 2;
		value = value / 1000000;
	}
    else if(fabs(value) > 1000)
	{
		*type = 1;
		value = value / 1000;
	}
	else
	{
		*type = 0;
	}
    return value;
}

+ (void)setLabelForFloatValue:(UILabel*)label Value:(double)val ValueUnit:(UInt16)unit HaveZero:(BOOL)zeroFlag
{
//	UIFont *font = [label.font fontWithSize:label.minimumScaleFactor];
	
	if(!zeroFlag && val == 0)
		label.text = @"----";
	else
	{
		const char unitChar[] = { 0, 'K', 'M', 'B', 'T', 'Q' };
//		const CGSize infiniteSize = { MAXFLOAT, MAXFLOAT };
		
		NSString *format;
		if(unit > 0)
			format = @"%.0f%c";
		else
		{
			NSString *tmp = [NSString stringWithFormat:@"%.2lf",val];
			NSArray *checkArray = [tmp componentsSeparatedByString:@"."];
			if([[checkArray objectAtIndex:1] isEqualToString:@"00"])
				format = @"%.0f%c";
			else
				format = @"%.2f%c";
		}
		CGSize size;
		NSString *str = nil;
		CGFloat width = label.frame.size.width;
		
		if (unit > 0 && val < 1000 && fmodf(val*1000, 1000) != 0) {
			val *= 1000;
			unit--;
		}
		
		while (TRUE) {
			
			str = [NSString stringWithFormat:format, val, unitChar[unit]];
			
			if (fmodf(val, 1000) != 0 || val < 1000) {
/////////// connor clear   不想有warrning 直接移掉
//				size = [str sizeWithFont:font constrainedToSize:infiniteSize lineBreakMode:NSLineBreakByWordWrapping];
				if (size.width < width) break;
			}
			
			val /= 1000;
			unit++;
		}
		label.text = str;
	}		
}

+ (NSString*) getSymbolByIdentSymbol:(NSString*)is
{
	NSString *returnString = nil;
	if(is)
	{
		NSArray *sArray = [is componentsSeparatedByString:@" "];
		if([sArray count] > 1)
			returnString = [sArray objectAtIndex:1];
	}
	return returnString;
}

+ (NSString*) removeTrialZero:(NSString*)strData
{
    NSRange range = [strData rangeOfString:@"."];
    int digits;
    if (range.location != NSNotFound) {
        digits = (int)[strData length];
    } else {
        range = [strData rangeOfString:@"e-"];
        if (range.location != NSNotFound) {
            digits = [strData intValue];
        } else {
            digits = 0;
        }
    }
    //小數後面沒有東西
    if (digits == 0) {
        return strData;
    }
    
    /*
     http://stackoverflow.com/questions/7469614/remove-more-than-2-trailing-zero
     */
     
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    //原來小數後面幾位數就保留幾位數
    [formatter setMaximumFractionDigits:digits];
    //小數後面最小零位，這樣就可以把多餘的0剔除了
    [formatter setMinimumFractionDigits:0];
    NSNumber *strDataNumber = [formatter numberFromString:strData];
    if (strDataNumber == nil) {
        return nil;
    }
    
    NSString *resultString = [formatter stringFromNumber:strDataNumber];

    
    return resultString;
}

#pragma mark -
#pragma mark 數值千分號位

+(NSString*) convertToFormatCurrencyValue:(double)value
{
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setCurrencySymbol:@""];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSNumber *c = [NSNumber numberWithFloat:value];
	return [numberFormatter stringFromNumber:c];
}

+(NSString*) convertToFormatVolumeValue:(int)vol
{
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber *c = [NSNumber numberWithInt:vol];
	return [numberFormatter stringFromNumber:c];
}

#pragma mark -
#pragma mark 寫檔案用

+ (void)moveDirectoryDataToCachesDirectoryData:(NSString *)fileName
{
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	NSString *oldPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath:oldPath])
	{
		NSString *newPath = [NSString stringWithFormat:@"%@/%@", cacheDirectory, fileName];
		
		//NSLog(@"oldPath:%@\n,newPath:%@",oldPath,newPath);
		
		NSError *error = nil;
		[fileManager moveItemAtPath:oldPath toPath:newPath error:&error];			
				
//		if(error)
//		{
//			//NSLog([NSString stringWithFormat:@"%@",[error localizedDescription]]);
//		}
	}
}

+ (NSString*)fonestockDocumentsPath
{
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); //
	NSString *documentsDirectory = [paths objectAtIndex:0];
	//NSLog(@"documentsDirectory:%@",documentsDirectory);
	return documentsDirectory;
}

+(NSString*)techLineDataDirectoryPath{
    NSString *documentsDirectory = [self fonestockDocumentsPath];
    NSString *directoryName = [documentsDirectory stringByAppendingPathComponent:@"TechData"];
    
    return directoryName;
}

+(NSString*)divergenceDataDirectoryPath{
    NSString *documentsDirectory = [self fonestockDocumentsPath];
    NSString *directoryName = [documentsDirectory stringByAppendingPathComponent:@"MyFile"];
    
    return directoryName;
}

+ (NSString*)getDocumentsStringByFileName:(NSString*)fName
{
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); //	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:fName];
	return path;
}

+ (NSString*)getLocalDocumentsString
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;
}

#pragma mark -
#pragma mark 縮圖用

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToMaxHeight:(CGFloat)sizeHeight MaxWidth:(CGFloat)sizeWidth
{
	CGSize imageSize = image.size;
	if(imageSize.height <= sizeHeight && imageSize.width <= sizeWidth)	//在範圍裡
		return image;
	else
	{
		float scaleRatio = 0;
		float ratio1,ratio2;
		ratio1 = sizeHeight / imageSize.height;
		ratio2 = sizeWidth / imageSize.width;
		if(ratio1 < ratio2)
			scaleRatio = ratio1;
		else
			scaleRatio = ratio2;
		return [CodingUtil imageWithImage:image scaledToSize:CGSizeMake(imageSize.width*scaleRatio, imageSize.height*scaleRatio)];
	}
}

#pragma mark For Thread

+ (void)runOnMainQueueWithoutDeadlocking:(dispatch_block_t ) block
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

#pragma mark For Order
//
//+ (void) makeHashBuff:(UInt8*)buf currentPtr:(UInt16)cPtr Offset:(int)offset dataSize:(UInt16)size
//{
//	UInt8 *tmpPtr = buf + cPtr;
//	UInt16 fixSize = [self make16Bytes:size];
//	int i = 0;
//	while( (cPtr+(offset/8)) < fixSize )	//補01010101
//	{	
//		if(i)
//		{
//			[self setBufferr:1 Bits:1 Buffer:tmpPtr Offset:offset];
//			offset++;
//			i=0;
//		}
//		else
//		{
//			[self setBufferr:0 Bits:1 Buffer:tmpPtr Offset:offset];
//			offset++;
//			i=1;
//		}
//	}
//	tmpPtr = buf + fixSize;
//	md5_context ctx;
//	md5_starts( &ctx );
//	md5_update( &ctx, (UInt8*)buf, fixSize);
//	md5_finish( &ctx, (UInt8*)tmpPtr);	
//}

+ (UInt16) make16Bytes:(UInt16)size
{
	UInt16 tmpSize = size % 16;
	if(tmpSize)
		return (size+ 16 - tmpSize) ;
	else
		return size;	
}

+ (NSString *) localAddressForInterface:(NSString *)interface 
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
	
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) 
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:interface])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil; 
}

+ (NSString*) getIPaddress
{
	//NSLog(@"ipAddress:%@",[CodingUtil localAddressForInterface:@"pdp_ip0"]);
	NSString *ipString = [CodingUtil localAddressForInterface:@"pdp_ip0"];
	
	if(ipString)
		return ipString; //3G
	else
		return [CodingUtil localAddressForInterface:@"en0"]; // local wifi ip
	

	
/*	char iphone_ip[255];
	strcpy(iphone_ip,"127.0.0.1"); // if everything fails
	NSHost* myhost =[NSHost currentHost];
	if (myhost)
	{
		NSString *ad;
#if (TARGET_IPHONE_SIMULATOR)
		ad = [[myhost addresses] objectAtIndex:1];
#else
		ad = [myhost address];
#endif
		if (ad)
			strcpy(iphone_ip,[ad cStringUsingEncoding: NSISOLatin1StringEncoding]);
	}
	return [NSString stringWithFormat:@"%s",iphone_ip]; */
	
	////
	
	/*
	InitAddresses();
	GetIPAddresses();
	
	int i;
	NSString *deviceIP;
	for (i=0; i<MAXADDRS; ++i)
	{
		static unsigned long localHost = 0x7F000001;		// 127.0.0.1
		unsigned long theAddr;
		
		theAddr = ip_addrs[i];
		
		if (theAddr == 0) break;
		if (theAddr == localHost) continue;
		
//		NSLog(@"%s %s %s\n", if_names[i], hw_addrs[i], ip_names[i]);
	}
	int find = 0;
	for(i=0 ; i<MAXADDRS ; ++i)
	{
		if(if_names[i]==NULL)
			break;
		if(if_names[i][0]=='e')
		{
			find = i;
			break;
		}
		
	}
	if(ip_names[find])
		deviceIP = [NSString stringWithFormat:@"%s", ip_names[find]];
	else if(ip_names[0])
		deviceIP = [NSString stringWithFormat:@"%s", ip_names[0]];
	else
		deviceIP = nil;
	
	return deviceIP;
	*/
}

+ (NSString*) allocNSStringByBuffer:(UInt8*)buffer Offset:(int)offset Length:(UInt32)len Encoding:(NSStringEncoding)encoding
{
	char *tmpMsg = malloc(len+1);
	tmpMsg[len] = 0;
	for(int i=0 ; i<len ; i++)
		tmpMsg[i] = [CodingUtil getUint8FromBuf:buffer++ Offset:offset Bits:8];
	int tmpLen = (int)strlen(tmpMsg);
	NSString *string = nil;
	if(tmpLen)
		string = [[NSString alloc] initWithBytes:tmpMsg length:tmpLen encoding:encoding];
	free(tmpMsg);
	return string;	//別人要release
}

+ (NSString*) allocNSStringByBig5Buffer:(UInt8*)buffer Offset:(int)offset Length:(UInt32)len
{
	char *tmp = malloc(len+1);
	tmp[len] = 0;
	for(int i=0 ; i<len ; i++)
		tmp[i] = [CodingUtil getUint8FromBuf:buffer++ Offset:offset Bits:8];
	int tmpLen = (int)strlen(tmp);
	NSString *string = nil;
	if(tmpLen)
		string = [[NSString alloc] initWithBytes:tmp length:tmpLen encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseTrad)];
	free(tmp);
	return string;	//別人要release
	
}

+ (NSString*) deleteSpaceByNSString:(NSString*)tmpString
{
	if(tmpString == nil)
		return nil;
/*	NSArray *tmpArray = [tmpString componentsSeparatedByString:@" "];
	for(NSString *new in tmpArray)
	{
		char tmp = [new cStringUsingEncoding:NSASCIIStringEncoding][0];
		if(tmp!=0)
		{
			returnString = new;
			break;
		}
	}*/
	NSString *returnString = [tmpString stringByReplacingOccurrencesOfString:@" " withString:@""];
	return returnString;
}

#ifdef SUPPORT_TRADING

+ (void) orderLoadingPage:(NSString*)initString DownloadString:(NSString*)dlString WaitCheck:(BOOL)wc CheckString:(NSString*)cs Controller:(NSObject <OnlineOrderProtocol>*)obj;
{
	[DataModalProc getDataModal].orderPacket.orderConnect.waitCheck = wc;
	OrderLoadingController *tmp = [[OrderLoadingController alloc] initWithNibName:@"OrderLoadingController" bundle:[NSBundle mainBundle]];
	tmp.view.tag = 178;	//以後可以搜尋找到
	[((BullseyeAppDelegate*)[UIApplication sharedApplication].delegate).window addSubview:tmp.view];
	tmp.beginString = initString;
	tmp.endString = dlString;
	tmp.contentString = cs;
	tmp.controller = obj;
	[tmp showText];
	[tmp.view setAlpha:0.0];
	tmp.view.frame = [[UIScreen mainScreen] applicationFrame];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.8];
	[tmp.view setAlpha:0.95];
	[UIView commitAnimations];
//	[tmp release];
	
}

+ (void) orderLoadingPageSetAlertMessage:(NSString*)alertMessage
{
	NSArray *tmpArray = ((BullseyeAppDelegate*)[UIApplication sharedApplication].delegate).window.subviews ;
	for(UIView *tmpView in tmpArray)
	{
		if(tmpView.tag == 178)
		{
            tmpView.frame = [[UIScreen mainScreen] applicationFrame];
			NSArray *uiCom = tmpView.subviews;
			for(NSObject *tmpCom in uiCom)
			{
				if([tmpCom isKindOfClass:[UITextView class]])
				{
					UITextView *tmpTextView = (UITextView*)tmpCom;
					tmpTextView.text = alertMessage;
					break;
				}
			}
			break;
		}
	}
}
#endif

#pragma mark button design

+ (UIButton *)buttonWithTitle:	(NSString *)title target:(id)target selector:(SEL)selector frame:(CGRect)frame image:(UIImage *)image imagePressed:(UIImage *)imagePressed
				darkTextColor:(BOOL)darkTextColor
{	
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	// or you can do this:
	//		UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	//		button.frame = frame;
	
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];	
	if (darkTextColor)
	{
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else
	{
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	
	UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	
	UIImage *newPressedImage = [imagePressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	
	return button;
}

+ (void) setColorButton:(UIButton*)btn Color:(ButtonColor)btnColor
{
	UIImage *buttonBackground;
	switch (btnColor) {
		case WHITE:
			buttonBackground = [UIImage imageNamed:@"whiteButton2.png"];
			break;
		case GRAY:
			buttonBackground = [UIImage imageNamed:@"whiteButton.png"];
			break;
		case GREEN:
			buttonBackground = [UIImage imageNamed:@"greenButton.png"];
			break;
		case BLUE:
			buttonBackground = [UIImage imageNamed:@"blueButton.png"];
			break;
		case BLACK:
			buttonBackground = [UIImage imageNamed:@"lightBlackButton.png"];			
			break;
		case CLEAR:
			buttonBackground = [UIImage imageNamed:@"clearButton.png"];			
			break;
        case LIGHTBLUE:
            buttonBackground = [UIImage imageNamed:@"lightBlueButton.png"];
            break;
        case LIGHTORANGE:
            buttonBackground = [UIImage imageNamed:@"lightOrangeButton.png"];
            break;
		default:
			break;
	}
	UIImage *newImage = [buttonBackground stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[btn setBackgroundImage:newImage forState:UIControlStateNormal];
}

+ (void) setButtonTitle:(NSString*)title Button:(UIButton*)btn;
{
	[btn setTitle:title forState:UIControlStateNormal];
	[btn setTitle:title forState:UIControlStateHighlighted];
	[btn setTitle:title forState:UIControlStateDisabled];
	[btn setTitle:title forState:UIControlStateSelected];
}

+ (NSArray*) allocArrayByFutureSymbol:(NSString*)futureSymbol OurServer:(BOOL)os	//自己期貨的Symbol 轉成下單用的 Array第一個是symbol 第二個是 fullname
{
	NSString *symbol = nil,*fullName = nil;
	if(os)	//自己轉成下單用
	{
		if([futureSymbol isEqualToString:@"EXF"])
		{
			symbol = @"FITE";
			fullName = @"電子";
		}
		else if([futureSymbol isEqualToString:@"FXF"])
		{
			symbol = @"FITF";
			fullName = @"金融";
		}
		else if([futureSymbol isEqualToString:@"GTF"])
		{
			symbol = @"FIGT";
			fullName = @"櫃指";
		}
		else if([futureSymbol isEqualToString:@"MXF"])
		{
			symbol = @"FIMTX";
			fullName = @"小型";
		}
		else if([futureSymbol isEqualToString:@"T5F"])
		{
			symbol = @"FIT5F";
			fullName = @"五十";
		}
		else if([futureSymbol isEqualToString:@"TXF"])
		{
			symbol = @"FITX";
			fullName = @"台指";
		}
		else if([futureSymbol isEqualToString:@"XIF"])
		{
			symbol = @"FIXI";
			fullName = @"XIF";
		}
		else if([futureSymbol isEqualToString:@"CPF"])
		{
			symbol = @"FICP";
			fullName = @"利率";
		}
		else if([futureSymbol isEqualToString:@"GBF"])
		{
			symbol = @"FIGB";
			fullName = @"公債";
		}
		else if([futureSymbol isEqualToString:@"GDF"])
		{
			symbol = @"FIGF";
			fullName = @"黃金";
		}
		else if([futureSymbol isEqualToString:@"MSF"])
		{
			symbol = @"FIMS";
			fullName = @"摩台";
		}
	}
	else	//下單轉成自己用
	{
		if([futureSymbol isEqualToString:@"FITE"])
		{
			symbol = @"EXF";
			fullName = @"電子";
		}
		else if([futureSymbol isEqualToString:@"FITF"])
		{
			symbol = @"FXF";
			fullName = @"金融";
		}
		else if([futureSymbol isEqualToString:@"FIGT"])
		{
			symbol = @"GTF";
			fullName = @"櫃指";
		}
		else if([futureSymbol isEqualToString:@"FIMTX"])
		{
			symbol = @"MXF";
			fullName = @"小型";
		}
		else if([futureSymbol isEqualToString:@"FIT5F"])
		{
			symbol = @"T5F";
			fullName = @"五十";
		}
		else if([futureSymbol isEqualToString:@"FITX"])
		{
			symbol = @"TXF";
			fullName = @"台指";
		}
		else if([futureSymbol isEqualToString:@"FIXI"])
		{
			symbol = @"XIF";
			fullName = @"XIF";
		}
		else if([futureSymbol isEqualToString:@"FICP"])
		{
			symbol = @"CPF";
			fullName = @"利率";
		}
		else if([futureSymbol isEqualToString:@"FIGB"])
		{
			symbol = @"GBF";
			fullName = @"公債";
		}		
		else if([futureSymbol isEqualToString:@"FIGF"])
		{
			symbol = @"GDF";
			fullName = @"黃金";
		}
		else if([futureSymbol isEqualToString:@"FIMS"])
		{
			symbol = @"MSF";
			fullName = @"摩台";
		}
	}
	
	NSArray *returnArray = nil;
	if(symbol && fullName)
		returnArray = [[NSArray alloc] initWithObjects:symbol,fullName,nil];
	return returnArray;
}

/*
+ (NSArray*) allocArrayByOptionSymbol:(NSString*)optionSymbol OurServer:(BOOL)os	//自己選擇權的Symbol 轉成下單用的 Array第一個是symbol 第二個是 fullname
{
	NSString *symbol = nil,*fullName = nil;
	if(os)	//自己轉成下單用
	{
		if([optionSymbol isEqualToString:@"TXO"])
		{
			symbol = @"TX";
			fullName = @"台指";
		}
		else if([optionSymbol isEqualToString:@"TFO"])
		{
			symbol = @"TF";
			fullName = @"台融指";
		}
		else if([optionSymbol isEqualToString:@"TEO"])
		{
			symbol = @"TE";
			fullName = @"電子指";
		}
		else if([optionSymbol isEqualToString:@"AFO"])
		{
			symbol = @"AF";
			fullName = @"南亞";
		}
		else if([optionSymbol isEqualToString:@"AGO"])
		{
			symbol = @"AGO";
			fullName = @"中鋼";
		}
		else if([optionSymbol isEqualToString:@"AHO"])
		{
			symbol = @"AH";
			fullName = @"聯電";
		}
		else if([optionSymbol isEqualToString:@"AIO"])
		{
			symbol = @"AI";
			fullName = @"台積電";
		}
		else if([optionSymbol isEqualToString:@"AJO"])
		{
			symbol = @"AJ";
			fullName = @"富邦金";
		}
		else if([optionSymbol isEqualToString:@"AKO"])
		{
			symbol = @"AK";
			fullName = @"台塑";
		}
		else if([optionSymbol isEqualToString:@"ALO"])
		{
			symbol = @"ALO";
			fullName = @"仁寶";
		}
		else if([optionSymbol isEqualToString:@"AMO"])
		{
			symbol = @"AM";
			fullName = @"友達";
		}
		else if([optionSymbol isEqualToString:@""])
		{
			symbol = @"";
			fullName = @"";
		}
		else if([optionSymbol isEqualToString:@""])
		{
			symbol = @"";
			fullName = @"";
		}
		else if([optionSymbol isEqualToString:@""])
		{
			symbol = @"";
			fullName = @"";
		}
		else if([optionSymbol isEqualToString:@""])
		{
			symbol = @"";
			fullName = @"";
		}
		else if([optionSymbol isEqualToString:@""])
		{
			symbol = @"";
			fullName = @"";
		}
		else if([optionSymbol isEqualToString:@""])
		{
			symbol = @"";
			fullName = @"";
		}
		else if([optionSymbol isEqualToString:@""])
		{
			symbol = @"";
			fullName = @"";
		}
		else if([optionSymbol isEqualToString:@""])
		{
			symbol = @"";
			fullName = @"";
		}
		
	}
	else	//下單轉成自己用
	{
	}
	NSArray *returnArray = nil;
	if(symbol && fullName)
		returnArray = [[NSArray alloc] initWithObjects:symbol,fullName,nil];
	return returnArray;
}*/

//server
+ (NSString*) getOrderStatusByType:(int)type {
	
	NSString *statusString;
	
	switch (type) {
		case 0:
			statusString = @"";
			break;
		case 1:
//			statusString = @"下單中";
#ifdef BROKER_MEGA
			statusString = @"下單處理中";
#else
			statusString = @"委託處理中";
#endif
			break;
		case 2:
//			statusString = @"下單成功";
			statusString = @"委託成功";
			break;
		case 3:
//			statusString = @"下單失敗";
			statusString = @"委託失敗";
			break;
		case 4:
			statusString = @"委託刪單中";			
			break;
		case 5:
			statusString = @"刪單成功";
			break;
		case 6:
			statusString = @"刪單失敗";
			break;
		case 7:
			statusString = @"委託減單中";
			break;
		case 8:
#ifdef BROKER_MEGA
			statusString = @"減量成功";
#else
			statusString = @"減單成功";
#endif
			break;
		case 9:
#ifdef BROKER_MEGA
			statusString = @"減量失敗";
#else
			statusString = @"減單失敗";
#endif
			break;
		case 10:
			statusString = @"已成交";
			break;
		case 11:
			statusString = @"未成交";
			break;
		case 12:
			statusString = @"預約單";
			break;
		case 15:
			statusString = @"委託改價中";
			break;
		case 16:
			statusString = @"委託改價成功";
			break;
		case 17:
			statusString = @"委託改價失敗";
			break;
		case 99:
			statusString = @"部份成交";
			break;
		case 100:
			statusString = @"全部成交";
			break;
		default: 
			statusString = @"----";			
			break;
			
	}
	return statusString;

}


//永豐版下單狀態
+(NSString *)getSinopacVersionQuertStatusByType:(int)type {
	
	NSString *statusString;
	
	switch (type) {
		case 1:
			statusString = @"委託中";
			break;
		case 2:
			statusString = @"已委託";
			break;
		case 3:
			statusString = @"委託失敗";
			break;
		case 4:
			statusString = @"刪單中";
			break;
		case 5:
			statusString = @"刪單成功";
			break;
		case 6:
			statusString = @"刪單失敗";
			break;
		case 7:
			statusString = @"減量中";
			break;
		case 8:
			statusString = @"減量成功";
			break;
		case 9:
			statusString = @"減量失敗";
			break;
		case 10:
			statusString = @"已成交";
			break;
		case 11:
			statusString = @"未成交";
			break;
		case 12:
			statusString = @"預約單";
			break;
		case 15:
			statusString = @"委託改價中";
			break;
		case 16:
			statusString = @"委託改價成功";
			break;
		case 17:
			statusString = @"委託改價失敗";
			break;
		default:
			statusString = @"----";
			break;
			
	}
	
	return statusString;

}

#pragma mark UIAnimation專用

+ (void) animationNextPage:(UIView*)animationView
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration: 0.75];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:animationView cache:YES];
	[UIView commitAnimations];
}

+ (void) animationPrePage:(UIView*)animationView
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration: 0.75];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:animationView cache:YES];
	[UIView commitAnimations];
}

#pragma mark TDAmeritrade在用的
#ifdef BROKER_TDAMERITRADE

//Alloc一個Loading的page放在window最上層 當WaitCheck==YES時 代表需要按確定才開始傳輸 此時需要CheckString代表一開始的文字
+ (void) ameritradeLoading:(NSString*)initString WaitCheck:(BOOL)wc CheckString:(NSString*)cs Controller:(NSObject <TDAmeritradeLoadingProtocol>*)obj
{
	TDAmeritradeLoading *tmp = [[TDAmeritradeLoading alloc] initWithNibName:@"TDAmeritradeLoading" bundle:nil Wait:wc];
	tmp.view.tag = 176;	//以後可以搜尋找到
	[((BullseyeAppDelegate*)[UIApplication sharedApplication].delegate).window addSubview:tmp.view];
	tmp.beginString = initString;
	tmp.contentString = cs;
	tmp.controller = obj;
	[tmp showText];
	[tmp.view setAlpha:0.0];	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.8];
	[tmp.view setAlpha:0.95];
	[UIView commitAnimations];
	
}

//抓出loading Page的TextView 把alertMessage塞進去
+ (void) ameritradeLoadingAlertMessage:(NSString*)alertMessage
{
	NSArray *tmpArray = ((BullseyeAppDelegate*)[UIApplication sharedApplication].delegate).window.subviews ;
	for(UIView *tmpView in tmpArray)
	{
		if(tmpView.tag == 176)
		{
			NSArray *uiCom = tmpView.subviews;
			for(NSObject *tmpCom in uiCom)
			{
				if([tmpCom isKindOfClass:[UITextView class]])
				{
					UITextView *tmpTextView = (UITextView*)tmpCom;
					tmpTextView.text = alertMessage;
					break;
				}
			}
			break;
		}
	}
	
}

#endif

#pragma mark for iOS8 alertController to be presented in a modal
+ (UIViewController*) getTopMostViewController
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    
    for (UIView *subView in [window subviews])
    {
        UIResponder *responder = [subView nextResponder];
        
        //added this block of code for iOS 8 which puts a UITransitionView in between the UIWindow and the UILayoutContainerView
        if ([responder isEqual:window])
        {
            //this is a UITransitionView
            if ([[subView subviews] count])
            {
                UIView *subSubView = [subView subviews][0]; //this should be the UILayoutContainerView
                responder = [subSubView nextResponder];
            }
        }
        
        if([responder isKindOfClass:[UIViewController class]]) {
            return [self topViewController: (UIViewController *) responder];
        }
    }
    
    return nil;
}

+ (UIViewController *) topViewController: (UIViewController *) controller
{
    BOOL isPresenting = NO;
    do {
        // this path is called only on iOS 6+, so -presentedViewController is fine here.
        UIViewController *presented = [controller presentedViewController];
        isPresenting = presented != nil;
        if(presented != nil) {
            controller = presented;
        }
        
    } while (isPresenting);
    
    return controller;
}


@end

/*              TAvalueParam             */

@implementation TAvalueParam
@synthesize nameString;
- (id) init
{
	if(self = [super init])
	{
		nameString = [[NSString alloc] init];
	}
	return self;
}


@end






/*				Symbol Format 1					*/

@implementation SymbolFormat1

- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset
{
	if(self = [super init])
	{
		*size = 0;
		UInt8 *tmpPtr = buff;
		IdentCode[0] = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		IdentCode[1] = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		symbolLength = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		if(symbolLength)
			symbol = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:offset Length:symbolLength Encoding:NSUTF8StringEncoding];
		else
			symbol = @"";
		tmpPtr += symbolLength;
		typeID = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		fullNameLength = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		if(fullNameLength)
			fullName = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:offset Length:fullNameLength Encoding:NSUTF8StringEncoding];
		else
			fullName = @"";
		*size = 5+symbolLength+fullNameLength;
	}
	return self;
}

@end


/*				Symbol Format 2					*/

@implementation SymbolFormat2

- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset
{
	if(self = [super init])
	{
		*size=0;
		UInt8 *tmpPtr = buff;
		typeID = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		symbolLength = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		if(symbolLength)
			symbol = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:offset Length:symbolLength Encoding:NSUTF8StringEncoding];
		else
			symbol = @"";
		tmpPtr += symbolLength;
		fullNameLength = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		if(fullNameLength)
			fullName = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:offset Length:fullNameLength Encoding:NSUTF8StringEncoding];
		else
			fullName = @"";
		*size = 3+symbolLength+fullNameLength;		
	}
	return self;
}

@end


/*				Symbol Format 3					*/

@implementation SymbolFormat3

- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset
{
	if(self = [super init])
	{
		*size = 0;
		UInt8 *tmpPtr = buff;
		IdentCode[0] = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		IdentCode[1] = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		symbolLength = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		if(symbolLength)
			symbol = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:offset Length:symbolLength Encoding:NSUTF8StringEncoding];
		else
			symbol = @"";
		*size = 3+symbolLength;
	}
	return self;
}


@end

/*				Symbol Format 4					*/

@implementation SymbolFormat4

- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset
{
	if(self = [super init])
	{
		*size = 0;
		UInt8 *tmpPtr = buff;
		symbolLength = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		if(symbolLength)
			symbol = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:offset Length:symbolLength Encoding:NSUTF8StringEncoding];
		else
			symbol = @"";
		*size = 1+symbolLength;
	}
	return self;
}

@end

/*				Symbol Format 5					*/

@implementation SymbolFormat5

- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset
{
	if(self = [super init])
	{
		*size = 0;
		UInt8 *tmpPtr = buff;
		IdentCode[0] = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		IdentCode[1] = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		symbolLength = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		if(symbolLength)
			symbol = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:offset Length:symbolLength Encoding:NSUTF8StringEncoding];
		else
			symbol = @"";
		tmpPtr += symbolLength;
		year = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		month = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		fullNameLength = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		if(fullNameLength)
			fullName = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:offset Length:fullNameLength Encoding:NSUTF8StringEncoding];
		else
			fullName = @"";
		*size = 6+symbolLength+fullNameLength;
	}
	return self;
}


@end

/*				Symbol Format 6					*/

@implementation SymbolFormat6

- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset
{
	if(self = [super init])
	{
		*size = 0;
		UInt8 *tmpPtr = buff;
		IdentCode[0] = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		IdentCode[1] = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		symbolLength = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		if(symbolLength)
			symbol = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:offset Length:symbolLength Encoding:NSUTF8StringEncoding];
		else
			symbol = @"";
		tmpPtr += symbolLength;
		year = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		month = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		*size = 5+symbolLength;
	}
	return self;
}

@end


/*				B-Value Format1(2 bytes)					*/

@implementation bValueFormat1

- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset
{
	if(self = [super init])
	{
		*size = 0;
		UInt8 *tmpPtr = buff;
		decimal = [CodingUtil getUint8FromBuf:tmpPtr Offset:1 Bits:1];
        positive = [CodingUtil getUint8FromBuf:tmpPtr Offset:2 Bits:1];
        dataValue = [CodingUtil getUint16FromBuf:tmpPtr Offset:3 Bits:13];
        
        tmpPtr +=2;
		*size = 2;
    }
	return self;
}
@end

/*				B-Value Format2(4 bytes)					*/

@implementation bValueFormat2

- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset
{
	if(self = [super init])
	{
		*size = 0;
		UInt8 *tmpPtr = buff;
		decimal = [CodingUtil getUint8FromBuf:tmpPtr Offset:2 Bits:2];
        positive = [CodingUtil getUint8FromBuf:tmpPtr Offset:4 Bits:1];
        dataValue = [CodingUtil getUint32FromBuf:tmpPtr Offset:5 Bits:27];
        
        tmpPtr +=4;
		*size = 4;
    }
	return self;
}
@end


/*				B-Value Format3(8 bytes)					*/

@implementation bValueFormat3

- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset
{
	if(self = [super init])
	{
		*size = 0;
		UInt8 *tmpPtr = buff;
		decimal = [CodingUtil getUint8FromBuf:tmpPtr Offset:2 Bits:3];
        type = [CodingUtil getUint8FromBuf:tmpPtr Offset:5 Bits:1];
        exponent = [CodingUtil getUint8FromBuf:tmpPtr Offset:6 Bits:1];
        positive = [CodingUtil getUint8FromBuf:tmpPtr Offset:7 Bits:1];
        dataValue = [CodingUtil getUint64FromBuf:tmpPtr Offset:8 Bits:56];
        
        tmpPtr +=8;
		*size = 8;
    }
	return self;
}
@end


/*				shortStringFormat					*/

@implementation shortStringFormat

- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset
{
	if(self = [super init])
	{
		*size = 0;
		UInt8 *tmpPtr = buff;
        
        length = [CodingUtil getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
		if(length)
			dataString = [CodingUtil allocNSStringByBuffer:tmpPtr Offset:offset Length:length Encoding:NSUTF8StringEncoding];
		else
			dataString = @"";
		tmpPtr += length;
		
		*size = 1+length;
	}
	return self;
}

@end

@implementation TrackUpFormat
@end

@implementation TrackDownFormat
@end

@implementation NewSymbolObject

@end