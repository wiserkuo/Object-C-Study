//
//  PatternTipsModel.h
//  FonestockPower
//
//  Created by Kenny on 2015/1/14.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol FSPatternTipsDelegate;

@interface PatternTipsModel : NSObject
@property (weak, nonatomic) id <FSPatternTipsDelegate> delegate;
@property (nonatomic, strong) NSString *downloadURL;
+(NSMutableArray *)getImgData:(NSString *)gategory;
+(NSMutableArray *)getImgName:(NSString *)gategory;
+(NSMutableDictionary *)DataFromFileIn:(NSData *)data;
+(NSString *)getFileTime:(NSString *)targetFile;
+(NSString *)getTheFileInMyFileFolder;
@end

@protocol FSPatternTipsDelegate <NSObject>
@required
-(void)loadDidFinishWithData:(PatternTipsModel *)data;
@end

@interface TipsSymbolObject : NSObject
@property (nonatomic, strong) NSString *identCodeSymbol;
@property (nonatomic, strong) NSString *identCode;
@property (nonatomic, strong) NSString *Symbol;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic) double last;
@property (nonatomic) double reference;
@end

@interface PatternTipsObject : NSObject
@property (nonatomic, strong) NSString *tipsName;
@property (nonatomic, strong) NSData *tipsImg;
@property (nonatomic, strong) NSMutableArray *tipsData;
@property (nonatomic) int dataCount;
@end
