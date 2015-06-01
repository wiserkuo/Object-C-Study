//
//  InternationalInfoObject_v1.h
//  FonestockPower
//
//  Created by CooperLin on 2014/10/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface theSecurityNodes_v1 : NSObject

@property (nonatomic, strong) NSMutableArray *forexArray;
@property (nonatomic, strong) NSMutableArray *materialArray;
@property (nonatomic, strong) NSMutableArray *industryArray;

@end

@interface forexFormat : NSObject{
@public
    NSString * name;
    CGFloat last;
    CGFloat oneDay;
    CGFloat oneWeek;
    CGFloat oneMonth;
    CGFloat threeMonth;
}
@end

@interface materialFormat : NSObject{
@public
    NSString *name;
    NSString *exchange;
    CGFloat last;
    CGFloat oneDay;
    CGFloat oneWeek;
    CGFloat oneMonth;
}
@end

@interface industryFormat :NSObject {
@public
    NSString *name;
    CGFloat last;
    CGFloat oneDay;
    CGFloat oneWeek;
    CGFloat oneMonth;
    CGFloat threeMonth;
    CGFloat sixMonth;
    CGFloat w52High;
    CGFloat w52Low;
    CGFloat thisYearHigh;
    CGFloat thisYearLow;
}
@end

@interface InternationalInfoObject_v1 : NSObject<NSURLConnectionDataDelegate,NSXMLParserDelegate>

typedef NS_ENUM(NSUInteger, InternationalTarget){
    InternationalTargetForex = 1,
    InternationalTargetMaterial = 2,
    InternationalTargetIndustry = 3
};

@property (nonatomic, strong) NSMutableArray *items;

-(NSString *)lookingForIdPath:(NSString *)fileName;

-(NSString *)getTheSectorID:(NSString *)fromWhat;

-(NSMutableArray *)loadWeb:(NSString *)sectorID :(NSInteger)forHeader;

-(NSString *)findTheTimeStamp:(NSInteger)what :(NSString *)tss;

-(NSMutableArray *)parseXML:(NSString *)fileName :(NSInteger)forHeader;

-(NSString *)convertDecimalPoint:(CGFloat)value;

-(UIColor *)compareToZero:(CGFloat)value;

-(NSString *)formatCGFloatData:(CGFloat)value;


-(NSString *)formatCGFloatDataChange:(CGFloat)value;

-(NSString *)formatCGFloatDataChangeUp:(CGFloat)value;

-(BOOL)isFileExists:(NSString *)sectorID;

-(UIColor *)compareToZeroRecUse:(CGFloat)value;

-(NSString *)formatCGFloatDataVolume:(CGFloat)value;

-(NSString *)formatCGFloatDataRank:(CGFloat)value;

@end
