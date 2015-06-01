//
//  EDOTargetModel.h
//  FonestockPower
//
//  Created by Kenny on 2014/5/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EODTargetModel : NSObject
-(NSMutableArray *)searchFigureSearchIdWithGategory:(NSString *)gategory ItemOrder:(NSNumber *)itemOrder;
-(NSMutableArray *)getLongSystem;
-(NSMutableArray *)getShortSystem;
+(NSData *)getTPNImage:(int)item;
+(NSString *)getTPNName:(int)item;
@end

@interface SystemObject : NSObject
@property (nonatomic) int imageID;
@property (nonatomic, strong) NSString *imageNmae;
@property (nonatomic, strong) NSData *imageData;
@end