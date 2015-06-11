//
//  FSTechModel.h
//  FonestockPower
//
//  Created by Neil on 2014/8/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSTechModel : NSObject

-(void)deleteUserLineByIdentCode:(NSString *)ids analysisPeriod:(NSNumber*)ap;

-(void)insertUserLineByIdentCode:(NSString *)ids analysisPeriod:(NSNumber*)ap lineType:(NSNumber*)lt lineNumber:(NSNumber*)ln pointA:(CGPoint)pointA pointB:(CGPoint)pointB;

-(NSMutableArray *)selectUserLineByIdentCode:(NSString *)ids analysisPeriod:(NSNumber*)ap;

@end
