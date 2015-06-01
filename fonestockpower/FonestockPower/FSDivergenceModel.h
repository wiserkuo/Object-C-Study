//
//  FSDivergenceModel.h
//  DivergenceStock
//
//  Created by Connor on 2014/12/1.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FSDivergenceDelegate;
@class ReturnTwoArrayObjects;
@interface FSDivergenceModel : NSObject

@property (weak, nonatomic) id <FSDivergenceDelegate> delegate;

+ (NSArray *)figureTheTick:(UInt16)target;

+ (NSString*) allocNSStringByBuffer:(UInt8*)buffer Offset:(int)offset Length:(UInt32)len Encoding:(NSStringEncoding)encoding;

+(NSString *)separatePositiveOrNegative:(float)value;
//因應lastPrice 小於refPrice 所產出的結果須加上+ ，反之加上-

+(UIColor *)makeItGreenOrRed:(float)value;
//傳入的值如果為負則為綠色，正為紅色，零為藍色

+(BOOL)isItYesOrNo:(NSArray *)array :(NSInteger)firstObjIndex :(NSInteger)indexNum;
//此處的array 為二維陣列，在判斷第二維陣列的字串內容是否為@""，如果是則回傳yes

//+(NSString *)getTheURLInDownStream:(NSData *)data;
//將透過protocolBuffer 取得的下行電文進行解析以取得具有資料的網址，並將其回傳

//+(void)DataFromServerIn:(NSData *)data storeBull:(NSMutableArray *)storeBull storeBear:(NSMutableArray *)storeBear;
+(ReturnTwoArrayObjects *)DataFromServerIn:(NSData *)data;
//將NSData 的資料整理並存在對應的storeBull 陣列或storeBear 陣列裡

-(void)protocolBufferCallBack:(id)sender;
@property (nonatomic, strong) NSString *downloadURL;
//透過protocolBuffer 接收下行電文後會送至此處

+(NSURLRequest *)openExplanation;

-(NSString *)getFileTime:(NSString *)targetFile;

-(NSString *)getTheFileInMyFileFolder;

- (void)reloadProtocolBuffersData;


@end

@protocol FSDivergenceDelegate <NSObject>
@required
-(void)loadDidFinishWithData:(FSDivergenceModel *)data;
@end

//@interface SymbolFormat1 : NSObject{
//@public
//    char IdentCode[2];
//}
//
//@property (nonatomic) UInt16 sectorID;
//@property (nonatomic) UInt8 symbolLength;
//@property (nonatomic, strong) NSString *symbol;
//@property (nonatomic) UInt8 typeID;
//@property (nonatomic) UInt8 fullNameLength;
//@property (nonatomic, strong) NSString *fullName;
//
//- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset;
//@end

@interface CompleteStuff : NSObject
@property (nonatomic, strong) SymbolFormat1 *symbol;
@property (nonatomic) UInt32 lastPrice;
@property (nonatomic) UInt32 refPrice;
@property (nonatomic, strong) NSMutableArray *divergenceObject;
@end

@interface ContainerForThreeObjects : NSObject
@property (nonatomic, strong) NSArray *divIDTick;
@property (nonatomic, strong) NSString *divPointerID;
@property (nonatomic) UInt16 startDate;
@property (nonatomic) UInt16 endDate;
@end

@interface FSShowResultAdObj : NSObject
@property NSString *uri;
@property NSString *img;
@end

@interface ReturnTwoArrayObjects : NSObject
@property (nonatomic, strong) NSMutableArray *storeBear;
@property (nonatomic, strong) NSMutableArray *storeBull;
@end
