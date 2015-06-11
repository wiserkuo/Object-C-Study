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

-(void)setDefaultDBData{
    [self setDefaultPortfolio];
    [self setDefaultSymbol];
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

-(void)setDefaultPortfolio{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    if ([_group isEqualToString:@"us"]) {
        NSArray * objArray = [[NSArray alloc]initWithObjects:@"US GOOG",@"US AMZN",@"US AAPL",@"US JPM",@"US GS", nil];
        for (int i=0; i<2; i++) {
            for (int j =0; j<[objArray count]; j++) {
                [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
                    [db executeUpdate:@"INSERT INTO groupPortfolio(IdentCodeSymbol, groupID) VALUES(?,?)",[objArray objectAtIndex:j],[NSNumber numberWithInt:i]];
                }];
            }
            
        }
    }else if ([_group isEqualToString:@"cn"]){
        NSArray * objArray = [[NSArray alloc]initWithObjects:@"SS 600000",@"SS 600019",@"SS 600519",@"SZ 000024",@"SZ 000100", nil];
        for (int i=0; i<2; i++) {
            for (int j =0; j<[objArray count]; j++) {
                [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
                    [db executeUpdate:@"INSERT INTO groupPortfolio(IdentCodeSymbol, groupID) VALUES(?,?)",[objArray objectAtIndex:j],[NSNumber numberWithInt:i]];
                }];
            }
            
        }
    }else{
        NSArray * objArray = [[NSArray alloc]initWithObjects:@"TW ^tse01", nil];
        for (int i=0; i<2; i++) {
            for (int j =0; j<[objArray count]; j++) {
                [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
                    [db executeUpdate:@"INSERT INTO groupPortfolio(IdentCodeSymbol, groupID) VALUES(?,?)",[objArray objectAtIndex:j],[NSNumber numberWithInt:i]];
                }];
            }
            
        }
    }
}

-(void)setDefaultSymbol{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    if ([_group isEqualToString:@"us"]) {
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','AAPL','1','Apple Inc.','301')"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','AMZN','1','Amazon.com, Inc.','301')"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','GOOG','1','Google Inc.','301')"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','GS','1','GOLDMAN SACHS GRP','300')"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','JPM','1','JP MORGAN CHASE CO','300')"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^DJI','3','DOW JONES INDUSTRIAL AVERAGE INDEX','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^DJT','3','DOW JONES TRANSPORTATION AVERAG','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^GSPC','3','S&P 500 INDEX,RTH','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^IXBK','3','NASDAQ BANK','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^IXF','3','NASDAQ FINANCIAL 100','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^IXIC','6','NASDAQ COMPOSITE','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^IXID','3','NASDAQ INDUSTRIAL','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^IXIS','3','NASDAQ INSURANCE','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^IXK','3','NASDAQ COMPUTER','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^IXTR','3','NASDAQ TRANSPORTATION','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^IXUT','3','NASDAQ TELECOMMUNICATIONS','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^MID','3','S&P 400 MIDCAP INDEX','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^NBI','3','NASDAQ BIOTECHNOLOGY','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^NDX','3','NASDAQ-100','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^NYA','6','NYSE COMPOSITE INDEX (NEW METHOD)','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^OEX','3','S&P 100 INDEX,RTH','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^RUT','3','RUSSELL 2000 INDEX','303');"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('US','^SOXX','3','PHLX SEMICONDUCTOR SECTOR INDEX','303');"];
            
        }];
    }else if ([_group isEqualToString:@"cn"]){
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('SS','000001','3','上证指数','102')"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('SS','600000','1','浦发银行','103')"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('SS','600019','1','宝钢股份','103')"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('SZ','000024','1','招商地产','123')"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('SZ','000100','1','TCL集团','123')"];
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('SS','600519','1','贵州茅台','103')"];
        }];
        
    }else{
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('TW','^tse01','6','加權指數','100')"];
//            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('TW','2330','1','台積電','82')"];
//            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('TW','1301','1','台塑','24')"];
//            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('TW','2912','1','統一超','39')"];
//            [db executeUpdate:@"INSERT INTO Cat_FullName(IdentCode,Symbol,Type_id,FullName,SectorID) VALUES ('TW','2881','1','富邦金','38')"];
        }];
    }
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
                                [NSNumber numberWithFloat:3.5],[NSNumber numberWithFloat:5],[NSNumber numberWithFloat:10],[NSNumber numberWithInt:i]];
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
