//
//  FSTechModel.m
//  FonestockPower
//
//  Created by Neil on 2014/8/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSTechModel.h"
#import "FMDB.h"
#import "FMDatabaseAdditions.h"
#import "IndexScaleView.h"

@implementation FSTechModel

-(NSMutableArray*)selectUserLineByIdentCode:(NSString *)ids analysisPeriod:(NSNumber*)ap{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSMutableArray * pointArray = [[NSMutableArray alloc]init];
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM TechUserLine WHERE IdentCodeSymbol = ? And analysisPeriod = ?",ids,ap];
        while ([message next]) {
            Line * line = [[Line alloc]init];
            line.lineType = [message intForColumn:@"lineType"];
            line.lineNum = [message intForColumn:@"lineNumber"];
            CGPoint pA = CGPointMake([message doubleForColumn:@"pointAx"], [message doubleForColumn:@"pointAy"]);
            line.pointA = pA;
            
            CGPoint pB = CGPointMake([message doubleForColumn:@"pointBx"], [message doubleForColumn:@"pointBy"]);
            line.pointB = pB;
            
            [pointArray addObject:line];
            
        }
        [message close];
    }];
    return pointArray;
}

-(void)insertUserLineByIdentCode:(NSString *)ids analysisPeriod:(NSNumber*)ap lineType:(NSNumber*)lt lineNumber:(NSNumber*)ln pointA:(CGPoint)pointA pointB:(CGPoint)pointB{
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"INSERT INTO TechUserLine (identCodeSymbol, analysisPeriod, lineType, lineNumber, pointAx, pointAy, pointBx, pointBy) VALUES (?,?,?,?,?,?,?,?)",ids,ap,lt,ln,[NSNumber numberWithFloat:pointA.x],[NSNumber numberWithFloat:pointA.y],[NSNumber numberWithFloat:pointB.x],[NSNumber numberWithFloat:pointB.y]];
        
    }];
}

-(void)deleteUserLineByIdentCode:(NSString *)ids analysisPeriod:(NSNumber*)ap{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;

    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM TechUserLine WHERE IdentCodeSymbol = ? And analysisPeriod = ?",ids,ap];

    }];

}

@end
