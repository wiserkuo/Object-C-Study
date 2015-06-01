//
//  FSDivergenceModel.m
//  DivergenceStock
//
//  Created by Connor on 2014/12/1.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSDivergenceModel.h"
#import "ProtocolBufferIn.h"
#import "Tips_location_down.pb.h"
#import "Tips_location_up.pb.h"
#import "ProtocolBufferOut.h"
#import "ProtocolBufferIn.h"
#import "FSShowResultViewController.h"

@implementation FSDivergenceModel

+ (NSArray *)figureTheTick:(UInt16)target
{
    NSString *str1, *str2, *str3, *str4, *str5;
    str5 = (target & (1 << 0))?@"true":@"";
    str4 = (target & (1 << 1))?@"true":@"";
    str3 = (target & (1 << 2))?@"true":@"";
    str2 = (target & (1 << 3))?@"true":@"";
    str1 = (target & (1 << 4))?@"true":@"";
    NSArray *ar = [NSArray arrayWithObjects:str1, str2, str3, str4, str5,nil];
    return ar;
}

+ (NSString*) allocNSStringByBuffer:(UInt8*)buffer Offset:(int)offset Length:(UInt32)len Encoding:(NSStringEncoding)encoding
{
    char *tmpMsg = malloc(len+1);
    tmpMsg[len] = 0;
    for(int i=0 ; i<len ; i++)
        tmpMsg[i] = [CodingUtil getUint8FromBuf:buffer++ Offset:offset Bits:8];
    int tmpLen = (int)strlen(tmpMsg);
    NSString *string = nil;
    if(tmpLen)
        string = [[NSString alloc] initWithBytes:tmpMsg length:tmpLen encoding:encoding];
    free(tmpMsg);
    return string;	//別人要release
}

+(NSString *)separatePositiveOrNegative:(float)value
{
    value = value / 100.0;
    if(value < 0){
        return [NSString stringWithFormat:@"%.2f%%",value];
    }else if(value == 0){
        return [NSString stringWithFormat:@"%.2f%%",value];
    }else{
        return [NSString stringWithFormat:@"+%.2f%%",value];
    }
}

+(UIColor *)makeItGreenOrRed:(float)value
{
    if(value > 0){
        return [StockConstant PriceUpColor];//[UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.5 alpha:1.0];
    }else if(value == 0){
        return [UIColor blueColor];
    }else{
        return [StockConstant PriceDownColor];//[UIColor redColor];
    }
}

+(BOOL)isItYesOrNo:(NSArray *)array :(NSInteger)firstObjIndex :(NSInteger)indexNum
{
    return [[[array objectAtIndex:firstObjIndex] objectAtIndex:indexNum] isEqualToString:@""];
}

+(ReturnTwoArrayObjects *)DataFromServerIn:(NSData *)data// storeBull:(NSMutableArray *)storeBull storeBear:(NSMutableArray *)storeBear
{
    ReturnTwoArrayObjects *rtfObj = [[ReturnTwoArrayObjects alloc] init];
    rtfObj.storeBear = [[NSMutableArray alloc] init];
    rtfObj.storeBull = [[NSMutableArray alloc] init];
    
    UInt8 *tmpPtr = (UInt8 *)[data bytes];
    int gg = 0;
    
    //因為整份電文共有兩組資料，所以gg 才給int 且小於2 就繼續，如果未來資料增加到三組，除了改< 2 之外，最下面的判斷儲存在哪個陣列也需改寫
    while(gg < 2){
        UInt16 i_count = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
  
        for(int i = 0; i < i_count; i++){
            CompleteStuff * csff = [[CompleteStuff alloc] init];
            UInt16 size = 0;
            int offset = 0;
            csff.symbol = [[SymbolFormat1 alloc] initWithBuff:tmpPtr objSize:&size Offset:offset];
            tmpPtr += size;

            csff.lastPrice = [CodingUtil getUint32FromBuf:tmpPtr Offset:offset Bits:32];
            offset += 32;

            csff.refPrice = [CodingUtil getUint32FromBuf:tmpPtr Offset:offset Bits:32];
            offset += 32;
            tmpPtr +=8;
          //  csff.divergenceObject = [[NSMutableArray alloc] init];
            csff.divergenceObject = [[NSMutableArray alloc]initWithObjects:@"", @"", @"", @"", @"", nil];
            UInt16 i_count_div = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
            for(int j = 0; j < i_count_div; j++){
                ContainerForThreeObjects * cfto = [[ContainerForThreeObjects alloc] init];
                //cfto.divIDTick = [self figureTheTick:[self getUInt16:&tmpPtr needOffset:YES]];
                cfto.divPointerID = [NSString stringWithFormat:@"%d",[CodingUtil getUInt16:&tmpPtr needOffset:YES]];
                cfto.startDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
                cfto.endDate = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
//                [csff.divergenceObject addObject:cfto];
                int a = [cfto.divPointerID intValue];
                @try {
                    [csff.divergenceObject setObject:cfto atIndexedSubscript:a-1];
                }
                @catch (NSException *exception) {
                    NSLog(@"eeee %@",exception);
                    [csff.divergenceObject removeAllObjects];
                    return nil;
                }
            }
            //判斷儲存在哪個陣列
            if(gg == 0){
                [rtfObj.storeBull addObject:csff];
            }else{
                [rtfObj.storeBear addObject:csff];
            }
        }
        
        gg++;
    }
    return rtfObj;
}

-(void)protocolBufferCallBack:(ProtocolBufferIn *)sender
{
    self.downloadURL = sender.downLoadURL;
    
    if ([self.delegate respondsToSelector:@selector(loadDidFinishWithData:)]) {
        [self.delegate loadDidFinishWithData:self];
    }
}

+(NSURLRequest *)openExplanation{
    
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString *htmlPath = @"https://www.fonestock.com/app/%@/edu/1.html";
    NSString *htmlFile = [NSString stringWithFormat:htmlPath,appid];
    
    NSURL *url = [NSURL URLWithString:htmlFile];
    NSURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    return request;
}

-(NSString *)getFileTime:(NSString *)targetFile
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

-(NSString *)getTheFileInMyFileFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appendDocumentsDirectory = [documentsDirectory stringByAppendingString:@"/MyFile"];
    NSError * error;
    NSArray * directoryContents =  [[NSFileManager defaultManager]
                                    contentsOfDirectoryAtPath:appendDocumentsDirectory error:&error];
    return directoryContents[0];
}

- (void)reloadProtocolBuffersData {
    //tips_localtion_upBuilder 這些class是connor 做的，我還不會
    //在這裡將上行的protocolbuffer 建立起來，並使用電文將其送出
    tips_location_upBuilder *builder = [tips_location_up builder];
    FSFonestock *fonestock = [FSFonestock sharedInstance];
    [builder setType:(int)fonestock.TipsLocationUpdataType];
    tips_location_up *tips = [builder build];
    //電文的部份
    ProtocolBufferOut *pbo = [[ProtocolBufferOut alloc] initWithUpStream:tips.data];
    [FSDataModelProc sendData:self WithPacket:pbo];
}

@end

/*				Symbol Format 1					*/
//
//@implementation SymbolFormat1
//
//- (id)initWithBuff:(UInt8*)buff objSize:(UInt16*)size Offset:(int)offset
//{
//    if(self = [super init])
//    {
//        *size = 0;
//        UInt8 *tmpPtr = buff;
//        IdentCode[0] = [FSDivergenceModel getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
//        IdentCode[1] = [FSDivergenceModel getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
//        symbolLength = [FSDivergenceModel getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
//        if(symbolLength)
//            symbol = [FSDivergenceModel allocNSStringByBuffer:tmpPtr Offset:offset Length:symbolLength Encoding:NSUTF8StringEncoding];
//        else
//            symbol = @"";
//        tmpPtr += symbolLength;
//        typeID = [FSDivergenceModel getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
//        fullNameLength = [FSDivergenceModel getUint8FromBuf:tmpPtr++ Offset:offset Bits:8];
//        if(fullNameLength)
//            fullName = [FSDivergenceModel allocNSStringByBuffer:tmpPtr Offset:offset Length:fullNameLength Encoding:NSUTF8StringEncoding];
//        else
//            fullName = @"";
//        *size = 5+symbolLength+fullNameLength;
//    }
//    return self;
//}
//
//@end

@implementation ContainerForThreeObjects
@end
@implementation CompleteStuff
@end
@implementation FSShowResultAdObj
@end
@implementation ReturnTwoArrayObjects
@end