//
//  FSFile.m
//  FSArch
//
//  Created by Connor on 2014/12/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSFile.h"

@implementation FSFile

+ (id)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FSFile alloc] init];
    });
    
    return sharedInstance;
}

+ (NSURL *)cachesURLWithSubDirectoryName:(NSString *)directoryName fileName:(NSString *)fileName {
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:documentsPath isDirectory:YES];
    NSURL *documentsSubDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:directoryName isDirectory:YES];
    
    NSError *error;
    // 檢查資料夾存不存在
    if (![documentsSubDirectoryURL checkResourceIsReachableAndReturnError:&error]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // 建立子資料夾
        [fileManager createDirectoryAtURL:documentsSubDirectoryURL withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (fileName != nil) {
        documentsSubDirectoryURL = [documentsSubDirectoryURL URLByAppendingPathComponent:fileName];
    }
    return documentsSubDirectoryURL;
}

+ (BOOL)writeFileInCache:(NSData *)data subDirectoryName:(NSString *)directoryName fileName:(NSString *)fileName {
    if(!data) return NO;
    NSError *error;
    NSURL *documentURL = [FSFile cachesURLWithSubDirectoryName:directoryName fileName:fileName];
    NSLog(@"寫檔路徑: %@", [documentURL path]);
    [data writeToURL:documentURL options:NSDataWritingFileProtectionNone error:&error];
    
    if (error) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)fileExistsInCacheDirectory:(NSString *)directoryName fileName:(NSString *)fileName {
    NSURL *url = [FSFile cachesURLWithSubDirectoryName:directoryName fileName:fileName];
    
    NSError *error;
    // 檢查檔案存不存在
    if ([url checkResourceIsReachableAndReturnError:&error]) {
        return YES;
    }
    return NO;
}

+ (BOOL)deleteInCacheDirectory:(NSString *)directoryName fileName:(NSString *)fileName {
    NSError *error;
    NSURL *url = [FSFile cachesURLWithSubDirectoryName:directoryName fileName:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:url error:&error];
    
    if (error) {
        return NO;
    } else {
        return YES;
    }
}

+ (NSData *)readFileInCacheDirectory:(NSString *)directoryName fileName:(NSString *)fileName {
    
    NSURL *url = [FSFile cachesURLWithSubDirectoryName:directoryName fileName:fileName];
    
//    NSData *fileData = [NSData dataWithContentsOfFile:url.absoluteString];
    NSData *fileData1 = [NSData dataWithContentsOfURL:url];
    return fileData1;
}

@end
