//
//  DefaultDBData.m
//  WirtsLeg
//
//  Created by Neil on 14/4/9.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import "DefaultDBData.h"
#import "FigureSearchMyProfileModel.h"
#import "FMDB.h"


@implementation DefaultDBData
- (id)init {
    if (self = [super init]) {
        NSString * appid = [FSFonestock sharedInstance].appId;
        self.group = [appid substringWithRange:NSMakeRange(0, 2)];
//#ifdef SERVER_SYNC
        self.customModel = [FigureSearchMyProfileModel sharedInstance];
//#endif
        
    }
    return self;
}

- (void)setDefaultDBData {
    
    // 新增自選股
    [self setDefaultSymbol];
    [self setDefaultPortfolio];
    
    [self setDefaultImage];
    [self setDefaultGroupName];
    [self setDefaultFigureSearchRangeValue];
}

-(void)setDefaultImage{
    [self setMoreImageWithName:@"more"];
    [self setZeroImageWithName:@"zero"];
    [self setLongDiyPatternWithName:@"DIY Pattern - Long Default"];
    [self setShortDiyPatternWithName:@"DIY Pattern - Short Default"];
    
}

-(void)setMoreImageWithName:(NSString *)name{
    for (int i=1;i<=12 ; i++) {
        UIImage *image =[UIImage imageNamed:[NSString stringWithFormat:@"%@_%d",name,i]];
        NSData *imageData = UIImagePNGRepresentation(image);
        [_customModel changeFigureSearchImageWithFigureSearchId:[NSNumber numberWithInt:i] Image:imageData];
    }
}

-(void)setZeroImageWithName:(NSString *)name{
    for (int i=1;i<=12 ; i++) {
        UIImage *image =[UIImage imageNamed:[NSString stringWithFormat:@"%@_%d",name,i]];
        NSData *imageData = UIImagePNGRepresentation(image);
        [_customModel changeFigureSearchImageWithFigureSearchId:[NSNumber numberWithInt:i+12] Image:imageData];
    }
}

-(void)setLongDiyPatternWithName:(NSString *)name{
    for (int i=1;i<=12 ; i++) {
        UIImage *image =[UIImage imageNamed:name];
        NSData *imageData = UIImagePNGRepresentation(image);
        [_customModel changeFigureSearchImageWithFigureSearchId:[NSNumber numberWithInt:i+24] Image:imageData];
        if ([_group isEqualToString:@"cn"]){
            [_customModel changeFigureSearchNameWithFigureSearchId:[NSNumber numberWithInt:i+24] Name:[NSString stringWithFormat:@"形态 %d",i]];
        }else if ([_group isEqualToString:@"tw"]){
            [_customModel changeFigureSearchNameWithFigureSearchId:[NSNumber numberWithInt:i+24] Name:[NSString stringWithFormat:@"型態 %d",i]];
        }else if ([_group isEqualToString:@"us"]){
            [_customModel changeFigureSearchNameWithFigureSearchId:[NSNumber numberWithInt:i+24] Name:[NSString stringWithFormat:@"My %d",i]];
        }
        
    }
}

-(void)setShortDiyPatternWithName:(NSString *)name{
    for (int i=1;i<=12 ; i++) {
        UIImage *image =[UIImage imageNamed:name];
        NSData *imageData = UIImagePNGRepresentation(image);
        [_customModel changeFigureSearchImageWithFigureSearchId:[NSNumber numberWithInt:i+36] Image:imageData];
        if ([_group isEqualToString:@"cn"]){
            [_customModel changeFigureSearchNameWithFigureSearchId:[NSNumber numberWithInt:i+36] Name:[NSString stringWithFormat:@"形态 %d",i]];
        }else if ([_group isEqualToString:@"tw"]){
            [_customModel changeFigureSearchNameWithFigureSearchId:[NSNumber numberWithInt:i+36] Name:[NSString stringWithFormat:@"型態 %d",i]];
        }else if ([_group isEqualToString:@"us"]){
            [_customModel changeFigureSearchNameWithFigureSearchId:[NSNumber numberWithInt:i+36] Name:[NSString stringWithFormat:@"My %d",i]];
        }
    }
}

- (void)setDefaultPortfolio {
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    NSMutableArray *defaultPortfolio = [[NSMutableArray alloc] init];
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        // 美股:道瓊,那期達克,費城半導體,S&P500
        [defaultPortfolio addObject:@"US ^DJI"];
        [defaultPortfolio addObject:@"US ^IXIC"];
        [defaultPortfolio addObject:@"US ^SOXX"];
        [defaultPortfolio addObject:@"US ^GSPC"];
    } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        // 陸股:上証指數,深証成份指數
        [defaultPortfolio addObject:@"SS 000001"];
        [defaultPortfolio addObject:@"SZ 399001"];
    
    } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        // 台股:加權指數
        [defaultPortfolio addObject:@"TW ^tse01"];
    }
    
    [dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i = 0; i <= 1; i++) {
            for (NSString *name in defaultPortfolio) {
                [db executeUpdate:@"INSERT INTO groupPortfolio(IdentCodeSymbol, groupID) VALUES(?, ?)", name ,[NSNumber numberWithInt:i]];
            }
        }
    }];
    
}

- (void)setDefaultSymbol {
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    NSMutableArray *defaultPortfolio = [[NSMutableArray alloc] init];
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        // 美股:道瓊,那期達克,費城半導體,S&P500
        [defaultPortfolio addObject:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^DJI','3','DOW JONES INDUSTRIAL AVERAGE INDEX','303');"];
        [defaultPortfolio addObject:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^IXIC','6','NASDAQ COMPOSITE','303');"];
        [defaultPortfolio addObject:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^SOXX','3','PHLX SEMICONDUCTOR SECTOR INDEX','303');"];
        [defaultPortfolio addObject:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^GSPC','3','S&P 500 INDEX,RTH','303');"];
    } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        // 陸股:上証指數,深証成份指數
        [defaultPortfolio addObject:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('SS','000001','3','上证指数','102')"];
        [defaultPortfolio addObject:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('SZ','399001','3','深证成份指数','102')"];
    } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        // 台股:加權指數
        [defaultPortfolio addObject:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('TW','^tse01','6','加權指數','100')"];
    }
    
    [dbAgent inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString *sql in defaultPortfolio) {
            [db executeUpdate:sql];
        }
    }];
}


-(void)setDefaultGroupName{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSArray * objArray = [[NSArray alloc]initWithObjects:@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十", nil];
    if ([_group isEqualToString:@"cn"]) {
        for (int i=0; i<10; i++) {
            [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
                [db executeUpdate:@"UPDATE groupName SET groupName = ? WHERE GroupIndex = ?",[NSString stringWithFormat:@"自选%@",[objArray objectAtIndex:i]],[NSNumber numberWithInt:i]];
            }];
            
        }
    }else if([_group isEqualToString:@"tw"]){
        for (int i=0; i<10; i++) {
            [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
                [db executeUpdate:@"UPDATE groupName SET groupName = ? WHERE GroupIndex = ?",[NSString stringWithFormat:@"自選%@",[objArray objectAtIndex:i]],[NSNumber numberWithInt:i]];
            }];
            
        }
    }else if([_group isEqualToString:@"us"]){
        for (int i=0; i<10; i++) {
            [ dbAgent inDatabase:  ^ (FMDatabase  * db )  {
               [db executeUpdate:@"UPDATE groupName SET groupName = ? WHERE GroupIndex = ?",
                [NSString stringWithFormat:@"Group %d",i + 1],[NSNumber numberWithInt:i]];
            }];
        }
    }
}

-(void)setDefaultFigureSearchRangeValue
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block BOOL modify = NO;
    if([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW){
        [ dbAgent inTransaction:  ^ (FMDatabase  * db , BOOL *rollback)  {
            
            for(int i = 1; i < 49; i++){
                BOOL success = [db executeUpdate:@"UPDATE FigureSearch SET dayRange = ?, weekRange = ?, monthRange = ? WHERE figureSearch_ID = ?",
                                [NSNumber numberWithFloat:5],[NSNumber numberWithFloat:7],[NSNumber numberWithFloat:10],[NSNumber numberWithInt:i]];
                if(!success){
                    *rollback = YES;
                    return;
                }
                modify = YES;
            }
        }];

    }else{
        [ dbAgent inTransaction:  ^ (FMDatabase  * db , BOOL *rollback)  {
            
            for(int i = 1; i < 49; i++){
                BOOL success = [db executeUpdate:@"UPDATE FigureSearch SET dayRange = ?, weekRange = ?, monthRange = ? WHERE figureSearch_ID = ?",
                                [NSNumber numberWithFloat:5.0],[NSNumber numberWithFloat:10],[NSNumber numberWithFloat:15],[NSNumber numberWithInt:i]];
                if(!success){
                    *rollback = YES;
                    return;
                }
                modify = YES;
            }
        }];
        
    }
}

@end
