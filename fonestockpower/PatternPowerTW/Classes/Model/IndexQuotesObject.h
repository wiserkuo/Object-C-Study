//
//  IndexQuotesObject.h
//  IndexQuotesViewController
//
//  Created by CooperLin on 2014/10/17.
//  Copyright (c) 2014年 CooperLin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface allInfoStorage : NSObject
@property (nonatomic, strong) NSMutableArray *storeInfo;
@end
@interface showInfoFormat :NSObject{
@public
    NSString *name;
    CGFloat last;
    CGFloat change;
    CGFloat changeRate;
    CGFloat highest;
    CGFloat lowest;
    CGFloat singleAmount;
    CGFloat totalAmount;
}
@end

@interface getAllCatNameAndID : NSObject
@property (nonatomic, strong) NSMutableArray *storeNameAndID;
@end
@interface showNameAndID : NSObject{
@public
    NSString *name;
    NSString *catID;
}
@end

@interface IndexQuotesObject : NSObject

-(NSMutableArray *)getNameAndIDFromDB;

-(NSMutableArray *)getStockNameFromCatFullName:(NSString *)theCatID;

-(NSMutableArray *)fillSymbolObject:(NSInteger)fromWhat;

-(NSString *)convertDecimalPoint:(CGFloat)value;

-(UIColor *)compareToZero:(CGFloat)value;

-(NSString *)formatCGFloatData:(CGFloat)value;

-(NSString *)forTWUse:(NSString *)hasLetter;
@end
