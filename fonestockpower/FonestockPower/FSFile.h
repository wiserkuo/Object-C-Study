//
//  FSFile.h
//  FSArch
//
//  Created by Connor on 2014/12/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSFile : NSObject

+ (NSURL *)cachesURLWithSubDirectoryName:(NSString *)directoryName fileName:(NSString *)fileName;
+ (BOOL)writeFileInCache:(NSData *)data subDirectoryName:(NSString *)directoryName fileName:(NSString *)fileName;
+ (BOOL)fileExistsInCacheDirectory:(NSString *)directoryName fileName:(NSString *)fileName;
+ (BOOL)deleteInCacheDirectory:(NSString *)directoryName fileName:(NSString *)fileName;
+ (NSData *)readFileInCacheDirectory:(NSString *)directoryName fileName:(NSString *)fileName;

@end
