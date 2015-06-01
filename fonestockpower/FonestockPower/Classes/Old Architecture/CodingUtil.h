//
//  CodingUtil.h
//  test4
//
//  Created by Yehsam on 2008/11/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#if defined YUANTA_BROKER
#import "YuantaUtil.h"
#endif

#ifdef SUPPORT_TRADING
#import "OnlineOrder.h"
#endif

#ifdef BROKER_TDAMERITRADE

#import "TDAmeritradeSession.h"

#endif

typedef enum
{
	kVolumeUnitNone = 0,
	kVolumeUnitThousand = 1,
	kVolumeUnitMillion = 2,
	kVolumeUnitBillion = 3,
	kVolumeUnitTrillion = 4
} VolumeUnitType;

typedef struct _priceFormat {
	UInt8 type;
	int significand;
	UInt8 exponent;
}PriceFormatData,*PriceFormatRef;

typedef struct valueFormat {
	UInt8 type;
	UInt8 sign;
	UInt32 value;
	char magnitude;
}TAvalueFormatData,*TAvalueFormatRef;

typedef enum _ButtonColor{
	WHITE,GRAY,GREEN,BLUE,BLACK,CLEAR,LIGHTBLUE,LIGHTORANGE
} ButtonColor;

@interface CodingUtil : NSObject {

}

/*
 
 NEW API
 
 connor update 2015.03.27
 
 */

+ (NSString *)hexadecimalString:(UInt8)bytes BytesLength:(NSUInteger)bytesLength;

// 轉換單位並根據scale無條件捨去數值
//+ (NSString *)valueRoundDownAndChangeUnitWithDouble:(double)value scale:(short)scale digitsCount:(int)digitsCount;


//// NEW 20150506

+ (NSString *)priceRoundRownWithDouble:(double)value;
+ (NSString *)volumeRoundRownWithDouble:(double)value;




/*
 connor update 2013.12.30
 */

+ (UInt16)getUInt8:(UInt8 **)buffer needOffset:(BOOL)needOffset;
+ (UInt16)getUInt16:(UInt8 **)buffer needOffset:(BOOL)needOffset;

+ (void)setUInt8:(char **)buffer value:(UInt8)val needOffset:(BOOL)needOffset;
+ (void)setUInt16:(char **)buffer value:(UInt16)val needOffset:(BOOL)needOffset;
+ (void)setUInt32:(char **)buffer value:(UInt32)val needOffset:(BOOL)needOffset;

// 用來取得ShortStringFormat, 並且可以直接offset
+ (NSString *)getShortStringFormatByBuffer:(UInt8 **)buffer needOffset:(BOOL)needOffset;
// 用來取得LongStringFormat, 並且可以直接offset
+ (NSString *)getLongStringFormatByBuffer:(UInt8 **)buffer needOffset:(BOOL)needOffset;

+ (NSString *)getShortStringFormatByBuffer:(UInt8 *)buffer bitOffset:(int *)bitOffset;
+ (NSString *)getLongStringFormatByBuffer:(UInt8 *)buffer bitOffset:(int *)bitOffset;






    
+ (NSString *)hashed_string:(NSString *)input;
+ (NSString *)md5:(NSString *)input;
+(double)getRevenueTAValue:(double)value Uint:(int)unit;

+ (BOOL) DateIsTodayDateWithYear:(UInt16)year month:(UInt8)month day:(UInt8)day;

// Set functions work on byte boundary.
+ (void)setUInt8 : (char *)buff value: (UInt8)val;
+ (void)setUInt16 : (char*)buff Value:(UInt16)val;
+ (void)setUInt32 : (char*)buff Value:(UInt32)val;


// Get functions work on byte boundary.
+ (UInt16)getUInt16 : (void *)buf;
+ (UInt32)getUInt32 : (void *)buf;
+ (UInt64)getUInt64 : (void *)buf;
// encryption type
enum 
{
	ENCRYPTION_NOTHING = 0,
	ENCRYPTION_DES,
	ENCRYPTION_AES,
	ENCRYPTION_TRIPLE_DES,
};
//+ (UInt8) EncryptData:(int)nType pKey:(UInt8*)pKey nKeyLen:(int)nKeyLen pBuff:(UInt8*)pBuff len:(int)len pDigest:(UInt8*) pDigest;
//+ (UInt8) DecryptData:(int)nType pKey:(UInt8*)pKey nKeyLen:(int)nKeyLen pBuff:(UInt8*)pBuff len:(int)len pDigest:(UInt8*) pDigest;

// For date

+ (UInt16) makeDate:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
+ (void) getDate:(UInt16)date year:(UInt16*)y month:(UInt8*)m day:(UInt8*)d;
+ (void) getDateNew:(UInt16)date year:(UInt16*)y month:(UInt8*)m day:(UInt8*)d;
+ (NSString*) getStringDate:(UInt16)rdate;
+ (NSString*) getStringDateNew:(UInt16)rdate;
+ (NSString*) getStringDatePlusZero:(UInt16)rdate;
+ (NSString*) getStringDate2:(UInt16)rdate;
+ (UInt16) makeDateFromDate:(NSDate *)date;
+ (UInt16 )dateConvertToNewDate:(UInt16)rdate;

+ (NSString*) getValueUnitString:(double)value Unit:(UInt8)unit;
+ (NSString*) getValueString:(double)value Unit:(UInt8)unit;
+ (NSString *)getValueString_2:(double)value Unit:(UInt8)unit;
+ (NSString*)getValueToPrecent:(double)value;
+ (NSString*) getMarketValue:(double)value;

+ (UInt8) getUint8FromBuf:(void *)buf Offset:(int)off Bits:(int)bits;
+ (UInt16) getUint16FromBuf:(void *)buf Offset:(int)off Bits:(int)bits;
+ (UInt32) getUint32FromBuf:(void *)buf Offset:(int)off Bits:(int)bits;
+ (UInt64) getUint64FromBuf:(void *)buf Offset:(int)off Bits:(int)bits;
+ (NSString *) getMacroeconomicValue:(double)value;
+ (void)updateVolume:(double *)pVol Unit:(UInt16 *)pUnit WithVolume:(double)vol Unit:(UInt16)unit;

// For Order
//+ (void) makeHashBuff:(UInt8*)buf currentPtr:(UInt16)cPtr Offset:(int)offset dataSize:(UInt16)size;
+ (UInt16) make16Bytes:(UInt16)size;

//--------------------------------------------------------------------------
// Functions to set bit value that is not at the byte boundary.
//--------------------------------------------------------------------------
+ (void)setBufferr:(UInt32)val Bits:(NSInteger)bits Buffer:(void *)buf Offset:(NSInteger)off; 

//For Message Format
+ (UInt16) getTimeFormat2Value:(void *)buf Offset:(int*)off;
+ (UInt16) getTickSNValue:(void *)buf Offset:(int*)off;
+ (double) getPriceFormatValue:(void *)buf Offset:(int*)off TAstruct:(PriceFormatRef)pr;
+ (double) getTAvalueFormatValue:(void *)buf Offset:(int*)off TAstruct:(TAvalueFormatRef)ta;
+ (double) getTAvalue:(void *)buf Offset:(int*)off TAstruct:(TAvalueFormatRef)ta;
+ (NSString *) getTAvalueFormatString:(void *)buf Offset:(int)off TAstruct:(TAvalueFormatRef)ta;

// Convert value from compressed format.
// The data align to the highest bit.
+ (double) ConvertPrice:(UInt32)value RefPrice:(double)refPrice;
+ (double) ConvertPrice:(UInt32)value RefPrice:(double)refPrice Exponent:(UInt8*)exp;
+ (double) ConvertTAValue:(UInt32)value WithType:(UInt16 *)type;
+ (double) ConvertDouble:(double)value WithType:(UInt16 *)type;

+ (NSString *)CoverFloatWithComma:(double)value DecimalPoint:(int)num;
+ (NSString *)CoverFloatWithCommaForCN:(double)value;
+ (NSString *)CoverFloatWithCommaPositionForCN:(double)value;
+ (NSString *)CoverFloatWithCommaPositionInfoForCN:(double)value;
+ (NSString *)ConvertFloatWithComma:(double)value DecimalPoint:(int)num;


+ (NSString*) ConvertPriceValueToString:(double)value; ////數值小於1 show小數點後三位, 其餘為兩位
+ (NSString*) ConvertPriceValueToString:(double)value withIdSymbol:(NSString*)idSymbol; //由identCode來判斷要顯示小數點後幾位數
+ (NSString*) ConvertDoubleValueToString:(double)val;
+ (NSString*) ConvertDoubleAndZeroValueToString:(double)val;	//包含把0轉成"---"
+ (NSString*) ConvertDoubleNoZeroValueToString:(double)val;	//把0轉成"---" 負數不轉
+ (NSString *)stringWithVolumeValueAndUnit:(double)value unit:(UInt8)unit;
+ (NSString *)stringWithVolumeByValue:(double)value;
+ (NSString *)stringWithVolumeByValue2:(double)value;
+ (NSString *)stringWithVolumeByValueNoDecimal:(double)value;
+ (NSString *)twStringWithVolumeByValue:(double)value;
+ (NSString *)twStringWithVolumeByValue3:(double)value;
+ (NSString *)twStringWithInfoVolumeByValue:(double)value;
+ (NSString *)stringNoDecimalByValue:(double)value Sign:(BOOL)sign;
+ (NSString *)stringWithMergedRevenueByValue:(double)value Sign:(BOOL)sign;
+ (void)setLabelForFloatValue:(UILabel*)label Value:(double)val ValueUnit:(UInt16)unit HaveZero:(BOOL)zeroFlag;

#pragma mark -
#pragma mark 數值千分號位

+(NSString*) convertToFormatCurrencyValue:(double)value;
+(NSString*) convertToFormatVolumeValue:(int)vol;

+ (NSString*) getSymbolByIdentSymbol:(NSString*)is;

+ (NSString*) removeTrialZero:(NSString*)strData;

#pragma mark -
#pragma mark for iOS8 alertController to be presented in a modal
+ (UIViewController*) getTopMostViewController;

#pragma mark -
#pragma mark 寫檔案用
+ (void)moveDirectoryDataToCachesDirectoryData:(NSString *)fileName;
+ (NSString*)fonestockDocumentsPath;
+ (NSString*)getDocumentsStringByFileName:(NSString*)fName;
+ (NSString*)getLocalDocumentsString;
+(NSString*)techLineDataDirectoryPath;
+(NSString*)divergenceDataDirectoryPath;

#pragma mark -
#pragma mark 縮圖用

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToMaxHeight:(CGFloat)sizeHeight MaxWidth:(CGFloat)sizeWidth;

#pragma mark -
#pragma mark 處理thread

+ (void)runOnMainQueueWithoutDeadlocking:(dispatch_block_t ) block;

#pragma mark -
#pragma mark 下單再用的

+ (NSString *) localAddressForInterface:(NSString *)interface ;
+ (NSString*) getIPaddress;

+ (NSString*) allocNSStringByBuffer:(UInt8*)buffer Offset:(int)offset Length:(UInt32)len Encoding:(NSStringEncoding)encoding;
//轉Big專用
+ (NSString*) allocNSStringByBig5Buffer:(UInt8*)buffer Offset:(int)offset Length:(UInt32)len;

+ (NSString*) deleteSpaceByNSString:(NSString*)tmpString;

#ifdef SUPPORT_TRADING
//Alloc一個Loading的page放在window最上層 當WaitCheck==YES時 代表需要按確定才開始傳輸 此時需要CheckString代表一開始的文字
+ (void) orderLoadingPage:(NSString*)initString DownloadString:(NSString*)dlString WaitCheck:(BOOL)wc CheckString:(NSString*)cs Controller:(NSObject <OnlineOrderProtocol>*)obj;

//抓出loading Page的TextView 把alertMessage塞進去
+ (void) orderLoadingPageSetAlertMessage:(NSString*)alertMessage;
// set button color
#endif

#pragma mark button design

+ (UIButton *)buttonWithTitle:	(NSString *)title target:(id)target selector:(SEL)selector frame:(CGRect)frame image:(UIImage *)image imagePressed:(UIImage *)imagePressed
				darkTextColor:(BOOL)darkTextColor;

+ (void) setColorButton:(UIButton*)btn Color:(ButtonColor)btnColor;

+ (void) setButtonTitle:(NSString*)title Button:(UIButton*)btn;

+ (NSArray*) allocArrayByFutureSymbol:(NSString*)futureSymbol OurServer:(BOOL)os;	//自己期貨的Symbol 轉成下單用的 Array第一個是symbol 第二個是 fullname

//+ (NSArray*) OptionSymbol:(NSString*)optionSymbol OurServer:(BOOL)os;	//自己選擇權的Symbol 轉成下單用的 Array第一個是symbol 第二個是 fullname

+ (NSString*) getOrderStatusByType:(int)type;
+ (NSString *)getSinopacVersionQuertStatusByType:(int)type;

#pragma mark UIAnimation專用

+ (void) animationNextPage:(UIView*)animationView;
+ (void) animationPrePage:(UIView*)animationView;

#pragma mark TDAmeritrade在用的
#ifdef BROKER_TDAMERITRADE

//Alloc一個Loading的page放在window最上層 當WaitCheck==YES時 代表需要按確定才開始傳輸 此時需要CheckString代表一開始的文字
+ (void) ameritradeLoading:(NSString*)initString WaitCheck:(BOOL)wc CheckString:(NSString*)cs Controller:(NSObject <TDAmeritradeLoadingProtocol>*)obj;

//抓出loading Page的TextView 把alertMessage塞進去
+ (void) ameritradeLoadingAlertMessage:(NSString*)alertMessage;

#endif
@end

@interface TAvalueParam : NSObject{
	NSString *nameString;
@public
	double value;
	UInt8 unit;
}

@property (nonatomic,copy) NSString *nameString;

@end



@interface SymbolFormat1 : NSObject{
@public
	UInt16 sectorID;
	char IdentCode[2];
	UInt8 symbolLength;
	NSString *symbol;
	UInt8 typeID;
	UInt8 fullNameLength;
	NSString *fullName;	
}
- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset;
@end

@interface SymbolFormat2 : NSObject{
	UInt8 typeID;
	UInt8 symbolLength;
	NSString *symbol;
	UInt8 fullNameLength;
	NSString *fullName;		
}
- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset;
@end

@interface SymbolFormat3 : NSObject{
@public
	char IdentCode[2];
	UInt8 symbolLength;
	NSString *symbol;
}
- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset;
@end

@interface SymbolFormat4 : NSObject{
	UInt8 symbolLength;
	NSString *symbol;
}
- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset;
@end

@interface SymbolFormat5 : NSObject{
@public
	char IdentCode[2];
	UInt8 symbolLength;
	NSString *symbol;
	UInt16 year;
	UInt8 month;
	UInt8 fullNameLength;
	NSString *fullName;
	NSString *period;
}
- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset;
@end

@interface SymbolFormat6 : NSObject{
@public
	char IdentCode[2];
	UInt8 symbolLength;
	NSString *symbol;
	UInt16 year;
	UInt8 month;	
}
- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset;
@end

@interface bValueFormat1 : NSObject{
@public
	UInt8 decimal;
    UInt8 positive;
    UInt16 dataValue;
}
- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset;
@end

@interface bValueFormat2 : NSObject{
@public
	UInt8 decimal;
    UInt8 positive;
    UInt32 dataValue;
}
- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset;
@end

@interface bValueFormat3 : NSObject{
@public
	UInt8 decimal;
    UInt8 type;
    UInt8 exponent;
    UInt8 positive;
    UInt64 dataValue;
}
- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset;
@end

@interface shortStringFormat : NSObject{
@public
	UInt8 length;
    NSString * dataString;
}
- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset;
@end

@interface TrackUpFormat : NSObject{
@public
	NSString * identCode;
	NSString * symbol;
	NSString * date;
    NSString * session;
    NSString * fullName;
    float markPrice;
}
@end

@interface TrackDownFormat : NSObject{
@public
	NSString * identCode;
	NSString * symbol;
    NSString * fullName;
    NSString * type;
	NSString * date;
    NSString * session;
    float high;
    float low;
    float todayPrice;
    float trackPrice;
    float ROI;
}
@end


@interface NewSymbolObject : NSObject

@property (nonatomic ,strong) NSString * identCode;
@property (nonatomic ,strong) NSString * symbol;
@property (nonatomic ,strong) NSString * fullName;
@property (nonatomic) int typeId;

@end
