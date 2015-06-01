//
//  InternationalInfoObject_v1.m
//  FonestockPower
//
//  Created by CooperLin on 2014/10/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "InternationalInfoObject_v1.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "FMDatabase.h"

@implementation InternationalInfoObject_v1{
    NSString *link;
    NSString *contentStr;
    NSData *resContain;
    BOOL codeLock;
    int code;
    //NSString *storeFileName;
    theSecurityNodes_v1 *tsn;
    InternationalInfoObject_v1 *iifo;
    
    forexFormat *fft;
    materialFormat *mft;
    industryFormat *ift;
    
    //for FMDB
    BOOL success;
    NSError *error;
    NSFileManager *fm;
    NSArray *paths;
    NSString *documentsDirectory;
    NSString *writableDBPath;
}

@synthesize items;


-(NSString *)getTheSectorID:(NSString *)fromWhat
{
    NSMutableArray *arT = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *getSectorID;
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT CatID FROM category Where CatName = ?",fromWhat];
        while([rs next]){
            NSString *putInArT = [NSString stringWithFormat:@"%d",[rs intForColumn:@"CatID"]];
            
            [arT addObject:putInArT];
        }
    }];
    if([arT count] > 0){
        getSectorID = [arT objectAtIndex:0];
    }
    return getSectorID;
}

-(BOOL)isFileExists:(NSString *)sectorID
{
    NSString *storeFileName =[NSString stringWithFormat:@"xmlTest%@.xml",sectorID];
    NSString* xmlFile = [self lookingForIdPath:storeFileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:xmlFile];
    return fileExists;
}

-(void)settingNSData:(NSString *)sectorID
{
    link = [NSString stringWithFormat:@"http://kqstock.fonestock.com:2172/query/international_info.cgi%%20?cmd=snapshot&sector_id=%@&data_timestamp=%@",sectorID,@"NULL"];
    
    resContain = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]] returningResponse:nil error:nil];
    contentStr = [[NSString alloc] initWithData:resContain encoding:NSUTF8StringEncoding];
    NSLog(@"connecting to the internet");
}

-(NSMutableArray *)loadWeb:(NSString *)sectorID :(NSInteger)forHeader
{
    //讓這裡單純做parser 網路的資料，儲存的method 也是這裡才有
    //NSMutableArray *showInTheTableView;
    tsn = [[theSecurityNodes_v1 alloc] init];

    [self settingNSData:sectorID];
    NSString *storeFileName =[NSString stringWithFormat:@"xmlTest%@.xml",sectorID];
    [self storeFileXML:storeFileName];
    return [self parseXMLOnLine:forHeader];
}

-(NSString *)lookingForIdPath:(NSString *)fileName
{
    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [cachePathArray lastObject];
    NSLog(@"%@",cachePath );
    NSString *idPath = [cachePath stringByAppendingPathComponent:fileName];
    return idPath;
}

-(void)storeFileXML:(NSString *)fileName
{
    NSString *idPath = [self lookingForIdPath:fileName];
    NSError *err = [[NSError alloc] init];
    BOOL a = [contentStr writeToFile:idPath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if(a){
        NSLog(@"store to XML file");
    }else{
        NSLog(@"store to XML file error %@",err);
    }
}

-(NSData *)readFileXML:(NSString *)fileName
{
    NSString *idPath = [self lookingForIdPath:fileName];
    NSData *titleData = [[NSData alloc] initWithContentsOfFile:idPath];
    return titleData;
}

-(NSString *)findTheTimeStamp:(NSInteger)what :(NSString *)tss
{
    //what == 0 means find the timeStamp from the web data
    //what == 1 means get the timeStamp from the plist ->不需要了吧@@
    //what == 2 means store the timeStamp to the plist ->不需要了吧@@
    //what == 3 means get the timeStamp from the XML
    NSString *timeStamp;
    if(what == 0){
        DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:resContain options:0 error:nil];
        NSArray *findTimeStamp = [xmlDoc nodesForXPath:@"//data_timestamp" error:nil];
        if(findTimeStamp){
            timeStamp = [[findTimeStamp objectAtIndex:0] stringValue];
        }
    }else if(what == 1){
        NSString *idPath = [self lookingForIdPath:@"TimeStampData.plist"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath: idPath]) {
            NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:idPath];
            timeStamp = [data objectForKey:@"timeStamp"];
        }else{
            timeStamp = @"NULL";
        }
        
    }else if(what == 2){
        NSString *idPath = [self lookingForIdPath:@"TimeStampData.plist"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSMutableDictionary *data;
        
        if ([fileManager fileExistsAtPath: idPath]) {
            data = [[NSMutableDictionary alloc] initWithContentsOfFile:idPath];
        } else {
            data = [[NSMutableDictionary alloc] init];
        }
        [data setValue:[NSString stringWithFormat:@"%@",tss] forKey:@"timeStamp"];
        [data writeToFile:idPath atomically:YES];
    }else if(what == 3){
        NSString *idPath = [self lookingForIdPath:tss];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath: idPath]) {
            NSData *data = [[NSData alloc] initWithContentsOfFile:idPath];
            DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
            NSArray *myNodes = [xmlDoc nodesForXPath:@"//data_timestamp" error:nil];
            timeStamp = [[myNodes objectAtIndex:0] stringValue];
        }
    }
    return timeStamp;
}

-(NSMutableArray *)parseXML:(NSString *)sectorID :(NSInteger)forHeader
{
    NSLog(@"parse XML from the file");
    
    NSMutableArray *aa = [[NSMutableArray alloc] init];
    id dd;
    NSString *storeFileName =[NSString stringWithFormat:@"xmlTest%@.xml",sectorID];
    NSData *data = [NSData dataWithContentsOfFile:[self lookingForIdPath:storeFileName]];
    
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
    
    NSArray *myNodes = [xmlDoc nodesForXPath:@"//security" error:nil];
    //security[last()-1] means select backward count second object
    for(DDXMLElement *xmlEle in myNodes){
        DDXMLElement *nameEle = [xmlEle elementForName:@"name"];
        NSString *name;
        NSString *exchange;
        if(nameEle){
            name = [nameEle stringValue];
        }
        DDXMLElement *exchangeEle = [xmlEle elementForName:@"exchange"];
        if(exchangeEle){
            exchange = [exchangeEle stringValue];
        }
        DDXMLElement *insideEle = [xmlEle elementForName:@"snapshot"];
        if(insideEle){
            DDXMLElement *referenceNode = [insideEle elementForName:@"reference"];
            CGFloat reference = [(NSNumber *)[referenceNode stringValue] floatValue];
            DDXMLElement *lastNode = [insideEle elementForName:@"last"];
            CGFloat last = [(NSNumber *)[lastNode stringValue] floatValue];
            DDXMLElement *thisYH = [insideEle elementForName:@"this_year_high"];
            CGFloat thisYearHigh = [(NSNumber *)[thisYH stringValue] floatValue];
            DDXMLElement *thisYL = [insideEle elementForName:@"this_year_low"];
            CGFloat thisYearLow = [(NSNumber *)[thisYL stringValue] floatValue];
            DDXMLElement *w52h = [insideEle elementForName:@"W52_high"];
            CGFloat w52High = [(NSNumber *)[w52h stringValue] floatValue];
            DDXMLElement *w52l = [insideEle elementForName:@"W52_low"];
            CGFloat w52Low = [(NSNumber *)[w52l stringValue] floatValue];
            DDXMLElement *close1WNode = [insideEle elementForName:@"close_1W"];
            CGFloat close_1W = [(NSNumber *)[close1WNode stringValue] floatValue];
            DDXMLElement *close1MNode = [insideEle elementForName:@"close_1M"];
            CGFloat close_1M = [(NSNumber *)[close1MNode stringValue] floatValue];
            DDXMLElement *close3MNode = [insideEle elementForName:@"close_3M"];
            CGFloat close_3M = [(NSNumber *)[close3MNode stringValue] floatValue];
            DDXMLElement *close6MNode = [insideEle elementForName:@"close_6M"];
            CGFloat close_6M = [(NSNumber *)[close6MNode stringValue] floatValue];
            DDXMLElement *cnn = [insideEle elementForName:@"cn_name"];
            NSString *cnName = @"";
            if(cnn){
                cnName = [cnn stringValue];
            }
            dd = [self putDataIntoObject:name :exchange :reference :last :thisYearHigh :thisYearLow :w52High :w52Low :close_1W :close_1M :close_3M :close_6M :cnName :forHeader];
        }
        [aa addObject:dd];
        //加入陣列的動作
    }
    [self settingNSData:sectorID];
    [self whetherNeedToUpdateOrNot:sectorID];
    return aa;
}

-(void)whetherNeedToUpdateOrNot:(NSString *)sectorID
{
    NSString *storeFileName =[NSString stringWithFormat:@"xmlTest%@.xml",sectorID];
    if(![[self findTheTimeStamp:3 :storeFileName] isEqualToString:[self findTheTimeStamp:0 :@"NULL"]]){
        [self storeFileXML:storeFileName];
        NSLog(@"兩個不相同才需要儲存，第二次進來後資料應該就是一樣的");
    }
}

-(NSMutableArray *)parseXMLOnLine:(NSInteger)forHeader
{
    NSLog(@"parse XML from the internet");
    
    NSData *data = resContain;
    NSMutableArray *aa = [[NSMutableArray alloc] init];
    NSDictionary *dd;
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
    
    NSArray *myNodes = [xmlDoc nodesForXPath:@"//security" error:nil];
    //security[last()-1] means select backward count second object
    for(DDXMLElement *xmlEle in myNodes){
        DDXMLElement *nameEle = [xmlEle elementForName:@"name"];
        NSString *name;
        NSString *exchange;
        if(nameEle){
            name = [nameEle stringValue];
        }
        DDXMLElement *exchangeEle = [xmlEle elementForName:@"exchange"];
        if(exchangeEle){
            exchange = [exchangeEle stringValue];
        }
        DDXMLElement *insideEle = [xmlEle elementForName:@"snapshot"];
        if(insideEle){
            DDXMLElement *referenceNode = [insideEle elementForName:@"reference"];
            CGFloat reference = [(NSNumber *)[referenceNode stringValue] floatValue];
            DDXMLElement *lastNode = [insideEle elementForName:@"last"];
            CGFloat last = [(NSNumber *)[lastNode stringValue] floatValue];
            DDXMLElement *thisYH = [insideEle elementForName:@"this_year_high"];
            CGFloat thisYearHigh = [(NSNumber *)[thisYH stringValue] floatValue];
            DDXMLElement *thisYL = [insideEle elementForName:@"this_year_low"];
            CGFloat thisYearLow = [(NSNumber *)[thisYL stringValue] floatValue];
            DDXMLElement *w52h = [insideEle elementForName:@"W52_high"];
            CGFloat w52High = [(NSNumber *)[w52h stringValue] floatValue];
            DDXMLElement *w52l = [insideEle elementForName:@"W52_low"];
            CGFloat w52Low = [(NSNumber *)[w52l stringValue] floatValue];
            DDXMLElement *close1WNode = [insideEle elementForName:@"close_1W"];
            CGFloat close_1W = [(NSNumber *)[close1WNode stringValue] floatValue];
            DDXMLElement *close1MNode = [insideEle elementForName:@"close_1M"];
            CGFloat close_1M = [(NSNumber *)[close1MNode stringValue] floatValue];
            DDXMLElement *close3MNode = [insideEle elementForName:@"close_3M"];
            CGFloat close_3M = [(NSNumber *)[close3MNode stringValue] floatValue];
            DDXMLElement *close6MNode = [insideEle elementForName:@"close_6M"];
            CGFloat close_6M = [(NSNumber *)[close6MNode stringValue] floatValue];
            DDXMLElement *cnn = [insideEle elementForName:@"cn_name"];
            NSString *cnName = @"";
            if(cnn){
                cnName = [cnn stringValue];
            }
            dd = [self putDataIntoObject:name :exchange :reference :last :thisYearHigh :thisYearLow :w52High :w52Low :close_1W :close_1M :close_3M :close_6M :cnName :forHeader];
        }
        [aa addObject:dd];
        //加入陣列的動作
    }
    return aa;
}

-(NSString *)convertDecimalPoint:(CGFloat)value
{
    NSString *retVal;

    
    if(value > 10000){
        retVal = [NSString stringWithFormat:@"%.0f",value];
    }else if(value >= 1000){
        retVal = [NSString stringWithFormat:@"%.1f",value];
    }else if(value < 100){
        retVal = [NSString stringWithFormat:@"%.2f",value];
    }else if(value >= 100 && value < 1000){
        retVal = [NSString stringWithFormat:@"%.2f",value];
    }else if(value == 0) {
        retVal = [NSString stringWithFormat:@"----"];

    }else{
        retVal = [NSString stringWithFormat:@"%.f",value];
    }
    return retVal;
}

-(UIColor *)compareToZero:(CGFloat)value
{

    if(value > 0){
        return [StockConstant PriceUpColor];
    }else if(value == 0){
        return [UIColor blueColor];
    }else{//綠色
        return [StockConstant PriceDownColor];
    }
}

-(UIColor *)compareToZeroRecUse:(CGFloat)value
{
    if(value > 0){
        return [UIColor redColor];
    }else if(value == 0){
        return [UIColor blueColor];
    }else{//綠色
        return [StockConstant PriceDownColor];
    }
}
-(NSString *)formatCGFloatData:(CGFloat)value
{
    NSString *str;
    if(value < 0){
        str = [NSString stringWithFormat:@"%.2f%%",value];
    }else if(value > 0){
        str = [NSString stringWithFormat:@"+%.2f%%",value];
    }else if(value == 0){
        str = [NSString stringWithFormat:@"%.2f%%",value];

    }
    return str;
}
-(NSString *)formatCGFloatDataChangeUp:(CGFloat)value
{
    NSString *str;
    if(value < 0){
        str = [NSString stringWithFormat:@"%.1f%%",value];
    }else if(value > 0){
        str = [NSString stringWithFormat:@"+%.1f%%",value];
    }else if(value == 0){
        str = [NSString stringWithFormat:@"%.1f%%",value];
    }
    return str;
}
-(NSString *)formatCGFloatDataChange:(CGFloat)value
{
    NSString *str;
    if (value == 0) {
        str = [NSString stringWithFormat:@"0.00"];
    }else if (value > 0){
        str = [NSString stringWithFormat:@"+%.2f", value];
    }else{
        str = [NSString stringWithFormat:@"%.2f", value];
    }
    return str;
}
-(NSString *)formatCGFloatDataVolume:(CGFloat)value
{
    NSString *str;

    str = [NSString stringWithFormat:@"%.2f%%",value];
    return str;
}
-(NSString *)formatCGFloatDataRank:(CGFloat)value
{
    NSString *str;
    if(value < 0 && value > -10){
        str = [NSString stringWithFormat:@"%.2f%%",value];
    }else if(value >= 100){
        str = [NSString stringWithFormat:@"+%.0f%%",value];
    }else if(value <= -10){
        str = [NSString stringWithFormat:@"%.1f%%",value];
    }else if(value == 0){
        str = [NSString stringWithFormat:@"%.1f%%", value];
    }else if(value > 0 && value < 10){
        str = [NSString stringWithFormat:@"+%.2f%%",value];
    }else if(value >= 10){
        str = [NSString stringWithFormat:@"+%.1f%%", value];
    }

    return str;
}

-(id)putDataIntoObject:(NSString *)name :(NSString *)exchange :(CGFloat)reference :(CGFloat)last :(CGFloat)thisYearHigh :(CGFloat)thisYearLow :(CGFloat)w52High :(CGFloat)w52Low :(CGFloat)close_1W :(CGFloat)close_1M :(CGFloat)close_3M :(CGFloat)close_6M :(NSString *)cnName :(NSInteger)forHeader
{
    id bigContainer;
    switch(forHeader){
        case InternationalTargetForex:
            fft = [[forexFormat alloc] init];
            fft->name = name;
            fft->last = last;
            fft->oneDay = last==0?0:(last - reference )/last;
            fft->oneWeek = close_1W==0?0:(last - close_1W)/close_1W;
            fft->oneMonth = close_1M==0?0:(last - close_1M)/close_1M;
            fft->threeMonth = close_3M==0?0:(last - close_3M)/close_3M;
            bigContainer = fft;
            break;
        case InternationalTargetMaterial:
            mft = [[materialFormat alloc] init];
            mft->name = name;
            mft->exchange = exchange;
            mft->last = last;
            mft->oneDay = (last - reference )/last;
            mft->oneWeek = close_1W==0?0:(last - close_1W)/close_1W;
            mft->oneMonth = close_1M==0?0:(last - close_1M)/close_1M;
            bigContainer = mft;
            break;
        case InternationalTargetIndustry:
            ift = [[industryFormat alloc] init];
            if([cnName isEqualToString:@""]){
                ift->name = name;
            }else{
                ift->name = cnName;
            }
            ift->last = last;
            ift->oneDay = (last - reference )/last;
            ift->oneWeek = close_1W==0?0:(last - close_1W)/close_1W;
            ift->oneMonth = close_1M==0?0:(last - close_1M)/close_1M;
            ift->threeMonth = close_3M==0?0:(last - close_3M)/close_3M;
            ift->sixMonth = (last - close_6M)/close_6M;
            ift->w52High = w52High;
            ift->w52Low = w52Low;
            ift->thisYearHigh = thisYearHigh;
            ift->thisYearLow = thisYearLow;
            bigContainer = ift;
            break;
    }
    return bigContainer;
}

@end

@implementation theSecurityNodes_v1
@end

@implementation forexFormat
@end

@implementation materialFormat
@end

@implementation industryFormat
@end
