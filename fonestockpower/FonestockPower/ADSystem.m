//
//  ADSystem.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/2/12.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "ADSystem.h"
#import "FSFile.h"
#import <CommonCrypto/CommonDigest.h>


@implementation ADSystem

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

-(NSMutableArray *)jsonParsing:(NSData *)localData{
    NSError *jsonParseError;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:localData options:kNilOptions error:&jsonParseError];
    NSMutableArray *adArray = [[NSMutableArray alloc]init];
//    NSMutableArray *adIndexArray = [[NSMutableArray alloc]init];
//    NSMutableArray *adReturnArray = [[NSMutableArray alloc]init];
    
    if (!jsonParseError) {
        NSArray *timeStamp = [result objectForKey:@"TimeStamp"];
        NSDictionary *timesDic = [timeStamp firstObject];
        NSString *times = [timesDic objectForKey:@"times"];
        if (times != (id)[NSNull null]) {
//            NSArray *index = [result objectForKey:@"Index"];
//            NSDictionary *dic = [index firstObject];
//            FSShowResultAdObj *adObj = [[FSShowResultAdObj alloc]init];
//            adObj.uri = [dic objectForKey:@"uri"];
//            int random = 1 + arc4random() % 100;
//            adObj.img = [NSString stringWithFormat:@"%@?TimeStamp=%d", [dic objectForKey:@"img"], random];
//            [adIndexArray addObject:adObj];
            
            NSArray *ad = [result objectForKey:@"Ad"];
            if (ad) {
                for (NSDictionary *dic in ad) {
                    FSShowResultAdObj *adObj = [[FSShowResultAdObj alloc]init];
                    adObj.uri = [dic objectForKey:@"uri"];
                    int random = 1 + arc4random() % 100;
                    adObj.img = [NSString stringWithFormat:@"%@?TimeStamp=%d", [dic objectForKey:@"img"], random];
                    [adArray addObject:adObj];
                }
            }

//            [adReturnArray addObject:adIndexArray];
//            [adReturnArray addObject:adArray];
        }
    }else{
        NSLog(@"Error parsing JSON.");
    }
    return adArray;
}
-(NSMutableArray *)getLoaclAdPlist{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"DivergenceAD.plist"];
    NSMutableArray *AdArray = [[NSMutableArray alloc]init];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *rootDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        NSData *localData = rootDict[@"adData"];
        AdArray = [self jsonParsing:localData];
    }
    return AdArray;
}

-(void)saveImgToFile:(NSMutableArray *)array NewData:(BOOL)isNewData{
//    NSError *saveImgError;
//    NSURLResponse *response;
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    for (NSArray *tmpArray in array) {
        for (FSShowResultAdObj *adObj in array) {
            NSURL *imgUrl = [NSURL URLWithString:adObj.img];
            NSString *path = [NSString stringWithFormat:@"%@/ADImage/%@",[CodingUtil fonestockDocumentsPath], imgUrl.lastPathComponent];
            if (![fileManager fileExistsAtPath:path]) {
                NSURLRequest *request = [NSURLRequest requestWithURL:imgUrl];
//                NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&saveImgError];
                [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if (!connectionError) {
                        NSString *path = [NSString stringWithFormat:@"%@/ADImage/%@",[CodingUtil fonestockDocumentsPath], response.suggestedFilename];
                        if (isNewData) {
                            [fileManager removeItemAtPath:path error:nil];
                            [FSFile writeFileInCache:data subDirectoryName:@"ADImage" fileName:response.suggestedFilename];
                        }else{
                            [FSFile writeFileInCache:data subDirectoryName:@"ADImage" fileName:response.suggestedFilename];
                        }
                        dispatch_async(dispatch_get_main_queue(),^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:response.suggestedFilename object:nil];
                        });
                    }else{
                        NSLog(@"Error saveImgToFile.");
                    }
                }];
            }
        }
//    }
}

- (void)getAdConnect
{
    NSHTTPURLResponse *response = nil;
    NSError *error;
    int random = 1 + arc4random() % 100;
    NSString *jsonUrlString = [NSString stringWithFormat:@"http://www.fonestock.com/app/%@/ad/ad.json?TimeStamp=%d",[FSFonestock sharedInstance].appId, random];
    
    NSURL *url = [NSURL URLWithString:jsonUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:FS_REQUEST_TIMEOUT];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (!error && [response statusCode] == 200) {
        [self syncAdToPlist:responseData];
    }else{
        NSLog(@"Divergence getAdConnect Fail");
    }
}
-(void)syncAdToPlist:(NSData *)responseData{
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:@"DivergenceAD.plist"];
    NSDictionary *loaclDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSData *localData = loaclDict[@"adData"];
    
    if (![[responseData MD5] isEqualToString:[localData MD5]]) {
        [self saveImgFromAdPlist:responseData Path:path NewData:YES];
    }else{
        [self saveImgFromAdPlist:responseData Path:path NewData:NO];
    }
}
-(void)saveImgFromAdPlist:(NSData *)responseData Path:(NSString *)path NewData:(BOOL)isNewData{
    NSDictionary *tmpDict = [[NSDictionary alloc] initWithObjectsAndKeys:responseData,@"adData",nil];
    BOOL success = [tmpDict writeToFile:path atomically:YES];
    if(!success) NSLog(@"wirte error!!");
    [self saveImgToFile:[self getLoaclAdPlist] NewData:isNewData];
}

//-(void)adForShow{
//    if ([[self getLoaclAdPlist] firstObject] != nil) {
//        AdObj = [[self getLoaclAdPlist] objectAtIndex:0];
//        imageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/ADImage/1.jpg",[CodingUtil fonestockDocumentsPath]]];
//        if(![AdObj.uri isEqualToString:@""]){
//            [imageView addGestureRecognizer:tapRecongnizer];
//        }
//    }
//}
@end
@implementation NSData(MD5)

- (NSString*)MD5
{
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(self.bytes, (int)self.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end
