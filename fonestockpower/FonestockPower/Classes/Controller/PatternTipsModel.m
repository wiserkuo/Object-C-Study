//
//  PatternTipsModel.m
//  FonestockPower
//
//  Created by Kenny on 2015/1/14.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "PatternTipsModel.h"
#import "ProtocolBufferIn.h"

@implementation PatternTipsModel
+(NSMutableArray *)getImgData:(NSString *)gategory
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    [dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearch WHERE gategory = ?",gategory];
        while ([message next]) {
            [imageArray addObject:[message dataForColumn:@"image_binary"]];
        }
    }];
    
    return imageArray;
}

+(NSMutableArray *)getImgName:(NSString *)gategory
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    [dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM FigureSearch WHERE gategory = ?",gategory];
        while ([message next]) {
            [nameArray addObject:[message stringForColumn:@"title"]];
        }
    }];
    
    
    return nameArray;
}


+(NSMutableDictionary *)DataFromFileIn:(NSData *)data
{
    UInt8 *tmpPtr = (UInt8 *)[data bytes];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *longArray = [[NSMutableArray alloc]init];
    NSMutableArray *shortArray = [[NSMutableArray alloc]init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dataCount" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    //多方
    UInt16 bullCount = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    for(int i = 0; i < bullCount; i++){
        PatternTipsObject *tipsObject = [[PatternTipsObject alloc] init];
        tipsObject.tipsData = [[NSMutableArray alloc] init];
        NSString *patternName = @"";
        for(int y =0; y < 6; y ++){
            char name = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
            patternName = [NSString stringWithFormat:@"%@%c", patternName, name];
        }
        patternName = [patternName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        int patternID = [[patternName stringByReplacingOccurrencesOfString:@"TPN" withString:@""]intValue];
        tipsObject.tipsName = [self getSingleImgName:patternID];
        tipsObject.tipsImg = [self getSingleImageData:patternID];
        //int tipsCount =
        [CodingUtil getUInt16:&tmpPtr needOffset:YES];
        int symbolCount = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
        tipsObject.dataCount = symbolCount;
        for(int z = 0 ; z < symbolCount; z ++){
            TipsSymbolObject *symbolObject = [[TipsSymbolObject alloc] init];
            UInt16 size = 0;
            int offset = 0;
            SymbolFormat1 *symbol = [[SymbolFormat1 alloc] initWithBuff:tmpPtr objSize:&size Offset:offset];
            tmpPtr += size;
            symbolObject.identCode = [NSString stringWithFormat:@"%c%c", symbol->IdentCode[0], symbol->IdentCode[1]];
            symbolObject.Symbol = symbol->symbol;
            symbolObject.identCodeSymbol = [NSString stringWithFormat:@"%c%c %@", symbol->IdentCode[0], symbol->IdentCode[1], symbol->symbol];
            symbolObject.fullName = symbol->fullName;
            
            symbolObject.last = [CodingUtil getUint32FromBuf:tmpPtr Offset:offset Bits:32];
            offset += 32;
            
            symbolObject.reference = [CodingUtil getUint32FromBuf:tmpPtr Offset:offset Bits:32];
            offset += 32;
            tmpPtr +=8;
            [tipsObject.tipsData addObject:symbolObject];
        }
        [longArray addObject:tipsObject];
    }
    
    NSMutableArray *sortedLongArray = [[NSMutableArray alloc]initWithArray:[longArray sortedArrayUsingDescriptors:sortDescriptors]];
    [dict setObject:sortedLongArray forKey:@"LongSystem"];
    
    //空方
    UInt16 bearCount = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    for(int i = 0; i < bearCount; i++){
        PatternTipsObject *tipsObject = [[PatternTipsObject alloc] init];
        tipsObject.tipsData = [[NSMutableArray alloc] init];
        NSString *patternName = @"";
        for(int y =0; y < 6; y ++){
            char name = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
            patternName = [NSString stringWithFormat:@"%@%c", patternName, name];
        }
        patternName = [patternName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        int patternID = [[patternName stringByReplacingOccurrencesOfString:@"TPN" withString:@""]intValue];
        //int tipsCount =
        [CodingUtil getUInt16:&tmpPtr needOffset:YES];
        int symbolCount = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
        tipsObject.tipsName = [self getSingleImgName:patternID];
        tipsObject.tipsImg = [self getSingleImageData:patternID];
        tipsObject.dataCount = symbolCount;
        for(int z = 0 ; z < symbolCount; z ++){
            TipsSymbolObject *symbolObject = [[TipsSymbolObject alloc] init];
            UInt16 size = 0;
            int offset = 0;
            SymbolFormat1 *symbol = [[SymbolFormat1 alloc] initWithBuff:tmpPtr objSize:&size Offset:offset];
            tmpPtr += size;
            symbolObject.identCode = [NSString stringWithFormat:@"%c%c", symbol->IdentCode[0], symbol->IdentCode[1]];
            symbolObject.Symbol = symbol->symbol;
            symbolObject.identCodeSymbol = [NSString stringWithFormat:@"%c%c %@", symbol->IdentCode[0], symbol->IdentCode[1], symbol->symbol];
            symbolObject.fullName = symbol->fullName;
            
            symbolObject.last = [CodingUtil getUint32FromBuf:tmpPtr Offset:offset Bits:32];
            offset += 32;
            
            symbolObject.reference = [CodingUtil getUint32FromBuf:tmpPtr Offset:offset Bits:32];
            offset += 32;
            tmpPtr +=8;
            [tipsObject.tipsData addObject:symbolObject];
        }
        [shortArray addObject:tipsObject];
    }
    
    NSMutableArray *sortedShortArray = [[NSMutableArray alloc]initWithArray:[shortArray sortedArrayUsingDescriptors:sortDescriptors]];
    [dict setObject:sortedShortArray forKey:@"ShortSystem"];

    return dict;
}

+(NSString *)getSingleImgName:(int)item
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *category;
    __block NSString *imgName = @"";
    if(item > 12){
        item -= 12;
        category = @"ShortSystem";
    }else{
        category = @"LongSystem";
    }
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT title FROM FigureSearch WHERE Gategory = ? AND itemOrder = ?",category,[NSNumber numberWithInt:item]];
        while ([message next]) {
            imgName = [message stringForColumn:@"title"];
        }
    }];
    
    return imgName;
}
+(NSData *)getSingleImageData:(int)item{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSString *category;
    __block NSData *imgData = [[NSData alloc]init];
    if(item > 12){
        item -= 12;
        category = @"ShortSystem";
    }else{
        category = @"LongSystem";
    }
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT image_binary FROM FigureSearch WHERE Gategory = ? AND itemOrder = ?",category,[NSNumber numberWithInt:item]];
        while ([message next]) {
            imgData = [message dataForColumn:@"image_binary"];
        }
    }];
    
    return imgData;
}

+(NSString *)getFileTime:(NSString *)targetFile
{
    NSString *fileName = targetFile;
    NSArray *fileComponents = [fileName componentsSeparatedByString:@"_"];
    if ([fileComponents count] == 4) {
        NSString *dateTimeString = [fileComponents objectAtIndex:2];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd-HHmm"];
        NSDate *dataDateTime = [formatter dateFromString:dateTimeString];
        
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            [formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        }
        else {
            [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        }
        
        return [NSString stringWithFormat:@"%@  %@", NSLocalizedStringFromTable(@"更新時間", @"DivergenceTips", @"更新時間"), [formatter stringFromDate:dataDateTime]];
    }
    return nil;
}

+(NSString *)getTheFileInMyFileFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appendDocumentsDirectory = [documentsDirectory stringByAppendingString:@"/MyFile"];
    NSError * error;
    NSArray * directoryContents =  [[NSFileManager defaultManager]
                                    contentsOfDirectoryAtPath:appendDocumentsDirectory error:&error];
    return directoryContents[0];
}

-(void)protocolBufferCallBack:(ProtocolBufferIn *)sender
{
    self.downloadURL = sender.downLoadURL;
    
    if ([self.delegate respondsToSelector:@selector(loadDidFinishWithData:)]) {
        [self.delegate loadDidFinishWithData:self];
    }
}
@end

@implementation TipsSymbolObject
@end
@implementation PatternTipsObject
@end
